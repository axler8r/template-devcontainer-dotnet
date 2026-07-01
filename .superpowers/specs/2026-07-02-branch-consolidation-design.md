# Branch Consolidation Design

**Date:** 2026-07-02
**Topic:** Consolidate template branches into a bare devcontainer `stable` branch

---

## Problem

The repository has three `template/*` branches (`template/console`, `template/library`,
`template/web-api`) whose `.devcontainer/` configuration is byte-for-byte identical.
The only meaningful differences are the `"name"` field in `devcontainer.json`, the
variant-specific `README.md`, and the scaffolded `src/` project. This duplication
creates maintenance overhead with no benefit — common changes must be applied three
times.

---

## Goal

Consolidate everything into a single `stable` branch that serves as a bare .NET dev
container template. Users scaffold their own project after cloning. Delete all
`template/*` branches.

---

## Branch Structure After Consolidation

| Branch | Purpose |
|---|---|
| `stable` | The only branch — bare devcontainer template, no pre-scaffolded project |

`template/console`, `template/library`, and `template/web-api` are deleted locally
and on the remote.

---

## File Inventory (`stable`)

```
.devcontainer/
  Dockerfile
  devcontainer.json
.github/
  LICENSE
.editorconfig
.gitignore             ← extended to ignore .superpowers/ and .claude/
global.json
README.md
```

`.superpowers/` and `.claude/` remain on disk for local reference but are gitignored
and do not ship with the template.

---

## Base Image

`mcr.microsoft.com/devcontainers/base:ubuntu-24.04`

- Ubuntu 24.04 LTS (supported until 2029) — Microsoft patches the image continuously
  without changing the tag; the tag only needs updating when deliberately upgrading to
  the next LTS
- ZSH, Oh My ZSH, and the `vscode` user (uid/gid 1000) are provided by the base image
- No multi-stage build or `common-utils` feature required

---

## `Dockerfile`

Single-stage. Installs the .NET SDK via `dotnet-install.sh` to a pinned version.
APT cache mounts keep subsequent rebuilds fast.

```dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ENV DOTNET_SDK_VERSION=10.0.109 \
    DOTNET_ROOT=/usr/local/dotnet-sdk \
    PATH=$PATH:/usr/local/dotnet-sdk \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_NOLOGO=1

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt-get update && apt-get install -y --no-install-recommends \
      curl \
      make \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://dot.net/v1/dotnet-install.sh \
      | bash -s -- --version $DOTNET_SDK_VERSION --install-dir $DOTNET_ROOT --no-path && \
    chown -R vscode:vscode $DOTNET_ROOT
```

---

## `devcontainer.json`

```json
{
  "name": ".NET",
  "build": {
    "dockerfile": "Dockerfile"
  },
  "remoteUser": "vscode",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-dotnettools.csdevkit",
        "editorconfig.editorconfig"
      ],
      "settings": {
        "dotnet.dotnetPath": "/usr/local/dotnet-sdk/dotnet"
      }
    }
  }
}
```

`dotnet.dotnetPath` is required because `dotnet-install.sh` places the SDK at
`/usr/local/dotnet-sdk`, which is not a standard system path. No `postCreateCommand`
— the bare template has no project to restore.

---

## SDK Version Pinning

Two mechanisms work together:

| Mechanism | Location | Controls |
|---|---|---|
| `DOTNET_SDK_VERSION=10.0.109` | `Dockerfile` ENV | what SDK is installed in the image |
| `"version": "10.0.109"` | `global.json` | what SDK the CLI and IDE use at the project level |

`global.json` uses `"rollForward": "latestPatch"` to allow patch updates without
changing the pin. Both values must be kept in sync when upgrading the SDK.

---

## `global.json`

```json
{
  "sdk": {
    "version": "10.0.109",
    "rollForward": "latestPatch"
  }
}
```

---

## `.editorconfig`

Carried forward unchanged from the template branches:

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 4
insert_final_newline = true
trim_trailing_whitespace = true

[*.{json,yml,yaml,xml,csproj}]
indent_size = 2

[*.cs]
dotnet_analyzer_diagnostic.severity = suggestion
```

---

## `.gitignore`

The existing `.gitignore` on `stable` is extended with:

```
.superpowers/
.claude/
```

---

## `README.md`

Rewritten to describe `stable` as a bare template. Covers:

1. What this template provides (devcontainer, SDK pin, editorconfig)
2. Prerequisites (VS Code, Dev Containers extension, Docker)
3. Usage: "Use this template → clone → Reopen in Container → scaffold with `dotnet new`"
4. Common `dotnet new` commands the user will run after cloning
5. Licence

---

## Branch Cleanup

Delete both local and remote copies of:

- `template/console`
- `template/library`
- `template/web-api`

---

## Out of Scope

- NixOS-based variant — the community standard is Ubuntu; personal NixOS workflows
  are covered by the user's Workbench/`flake.nix` setup
- Solution files (`.sln`) — users add if needed
- CI/CD workflows — not part of the template
- Pre-scaffolded project — users run `dotnet new` after cloning
