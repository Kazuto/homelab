#!/usr/bin/env bash
# Usage:
#   ./fetch-env.sh          — fetch .env from Bitwarden
#   ./fetch-env.sh update   — push current .env back to Bitwarden
#
# Required env vars (set once in your shell profile or pass inline):
#   BW_CLIENTID      — Bitwarden API key client ID
#   BW_CLIENTSECRET  — Bitwarden API key client secret
#   BW_PASSWORD      — Bitwarden master password (for unlocking)
#
# Get your API key at: https://bitwarden.com/help/personal-api-key/

set -euo pipefail

ITEM_NAME="homelab_env"
ENV_FILE="$(dirname "$0")/.env"

# ── helpers ──────────────────────────────────────────────────────────────────

die() { echo "ERROR: $*" >&2; exit 1; }

require() {
  command -v "$1" &>/dev/null || die "'$1' is not installed (brew install $1)"
}

require bw
require jq

check_vars() {
  local missing=()
  [[ -z "${BW_CLIENTID:-}" ]]     && missing+=(BW_CLIENTID)
  [[ -z "${BW_CLIENTSECRET:-}" ]] && missing+=(BW_CLIENTSECRET)
  [[ -z "${BW_PASSWORD:-}" ]]     && missing+=(BW_PASSWORD)
  if [[ ${#missing[@]} -gt 0 ]]; then
    die "Missing required environment variables: ${missing[*]}"
  fi
}

# Login with API key (no-op if already logged in), then unlock and export session
bw_session() {
  local status
  status=$(bw status 2>/dev/null | jq -r '.status')

  if [[ "$status" == "unauthenticated" ]]; then
    echo "Logging in with API key..." >&2
    bw login --apikey 2>/dev/null
  fi

  echo "Unlocking vault..." >&2
  bw unlock --passwordenv BW_PASSWORD --raw
}

# ── commands ─────────────────────────────────────────────────────────────────

cmd_fetch() {
  check_vars
  export BW_SESSION
  BW_SESSION=$(bw_session)

  echo "Fetching '${ITEM_NAME}'..." >&2
  bw sync --quiet
  bw get item "$ITEM_NAME" | jq -r '.notes' > "$ENV_FILE"
  echo "Written to ${ENV_FILE}" >&2
  bw lock --quiet
}

cmd_update() {
  [[ -f "$ENV_FILE" ]] || die ".env not found at ${ENV_FILE}"
  check_vars
  export BW_SESSION
  BW_SESSION=$(bw_session)

  echo "Syncing vault..." >&2
  bw sync --quiet

  local item_id notes_b64 item_json updated_json
  item_id=$(bw get item "$ITEM_NAME" | jq -r '.id')
  [[ -z "$item_id" ]] && die "Item '${ITEM_NAME}' not found in vault"

  # Bitwarden CLI expects notes as a plain string in the JSON body
  item_json=$(bw get item "$item_id")
  updated_json=$(echo "$item_json" | jq --rawfile notes "$ENV_FILE" '.notes = $notes')

  echo "Pushing updated .env to '${ITEM_NAME}'..." >&2
  echo "$updated_json" | bw encode | bw edit item "$item_id" > /dev/null
  echo "Done." >&2
  bw lock --quiet
}

# ── main ─────────────────────────────────────────────────────────────────────

case "${1:-fetch}" in
  fetch)  cmd_fetch  ;;
  update) cmd_update ;;
  *) echo "Usage: $0 [fetch|update]" >&2; exit 1 ;;
esac
