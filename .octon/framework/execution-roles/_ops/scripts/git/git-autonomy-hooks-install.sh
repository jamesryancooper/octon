#!/usr/bin/env bash
set -euo pipefail

MARKER="OCTON AUTONOMY CLEANUP HOOK"

usage() {
  cat <<'USAGE'
Usage:
  git-autonomy-hooks-install.sh

Installs managed post-merge and post-checkout hooks that run non-blocking
local cleanup convergence with lock/throttle safety.
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

write_managed_hook() {
  local hook_name="$1"
  local hook_path="$2"
  local backup_path="$3"

  cat >"${hook_path}" <<EOF_HOOK
#!/usr/bin/env bash
# ${MARKER}
set -euo pipefail

HOOK_NAME="${hook_name}"
LEGACY_HOOK="${backup_path}"

if [[ -x "\${LEGACY_HOOK}" ]]; then
  "\${LEGACY_HOOK}" "\$@" || true
fi

if [[ "\${HOOK_NAME}" == "post-checkout" && "\${3:-0}" != "1" ]]; then
  exit 0
fi

REPO_ROOT="\$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "\${REPO_ROOT}" ]] || exit 0

CLEANUP_SCRIPT="\${REPO_ROOT}/.octon/framework/execution-roles/_ops/scripts/git/git-pr-cleanup.sh"
[[ -x "\${CLEANUP_SCRIPT}" ]] || exit 0

if ! git -C "\${REPO_ROOT}" diff --quiet || ! git -C "\${REPO_ROOT}" diff --cached --quiet; then
  exit 0
fi

STATE_DIR="\${REPO_ROOT}/.git/.octon-autonomy-hooks"
LOCK_DIR="\${STATE_DIR}/cleanup.lock"
STAMP_FILE="\${STATE_DIR}/last-run-epoch"
LOG_FILE="\${STATE_DIR}/cleanup.log"
THROTTLE_SECONDS="\${OCTON_AUTONOMY_HOOK_THROTTLE_SECONDS:-120}"

mkdir -p "\${STATE_DIR}"

if [[ -d "\${LOCK_DIR}" ]]; then
  exit 0
fi

now_epoch="\$(date +%s)"
if [[ -f "\${STAMP_FILE}" ]]; then
  last_epoch="\$(cat "\${STAMP_FILE}" 2>/dev/null || echo 0)"
  if [[ "\${last_epoch}" =~ ^[0-9]+$ ]] && (( now_epoch - last_epoch < THROTTLE_SECONDS )); then
    exit 0
  fi
fi

if ! mkdir "\${LOCK_DIR}" 2>/dev/null; then
  exit 0
fi

(
  set -euo pipefail
  trap 'rmdir "\${LOCK_DIR}" >/dev/null 2>&1 || true' EXIT
  echo "\$(date +%s)" > "\${STAMP_FILE}"
  "\${CLEANUP_SCRIPT}" --no-sync-main >> "\${LOG_FILE}" 2>&1 || true
) >/dev/null 2>&1 &
EOF_HOOK

  chmod +x "${hook_path}"
}

install_hook() {
  local hook_name="$1"
  local hooks_dir="$2"
  local hook_path="${hooks_dir}/${hook_name}"
  local backup_path="${hooks_dir}/${hook_name}.octon-local"

  if [[ -f "${hook_path}" ]] && ! rg -q "${MARKER}" "${hook_path}"; then
    cp "${hook_path}" "${backup_path}"
    chmod +x "${backup_path}" || true
    info "Backed up existing ${hook_name} hook to ${backup_path}."
  fi

  write_managed_hook "${hook_name}" "${hook_path}" "${backup_path}"
  info "Installed managed ${hook_name} hook."
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
  mkdir -p "${hooks_dir}"

  install_hook "post-merge" "${hooks_dir}"
  install_hook "post-checkout" "${hooks_dir}"

  echo "[OK] Installed Octon autonomy cleanup hooks under ${hooks_dir}."
}

main "$@"
