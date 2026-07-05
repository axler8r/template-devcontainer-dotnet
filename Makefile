# variables --------------------------------------------------------->8---------
SHELL     := /usr/bin/env zsh
DOTNET    ?= dotnet
SOLUTION  := $(wildcard *.sln)
TEST_NAME :=

# usage: $(call env-upsert,KEY,VALUE) — upsert KEY into .env, preserving other lines
define env-upsert
{ grep -v '^$(1)=' .env 2>/dev/null; echo "$(1)=$(2)"; } > .env.tmp && mv .env.tmp .env
endef

-include .env


# phony ------------------------------------------------------------->8---------
.PHONY: help \
        init restore \
        build run watch \
        format \
        publish \
        test test-filter \
        clean \
        target


# default target ---------------------------------------------------->8---------
help: ## Show this help message
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_.-]+:.*?## / {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Quick Start:"
	@echo "  make target     # Set the run project"
	@echo "  make restore    # Restore NuGet packages"
	@echo "  make build      # Build the solution"
	@echo "  make test       # Run tests"


# setup targets ----------------------------------------------------->8---------
init: ## Initialise project kind (api, library, cli, gui, worker)
	@echo "Select project kind:" \
		&& echo "  1) api     — ASP.NET Core Web API" \
		&& echo "  2) library — class library" \
		&& echo "  3) cli     — console application" \
		&& echo "  4) gui     — desktop GUI (WPF / WinForms)" \
		&& echo "  5) worker  — background worker service" \
		&& read "choice?Enter kind [1-5]: " \
		&& case $$choice in \
			1) kind=api ;; \
			2) kind=library ;; \
			3) kind=cli ;; \
			4) kind=gui ;; \
			5) kind=worker ;; \
			*) echo "Invalid choice: $$choice" && exit 1 ;; \
		esac \
		&& $(call env-upsert,KIND,$$kind) \
		&& echo "KIND=$$kind written to .env"

restore: ## Restore NuGet packages
	@echo "Restoring NuGet packages..."
	$(DOTNET) restore $(SOLUTION)


# lifecycle targets ------------------------------------------------->8---------
build: ## Build the solution
	@echo "Building solution..."
	$(DOTNET) build $(SOLUTION)

run: ## Run the application (set project first: make target)
	@test -n "$(RUN_PROJECT)" || (echo "RUN_PROJECT is not set — run 'make target' first" && exit 1)
	@echo "Running $(RUN_PROJECT)..."
	$(DOTNET) run --project $(RUN_PROJECT)

watch: ## Run with hot reload (set project first: make target)
	@test -n "$(RUN_PROJECT)" || (echo "RUN_PROJECT is not set — run 'make target' first" && exit 1)
	@echo "Watching $(RUN_PROJECT)..."
	$(DOTNET) watch --project $(RUN_PROJECT)


# quality targets --------------------------------------------------->8---------
format: ## Format source code
	@echo "Formatting source..."
	$(DOTNET) format $(SOLUTION)


# release targets --------------------------------------------------->8---------
publish: ## Publish release build
	@echo "Publishing release build..."
	$(DOTNET) publish $(SOLUTION) --configuration Release


# test targets ------------------------------------------------------>8---------
test: ## Run all tests
	@echo "Running tests..."
	$(DOTNET) test $(SOLUTION)

test-filter: ## Run a single test by name (usage: make test-filter TEST_NAME=MyTest)
	@test -n "$(TEST_NAME)" || (echo "TEST_NAME is not set — usage: make test-filter TEST_NAME=MyTest" && exit 1)
	@echo "Running test: $(TEST_NAME)..."
	$(DOTNET) test $(SOLUTION) --filter "FullyQualifiedName~$(TEST_NAME)"


# maintenance targets ----------------------------------------------->8---------
clean: ## Clean build artefacts
	@echo "Cleaning solution..."
	$(DOTNET) clean $(SOLUTION)
	@echo "Removing bin and obj directories..."
	find . -type d \( -name bin -o -name obj \) -not -path './.git/*' \
		-exec rm -rf {} + 2>/dev/null || true


# utility targets --------------------------------------------------->8---------
target: ## Set the run project path (writes RUN_PROJECT to .env)
	@read "project?Enter run project path (e.g. src/MyApp/MyApp.csproj): " \
		&& $(call env-upsert,RUN_PROJECT,$$project) \
		&& echo "RUN_PROJECT written to .env"
