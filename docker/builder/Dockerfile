FROM alpine:3

ARG ANSIBLE_VERSION=2.9
ARG CONFTEST_VERSION=0.23.0
ARG FLUX_VERSION=0.12.3
ARG HELM_VERSION=3.5.4
ARG K3SUP_VERSION=0.10.2
ARG KUBECTL_VERSION=1.21.0
ARG KUBESEAL_VERSION=0.15.0
ARG KUBEVAL_VERSION=0.15.0
ARG KUSTOMIZE_VERSION=4.1.0
ARG SOPS_VERSION=3.7.1
ARG TASK_VERSION=3.4.2
ARG TERRAFORM_VERSION=0.14.8

WORKDIR /

ENV DEBIAN_FRONTEND=noninteractive
ENV CRYPTOGRAPHY_DONT_BUILD_RUST=1

RUN apk --update --no-cache add \
  ca-certificates \
  openssh-client \
  bash \
  curl \
  gnupg \
  pinentry \
  git \
  jq \
  yq \
  shellcheck \
  git-crypt \
  apache2-utils \
  sshpass \
  sudo

RUN apk --update --no-cache add --virtual build-dependencies

# Install envsubst
RUN apk add --update libintl && \
    apk add --virtual build-dependencies gettext &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst

# Install kubectl
RUN curl -LO https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    mv kubectl /usr/bin/kubectl && \
    chmod +x /usr/bin/kubectl

# Install helm
RUN apk add --update --no-cache curl unzip ca-certificates && \
    curl -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar xvz && \
    mv linux-amd64/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-amd64

# Install kubeseal
RUN curl -sL -o /usr/bin/kubeseal https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-linux-amd64 && \
  chmod +x /usr/bin/kubeseal

# Install flux
RUN curl -sL -o flux.tar.gz https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_amd64.tar.gz && \
  tar -C /usr/bin -xvzf flux.tar.gz && \
  chmod +x /usr/bin/flux

# Install terraform
RUN curl -sL -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip  && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/bin/terraform && \
    chmod +x /usr/bin/terraform && \
    rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install kustomize
RUN curl -sL -o kustomize_linux_amd64.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_amd64.tar.gz && \
    tar -C /usr/bin -xvzf kustomize_linux_amd64.tar.gz && \
    chmod +x /usr/bin/kustomize

# Install kubeval
RUN curl -sL -o kubeval-linux-amd64.tar.gz https://github.com/instrumenta/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz && \
    tar -C /usr/bin -xvzf kubeval-linux-amd64.tar.gz && \
    chmod +x /usr/bin/kubeval

# Install k3sup
RUN curl -sL -o k3sup https://github.com/alexellis/k3sup/releases/download/${K3SUP_VERSION}/k3sup && \
    mv k3sup /usr/bin && chmod +x /usr/bin/k3sup

# Install ansible
RUN apk --update add git python3 py-pip openssl ca-certificates && \
    apk --update add --virtual build-dependencies python3-dev libffi-dev openssl-dev build-base

RUN pip3 install --upgrade pip cffi && \
    pip3 install ansible==${ANSIBLE_VERSION} \
        jinja2==2.11.3 \
        netaddr==0.7.19 \
        pbr==5.4.4 \
        jmespath==0.9.5 \
        ruamel.yaml==0.16.10 \
        pyOpenSSL \
        pre-commit

# Install conftest
RUN curl -sL -o conftest_Linux_x86_64.tar.gz https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz && \
    tar -C /usr/bin -xvzf conftest_Linux_x86_64.tar.gz && \
    chmod +x /usr/bin/conftest

RUN ansible-galaxy collection install community.kubernetes && \
    ansible-galaxy collection install community.general && \
    ansible-galaxy install geerlingguy.postgresql

# Install sops
RUN curl -sL -o sops https://github.com/mozilla/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux && \
    mv sops /usr/bin && chmod +x /usr/bin/sops

# Install task
RUN curl -sL -o task_linux_amd64.tar.gz https://github.com/go-task/task/releases/download/v${TASK_VERSION}/task_linux_amd64.tar.gz && \
    tar -C /usr/bin -xvzf task_linux_amd64.tar.gz && \
    chmod +x /usr/bin/task

# Aliases because humans might use this :shrug:
RUN echo 'eval "$(direnv hook bash)"' >> ~/.bashrc && \
    echo 'alias k="kubectl"' >> ~/.bashrc && \
    echo 'alias t="terraform"' >> ~/.bashrc && \
    echo 'alias f="flux"' >> ~/.bashrc && \
    echo 'alias s="sops"' >> ~/.bashrc && \
    echo 'alias reconcile="flux reconcile source git -n flux-system flux-system"' >> ~/.bashrc

# Cleanup
RUN rm -rf /var/cache/apk/* 

CMD bash