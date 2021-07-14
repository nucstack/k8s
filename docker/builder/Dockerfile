FROM alpine:3.14

ARG ANSIBLE_VERSION=2.10
ARG CONFTEST_VERSION=0.24.0
ARG FLUX_VERSION=0.16.0
ARG HELM_VERSION=3.5.4
ARG LINKERD_VERSION=2.10.2
ARG KUBECTL_VERSION=1.21.0
ARG KUBEVAL_VERSION=0.15.0
ARG KUSTOMIZE_VERSION=4.1.3
ARG PACKER_VERSION=1.7.2
ARG SOPS_VERSION=3.7.1
ARG STEP_VERSION=0.15.16
ARG TASK_VERSION=3.4.2
ARG TERRAFORM_VERSION=0.14.8

ARG ANSIBLE_ROLE_K3S=2.9.1
ARG ANSIBLE_COLLECTION_GENERAL=3.1.0
ARG ANSIBLE_COLLECTION_K8S=1.2.1
ARG ANSIBLE_ROLE_KERNEL=1.2.4

WORKDIR /

ENV DEBIAN_FRONTEND=noninteractive
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1

# Install build deps
RUN apk --update --no-cache add --virtual .build-dep \
    bash \
    build-base \
    gettext \
    libffi-dev \
    libintl \
    openssl-dev \
    python3-dev \
    unzip && \
    # Install deps
    apk --update --no-cache add \
    apache2-utils \
    ca-certificates \
    curl \
    git \
    git-crypt \
    gnupg \
    jq \
    openssh-client \
    openssl \
    python3 \
    py3-pip \
    rsync \
    shellcheck \
    sshpass \
    sudo \
    yq

# Install required binaries
RUN \
    # ansible
    pip3 install --upgrade pip cffi && \
    pip3 install ansible==${ANSIBLE_VERSION} && \
    pip3 install mitogen ansible-lint jmespath netaddr checkov && \
    # ansible collections
    ansible-galaxy collection install "community.kubernetes:==${ANSIBLE_COLLECTION_K8S}" && \
    ansible-galaxy collection install "community.general:==${ANSIBLE_COLLECTION_GENERAL}" && \
    ansible-galaxy install "xanmanning.k3s,v${ANSIBLE_ROLE_K3S}" && \
    ansible-galaxy install "accelize.linux_kernel,${ANSIBLE_ROLE_KERNEL}"
RUN \
    # conftest
    curl -sL -o conftest_Linux_x86_64.tar.gz https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz && \
    tar -C /usr/bin -xvzf conftest_Linux_x86_64.tar.gz && \
    chmod +x /usr/bin/conftest && \
    # envsubst
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    # flux
    curl -sL -o flux.tar.gz https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_amd64.tar.gz && \
    tar -C /usr/bin -xvzf flux.tar.gz && \
    chmod +x /usr/bin/flux && \
    # helm
    curl  -sL -o helm-linux-amd64.tar.gz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \    
    tar -xzvf helm-linux-amd64.tar.gz -C /usr/bin --strip-components=1 linux-amd64/helm && \
    chmod +x /usr/bin/helm && \
    # kubectl
    curl -sL -o usr/bin/kubectl https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x /usr/bin/kubectl && \
    # kubeval
    curl -sL -o kubeval-linux-amd64.tar.gz https://github.com/instrumenta/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz && \
    tar -C /usr/bin -xvzf kubeval-linux-amd64.tar.gz && \
    rm -rf kubeval-linux-amd64.tar.gz && \
    chmod +x /usr/bin/kubeval && \
    # kustomize
    curl -sL -o kustomize_linux_amd64.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz && \
    tar -C /usr/bin -xvzf kustomize_linux_amd64.tar.gz && \
    rm -rf kustomize_linux_amd64.tar.gz && \
    chmod +x /usr/bin/kustomize && \
    # linkerd
    curl -sL -o linkerd https://github.com/linkerd/linkerd2/releases/download/stable-${LINKERD_VERSION}/linkerd2-cli-stable-${LINKERD_VERSION}-linux-amd64 && \
    mv linkerd /usr/bin && chmod +x /usr/bin/linkerd && \
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
    rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Cleanup
RUN rm -rf /var/cache/apk/*

RUN addgroup -S builder && adduser -S builder -G builder
USER builder

HEALTHCHECK NONE

CMD bash