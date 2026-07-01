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

RUN curl -sSL https://dot.net/v1/dotnet-install.sh \
      | bash -s -- --version $DOTNET_SDK_VERSION --install-dir $DOTNET_ROOT --no-path && \
    chown -R vscode:vscode $DOTNET_ROOT
