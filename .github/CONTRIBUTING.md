# Contributing

Thank you for taking the time to contribute.

## Prerequisites

- A GitHub account
- Git installed locally

## Workflow

1. Fork the repository and clone your fork.
2. Create a feature branch:

   ```sh
   git checkout -b wip/YYYYMMDD-<short-description>
   ```

3. Make your changes, committing frequently. Follow the
   [Conventional Commits](https://www.conventionalcommits.org/) specification:

   ```
   feat(scope): add something new
   fix(scope): correct something broken
   docs(scope): update documentation
   ```

4. Push your branch and open a Pull Request against `main`.
5. Do not merge locally; merge via GitHub after review and passing checks.

## Pull Request Expectations

- One concern per PR — keep changes focused.
- CI must pass before review.
- Describe *why* the change is needed in the PR body.

## Code of Conduct

By participating in this project you agree to abide by the
[Code of Conduct](CODE_OF_CONDUCT.md).
