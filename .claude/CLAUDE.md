# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repository is a template for bootstrapping .NET projects inside a Dev Container. It produces a reusable scaffold containing `.devcontainer/Dockerfile`, `.devcontainer/devcontainer.json`, and supporting project files for local .NET development inside VS Code.

## Skills

Always invoke these skills at the start of relevant work:

- `using-dev-container` — Dev Container structure, Dockerfile conventions, and verification rules.
- `using-dotnet-dev-container` — .NET SDK installation, NuGet workflow, and dotnet CLI guidance.

## Intended Structure

A completed template should provide:

```
.devcontainer/
  Dockerfile          # Installs .NET SDK, ZSH, make, git; creates vscode user uid/gid 1000
  devcontainer.json   # References Dockerfile; declares VS Code extensions and settings
global.json           # Pins the .NET SDK version matched by the Dockerfile
```

## Specs and Plans

Design specs are saved to `.superpowers/specs/YYYY-MM-DD-<topic>-design.md` in the project root.

## Key Conventions

- The `vscode` user (uid/gid 1000) must be the non-root user in the Dockerfile.
- SDK version in `global.json` must match the SDK installed in the Dockerfile.
- Do not restore or build the project inside the Dockerfile.
- Extensions are declared in `devcontainer.json`, not installed locally.

## .NET Workflows

```sh
dotnet restore    # Restore NuGet packages
dotnet build      # Build the solution or project
dotnet test       # Run tests
dotnet run        # Run the application
```

Run a single test by name:

```sh
dotnet test --filter "FullyQualifiedName~<TestName>"
```
