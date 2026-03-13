#!/usr/bin/env bash
# policy-reversible-primitives.sh - Execute reversible primitives for destructive-adjacent ACP classes.

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  policy-reversible-primitives.sh apply \
    --run-id <id> \
    --operation-class <class> \
    [--target-json <json-object>] \
    [--workspace <path>] \
    [--recovery-window <iso8601>] \
    [--rollback-handle <handle>] \
    [--primitive <name>]
USAGE
}

require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required for policy-reversible-primitives.sh" >&2
    exit 1
  fi
}

normalize_workspace() {
  local workspace="$1"
  if [[ -z "$workspace" ]]; then
    pwd
  else
    printf '%s\n' "$workspace"
  fi
}

apply_fs_soft_delete() {
  local run_id="$1"
  local workspace="$2"
  local target_json="$3"
  local recovery_window="$4"
  local rollback_handle="$5"
  local primitive="$6"

  local trash_root manifest_file
  trash_root="$workspace/.octon/.trash/$run_id"
  manifest_file="$trash_root/manifest.json"
  mkdir -p "$trash_root"

  local moved_json
  moved_json='[]'
  while IFS= read -r rel_path; do
    [[ -n "$rel_path" ]] || continue
    local src="$workspace/$rel_path"
    if [[ -e "$src" ]]; then
      local dst="$trash_root/$rel_path"
      mkdir -p "$(dirname "$dst")"
      mv "$src" "$dst"
      moved_json="$(jq -cn --argjson base "$moved_json" --arg rel "$rel_path" '$base + [$rel]')"
    fi
  done < <(jq -r '.paths[]? // empty' <<<"$target_json")

  jq -n \
    --arg run_id "$run_id" \
    --arg primitive "${primitive:-fs.move_to_trash}" \
    --arg rollback_handle "${rollback_handle:-fs:trash:$manifest_file}" \
    --arg recovery_window "${recovery_window:-P30D}" \
    --arg manifest "$manifest_file" \
    --argjson moved "$moved_json" \
    '{
      applied: true,
      primitive: $primitive,
      rollback_handle: $rollback_handle,
      recovery_window: $recovery_window,
      artifacts: [{type:"trash_manifest",ref:$manifest}],
      moved_paths: $moved
    }' | tee "$manifest_file"
}

apply_db_tombstone() {
  local run_id="$1"
  local workspace="$2"
  local target_json="$3"
  local recovery_window="$4"
  local rollback_handle="$5"
  local primitive="$6"

  local out_dir manifest_file
  out_dir="$workspace/.octon/continuity/runs/$run_id/rollback"
  manifest_file="$out_dir/db-tombstone.json"
  mkdir -p "$out_dir"

  jq -n \
    --arg run_id "$run_id" \
    --arg primitive "${primitive:-db.tombstone}" \
    --arg rollback_handle "${rollback_handle:-db:tombstone:$manifest_file}" \
    --arg recovery_window "${recovery_window:-P90D}" \
    --argjson target "$target_json" \
    '{
      applied: true,
      primitive: $primitive,
      rollback_handle: $rollback_handle,
      recovery_window: $recovery_window,
      artifacts: [{type:"db_tombstone_manifest",ref:$rollback_handle}],
      target: $target
    }' | tee "$manifest_file"
}

apply_resource_detach() {
  local run_id="$1"
  local workspace="$2"
  local target_json="$3"
  local recovery_window="$4"
  local rollback_handle="$5"
  local primitive="$6"

  local out_dir manifest_file
  out_dir="$workspace/.octon/continuity/runs/$run_id/rollback"
  manifest_file="$out_dir/resource-detach.json"
  mkdir -p "$out_dir"

  jq -n \
    --arg run_id "$run_id" \
    --arg primitive "${primitive:-infra.detach_archive}" \
    --arg rollback_handle "${rollback_handle:-infra:detach:$manifest_file}" \
    --arg recovery_window "${recovery_window:-P30D}" \
    --argjson target "$target_json" \
    '{
      applied: true,
      primitive: $primitive,
      rollback_handle: $rollback_handle,
      recovery_window: $recovery_window,
      artifacts: [{type:"resource_detach_manifest",ref:$rollback_handle}],
      target: $target
    }' | tee "$manifest_file"
}

main() {
  require_jq

  local cmd="${1:-}"
  shift || true

  local run_id="" operation_class="" target_json='{}' workspace="" recovery_window="" rollback_handle="" primitive=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --run-id) run_id="$2"; shift 2 ;;
      --operation-class) operation_class="$2"; shift 2 ;;
      --target-json) target_json="$2"; shift 2 ;;
      --workspace) workspace="$2"; shift 2 ;;
      --recovery-window) recovery_window="$2"; shift 2 ;;
      --rollback-handle) rollback_handle="$2"; shift 2 ;;
      --primitive) primitive="$2"; shift 2 ;;
      -h|--help|help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ "$cmd" == "apply" ]] || { usage >&2; exit 1; }
  [[ -n "$run_id" ]] || { echo "--run-id is required" >&2; exit 1; }
  [[ -n "$operation_class" ]] || { echo "--operation-class is required" >&2; exit 1; }
  jq -e 'type == "object"' <<<"$target_json" >/dev/null 2>&1 || {
    echo "--target-json must be a JSON object" >&2
    exit 1
  }

  workspace="$(normalize_workspace "$workspace")"

  case "$operation_class" in
    fs.soft_delete)
      apply_fs_soft_delete "$run_id" "$workspace" "$target_json" "$recovery_window" "$rollback_handle" "$primitive"
      ;;
    db.tombstone)
      apply_db_tombstone "$run_id" "$workspace" "$target_json" "$recovery_window" "$rollback_handle" "$primitive"
      ;;
    resource.detach)
      apply_resource_detach "$run_id" "$workspace" "$target_json" "$recovery_window" "$rollback_handle" "$primitive"
      ;;
    *)
      jq -n \
        --arg primitive "$primitive" \
        --arg rollback_handle "$rollback_handle" \
        --arg recovery_window "$recovery_window" \
        '{applied:false,primitive:(if $primitive=="" then null else $primitive end),rollback_handle:(if $rollback_handle=="" then null else $rollback_handle end),recovery_window:(if $recovery_window=="" then null else $recovery_window end),artifacts:[]}'
      ;;
  esac
}

main "$@"
