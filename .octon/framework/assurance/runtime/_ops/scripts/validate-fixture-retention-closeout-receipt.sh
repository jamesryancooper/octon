#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd -- "$SCRIPT_DIR/../../../../" && pwd)"
OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
DEFAULT_ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
ROOT_DIR="${OCTON_ROOT_DIR:-$DEFAULT_ROOT_DIR}"
SCHEMA_PATH="$FRAMEWORK_DIR/product/contracts/fixture-retention-closeout-receipt-v1.schema.json"
RECEIPT_PATH=""
EMIT_CONSUMPTION_JSON=0
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-fixture-retention-closeout-receipt.sh --receipt <path> [--emit-consumption-json]
USAGE
}

pass() {
  [[ "$EMIT_CONSUMPTION_JSON" -eq 1 ]] || echo "[OK] $1"
}

fail() {
  [[ "$EMIT_CONSUMPTION_JSON" -eq 1 ]] || echo "[ERROR] $1"
  errors=$((errors + 1))
}

need_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[ERROR] $1 is required" >&2
    exit 1
  fi
}

normalize_path() {
  local path="$1"
  case "$path" in
    "$ROOT_DIR"/*) path="${path#"$ROOT_DIR"/}" ;;
  esac
  path="${path#./}"
  while [[ "$path" == */ && "$path" != "/" ]]; do
    path="${path%/}"
  done
  printf '%s\n' "$path"
}

scalar() {
  yq -r "$1" "$RECEIPT_PATH" 2>/dev/null || true
}

path_under_root() {
  local path="$1"
  local root="$2"
  root="${root%/}"
  [[ "$path" == "$root" || "$path" == "$root/"* ]]
}

path_under_any_root_file() {
  local path="$1"
  local roots_file="$2"
  local root
  while IFS= read -r root; do
    [[ -n "$root" ]] || continue
    if path_under_root "$path" "$root"; then
      return 0
    fi
  done <"$roots_file"
  return 1
}

digest_file_lines() {
  local file="$1"
  if [[ -s "$file" ]]; then
    LC_ALL=C sort "$file" | shasum -a 256 | awk '{print "sha256:" $1}'
  else
    printf '' | shasum -a 256 | awk '{print "sha256:" $1}'
  fi
}

reject_authority_ref() {
  local value="$1"
  local label="$2"
  if [[ "$value" == .octon/generated/* || "$value" == *"/generated/"* ]]; then
    fail "$label must not use generated output as authority"
  fi
  if [[ "$value" == */support/proposal-closeout.md || "$value" == */support/executable-implementation-prompt.md ]]; then
    fail "$label must not use proposal-local prose or generated prompt as authority"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --receipt)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      RECEIPT_PATH="$1"
      ;;
    --emit-consumption-json)
      EMIT_CONSUMPTION_JSON=1
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

[[ -n "$RECEIPT_PATH" ]] || { usage >&2; exit 2; }
need_tool jq
need_tool yq
GIT_ROOT="$(git -C "$ROOT_DIR" rev-parse --show-toplevel 2>/dev/null)" || {
  echo "[ERROR] not inside a git repository: $ROOT_DIR" >&2
  exit 1
}
ROOT_DIR="$GIT_ROOT"
RECEIPT_REL="$(normalize_path "$RECEIPT_PATH")"
RECEIPT_PATH="$ROOT_DIR/$RECEIPT_REL"

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/fixture-retention-validate.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT
ROOTS_FILE="$TMP_DIR/scope-roots.txt"
RECEIPT_ROWS="$TMP_DIR/receipt-status-rows.txt"
RECEIPT_PATHS="$TMP_DIR/receipt-paths.txt"
CURRENT_ROWS="$TMP_DIR/current-status-rows.txt"
CURRENT_PATHS="$TMP_DIR/current-paths.txt"
CONSUMPTION_JSON="$TMP_DIR/consumption.json"

[[ "$EMIT_CONSUMPTION_JSON" -eq 1 ]] || echo "== Fixture Retention Closeout Receipt Validation =="

[[ -f "$SCHEMA_PATH" ]] && pass "receipt schema exists" || fail "receipt schema missing: $SCHEMA_PATH"
jq -e '.' "$SCHEMA_PATH" >/dev/null 2>&1 && pass "receipt schema JSON parses" || fail "receipt schema JSON does not parse"
[[ -f "$RECEIPT_PATH" ]] && pass "receipt file exists: $RECEIPT_REL" || fail "receipt file missing: $RECEIPT_REL"
if [[ ! -f "$RECEIPT_PATH" ]]; then
  [[ "$EMIT_CONSUMPTION_JSON" -eq 1 ]] || echo "Validation summary: errors=$errors"
  exit 1
fi
yq -e '.' "$RECEIPT_PATH" >/dev/null 2>&1 && pass "receipt YAML parses" || fail "receipt YAML does not parse"
if yq -r '.. | select(tag == "!!str")' "$RECEIPT_PATH" 2>/dev/null | grep -Exq 'archive-ready|cleaned'; then
  fail "fixture retention receipt must not claim archive-ready or cleaned"
else
  pass "receipt does not claim archive-ready or cleaned"
fi

[[ "$(scalar '.schema_version')" == "fixture-retention-closeout-receipt-v1" ]] \
  && pass "schema_version correct" \
  || fail "schema_version must be fixture-retention-closeout-receipt-v1"
[[ "$(scalar '.route_id')" == "fixture-retention-closeout" ]] \
  && pass "route_id correct" \
  || fail "route_id must be fixture-retention-closeout"

fixture_path="$(normalize_path "$(scalar '.fixture.path')")"
proposal_id="$(scalar '.fixture.proposal_id')"
proposal_kind="$(scalar '.fixture.proposal_kind')"
manifest="$ROOT_DIR/$fixture_path/proposal.yml"
[[ -f "$manifest" ]] && pass "fixture manifest exists" || fail "fixture manifest missing"
if [[ -f "$manifest" ]]; then
  [[ "$(yq -r '.proposal_id // ""' "$manifest" 2>/dev/null || true)" == "$proposal_id" ]] \
    && pass "fixture proposal_id matches manifest" \
    || fail "fixture.proposal_id must match proposal.yml"
  [[ "$(yq -r '.proposal_kind // ""' "$manifest" 2>/dev/null || true)" == "$proposal_kind" ]] \
    && pass "fixture proposal_kind matches manifest" \
    || fail "fixture.proposal_kind must match proposal.yml"
  [[ "$(yq -r '.lifecycle.temporary // false' "$manifest" 2>/dev/null || true)" == "true" ]] \
    && pass "fixture lifecycle temporary" \
    || fail "fixture retention requires proposal.yml lifecycle.temporary true"
fi
[[ "$(scalar '.fixture.temporary_lifecycle')" == "true" ]] \
  && pass "receipt fixture temporary_lifecycle true" \
  || fail "fixture.temporary_lifecycle must be true"

retention_verdict="$(scalar '.retention_verdict')"
case "$retention_verdict" in
  retained|blocked) pass "retention_verdict allowed" ;;
  *) fail "retention_verdict must be retained or blocked" ;;
esac
[[ -n "$(scalar '.retention_run_id')" && "$(scalar '.retention_run_id')" != "null" ]] \
  && pass "retention_run_id declared" \
  || fail "retention_run_id missing"
[[ -n "$(scalar '.retained_at')" && "$(scalar '.retained_at')" != "null" ]] \
  && pass "retained_at declared" \
  || fail "retained_at missing"
[[ -n "$(scalar '.purpose')" && "$(scalar '.purpose')" != "null" ]] \
  && pass "purpose declared" \
  || fail "purpose missing"
[[ -n "$(scalar '.owner_scope')" && "$(scalar '.owner_scope')" != "null" ]] \
  && pass "owner_scope declared" \
  || fail "owner_scope missing"

yq -r '.fixture_scope.roots[]?' "$RECEIPT_PATH" 2>/dev/null | while IFS= read -r root; do
  [[ -n "$root" && "$root" != "null" ]] || continue
  normalize_path "$root"
done >"$ROOTS_FILE"
grep -Fxq "$fixture_path" "$ROOTS_FILE" \
  && pass "fixture scope includes fixture path" \
  || fail "fixture_scope.roots must include fixture.path"

yq -r '.retained_status_entries[]? | [.status, .path] | @tsv' "$RECEIPT_PATH" 2>/dev/null >"$TMP_DIR/receipt-raw-rows.txt" || true
while IFS=$'\t' read -r status path; do
  [[ -n "${status:-}" && -n "${path:-}" ]] || continue
  path="$(normalize_path "$path")"
  printf '%s\t%s\n' "$status" "$path"
  printf '%s\n' "$path" >>"$RECEIPT_PATHS"
  path_under_any_root_file "$path" "$ROOTS_FILE" || fail "retained path must be inside declared fixture scope: $path"
done <"$TMP_DIR/receipt-raw-rows.txt" >"$RECEIPT_ROWS"
sort -u -o "$RECEIPT_ROWS" "$RECEIPT_ROWS"
sort -u -o "$RECEIPT_PATHS" "$RECEIPT_PATHS" 2>/dev/null || true

while IFS= read -r root; do
  [[ -n "$root" ]] || continue
  git -C "$ROOT_DIR" status --porcelain=v1 --untracked-files=all -- "$root" 2>/dev/null || true
done <"$ROOTS_FILE" | while IFS= read -r line; do
  [[ ${#line} -ge 4 ]] || continue
  status="${line:0:2}"
  status="${status// /}"
  raw_path="${line:3}"
  case "$raw_path" in
    *" -> "*) raw_path="${raw_path##* -> }" ;;
  esac
  path="$(normalize_path "$raw_path")"
  printf '%s\t%s\n' "$status" "$path"
  printf '%s\n' "$path" >>"$CURRENT_PATHS"
done >"$CURRENT_ROWS"
sort -u -o "$CURRENT_ROWS" "$CURRENT_ROWS"
sort -u -o "$CURRENT_PATHS" "$CURRENT_PATHS" 2>/dev/null || true

current_path_digest="$(digest_file_lines "$CURRENT_PATHS")"
current_status_digest="$(digest_file_lines "$CURRENT_ROWS")"
[[ "$(scalar '.retained_path_set_digest')" == "$current_path_digest" ]] \
  && pass "retained path-set digest current" \
  || fail "retained_path_set_digest mismatch"
[[ "$(scalar '.git_status_digest')" == "$current_status_digest" ]] \
  && pass "git status digest current" \
  || fail "git_status_digest mismatch"
cmp -s "$RECEIPT_ROWS" "$CURRENT_ROWS" \
  && pass "retained status entries exactly match current scope status" \
  || fail "retained_status_entries must exactly match current scoped git status"

evidence_count="$(yq -r '(.evidence_refs // []) | length' "$RECEIPT_PATH" 2>/dev/null || echo 0)"
[[ "$evidence_count" -gt 0 ]] && pass "evidence_refs non-empty" || fail "evidence_refs must be non-empty"
for ((index=0; index<evidence_count; index++)); do
  ref="$(normalize_path "$(scalar ".evidence_refs[$index]")")"
  reject_authority_ref "$ref" "evidence_refs[$index]"
  [[ -e "$ROOT_DIR/$ref" ]] && pass "evidence_refs[$index] exists" || fail "evidence_refs[$index] does not exist: $ref"
done

generated_count="$(yq -r '(.generated_artifact_refs // []) | length' "$RECEIPT_PATH" 2>/dev/null || echo 0)"
for ((index=0; index<generated_count; index++)); do
  [[ "$(scalar ".generated_artifact_refs[$index].authority")" == "derived-only-non-authority" ]] \
    && pass "generated artifact ref[$index] derived-only" \
    || fail "generated_artifact_refs[$index].authority must be derived-only-non-authority"
done

for key in \
  allowed \
  exact_path_set_match_required \
  current_digest_match_required \
  schema_route_version_match_required \
  purpose_owner_scope_match_required \
  all_retained_paths_inside_declared_scope_required \
  unrelated_residue_coverage_forbidden \
  nonblocking_only_for_unrelated_packet_terminal_readiness; do
  [[ "$(scalar ".terminal_worktree_hygiene_consumption.$key")" == "true" ]] \
    && pass "terminal consumption $key true" \
    || fail "terminal_worktree_hygiene_consumption.$key must be true"
done
[[ "$(scalar '.terminal_worktree_hygiene_consumption.target_packet_evidence_authority')" == "false" ]] \
  && pass "fixture receipt not target packet evidence authority" \
  || fail "fixture receipt must not be target packet evidence authority"
[[ "$(scalar '.terminal_worktree_hygiene_consumption.purpose')" == "$(scalar '.purpose')" ]] \
  && pass "terminal consumption purpose matches receipt purpose" \
  || fail "terminal_worktree_hygiene_consumption.purpose must match top-level purpose"
[[ "$(scalar '.terminal_worktree_hygiene_consumption.owner_scope')" == "$(scalar '.owner_scope')" ]] \
  && pass "terminal consumption owner_scope matches receipt owner_scope" \
  || fail "terminal_worktree_hygiene_consumption.owner_scope must match top-level owner_scope"

for forbidden in archive-ready-claim cleaned-claim target-packet-implementation-evidence target-packet-conformance-evidence target-packet-drift-evidence repo-hygiene-deletion; do
  yq -e ".terminal_worktree_hygiene_consumption.does_not_authorize[]? | select(. == \"$forbidden\")" "$RECEIPT_PATH" >/dev/null 2>&1 \
    && pass "does_not_authorize includes $forbidden" \
    || fail "does_not_authorize must include $forbidden"
done

for key in archive_relocation proposal_status_mutation generated_publication_edit git_mutation residue_deletion repo_hygiene_deletion_authority target_packet_evidence_authority; do
  [[ "$(scalar ".authority_boundaries.$key")" == "false" ]] \
    && pass "authority_boundaries.$key false" \
    || fail "authority_boundaries.$key must be false"
done

state_count="$(yq -r '(.state_ledger // []) | length' "$RECEIPT_PATH" 2>/dev/null || echo 0)"
[[ "$state_count" -ge 5 ]] && pass "state ledger has at least five entries" || fail "state ledger must have at least five entries"
for state_id in resolve-fixture-identity bind-retention-scope verify-retained-evidence classify-retained-path-set emit-retention-receipt; do
  yq -e ".state_ledger[]? | select(.state_id == \"$state_id\")" "$RECEIPT_PATH" >/dev/null 2>&1 \
    && pass "state ledger includes $state_id" \
    || fail "state ledger missing $state_id"
  outputs="$(yq -r ".state_ledger[]? | select(.state_id == \"$state_id\") | .output_evidence_refs[]?" "$RECEIPT_PATH" 2>/dev/null || true)"
  grep -Fq "reports/$state_id-report.md" <<<"$outputs" \
    && pass "state $state_id report materialized" \
    || fail "state $state_id must reference reports/$state_id-report.md"
  grep -Fq "stages/$state_id/outcome.json" <<<"$outputs" \
    && pass "state $state_id outcome materialized" \
    || fail "state $state_id must reference stages/$state_id/outcome.json"
done

if [[ "$retention_verdict" == "retained" ]]; then
  [[ "$(scalar '.freshness.status')" == "fresh" ]] \
    && pass "retained receipt freshness fresh" \
    || fail "retained receipt requires freshness.status fresh"
  [[ "$(scalar '.blocker.class')" == "none" ]] \
    && pass "retained receipt blocker none" \
    || fail "retained receipt requires blocker.class none"
  [[ -s "$RECEIPT_ROWS" ]] && pass "retained receipt has retained status entries" || fail "retained receipt requires retained status entries"
fi

if [[ "$EMIT_CONSUMPTION_JSON" -eq 1 ]]; then
  if [[ "$errors" -eq 0 && "$retention_verdict" == "retained" ]]; then
    yq -o=json '.retained_status_entries // []' "$RECEIPT_PATH" >"$TMP_DIR/entries.json"
    jq -n \
      --arg receipt_ref "$RECEIPT_REL" \
      --arg purpose "$(scalar '.purpose')" \
      --arg owner_scope "$(scalar '.owner_scope')" \
      --slurpfile entries "$TMP_DIR/entries.json" \
      '{receipt_ref: $receipt_ref, purpose: $purpose, owner_scope: $owner_scope, retained_status_entries: ($entries[0] // [])}' >"$CONSUMPTION_JSON"
    cat "$CONSUMPTION_JSON"
    exit 0
  fi
  exit 1
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
