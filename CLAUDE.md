# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Claude instructions

When you add, remove, or significantly change a feature, command, or configuration option, update README.md to reflect it before marking the task complete.

## What this repo is

A catalog of VS Code dev container images for Azure infrastructure development. Each image is defined under `images/<name>/Dockerfile`, built and published to the GitHub Container Registry (`ghcr.io/jay-withers/dev-container/<name>`), and consumed by other repos via an `image:` reference in their `.devcontainer/devcontainer.json`. There is no application code — the primary deliverable is the set of container images.

## Common commands

Run all pre-commit hooks against every file (the standard way to validate changes):

```sh
pre-commit run --all-files --config config/.pre-commit-config.yaml
```

Inside the container, a shell function in `~/.bashrc` wraps `pre-commit` to always pass `--config config/.pre-commit-config.yaml`, so inside the container you can just run:

```sh
pre-commit run --all-files
```

Build an image locally (from the repo root):

```sh
docker build -t base images/base
docker build --build-arg BASE_IMAGE=base -t terraform images/terraform
docker build --build-arg BASE_IMAGE=base -t k8s images/k8s
```

## Architecture

### Images

Images form a base + specialisation hierarchy under `images/`:

- **`images/base/Dockerfile`** — builds from `mcr.microsoft.com/devcontainers/base:ubuntu-24.04`. Installs the tooling common to every image: Azure CLI, Node.js, pre-commit. All tools are installed from pinned URLs that include a `@sha256:` digest suffix, verified at build time.
- **`images/terraform/Dockerfile`** — `FROM` the base image (via the `BASE_IMAGE` build arg, defaulting to the published `:latest`). Adds TFLint, Checkov, terraform-docs, and tfenv (which manages the Terraform version via `.terraform-version` in the consuming repo's workspace).
- **`images/k8s/Dockerfile`** — `FROM` the base image. Adds kubectl, kubectx, helm, and k9s.

Specialised images switch to `USER root` to install, then back to `USER vscode`. To add a new image, create `images/<name>/Dockerfile` `FROM` the base and add it to the `leaves` matrix in `tag.yml` and the build/smoke-test steps in `container-build.yml`.

### This repo's own dev container

- **`.devcontainer/devcontainer.json`** — references the published `base` image via `image:` (the base tooling is all that's needed to edit Dockerfiles, workflows, and config) and wires up VS Code extensions and format-on-save. A `postCreateCommand` runs `pre-commit install --config config/.pre-commit-config.yaml` to install the git hooks on container create.

### Pre-commit configuration

This repo's own hooks live in **`config/.pre-commit-config.yaml`** — secret scanning, workflow/config linting, commit-message and shell linting, plus the standard whitespace/format hooks. Hook revisions are frozen with a comment showing the upstream tag; Renovate keeps these updated automatically.

### Dependency pinning and updates

Tool versions are declared as `ARG` values in each image's Dockerfile as full download URLs with `@sha256:` digests appended. **`renovate.json`** uses regex custom managers (scoped per Dockerfile via `fileMatch`) to parse these ARGs and raise PRs when new releases are available. Renovate also updates GitHub Actions pins, Dockerfile `FROM` base images, and pre-commit hook revisions. All Renovate PRs are auto-approved and auto-merged (squash) once CI passes.

### Commit messages

Commits must follow [Conventional Commits](https://www.conventionalcommits.org/). The commitlint hook (`config/commitlint.config.js`) enforces this at the `commit-msg` stage. The `no-commit-to-branch` hook blocks direct commits to `main`.

### CI

- **`.github/workflows/pre-commit.yml`** — runs on PRs to `main`. Installs tools then runs `pre-commit run --all-files --config config/.pre-commit-config.yaml`. The `no-commit-to-branch` hook is skipped in CI via `SKIP=no-commit-to-branch`.
- **`.github/workflows/container-build.yml`** — runs on PRs that change `images/**`. Builds the base image into a job-local registry, then builds the terraform and k8s images (`FROM` that base) for `linux/arm64` via QEMU and smoke-tests each tool. Nothing is pushed to GHCR.
- **`.github/workflows/tag.yml`** — runs on merge to `main`. Bumps the semver tag, builds and pushes the base image to GHCR, then builds and pushes each leaf image (`terraform`, `k8s`) referencing the freshly published base at the same version. Each image is tagged with both the new version and `latest`.
