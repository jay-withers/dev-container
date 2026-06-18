FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG AZURE_CLI_URL="https://packages.microsoft.com/repos/azure-cli/pool/main/a/azure-cli/azure-cli_2.73.0-1~noble_arm64.deb@sha256:6af9009a39895ba396e92d5138824091e95f9bd797422db2fe9564a0cf4a35f4"
ARG CHECKOV_URL="https://github.com/bridgecrewio/checkov/releases/download/3.2.529/checkov_linux_arm64.zip@sha256:fff55b064eadfc14ce35da9b9744dedf82fb50c25447076149480ad92c06a6a9"
ARG HELM_URL="https://get.helm.sh/helm-v4.2.1-linux-arm64.tar.gz@sha256:596b9a73d366c1e72ce67d595c22805480e30914593aafbc9f547694e72814db"
ARG K9S_URL="https://github.com/derailed/k9s/releases/download/v0.51.0/k9s_Linux_arm64.tar.gz@sha256:3ee05c82e5f9198928a4e86133608ba6a2c10a2244d6a7789e820f78319d640c"
ARG KUBECTL_URL="https://dl.k8s.io/release/v1.36.2/bin/linux/arm64/kubectl@sha256:c957eb8c4bea27a3bb35b269edd9082e27f027f7b76b20b5bf4afebc726c6d3e"
ARG KUBECTX_URL="https://github.com/ahmetb/kubectx/releases/download/v0.11.0/kubectx_v0.11.0_linux_arm64.tar.gz@sha256:1dac2072216689e773325cb7587b858ea7415706ebcf04e23bf80e7e70555340"
ARG NODE_URL="https://nodejs.org/dist/v24.16.0/node-v24.16.0-linux-arm64.tar.xz@sha256:524659219d6a207a7400f2bde15d19ba060ffbe0d32a8643319ad67e3bb64c78"
ARG POWERSHELL_URL="https://github.com/PowerShell/PowerShell/releases/download/v7.6.3/powershell-7.6.3-linux-arm64.tar.gz@sha256:7a14a385eca7dc5bedc1c8aa3d8b765f449ada30aabe5785a9fd331266eb062d"
ARG PRE_COMMIT_URL="https://github.com/pre-commit/pre-commit/releases/download/v3.7.1/pre-commit-3.7.1.pyz@sha256:a0349324f0f53b08d00eb473b5f6646c8a07f3253703c09b977b0b9b9476d486"
ARG TERRAFORM_DOCS_URL="https://github.com/terraform-docs/terraform-docs/releases/download/v0.24.0/terraform-docs-v0.24.0-linux-arm64.tar.gz@sha256:d12bd7b73c1fc9c64efc79f8157dd713dabd559f1ecf3cfc0f42e32279a155fd"
ARG TFLINT_URL="https://github.com/terraform-linters/tflint/releases/download/v0.61.0/tflint_linux_arm64.zip@sha256:999c25cfdb5208fe1133dec6b219e666a39fc2a7a0786a781dc9924ea5945ebf"

# Base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        bash-completion curl unzip xz-utils python3 \
    && rm -rf /var/lib/apt/lists/*

# azure-cli with pinned SHA256 digest
RUN URL="${AZURE_CLI_URL%@sha256:*}" \
    && SHA="${AZURE_CLI_URL##*@sha256:}" \
    && curl -fsSL "${URL}" -o /tmp/azure-cli.deb \
    && (cd /tmp && echo "${SHA}  azure-cli.deb" | sha256sum -c) \
    && apt-get update && apt-get install -y --no-install-recommends /tmp/azure-cli.deb \
    && rm /tmp/azure-cli.deb \
    && rm -rf /var/lib/apt/lists/* \
    && az --version

# checkov binary with pinned SHA256 digest
RUN URL="${CHECKOV_URL%@sha256:*}" \
    && SHA="${CHECKOV_URL##*@sha256:}" \
    && curl -fsSL "${URL}" -o /tmp/checkov.zip \
    && (cd /tmp && echo "${SHA}  checkov.zip" | sha256sum -c) \
    && unzip /tmp/checkov.zip -d /usr/local/bin \
    && mv /usr/local/bin/dist/checkov /usr/local/bin/checkov \
    && rm -rf /usr/local/bin/dist \
    && chmod +x /usr/local/bin/checkov \
    && rm /tmp/checkov.zip \
    && checkov --version

# pre-commit with pinned SHA256 digest
RUN URL="${PRE_COMMIT_URL%@sha256:*}" \
    && SHA="${PRE_COMMIT_URL##*@sha256:}" \
    && curl -fsSL "${URL}" -o /usr/local/bin/pre-commit \
    && (cd /usr/local/bin && echo "${SHA}  pre-commit" | sha256sum -c) \
    && chmod +x /usr/local/bin/pre-commit \
    && pre-commit --version

# tflint with pinned SHA256 digest
RUN URL="${TFLINT_URL%@sha256:*}" \
    && SHA="${TFLINT_URL##*@sha256:}" \
    && curl -fsSL "${URL}" -o /tmp/tflint.zip \
    && (cd /tmp && echo "${SHA}  tflint.zip" | sha256sum -c) \
    && unzip /tmp/tflint.zip tflint -d /usr/local/bin \
    && rm /tmp/tflint.zip \
    && tflint --version

# terraform-docs with pinned SHA256 digest
RUN URL="${TERRAFORM_DOCS_URL%@sha256:*}" \
    && SHA="${TERRAFORM_DOCS_URL##*@sha256:}" \
    && curl -fsSL "${URL}" -o /tmp/terraform-docs.tar.gz \
    && (cd /tmp && echo "${SHA}  terraform-docs.tar.gz" | sha256sum -c) \
    && tar -xz -C /usr/local/bin -f /tmp/terraform-docs.tar.gz terraform-docs \
    && chmod +x /usr/local/bin/terraform-docs \
    && rm /tmp/terraform-docs.tar.gz \
    && terraform-docs --version \
    && terraform-docs completion bash > /etc/bash_completion.d/terraform-docs

# node with pinned SHA256 digest
RUN URL="${NODE_URL%@sha256:*}" \
    && SHA="${NODE_URL##*@sha256:}" \
    && curl -fsSL "${URL}" -o /tmp/node.tar.xz \
    && (cd /tmp && echo "${SHA}  node.tar.xz" | sha256sum -c) \
    && tar -xJ -C /usr/local --strip-components=1 -f /tmp/node.tar.xz \
    && rm /tmp/node.tar.xz \
    && node --version

# kubectl with pinned SHA256 digest
RUN URL="${KUBECTL_URL%@sha256:*}" \
    && SHA="${KUBECTL_URL##*@sha256:}" \
    && curl -fsSL "${URL}" -o /usr/local/bin/kubectl \
    && (cd /usr/local/bin && echo "${SHA}  kubectl" | sha256sum -c) \
    && chmod +x /usr/local/bin/kubectl \
    && kubectl version --client \
    && kubectl completion bash > /etc/bash_completion.d/kubectl

# kubectx with pinned SHA256 digest
RUN URL="${KUBECTX_URL%@sha256:*}" \
    && SHA="${KUBECTX_URL##*@sha256:}" \
    && curl -fsSL "${URL}" -o /tmp/kubectx.tar.gz \
    && (cd /tmp && echo "${SHA}  kubectx.tar.gz" | sha256sum -c) \
    && tar -xz -C /usr/local/bin -f /tmp/kubectx.tar.gz kubectx \
    && rm /tmp/kubectx.tar.gz \
    && kubectx --version

# helm with pinned SHA256 digest
RUN URL="${HELM_URL%@sha256:*}" \
    && SHA="${HELM_URL##*@sha256:}" \
    && curl -fsSL "${URL}" -o /tmp/helm.tar.gz \
    && (cd /tmp && echo "${SHA}  helm.tar.gz" | sha256sum -c) \
    && tar -xz -C /usr/local/bin --strip-components=1 -f /tmp/helm.tar.gz linux-arm64/helm \
    && rm /tmp/helm.tar.gz \
    && helm version \
    && helm completion bash > /etc/bash_completion.d/helm

# k9s with pinned SHA256 digest
RUN URL="${K9S_URL%@sha256:*}" \
    && SHA="${K9S_URL##*@sha256:}" \
    && curl -fsSL "${URL}" -o /tmp/k9s.tar.gz \
    && (cd /tmp && echo "${SHA}  k9s.tar.gz" | sha256sum -c) \
    && tar -xz -C /usr/local/bin -f /tmp/k9s.tar.gz k9s \
    && rm /tmp/k9s.tar.gz \
    && k9s version

# PowerShell with pinned SHA256 digest
RUN URL="${POWERSHELL_URL%@sha256:*}" \
    && SHA="${POWERSHELL_URL##*@sha256:}" \
    && curl -fsSL "${URL}" -o /tmp/powershell.tar.gz \
    && (cd /tmp && echo "${SHA}  powershell.tar.gz" | sha256sum -c) \
    && mkdir -p /opt/microsoft/powershell/7 \
    && tar -xz -C /opt/microsoft/powershell/7 -f /tmp/powershell.tar.gz \
    && chmod +x /opt/microsoft/powershell/7/pwsh \
    && ln -s /opt/microsoft/powershell/7/pwsh /usr/local/bin/pwsh \
    && rm /tmp/powershell.tar.gz \
    && pwsh --version

# Az PowerShell module
RUN pwsh -NoLogo -NonInteractive -Command "\
    Set-PSRepository PSGallery -InstallationPolicy Trusted; \
    Install-Module -Name Az -Force -Scope AllUsers"

# tfenv — terraform version controlled by .terraform-version in the workspace
RUN git clone --depth=1 https://github.com/tfutils/tfenv.git /home/vscode/.tfenv \
    && chown -R vscode:vscode /home/vscode/.tfenv

ENV PATH="/home/vscode/.tfenv/bin:${PATH}"

USER vscode
