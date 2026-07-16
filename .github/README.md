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
- `.devcontainer/devcontainer.json` — development-only tooling via Dev Container Features (Python, GitHub CLI, ZSH productivity defaults) and VS Code extensions (C# Dev Kit, EditorConfig, GitHub Copilot, Copilot Chat)
- `.devcontainer/devcontainer.local.json.example` — optional local override template for personal extensions/settings
- `global.json` — pins SDK to `10.0.109` with `rollForward: latestPatch`
- `.editorconfig` — standard .NET code style
- `.gitignore` — standard .NET gitignore

## Layering Contract

The SDLC components are split across three layers.

**Implementation layer** — `.devcontainer/Dockerfile`:
- The base OS
- The runtime
- The minimum OS and runtime dependencies required to run the implementation
- The implementation and its dependencies

**Development layer** — `.devcontainer/devcontainer.json`:
- Python for scripting
- GitHub Copilot
- GitHub CLI
- ZSH shell
- ZSH productivity tooling
- All the Visual Studio Code extensions needed to do development

**Personal layer** — `.devcontainer/devcontainer.local.json`:
- Developer-specific extensions and settings
- Intentionally not version controlled; use `.devcontainer/devcontainer.local.json.example` as a starting point

## Contributor Guidance

- Contributor workflow and PR expectations: [`.github/CONTRIBUTING.md`](CONTRIBUTING.md)
- GitHub Copilot repository instructions: [`.github/copilot-instructions.md`](copilot-instructions.md)

## Licence

MIT — see [`.github/LICENSE`](.github/LICENSE).
