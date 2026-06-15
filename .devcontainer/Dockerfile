FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG AZURE_CLI_URL="https://packages.microsoft.com/repos/azure-cli/pool/main/a/azure-cli/azure-cli_2.73.0-1~noble_arm64.deb@sha256:6af9009a39895ba396e92d5138824091e95f9bd797422db2fe9564a0cf4a35f4"
ARG CHECKOV_URL="https://github.com/bridgecrewio/checkov/releases/download/3.2.529/checkov_linux_arm64.zip@sha256:fff55b064eadfc14ce35da9b9744dedf82fb50c25447076149480ad92c06a6a9"
ARG NODE_URL="https://nodejs.org/dist/v24.16.0/node-v24.16.0-linux-arm64.tar.xz@sha256:524659219d6a207a7400f2bde15d19ba060ffbe0d32a8643319ad67e3bb64c78"
ARG PRE_COMMIT_URL="https://github.com/pre-commit/pre-commit/releases/download/v3.7.1/pre-commit-3.7.1.pyz@sha256:a0349324f0f53b08d00eb473b5f6646c8a07f3253703c09b977b0b9b9476d486"
ARG TERRAFORM_DOCS_URL="https://github.com/terraform-docs/terraform-docs/releases/download/v0.24.0/terraform-docs-v0.24.0-linux-arm64.tar.gz@sha256:d12bd7b73c1fc9c64efc79f8157dd713dabd559f1ecf3cfc0f42e32279a155fd"
ARG TERRAFORM_URL="https://releases.hashicorp.com/terraform/1.15.5/terraform_1.15.5_linux_arm64.zip@sha256:06e7b48de826146c6d9331ba35b13da12332d8392be30d1dd6b789ba4713fff0"
ARG TFLINT_URL="https://github.com/terraform-linters/tflint/releases/download/v0.61.0/tflint_linux_arm64.zip@sha256:999c25cfdb5208fe1133dec6b219e666a39fc2a7a0786a781dc9924ea5945ebf"

# Base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl unzip xz-utils python3 \
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

# terraform with pinned SHA256 digest
RUN URL="${TERRAFORM_URL%@sha256:*}" \
    && SHA="${TERRAFORM_URL##*@sha256:}" \
    && curl -fsSL "${URL}" -o /tmp/terraform.zip \
    && (cd /tmp && echo "${SHA}  terraform.zip" | sha256sum -c) \
    && unzip /tmp/terraform.zip terraform -d /usr/local/bin \
    && rm /tmp/terraform.zip \
    && terraform version

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
    && terraform-docs --version

# node with pinned SHA256 digest
RUN URL="${NODE_URL%@sha256:*}" \
    && SHA="${NODE_URL##*@sha256:}" \
    && curl -fsSL "${URL}" -o /tmp/node.tar.xz \
    && (cd /tmp && echo "${SHA}  node.tar.xz" | sha256sum -c) \
    && tar -xJ -C /usr/local --strip-components=1 -f /tmp/node.tar.xz \
    && rm /tmp/node.tar.xz \
    && node --version

USER vscode
