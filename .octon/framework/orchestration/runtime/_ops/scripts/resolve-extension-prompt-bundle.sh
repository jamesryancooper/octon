#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/extensions-common.sh"

extensions_common_init "${BASH_SOURCE[0]}"

PACK_ID=""
SOURCE_ID="bundled-first-party"
PROMPT_SET_ID=""
ALIGNMENT_MODE="auto"
CATALOG_PATH="$CATALOG_FILE"

usage() {
  cat <<'EOF'
usage:
  resolve-extension-prompt-bundle.sh --pack-id <id> --prompt-set-id <id> [--source-id <id>] [--alignment-mode auto|always|skip] [--catalog <path>]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pack-id)
      shift
      PACK_ID="${1:-}"
      ;;
    --source-id)
      shift
      SOURCE_ID="${1:-}"
      ;;
    --prompt-set-id)
      shift
      PROMPT_SET_ID="${1:-}"
      ;;
    --alignment-mode)
      shift
      ALIGNMENT_MODE="${1:-}"
      ;;
    --catalog)
      shift
      CATALOG_PATH="${1:-}"
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

[[ -n "$PACK_ID" && -n "$PROMPT_SET_ID" ]] || {
  usage >&2
  exit 2
}

case "$ALIGNMENT_MODE" in
  auto|always|skip)
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

[[ "$CATALOG_PATH" = /* ]] || CATALOG_PATH="$ROOT_DIR/$CATALOG_PATH"
[[ -f "$CATALOG_PATH" ]] || {
  jq -cn --arg mode "$ALIGNMENT_MODE" --arg pack "$PACK_ID" --arg prompt_set "$PROMPT_SET_ID" '
    {
      status: "blocked",
      safe_to_run: false,
      alignment_mode: $mode,
      pack_id: $pack,
      prompt_set_id: $prompt_set,
      reason_codes: ["missing-catalog"]
    }'
  exit 1
}

mapfile -t bundle_matches < <(yq -o=json ".packs[]? | select(.pack_id == \"$PACK_ID\" and .source_id == \"$SOURCE_ID\") | .prompt_bundles[]? | select(.prompt_set_id == \"$PROMPT_SET_ID\")" "$CATALOG_PATH" 2>/dev/null | jq -c '.' || true)

if [[ "${#bundle_matches[@]}" -gt 1 ]]; then
  jq -cn --arg mode "$ALIGNMENT_MODE" --arg pack "$PACK_ID" --arg prompt_set "$PROMPT_SET_ID" '
    {
      status: "blocked",
      safe_to_run: false,
      alignment_mode: $mode,
      pack_id: $pack,
      prompt_set_id: $prompt_set,
      reason_codes: ["duplicate-prompt-bundle"]
    }'
  exit 1
fi

bundle_json="${bundle_matches[0]:-}"

if [[ -z "$bundle_json" || "$bundle_json" == "null" ]]; then
  jq -cn --arg mode "$ALIGNMENT_MODE" --arg pack "$PACK_ID" --arg prompt_set "$PROMPT_SET_ID" '
    {
      status: "blocked",
      safe_to_run: false,
      alignment_mode: $mode,
      pack_id: $pack,
      prompt_set_id: $prompt_set,
      reason_codes: ["missing-prompt-bundle"]
    }'
  exit 1
fi

manifest_path="$(jq -r '.manifest_path // ""' <<<"$bundle_json")"
manifest_sha="$(jq -r '.manifest_sha256 // ""' <<<"$bundle_json")"
bundle_sha="$(jq -r '.bundle_sha256 // ""' <<<"$bundle_json")"
receipt_path="$(jq -r '.alignment_receipt_path // ""' <<<"$bundle_json")"
publication_status="$(jq -r '.publication_status // ""' <<<"$bundle_json")"
default_mode="$(jq -r '.default_alignment_mode // ""' <<<"$bundle_json")"
skip_policy="$(jq -r '.skip_mode_policy // ""' <<<"$bundle_json")"

declare -a reasons=()
foundational_failure=0

[[ "$publication_status" == "published" || "$publication_status" == "published_with_quarantine" ]] || reasons+=("bundle-not-published")

manifest_abs="$ROOT_DIR/$manifest_path"
if [[ ! -f "$manifest_abs" ]]; then
  reasons+=("manifest-missing")
  foundational_failure=1
fi

receipt_abs="$ROOT_DIR/$receipt_path"
if [[ ! -f "$receipt_abs" ]]; then
  reasons+=("alignment-receipt-missing")
  foundational_failure=1
fi

if [[ -f "$manifest_abs" ]]; then
  current_manifest_sha="$(ext_hash_file "$manifest_abs")"
  [[ "$current_manifest_sha" == "$manifest_sha" ]] || reasons+=("prompt-manifest-sha-changed")
fi

if [[ -f "$receipt_abs" ]]; then
  receipt_schema="$(yq -r '.schema_version // ""' "$receipt_abs" 2>/dev/null || true)"
  receipt_safe="$(yq -r '.safe_to_run // ""' "$receipt_abs" 2>/dev/null || true)"
  receipt_bundle_sha="$(yq -r '.bundle_sha256 // ""' "$receipt_abs" 2>/dev/null || true)"
  [[ "$receipt_schema" == "octon-extension-prompt-alignment-receipt-v1" ]] || reasons+=("alignment-receipt-schema-invalid")
  [[ "$receipt_safe" == "true" ]] || reasons+=("alignment-receipt-unsafe")
  [[ "$receipt_bundle_sha" == "$bundle_sha" ]] || reasons+=("alignment-receipt-bundle-mismatch")
fi

while IFS=$'\t' read -r anchor_path anchor_sha; do
  [[ -n "$anchor_path" ]] || continue
  if [[ ! -e "$ROOT_DIR/$anchor_path" ]]; then
    reasons+=("anchor-missing:$anchor_path")
    continue
  fi
  current_anchor_sha="$(ext_hash_file "$ROOT_DIR/$anchor_path")"
  [[ "$current_anchor_sha" == "$anchor_sha" ]] || reasons+=("required-anchor-sha-changed:$anchor_path")
done < <(jq -r '.required_repo_anchors[]? | [.path, .sha256] | @tsv' <<<"$bundle_json")

bundle_dir_abs="$(dirname "$manifest_abs")"
prompt_root_abs="$(dirname "$bundle_dir_abs")"
while IFS=$'\t' read -r rel_path asset_sha; do
  [[ -n "$rel_path" ]] || continue
  asset_abs="$bundle_dir_abs/$rel_path"
  if [[ ! -f "$asset_abs" ]]; then
    reasons+=("prompt-asset-missing:$rel_path")
    continue
  fi
  current_asset_sha="$(ext_hash_file "$asset_abs")"
  [[ "$current_asset_sha" == "$asset_sha" ]] || reasons+=("prompt-asset-sha-changed:$rel_path")
done < <(jq -r '.prompt_assets[]? | [.path, .sha256] | @tsv' <<<"$bundle_json")

while IFS=$'\t' read -r rel_path asset_sha; do
  [[ -n "$rel_path" ]] || continue
  asset_abs="$bundle_dir_abs/$rel_path"
  if [[ ! -f "$asset_abs" ]]; then
    reasons+=("reference-asset-missing:$rel_path")
    continue
  fi
  current_asset_sha="$(ext_hash_file "$asset_abs")"
  [[ "$current_asset_sha" == "$asset_sha" ]] || reasons+=("reference-asset-sha-changed:$rel_path")
done < <(jq -r '.reference_assets[]? | [.path, .sha256] | @tsv' <<<"$bundle_json")

while IFS=$'\t' read -r rel_path asset_sha; do
  [[ -n "$rel_path" ]] || continue
  asset_abs="$prompt_root_abs/$rel_path"
  if [[ ! -f "$asset_abs" ]]; then
    reasons+=("shared-reference-asset-missing:$rel_path")
    continue
  fi
  current_asset_sha="$(ext_hash_file "$asset_abs")"
  [[ "$current_asset_sha" == "$asset_sha" ]] || reasons+=("shared-reference-asset-sha-changed:$rel_path")
done < <(jq -r '.shared_reference_assets[]? | [.path, .sha256] | @tsv' <<<"$bundle_json")

if [[ "$ALIGNMENT_MODE" == "always" ]]; then
  reasons+=("realignment-required")
fi

status="fresh"
safe_to_run=true

if [[ "${#reasons[@]}" -gt 0 ]]; then
  case "$ALIGNMENT_MODE" in
    skip)
      if [[ "$foundational_failure" -eq 1 ]]; then
        status="blocked"
        safe_to_run=false
      else
        status="degraded_skip"
        safe_to_run=true
      fi
      ;;
    auto|always)
      status="blocked"
      safe_to_run=false
      ;;
  esac
fi

if [[ "${#reasons[@]}" -eq 0 ]]; then
  reasons_json='[]'
else
  reasons_json="$(printf '%s\n' "${reasons[@]}" | jq -R . | jq -s .)"
fi

jq -cn \
  --arg status "$status" \
  --argjson safe "$safe_to_run" \
  --arg mode "$ALIGNMENT_MODE" \
  --arg default_mode "$default_mode" \
  --arg skip_policy "$skip_policy" \
  --arg pack "$PACK_ID" \
  --arg source "$SOURCE_ID" \
  --arg prompt_set "$PROMPT_SET_ID" \
  --arg manifest_path "$manifest_path" \
  --arg receipt_path "$receipt_path" \
  --arg bundle_sha "$bundle_sha" \
  --argjson reasons "$reasons_json" '
  {
    status: $status,
    safe_to_run: $safe,
    alignment_mode: $mode,
    default_alignment_mode: $default_mode,
    skip_mode_policy: $skip_policy,
    pack_id: $pack,
    source_id: $source,
    prompt_set_id: $prompt_set,
    manifest_path: $manifest_path,
    alignment_receipt_path: $receipt_path,
    prompt_bundle_sha256: $bundle_sha,
    reason_codes: $reasons
  }'

if [[ "$safe_to_run" == "true" ]]; then
  exit 0
fi
exit 1
