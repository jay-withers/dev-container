# Azure Terraform Dev Container

A VS Code dev container for Azure infrastructure development with Terraform. Provides a fully configured, reproducible environment with all required tooling pre-installed — no local setup beyond Docker.

## Prerequisites

- [Docker](https://www.docker.com/get-started/) installed and running
- Git identity configured on your host (`user.name` and `user.email`) — the container reads these at startup and fails with a clear message if missing

## Getting started

Open the repo in VS Code and select **Reopen in Container**.

## Tooling

All tools are installed from pinned URLs with SHA256 digest verification at build time. Terraform version is managed by tfenv and pinned in [.terraform-version](.terraform-version).

| Tool           | Version |
| -------------- | ------- |
| Azure CLI      | 2.73.0  |
| tfenv          | latest  |
| TFLint         | 0.61.0  |
| Checkov        | 3.2.529 |
| terraform-docs | 0.24.0  |
| pre-commit     | 3.7.1   |
| Node.js        | 24.16.0 |

## VS Code extensions

| Extension                                  | Purpose                               |
| ------------------------------------------ | ------------------------------------- |
| `hashicorp.terraform`                      | Terraform language support and formatting |
| `ms-azuretools.vscode-azureterraform`      | Azure Terraform integration           |
| `ms-azuretools.vscode-azureresourcegroups` | Browse Azure resources                |
| `ms-azure-devops.azure-pipelines`          | Azure Pipelines YAML support          |
| `anthropic.claude-code`                    | Claude AI assistant                   |
| `ms-vscode.powershell`                     | PowerShell language support           |
| `eamodio.gitlens`                          | Enhanced git tooling                  |
| `redhat.vscode-yaml`                       | YAML language support                 |
| `timonwong.shellcheck`                     | Shell script linting                  |
| `DavidAnson.vscode-markdownlint`           | Markdown linting                      |

## Pre-commit hooks

Hooks are installed automatically when the container is created. The following run on every commit:

| Hook                   | What it checks                                                                    |
| ---------------------- | --------------------------------------------------------------------------------- |
| `terraform fmt`        | Terraform formatting                                                              |
| `terraform_validate`   | Terraform configuration validity                                                  |
| `terraform_docs`       | Keeps terraform-docs output up to date                                            |
| `tflint`               | Terraform linting                                                                 |
| `checkov`              | Terraform security and compliance                                                 |
| `gitleaks`             | Secret scanning                                                                   |
| `actionlint`           | GitHub Actions workflow linting                                                   |
| `commitlint`           | Conventional commit message format (commit-msg stage)                             |
| Standard hooks         | Trailing whitespace, EOF newline, YAML/JSON/Azure Pipelines validity, large files |

To run hooks manually:

```sh
pre-commit run --all-files --config config/.pre-commit-config.yaml
```

## Claude Code MCP servers

Two MCP servers are configured for Claude Code automatically on container creation:

| Server                        | Purpose                                                                    |
| ----------------------------- | -------------------------------------------------------------------------- |
| Azure MCP (`@azure/mcp`)      | Interact with Azure resources, query subscriptions, resource groups, and services |
| Microsoft Learn               | Search and fetch official Microsoft and Azure documentation                |

## Dependency updates

[Renovate](https://docs.renovatebot.com/) is configured in [renovate.json](renovate.json) to keep pinned versions up to date automatically. It raises PRs for:

- GitHub Actions (`uses:` pins in workflows)
- Pre-commit hook revisions (`config/.pre-commit-config.yaml`)
- Dockerfile `FROM` base image
- Tool versions in Dockerfile ARGs (TFLint, Checkov, terraform-docs, pre-commit, Node.js)

Renovate will auto-approve and auto-merge PRs (squash) once the `pre-commit` workflow passes.

To enable it, install the [Renovate GitHub App](https://github.com/apps/renovate) on the repository.

## VS Code without Docker

If you open the repo without the dev container, VS Code will prompt you to install the recommended extensions defined in [.vscode/extensions.json](.vscode/extensions.json).

## Home directory mount

The host home directory is mounted at `/host-home` inside the container, giving access to host SSH keys, credentials, and other config without copying them into the image.

## Terraform example

The `terraform/` directory contains a simple Azure Resource Group module used as a working example for the tooling and pre-commit hooks. See [terraform/README.md](terraform/README.md) for details.
