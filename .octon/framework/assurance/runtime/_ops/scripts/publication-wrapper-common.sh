#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
RUNTIME_CRATES_DIR="$ROOT_DIR/.octon/framework/engine/runtime/crates"
PUBLICATION_KERNEL_TARGET_DIR="${OCTON_PUBLICATION_KERNEL_TARGET_DIR:-$ROOT_DIR/.octon/generated/.tmp/engine/build/runtime-crates-target}"
PUBLICATION_KERNEL_BIN="$PUBLICATION_KERNEL_TARGET_DIR/debug/octon"
PUBLICATION_SCRATCH_ROOT="$ROOT_DIR/.octon/generated/.tmp"
PUBLICATION_SCRATCH_MAX_FILES="${OCTON_PUBLICATION_SCRATCH_MAX_FILES:-50000}"
PUBLICATION_SCRATCH_MAX_BYTES="${OCTON_PUBLICATION_SCRATCH_MAX_BYTES:-2147483648}"
PUBLICATION_SCRATCH_TTL_SECONDS="${OCTON_PUBLICATION_SCRATCH_TTL_SECONDS:-604800}"
PUBLICATION_SCRATCH_CLEANUP_MODE="${OCTON_PUBLICATION_SCRATCH_CLEANUP_MODE:-dry-run}"

publication_abs_path() {
  local path="$1"
  case "$path" in
    /*)
      printf '%s\n' "$path"
      ;;
    *)
      printf '%s/%s\n' "$ROOT_DIR" "${path#./}"
      ;;
  esac
}

publication_require_generated_tmp_path() {
  local path
  path="$(publication_abs_path "$1")"
  case "$path" in
    "$PUBLICATION_SCRATCH_ROOT"|"$PUBLICATION_SCRATCH_ROOT"/*)
      return 0
      ;;
    *)
      echo "publication scratch path must stay under .octon/generated/.tmp: ${path#$ROOT_DIR/}" >&2
      return 1
      ;;
  esac
}

publication_file_count() {
  local root="$1"
  if [[ ! -d "$root" ]]; then
    printf '0\n'
    return
  fi
  find "$root" -type f | wc -l | tr -d '[:space:]'
  printf '\n'
}

publication_byte_count() {
  local root="$1"
  if [[ ! -d "$root" ]]; then
    printf '0\n'
    return
  fi
  du -sk "$root" | awk '{print $1 * 1024}'
}

publication_scratch_budget_status() {
  local root="$1"
  local files bytes
  files="$(publication_file_count "$root")"
  bytes="$(publication_byte_count "$root")"
  if (( files > PUBLICATION_SCRATCH_MAX_FILES || bytes > PUBLICATION_SCRATCH_MAX_BYTES )); then
    printf 'over_budget\n'
  else
    printf 'within_budget\n'
  fi
}

publication_emit_scratch_budget_report() {
  local root="$1"
  local files="$2"
  local bytes="$3"
  local status="$4"
  printf 'tmp_budget_report:\n'
  printf '  root: "%s"\n' "${root#$ROOT_DIR/}"
  printf '  file_count: %s\n' "$files"
  printf '  byte_count: %s\n' "$bytes"
  printf '  max_files: %s\n' "$PUBLICATION_SCRATCH_MAX_FILES"
  printf '  max_bytes: %s\n' "$PUBLICATION_SCRATCH_MAX_BYTES"
  printf '  ttl_seconds: %s\n' "$PUBLICATION_SCRATCH_TTL_SECONDS"
  printf '  status: "%s"\n' "$status"
  printf '  cleanup_default: "dry-run"\n'
  printf '  cleanup_authority: "cleanup-local-run-artifacts.sh authorization receipt or explicit --confirm"\n'
  printf '  rebuildability: "producer-owned scratch/cache; recreate through owning publisher or build route"\n'
}

publication_write_scratch_budget_report() {
  local root="${1:-$PUBLICATION_SCRATCH_ROOT}"
  local output="${2:-}"
  publication_require_generated_tmp_path "$root" || return 1
  local files bytes status
  files="$(publication_file_count "$root")"
  bytes="$(publication_byte_count "$root")"
  status="$(publication_scratch_budget_status "$root")"
  if [[ -n "$output" ]]; then
    publication_emit_scratch_budget_report "$root" "$files" "$bytes" "$status" >"$output"
  else
    publication_emit_scratch_budget_report "$root" "$files" "$bytes" "$status"
  fi
}

publication_prune_stale_dir() {
  local root="$1"
  local ttl_minutes
  ttl_minutes=$(( (PUBLICATION_SCRATCH_TTL_SECONDS + 59) / 60 ))
  [[ "$ttl_minutes" -ge 0 ]] || ttl_minutes=0
  [[ -d "$root" ]] || return 0

  find "$root" -type f -mmin +"$ttl_minutes" -print0 |
    while IFS= read -r -d '' path; do
      rm -f -- "$path"
    done
  find "$root" -depth -type d -empty -print0 |
    while IFS= read -r -d '' path; do
      rmdir -- "$path" 2>/dev/null || true
    done
}

publication_prune_stale_rebuildable_cache() {
  local target_dir="$1"
  publication_require_generated_tmp_path "$target_dir" || return 1
  local safe_dir
  for safe_dir in \
    "$target_dir/debug/incremental" \
    "$target_dir/debug/.fingerprint" \
    "$target_dir/tmp"
  do
    publication_prune_stale_dir "$safe_dir"
  done
}

publication_scratch_preflight() {
  local target_dir="${1:-$PUBLICATION_KERNEL_TARGET_DIR}"
  publication_require_generated_tmp_path "$target_dir" || return 1
  mkdir -p "$target_dir"

  case "$PUBLICATION_SCRATCH_CLEANUP_MODE" in
    off|dry-run)
      ;;
    prune)
      publication_prune_stale_rebuildable_cache "$target_dir"
      ;;
    *)
      echo "unsupported OCTON_PUBLICATION_SCRATCH_CLEANUP_MODE: $PUBLICATION_SCRATCH_CLEANUP_MODE" >&2
      return 1
      ;;
  esac

  if [[ -n "${OCTON_PUBLICATION_SCRATCH_REPORT:-}" ]]; then
    publication_write_scratch_budget_report "$PUBLICATION_SCRATCH_ROOT" "$OCTON_PUBLICATION_SCRATCH_REPORT"
  fi
  if [[ "${OCTON_PUBLICATION_SCRATCH_FAIL_ON_BUDGET:-0}" == "1" ]] &&
    [[ "$(publication_scratch_budget_status "$PUBLICATION_SCRATCH_ROOT")" == "over_budget" ]]; then
    echo "publication scratch budget exceeded under .octon/generated/.tmp" >&2
    return 1
  fi
}

resolve_octon_kernel_bin() {
  if [[ -n "${OCTON_KERNEL_BIN:-}" ]]; then
    printf '%s\n' "$OCTON_KERNEL_BIN"
    return
  fi

  publication_scratch_preflight "$PUBLICATION_KERNEL_TARGET_DIR"
  (
    cd "$RUNTIME_CRATES_DIR"
    export CARGO_TARGET_DIR="$PUBLICATION_KERNEL_TARGET_DIR"
    cargo build -q -p octon_kernel --bin octon
  )

  if [[ -x "$PUBLICATION_KERNEL_BIN" ]]; then
    printf '%s\n' "$PUBLICATION_KERNEL_BIN"
    return
  fi

  echo "unable to resolve octon kernel binary for publication wrapper" >&2
  exit 1
}

run_octon_kernel() {
  local kernel_bin
  kernel_bin="$(resolve_octon_kernel_bin)"
  OCTON_KERNEL_BIN="$kernel_bin" "$kernel_bin" "$@"
}

run_publication_wrapper() {
  local publisher_cmd="$1"
  run_octon_kernel publish "$publisher_cmd"
}

enter_publication_runtime_boundary() {
  local publisher_cmd="$1"
  if [[ "${OCTON_PUBLICATION_ENTRYPOINT:-}" != "runtime" ]]; then
    run_publication_wrapper "$publisher_cmd"
    exit $?
  fi

  if [[ -z "${OCTON_PUBLICATION_TOKEN_MANIFEST:-}" ]]; then
    echo "missing OCTON_PUBLICATION_TOKEN_MANIFEST for runtime publication entrypoint" >&2
    exit 1
  fi
  if [[ -z "${OCTON_PUBLICATION_TOKEN_RESULT_MANIFEST:-}" ]]; then
    echo "missing OCTON_PUBLICATION_TOKEN_RESULT_MANIFEST for runtime publication entrypoint" >&2
    exit 1
  fi

  run_octon_kernel publication-internal verify-manifest \
    --publisher "$publisher_cmd" \
    --manifest "$OCTON_PUBLICATION_TOKEN_MANIFEST" \
    --result-manifest "$OCTON_PUBLICATION_TOKEN_RESULT_MANIFEST"
}
