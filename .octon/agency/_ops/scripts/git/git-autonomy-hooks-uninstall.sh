#!/usr/bin/env bash
set -euo pipefail

MARKER="OCTON AUTONOMY CLEANUP HOOK"

usage() {
  cat <<'USAGE'
Usage:
  git-autonomy-hooks-uninstall.sh

Removes managed Octon post-merge/post-checkout cleanup hooks.
If a pre-existing hook backup exists, it is restored.
USAGE
}

error() {
  echo "[ERROR] $1" >&2
  exit 1
}

info() {
  echo "[INFO] $1"
}

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || error "Missing required command: $cmd"
}

uninstall_hook() {
  local hook_name="$1"
  local hooks_dir="$2"
  local hook_path="${hooks_dir}/${hook_name}"
  local backup_path="${hooks_dir}/${hook_name}.octon-local"

  if [[ ! -f "${hook_path}" ]]; then
    info "No ${hook_name} hook found; nothing to uninstall."
    return 0
  fi

  if ! rg -q "${MARKER}" "${hook_path}"; then
    info "${hook_name} hook is not managed by Octon; leaving as-is."
    return 0
  fi

  if [[ -f "${backup_path}" ]]; then
    mv "${backup_path}" "${hook_path}"
    chmod +x "${hook_path}" || true
    info "Restored original ${hook_name} hook from backup."
  else
    rm -f "${hook_path}"
    info "Removed managed ${hook_name} hook."
  fi
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi

  require_cmd git
  require_cmd rg

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || error "Run inside a git repository."

  local hooks_dir
  hooks_dir="$(git rev-parse --git-path hooks)"

  uninstall_hook "post-merge" "${hooks_dir}"
  uninstall_hook "post-checkout" "${hooks_dir}"

  echo "[OK] Uninstall flow completed for Octon autonomy hooks in ${hooks_dir}."
}

main "$@"
