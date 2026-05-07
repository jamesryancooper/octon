#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

PROPOSAL_PATH=""
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

usage() {
  cat <<'EOF'
usage:
  validate-proposal-implementation-readiness.sh --package <path>
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      PROPOSAL_PATH="$1"
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

[[ -n "$PROPOSAL_PATH" ]] || { usage >&2; exit 2; }

if [[ "$PROPOSAL_PATH" = /* ]]; then
  PROPOSAL_DIR="$PROPOSAL_PATH"
else
  PROPOSAL_DIR="$ROOT_DIR/$PROPOSAL_PATH"
fi

MANIFEST="$PROPOSAL_DIR/proposal.yml"
REVIEW="$PROPOSAL_DIR/support/implementation-grade-completeness-review.md"
EXECUTABLE_PROMPT="$PROPOSAL_DIR/support/executable-implementation-prompt.md"
REVIEW_GATE_SCRIPT="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh"
legacy_archive=0

if [[ ! -d "$PROPOSAL_DIR" ]]; then
  fail "proposal package exists"
  echo "Validation summary: errors=$errors warnings=$warnings"
  exit 1
fi

if [[ ! -f "$MANIFEST" ]]; then
  fail "proposal manifest exists"
  echo "Validation summary: errors=$errors warnings=$warnings"
  exit 1
fi

proposal_kind="$(yq -r '.proposal_kind // ""' "$MANIFEST")"
status="$(yq -r '.status // ""' "$MANIFEST")"
archive_disposition="$(yq -r '.archive.disposition // ""' "$MANIFEST")"
promotion_scope="$(yq -r '.promotion_scope // ""' "$MANIFEST")"

case "$PROPOSAL_DIR" in
  */.octon/inputs/exploratory/proposals/.archive/*)
    legacy_archive=1
    ;;
esac

case "$proposal_kind" in
  policy|architecture|migration|design) pass "proposal kind supports implementation-readiness gate" ;;
  *) fail "proposal kind supports implementation-readiness gate" ;;
esac

requires_receipt=0
requires_pass=0
case "$status" in
  in-review)
    requires_receipt=1
    ;;
  accepted|implemented)
    if [[ "$legacy_archive" -eq 1 && ! -f "$REVIEW" ]]; then
      true
    else
      requires_receipt=1
      requires_pass=1
    fi
    ;;
  archived)
    if [[ -f "$REVIEW" ]]; then
      requires_receipt=1
      requires_pass=1
    elif [[ "$archive_disposition" == "implemented" ]]; then
      legacy_archive=1
    fi
    ;;
  draft)
    true
    ;;
  *)
    true
    ;;
esac

if [[ -f "$EXECUTABLE_PROMPT" ]]; then
  if [[ "$legacy_archive" -eq 1 && ! -f "$REVIEW" ]]; then
    true
  else
    requires_receipt=1
    requires_pass=1
  fi
fi

extract_field() {
  local field="$1"
  [[ -f "$REVIEW" ]] || return 0
  grep -E -i "^[[:space:]-]*${field}[[:space:]]*:" "$REVIEW" \
    | head -n 1 \
    | sed -E 's/^[^:]+:[[:space:]]*`?([^`[:space:]]+).*/\1/' \
    | tr '[:upper:]' '[:lower:]' || true
}

require_prompt_pattern() {
  local label="$1"
  local pattern="$2"
  if grep -Eiq "$pattern" "$EXECUTABLE_PROMPT"; then
    pass "$label"
  else
    fail "$label"
  fi
}

validate_proposal_review_gate() {
  if [[ ! -f "$REVIEW_GATE_SCRIPT" ]]; then
    fail "proposal review gate validator exists"
    return 0
  fi

  if bash "$REVIEW_GATE_SCRIPT" --package "$PROPOSAL_DIR"; then
    pass "proposal review gate passes"
  else
    fail "proposal review gate passes"
  fi

  if [[ -f "$EXECUTABLE_PROMPT" ]]; then
    if [[ "$legacy_archive" -eq 1 && "$status" == "archived" ]]; then
      warn "legacy archived executable prompt is not re-authorized by proposal review gate"
      return 0
    fi

    if bash "$REVIEW_GATE_SCRIPT" --package "$PROPOSAL_DIR" --require-implementation-authorization; then
      pass "proposal review authorizes executable implementation prompt"
    else
      fail "proposal review authorizes executable implementation prompt"
    fi
  fi
}

validate_executable_prompt() {
  [[ -f "$EXECUTABLE_PROMPT" ]] || return 0

  if [[ "$legacy_archive" -eq 1 && "$status" == "archived" && ! -f "$REVIEW" ]]; then
    warn "legacy archived executable prompt is not re-linted"
    return 0
  fi

  pass "executable implementation prompt exists"
  require_prompt_pattern \
    "executable implementation prompt names validation commands" \
    'validate-[a-z0-9-]+\.sh|alignment-check\.sh|validator|validation'
  require_prompt_pattern \
    "executable implementation prompt includes retained evidence expectations" \
    'evidence|receipt|support/implementation'
  require_prompt_pattern \
    "executable implementation prompt includes rollback expectations" \
    'rollback'
  require_prompt_pattern \
    "executable implementation prompt requires conformance receipt" \
    'support/implementation-conformance-review\.md'
  require_prompt_pattern \
    "executable implementation prompt requires drift/churn receipt" \
    'support/post-implementation-drift-churn-review\.md'
  require_prompt_pattern \
    "executable implementation prompt includes closeout refusal criteria" \
    '(refuse|forbid|block)[^[:cntrl:]]*(closeout|archive)|(closeout|archive)[^[:cntrl:]]*(refuse|forbid|block)'

  while IFS= read -r target; do
    [[ -n "$target" ]] || continue
    if grep -Fq "$target" "$EXECUTABLE_PROMPT"; then
      pass "executable implementation prompt covers promotion target: $target"
    else
      fail "executable implementation prompt covers promotion target: $target"
    fi
  done < <(yq -r '.promotion_targets[]?' "$MANIFEST")
}

if [[ -f "$REVIEW" ]]; then
  pass "implementation-grade completeness review exists"

  verdict="$(extract_field "verdict")"
  unresolved_questions_count="$(extract_field "unresolved_questions_count")"
  clarification_required="$(extract_field "clarification_required")"

  if [[ "$verdict" =~ ^(pass|fail)$ ]]; then
    pass "readiness verdict is explicit"
  else
    fail "readiness verdict is explicit"
  fi

  if [[ "$unresolved_questions_count" =~ ^[0-9]+$ ]]; then
    pass "unresolved question count is numeric"
  else
    fail "unresolved question count is numeric"
  fi

  if [[ "$clarification_required" =~ ^(yes|no)$ ]]; then
    pass "clarification_required is explicit"
  else
    fail "clarification_required is explicit"
  fi

  for section in \
    "Blockers" \
    "Assumptions" \
    "Promotion Target Coverage" \
    "Affected Artifact Coverage" \
    "Validator Coverage" \
    "Implementation Prompt Readiness" \
    "Exclusions" \
    "Final Route Recommendation"; do
    if grep -Fqi "$section" "$REVIEW"; then
      pass "review includes section: $section"
    else
      fail "review includes section: $section"
    fi
  done

  if [[ "$requires_pass" -eq 1 ]]; then
    [[ "$verdict" == "pass" ]] && pass "readiness gate passes for lifecycle status" || fail "readiness gate passes for lifecycle status"
    [[ "$unresolved_questions_count" == "0" ]] && pass "no unresolved questions for implementation-ready lifecycle status" || fail "no unresolved questions for implementation-ready lifecycle status"
    [[ "$clarification_required" == "no" ]] && pass "no clarification required for implementation-ready lifecycle status" || fail "no clarification required for implementation-ready lifecycle status"
  elif [[ "$status" == "in-review" ]]; then
    if [[ "$verdict" == "pass" ]]; then
      pass "in-review proposal has passing implementation-grade receipt"
    else
      warn "in-review proposal is not implementation-grade complete yet"
    fi
  elif [[ "$status" == "draft" && "$verdict" != "pass" ]]; then
    warn "draft proposal is structurally valid but not implementation-grade complete"
  fi
else
  if [[ "$requires_receipt" -eq 1 ]]; then
    fail "implementation-grade completeness review exists"
  elif [[ "$legacy_archive" -eq 1 ]]; then
    warn "legacy archived proposal has no implementation-grade completeness review"
  else
    warn "draft proposal has no implementation-grade completeness review"
  fi
fi

validate_executable_prompt
validate_proposal_review_gate

if yq -e '.promotion_targets | type == "!!seq" and length > 0' "$MANIFEST" >/dev/null 2>&1; then
  pass "promotion targets are present"
else
  fail "promotion targets are present"
fi

saw_octon=0
saw_non_octon=0
while IFS= read -r target; do
  [[ -n "$target" ]] || continue
  if [[ "$target" == .octon/* ]]; then
    saw_octon=1
  else
    saw_non_octon=1
  fi
done < <(yq -r '.promotion_targets[]?' "$MANIFEST")

if [[ "$promotion_scope" == "octon-internal" && "$saw_non_octon" -eq 1 ]]; then
  if [[ "$legacy_archive" -eq 1 || "$status" == "archived" ]]; then
    warn "legacy archived octon-internal proposal has non-.octon promotion targets"
  else
    fail "octon-internal proposal targets stay under .octon/"
  fi
elif [[ "$promotion_scope" == "repo-local" && "$saw_octon" -eq 1 ]]; then
  if [[ "$legacy_archive" -eq 1 || "$status" == "archived" ]]; then
    warn "legacy archived repo-local proposal has .octon promotion targets"
  else
    fail "repo-local proposal targets stay outside .octon/"
  fi
elif [[ "$saw_octon" -eq 1 && "$saw_non_octon" -eq 1 && "$status" != "archived" ]]; then
  fail "active proposal avoids mixed target families"
else
  pass "promotion target scope is coherent"
fi

if [[ "$requires_receipt" -eq 1 ]]; then
  case "$proposal_kind" in
    policy)
      [[ -f "$PROPOSAL_DIR/implementation/implementation-map.md" ]] && pass "policy implementation map exists" || fail "policy implementation map exists"
      for file in policy/decision.md policy/policy-delta.md policy/enforcement-plan.md; do
        [[ -f "$PROPOSAL_DIR/$file" ]] && pass "policy file exists: $file" || fail "policy file exists: $file"
      done
      grep -Fqi "## Decision" "$PROPOSAL_DIR/policy/decision.md" 2>/dev/null && pass "policy decision section exists" || fail "policy decision section exists"
      grep -Eiq "Durable Authority|Canonical Policy|target authority" "$PROPOSAL_DIR/policy/policy-delta.md" 2>/dev/null && pass "policy durable authority coverage exists" || fail "policy durable authority coverage exists"
      grep -Eiq "Validator|Validation|Enforcement" "$PROPOSAL_DIR/policy/enforcement-plan.md" 2>/dev/null && pass "policy validator/enforcement coverage exists" || fail "policy validator/enforcement coverage exists"
      ;;
    architecture)
      [[ -f "$PROPOSAL_DIR/architecture/target-architecture.md" ]] && pass "target architecture exists" || fail "target architecture exists"
      [[ -f "$PROPOSAL_DIR/architecture/implementation-plan.md" ]] && pass "architecture implementation plan exists" || fail "architecture implementation plan exists"
      [[ -f "$PROPOSAL_DIR/architecture/acceptance-criteria.md" ]] && pass "architecture acceptance criteria exist" || fail "architecture acceptance criteria exist"
      ;;
    migration)
      [[ -f "$PROPOSAL_DIR/migration/plan.md" ]] && pass "migration plan exists" || fail "migration plan exists"
      [[ -f "$PROPOSAL_DIR/migration/rollback.md" ]] && pass "migration rollback exists" || fail "migration rollback exists"
      [[ -f "$PROPOSAL_DIR/migration/release-notes.md" ]] && pass "migration release notes exist" || fail "migration release notes exist"
      ;;
    design)
      [[ -f "$PROPOSAL_DIR/implementation/minimal-implementation-blueprint.md" ]] && pass "design implementation blueprint exists" || fail "design implementation blueprint exists"
      [[ -f "$PROPOSAL_DIR/implementation/first-implementation-plan.md" ]] && pass "design first implementation plan exists" || fail "design first implementation plan exists"
      [[ -f "$PROPOSAL_DIR/normative/assurance/implementation-readiness.md" ]] && pass "design implementation readiness doc exists" || fail "design implementation readiness doc exists"
      ;;
  esac
fi

if [[ "$requires_receipt" -eq 1 ]]; then
  placeholder_hits="$(
    find "$PROPOSAL_DIR" -type f -print0 \
      | xargs -0 awk '
          /^```/ { in_fence = !in_fence; next }
          in_fence { next }
          /\[Describe/ || /(^|[^[:alnum:]_])(TODO|TBD|FIXME)([^[:alnum:]_]|$)/ || (index($0, "{{") && index($0, "}}")) {
            print FILENAME ":" FNR ":" $0
          }
        ' 2>/dev/null || true
  )"
  if [[ -n "$placeholder_hits" ]]; then
    fail "implementation-grade proposal contains no scaffold placeholders"
    printf '%s\n' "$placeholder_hits"
  else
    pass "implementation-grade proposal contains no scaffold placeholders"
  fi
fi

echo "Validation summary: errors=$errors warnings=$warnings"
[[ $errors -eq 0 ]]
