# user in container
ARG CONTAINER_USER=user
ARG CONTAINER_GROUP=user

ARG CONTAINER_USER_ID=1000
ARG CONTAINER_GROUP_ID=1000

# set location of workspace directory
# (temporary space within container image)
ARG WORKSPACE_ROOT_DIR="/home/${CONTAINER_USER}"

# Debian release and options
ARG DEBIAN_RELEASE=trixie-debian13-dev
ARG DEBIAN_FRONTEND=noninteractive

# ansible CLI tools versions
ARG ANSIBLE_CLI_VERSION=v2.21.1

# cert-manager CLI version
ARG CM_CTL_CLI_VERSION=v2.5.0

# Hetzner Cloud CLI version
ARG HCLOUD_CLI_VERSION=v1.66.0

# Helm version
ARG HELM_CLI_VERSION=v4.2.2

# kubectl version
ARG K9S_CLI_VERSION=v0.51.0

# kops version
ARG KOPS_CLI_VERSION=v1.36.0-beta.1

# kubectl version
ARG KUBECTL_CLI_VERSION=v1.36.2

# Kustomize version
ARG KUSTOMIZE_CLI_VERSION=5.8.1

# SwarmCLI version
ARG SWARM_CLI_VERSION=v1.12.0

# Terraform version
ARG TERRAFORM_CLI_VERSION=1.16.0-alpha20260617

# Terragrunt version
ARG TERRAGRUNT_CLI_VERSION=v1.1.0-rc2

# container as builder for preparing Hetzner Cloud tools
FROM dhi.io/debian-base:${DEBIAN_RELEASE} AS hetznercloud-tools-builder

LABEL stage="hetznercloud-tools-builder" \
      description="Debian-based container builder for preparing Hetzner Cloud tools" \
      org.opencontainers.image.description="Debian-based container builder for preparing Hetzner Cloud tools" \
      org.opencontainers.image.url=https://github.com/stefanbosak/hetznercloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/hetznercloud-tools

ARG DEBIAN_FRONTEND

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# install required packages and additional applications
RUN apt-get update && \
    apt-get -y --no-install-recommends install ca-certificates binutils curl unzip && \
    apt-get clean && rm -rf "/var/lib/apt/lists/*"

# container as builder for preparing Hetzner Cloud tools
FROM hetznercloud-tools-builder AS hetznercloud-tools-ansible-cli-builder

LABEL stage="hetznercloud-tools-ansible-cli-builder" \
      description="Debian-based container builder for preparing Hetzner Cloud tool ansible" \
      org.opencontainers.image.description="Debian-based container builder for preparing Hetzner Cloud tool ansible" \
      org.opencontainers.image.url=https://github.com/stefanbosak/hetznercloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/hetznercloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG ANSIBLE_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download and install ansible tool
RUN apt-get -y --no-install-recommends install python-is-python3 python3-pip && \
    apt-get clean && rm -rf "/var/lib/apt/lists/*"
RUN python3 -m pip install --break-system-packages "https://github.com/ansible/ansible/archive/refs/tags/${ANSIBLE_CLI_VERSION}.tar.gz"


# container as builder for preparing Hetzner Cloud tools
FROM hetznercloud-tools-builder AS hetznercloud-tools-cm-builder

LABEL stage="hetznercloud-tools-cm-builder" \
      description="Debian-based container builder for preparing Hetzner Cloud tool cert-manager CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing Hetzner Cloud tool cert-manager CLI" \
      org.opencontainers.image.url=https://github.com/stefanbosak/hetznercloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/hetznercloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG CM_CTL_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download cert-manager
ADD "https://github.com/cert-manager/cmctl/releases/download/${CM_CTL_CLI_VERSION}/cmctl_linux_${TARGETARCH}" "${WORKSPACE_ROOT_DIR}/cmctl_linux_${TARGETARCH}"

# install cert-manager
RUN mkdir -p "/usr/local/bin/" && install -v -o root -g root -m 0755 "${WORKSPACE_ROOT_DIR}/cmctl_linux_${TARGETARCH}" "/usr/local/bin/kubectl-cert_manager"


# container as builder for preparing Hetzner Cloud tools
FROM hetznercloud-tools-builder AS hetznercloud-tools-cnpg-builder

LABEL stage="hetznercloud-tools-cnpg-builder" \
      description="Debian-based container builder for preparing Hetzner Cloud tool CNPG CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing Hetzner Cloud tool CNPG CLI" \
      org.opencontainers.image.url=https://github.com/stefanbosak/hetznercloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/hetznercloud-tools

ARG TARGETOS
ARG TARGETARCH

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# install kubectl CNPG plugin
RUN mkdir -p "/usr/local/bin/" && \
    curl -sSfL https://github.com/cloudnative-pg/cloudnative-pg/raw/main/hack/install-cnpg-plugin.sh | \
    sh -s -- -b /usr/local/bin


# container as builder for preparing Hetzner Cloud tools
FROM hetznercloud-tools-builder AS hetznercloud-tools-hcloud-cli-builder

LABEL stage="hetznercloud-tools-hcloud-cli-builder" \
      description="Debian-based container builder for preparing Hetzner Cloud tool hcloud CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing Hetzner Cloud tool hcloud CLI" \
      org.opencontainers.image.url=https://github.com/stefanbosak/hetznercloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/hetznercloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG HCLOUD_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download hcloud CLI archive file (https://github.com/hetznercloud/cli)
ADD "https://github.com/hetznercloud/cli/releases/download/${HCLOUD_CLI_VERSION}/hcloud-${TARGETOS}-${TARGETARCH}.tar.gz" "${WORKSPACE_ROOT_DIR}/"

# install hcloud CLI
RUN mkdir -p "/usr/local/bin/" && tar -xvf "${WORKSPACE_ROOT_DIR}/hcloud-${TARGETOS}-${TARGETARCH}.tar.gz" -C "/usr/local/bin" --no-anchored "hcloud"


# container as builder for preparing Hetzner Cloud tools
FROM hetznercloud-tools-builder AS hetznercloud-tools-helm-builder

LABEL stage="hetznercloud-tools-helm-builder" \
      description="Debian-based container builder for preparing Hetzner Cloud tool HELM CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing Hetzner Cloud tool HELM CLI" \
      org.opencontainers.image.url=https://github.com/stefanbosak/hetznercloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/hetznercloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG HELM_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download HELM archive file
ADD "https://get.helm.sh/helm-${HELM_CLI_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz" "${WORKSPACE_ROOT_DIR}/"

# install HELM
RUN mkdir -p "/usr/local/bin/" && tar -xvf "${WORKSPACE_ROOT_DIR}/helm-${HELM_CLI_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz" -C "/usr/local/bin" --strip-components 1 --no-anchored "helm"


# container as builder for preparing Hetzner Cloud tools
FROM hetznercloud-tools-builder AS hetznercloud-tools-k9s-builder

LABEL stage="hetznercloud-tools-k9s-builder" \
      description="Debian-based container builder for preparing Hetzner Cloud tool k9s CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing Hetzner Cloud tool k9s CLI" \
      org.opencontainers.image.url=https://github.com/stefanbosak/hetznercloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/hetznercloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG K9S_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download k9s CLI binary file
ADD "https://github.com/derailed/k9s/releases/download/${K9S_CLI_VERSION}/k9s_Linux_${TARGETARCH}.tar.gz" "${WORKSPACE_ROOT_DIR}/"

# install k9s
RUN mkdir -p "/usr/local/bin/" && tar -xvf "${WORKSPACE_ROOT_DIR}/k9s_Linux_${TARGETARCH}.tar.gz" -C "/usr/local/bin" --no-anchored "k9s"


# container as builder for preparing kops Hetzner Cloud tools
FROM hetznercloud-tools-builder AS hetznercloud-tools-kops-builder

LABEL stage="hetznercloud-tools-kops-builder" \
      description="Debian-based container builder for preparing Hetzner Cloud tool kops CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing Hetzner Cloud tool kops CLI" \
      org.opencontainers.image.url=https://github.com/stefanbosak/hetznercloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/hetznercloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG KOPS_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download kubectl CLI binary file
ADD "https://github.com/kubernetes/kops/releases/download/${KOPS_CLI_VERSION}/kops-${TARGETOS}-${TARGETARCH}" "${WORKSPACE_ROOT_DIR}/"

# install kubectl
RUN mkdir -p "/usr/local/bin/" && install -v -o root -g root -m 0755 "${WORKSPACE_ROOT_DIR}/kops-${TARGETOS}-${TARGETARCH}" "/usr/local/bin/kops"


# container as builder for preparing Hetzner Cloud tools
FROM hetznercloud-tools-builder AS hetznercloud-tools-kubectl-builder

LABEL stage="hetznercloud-tools-kubectl-builder" \
      description="Debian-based container builder for preparing Hetzner Cloud tool kubectl CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing Hetzner Cloud tool kubectl CLI" \
      org.opencontainers.image.url=https://github.com/stefanbosak/hetznercloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/hetznercloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG KUBECTL_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download kubectl CLI binary file
ADD "https://dl.k8s.io/release/${KUBECTL_CLI_VERSION}/bin/linux/${TARGETARCH}/kubectl" "${WORKSPACE_ROOT_DIR}/"

# install kubectl
RUN mkdir -p "/usr/local/bin/" && install -v -o root -g root -m 0755 "${WORKSPACE_ROOT_DIR}/kubectl" "/usr/local/bin/"


# container as builder for preparing Hetzner Cloud tools
FROM hetznercloud-tools-builder AS hetznercloud-tools-kustomize-builder

LABEL stage="hetznercloud-tools-kustomize-builder" \
      description="Debian-based container builder for preparing Hetzner Cloud tool kustomize CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing Hetzner Cloud tool kustomize CLI" \
      org.opencontainers.image.url=https://github.com/stefanbosak/hetznercloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/hetznercloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG KUSTOMIZE_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download kustomize archive
ADD "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v${KUSTOMIZE_CLI_VERSION}/kustomize_v${KUSTOMIZE_CLI_VERSION}_${TARGETOS}_${TARGETARCH}.tar.gz" "${WORKSPACE_ROOT_DIR}/"

# install kustomize
RUN mkdir -p "/usr/local/bin/" && tar -xvf "${WORKSPACE_ROOT_DIR}/kustomize_v${KUSTOMIZE_CLI_VERSION}_${TARGETOS}_${TARGETARCH}.tar.gz" -C "/usr/local/bin" --no-anchored "kustomize"


# container as builder for preparing Hetzner Cloud tools
FROM hetznercloud-tools-builder AS hetznercloud-tools-swarmcli-builder

LABEL stage="hetznercloud-tools-swarmcli-builder" \
      description="Debian-based container builder for preparing Hetzner Cloud tool SwarmCLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing Hetzner Cloud tool SwarmCLI" \
      org.opencontainers.image.url=https://github.com/stefanbosak/hetznercloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/hetznercloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG SWARM_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# install SwarmCLI
RUN mkdir -p "/usr/local/bin/" && \
    curl -fsSL https://swarmcli.io/install.sh | \
    sh -s -- ce /usr/local/bin "${SWARM_CLI_VERSION}"


# container as builder for preparing Hetzner Cloud tools
FROM hetznercloud-tools-builder AS hetznercloud-tools-terraform-builder

LABEL stage="hetznercloud-tools-terraform-builder" \
      description="Debian-based container builder for preparing Hetzner Cloud tool terraform" \
      org.opencontainers.image.description="Debian-based container builder for preparing Hetzner Cloud tool terraform" \
      org.opencontainers.image.url=https://github.com/stefanbosak/hetznercloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/hetznercloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG TERRAFORM_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download TF CLI archive file
ADD "https://releases.hashicorp.com/terraform/${TERRAFORM_CLI_VERSION}/terraform_${TERRAFORM_CLI_VERSION}_${TARGETOS}_${TARGETARCH}.zip" "${WORKSPACE_ROOT_DIR}/"

# install TF CLI binary
RUN mkdir -p "/usr/local/bin/" && unzip "terraform_${TERRAFORM_CLI_VERSION}_${TARGETOS}_${TARGETARCH}.zip" -d "/usr/local/bin/"


# container as builder for preparing Hetzner Cloud tools
FROM hetznercloud-tools-builder AS hetznercloud-tools-terragrunt-builder

LABEL stage="hetznercloud-tools-terragrunt-builder" \
      description="Debian-based container builder for preparing Hetzner Cloud tool terragrunt CLI" \
      org.opencontainers.image.description="Debian-based container builder for preparing Hetzner Cloud tool terragrunt CLI" \
      org.opencontainers.image.url=https://github.com/stefanbosak/hetznercloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/hetznercloud-tools

ARG TARGETOS
ARG TARGETARCH
ARG TERRAGRUNT_CLI_VERSION

ARG WORKSPACE_ROOT_DIR
WORKDIR "${WORKSPACE_ROOT_DIR}"

# download kubectl CLI binary file
ADD "https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_CLI_VERSION}/terragrunt_${TARGETOS}_${TARGETARCH}" "${WORKSPACE_ROOT_DIR}/"

# install terragrunt CLI
RUN mkdir -p "/usr/local/bin/" && install -v -o root -g root -m 0755 "${WORKSPACE_ROOT_DIR}/terragrunt_${TARGETOS}_${TARGETARCH}" "/usr/local/bin/terragrunt"


FROM scratch AS hetznercloud-tools-binaries-aggregator

# transfer tools from builders
COPY --from=hetznercloud-tools-ansible-cli-builder "/usr/local/bin" "/usr/local/bin"
COPY --from=hetznercloud-tools-ansible-cli-builder "/usr/local/lib/" "/usr/local/lib"
COPY --from=hetznercloud-tools-cm-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=hetznercloud-tools-cnpg-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=hetznercloud-tools-hcloud-cli-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=hetznercloud-tools-helm-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=hetznercloud-tools-k9s-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=hetznercloud-tools-kops-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=hetznercloud-tools-kubectl-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=hetznercloud-tools-kustomize-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=hetznercloud-tools-swarmcli-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=hetznercloud-tools-terraform-builder "/usr/local/bin/" "/usr/local/bin/"
COPY --from=hetznercloud-tools-terragrunt-builder "/usr/local/bin/" "/usr/local/bin/"


# container as final image for providing Hetzner Cloud tools
FROM dhi.io/debian-base:${DEBIAN_RELEASE} AS hetznercloud-tools-image

LABEL stage="hetznercloud-tools-image" \
      description="Debian-based container with Hetzner Cloud tools" \
      org.opencontainers.image.description="Debian-based container with Hetzner Cloud tools" \
      org.opencontainers.image.url=https://github.com/stefanbosak/hetznercloud-tools \
      org.opencontainers.image.source=https://github.com/stefanbosak/hetznercloud-tools

ARG TARGETOS
ARG TARGETARCH

# user in container
ARG CONTAINER_USER
ARG CONTAINER_GROUP

ARG CONTAINER_USER_ID
ARG CONTAINER_GROUP_ID

ARG DEBIAN_FRONTEND

ARG HOME_ROOT_DIR="/home/${CONTAINER_USER}"

WORKDIR "${HOME_ROOT_DIR}"

RUN mkdir -p "/usr/local/bin/" && \
    apt-get update \
    && apt-get install -y --no-install-recommends \
      bash \
      bash-completion \
      bc \
      ca-certificates \
      curl \
      dnsutils \
      git \
      gnupg \
      gzip \
      iproute2 \
      iputils-ping \
      jq \
      kmod \
      lsof \
      openssh-client \
      pigz \
      procps \
      psmisc \
      python-is-python3 \
      python3-venv \
      python3-argcomplete \
      ripgrep \
      rsync \
      socat \
      unzip \
      wget \
      whois \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# install DiD (Docker in Docker)
# - DinD via QEMU on ARM64 is not supported
#   (ARM64 requires ARM64 kernel from host system which is not present on AMD64 host)
RUN curl -fsSL https://test.docker.com | sh && \
    if ! getent group docker > /dev/null 2>&1; then \
      groupadd docker; \
    fi

# copy tools from aggregator
COPY --from=hetznercloud-tools-binaries-aggregator / /

# setup user and group
RUN if getent group "${CONTAINER_GROUP_ID}" > /dev/null; then \
      _existing_group="$(getent group "${CONTAINER_GROUP_ID}" | cut -d: -f1)"; \
      if [ "${_existing_group}" != "${CONTAINER_GROUP}" ]; then \
        groupmod -n "${CONTAINER_GROUP}" "${_existing_group}"; \
      fi; \
    else \
      groupadd --gid "${CONTAINER_GROUP_ID}" "${CONTAINER_GROUP}"; \
    fi \
    && if getent passwd "${CONTAINER_USER_ID}" > /dev/null; then \
         _existing_user="$(getent passwd "${CONTAINER_USER_ID}" | cut -d: -f1)"; \
         if [ "${_existing_user}" != "${CONTAINER_USER}" ]; then \
           if [ -d "/home/${_existing_user}" ]; then \
             mv "/home/${_existing_user}" "/home/${CONTAINER_USER}"; \
           fi; \
           usermod -d "${HOME_ROOT_DIR}" -l "${CONTAINER_USER}" "${_existing_user}"; \
         fi; \
       else \
         useradd \
           --uid "${CONTAINER_USER_ID}" \
           --gid "${CONTAINER_GROUP_ID}" \
           --groups "${CONTAINER_GROUP}" \
           -M -d "${HOME_ROOT_DIR}" \
           -s /bin/bash \
           "${CONTAINER_USER}"; \
       fi \
    && chown -R "${CONTAINER_USER}:${CONTAINER_GROUP}" "${HOME_ROOT_DIR}" \
    && usermod -aG docker "${CONTAINER_USER}" && \
# enable tools completions (required to run given tool to generate completion file content)
    ln -s /usr/local/bin/kubectl-cert_manager /usr/local/bin/cmctl && \
    cmctl completion bash > /usr/share/bash-completion/completions/cmctl && \
    ln -s /usr/local/bin/kubectl-cnpg /usr/local/bin/cnpgctl && \
    cnpgctl completion bash > /usr/share/bash-completion/completions/cnpgctl && \
    sed -i 's/kubectl-cnpg/cnpgctl/g' /usr/share/bash-completion/completions/cnpgctl && \
    hcloud completion bash > "/usr/share/bash-completion/completions/hcloud" && \
    helm completion bash > "/usr/share/bash-completion/completions/helm" && \
    k9s completion bash > "/usr/share/bash-completion/completions/k9s" && \
    kops completion bash > "/usr/share/bash-completion/completions/kops" && \
    kubectl completion bash > "/usr/share/bash-completion/completions/kubectl" && \
    cp "/usr/share/bash-completion/completions/kubectl" "/usr/share/bash-completion/completions/k" && \
    sed -i 's/kubectl/k/g' "/usr/share/bash-completion/completions/k" && \
    ln -s /usr/local/bin/kubectl /usr/local/bin/k && \
    kustomize completion bash > "/usr/share/bash-completion/completions/kustomize" && \
    echo "complete -C terraform terraform" > "/usr/share/bash-completion/completions/terraform" && \
    echo "complete -C terragrunt terragrunt" > "/usr/share/bash-completion/completions/terragrunt" && \
    activate-global-python-argcomplete

# container user and group
USER "${CONTAINER_USER}:${CONTAINER_GROUP}"

WORKDIR "${HOME_ROOT_DIR}"

RUN cp /etc/skel/.bashrc /etc/skel/.profile "${HOME_ROOT_DIR}"

# open shell
CMD ["bash"]
