#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
EXPLORATORY_DIR="$OCTON_DIR/inputs/exploratory"
EXPLORATORY_ARCHITECTURE_DIR="$OCTON_DIR/framework/cognition/_meta/architecture/inputs/exploratory"
IDEATION_ARCHITECTURE_DIR="$OCTON_DIR/framework/cognition/_meta/architecture/inputs/exploratory/ideation"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

rel_path() {
  local path="$1"
  case "$path" in
    "$ROOT_DIR"/*) printf '%s\n' "${path#$ROOT_DIR/}" ;;
    *) printf '%s\n' "$path" ;;
  esac
}

require_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    pass "found file: $(rel_path "$path")"
  else
    fail "missing file: $(rel_path "$path")"
  fi
}

require_dir() {
  local path="$1"
  if [[ -d "$path" ]]; then
    pass "found directory: $(rel_path "$path")"
  else
    fail "missing directory: $(rel_path "$path")"
  fi
}

forbid_path() {
  local path="$1"
  if [[ -e "$path" ]]; then
    fail "retired exploratory surface exists: $(rel_path "$path")"
  else
    pass "retired exploratory surface absent: $(rel_path "$path")"
  fi
}

require_text() {
  local path="$1"
  local text="$2"
  local label="$3"
  if [[ ! -f "$path" ]]; then
    fail "missing file for text check: $(rel_path "$path")"
    return
  fi
  if rg -Fq -- "$text" "$path"; then
    pass "$label"
  else
    fail "$label"
  fi
}

forbid_regex() {
  local path="$1"
  local pattern="$2"
  local label="$3"
  if [[ ! -f "$path" ]]; then
    fail "missing file for regex check: $(rel_path "$path")"
    return
  fi
  if rg -inq -- "$pattern" "$path"; then
    fail "$label: $(rel_path "$path") :: $pattern"
  fi
}

validate_root_entries() {
  local entry base
  while IFS= read -r entry; do
    base="$(basename "$entry")"
    case "$base" in
      README.md|ideation|proposals|plans|syntheses|reports)
        pass "allowed exploratory root entry: $base"
        ;;
      *)
        fail "unexpected exploratory root entry: $(rel_path "$entry")"
        ;;
    esac
  done < <(find "$EXPLORATORY_DIR" -mindepth 1 -maxdepth 1 -print | sort)
}

validate_exploratory_architecture() {
  local architecture_readme="$EXPLORATORY_ARCHITECTURE_DIR/README.md"
  require_file "$architecture_readme"
  require_text "$architecture_readme" 'Local README files under `.octon/inputs/exploratory/**` are point-of-use' \
    "exploratory architecture states local READMEs are adapters"
  require_text "$architecture_readme" "ideation/**" \
    "exploratory architecture covers ideation"
  require_text "$architecture_readme" "proposals/**" \
    "exploratory architecture covers proposals"
  require_text "$architecture_readme" "plans/*.md" \
    "exploratory architecture covers plans"
  require_text "$architecture_readme" "syntheses/*.md" \
    "exploratory architecture covers syntheses"
  require_text "$architecture_readme" "reports/<report-id>/" \
    "exploratory architecture covers reports"
  require_text "$architecture_readme" 'governed proposal, plan, Change, retained evidence update, or durable authored edit outside `inputs/**`' \
    "exploratory architecture states governed route"
}

validate_ideation() {
  local governed_route='governed proposal, plan, Change, retained evidence update, or durable authored edit outside `inputs/**`'
  local docs=(
    "$EXPLORATORY_DIR/ideation/projects/README.md"
    "$EXPLORATORY_DIR/ideation/projects/registry.md"
    "$EXPLORATORY_DIR/ideation/projects/_scaffold/template/project.md"
    "$EXPLORATORY_DIR/ideation/projects/_scaffold/template/resources.md"
    "$EXPLORATORY_DIR/ideation/scratchpad/README.md"
    "$EXPLORATORY_DIR/ideation/scratchpad/inbox/README.md"
  )
  local architecture_docs=(
    "$IDEATION_ARCHITECTURE_DIR/projects.md"
    "$IDEATION_ARCHITECTURE_DIR/scratchpad.md"
  )
  local file pattern

  for file in "${docs[@]}"; do
    require_file "$file"
  done
  for file in "${architecture_docs[@]}"; do
    require_file "$file"
  done

  require_text "$EXPLORATORY_DIR/ideation/projects/README.md" "human-led" \
    "projects README states human-led boundary"
  require_text "$EXPLORATORY_DIR/ideation/projects/README.md" "non-authoritative input" \
    "projects README states non-authority boundary"
  require_text "$EXPLORATORY_DIR/ideation/scratchpad/README.md" "human-led content" \
    "scratchpad README states human-led boundary"
  require_text "$EXPLORATORY_DIR/ideation/scratchpad/README.md" "non-authoritative input" \
    "scratchpad README states non-authority boundary"

  local forbidden_patterns=(
    "cognition/runtime/context"
    "findings[[:space:]_-]+published"
    "published[[:space:]_-]+to[[:space:]_-]+workspace"
    "published[[:space:]_-]+to[[:space:]_-]+harness"
    "publish[[:space:]_-]+findings"
    "mission[[:space:]_-]+created"
    "create[[:space:]_-]+mission"
    "spawn[[:space:]_-]+missions"
    "missions/"
    "context/[[:space:]]*\\(permanent knowledge\\)"
    "agent-facing"
    "flow[[:space:]_-]+directly"
    "no separate.*promotion"
    "produce artifacts.*feed"
  )

  for file in "${docs[@]}" "${architecture_docs[@]}"; do
    [[ -f "$file" ]] || continue
    require_text "$file" "$governed_route" \
      "ideation doc states governed route: $(rel_path "$file")"
    for pattern in "${forbidden_patterns[@]}"; do
      forbid_regex "$file" "$pattern" "ideation doc contains retired direct-promotion language"
    done
    pass "ideation doc excludes retired direct-promotion language: $(rel_path "$file")"
  done
}

validate_plans() {
  local file base
  require_file "$EXPLORATORY_DIR/plans/README.md"
  require_text "$EXPLORATORY_DIR/plans/README.md" "not evidence, workflow state, policy, or runtime authority" \
    "plans README states non-authority boundary"

  while IFS= read -r file; do
    base="$(basename "$file")"
    case "$base" in
      README.md)
        ;;
      *receipt*.md|*completion-receipt*.md)
        fail "receipt-like file retained under plans: $(rel_path "$file")"
        ;;
      20??-??-??-*-implementation-plan.md|\
      20??-??-??-*-migration-plan.md|\
      20??-??-??-*-task-breakdown.md|\
      20??-??-??-*-checklist.md|\
      20??-??-??-*-assessment.md|\
      20??-??-??-*-backlog.md|\
      20??-??-??-*-plan.md)
        pass "valid advisory plan artifact: $base"
        ;;
      *)
        fail "invalid exploratory plan filename: $(rel_path "$file")"
        ;;
    esac
  done < <(find "$EXPLORATORY_DIR/plans" -maxdepth 1 -type f -name '*.md' -print | sort)
}

validate_syntheses() {
  local entry base
  require_file "$EXPLORATORY_DIR/syntheses/README.md"
  require_text "$EXPLORATORY_DIR/syntheses/README.md" "remain advisory until promoted" \
    "syntheses README states advisory boundary"

  while IFS= read -r entry; do
    base="$(basename "$entry")"
    case "$base" in
      .gitkeep|README.md|*-synthesis.md)
        pass "valid synthesis entry: $base"
        ;;
      *)
        fail "invalid synthesis entry: $(rel_path "$entry")"
        ;;
    esac
  done < <(find "$EXPLORATORY_DIR/syntheses" -mindepth 1 -maxdepth 1 -type f -print | sort)
}

validate_reports() {
  local report manifest id mode
  require_file "$EXPLORATORY_DIR/reports/README.md"
  require_text "$EXPLORATORY_DIR/reports/README.md" "Reports are non-authoritative source material" \
    "reports README states non-authority boundary"

  while IFS= read -r report; do
    case "$(basename "$report")" in
      .gitkeep|README.md)
        continue
        ;;
    esac
    if [[ ! -d "$report" ]]; then
      fail "reports surface may contain only report directories: $(rel_path "$report")"
      continue
    fi
    id="$(basename "$report")"
    manifest="$report/report.yml"
    require_file "$manifest"
    if [[ -f "$manifest" ]]; then
      if [[ "$(yq -r '.schema_version // ""' "$manifest")" == "octon-exploratory-report-v1" ]]; then
        pass "report schema current: $id"
      else
        fail "report schema must be octon-exploratory-report-v1: $(rel_path "$manifest")"
      fi
      if [[ "$(yq -r '.report_id // ""' "$manifest")" == "$id" ]]; then
        pass "report_id matches directory: $id"
      else
        fail "report_id must match directory: $(rel_path "$manifest")"
      fi
      mode="$(yq -r '.authority_mode // ""' "$manifest")"
      if [[ "$mode" == "non_authoritative" ]]; then
        pass "report authority mode is non_authoritative: $id"
      else
        fail "report authority_mode must be non_authoritative: $(rel_path "$manifest")"
      fi
    fi
  done < <(find "$EXPLORATORY_DIR/reports" -mindepth 1 -maxdepth 1 -print | sort)
}

main() {
  echo "== Exploratory Input Surface Validation =="

  require_dir "$EXPLORATORY_DIR"
  require_file "$EXPLORATORY_DIR/README.md"
  require_text "$EXPLORATORY_DIR/README.md" "never become runtime, policy, generated, state/control" \
    "exploratory README states non-authority boundary"

  require_dir "$EXPLORATORY_DIR/proposals"
  require_dir "$EXPLORATORY_DIR/ideation"
  require_dir "$EXPLORATORY_DIR/plans"
  require_dir "$EXPLORATORY_DIR/syntheses"
  require_dir "$EXPLORATORY_DIR/reports"
  forbid_path "$EXPLORATORY_DIR/drafts"
  forbid_path "$EXPLORATORY_DIR/packages"

  validate_root_entries
  validate_exploratory_architecture
  validate_ideation
  validate_plans
  validate_syntheses
  validate_reports

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
