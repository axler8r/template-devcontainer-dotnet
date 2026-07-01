# Branch Consolidation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the three `template/*` variant branches with a single bare devcontainer scaffold on `stable`, then delete the variant branches locally and on GitHub.

**Architecture:** All changes land on `stable`. Three new files are authored from scratch (`.devcontainer/Dockerfile`, `.devcontainer/devcontainer.json`, `global.json`), one is carried forward unchanged (`.editorconfig`), one is extended (`.gitignore`), and one is rewritten (`README.md`). Branch deletion is the final step.

**Tech Stack:** Docker (BuildKit), .NET 10 SDK, `dotnet-install.sh`, `gh` CLI (for remote branch deletion)

## Global Constraints

- Branch: all work on `stable`
- Base image: `mcr.microsoft.com/devcontainers/base:ubuntu-24.04`
- SDK version: `10.0.109` — appears verbatim in both `Dockerfile` ENV and `global.json`; must be identical in both files
- SDK install path: `/usr/local/dotnet-sdk` — appears verbatim in `Dockerfile`, `devcontainer.json` (`dotnet.dotnetPath`), and ENV vars
- `vscode` user (uid/gid 1000) — provided by base image; do not recreate
- No `postCreateCommand` in `devcontainer.json` — bare template has no project to restore
- `.superpowers/` and `.claude/` must not appear in `git status` after `.gitignore` is updated
- Conventional commit format per `~/.gitcommit`

---

### Task 1: Scaffold devcontainer files

**Files:**
- Create: `.devcontainer/Dockerfile`
- Create: `.devcontainer/devcontainer.json`
- Create: `global.json`
- Create: `.editorconfig`

**Interfaces:**
- Produces: a buildable dev container image with `dotnet` at `/usr/local/dotnet-sdk/dotnet` reporting version `10.0.109`

- [ ] **Step 1: Create `.devcontainer/` directory and `Dockerfile`**

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

- [ ] **Step 2: Create `.devcontainer/devcontainer.json`**

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

- [ ] **Step 3: Create `global.json`**

```json
{
  "sdk": {
    "version": "10.0.109",
    "rollForward": "latestPatch"
  }
}
```

- [ ] **Step 4: Create `.editorconfig`**

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

- [ ] **Step 5: Build the image to verify the Dockerfile is valid**

Run from the repository root:

```sh
docker build -t dotnet-devcontainer-test -f .devcontainer/Dockerfile .devcontainer/
```

Expected: build completes with no errors. The `dotnet-install.sh` step should print something like:

```
dotnet-install: Installed version is 10.0.109
```

- [ ] **Step 6: Verify the SDK version**

```sh
docker run --rm dotnet-devcontainer-test /usr/local/dotnet-sdk/dotnet --version
```

Expected output:

```
10.0.109
```

- [ ] **Step 7: Commit**

```sh
git add .devcontainer/ global.json .editorconfig
git commit -m "$(cat <<'EOF'
feat(stable): scaffold bare .NET devcontainer

add:
  - .devcontainer/Dockerfile — installs .NET 10.0.109 SDK via dotnet-install.sh
    to /usr/local/dotnet-sdk; uses APT cache mounts for fast rebuilds
  - .devcontainer/devcontainer.json — C# Dev Kit and EditorConfig extensions;
    dotnet.dotnetPath set to match SDK install location
  - global.json — pins SDK to 10.0.109 with rollForward latestPatch
  - .editorconfig — standard .NET code style defaults
EOF
)"
```

---

### Task 2: Update `.gitignore` and rewrite `README.md`

**Files:**
- Modify: `.gitignore`
- Modify: `README.md`

**Interfaces:**
- Consumes: nothing from Task 1
- Produces: `.superpowers/` and `.claude/` are gitignored; `README.md` describes the bare template

- [ ] **Step 1: Append to `.gitignore`**

Add these two lines at the end of the existing `.gitignore`:

```
# Internal development artefacts — not part of the template
.superpowers/
.claude/
```

- [ ] **Step 2: Verify `.superpowers/` and `.claude/` are ignored**

```sh
git status
```

Expected: neither `.superpowers/` nor `.claude/` appears in the output (they are ignored, not untracked).

- [ ] **Step 3: Rewrite `README.md`**

Replace the entire file with:

```markdown
# dotnet-devcontainer-template

A bare .NET dev container scaffold for VS Code. Clone it, open it in a container,
then scaffold your project with `dotnet new`.

## Prerequisites

- [VS Code](https://code.visualstudio.com/)
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- Docker

## Usage

1. Click **Use this template → Create a new repository** on GitHub.
2. Clone your new repository.
3. Open it in VS Code and select **Reopen in Container** when prompted.
4. Wait for the container to build.
5. Scaffold your project:

   ```sh
   dotnet new console -n MyApp -o src/MyApp    # Console App
   dotnet new classlib -n MyLib -o src/MyLib   # Class Library
   dotnet new webapi  -n MyApi -o src/MyApi    # ASP.NET Core Web API
   ```

## What's included

- `.devcontainer/Dockerfile` — .NET 10 SDK installed via `dotnet-install.sh`; non-root `vscode` user (uid/gid 1000) provided by the base image
- `.devcontainer/devcontainer.json` — C# Dev Kit and EditorConfig extensions; SDK path configured
- `global.json` — pins SDK to `10.0.109` with `rollForward: latestPatch`
- `.editorconfig` — standard .NET code style

## Licence

MIT — see [`.github/LICENSE`](.github/LICENSE).
```

- [ ] **Step 4: Verify `git diff` looks correct**

```sh
git diff README.md
```

Confirm the old variant-link table is gone and the new bare-template content is present.

- [ ] **Step 5: Commit**

```sh
git add .gitignore README.md
git commit -m "$(cat <<'EOF'
chore(stable): gitignore dev artefacts and update README

modify:
  - .gitignore — ignore .superpowers/ and .claude/ so they do not ship
    with the template
  - README.md — rewrite for bare devcontainer template; replaces variant
    branch table with dotnet new scaffold instructions
EOF
)"
```

---

### Task 3: Delete template branches

**Files:** none — git operations only

**Interfaces:**
- Consumes: nothing from Tasks 1–2 (independent; can run any time after Task 1 is committed)
- Produces: no `template/*` branches exist locally or on GitHub

- [ ] **Step 1: Confirm which branches exist**

```sh
git branch -a
```

Expected before deletion:

```
* stable
  template/console
  template/library
  template/web-api
```

- [ ] **Step 2: Delete local branches**

```sh
git branch -d template/console template/library template/web-api
```

Expected:

```
Deleted branch template/console (was <sha>).
Deleted branch template/library (was <sha>).
Deleted branch template/web-api (was <sha>).
```

If any branch reports "not fully merged", use `-D` (force) — these branches are being intentionally retired.

- [ ] **Step 3: Delete remote branches on GitHub**

No git remote is configured locally. Use the `gh` CLI (authenticate first if needed with `gh auth login`):

```sh
gh repo view AxlER8R/dotnet-devcontainer-template  # confirm you can reach the repo
gh api -X DELETE repos/AxlER8R/dotnet-devcontainer-template/git/refs/heads/template/console
gh api -X DELETE repos/AxlER8R/dotnet-devcontainer-template/git/refs/heads/template/library
gh api -X DELETE repos/AxlER8R/dotnet-devcontainer-template/git/refs/heads/template/web-api
```

Each command returns HTTP 204 (no output) on success.

**Alternative — GitHub web UI:** Navigate to `github.com/AxlER8R/dotnet-devcontainer-template/branches` and delete each `template/*` branch from there.

- [ ] **Step 4: Verify**

```sh
git branch -a
```

Expected after deletion:

```
* stable
```

No `template/*` entries (local or remote).
