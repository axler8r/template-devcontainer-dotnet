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
      make

RUN command -v zsh  >/dev/null || { echo "zsh missing from base image"; exit 1; } && \
    command -v git  >/dev/null || { echo "git missing from base image"; exit 1; } && \
    [ "$(id -u vscode)" = "1000" ] || { echo "vscode uid != 1000"; exit 1; } && \
    [ "$(id -g vscode)" = "1000" ] || { echo "vscode gid != 1000"; exit 1; }

RUN curl -sSL https://dot.net/v1/dotnet-install.sh \
      | bash -s -- --version $DOTNET_SDK_VERSION --install-dir $DOTNET_ROOT --no-path && \
    chown -R vscode:vscode $DOTNET_ROOT
