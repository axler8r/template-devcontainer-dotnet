# .NET Dev Container Template Repository — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Populate `dotnet-devcontainer-template` with four branches — a `stable` landing branch and three standalone orphan GitHub template branches (`template/web-api`, `template/library`, `template/console`), each containing a Dev Container scaffold and a pre-scaffolded .NET project.

**Architecture:** Variant branches are git orphan branches (no shared ancestor) so each is fully self-contained as a GitHub template. The `stable` branch holds the landing README and project infrastructure. Dev Containers use `mcr.microsoft.com/devcontainers/base:ubuntu-24.04` (which provides the `vscode` user at uid/gid 1000 and ZSH) with .NET SDK 9.0 added via the Microsoft package feed.

**Tech Stack:** .NET 9.0 SDK, Docker, VS Code Dev Containers, NuGet.

## Global Constraints

- Base image: `mcr.microsoft.com/devcontainers/base:ubuntu-24.04`
- Remote user: `vscode` (uid/gid 1000, provided by base image — do not re-create)
- .NET SDK: `dotnet-sdk-9.0` via Microsoft package feed; pin exact patch in `global.json` (e.g. `9.0.300` — verify at implementation time, see Task 2 Step 2)
- `rollForward`: `"latestPatch"` in `global.json`
- Project names: `Template.WebApi`, `Template.Library`, `Template.Console`
- Project location: `src/<ProjectName>/`
- VS Code extensions: `ms-dotnettools.csharp`, `ms-dotnettools.csdevkit`, `editorconfig.editorconfig`
- `postCreateCommand`: `"dotnet restore"`
- MIT licence year: 2026, holder: AxlER8R
- No solution file, no docker-compose, no CI workflows

---

### Task 1: Fix stable branch and add landing README

**Files:**
- Rename: `.github/REAME.md` → `.github/README.md`
- Modify: `.github/LICENSE` (add MIT licence text)
- Create: `README.md` (landing page)
- Modify: `.superpowers/specs/2026-07-01-template-repo-design.md` (mark known issue resolved)

**Interfaces:**
- Produces: Complete `stable` branch ready for users to browse on GitHub

- [ ] **Step 1: Rename the typo'd file**

```bash
git mv .github/REAME.md .github/README.md
```

- [ ] **Step 2: Add MIT licence content to `.github/LICENSE`**

The file exists but is empty. Write the following content:

```
MIT License

Copyright (c) 2026 AxlER8R

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 3: Create the landing `README.md`**

```markdown
# dotnet-devcontainer-template

GitHub template repository for bootstrapping .NET projects inside a VS Code Dev Container.

## Variants

Pick the branch that matches your project type and click **Use this template**.

| Variant | Branch | Use case |
|---|---|---|
| ASP.NET Core Web API | `template/web-api` | REST APIs and HTTP services |
| Class Library | `template/library` | Reusable .NET packages |
| Console App | `template/console` | CLI tools and background workers |

## Usage

1. Open the variant branch on GitHub.
2. Click **Use this template → Create a new repository**.
3. Clone your new repository.
4. Open it in VS Code and select **Reopen in Container** when prompted.
5. Rename the project: update the `src/<ProjectName>/` directory, `.csproj` filename, and namespace declarations throughout.

## What's included

- `.devcontainer/Dockerfile` — .NET SDK, and a non-root `vscode` user
- `.devcontainer/devcontainer.json` — VS Code extension declarations and `dotnet restore` on container open
- `global.json` — SDK version pin
- `.editorconfig` — standard .NET code style
- `.gitignore` — standard .NET gitignore
- A pre-scaffolded project in `src/<ProjectName>/`

## Licence

MIT — see [`.github/LICENSE`](.github/LICENSE).
```

- [ ] **Step 4: Mark the known issue resolved in the spec**

In `.superpowers/specs/2026-07-01-template-repo-design.md`, replace the Known Issues section body with:

```markdown
~~`.github/REAME.md` in the existing scaffold has a filename typo (missing `D`). Rename to `README.md` during implementation.~~ Resolved in Task 1.
```

- [ ] **Step 5: Commit**

```bash
git add README.md .github/LICENSE .github/README.md .superpowers/specs/2026-07-01-template-repo-design.md
git commit -m "chore(stable): add landing README and fix file naming

add:
  - README.md — landing page linking to all three variant branches

modify:
  - .github/LICENSE — MIT licence text
  - .github/README.md — renamed from REAME.md (typo fix)
  - spec — mark REAME.md typo as resolved"
```

---

### Task 2: Create template/web-api branch

**Files:**
- Create: `.devcontainer/Dockerfile`
- Create: `.devcontainer/devcontainer.json`
- Create: `global.json`
- Create: `.editorconfig`
- Create: `.gitignore`
- Create: `.github/LICENSE`
- Create: `README.md`
- Generate: `src/Template.WebApi/` (via `dotnet new webapi`)

**Interfaces:**
- Produces: Standalone orphan `template/web-api` branch usable as a GitHub template; SDK patch version used here is the authoritative value for Tasks 3 and 4

- [ ] **Step 1: Create an orphan branch**

An orphan branch has no commit history — required for fully standalone template branches.

```bash
git checkout --orphan template/web-api
git rm -rf .
```

After `git rm -rf .`, the working tree is clean and the branch has no commits yet.

- [ ] **Step 2: Create `.devcontainer/Dockerfile`**

```dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

RUN apt-get update \
    && apt-get install -y wget apt-transport-https \
    && wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb \
         -O /tmp/packages-microsoft-prod.deb \
    && dpkg -i /tmp/packages-microsoft-prod.deb \
    && rm /tmp/packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y dotnet-sdk-9.0 make \
    && rm -rf /var/lib/apt/lists/*
```

- [ ] **Step 3: Create `.devcontainer/devcontainer.json`**

```json
{
  "name": "Template.WebApi",
  "dockerFile": "Dockerfile",
  "remoteUser": "vscode",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-dotnettools.csharp",
        "ms-dotnettools.csdevkit",
        "editorconfig.editorconfig"
      ]
    }
  },
  "postCreateCommand": "dotnet restore"
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
```

- [ ] **Step 5: Copy `.gitignore` from stable**

```bash
git show stable:.gitignore > .gitignore
```

- [ ] **Step 6: Create `.github/LICENSE`**

```
MIT License

Copyright (c) 2026 AxlER8R

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 7: Create `README.md`**

```markdown
# Template.WebApi

ASP.NET Core Web API Dev Container template.

## Prerequisites

- [VS Code](https://code.visualstudio.com/)
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- Docker

## Usage

1. Click **Use this template → Create a new repository** on GitHub.
2. Clone your new repository.
3. Open it in VS Code and select **Reopen in Container** when prompted.
4. Wait for the container to build and `dotnet restore` to complete.

## Rename the project

Replace `Template.WebApi` with your project name:

1. Rename the `src/Template.WebApi/` directory.
2. Rename the `.csproj` file inside it to match.
3. Update the namespace in all `.cs` files.
4. Update `"name"` in `.devcontainer/devcontainer.json`.

## Common commands

```sh
dotnet restore
dotnet build
dotnet run --project src/Template.WebApi
dotnet test
```

## Licence

MIT — see [`.github/LICENSE`](.github/LICENSE).
```

- [ ] **Step 8: Build image, pin SDK version, and scaffold project**

Build the devcontainer image. The `.devcontainer` directory is the build context:

```bash
docker build -f .devcontainer/Dockerfile .devcontainer -t template-web-api
```

Expected: no errors, image tagged `template-web-api`.

Get the exact SDK version installed in the image:

```bash
docker run --rm template-web-api dotnet --version
```

Create `global.json` using the version string printed above (e.g. `9.0.315`):

```json
{
  "sdk": {
    "version": "9.0.315",
    "rollForward": "latestPatch"
  }
}
```

Scaffold the Web API project inside the image, mounting the repo root:

```bash
docker run --rm -v "$(pwd)":/workspace -w /workspace template-web-api \
  dotnet new webapi -n Template.WebApi -o src/Template.WebApi
```

Expected: `src/Template.WebApi/` created with `.csproj`, `Program.cs`, `appsettings*.json`, `Properties/launchSettings.json`.

- [ ] **Step 9: Verify the project builds inside the image**

```bash
docker run --rm -v "$(pwd)":/workspace -w /workspace template-web-api \
  dotnet build src/Template.WebApi
```

Expected: `Build succeeded.`

- [ ] **Step 10: Commit**

```bash
git add .devcontainer/ .editorconfig .gitignore .github/LICENSE global.json README.md src/
git commit -m "feat(web-api): scaffold ASP.NET Core Web API dev container template

add:
  - .devcontainer/Dockerfile — .NET 9 SDK on ubuntu-24.04 base with make
  - .devcontainer/devcontainer.json — C# Dev Kit extensions, dotnet restore on open
  - global.json — .NET 9.0 SDK version pin with latestPatch rollforward
  - .editorconfig — standard .NET code style
  - .gitignore — standard .NET gitignore
  - .github/LICENSE — MIT licence
  - src/Template.WebApi — dotnet new webapi scaffold with OpenAPI
  - README.md — usage and rename instructions"
```

---

### Task 3: Create template/library branch

**Files:**
- Create: `.devcontainer/Dockerfile` (same content as Task 2)
- Create: `.devcontainer/devcontainer.json`
- Create: `global.json` (same SDK version as Task 2)
- Create: `.editorconfig` (same content as Task 2)
- Create: `.gitignore` (same content as Task 2)
- Create: `.github/LICENSE` (same content as Task 2)
- Create: `README.md`
- Generate: `src/Template.Library/` (via `dotnet new classlib`)

**Interfaces:**
- Depends on: Task 2 Step 8 (SDK patch version — read from `template/web-api` branch: `git show template/web-api:global.json`)
- Produces: Standalone orphan `template/library` branch usable as a GitHub template

- [ ] **Step 1: Create an orphan branch**

```bash
git checkout --orphan template/library
git rm -rf .
```

- [ ] **Step 2: Create `.devcontainer/Dockerfile`**

.NET 10 is installed directly from Ubuntu's native `noble-updates` repo — no Microsoft packages feed needed.

```dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

RUN apt-get update \
    && apt-get install -y dotnet-sdk-10.0 make \
    && rm -rf /var/lib/apt/lists/*
```

- [ ] **Step 3: Create `.devcontainer/devcontainer.json`**

```json
{
  "name": "Template.Library",
  "dockerFile": "Dockerfile",
  "remoteUser": "vscode",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-dotnettools.csharp",
        "ms-dotnettools.csdevkit",
        "editorconfig.editorconfig"
      ]
    }
  },
  "postCreateCommand": "dotnet restore"
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
```

- [ ] **Step 5: Copy `.gitignore` from stable**

```bash
git show stable:.gitignore > .gitignore
```

- [ ] **Step 6: Create `.github/LICENSE`**

```
MIT License

Copyright (c) 2026 AxlER8R

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 7: Create `README.md`**

```markdown
# Template.Library

.NET Class Library Dev Container template.

## Prerequisites

- [VS Code](https://code.visualstudio.com/)
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- Docker

## Usage

1. Click **Use this template → Create a new repository** on GitHub.
2. Clone your new repository.
3. Open it in VS Code and select **Reopen in Container** when prompted.
4. Wait for the container to build and `dotnet restore` to complete.

## Rename the project

Replace `Template.Library` with your project name:

1. Rename the `src/Template.Library/` directory.
2. Rename the `.csproj` file inside it to match.
3. Update the namespace in all `.cs` files.
4. Update `"name"` in `.devcontainer/devcontainer.json`.

## Common commands

```sh
dotnet restore
dotnet build
dotnet test
```

## Licence

MIT — see [`.github/LICENSE`](.github/LICENSE).
```

- [ ] **Step 8: Build image, pin SDK version, and scaffold project**

```bash
docker build -f .devcontainer/Dockerfile .devcontainer -t template-library
```

Create `global.json` — use the version from Task 2 (`git show template/web-api:global.json` confirms `10.0.109`):

```json
{
  "sdk": {
    "version": "10.0.109",
    "rollForward": "latestPatch"
  }
}
```

Scaffold the Class Library project. Run as the current host user to avoid root-owned files:

```bash
docker run --rm -v "$(pwd)":/workspace -w /workspace --user "$(id -u):$(id -g)" template-library \
  dotnet new classlib -n Template.Library -o src/Template.Library
```

Expected: `src/Template.Library/` created with `.csproj` and `Class1.cs`.

- [ ] **Step 9: Verify the project builds inside the image**

```bash
docker run --rm -v "$(pwd)":/workspace -w /workspace --user "$(id -u):$(id -g)" template-library \
  dotnet build src/Template.Library
```

Expected: `Build succeeded.`

- [ ] **Step 10: Commit**

```bash
git add .devcontainer/ .editorconfig .gitignore .github/LICENSE global.json README.md src/
git commit -m "feat(library): scaffold .NET class library dev container template

add:
  - .devcontainer/Dockerfile — .NET 10 SDK on ubuntu-24.04 base with make
  - .devcontainer/devcontainer.json — C# Dev Kit extensions, dotnet restore on open
  - global.json — .NET 9.0 SDK version pin with latestPatch rollforward
  - .editorconfig — standard .NET code style
  - .gitignore — standard .NET gitignore
  - .github/LICENSE — MIT licence
  - src/Template.Library — dotnet new classlib scaffold
  - README.md — usage and rename instructions"
```

---

### Task 4: Create template/console branch

**Files:**
- Create: `.devcontainer/Dockerfile` (same content as Tasks 2–3)
- Create: `.devcontainer/devcontainer.json`
- Create: `global.json` (same SDK version as Tasks 2–3)
- Create: `.editorconfig` (same content as Tasks 2–3)
- Create: `.gitignore` (same content as Tasks 2–3)
- Create: `.github/LICENSE` (same content as Tasks 2–3)
- Create: `README.md`
- Generate: `src/Template.Console/` (via `dotnet new console`)

**Interfaces:**
- Depends on: Task 2 Step 8 (SDK patch version — read from `template/web-api` branch: `git show template/web-api:global.json`)
- Produces: Standalone orphan `template/console` branch usable as a GitHub template

- [ ] **Step 1: Create an orphan branch**

```bash
git checkout --orphan template/console
git rm -rf .
```

- [ ] **Step 2: Create `.devcontainer/Dockerfile`**

.NET 10 is installed directly from Ubuntu's native `noble-updates` repo — no Microsoft packages feed needed.

```dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

RUN apt-get update \
    && apt-get install -y dotnet-sdk-10.0 make \
    && rm -rf /var/lib/apt/lists/*
```

- [ ] **Step 3: Create `.devcontainer/devcontainer.json`**

```json
{
  "name": "Template.Console",
  "dockerFile": "Dockerfile",
  "remoteUser": "vscode",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-dotnettools.csharp",
        "ms-dotnettools.csdevkit",
        "editorconfig.editorconfig"
      ]
    }
  },
  "postCreateCommand": "dotnet restore"
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
```

- [ ] **Step 5: Copy `.gitignore` from stable**

```bash
git show stable:.gitignore > .gitignore
```

- [ ] **Step 6: Create `.github/LICENSE`**

```
MIT License

Copyright (c) 2026 AxlER8R

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 7: Create `README.md`**

```markdown
# Template.Console

.NET Console App Dev Container template.

## Prerequisites

- [VS Code](https://code.visualstudio.com/)
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- Docker

## Usage

1. Click **Use this template → Create a new repository** on GitHub.
2. Clone your new repository.
3. Open it in VS Code and select **Reopen in Container** when prompted.
4. Wait for the container to build and `dotnet restore` to complete.

## Rename the project

Replace `Template.Console` with your project name:

1. Rename the `src/Template.Console/` directory.
2. Rename the `.csproj` file inside it to match.
3. Update the namespace in all `.cs` files.
4. Update `"name"` in `.devcontainer/devcontainer.json`.

## Common commands

```sh
dotnet restore
dotnet build
dotnet run --project src/Template.Console
```

## Licence

MIT — see [`.github/LICENSE`](.github/LICENSE).
```

- [ ] **Step 8: Build image, pin SDK version, and scaffold project**

```bash
docker build -f .devcontainer/Dockerfile .devcontainer -t template-console
```

Create `global.json` — use the version from Task 2 (`git show template/web-api:global.json` confirms `10.0.109`):

```json
{
  "sdk": {
    "version": "10.0.109",
    "rollForward": "latestPatch"
  }
}
```

Scaffold the Console project. Run as the current host user to avoid root-owned files:

```bash
docker run --rm -v "$(pwd)":/workspace -w /workspace --user "$(id -u):$(id -g)" template-console \
  dotnet new console -n Template.Console -o src/Template.Console
```

Expected: `src/Template.Console/` created with `.csproj` and `Program.cs`.

- [ ] **Step 9: Verify the project builds inside the image**

```bash
docker run --rm -v "$(pwd)":/workspace -w /workspace --user "$(id -u):$(id -g)" template-console \
  dotnet build src/Template.Console
```

Expected: `Build succeeded.`

- [ ] **Step 10: Commit**

```bash
git add .devcontainer/ .editorconfig .gitignore .github/LICENSE global.json README.md src/
git commit -m "feat(console): scaffold .NET console app dev container template

add:
  - .devcontainer/Dockerfile — .NET 10 SDK on ubuntu-24.04 base with make
  - .devcontainer/devcontainer.json — C# Dev Kit extensions, dotnet restore on open
  - global.json — .NET 10.0 SDK version pin with latestPatch rollforward
  - .editorconfig — standard .NET code style
  - .gitignore — standard .NET gitignore
  - .github/LICENSE — MIT licence
  - src/Template.Console — dotnet new console scaffold
  - README.md — usage and rename instructions"
```
