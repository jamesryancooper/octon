#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

PROPOSAL_PATH=""
REQUIRE_IMPLEMENTATION_AUTHORIZATION=0
PRINT_DIGEST=0
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
  validate-proposal-review-gate.sh --package <path> [--require-implementation-authorization]
  validate-proposal-review-gate.sh --package <path> --print-digest
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      PROPOSAL_PATH="$1"
      ;;
    --require-implementation-authorization)
      REQUIRE_IMPLEMENTATION_AUTHORIZATION=1
      ;;
    --print-digest)
      PRINT_DIGEST=1
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
REVIEW="$PROPOSAL_DIR/support/proposal-review.md"

reviewed_file_inventory() {
  find "$PROPOSAL_DIR" -type f | while IFS= read -r file; do
    local rel="${file#$PROPOSAL_DIR/}"
    case "$rel" in
      .*|*/.*)
        continue
        ;;
      SHA256SUMS.txt|support/SHA256SUMS.txt)
        continue
        ;;
      support/proposal-review.md|support/revisions/*)
        continue
        ;;
      support/proposal-creation.md)
        continue
        ;;
      support/executable-implementation-prompt.md)
        continue
        ;;
      support/implementation-run.md)
        continue
        ;;
      support/implementation-conformance-review.md|support/post-implementation-drift-churn-review.md)
        continue
        ;;
      support/proposal-closeout.md)
        continue
        ;;
      support/validation.md|support/validation/*|support/.tmp/*)
        continue
        ;;
    esac
    printf '%s\n' "$rel"
  done | LC_ALL=C sort
}

reviewed_packet_digest() {
  local tmp_dir inventory hashes
  tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/proposal-review-digest.XXXXXX")"
  inventory="$tmp_dir/inventory.txt"
  hashes="$tmp_dir/hashes.txt"
  reviewed_file_inventory >"$inventory"
  if [[ ! -s "$inventory" ]]; then
    printf 'sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855\n'
  else
    while IFS= read -r rel; do
      shasum -a 256 "$PROPOSAL_DIR/$rel" | awk -v rel="$rel" '{print $1 "  " rel}'
    done <"$inventory" >"$hashes"
    shasum -a 256 "$hashes" | awk '{print "sha256:" $1}'
  fi
  rm -r "$tmp_dir"
}

extract_field() {
  local field="$1"
  [[ -f "$REVIEW" ]] || return 0
  grep -E -i "^[[:space:]-]*${field}[[:space:]]*:" "$REVIEW" \
    | head -n 1 \
    | sed -E 's/^[^:]+:[[:space:]]*//' \
    | sed -E 's/[[:space:]]+$//' \
    | tr -d '`' || true
}

require_section() {
  local section="$1"
  if grep -Fqi "$section" "$REVIEW"; then
    pass "review includes section: $section"
  else
    fail "review includes section: $section"
  fi
}

validate_review_shape() {
  review_id="$(extract_field "review_id")"
  reviewed_at="$(extract_field "reviewed_at")"
  reviewer="$(extract_field "reviewer")"
  verdict="$(extract_field "verdict" | tr '[:upper:]' '[:lower:]')"
  implementation_prompt_authorized="$(extract_field "implementation_prompt_authorized" | tr '[:upper:]' '[:lower:]')"
  recorded_digest="$(extract_field "reviewed_packet_digest")"
  open_blocking_findings_count="$(extract_field "open_blocking_findings_count")"

  [[ -n "$review_id" ]] && pass "review_id present" || fail "review_id present"
  [[ -n "$reviewed_at" ]] && pass "reviewed_at present" || fail "reviewed_at present"
  [[ -n "$reviewer" ]] && pass "reviewer present" || fail "reviewer present"

  if [[ "$verdict" =~ ^(accepted|revision-required|rejected)$ ]]; then
    pass "review verdict is explicit"
  else
    fail "review verdict is explicit"
  fi

  if [[ "$implementation_prompt_authorized" =~ ^(yes|no)$ ]]; then
    pass "implementation prompt authorization is explicit"
  else
    fail "implementation prompt authorization is explicit"
  fi

  if [[ "$recorded_digest" =~ ^sha256:[0-9a-f]{64}$ ]]; then
    pass "reviewed packet digest is explicit"
  else
    fail "reviewed packet digest is explicit"
  fi

  if [[ "$open_blocking_findings_count" =~ ^[0-9]+$ ]]; then
    pass "open blocking finding count is numeric"
  else
    fail "open blocking finding count is numeric"
  fi

  require_section "Approved Promotion Targets"
  require_section "Exclusions"
  require_section "Blocking Findings"
  require_section "Nonblocking Findings"
  require_section "Final Route Recommendation"
}

validate_digest_fresh() {
  local current_digest
  current_digest="$(reviewed_packet_digest)"
  if [[ "$recorded_digest" == "$current_digest" ]]; then
    pass "reviewed packet digest is fresh"
  else
    fail "reviewed packet digest is fresh"
    echo "recorded: $recorded_digest"
    echo "current:  $current_digest"
  fi
}

validate_manifest_targets_covered() {
  local target
  while IFS= read -r target; do
    [[ -n "$target" ]] || continue
    if grep -Fq "$target" "$REVIEW"; then
      pass "review covers promotion target: $target"
    else
      fail "review covers promotion target: $target"
    fi
  done < <(yq -r '.promotion_targets[]?' "$MANIFEST")
}

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

if [[ "$PRINT_DIGEST" -eq 1 ]]; then
  reviewed_packet_digest
  exit 0
fi

status="$(yq -r '.status // ""' "$MANIFEST")"

case "$status" in
  draft|in-review|accepted|implemented|rejected|archived)
    pass "proposal status supports review gate"
    ;;
  *)
    fail "proposal status supports review gate"
    ;;
esac

if [[ ! -f "$REVIEW" ]]; then
  if [[ "$REQUIRE_IMPLEMENTATION_AUTHORIZATION" -eq 1 ]]; then
    fail "proposal review receipt authorizes implementation"
  fi

  case "$status" in
    draft)
      pass "draft proposal may omit proposal review receipt"
      ;;
    in-review)
      pass "in-review proposal awaits proposal review receipt"
      ;;
    accepted)
      warn "accepted proposal predates proposal-review gate; implementation authorization remains blocked until review receipt exists"
      ;;
    rejected)
      fail "rejected proposal has rejected proposal review receipt"
      ;;
    implemented|archived)
      warn "implemented or archived proposal has no proposal review receipt"
      ;;
  esac
else
  pass "proposal review receipt exists"
  validate_review_shape

  case "$status" in
    draft)
      warn "draft proposal has a proposal review receipt before entering in-review"
      ;;
    in-review)
      case "$verdict" in
        revision-required)
          pass "in-review proposal records revision-required review outcome"
          if [[ "$open_blocking_findings_count" =~ ^[1-9][0-9]*$ ]]; then
            warn "revision-required review has open blocking findings"
          fi
          ;;
        accepted)
          fail "accepted review outcome must advance proposal status to accepted"
          ;;
        rejected)
          fail "rejected review outcome must advance proposal status to rejected"
          ;;
      esac
      ;;
    accepted)
      [[ "$verdict" == "accepted" ]] && pass "accepted proposal has accepted review verdict" || fail "accepted proposal has accepted review verdict"
      [[ "$implementation_prompt_authorized" == "yes" ]] && pass "review authorizes implementation prompt" || fail "review authorizes implementation prompt"
      [[ "$open_blocking_findings_count" == "0" ]] && pass "accepted review has no open blocking findings" || fail "accepted review has no open blocking findings"
      validate_digest_fresh
      validate_manifest_targets_covered
      ;;
    rejected)
      [[ "$verdict" == "rejected" ]] && pass "rejected proposal has rejected review verdict" || fail "rejected proposal has rejected review verdict"
      ;;
    implemented|archived)
      if [[ "$verdict" == "accepted" ]]; then
        pass "implemented or archived proposal preserves accepted review evidence"
      else
        warn "implemented or archived proposal review verdict is not accepted"
      fi
      ;;
  esac
fi

if [[ "$REQUIRE_IMPLEMENTATION_AUTHORIZATION" -eq 1 ]]; then
  if [[ -f "$REVIEW" ]]; then
    [[ "$status" == "accepted" ]] && pass "proposal status is accepted for implementation authorization" || fail "proposal status is accepted for implementation authorization"
    [[ "$verdict" == "accepted" ]] && pass "proposal review authorizes implementation" || fail "proposal review authorizes implementation"
    [[ "$implementation_prompt_authorized" == "yes" ]] && pass "proposal review permits implementation prompt generation" || fail "proposal review permits implementation prompt generation"
    [[ "$open_blocking_findings_count" == "0" ]] && pass "proposal review has no open blockers for implementation" || fail "proposal review has no open blockers for implementation"
    validate_digest_fresh
    validate_manifest_targets_covered
  fi
fi

echo "Validation summary: errors=$errors warnings=$warnings"
[[ $errors -eq 0 ]]
