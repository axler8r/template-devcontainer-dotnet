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
