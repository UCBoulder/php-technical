#!/usr/bin/env bash

set -euo pipefail
umask 077

if [[ -z "${CODEX_AUTH_JSON:-}" ]]; then
  echo "CODEX_AUTH_JSON is required. An interview administrator must add it as a repository-level GitHub Codespaces secret." >&2
  exit 1
fi

codex_dir="${CODEX_AUTH_HOME:-${HOME}/.codex}"
auth_file="${codex_dir}/auth.json"
auth_hash_file="${codex_dir}/.last-synced-auth.sha256"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

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

if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "${auth_file}" | awk '{print $1}' > "${auth_hash_file}"
else
  shasum -a 256 "${auth_file}" | awk '{print $1}' > "${auth_hash_file}"
fi
chmod 0600 "${auth_hash_file}"

"${script_dir}/sync-codex-auth.sh" --check

echo "Codex credentials installed at ~/.codex/auth.json; refreshing them now."
"${script_dir}/bin/codex" exec \
  --skip-git-repo-check \
  --sandbox read-only \
  "Reply with only: ready" >/dev/null

echo "Codex credentials are ready and saved for the next Codespace."
