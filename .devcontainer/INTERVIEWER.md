# Interviewer Codespaces setup

This document describes the repository configuration used to provide Codex in
candidate Codespaces. It is intended for interview administrators.

## Required Codespaces secret

Add `CODEX_AUTH_JSON` as a repository-level Codespaces secret. Its value must
be the complete contents of the interview account's `~/.codex/auth.json` file.
Do not configure it as an Actions secret.

Using the GitHub CLI, configure it without printing it:

```sh
gh secret set CODEX_AUTH_JSON \
  --app codespaces \
  --repo UCBoulder/php-technical \
  < /secure/path/to/auth.json
```

## Credential handoff

When a Codespace is created, setup:

1. Validates and installs the supplied JSON as `~/.codex/auth.json`.
2. Confirms that GitHub can update the repository's Codespaces secret.
3. Runs a small Codex request to refresh an expired access token.
4. Writes the updated `auth.json` back to `CODEX_AUTH_JSON` for the next
   Codespace.

Later `codex` commands repeat the writeback after they exit if the credential
file changed.

The writeback first uses the GitHub credentials already available in the
Codespace. If that account cannot update repository Codespaces secrets, add an
optional `CODESPACES_SECRET_WRITER_TOKEN` repository-level Codespaces secret.
Its value must be a fine-grained GitHub token restricted to
`UCBoulder/php-technical` with repository **Codespaces secrets: Read and write**
permission.

```sh
printf '%s' "$CODESPACES_SECRET_WRITER_TOKEN" | gh secret set \
  CODESPACES_SECRET_WRITER_TOKEN \
  --app codespaces \
  --repo UCBoulder/php-technical
```

This handoff assumes interviews are sequential. Finish and delete the current
Codespace before creating the next one.

## Repository access

GitHub does not copy Codespaces secrets to forks. Give each candidate access to
a UCBoulder-owned interview repository with the Codespaces secret configured,
then have them create the Codespace from that repository. Use separate private
repositories when interviews overlap or candidate work must remain isolated.

## After an interview

1. Delete the candidate's Codespace.
2. Remove the candidate's repository access.
3. Delete `CODEX_AUTH_JSON` from the interview repository.
4. If configured, delete and revoke `CODESPACES_SECRET_WRITER_TOKEN`.
5. Revoke or rotate the interview Codex credential.

Deleting only the GitHub secret is insufficient because a running or stopped
Codespace can retain the credential file that was already installed.
