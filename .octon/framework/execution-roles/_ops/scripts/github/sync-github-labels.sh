#!/usr/bin/env bash
set -euo pipefail

REPO=""
DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage:
  sync-github-labels.sh [--repo <owner/repo>] [--dry-run]

Synchronizes the autonomy label catalog used by PR triage/policy workflows.
Creates missing labels and updates existing label color/description idempotently.
USAGE
}

error() {
  echo "[ERROR] $1" >&2
  exit 1
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

sync_label() {
  local repo="$1"
  local name="$2"
  local color="$3"
  local description="$4"
  local encoded

  encoded="$(jq -rn --arg name "$name" '$name | @uri')"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY] sync label '$name' (color=$color)"
    return 0
  fi

  if gh api "repos/${repo}/labels/${encoded}" >/dev/null 2>&1; then
    gh api \
      --method PATCH \
      "repos/${repo}/labels/${encoded}" \
      -f new_name="$name" \
      -f color="$color" \
      -f description="$description" >/dev/null
    echo "[OK] updated label: $name"
  else
    gh api \
      --method POST \
      "repos/${repo}/labels" \
      -f name="$name" \
      -f color="$color" \
      -f description="$description" >/dev/null
    echo "[OK] created label: $name"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      shift
      [[ $# -gt 0 ]] || error "--repo requires a value"
      REPO="$1"
      ;;
    --dry-run)
      DRY_RUN=1
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

require_cmd gh
require_cmd jq
require_cmd git

if [[ -z "$REPO" ]]; then
  REPO="$(repo_from_origin || true)"
fi
[[ -n "$REPO" ]] || error "Unable to infer repository. Pass --repo <owner/repo>."

while IFS='|' read -r name color description; do
  [[ -n "$name" ]] || continue
  sync_label "$REPO" "$name" "$color" "$description"
done <<'EOF'
type:feat|1D76DB|New feature
type:fix|D73A4A|Bug fix
type:refactor|A2EEEF|Refactor
type:perf|C2E0C6|Performance improvement
type:test|FBCA04|Tests
type:docs|0075CA|Documentation
type:chore|C5DEF5|Maintenance and chores
type:ci|5319E7|CI or automation
type:revert|BFD4F2|Revert change
type:unknown|D4C5F9|Unclassified branch type
area:execution-roles|0E8A16|Octon execution-role domain
area:capabilities|0E8A16|Octon capabilities domain
area:cognition|0E8A16|Octon cognition domain
area:orchestration|0E8A16|Octon orchestration domain
area:scaffolding|0E8A16|Octon scaffolding domain
area:assurance|0E8A16|Octon assurance domain
area:engine|0E8A16|Octon engine domain
area:continuity|0E8A16|Octon continuity domain
area:ideation|0E8A16|Octon ideation domain
area:output|0E8A16|Octon output domain
area:github|0052CC|GitHub workflow or settings surface
area:root|0052CC|Root contract or repository surface
area:uncategorized|BFDADC|No known area match
risk:low|D4C5F9|Low risk routine change
risk:med|FBCA04|Medium risk change
risk:high|B60205|High impact governance/control-plane change
autonomy:attention-required|D93F0B|PR requires prompt human action to maintain clean-state flow
ops:autonomy-health|B60205|Automation and autonomy health signal
bot:dependabot|0366D6|Dependabot pull request
autonomy:stale-draft|C5DEF5|Draft PR marked stale by automation
EOF

echo "[OK] Label sync complete for ${REPO}"
