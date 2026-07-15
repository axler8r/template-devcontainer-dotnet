# GitHub Copilot Instructions

## Mission

This repository is a template for bootstrapping .NET projects inside a VS Code Dev Container.
When suggesting changes, optimize for maintainable template behavior rather than one-off project customizations.

## Canonical Sources

- Use this file as the canonical source for Copilot behavior in this repository.
- Use `.github/CONTRIBUTING.md` for contributor workflow and PR expectations.
- `CLAUDE.md` remains Claude-specific and may contain non-Copilot details.

## Repository Guardrails

- Keep `vscode` as the non-root user with uid/gid `1000` in `.devcontainer/Dockerfile`.
- Keep `global.json` SDK version aligned with `DOTNET_SDK_VERSION` in `.devcontainer/Dockerfile`.
- Do not run restore/build/publish steps inside `.devcontainer/Dockerfile`.
- Declare editor extensions in `.devcontainer/devcontainer.json`, not by installing them in Dockerfile image layers.

## .NET Workflow Defaults

Prefer these commands unless the user asks for alternatives:

```sh
dotnet restore
dotnet build
dotnet test
dotnet run
```

Single-test execution:

```sh
dotnet test --filter "FullyQualifiedName~<TestName>"
```

## Git and PR Workflow

- Default PR target branch is `main`.
- Create a working branch named `wip/YYYYMMDD-<slug>`.
- Push the branch and open a PR; do not merge locally.
- After merge on GitHub, update local `main` and delete the WIP branch.

## Specs and Planning

- Track specs/plans as GitHub issues with label `spec`.
- Issue title format: `<type>(<context>): <description>`.
- Use sections: `Purpose`, `Scope`, `Design`, `Plan`.

## Conflict Handling

When documentation appears inconsistent, prefer conservative behavior:

- Ask for confirmation before suggesting workflow-changing actions.
- Avoid silently rewriting branch strategy, release process, or repository governance.

## Prohibited Actions

- Do not introduce Dockerfile steps that restore/build project artifacts.
- Do not change SDK version in only one place; update Dockerfile and `global.json` together.
- Do not bypass contributor workflow expectations in `.github/CONTRIBUTING.md`.