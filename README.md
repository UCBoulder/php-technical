# PHP Hello World

## GitHub Codespaces

Open the repository in GitHub Codespaces. The development container installs
PHP 8.3 and the same Codex, Claude Code, and GitHub Copilot command-line tools
used by the reference technical-assessment environment. It also validates the
program automatically when the Codespace is created.

From the Codespace terminal, run:

```sh
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
