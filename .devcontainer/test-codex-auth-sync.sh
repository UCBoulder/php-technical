#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
test_root="$(mktemp -d "${TMPDIR:-/tmp}/php-technical-auth-test.XXXXXX")"
fixture_dir="${test_root}/.devcontainer"

cleanup() {
  rm -rf -- "${test_root}"
}
trap cleanup EXIT

export CODEX_AUTH_HOME="${test_root}/codex"
export CODEX_AUTH_REPOSITORY="UCBoulder/php-technical"
unset GH_TOKEN GITHUB_TOKEN

install -d -m 0700 \
  "${fixture_dir}/bin" \
  "${fixture_dir}/node_modules/.bin"
cp "${script_dir}/setup-codex-auth.sh" "${fixture_dir}/setup-codex-auth.sh"
cp "${script_dir}/sync-codex-auth.sh" "${fixture_dir}/sync-codex-auth.sh"
cp "${script_dir}/bin/codex" "${fixture_dir}/bin/codex"

# CODEX_AUTH_HOME must expand later when the generated fixture runs.
# shellcheck disable=SC2016
printf '%s\n' \
  '#!/usr/bin/env bash' \
  'printf '\''%s'\'' '\''{"tokens":{"refresh_token":"refreshed"}}'\'' > "${CODEX_AUTH_HOME}/auth.json"' \
  > "${fixture_dir}/node_modules/.bin/codex"
chmod 0755 \
  "${fixture_dir}/setup-codex-auth.sh" \
  "${fixture_dir}/sync-codex-auth.sh" \
  "${fixture_dir}/bin/codex" \
  "${fixture_dir}/node_modules/.bin/codex"

# Invoked by the scripts through the exported function.
# shellcheck disable=SC2329
php() {
  jq -e . >/dev/null
}

# Invoked by the scripts through the exported function.
# shellcheck disable=SC2329
gh() {
  [[ -z "${GH_TOKEN:-}" ]]

  case "$*" in
    "api repos/UCBoulder/php-technical/codespaces/secrets/public-key")
      return 0
      ;;
    "secret set CODEX_AUTH_JSON --app codespaces --repo UCBoulder/php-technical")
      cmp - "${CODEX_AUTH_HOME}/auth.json"
      ;;
    *)
      return 1
      ;;
  esac
}

export -f php gh

CODEX_AUTH_JSON='{"tokens":{"refresh_token":"initial"}}' \
  "${fixture_dir}/setup-codex-auth.sh" >/dev/null

[[ "$(jq -r '.tokens.refresh_token' "${CODEX_AUTH_HOME}/auth.json")" == "refreshed" ]]

if command -v sha256sum >/dev/null 2>&1; then
  expected_hash="$(sha256sum "${CODEX_AUTH_HOME}/auth.json" | awk '{print $1}')"
else
  expected_hash="$(shasum -a 256 "${CODEX_AUTH_HOME}/auth.json" | awk '{print $1}')"
fi
IFS= read -r saved_hash < "${CODEX_AUTH_HOME}/.last-synced-auth.sha256"
[[ "${saved_hash}" == "${expected_hash}" ]]

printf '%s' '{"tokens":{"refresh_token":"refreshed-again"}}' > "${CODEX_AUTH_HOME}/auth.json"

# Invoked by the script through the exported function.
# shellcheck disable=SC2329
gh() {
  [[ -z "${GH_TOKEN:-}" ]]
  [[ "$*" == "secret set CODEX_AUTH_JSON --app codespaces --repo UCBoulder/php-technical" ]]
  cmp - "${CODEX_AUTH_HOME}/auth.json"
}
export -f gh

"${fixture_dir}/sync-codex-auth.sh" >/dev/null

# Invoked by the script through the exported function.
# shellcheck disable=SC2329
gh() {
  return 99
}
export -f gh

"${fixture_dir}/sync-codex-auth.sh" >/dev/null

export CODEX_AUTH_HOME="${test_root}/preflight-failure-codex"

# Invoked by the script through the exported function.
# shellcheck disable=SC2329
gh() {
  return 1
}
export -f gh

if CODEX_AUTH_JSON='{"tokens":{"refresh_token":"preflight-initial"}}' \
  "${fixture_dir}/setup-codex-auth.sh" >/dev/null 2>&1; then
  echo "Setup unexpectedly continued after the GitHub preflight failed" >&2
  exit 1
fi

[[ "$(jq -r '.tokens.refresh_token' "${CODEX_AUTH_HOME}/auth.json")" == "preflight-initial" ]]

echo "Codex credential writeback test passed"
