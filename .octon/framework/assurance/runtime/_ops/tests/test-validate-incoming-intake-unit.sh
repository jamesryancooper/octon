#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../../.." && pwd)"

pass_count=0
fail_count=0
declare -a CLEANUP_DIRS=()

cleanup() {
  local dir
  for dir in "${CLEANUP_DIRS[@]}"; do
    [[ -n "$dir" ]] && rm -r -f -- "$dir"
  done
}
trap cleanup EXIT

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

assert_success() {
  local name="$1"
  shift
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

create_fixture() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/incoming-intake.XXXXXX")"
  CLEANUP_DIRS+=("$fixture_root")
  mkdir -p "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts"
  mkdir -p "$fixture_root/.octon/inputs/additive/.incoming"
  mkdir -p "$fixture_root/.octon/inputs/additive/.archive"
  mkdir -p "$fixture_root/.octon/inputs/additive/extensions"
  cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh" \
    "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh"
  chmod +x "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh"
  printf '%s\n' "$fixture_root"
}

run_validator() {
  local fixture_root="$1"
  local intake_id="$2"
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh" --intake-id "$intake_id" >/dev/null 2>&1
}

run_validator_output() {
  local fixture_root="$1"
  local intake_id="$2"
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh" --intake-id "$intake_id"
}

write_intake_unit() {
  local fixture_root="$1"
  local intake_id="$2"
  local provenance_status="${3:-declared}"
  local risk_binary="${4:-no}"
  local risk_secret="${5:-no}"
  local size_class="${6:-small}"
  local intake
  intake="$fixture_root/.octon/inputs/additive/.incoming/$intake_id"
  mkdir -p "$intake/payload"
  cat >"$intake/intake.yml" <<EOF
schema_version: "octon-additive-incoming-intake-unit-v1"
intake_id: "$intake_id"
authority_mode: "non_authoritative"
status: "unclassified"
staged_at: "2026-05-22T00:00:00Z"
submitted_by:
  type: "human"
  name: "fixture"
reason: "validator fixture"
next_step: "classify-route"
route_hint: "unknown"
payload:
  root: "payload/"
  form: "directory"
provenance:
  status: "$provenance_status"
  origin_class: "unknown"
  imported_from: "unknown"
  origin_uri: null
  source_digest_sha256: null
  attestation_refs: []
risk:
  contains_executable: "no"
  contains_binary: "$risk_binary"
  contains_secret_or_private_data: "$risk_secret"
  redistribution_risk: "unknown"
  size_class: "$size_class"
EOF
  printf '# Payload\n' >"$intake/payload/README.md"
}

case_accepts_valid_minimal_intake_unit() {
  local fixture_root
  fixture_root="$(create_fixture)"
  write_intake_unit "$fixture_root" "valid-intake"
  run_validator "$fixture_root" "valid-intake"
}

case_accepts_path_argument_for_fixture_validation() {
  local fixture_root intake
  fixture_root="$(create_fixture)"
  write_intake_unit "$fixture_root" "path-intake"
  intake="$fixture_root/.octon/inputs/additive/.incoming/path-intake"
  OCTON_DIR_OVERRIDE="$fixture_root/.octon" OCTON_ROOT_DIR="$fixture_root" \
    bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh" --path "$intake" >/dev/null
}

case_rejects_bad_ids() {
  local fixture_root id
  fixture_root="$(create_fixture)"
  for id in "../escape" "UpperCase" ".hidden" "bad--id" "bad-id-" "bad_id" "payload" "state"; do
    if run_validator "$fixture_root" "$id"; then
      return 1
    fi
  done
}

case_rejects_missing_intake() {
  local fixture_root
  fixture_root="$(create_fixture)"
  ! run_validator "$fixture_root" "missing-intake"
}

case_rejects_missing_envelope() {
  local fixture_root intake
  fixture_root="$(create_fixture)"
  intake="$fixture_root/.octon/inputs/additive/.incoming/missing-envelope"
  mkdir -p "$intake/payload"
  printf '# Payload\n' >"$intake/payload/README.md"
  ! run_validator "$fixture_root" "missing-envelope"
}

case_rejects_malformed_envelope() {
  local fixture_root intake
  fixture_root="$(create_fixture)"
  intake="$fixture_root/.octon/inputs/additive/.incoming/malformed-envelope"
  mkdir -p "$intake/payload"
  printf '# Payload\n' >"$intake/payload/README.md"
  printf 'schema_version: [\n' >"$intake/intake.yml"
  ! run_validator "$fixture_root" "malformed-envelope"
}

case_rejects_mismatched_envelope_id() {
  local fixture_root
  fixture_root="$(create_fixture)"
  write_intake_unit "$fixture_root" "mismatched-id"
  perl -0pi -e 's/intake_id: "mismatched-id"/intake_id: "other-id"/' \
    "$fixture_root/.octon/inputs/additive/.incoming/mismatched-id/intake.yml"
  ! run_validator "$fixture_root" "mismatched-id"
}

case_rejects_missing_payload() {
  local fixture_root intake
  fixture_root="$(create_fixture)"
  write_intake_unit "$fixture_root" "missing-payload"
  intake="$fixture_root/.octon/inputs/additive/.incoming/missing-payload"
  rm -r -f -- "$intake/payload"
  ! run_validator "$fixture_root" "missing-payload"
}

case_rejects_empty_payload() {
  local fixture_root intake
  fixture_root="$(create_fixture)"
  write_intake_unit "$fixture_root" "empty-payload"
  intake="$fixture_root/.octon/inputs/additive/.incoming/empty-payload"
  rm -f "$intake/payload/README.md"
  ! run_validator "$fixture_root" "empty-payload"
}

case_rejects_noise_only_payload() {
  local fixture_root intake
  fixture_root="$(create_fixture)"
  write_intake_unit "$fixture_root" "noise-only"
  intake="$fixture_root/.octon/inputs/additive/.incoming/noise-only"
  rm -f "$intake/payload/README.md"
  printf 'noise\n' >"$intake/payload/.DS_Store"
  printf 'keep\n' >"$intake/payload/.gitkeep"
  ! run_validator "$fixture_root" "noise-only"
}

case_rejects_top_level_payload_leakage() {
  local fixture_root intake
  fixture_root="$(create_fixture)"
  write_intake_unit "$fixture_root" "top-level-leakage"
  intake="$fixture_root/.octon/inputs/additive/.incoming/top-level-leakage"
  printf '# Raw\n' >"$intake/raw.md"
  ! run_validator "$fixture_root" "top-level-leakage"
}

case_rejects_symlink_escape_inside_payload() {
  local fixture_root intake
  fixture_root="$(create_fixture)"
  write_intake_unit "$fixture_root" "symlink-escape"
  intake="$fixture_root/.octon/inputs/additive/.incoming/symlink-escape"
  printf 'outside\n' >"$fixture_root/outside.txt"
  ln -s "$fixture_root/outside.txt" "$intake/payload/outside-link"
  ! run_validator "$fixture_root" "symlink-escape"
}

case_rejects_hardlink_payload_escape() {
  local fixture_root intake
  fixture_root="$(create_fixture)"
  write_intake_unit "$fixture_root" "hardlink-escape"
  intake="$fixture_root/.octon/inputs/additive/.incoming/hardlink-escape"
  printf 'outside\n' >"$fixture_root/outside-hardlink.txt"
  ln "$fixture_root/outside-hardlink.txt" "$intake/payload/outside-hardlink.txt"
  ! run_validator "$fixture_root" "hardlink-escape"
}

case_rejects_forbidden_resolved_targets() {
  local fixture_root target id link index
  fixture_root="$(create_fixture)"
  index=0

  for target in \
    "$fixture_root/Downloads/bad-intake" \
    "$fixture_root/.archive/bad-intake" \
    "$fixture_root/.octon/generated/bad-intake" \
    "$fixture_root/.octon/state/control/bad-intake" \
    "$fixture_root/.octon/state/evidence/bad-intake" \
    "$fixture_root/.codex/skills/bad-intake" \
    "$fixture_root/.claude/skills/bad-intake" \
    "$fixture_root/.cursor/skills/bad-intake" \
    "$fixture_root/.octon/inputs/additive/extensions/.incoming/bad-intake"; do
    index=$((index + 1))
    id="bad-target-$index"
    link="$fixture_root/.octon/inputs/additive/.incoming/$id"
    mkdir -p "$target"
    printf '# Bad\n' >"$target/README.md"
    ln -s "$target" "$link"
    if run_validator "$fixture_root" "$id"; then
      return 1
    fi
    rm -f "$link"
  done
}

case_accepts_safe_filename_with_spaces() {
  local fixture_root intake output
  fixture_root="$(create_fixture)"
  write_intake_unit "$fixture_root" "safe-spaces"
  intake="$fixture_root/.octon/inputs/additive/.incoming/safe-spaces"
  printf '# Safe\n' >"$intake/payload/file with spaces and punctuation-1.0.md"
  output="$(run_validator_output "$fixture_root" "safe-spaces")"
  [[ "$output" == *"file with spaces and punctuation-1.0.md"* ]]
}

case_rejects_unsafe_inventory_paths() {
  local fixture_root intake file
  fixture_root="$(create_fixture)"

  for file in \
    $'newline\npath.md' \
    $'tab\tpath.md' \
    'quote"path.md' \
    'back\slash.md' \
    $'control\001path.md'; do
    rm -r -f -- "$fixture_root/.octon/inputs/additive/.incoming/unsafe-paths"
    write_intake_unit "$fixture_root" "unsafe-paths"
    intake="$fixture_root/.octon/inputs/additive/.incoming/unsafe-paths"
    printf '# Unsafe\n' >"$intake/payload/$file"
    if run_validator "$fixture_root" "unsafe-paths"; then
      return 1
    fi
  done
}

case_rejects_nested_staging_roots() {
  local fixture_root intake
  fixture_root="$(create_fixture)"

  write_intake_unit "$fixture_root" "nested-incoming"
  intake="$fixture_root/.octon/inputs/additive/.incoming/nested-incoming"
  mkdir -p "$intake/payload/.incoming/inner"
  printf '# Inner\n' >"$intake/payload/.incoming/inner/README.md"
  ! run_validator "$fixture_root" "nested-incoming" || return 1

  write_intake_unit "$fixture_root" "nested-archive"
  intake="$fixture_root/.octon/inputs/additive/.incoming/nested-archive"
  mkdir -p "$intake/payload/.archive/inner"
  printf '# Inner\n' >"$intake/payload/.archive/inner/README.md"
  ! run_validator "$fixture_root" "nested-archive"
}

case_missing_provenance_is_classification_finding_not_shape_failure() {
  local fixture_root output
  fixture_root="$(create_fixture)"
  write_intake_unit "$fixture_root" "missing-provenance" "missing"
  output="$(run_validator_output "$fixture_root" "missing-provenance")"
  [[ "$output" == *"provenance-missing"* ]]
}

case_candidate_packs_inside_payload_are_classification_findings() {
  local fixture_root intake output
  fixture_root="$(create_fixture)"
  write_intake_unit "$fixture_root" "candidate-pack"
  intake="$fixture_root/.octon/inputs/additive/.incoming/candidate-pack"
  mkdir -p "$intake/payload/candidate"
  cat >"$intake/payload/candidate/pack.yml" <<'EOF'
schema_version: "octon-extension-pack-v5"
pack_id: "candidate"
EOF
  output="$(run_validator_output "$fixture_root" "candidate-pack")"
  [[ "$output" == *"candidate-extension-pack"* ]]
}

case_candidate_skills_inside_payload_are_classification_findings() {
  local fixture_root intake output
  fixture_root="$(create_fixture)"
  write_intake_unit "$fixture_root" "candidate-skill"
  intake="$fixture_root/.octon/inputs/additive/.incoming/candidate-skill"
  mkdir -p "$intake/payload/skill"
  printf '# Skill\n' >"$intake/payload/skill/SKILL.md"
  output="$(run_validator_output "$fixture_root" "candidate-skill")"
  [[ "$output" == *"candidate-core-skill"* ]]
}

case_declared_binary_secret_and_oversized_risks_are_findings() {
  local fixture_root output
  fixture_root="$(create_fixture)"
  write_intake_unit "$fixture_root" "risk-findings" "partial" "yes" "yes" "oversized"
  output="$(run_validator_output "$fixture_root" "risk-findings")"
  [[ "$output" == *"risk-binary-yes"* ]] && \
    [[ "$output" == *"risk-secret-or-private-data-yes"* ]] && \
    [[ "$output" == *"risk-size-oversized"* ]]
}

main() {
  assert_success "incoming intake validator accepts valid minimal envelope" case_accepts_valid_minimal_intake_unit
  assert_success "incoming intake validator supports --path for fixtures" case_accepts_path_argument_for_fixture_validation
  assert_success "incoming intake validator rejects bad ids" case_rejects_bad_ids
  assert_success "incoming intake validator rejects missing intake" case_rejects_missing_intake
  assert_success "incoming intake validator rejects missing intake.yml" case_rejects_missing_envelope
  assert_success "incoming intake validator rejects malformed intake.yml" case_rejects_malformed_envelope
  assert_success "incoming intake validator rejects mismatched intake_id" case_rejects_mismatched_envelope_id
  assert_success "incoming intake validator rejects missing payload" case_rejects_missing_payload
  assert_success "incoming intake validator rejects empty payload" case_rejects_empty_payload
  assert_success "incoming intake validator rejects noise-only payload" case_rejects_noise_only_payload
  assert_success "incoming intake validator rejects top-level payload leakage" case_rejects_top_level_payload_leakage
  assert_success "incoming intake validator rejects symlink escape inside payload" case_rejects_symlink_escape_inside_payload
  assert_success "incoming intake validator rejects hardlink payload escape" case_rejects_hardlink_payload_escape
  assert_success "incoming intake validator rejects forbidden resolved targets" case_rejects_forbidden_resolved_targets
  assert_success "incoming intake validator accepts safe filenames with spaces" case_accepts_safe_filename_with_spaces
  assert_success "incoming intake validator rejects unsafe inventory paths" case_rejects_unsafe_inventory_paths
  assert_success "incoming intake validator rejects nested staging roots" case_rejects_nested_staging_roots
  assert_success "missing provenance is a classification finding" case_missing_provenance_is_classification_finding_not_shape_failure
  assert_success "candidate extension packs inside payload are findings" case_candidate_packs_inside_payload_are_classification_findings
  assert_success "candidate core skills inside payload are findings" case_candidate_skills_inside_payload_are_classification_findings
  assert_success "declared binary secret and oversized risks are findings" case_declared_binary_secret_and_oversized_risks_are_findings

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
