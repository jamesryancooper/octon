#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
QUALITY_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
HARMONY_DIR="$(cd -- "$QUALITY_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$HARMONY_DIR/.." && pwd)"

COMMITS_DOC="$HARMONY_DIR/agency/practices/commits.md"
PR_DOC="$HARMONY_DIR/agency/practices/pull-request-standards.md"
STANDARDS_JSON="$HARMONY_DIR/agency/practices/standards/commit-pr-standards.json"
PR_TEMPLATE="$ROOT_DIR/.github/PULL_REQUEST_TEMPLATE.md"
COMMIT_WORKFLOW="$ROOT_DIR/.github/workflows/commit-and-branch-standards.yml"
PR_WORKFLOW="$ROOT_DIR/.github/workflows/pr-quality.yml"

errors=0
warnings=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

warn() {
  echo "[WARN] $1"
  warnings=$((warnings + 1))
}

pass() {
  echo "[OK] $1"
}

require_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    fail "missing file: ${file#$ROOT_DIR/}"
  else
    pass "found file: ${file#$ROOT_DIR/}"
  fi
}

check_contains_literal() {
  local file="$1"
  local needle="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  if grep -Fq "$needle" "$file"; then
    pass "$ok_msg"
  else
    fail "$fail_msg"
  fi
}

check_contains_regex() {
  local file="$1"
  local regex="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  if grep -Eq "$regex" "$file"; then
    pass "$ok_msg"
  else
    fail "$fail_msg"
  fi
}

extract_allowed_types() {
  local section="$1"

  awk -v section="\"$section\"" '
    BEGIN {
      in_section = 0
      in_allowed = 0
    }
    $0 ~ section"[[:space:]]*:[[:space:]]*\\{" {
      in_section = 1
      next
    }
    in_section && $0 ~ /^[[:space:]]*}[[:space:]]*,?[[:space:]]*$/ {
      in_section = 0
      in_allowed = 0
      next
    }
    in_section && $0 ~ /"allowed_types"[[:space:]]*:[[:space:]]*\[/ {
      in_allowed = 1
    }
    in_allowed {
      line = $0
      while (match(line, /"[^"]+"/)) {
        token = substr(line, RSTART + 1, RLENGTH - 2)
        if (token != "allowed_types") {
          print token
        }
        line = substr(line, RSTART + RLENGTH)
      }
      if ($0 ~ /\]/) {
        in_allowed = 0
      }
    }
  ' "$STANDARDS_JSON"
}

check_type_alignment() {
  local commit_csv branch_csv
  local -a commit_types branch_types

  mapfile -t commit_types < <(extract_allowed_types "commit")
  mapfile -t branch_types < <(extract_allowed_types "branch")

  if [[ ${#commit_types[@]} -eq 0 ]]; then
    fail "could not parse commit.allowed_types from standards json"
    return
  fi

  if [[ ${#branch_types[@]} -eq 0 ]]; then
    fail "could not parse branch.allowed_types from standards json"
    return
  fi

  commit_csv="$(printf '%s\n' "${commit_types[@]}" | sort -u | paste -sd, -)"
  branch_csv="$(printf '%s\n' "${branch_types[@]}" | sort -u | paste -sd, -)"

  if [[ "$commit_csv" == "$branch_csv" ]]; then
    pass "commit and branch allowed_types are aligned (${commit_csv})"
  else
    fail "commit and branch allowed_types differ (commit=${commit_csv}; branch=${branch_csv})"
  fi

  local type
  for type in "${commit_types[@]}"; do
    check_contains_literal \
      "$COMMITS_DOC" \
      "\`$type\`" \
      "commits.md documents allowed type '$type'" \
      "commits.md does not document allowed type '$type'"
  done
}

check_standards_contract() {
  check_contains_literal \
    "$STANDARDS_JSON" \
    "\"commit_policy_doc\": \".harmony/agency/practices/commits.md\"" \
    "standards json points commit policy to commits.md" \
    "standards json missing canonical commit policy path"

  check_contains_literal \
    "$STANDARDS_JSON" \
    "\"pr_policy_doc\": \".harmony/agency/practices/pull-request-standards.md\"" \
    "standards json points pr policy to pull-request-standards.md" \
    "standards json missing canonical pr policy path"

  check_contains_literal \
    "$STANDARDS_JSON" \
    "\"pr_template_path\": \".github/PULL_REQUEST_TEMPLATE.md\"" \
    "standards json points to canonical pr template" \
    "standards json missing canonical pr template path"
}

check_commit_policy_alignment() {
  check_contains_literal \
    "$COMMITS_DOC" \
    "standards/commit-pr-standards.json" \
    "commits.md references machine standards contract" \
    "commits.md missing standards/commit-pr-standards.json reference"

  check_contains_literal \
    "$COMMITS_DOC" \
    ".github/workflows/commit-and-branch-standards.yml" \
    "commits.md references commit/branch workflow" \
    "commits.md missing commit/branch workflow reference"

  check_contains_literal \
    "$COMMITS_DOC" \
    "<type>(<scope>): <summary>" \
    "commits.md documents canonical header format" \
    "commits.md missing canonical header format"
}

check_pr_policy_alignment() {
  check_contains_literal \
    "$PR_DOC" \
    ".github/PULL_REQUEST_TEMPLATE.md" \
    "pull-request-standards.md references canonical template" \
    "pull-request-standards.md missing canonical template reference"

  check_contains_literal \
    "$PR_DOC" \
    ".github/workflows/pr-quality.yml" \
    "pull-request-standards.md references pr quality workflow" \
    "pull-request-standards.md missing pr-quality workflow reference"
}

check_workflow_alignment() {
  check_contains_literal \
    "$COMMIT_WORKFLOW" \
    ".harmony/agency/practices/standards/commit-pr-standards.json" \
    "commit-and-branch workflow reads standards json" \
    "commit-and-branch workflow not reading standards json"

  check_contains_literal \
    "$COMMIT_WORKFLOW" \
    "commitRules.allowed_types.map" \
    "commit workflow builds commit pattern from standards contract" \
    "commit workflow appears to hardcode commit types (missing allowed_types.map)"

  check_contains_literal \
    "$COMMIT_WORKFLOW" \
    "branch.allowed_types.map" \
    "branch workflow builds branch pattern from standards contract" \
    "branch workflow appears to hardcode branch types (missing allowed_types.map)"

  check_contains_literal \
    "$PR_WORKFLOW" \
    "const templatePath = \".github/PULL_REQUEST_TEMPLATE.md\";" \
    "pr-quality workflow validates canonical template path" \
    "pr-quality workflow not pinned to canonical template path"
}

check_template_contract() {
  check_contains_regex \
    "$PR_TEMPLATE" \
    "^## Checklist[[:space:]]*$" \
    "pr template includes Checklist heading" \
    "pr template missing Checklist heading"

  check_contains_regex \
    "$PR_TEMPLATE" \
    "^- \\[[ xX]\\] " \
    "pr template includes checklist items" \
    "pr template missing checklist items"
}

main() {
  echo "== Commit/PR Standards Alignment Validation =="

  require_file "$COMMITS_DOC"
  require_file "$PR_DOC"
  require_file "$STANDARDS_JSON"
  require_file "$PR_TEMPLATE"
  require_file "$COMMIT_WORKFLOW"
  require_file "$PR_WORKFLOW"

  check_standards_contract
  check_commit_policy_alignment
  check_pr_policy_alignment
  check_workflow_alignment
  check_template_contract
  check_type_alignment

  echo
  echo "Validation summary: errors=$errors warnings=$warnings"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
