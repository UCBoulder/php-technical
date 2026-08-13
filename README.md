# PHP Hello World

## GitHub Codespaces

Open the repository in GitHub Codespaces. The development container installs
PHP 8.3 and the same Codex, Claude Code, and GitHub Copilot command-line tools
used by the reference technical-assessment environment. It also validates the
program automatically when the Codespace is created.

Before creating the Codespace, add a user-level Codespaces secret named
`CODEX_AUTH_JSON` containing the complete contents of your local
`~/.codex/auth.json`. Scope the secret to this repository. The container setup
validates the JSON and installs it as `~/.codex/auth.json` with permissions set
to `0600`; the `~/.codex` directory is set to `0700`.

Using the GitHub CLI, configure the secret without printing it:

```sh
gh secret set CODEX_AUTH_JSON \
  --user \
  --app codespaces \
  --repos UCBoulder/php-technical \
  < ~/.codex/auth.json
```

The secret is required. If it is missing, Codespace post-creation setup stops
with instructions to add it and rebuild the container. Each developer should
use their own user-level secret; do not share a personal `auth.json` through a
repository-level or organization-level secret.

From the Codespace terminal, run:

```sh
codex login status
php index.php
make test-local
```

## Docker or Podman

Build and run the program with Docker or Podman:

```sh
make build
make run
```

To verify the output:

```sh
make test
```

With PHP 8.3 or newer installed locally, you can also run:

```sh
php index.php
make test-local
```
