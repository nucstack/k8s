FROM alpine:3

ARG ANSIBLE_VERSION=2.9
ARG CONFTEST_VERSION=0.23.0
ARG FLUX_VERSION=0.13.2
ARG HELM_VERSION=3.5.4
ARG KUBECTL_VERSION=1.21.0
ARG KUBEVAL_VERSION=0.15.0
ARG KUSTOMIZE_VERSION=4.1.0
ARG SOPS_VERSION=3.7.1
ARG TASK_VERSION=3.4.2
ARG TERRAFORM_VERSION=0.14.8

WORKDIR /

ENV DEBIAN_FRONTEND=noninteractive
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1

RUN apk --update --no-cache add --virtual build-dependencies \
    apache2-utils \
    bash \
    build-base \
    ca-certificates \
    curl \
    gettext \
    git \
    git-crypt \
    gnupg \
    jq \    
    libffi-dev \
    libintl \
    openssh-client \
    openssl \
    openssl-dev \
    pinentry \
    python3-dev \
    python3 \
    py-pip \
    rsync \
    shellcheck \
    sshpass \
    sudo \
    unzip \
    yq

# Install ansible
RUN pip3 install --upgrade pip cffi && \
    pip3 install ansible==${ANSIBLE_VERSION} \
        jinja2==2.11.3 \
        netaddr==0.7.19 \
        pbr==5.4.4 \
        jmespath==0.9.5 \
        ruamel.yaml==0.16.10 \
        pyOpenSSL \
        pre-commit

RUN ansible-galaxy collection install community.kubernetes && \
    ansible-galaxy collection install community.general

# Install conftest
RUN curl -sL -o conftest_Linux_x86_64.tar.gz https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz && \
    tar -C /usr/bin -xvzf conftest_Linux_x86_64.tar.gz && \
    chmod +x /usr/bin/conftest

# Install envsubst
RUN cp /usr/bin/envsubst /usr/local/bin/envsubst

# Install flux
RUN curl -sL -o flux.tar.gz https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_amd64.tar.gz && \
    tar -C /usr/bin -xvzf flux.tar.gz && \
    chmod +x /usr/bin/flux

# Install helm
RUN curl  -sL -o helm-linux-amd64.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \    
    tar -xzvf helm-linux-amd64.tar.gz -C /usr/bin --strip-components=1 linux-amd64/helm && \
    chmod +x /usr/bin/helm

# Install kubectl
RUN curl -LO https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    mv kubectl /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

# Install kubeval
RUN curl -sL -o kubeval-linux-amd64.tar.gz https://github.com/instrumenta/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz && \
    tar -C /usr/bin -xvzf kubeval-linux-amd64.tar.gz && \
    rm -rf kubeval-linux-amd64.tar.gz && \
    chmod +x /usr/bin/kubeval

# Install kustomize
RUN curl -sL -o kustomize_linux_amd64.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz && \
    tar -C /usr/bin -xvzf kustomize_linux_amd64.tar.gz && \
    rm -rf kustomize_linux_amd64.tar.gz && \
    chmod +x /usr/bin/kustomize

# Install sops
RUN curl -sL -o sops https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux && \
    mv sops /usr/bin && chmod +x /usr/bin/sops

# Install task
RUN curl -sL -o task_linux_amd64.tar.gz https://github.com/go-task/task/releases/download/v${TASK_VERSION}/task_linux_amd64.tar.gz && \
    tar -C /usr/bin -xvzf task_linux_amd64.tar.gz && \
    rm -rf task_linux_amd64.tar.gz && \
    chmod +x /usr/bin/task

# Install terraform
RUN curl -sL -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip  && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/bin/terraform && \
    chmod +x /usr/bin/terraform && \
    rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Aliases because humans might use this :shrug:
RUN echo 'alias k="kubectl"' >> ~/.bashrc

# Cleanup
RUN rm -rf /var/cache/apk/* 

CMD bash
