# Dev Containers

A catalog of VS Code dev container images for Azure infrastructure development. Images are built from a shared base and published to the GitHub Container Registry, so any repo can reference one directly — no local build required.

## Available images

| Image       | Registry path                                      | Tooling on top of base                       |
| ----------- | -------------------------------------------------- | -------------------------------------------- |
| `base`      | `ghcr.io/jay-withers/dev-container/base`           | Azure CLI, Node.js, pre-commit               |
| `terraform` | `ghcr.io/jay-withers/dev-container/terraform`      | + tflint, checkov, terraform-docs, tfenv     |
| `k8s`       | `ghcr.io/jay-withers/dev-container/k8s`            | + kubectl, kubectx, helm, k9s                |

Each specialised image is built `FROM` the base image, so common tooling stays in one place.

## Using an image in another repo

Add a `.devcontainer/devcontainer.json` that references the published image:

```json
{
  "image": "ghcr.io/jay-withers/dev-container/terraform:latest",
  "customizations": {
    "vscode": {
      "extensions": []
    }
  }
}
```

For the `terraform` image, pin a Terraform version by adding a `.terraform-version` file to your workspace root; install it with `tfenv install` (e.g. from a `postCreateCommand`).

To pin to a specific image version rather than `latest`, use a semver tag:

```json
"image": "ghcr.io/jay-withers/dev-container/terraform:v1.2.3"
```

## Prerequisites (for local use)

- [Docker](https://www.docker.com/get-started/) installed and running

## Repository layout

```text
images/
  base/Dockerfile        # shared: ubuntu, Azure CLI, Node.js, pre-commit
  terraform/Dockerfile   # FROM base + tflint, checkov, terraform-docs, tfenv
  k8s/Dockerfile         # FROM base + kubectl, kubectx, helm, k9s
config/                  # shared pre-commit and tooling config
.devcontainer/           # this repo's own dev container (uses the base image)
```

## Tooling versions

All tools are installed from pinned URLs with SHA256 digest verification at build time. In the `terraform` image, the Terraform version is managed by tfenv via a `.terraform-version` file in the consuming repo's workspace root.

Shell (bash) tab completion is enabled for: Azure CLI, kubectl, helm, terraform-docs, and terraform.

| Tool           | Version | Image     |
| -------------- | ------- | --------- |
| Azure CLI      | 2.73.0  | base      |
| Node.js        | 24.16.0 | base      |
| pre-commit     | 3.7.1   | base      |
| TFLint         | 0.61.0  | terraform |
| Checkov        | 3.2.529 | terraform |
| terraform-docs | 0.24.0  | terraform |
| tfenv          | latest  | terraform |
| kubectl        | 1.36.2  | k8s       |
| helm           | 4.2.1   | k8s       |
| k9s            | 0.51.0  | k8s       |
| kubectx        | 0.11.0  | k8s       |

## VS Code extensions

This repo's own dev container ([.devcontainer/devcontainer.json](.devcontainer/devcontainer.json)) enables the extensions used to maintain the images:

| Extension                          | Purpose                          |
| ---------------------------------- | -------------------------------- |
| `ms-azuretools.vscode-docker`      | Dockerfile authoring and linting |
| `github.vscode-github-actions`     | GitHub Actions workflow support  |
| `redhat.vscode-yaml`               | YAML language support            |
| `timonwong.shellcheck`             | Shell script linting             |
| `DavidAnson.vscode-markdownlint`   | Markdown linting                 |
| `eamodio.gitlens`                  | Enhanced git tooling             |
| `anthropic.claude-code`            | Claude AI assistant              |

## Pre-commit hooks

This repo's own hooks (defined in [config/.pre-commit-config.yaml](config/.pre-commit-config.yaml)) run on every commit:

| Hook                   | What it checks                                                                                |
| ---------------------- | --------------------------------------------------------------------------------------------- |
| `gitleaks`             | Secret scanning                                                                               |
| `actionlint`           | GitHub Actions workflow linting                                                               |
| `check-azure-pipelines`| Azure Pipelines YAML validity                                                                 |
| `check-renovate`       | Renovate config validity                                                                      |
| `commitlint`           | Conventional commit message format (commit-msg stage)                                         |
| `shellcheck`           | Shell script linting                                                                          |
| Standard hooks         | Trailing whitespace, EOF newline, YAML/JSON validity, merge conflicts, large files            |

To run hooks manually:

```sh
pre-commit run --all-files --config config/.pre-commit-config.yaml
```

## CI

| Workflow          | When it runs                       | What it does                                                                                         |
| ----------------- | ---------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `pre-commit`      | Every PR to `main`                 | Installs all tools and runs `pre-commit run --all-files` to validate hooks                           |
| `container-build` | PRs that change `images/**`        | Builds base, terraform, and k8s images for `linux/arm64` via QEMU and smoke-tests each tool          |
| `tag`             | Every merge to `main`              | Bumps the semver tag, then builds and publishes every image to GHCR with that tag and `latest`       |

## Dependency updates

[Renovate](https://docs.renovatebot.com/) is configured in [renovate.json](renovate.json) to keep pinned versions up to date automatically. It raises PRs for:

- GitHub Actions (`uses:` pins in workflows)
- Pre-commit hook revisions (`config/.pre-commit-config.yaml`)
- Dockerfile `FROM` base images
- Tool versions in Dockerfile ARGs across `images/base`, `images/terraform`, and `images/k8s`

Renovate will auto-approve and auto-merge PRs (squash) once the `pre-commit` and `container-build` workflows pass.

To enable it, install the [Renovate GitHub App](https://github.com/apps/renovate) on the repository.
