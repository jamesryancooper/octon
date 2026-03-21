#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/extensions-common.sh"

extensions_common_init "${BASH_SOURCE[0]}"

FRAMEWORK_MANIFEST="$OCTON_DIR/framework/manifest.yml"
INSTANCE_MANIFEST="$OCTON_DIR/instance/manifest.yml"
VALIDATOR_DIR="$OCTON_DIR/framework/assurance/runtime/_ops/scripts"
PUBLISH_EXTENSIONS_SCRIPT="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh"
PUBLISH_CAPABILITIES_SCRIPT="$OCTON_DIR/framework/capabilities/_ops/scripts/publish-capability-routing.sh"

PROFILE=""
OUTPUT_DIR=""
PACK_IDS_CSV=""
VALIDATE_ONLY="${EXPORT_HARNESS_VALIDATE_ONLY:-0}"

usage() {
  cat <<'USAGE'
Usage:
  export-harness.sh --profile repo_snapshot --output-dir <path>
  export-harness.sh --profile pack_bundle --output-dir <path> --pack-ids <csv>

Profiles:
  repo_snapshot  Export octon.yml, framework/**, instance/**, and the published enabled-pack dependency closure.
  pack_bundle    Export only selected packs plus dependency closure.

Notes:
  - full_fidelity is advisory only and must use a normal Git clone.
  - Output is written to <path>/.octon/ with export.receipt.yml at <path>/.
USAGE
}

fail() {
  echo "[ERROR] $1" >&2
  exit 1
}

load_pack_bundle_selected_keys() {
  local item pack_id source_id key
  declare -A seen_pack_ids=()
  IFS=',' read -r -a input_items <<< "$PACK_IDS_CSV"
  EXT_SELECTED_KEYS=()
  for item in "${input_items[@]}"; do
    pack_id="$(ext_trim "$item")"
    [[ -n "$pack_id" ]] || continue
    [[ -z "${seen_pack_ids["$pack_id"]:-}" ]] || fail "duplicate pack id in pack_bundle request: $pack_id"
    seen_pack_ids["$pack_id"]="1"
    source_id="$(ext_detect_pack_source_id "$pack_id" 2>/dev/null || true)"
    [[ -n "$source_id" ]] || fail "missing pack manifest for '$pack_id'"
    key="$(ext_pack_key "$pack_id" "$source_id")"
    EXT_SELECTED_KEYS+=("$key")
  done
  [[ "${#EXT_SELECTED_KEYS[@]}" -gt 0 ]] || fail "pack_bundle requires at least one explicit pack id"
}

run_validators() {
  local validator
  for validator in \
    validate-harness-version-contract.sh \
    validate-root-manifest-profiles.sh \
    validate-companion-manifests.sh \
    validate-extension-pack-contract.sh
  do
    OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" \
      bash "$VALIDATOR_DIR/$validator"
  done
}

ensure_output_dir() {
  if [[ -e "$OUTPUT_DIR" ]]; then
    [[ -d "$OUTPUT_DIR" ]] || fail "output path exists and is not a directory: $OUTPUT_DIR"
    if find "$OUTPUT_DIR" -mindepth 1 -print -quit | grep -q .; then
      fail "output directory must be empty: $OUTPUT_DIR"
    fi
  else
    mkdir -p "$OUTPUT_DIR"
  fi
}

copy_file() {
  local rel_path="$1"
  local source="$OCTON_DIR/$rel_path"
  local target_root="$OUTPUT_DIR/.octon"
  mkdir -p "$target_root/$(dirname "$rel_path")"
  cp "$source" "$target_root/$rel_path"
}

copy_dir() {
  local rel_path="$1"
  local source="$OCTON_DIR/$rel_path"
  local target_root="$OUTPUT_DIR/.octon"
  mkdir -p "$target_root/$(dirname "$rel_path")"
  cp -R "$source" "$target_root/$rel_path"
}

emit_receipt() {
  local receipt="$OUTPUT_DIR/export.receipt.yml"
  local key

  {
    printf 'schema_version: "octon-export-receipt-v1"\n'
    printf 'profile: "%s"\n' "$PROFILE"
    printf 'generated_at: "%s"\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    printf 'export_root: "%s"\n' "$OUTPUT_DIR/.octon"
    printf 'manifest_schema_versions:\n'
    printf '  root: "%s"\n' "$(yq -r '.schema_version // ""' "$ROOT_MANIFEST")"
    printf '  framework: "%s"\n' "$(yq -r '.schema_version // ""' "$FRAMEWORK_MANIFEST")"
    printf '  instance: "%s"\n' "$(yq -r '.schema_version // ""' "$INSTANCE_MANIFEST")"
    printf '  extensions: "%s"\n' "$(yq -r '.schema_version // ""' "$EXTENSIONS_MANIFEST")"
    ext_emit_pack_ref_list "selected_packs" "${EXT_SELECTED_KEYS[@]}"
    ext_emit_dependency_closure_list "resolved_dependency_closure" "${EXT_PUBLISHED_KEYS[@]}"
    printf 'exported_paths:\n'
    if [[ "$PROFILE" == "repo_snapshot" ]]; then
      printf '  - ".octon/octon.yml"\n'
      printf '  - ".octon/framework/"\n'
      printf '  - ".octon/instance/"\n'
    fi
    for key in "${EXT_PUBLISHED_KEYS[@]}"; do
      printf '  - ".octon/inputs/additive/extensions/%s/"\n' "$(ext_key_pack_id "$key")"
    done
  } >"$receipt"
}

materialize_export() {
  local key
  mkdir -p "$OUTPUT_DIR/.octon"

  if [[ "$PROFILE" == "repo_snapshot" ]]; then
    copy_file "octon.yml"
    copy_dir "framework"
    copy_dir "instance"
  fi

  for key in "${EXT_PUBLISHED_KEYS[@]}"; do
    copy_dir "inputs/additive/extensions/$(ext_key_pack_id "$key")"
  done
}

check_declared_conflicts_in_published_set() {
  local key manifest conflict_pack_id conflict_range existing_key existing_version
  for key in "${EXT_PUBLISHED_KEYS[@]}"; do
    manifest="$ROOT_DIR/${EXT_PUBLISHED_MANIFEST_REL["$key"]}"
    while IFS=$'\t' read -r conflict_pack_id conflict_range; do
      [[ -n "$conflict_pack_id" ]] || continue
      existing_key="$(ext_find_published_key_by_pack_id "$conflict_pack_id" || true)"
      [[ -n "$existing_key" ]] || continue
      [[ "$existing_key" != "$key" ]] || continue
      existing_version="${EXT_PUBLISHED_VERSION["$existing_key"]}"
      ext_version_satisfies "$existing_version" "$conflict_range" && fail "pack_bundle published set contains declared conflict: $(ext_key_pack_id "$key") -> $conflict_pack_id"
    done < <(yq -r '.dependencies.conflicts[]? | [.pack_id, .version_range] | @tsv' "$manifest" 2>/dev/null || true)
  done
}

load_current_repo_snapshot_state() {
  OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" \
    bash "$PUBLISH_EXTENSIONS_SCRIPT" >/dev/null

  OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" \
    bash "$VALIDATOR_DIR/validate-extension-publication-state.sh" >/dev/null

  OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" \
    bash "$PUBLISH_CAPABILITIES_SCRIPT" >/dev/null

  OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" \
    bash "$VALIDATOR_DIR/validate-capability-publication-state.sh" >/dev/null

  [[ "$(yq -r '.status // ""' "$ACTIVE_STATE")" == "published" ]] || fail "repo_snapshot requires clean published extension state"
  yq -e '.records | length == 0' "$QUARANTINE_STATE" >/dev/null 2>&1 || fail "repo_snapshot fails closed when extension quarantine is non-empty"

  ext_load_published_keys_from_active_state
  mapfile -t EXT_SELECTED_KEYS < <(ext_pack_key_sort "${EXT_SELECTED_KEYS[@]}")
  mapfile -t EXT_PUBLISHED_KEYS < <(ext_pack_key_sort "${EXT_PUBLISHED_KEYS[@]}")
}

resolve_pack_bundle_selection() {
  local selected_key pack_id source_id
  ext_reset_resolution_state
  load_pack_bundle_selected_keys
  for selected_key in "${EXT_SELECTED_KEYS[@]}"; do
    pack_id="$(ext_key_pack_id "$selected_key")"
    source_id="$(ext_key_source_id "$selected_key")"
    ext_clear_candidate_state
    ext_resolve_candidate_pack "$pack_id" "$source_id" 0 || fail "pack_bundle resolution failed for '$pack_id': $EXT_LAST_ERROR_REASON"
    ext_merge_candidate_into_published
  done
  mapfile -t EXT_SELECTED_KEYS < <(ext_pack_key_sort "${EXT_SELECTED_KEYS[@]}")
  mapfile -t EXT_PUBLISHED_KEYS < <(ext_pack_key_sort "${EXT_PUBLISHED_KEYS[@]}")
  check_declared_conflicts_in_published_set
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --profile)
        shift
        [[ $# -gt 0 ]] || fail "--profile requires a value"
        PROFILE="$1"
        ;;
      --output-dir)
        shift
        [[ $# -gt 0 ]] || fail "--output-dir requires a value"
        OUTPUT_DIR="$1"
        ;;
      --pack-ids)
        shift
        [[ $# -gt 0 ]] || fail "--pack-ids requires a value"
        PACK_IDS_CSV="$1"
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        usage >&2
        fail "unknown argument: $1"
        ;;
    esac
    shift
  done

  [[ -n "$PROFILE" ]] || fail "--profile is required"
  [[ -n "$OUTPUT_DIR" ]] || fail "--output-dir is required"

  if [[ "$PROFILE" == "full_fidelity" ]]; then
    fail "full_fidelity is advisory only; use a normal Git clone for exact repository reproduction"
  fi
  [[ "$PROFILE" == "repo_snapshot" || "$PROFILE" == "pack_bundle" ]] || fail "profile must be repo_snapshot or pack_bundle"

  run_validators

  if [[ "$PROFILE" == "repo_snapshot" ]]; then
    [[ "$VALIDATE_ONLY" == "1" ]] || load_current_repo_snapshot_state
    if [[ "$VALIDATE_ONLY" == "1" ]]; then
      load_current_repo_snapshot_state
      echo "[OK] export request validated for profile '$PROFILE'"
      exit 0
    fi
  fi

  if [[ "$PROFILE" == "pack_bundle" ]]; then
    resolve_pack_bundle_selection
    if [[ "$VALIDATE_ONLY" == "1" ]]; then
      echo "[OK] export request validated for profile '$PROFILE'"
      exit 0
    fi
  fi

  ensure_output_dir
  materialize_export
  emit_receipt
  echo "[OK] export created at $OUTPUT_DIR"
}

main "$@"
