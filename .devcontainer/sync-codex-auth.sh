#!/usr/bin/env bash

set -euo pipefail
umask 077

if ! command -v gh >/dev/null 2>&1; then
  echo "Cannot save refreshed Codex credentials: GitHub CLI is not installed." >&2
  exit 1
fi

codex_dir="${CODEX_AUTH_HOME:-${HOME}/.codex}"
auth_file="${codex_dir}/auth.json"
auth_hash_file="${codex_dir}/.last-synced-auth.sha256"
repository="${CODEX_AUTH_REPOSITORY:-UCBoulder/php-technical}"

github_cli() {
  if [[ -n "${CODESPACES_SECRET_WRITER_TOKEN:-}" ]]; then
    GH_TOKEN="${CODESPACES_SECRET_WRITER_TOKEN}" gh "$@"
  else
    gh "$@"
  fi
}

if [[ "${1:-}" == "--check" ]]; then
  github_cli api "repos/${repository}/codespaces/secrets/public-key" >/dev/null
  exit 0
fi

if [[ ! -f "${auth_file}" ]]; then
  echo "Cannot save refreshed Codex credentials: ${auth_file} does not exist." >&2
  exit 1
fi

php -r 'json_decode(stream_get_contents(STDIN), true, 512, JSON_THROW_ON_ERROR);' < "${auth_file}"

if command -v sha256sum >/dev/null 2>&1; then
  auth_hash="$(sha256sum "${auth_file}" | awk '{print $1}')"
else
  auth_hash="$(shasum -a 256 "${auth_file}" | awk '{print $1}')"
fi

previous_hash=""
if [[ -f "${auth_hash_file}" ]]; then
  IFS= read -r previous_hash < "${auth_hash_file}"
fi

if [[ "${auth_hash}" == "${previous_hash}" ]]; then
  exit 0
fi

github_cli secret set CODEX_AUTH_JSON \
  --app codespaces \
  --repo "${repository}" \
  < "${auth_file}"

hash_tmp="$(mktemp "${codex_dir}/auth.sha256.tmp.XXXXXX")"
cleanup() {
  if [[ -n "${hash_tmp:-}" && -f "${hash_tmp}" ]]; then
    unlink "${hash_tmp}"
  fi
}
trap cleanup EXIT

printf '%s\n' "${auth_hash}" > "${hash_tmp}"
chmod 0600 "${hash_tmp}"
mv "${hash_tmp}" "${auth_hash_file}"
hash_tmp=""

echo "Saved refreshed Codex credentials for the next Codespace."
