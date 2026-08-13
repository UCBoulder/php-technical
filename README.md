# PHP Hello World

## GitHub Codespaces

Open the repository in GitHub Codespaces. The development container installs
PHP 8.3 and the same Codex, Claude Code, and GitHub Copilot command-line tools. 

The interview environment supplies Codex credentials automatically. Candidates
do not need an OpenAI account, a subscription, an API key, or a Codex login.

When the Codespace is created, setup validates the supplied credential JSON and
installs it as `~/.codex/auth.json`. The file is readable only by the logged-in
Codespace user.

From the Codespace terminal, run:

```sh
codex login status
php index.php
make test-local
```

### Interview administrator setup

Add `CODEX_AUTH_JSON` as a **repository-level Codespaces secret**. Its value
must be the complete contents of the interview service account's
`~/.codex/auth.json` file. It must not be configured as an Actions secret.

Using the GitHub CLI, configure it without printing it:

```sh
gh secret set CODEX_AUTH_JSON \
  --app codespaces \
  --repo UCBoulder/php-technical \
  < /secure/path/to/auth.json
```

GitHub does not copy Codespaces secrets to forks. For the zero-login experience,
give each candidate access to a UCBoulder-owned interview repository that has
the repository secret configured, and have them create the Codespace from that
repository. Use a dedicated private repository per candidate when interviews
overlap or candidate work must remain isolated.

At the end of the interview:

1. Delete the candidate's Codespace.
2. Remove the candidate's repository access.
3. Delete `CODEX_AUTH_JSON` from the interview repository.
4. Revoke or rotate the interview service-account credential.

Deleting only the GitHub secret is insufficient because a running or stopped
Codespace can retain the credential file that was already installed.

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
