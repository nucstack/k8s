FROM docker:20.10.8-dind-rootless

# default binary versions
ARG FLUX_VERSION=0.17.0
ARG HELM_VERSION=3.5.4
ARG KIND_VERSION=0.11.1
ARG KUBECTL_VERSION=1.21.3
ARG KUBEVAL_VERSION=0.15.0
ARG KUBELOGIN_VERSION=1.25.0
ARG KUSTOMIZE_VERSION=4.1.3
ARG KUSTOMIZER_VERSION=1.0.0
ARG PACKER_VERSION=1.7.2
ARG SOPS_VERSION=3.7.1
ARG STEP_VERSION=0.15.16
ARG TASK_VERSION=3.6.0
ARG TERRAFORM_VERSION=0.15.5
ARG VELERO_VERSION=1.6.3

ENV DEBIAN_FRONTEND=noninteractive \
    CRYPTOGRAPHY_DONT_BUILD_RUST=1 \
    EDITOR=nano \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

USER root

# install persisted devcontainer dependencies
RUN apk --update --no-cache add \
    apache2-utils \
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
    python3 \
    python3-dev \
    py3-pip \
    rsync \
    shadow \
    shellcheck \
    sshpass \
    sudo \
    unzip \
    yq \
    zsh


# install pip/ansible dependencies
COPY pip-requirements.txt ansible-requirements.yml /tmp/
RUN pip3 install --requirement /tmp/pip-requirements.txt
RUN ansible-galaxy install -r /tmp/ansible-requirements.yml

# install required binaries
RUN \
    # envsubst
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    # flux
    curl -sL -o flux.tar.gz https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_amd64.tar.gz && \
    tar -C /usr/bin -xvzf flux.tar.gz && \
    rm -rf flux.tar.gz && \
    chmod +x /usr/bin/flux && \
    # helm
    curl  -sL -o helm-linux-amd64.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -xzvf helm-linux-amd64.tar.gz -C /usr/bin --strip-components=1 linux-amd64/helm && \
    rm -rf helm-linux-amd64.tar.gz && \
    chmod +x /usr/bin/helm && \
    # kind
    curl -sL -o usr/bin/kind https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64 && \
    chmod +x usr/bin/kind && \
    # kubectl
    curl -sL -o usr/bin/kubectl https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x /usr/bin/kubectl && \
    # kubeval
    curl -sL -o kubeval-linux-amd64.tar.gz https://github.com/instrumenta/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz && \
    tar -C /usr/bin -xvzf kubeval-linux-amd64.tar.gz && \
    rm -rf kubeval-linux-amd64.tar.gz && \
    chmod +x /usr/bin/kubeval && \
    # kubelogin
    curl -sL -o kubelogin_linux_amd64.zip https://github.com/int128/kubelogin/releases/download/v${KUBELOGIN_VERSION}/kubelogin_linux_amd64.zip && \
    unzip kubelogin_linux_amd64.zip && \
    mv kubelogin /usr/bin/kubectl-oidc_login && \
    chmod +x /usr/bin/kubectl-oidc_login && \
    rm -rf kubelogin_linux_amd64.zip && \
    # kustomize
    curl -sL -o kustomize_linux_amd64.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz && \
    tar -C /usr/bin -xvzf kustomize_linux_amd64.tar.gz && \
    rm -rf kustomize_linux_amd64.tar.gz && \
    chmod +x /usr/bin/kustomize && \
    # kustomizer
    curl -sL -o kustomizer_linux_amd64.tar.gz https://github.com/stefanprodan/kustomizer/releases/download/v${KUSTOMIZER_VERSION}/kustomizer_${KUSTOMIZER_VERSION}_linux_amd64.tar.gz && \
    tar -C /usr/bin -xvzf kustomizer_linux_amd64.tar.gz && \
    rm -rf kustomizer_linux_amd64.tar.gz && \
    chmod +x /usr/bin/kustomizer && \
    # packer
    curl -sL -o packer_${PACKER_VERSION}_linux_amd64.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip  && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip && \
    mv packer /usr/bin/packer && \
    chmod +x /usr/bin/packer && \
    rm -rf packer_${PACKER_VERSION}_linux_amd64.zip && \
    # sops
    curl -sL -o sops https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux && \
    mv sops /usr/bin && chmod +x /usr/bin/sops && \
    # step
    curl -sL -o step.tar.gz https://github.com/smallstep/cli/releases/download/v${STEP_VERSION}/step_linux_${STEP_VERSION}_amd64.tar.gz && \
    tar -xzvf step.tar.gz -C /usr/bin --strip-components=2 step_${STEP_VERSION}/bin/step && \
    rm -rf step.tar.gz step_${STEP_VERSION} && \
    chmod +x /usr/bin/step && \
    # task
    curl -sL -o task_linux_amd64.tar.gz https://github.com/go-task/task/releases/download/v${TASK_VERSION}/task_linux_amd64.tar.gz && \
    tar -C /usr/bin -xvzf task_linux_amd64.tar.gz && \
    rm -rf task_linux_amd64.tar.gz && \
    chmod +x /usr/bin/task && \
    # terraform
    curl -sL -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip  && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/bin/terraform && \
    chmod +x /usr/bin/terraform && \
    rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    # velero
    curl -sL -o velero_linux_amd64.tar.gz https://github.com/vmware-tanzu/velero/releases/download/v${VELERO_VERSION}/velero-v${VELERO_VERSION}-linux-amd64.tar.gz && \
    tar -C /tmp -xvzf velero_linux_amd64.tar.gz && \
    mv /tmp/velero-v${VELERO_VERSION}-linux-amd64/velero /usr/bin && \
    rm -rf velero_linux_amd64.tar.gz && rm -rf /tmp/velero-v${VELERO_VERSION}-linux-amd64 && \
    chmod +x /usr/bin/velero

HEALTHCHECK NONE

RUN mkdir -p /etc/sudoers.d && \
    echo rootless ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/rootless && \
    chmod 0440 /etc/sudoers.d/rootless

# Setup shells
RUN usermod --shell /bin/zsh rootless

COPY --chown=rootless .zshrc /home/rootless
RUN git clone --single-branch --depth 1 https://github.com/robbyrussell/oh-my-zsh.git /home/rootless/.oh-my-zsh &> /dev/null && \
    rm -rf /home/rootless/.oh-my-zsh/.git && \
    chown -R rootless:1000 /home/rootless/.oh-my-zsh && \
    chmod -R 700 /home/rootless/.oh-my-zsh && \
    cp -R /root/.ansible /home/rootless && chown -R rootless:1000 /home/rootless

# cleanup
RUN rm -rf /var/cache/apk/*

WORKDIR /home/rootless
USER rootless
ENV DOCKER_HOST=unix:///var/run/user/1000/docker.sock
