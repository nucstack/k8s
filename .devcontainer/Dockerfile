# dependencies
FROM docker.io/fluxcd/flux-cli:v0.31.1 as flux
FROM docker.io/hadolint/hadolint:v2.10.0 as hadolint
FROM docker.io/alpine/helm:3.9.0 as helm
FROM docker.io/bitnami/kubectl:1.24.2 as kubectl
FROM docker.io/cytopia/kubeval:0.16 as kubeval
FROM docker.io/zegl/kube-score:v1.14.0 as kube-score
FROM k8s.gcr.io/kustomize/kustomize:v4.5.5 as kustomize
FROM docker.io/openfaas/faas-cli:0.12.14 as openfaas
FROM docker.io/prom/alertmanager:v0.24.0 as prom-am
FROM docker.io/prom/prometheus:v2.36.2 as prom
FROM docker.io/hashicorp/terraform:1.2.3 as terraform
FROM docker.io/aquasec/trivy:0.29.2 as trivy
FROM docker.io/hashicorp/vault:1.10.4 as vault
FROM docker.io/velero/velero:v1.8.1 as velero
FROM docker.io/mikefarah/yq:4.25.2 as yq

# base image
FROM docker:20.10.17-dind-rootless

ENV DEBIAN_FRONTEND=noninteractive \
    EDITOR=nano \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    KUBENT_VERSION=0.5.1

USER root

# install persisted devcontainer dependencies
RUN apk --update --no-cache add \
    apache2-utils \
    bash \
    build-base \
    ca-certificates \
    curl \
    docker \
    gettext \
    git \
    git-crypt \
    gnupg \
    jq \
    libffi-dev \
    libintl \
    nano \
    openssh-client \
    openssl \
    openssl-dev \
    py-cryptography \
    python3 \
    python3-dev \
    py3-pip \
    rsync \
    shadow \
    shellcheck \
    sshpass \
    sudo \
    unzip \
    zsh

# install pip/ansible dependencies
COPY pip-requirements.txt ansible-requirements.yml /tmp/
RUN pip3 install --no-cache-dir --requirement /tmp/pip-requirements.txt && \
    ansible-galaxy install -r /tmp/ansible-requirements.yml --ignore-errors

# install binary releases
COPY binary-releases.sh /tmp/binary-releases.sh
RUN /tmp/binary-releases.sh

COPY --from=flux       /usr/local/bin/flux              /usr/local/bin/flux
COPY --from=hadolint   /bin/hadolint                    /usr/local/bin/hadolint
COPY --from=helm       /usr/bin/helm                    /usr/local/bin/helm
COPY --from=kubectl    /opt/bitnami/kubectl/bin/kubectl /usr/local/bin/kubectl
COPY --from=kubeval    /usr/bin/kubeval                 /usr/local/bin/kubeval
COPY --from=kube-score /kube-score                      /usr/local/bin/kube-score
COPY --from=kustomize  /app/kustomize                   /usr/local/bin/kustomize
COPY --from=terraform  /bin/terraform                   /usr/local/bin/terraform
COPY --from=openfaas   /home/app/faas-cli               /usr/local/bin/faas-cli
COPY --from=prom       /bin/promtool                    /usr/local/bin/promtool
COPY --from=prom-am    /bin/amtool                      /usr/local/bin/amtool
COPY --from=trivy      /usr/local/bin/trivy             /usr/local/bin/trivy
COPY --from=vault      /bin/vault                       /usr/local/bin/vault
COPY --from=velero     /velero                          /usr/local/bin/velero
COPY --from=yq         /usr/bin/yq                      /usr/local/bin/yq

RUN wget https://github.com/doitintl/kube-no-trouble/releases/download/${KUBENT_VERSION}/kubent-${KUBENT_VERSION}-linux-amd64.tar.gz && \
    tar -xzf kubent-${KUBENT_VERSION}-linux-amd64.tar.gz -C /usr/local/bin && rm kubent-${KUBENT_VERSION}-linux-amd64.tar.gz

# Setup user/profile
RUN mkdir -p /etc/sudoers.d && \
    echo rootless ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/rootless && \
    chmod 0440 /etc/sudoers.d/rootless && \
    usermod --shell /bin/zsh rootless

COPY --chown=rootless .zshrc /home/rootless
RUN git clone --single-branch --depth 1 https://github.com/robbyrussell/oh-my-zsh.git /home/rootless/.oh-my-zsh > /dev/null && \
    rm -rf /home/rootless/.oh-my-zsh/.git && \
    chown -R rootless:1000 /home/rootless/.oh-my-zsh && \
    chmod -R 700 /home/rootless/.oh-my-zsh && \
    cp -R /root/.ansible /home/rootless && chown -R rootless:1000 /home/rootless && \
    rm -rf /var/cache/apk/*

WORKDIR /home/rootless
USER rootless

RUN helm plugin install https://github.com/databus23/helm-diff

ENV DOCKER_HOST=unix:///var/run/user/1000/docker.sock

HEALTHCHECK NONE
