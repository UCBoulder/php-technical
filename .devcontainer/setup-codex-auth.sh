#!/usr/bin/env bash

set -euo pipefail
umask 077

if [[ -z "${CODEX_AUTH_JSON:-}" ]]; then
  echo "CODEX_AUTH_JSON is required. An interview administrator must add it as a repository-level GitHub Codespaces secret." >&2
  exit 1
fi

codex_dir="${HOME}/.codex"
auth_file="${codex_dir}/auth.json"

install -d -m 0700 "${codex_dir}"
chmod 0700 "${codex_dir}"
auth_tmp="$(mktemp "${codex_dir}/auth.json.tmp.XXXXXX")"

cleanup() {
  if [[ -n "${auth_tmp:-}" && -f "${auth_tmp}" ]]; then
    unlink "${auth_tmp}"
  fi
}
trap cleanup EXIT

printf '%s' "${CODEX_AUTH_JSON}" > "${auth_tmp}"
chmod 0600 "${auth_tmp}"

php -r 'json_decode(stream_get_contents(STDIN), true, 512, JSON_THROW_ON_ERROR);' < "${auth_tmp}"

mv "${auth_tmp}" "${auth_file}"
auth_tmp=""

echo "Codex credentials installed at ~/.codex/auth.json"
