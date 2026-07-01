# Template Repository Design

**Date:** 2026-07-01
**Topic:** .NET Dev Container GitHub template repository

---

## Purpose

A GitHub template repository that bootstraps .NET projects inside a Dev Container. Users click "Use this template" on a variant branch and get a ready-to-open scaffold with a pre-scaffolded .NET project.

---

## Branch Structure

The repository has four branches:

| Branch | Purpose |
|---|---|
| `stable` | Landing branch — README only, describes the template and links to all three variants |
| `template/web-api` | Standalone ASP.NET Core Web API variant |
| `template/library` | Standalone Class Library variant |
| `template/console` | Standalone Console App variant |

Each variant branch is independently usable as a GitHub template. Branches are standalone — no shared ancestor between variants. Changes common to all variants must be applied to each branch separately.

---

## File Structure (per variant branch)

```
.devcontainer/
  Dockerfile
  devcontainer.json
.github/
  LICENSE
src/
  <ProjectName>/
    <ProjectName>.csproj
    ...
.editorconfig
.gitignore
global.json
README.md
```

Project names use the `Template.*` prefix:

| Branch | Project name |
|---|---|
| `template/web-api` | `Template.WebApi` |
| `template/library` | `Template.Library` |
| `template/console` | `Template.Console` |

Users rename the project name, namespace, and `.csproj` filename after cloning. There is no solution file by default.

---

## Dev Container Configuration

### `Dockerfile`

- Installs the .NET SDK via the official Microsoft package feed, version pinned to match `global.json`
- Installs ZSH, `make`, `git`
- Creates a non-root user `vscode` with uid/gid 1000
- SDK installation placed early in the file to maximise layer cache reuse
- No project restore or build steps in the image

### `devcontainer.json`

- References `Dockerfile` directly (no Compose)
- `"remoteUser": "vscode"`
- `"postCreateCommand": "dotnet restore"` — restores NuGet packages on first container open
- VS Code extensions:
  - `ms-dotnettools.csharp` — C# language support
  - `ms-dotnettools.csdevkit` — CS Dev Kit (solution explorer, test runner)
  - `editorconfig.editorconfig` — EditorConfig support

### `global.json`

Pins the .NET SDK to a specific `major.minor.patch` version matching the Dockerfile install, with `"rollForward": "latestPatch"` to allow patch-level updates without breaking the pin.

---

## Project Scaffolding (per variant)

Each project is generated using `dotnet new` and committed as-is.

| Branch | Command |
|---|---|
| `template/web-api` | `dotnet new webapi -n Template.WebApi -o src/Template.WebApi` |
| `template/library` | `dotnet new classlib -n Template.Library -o src/Template.Library` |
| `template/console` | `dotnet new console -n Template.Console -o src/Template.Console` |

The Web API variant includes OpenAPI/Swagger (default `dotnet new webapi` output, no `--no-openapi` flag).

`.gitignore` is generated via `dotnet new gitignore`.

---

## Supporting Files

### `.editorconfig`

Minimal standard .NET editorconfig covering:
- Indent style (spaces, size 4)
- Charset (utf-8)
- End of line (lf)
- .NET analyser severity defaults

### `LICENSE`

MIT licence, attributed to AxlER8R. Located at `.github/LICENSE`.

### `README.md` on `stable`

- Describes the template and its purpose
- Lists the three variants with use cases
- Provides "Use this template" links for each variant branch
- Explains the rename-after-clone workflow

### `README.md` on variant branches

Covers:
1. Prerequisites (VS Code + Dev Containers extension)
2. How to use (click "Use this template", clone, reopen in container)
3. Rename instructions (project name, namespace, `.csproj` filename)
4. Common commands: `dotnet restore`, `dotnet build`, `dotnet test`, `dotnet run`

---

## Out of Scope

- Solution files (`.sln`) — users add if needed
- CI/CD workflows — not included in the initial template
- Docker Compose — not required; the Dev Container uses a single container
- Alternative package managers or runtimes
