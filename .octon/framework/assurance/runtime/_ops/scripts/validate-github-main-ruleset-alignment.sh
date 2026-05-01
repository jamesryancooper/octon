#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

POLICY="$OCTON_DIR/framework/product/contracts/default-work-unit.yml"
CLOSEOUT_CHANGE="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md"
HOSTED_PREFLIGHT_SCRIPT="$OCTON_DIR/framework/execution-roles/_ops/scripts/git/git-branch-hosted-preflight.sh"

EXPECTATION="current-pr-required"
RULESET_JSON=""
STRICT_LIVE=0
REMOTE="origin"
TARGET_BRANCH="main"
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-github-main-ruleset-alignment.sh [--expect current-pr-required|target-route-neutral] [--ruleset-json <path>] [--strict-live]

Validates GitHub main ruleset posture against Octon's hybrid landing model.
The default expectation documents the current repository state: a PR-required
ruleset blocks hosted branch-no-pr landing. Use --expect target-route-neutral
after the live ruleset is migrated.
USAGE
}

pass() { echo "[OK] $1"; }
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }

require_file() {
  local file="$1"
  [[ -f "$file" ]] && pass "found ${file#$ROOT_DIR/}" || fail "missing ${file#$ROOT_DIR/}"
}

require_literal() {
  local file="$1"
  local needle="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  grep -Fq -- "$needle" "$file" && pass "$ok_msg" || fail "$fail_msg"
}

require_yq() {
  local file="$1"
  local expr="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  yq -e "$expr" "$file" >/dev/null 2>&1 && pass "$ok_msg" || fail "$fail_msg"
}

repo_from_remote() {
  local url path
  url="$(git -C "$ROOT_DIR" remote get-url "$REMOTE" 2>/dev/null || true)"
  case "$url" in
    git@github.com:*)
      path="${url#git@github.com:}"
      ;;
    https://github.com/*)
      path="${url#https://github.com/}"
      ;;
    http://github.com/*)
      path="${url#http://github.com/}"
      ;;
    *)
      return 1
      ;;
  esac
  path="${path%.git}"
  [[ "$path" == */* ]] || return 1
  printf '%s\n' "$path"
}

rules_require_pr() {
  local file="$1"
  jq -e '.. | objects | select(.type? == "pull_request")' "$file" >/dev/null 2>&1
}

rules_require_checks() {
  local file="$1"
  jq -e '.. | objects | select(.type? == "required_status_checks")' "$file" >/dev/null 2>&1
}

validate_static_policy() {
  require_file "$POLICY"
  require_file "$CLOSEOUT_CHANGE"
  require_file "$HOSTED_PREFLIGHT_SCRIPT"
  require_yq "$POLICY" '.fail_closed_conditions[]? | select(. == "provider_ruleset_blocks_requested_hosted_no_pr_landing")' "policy fails closed when provider blocks hosted no-PR landing" "policy must fail closed when provider blocks hosted no-PR landing"
  require_yq "$POLICY" '.pr_required_predicates[]? | select(. == "provider_ruleset_requires_pr")' "policy treats provider PR rule as PR-required predicate" "policy must treat provider PR rule as PR-required predicate"
  require_literal "$CLOSEOUT_CHANGE" 'If the provider ruleset requires PR for `main`, report a blocker' "closeout-change reports PR-required no-PR blocker" "closeout-change must report PR-required no-PR blocker"
  require_literal "$HOSTED_PREFLIGHT_SCRIPT" "Provider ruleset requires PR; hosted branch-no-pr landing unavailable." "preflight produces clear PR-required blocker" "preflight must produce clear PR-required blocker"
}

validate_rules_file() {
  local file="$1"
  [[ -f "$file" ]] || { fail "ruleset JSON exists: $file"; return; }
  jq -e '.' "$file" >/dev/null 2>&1 || { fail "ruleset JSON parses"; return; }

  case "$EXPECTATION" in
    current-pr-required)
      if rules_require_pr "$file"; then
        pass "PR-required ruleset blocks hosted branch-no-pr landing"
      else
        fail "current expectation requires a pull_request rule"
      fi
      ;;
    target-route-neutral)
      if rules_require_pr "$file"; then
        fail "target route-neutral ruleset must not require PR for main"
      else
        pass "target route-neutral ruleset does not require PR"
      fi
      if rules_require_checks "$file"; then
        pass "target route-neutral ruleset retains required checks"
      else
        fail "target route-neutral ruleset must retain required checks"
      fi
      ;;
    *)
      fail "unknown expectation: $EXPECTATION"
      ;;
  esac
}

validate_live_rules() {
  if ! command -v gh >/dev/null 2>&1; then
    [[ "$STRICT_LIVE" -eq 1 ]] && fail "gh is required for strict live ruleset validation" || pass "live ruleset validation skipped; gh unavailable"
    return
  fi

  local repo tmp
  repo="$(repo_from_remote)" || {
    [[ "$STRICT_LIVE" -eq 1 ]] && fail "unable to resolve GitHub repo from remote" || pass "live ruleset validation skipped; GitHub remote unavailable"
    return
  }
  tmp="$(mktemp)"
  if gh api "repos/${repo}/rules/branches/${TARGET_BRANCH}" >"$tmp" 2>/dev/null; then
    validate_rules_file "$tmp"
  elif [[ "$STRICT_LIVE" -eq 1 ]]; then
    fail "unable to query live GitHub branch rules"
  else
    pass "live ruleset validation skipped; GitHub API unavailable"
  fi
  rm -f -- "$tmp"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --expect)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      EXPECTATION="$1"
      ;;
    --ruleset-json)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      RULESET_JSON="$1"
      ;;
    --strict-live)
      STRICT_LIVE=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [[ -n "$RULESET_JSON" && "$RULESET_JSON" != /* ]]; then
  RULESET_JSON="$ROOT_DIR/$RULESET_JSON"
fi

command -v jq >/dev/null 2>&1 || { echo "[ERROR] jq is required" >&2; exit 1; }
command -v yq >/dev/null 2>&1 || { echo "[ERROR] yq is required" >&2; exit 1; }

echo "== GitHub Main Ruleset Alignment Validation =="
validate_static_policy
if [[ -n "$RULESET_JSON" ]]; then
  validate_rules_file "$RULESET_JSON"
else
  validate_live_rules
fi

echo
echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
