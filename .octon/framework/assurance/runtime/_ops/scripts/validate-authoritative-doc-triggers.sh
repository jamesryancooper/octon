#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
REGISTRY_FILE="${DOC_CLASSIFICATION_REGISTRY_FILE:-$OCTON_DIR/framework/cognition/_meta/architecture/contract-registry.yml}"
WORKFLOW_FILE="${MAIN_PUSH_SAFETY_WORKFLOW_FILE:-$ROOT_DIR/.github/workflows/main-push-safety.yml}"
CLASSIFIER_SCRIPT="${AUTHORITATIVE_DOC_CLASSIFIER_SCRIPT:-$OCTON_DIR/framework/assurance/runtime/_ops/scripts/classify-authoritative-doc-change.sh}"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

has_pattern() {
  local pattern="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -q "$pattern" "$file"
  else
    grep -Eq "$pattern" "$file"
  fi
}

has_text() {
  local text="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -Fq "$text" "$file"
  else
    grep -Fq "$text" "$file"
  fi
}

require_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    pass "found file: ${file#$ROOT_DIR/}"
  else
    fail "missing file: ${file#$ROOT_DIR/}"
  fi
}

assert_classification() {
  local path="$1"
  local expected="$2"
  local actual
  actual="$(bash "$CLASSIFIER_SCRIPT" --registry "$REGISTRY_FILE" "$path" | awk -F '\t' 'NR == 1 { print $1 }')"
  if [[ "$actual" == "$expected" ]]; then
    pass "$path classifies as $expected"
  else
    fail "$path must classify as $expected (got $actual)"
  fi
}

main() {
  echo "== Authoritative Doc Trigger Validation =="

  require_file "$REGISTRY_FILE"
  require_file "$WORKFLOW_FILE"
  require_file "$CLASSIFIER_SCRIPT"

  if ! command -v yq >/dev/null 2>&1; then
    fail "yq is required for authoritative-doc trigger validation"
    exit 1
  fi

  if [[ "$(yq -r '.documentation.safety_trigger_classes | length' "$REGISTRY_FILE")" == "1" ]] \
    && [[ "$(yq -r '.documentation.safety_trigger_classes[0] // ""' "$REGISTRY_FILE")" == "authoritative-doc" ]]; then
    pass "authoritative-doc is the only safety trigger class"
  else
    fail "documentation safety triggers must be exactly [authoritative-doc]"
  fi

  if has_pattern '\*\*/\*\.md' "$WORKFLOW_FILE"; then
    fail "main-push-safety workflow must not blanket-ignore Markdown paths"
  else
    pass "main-push-safety workflow no longer blanket-ignores Markdown"
  fi

  if has_text 'classify-authoritative-doc-change.sh' "$WORKFLOW_FILE"; then
    pass "main-push-safety workflow delegates to the authoritative-doc classifier"
  else
    fail "main-push-safety workflow must invoke classify-authoritative-doc-change.sh"
  fi

  if has_text "needs.classify.outputs.should_run == 'true'" "$WORKFLOW_FILE"; then
    pass "main-push-safety workflow gates heavy checks on classifier output"
  else
    fail "main-push-safety workflow must gate heavy checks on classifier output"
  fi

  if has_text 'git fetch --no-tags --depth=1 origin "${before}"' "$WORKFLOW_FILE" \
    && has_text 'git cat-file -e "${before}^{commit}"' "$WORKFLOW_FILE"; then
    pass "main-push-safety workflow fail-closes when the push base commit is missing locally"
  else
    fail "main-push-safety workflow must fetch/verify the push base commit before diffing"
  fi

  if has_text 'git diff --name-only "$before" "${{ github.sha }}" || true' "$WORKFLOW_FILE"; then
    fail "main-push-safety workflow must not swallow diff failures"
  else
    pass "main-push-safety workflow does not swallow diff failures"
  fi

  while IFS= read -r required_doc; do
    [[ -n "$required_doc" ]] || continue
    assert_classification "$required_doc" "authoritative-doc"
  done < <(yq -r '.execution.required_doc_surfaces[]? | select(test("\\.md$"))' "$REGISTRY_FILE")

  assert_classification ".octon/framework/execution-roles/practices/pull-request-standards.md" "authoritative-doc"
  assert_classification ".octon/instance/cognition/decisions/062-self-audit-and-release-hardening-atomic-cutover.md" "authoritative-doc"
  assert_classification ".github/PULL_REQUEST_TEMPLATE.md" "authoritative-doc"
  assert_classification ".github/PULL_REQUEST_TEMPLATE/kaizen.md" "authoritative-doc"
  assert_classification ".octon/framework/engine/practices/release-runbook.md" "operational-guide"
  assert_classification "README.md" "narrative-doc"

  echo "Validation summary: errors=$errors"
  if [[ "$errors" -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
