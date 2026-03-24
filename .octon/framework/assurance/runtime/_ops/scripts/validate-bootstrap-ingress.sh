#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

CANONICAL_AGENTS_FILE="$OCTON_DIR/AGENTS.md"
ROOT_AGENTS_FILE="$ROOT_DIR/AGENTS.md"
ROOT_CLAUDE_FILE="$ROOT_DIR/CLAUDE.md"
OBJECTIVE_FILE="$OCTON_DIR/instance/bootstrap/OBJECTIVE.md"
INTENT_FILE="$OCTON_DIR/instance/cognition/context/shared/intent.contract.yml"
EXPECTED_INGRESS_TARGET=".octon/AGENTS.md"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

has_text() {
  local text="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -n -F -m 1 "$text" "$file" >/dev/null 2>&1
  else
    grep -Fnm 1 -- "$text" "$file" >/dev/null 2>&1
  fi
}

has_pattern() {
  local pattern="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -n -m 1 "$pattern" "$file" >/dev/null 2>&1
  else
    grep -Enm 1 -- "$pattern" "$file" >/dev/null 2>&1
  fi
}

frontmatter_field() {
  local file_path="$1"
  local key="$2"
  awk -v key="$key" '
    NR == 1 && $0 == "---" {in_frontmatter=1; next}
    in_frontmatter && $0 == "---" {exit}
    in_frontmatter && $0 ~ "^[[:space:]]*" key ":[[:space:]]*" {
      line=$0
      sub("^[[:space:]]*" key ":[[:space:]]*", "", line)
      sub(/[[:space:]]+#.*/, "", line)
      gsub(/^"/, "", line)
      gsub(/"$/, "", line)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
      print line
      exit
    }
  ' "$file_path"
}

yaml_scalar_field() {
  local file_path="$1"
  local key="$2"
  awk -v key="$key" '
    $0 ~ "^[[:space:]]*" key ":[[:space:]]*" {
      line=$0
      sub("^[[:space:]]*" key ":[[:space:]]*", "", line)
      sub(/[[:space:]]+#.*/, "", line)
      gsub(/^"/, "", line)
      gsub(/"$/, "", line)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
      print line
      exit
    }
  ' "$file_path"
}

validate_ingress_adapter() {
  local file_path="$1"
  local label="$2"
  local target=""

  if [[ -L "$file_path" ]]; then
    target="$(readlink "$file_path")"
    if [[ "$target" == "$EXPECTED_INGRESS_TARGET" ]]; then
      pass "$label symlink points to $EXPECTED_INGRESS_TARGET"
    else
      fail "$label symlink target mismatch: $target"
    fi
    return
  fi

  if [[ -f "$file_path" ]]; then
    if cmp -s "$CANONICAL_AGENTS_FILE" "$file_path"; then
      pass "$label matches canonical projected ingress"
    else
      fail "$label must be a symlink to $EXPECTED_INGRESS_TARGET or a byte-for-byte parity copy"
    fi
    return
  fi

  fail "$label is missing: ${file_path#$ROOT_DIR/}"
}

validate_objective_headings() {
  local heading
  local -a required_headings=(
    "Workspace Goal"
    "What Octon Should Optimize For"
    "In Scope"
    "Out of Scope"
    "Success Signals"
    "Initial Focus"
  )

  for heading in "${required_headings[@]}"; do
    if has_pattern "^## ${heading}$" "$OBJECTIVE_FILE"; then
      pass ".octon/instance/bootstrap/OBJECTIVE.md contains section: $heading"
    else
      fail ".octon/instance/bootstrap/OBJECTIVE.md missing section: $heading"
    fi
  done
}

main() {
  local objective_schema objective_id objective_intent_id objective_intent_version
  local objective_owner objective_approved_by intent_schema intent_id intent_version
  local intent_owner intent_approved_by

  echo "== Bootstrap Ingress Validation =="

  [[ -f "$CANONICAL_AGENTS_FILE" ]] || fail "missing canonical AGENTS source: ${CANONICAL_AGENTS_FILE#$ROOT_DIR/}"
  [[ -f "$OBJECTIVE_FILE" ]] || fail "missing canonical objective brief: ${OBJECTIVE_FILE#$ROOT_DIR/}"
  [[ -f "$INTENT_FILE" ]] || fail "missing intent contract: ${INTENT_FILE#$ROOT_DIR/}"

  if has_text '.octon/instance/ingress/AGENTS.md' "$CANONICAL_AGENTS_FILE"; then
    pass ".octon/AGENTS.md points to canonical internal ingress"
  else
    fail ".octon/AGENTS.md must point to canonical internal ingress"
  fi

  if has_text 'Repo-root `AGENTS.md` and `CLAUDE.md` are thin adapters to this file.' "$CANONICAL_AGENTS_FILE"; then
    pass ".octon/AGENTS.md declares the thin-adapter rule"
  else
    fail ".octon/AGENTS.md must declare the thin-adapter rule"
  fi

  validate_ingress_adapter "$ROOT_AGENTS_FILE" "AGENTS.md"
  validate_ingress_adapter "$ROOT_CLAUDE_FILE" "CLAUDE.md"

  if [[ -e "$ROOT_DIR/OBJECTIVE.md" || -L "$ROOT_DIR/OBJECTIVE.md" ]]; then
    fail "root OBJECTIVE.md must not exist; canonical objective brief lives at .octon/instance/bootstrap/OBJECTIVE.md"
  else
    pass "root OBJECTIVE.md is absent"
  fi

  objective_schema="$(frontmatter_field "$OBJECTIVE_FILE" "schema_version")"
  objective_id="$(frontmatter_field "$OBJECTIVE_FILE" "objective_id")"
  objective_intent_id="$(frontmatter_field "$OBJECTIVE_FILE" "intent_id")"
  objective_intent_version="$(frontmatter_field "$OBJECTIVE_FILE" "intent_version")"
  objective_owner="$(frontmatter_field "$OBJECTIVE_FILE" "owner")"
  objective_approved_by="$(frontmatter_field "$OBJECTIVE_FILE" "approved_by")"

  intent_schema="$(yaml_scalar_field "$INTENT_FILE" "schema_version")"
  intent_id="$(yaml_scalar_field "$INTENT_FILE" "intent_id")"
  intent_version="$(yaml_scalar_field "$INTENT_FILE" "version")"
  intent_owner="$(yaml_scalar_field "$INTENT_FILE" "owner")"
  intent_approved_by="$(yaml_scalar_field "$INTENT_FILE" "approved_by")"

  [[ "$objective_schema" == "objective-brief-v1" ]] || fail ".octon/instance/bootstrap/OBJECTIVE.md schema_version must be objective-brief-v1"
  [[ "$intent_schema" == "intent-contract-v1" ]] || fail "intent contract schema_version must be intent-contract-v1"
  [[ -n "$objective_id" ]] || fail ".octon/instance/bootstrap/OBJECTIVE.md missing objective_id"
  [[ -n "$objective_intent_id" ]] || fail ".octon/instance/bootstrap/OBJECTIVE.md missing intent_id"
  [[ -n "$objective_intent_version" ]] || fail ".octon/instance/bootstrap/OBJECTIVE.md missing intent_version"
  [[ -n "$objective_owner" ]] || fail ".octon/instance/bootstrap/OBJECTIVE.md missing owner"
  [[ -n "$objective_approved_by" ]] || fail ".octon/instance/bootstrap/OBJECTIVE.md missing approved_by"
  [[ -n "$intent_id" ]] || fail "intent contract missing intent_id"
  [[ -n "$intent_version" ]] || fail "intent contract missing version"
  [[ -n "$intent_owner" ]] || fail "intent contract missing owner"
  [[ -n "$intent_approved_by" ]] || fail "intent contract missing approved_by"

  if [[ "$objective_intent_id" == "$intent_id" ]]; then
    pass "objective brief intent_id matches intent contract"
  else
    fail "objective brief intent_id diverges from intent contract"
  fi

  if [[ "$objective_intent_version" == "$intent_version" ]]; then
    pass "objective brief intent_version matches intent contract"
  else
    fail "objective brief intent_version diverges from intent contract"
  fi

  if [[ "$objective_owner" == "$intent_owner" ]]; then
    pass "objective brief owner matches intent contract"
  else
    fail "objective brief owner diverges from intent contract"
  fi

  if [[ "$objective_approved_by" == "$intent_approved_by" ]]; then
    pass "objective brief approved_by matches intent contract"
  else
    fail "objective brief approved_by diverges from intent contract"
  fi

  validate_objective_headings

  echo "Validation summary: errors=$errors"
  if (( errors > 0 )); then
    exit 1
  fi
}

main "$@"
