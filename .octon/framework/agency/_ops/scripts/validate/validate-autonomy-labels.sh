#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/../../../../.." && pwd)"
SYNC_SCRIPT="${SCRIPT_DIR}/../github/sync-github-labels.sh"

CHECK_REMOTE=0
REPO=""

usage() {
  cat <<'USAGE'
Usage:
  validate-autonomy-labels.sh [--check-remote] [--repo <owner/repo>]

Validates that workflow-referenced labels are present in the canonical label
catalog defined by sync-github-labels.sh.

Optional:
  --check-remote    Also verify all canonical labels exist in the GitHub repo.
  --repo            Override owner/repo (default: infer from git origin).
USAGE
}

error() {
  echo "[ERROR] $1" >&2
  exit 1
}

pass() {
  echo "[OK] $1"
}

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || error "Missing required command: $cmd"
}

repo_from_origin() {
  local remote
  remote="$(git config --get remote.origin.url 2>/dev/null || true)"
  if [[ -z "$remote" ]]; then
    return 1
  fi

  if [[ "$remote" =~ ^https?://github\.com/([^/]+)/([^/]+)\.git$ ]]; then
    echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
    return 0
  fi

  if [[ "$remote" =~ ^https?://github\.com/([^/]+)/([^/]+)$ ]]; then
    echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
    return 0
  fi

  if [[ "$remote" =~ ^git@github\.com:([^/]+)/([^/]+)\.git$ ]]; then
    echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
    return 0
  fi

  if [[ "$remote" =~ ^git@github\.com:([^/]+)/([^/]+)$ ]]; then
    echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
    return 0
  fi

  return 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check-remote)
      CHECK_REMOTE=1
      ;;
    --repo)
      shift
      [[ $# -gt 0 ]] || error "--repo requires a value"
      REPO="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      error "Unknown argument: $1"
      ;;
  esac
  shift
done

require_cmd awk
require_cmd sort
require_cmd uniq
require_cmd grep

[[ -f "${SYNC_SCRIPT}" ]] || error "Missing catalog source script: ${SYNC_SCRIPT}"

catalog_labels="$({
  awk -F'|' '/^(type|area|risk|autonomy|bot|ops):[a-z0-9-]+\|/ { print $1 }' "${SYNC_SCRIPT}" | sort -u
} || true)"

[[ -n "${catalog_labels}" ]] || error "No labels could be read from ${SYNC_SCRIPT}"

if command -v rg >/dev/null 2>&1; then
  workflow_labels="$({
    rg -o --no-filename '(type|area|risk|autonomy|bot|ops):[a-z0-9-]+' \
      "${ROOT_DIR}/.github/workflows" \
      -g '*.yml' \
      -g '*.yaml' \
      2>/dev/null | sort -u
  } || true)"
else
  workflow_labels="$({
    grep -RhoE '(type|area|risk|autonomy|bot|ops):[a-z0-9-]+' \
      "${ROOT_DIR}/.github/workflows" \
      --include='*.yml' \
      --include='*.yaml' \
      2>/dev/null | sort -u
  } || true)"
fi

if [[ -z "${workflow_labels}" ]]; then
  pass "No workflow labels detected under .github/workflows."
  workflow_labels=""
fi

required_labels=(
  "autonomy:attention-required"
  "ops:autonomy-health"
)

missing=0

for label in "${required_labels[@]}"; do
  if ! grep -qx "${label}" <<<"${catalog_labels}"; then
    echo "[ERROR] Missing required catalog label: ${label}"
    missing=$((missing + 1))
  fi
done

if [[ -n "${workflow_labels}" ]]; then
  while IFS= read -r label; do
    [[ -n "${label}" ]] || continue
    if ! grep -qx "${label}" <<<"${catalog_labels}"; then
      echo "[ERROR] Workflow label missing from catalog: ${label}"
      missing=$((missing + 1))
    fi
  done <<<"${workflow_labels}"
fi

if [[ "${CHECK_REMOTE}" -eq 1 ]]; then
  require_cmd gh
  require_cmd jq
  require_cmd git

  if [[ -z "${REPO}" ]]; then
    REPO="$(repo_from_origin || true)"
  fi
  [[ -n "${REPO}" ]] || error "Unable to infer repository for --check-remote mode."

  remote_labels="$({
    gh api "repos/${REPO}/labels?per_page=100" --paginate | jq -r '.[].name' | sort -u
  } || true)"

  if [[ -z "${remote_labels}" ]]; then
    echo "[ERROR] Unable to fetch labels from ${REPO} (check gh auth/network)."
    missing=$((missing + 1))
  else
    while IFS= read -r label; do
      [[ -n "${label}" ]] || continue
      if ! grep -qx "${label}" <<<"${remote_labels}"; then
        echo "[ERROR] Missing remote label: ${label}"
        missing=$((missing + 1))
      fi
    done <<<"${catalog_labels}"
  fi
fi

if [[ "${missing}" -gt 0 ]]; then
  echo "[ERROR] Autonomy label validation failed with ${missing} issue(s)."
  exit 1
fi

catalog_count="$(printf '%s\n' "${catalog_labels}" | sed '/^$/d' | wc -l | tr -d ' ')"
workflow_count="$(printf '%s\n' "${workflow_labels}" | sed '/^$/d' | wc -l | tr -d ' ')"

pass "Agency label catalog validated (${catalog_count} catalog labels, ${workflow_count} workflow labels)."
