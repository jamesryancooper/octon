#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$SCRIPT_DIR/repo-hygiene-common.sh"

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/repo-hygiene.XXXXXX")"
trap 'remove_tree "$TMP_DIR"' EXIT

MODE=""
AUDIT_ID=""
AUDIT_DIR=""
PACKET_ROOT=""
OUTPUT_DIR=""
LOG_DIR=""
AUDIT_SUMMARY_FILE=""
FINDINGS_FILE=""
BLOCKING_FINDINGS_FILE=""
SUMMARY_MD_FILE=""
TRACKED_FILES_FILE=""
SHELL_FILES_FILE=""
SH_ONLY_FILES_FILE=""
HOST_TOOL_RESOLUTION_FILE=""
REQUIRED_DETECTOR_FAILURES=0
STATIC_PROTECTED_PREFIXES_FILE=""
HOST_TOOL_ENV_FILE=""

usage() {
  cat <<'EOF'
Usage:
  repo-hygiene.sh scan
  repo-hygiene.sh enforce
  repo-hygiene.sh audit [--audit-id <id>] [--audit-dir <path>]
  repo-hygiene.sh packetize [--audit-id <id> | --audit-dir <path>] [--packet-root <path>]
EOF
}

init_report_files() {
  mkdir -p "$OUTPUT_DIR" "$LOG_DIR"
  write_yaml_header "$AUDIT_SUMMARY_FILE" "repo-hygiene-audit-summary-v1" "$AUDIT_ID" "$MODE"
  cat >>"$AUDIT_SUMMARY_FILE" <<'EOF'
detectors: []
summary:
  total_findings: 0
  blocking_findings: 0
  high_confidence_blocking_findings: 0
  required_detector_failures: 0
  packetization_ready: false
  findings_by_class: []
  findings_by_action: []
  findings_by_confidence: []
paths:
  findings_ref: "findings.yml"
  blocking_findings_ref: "blocking-findings.yml"
  summary_ref: "summary.md"
EOF

  write_yaml_header "$FINDINGS_FILE" "repo-hygiene-findings-v1" "$AUDIT_ID" "$MODE"
  cat >>"$FINDINGS_FILE" <<'EOF'
findings: []
EOF
}

binary_version_line() {
  local binary_path="$1"
  case "$(basename "$binary_path")" in
    shellcheck)
      "$binary_path" --version 2>&1 | awk '/^version:/ {print $2; exit}' | tr -d '\r'
      ;;
    cargo-machete)
      PATH="$(dirname "$binary_path"):$PATH" cargo machete --version 2>&1 | head -n 1 | tr -d '\r'
      ;;
    cargo-udeps)
      PATH="$(dirname "$binary_path"):$PATH" cargo udeps --version 2>&1 | head -n 1 | tr -d '\r'
      ;;
    *)
      "$binary_path" --version 2>&1 | head -n 1 | tr -d '\r'
      ;;
  esac
}

resolve_host_tools_for_mode() {
  [[ "$MODE" == "scan" || "$MODE" == "packetize" ]] && return 0
  HOST_TOOL_ENV_FILE="$TMP_DIR/host-tools.env"
  bash "$PROVISION_HOST_TOOLS_SCRIPT" verify \
    --repo-root "$ROOT_DIR" \
    --consumer repo-hygiene \
    --mode "$MODE" \
    --emit-env "$HOST_TOOL_ENV_FILE" \
    --quiet
  # shellcheck source=/dev/null
  source "$HOST_TOOL_ENV_FILE"
  HOST_TOOL_RESOLUTION_FILE="$OUTPUT_DIR/host-tools.yml"

  {
    echo 'schema_version: "repo-hygiene-host-tool-resolution-v1"'
    printf 'generated_at: "%s"\n' "$(now_utc)"
    echo 'consumer: "repo-hygiene"'
    printf 'mode: "%s"\n' "$MODE"
    printf 'octon_home: "%s"\n' "${OCTON_HOST_TOOLS_HOME:-}"
    echo 'tools:'
    if [[ -n "${OCTON_HOST_TOOL_SHELLCHECK_BIN:-}" ]]; then
      printf '  shellcheck:\n    binary_path: "%s"\n    version_line: "%s"\n' \
        "$OCTON_HOST_TOOL_SHELLCHECK_BIN" "$(binary_version_line "$OCTON_HOST_TOOL_SHELLCHECK_BIN")"
    fi
    if [[ -n "${OCTON_HOST_TOOL_CARGO_MACHETE_BIN:-}" ]]; then
      printf '  cargo-machete:\n    binary_path: "%s"\n    version_line: "%s"\n' \
        "$OCTON_HOST_TOOL_CARGO_MACHETE_BIN" "$(binary_version_line "$OCTON_HOST_TOOL_CARGO_MACHETE_BIN")"
    fi
    if [[ -n "${OCTON_HOST_TOOL_CARGO_UDEPS_BIN:-}" ]]; then
      printf '  cargo-udeps:\n    binary_path: "%s"\n    version_line: "%s"\n' \
        "$OCTON_HOST_TOOL_CARGO_UDEPS_BIN" "$(binary_version_line "$OCTON_HOST_TOOL_CARGO_UDEPS_BIN")"
    fi
  } >"$HOST_TOOL_RESOLUTION_FILE"

  HOST_TOOL_RESOLUTION_REL="host-tools.yml" yq -i '.paths.host_tool_resolution_ref = strenv(HOST_TOOL_RESOLUTION_REL)' "$AUDIT_SUMMARY_FILE"
}

resolved_direct_binary() {
  local env_key="$1"
  local fallback_bin="$2"
  local candidate="${!env_key:-}"
  if [[ -n "$candidate" && -x "$candidate" ]]; then
    printf '%s\n' "$candidate"
  elif command -v "$fallback_bin" >/dev/null 2>&1; then
    command -v "$fallback_bin"
  else
    printf '\n'
  fi
}

record_detector() {
  local detector_id="$1"
  local available="$2"
  local required="$3"
  local ran="$4"
  local status="$5"
  local exit_status="$6"
  local log_ref="$7"
  local notes="$8"
  local command_text
  command_text="$(policy_detector_command "$detector_id")"

  DETECTOR_ID="$detector_id" \
  AVAILABLE="$available" \
  REQUIRED="$required" \
  RAN="$ran" \
  STATUS="$status" \
  EXIT_STATUS="$exit_status" \
  LOG_REF="$log_ref" \
  NOTES="$notes" \
  COMMAND_TEXT="$command_text" \
  yq -i '
    .detectors += [{
      "id": strenv(DETECTOR_ID),
      "command": strenv(COMMAND_TEXT),
      "available": (strenv(AVAILABLE) == "true"),
      "required_for_mode": (strenv(REQUIRED) == "true"),
      "ran": (strenv(RAN) == "true"),
      "status": strenv(STATUS),
      "exit_status": strenv(EXIT_STATUS),
      "log_ref": strenv(LOG_REF),
      "notes": strenv(NOTES)
    }]
  ' "$AUDIT_SUMMARY_FILE"
}

append_finding() {
  local id="$1"
  local finding_class="$2"
  local confidence="$3"
  local action="$4"
  local blocking="$5"
  local path_ref="$6"
  local title="$7"
  local rationale="$8"
  local detector="$9"
  local evidence_refs="${10}"

  FINDING_ID="$id" \
  FINDING_CLASS="$finding_class" \
  CONFIDENCE="$confidence" \
  ACTION="$action" \
  BLOCKING="$blocking" \
  PATH_REF="$path_ref" \
  TITLE="$title" \
  RATIONALE="$rationale" \
  DETECTOR="$detector" \
  EVIDENCE_REFS="$evidence_refs" \
  yq -i '
    .findings += [{
      "id": strenv(FINDING_ID),
      "class": strenv(FINDING_CLASS),
      "confidence": strenv(CONFIDENCE),
      "action": strenv(ACTION),
      "blocking": (strenv(BLOCKING) == "true"),
      "path": strenv(PATH_REF),
      "title": strenv(TITLE),
      "rationale": strenv(RATIONALE),
      "detector": strenv(DETECTOR),
      "evidence_refs": (strenv(EVIDENCE_REFS) | split(",") | map(select(length > 0)))
    }]
  ' "$FINDINGS_FILE"
}

tool_available_for_detector() {
  local detector_id="$1"
  case "$detector_id" in
    cargo-check|cargo-clippy|cargo-machete|cargo-udeps)
      command -v cargo >/dev/null 2>&1
      ;;
    git-ls-files)
      command -v git >/dev/null 2>&1
      ;;
    find)
      command -v find >/dev/null 2>&1
      ;;
    reference-scan)
      command -v rg >/dev/null 2>&1
      ;;
    shellcheck)
      [[ -n "$(resolved_direct_binary OCTON_HOST_TOOL_SHELLCHECK_BIN shellcheck)" ]]
      ;;
    bash-syntax)
      command -v bash >/dev/null 2>&1
      ;;
    sh-syntax)
      command -v sh >/dev/null 2>&1
      ;;
    transition-heuristics|retirement-reconciliation|historical-release-reconciliation|dynamic-protection)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

run_command_detector() {
  local detector_id="$1"
  shift
  local required="false"
  local log_file="$LOG_DIR/$detector_id.log"
  local log_ref="${log_file#$ROOT_DIR/}"
  local exit_status=0
  local status="passed"
  local notes=""

  if policy_detector_required "$detector_id" "$MODE"; then
    required="true"
  fi

  if ! tool_available_for_detector "$detector_id"; then
    status="missing"
    notes="required tool for detector is unavailable in the local environment"
    if [[ "$required" == "true" ]]; then
      REQUIRED_DETECTOR_FAILURES=$((REQUIRED_DETECTOR_FAILURES + 1))
    fi
    : >"$log_file"
    record_detector "$detector_id" "false" "$required" "false" "$status" "0" "$log_ref" "$notes"
    return 0
  fi

  if "$@" >"$log_file" 2>&1; then
    exit_status=0
    status="passed"
  else
    exit_status=$?
    status="failed"
    if [[ "$detector_id" == "cargo-machete" ]] && grep -Fq 'cargo-machete found the following unused dependencies' "$log_file"; then
      status="passed"
      notes="cargo-machete reported candidate unused dependencies"
    elif [[ "$detector_id" == "cargo-udeps" ]] && grep -Fq 'unused dependencies:' "$log_file"; then
      status="passed"
      notes="cargo-udeps reported candidate unused dependencies"
    elif [[ "$required" == "true" ]]; then
      REQUIRED_DETECTOR_FAILURES=$((REQUIRED_DETECTOR_FAILURES + 1))
    fi
  fi
  sanitize_retained_log "$log_file"

  record_detector "$detector_id" "true" "$required" "true" "$status" "$exit_status" "$log_ref" "$notes"
  return 0
}

collect_tracked_files() {
  if [[ -f "$LOG_DIR/git-ls-files.log" ]]; then
    cp "$LOG_DIR/git-ls-files.log" "$TRACKED_FILES_FILE"
  else
    git -C "$ROOT_DIR" ls-files >"$TRACKED_FILES_FILE"
  fi
}

collect_shell_files() {
  grep -E '\.sh$' "$TRACKED_FILES_FILE" | sort -u >"$SHELL_FILES_FILE" || true
  : >"$SH_ONLY_FILES_FILE"
  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    if head -n 1 "$ROOT_DIR/$path" | grep -Eq '^#!.*(/|env )sh([[:space:]]|$)'; then
      printf '%s\n' "$path" >>"$SH_ONLY_FILES_FILE"
    fi
  done <"$SHELL_FILES_FILE"
}

run_shell_syntax_detector() {
  local detector_id="$1"
  local shell_bin="$2"
  local input_file="$3"
  local required="false"
  local available="true"
  local log_file="$LOG_DIR/$detector_id.log"
  local log_ref="${log_file#$ROOT_DIR/}"
  local status="passed"
  local exit_status=0

  if policy_detector_required "$detector_id" "$MODE"; then
    required="true"
  fi

  if ! command -v "$shell_bin" >/dev/null 2>&1; then
    available="false"
    status="missing"
    if [[ "$required" == "true" ]]; then
      REQUIRED_DETECTOR_FAILURES=$((REQUIRED_DETECTOR_FAILURES + 1))
    fi
    : >"$log_file"
    record_detector "$detector_id" "$available" "$required" "false" "$status" "0" "$log_ref" "shell interpreter unavailable"
    return 0
  fi

  : >"$log_file"
  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    if ! "$shell_bin" -n "$ROOT_DIR/$path" >>"$log_file" 2>&1; then
      status="failed"
      exit_status=1
    fi
  done <"$input_file"
  sanitize_retained_log "$log_file"

  if [[ "$status" == "failed" && "$required" == "true" ]]; then
    REQUIRED_DETECTOR_FAILURES=$((REQUIRED_DETECTOR_FAILURES + 1))
  fi
  record_detector "$detector_id" "$available" "$required" "true" "$status" "$exit_status" "$log_ref" ""
}

run_shellcheck_detector() {
  local detector_id="shellcheck"
  local required="false"
  local log_file="$LOG_DIR/$detector_id.log"
  local log_ref="${log_file#$ROOT_DIR/}"
  local status="passed"
  local exit_status=0
  local shellcheck_bin

  if policy_detector_required "$detector_id" "$MODE"; then
    required="true"
  fi

  shellcheck_bin="$(resolved_direct_binary OCTON_HOST_TOOL_SHELLCHECK_BIN shellcheck)"
  if [[ -z "$shellcheck_bin" ]]; then
    if [[ "$required" == "true" ]]; then
      REQUIRED_DETECTOR_FAILURES=$((REQUIRED_DETECTOR_FAILURES + 1))
    fi
    : >"$log_file"
    record_detector "$detector_id" "false" "$required" "false" "missing" "0" "$log_ref" "shellcheck is unavailable"
    return 0
  fi

  : >"$log_file"
  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    if ! "$shellcheck_bin" -x "$ROOT_DIR/$path" >>"$log_file" 2>&1; then
      exit_status=$?
      status="passed"
    fi
  done <"$SHELL_FILES_FILE"
  sanitize_retained_log "$log_file"

  if [[ -s "$log_file" ]]; then
    record_detector "$detector_id" "true" "$required" "true" "$status" "$exit_status" "$log_ref" "shellcheck reported lint findings"
  else
    record_detector "$detector_id" "true" "$required" "true" "$status" "$exit_status" "$log_ref" ""
  fi
}

parse_clippy_findings() {
  local log_file="$LOG_DIR/cargo-clippy.log"
  [[ -f "$log_file" ]] || return 0

  while IFS= read -r line; do
    [[ "$line" == *" warning: "* ]] || continue
    local path_part="${line%%:*}"
    local line_rest="${line#"$path_part":}"
    local line_no="${line_rest%%:*}"
    local message="${line##* warning: }"
    local finding_id
    finding_id="$(sanitize_id "rh-clippy-${path_part}-${line_no}-${message}")"
    append_finding \
      "$finding_id" \
      "rust-static-deadness" \
      "low" \
      "needs-ablation-before-delete" \
      "false" \
      "$path_part:$line_no" \
      "Rust deadness signal from clippy" \
      "$message" \
      "cargo-clippy" \
      ".octon/framework/engine/runtime/crates/Cargo.toml,$AUDIT_SUMMARY_FILE"
  done <"$log_file"
}

parse_machete_findings() {
  local log_file="$LOG_DIR/cargo-machete.log"
  [[ -f "$log_file" ]] || return 0
  if grep -Fq 'error: no such command: `machete`' "$log_file"; then
    return 0
  fi

  while IFS= read -r line; do
    line="$(printf '%s\n' "$line" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    [[ -n "$line" ]] || continue
    local dependency="$line"
    local finding_id
    finding_id="$(sanitize_id "rh-machete-$dependency")"
    append_finding \
      "$finding_id" \
      "rust-dependency-deadness" \
      "medium" \
      "needs-ablation-before-delete" \
      "false" \
      ".octon/framework/engine/runtime/crates/Cargo.toml" \
      "Rust dependency deadness candidate" \
      "cargo machete reported a potentially unused dependency: $dependency" \
      "cargo-machete" \
      ".octon/framework/engine/runtime/crates/Cargo.toml,$AUDIT_SUMMARY_FILE"
  done <"$log_file"
}

parse_udeps_findings() {
  local log_file="$LOG_DIR/cargo-udeps.log"
  [[ -f "$log_file" ]] || return 0

  while IFS= read -r line; do
    [[ "$line" == *"unused dependencies"* || "$line" == *"unused dependency"* ]] || continue
    local finding_id
    finding_id="$(sanitize_id "rh-udeps-$line")"
    append_finding \
      "$finding_id" \
      "rust-dependency-deadness" \
      "medium" \
      "needs-ablation-before-delete" \
      "false" \
      ".octon/framework/engine/runtime/crates/Cargo.toml" \
      "Rust dependency deadness candidate" \
      "$line" \
      "cargo-udeps" \
      ".octon/framework/engine/runtime/crates/Cargo.toml,$AUDIT_SUMMARY_FILE"
  done <"$log_file"
}

detect_shell_orphans() {
  command -v rg >/dev/null 2>&1 || return 0

  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    if [[ "$path" == .octon/instance/* || "$path" == .github/* || "$path" == scripts/* ]]; then
      :
    elif [[ "$path" == *.sh && "$path" != */* ]]; then
      :
    else
      continue
    fi
    if path_is_protected "$path"; then
      continue
    fi

    local full_ref_hits base_ref_hits base_name
    base_name="$(basename "$path")"
    full_ref_hits="$(rg -l -F -- "$path" "$ROOT_DIR/.octon/instance" "$ROOT_DIR/.github" "$ROOT_DIR/AGENTS.md" "$ROOT_DIR/CLAUDE.md" 2>/dev/null | grep -v -F "$ROOT_DIR/$path" || true)"
    base_ref_hits="$(rg -l -F -- "$base_name" "$ROOT_DIR/.octon/instance" "$ROOT_DIR/.github" "$ROOT_DIR/AGENTS.md" "$ROOT_DIR/CLAUDE.md" 2>/dev/null | grep -v -F "$ROOT_DIR/$path" || true)"
    if [[ -z "$full_ref_hits" && -z "$base_ref_hits" ]]; then
      local finding_id
      finding_id="$(sanitize_id "rh-shell-orphan-$path")"
      append_finding \
        "$finding_id" \
        "shell-script-orphaning" \
        "medium" \
        "needs-ablation-before-delete" \
        "false" \
        "$path" \
        "Potential orphaned shell surface" \
        "Tracked shell surface has no live path or basename references across authoritative and workflow roots." \
        "reference-scan" \
        "$path,$AUDIT_SUMMARY_FILE"
    fi
  done <"$SHELL_FILES_FILE"
}

detect_artifact_bloat() {
  local graph_count materialized_count
  graph_count="$(grep -c '^\.octon/generated/cognition/graph/' "$TRACKED_FILES_FILE" || true)"
  materialized_count="$(grep -c '^\.octon/generated/cognition/projections/materialized/' "$TRACKED_FILES_FILE" || true)"

  if [[ "$graph_count" != "0" ]]; then
    append_finding \
      "rh-generated-graph-rebuild-root" \
      "artifact-bloat" \
      "low" \
      "needs-ablation-before-delete" \
      "false" \
      ".octon/generated/cognition/graph/**" \
      "Rebuild-by-default graph outputs remain tracked" \
      "The root manifest marks the graph family as rebuild-by-default, and ${graph_count} tracked files remain under this root." \
      "find" \
      ".octon/octon.yml,.octon/generated/cognition/graph/**"
  fi

  if [[ "$materialized_count" != "0" ]]; then
    append_finding \
      "rh-generated-materialized-rebuild-root" \
      "artifact-bloat" \
      "low" \
      "needs-ablation-before-delete" \
      "false" \
      ".octon/generated/cognition/projections/materialized/**" \
      "Rebuild-by-default materialized projections remain tracked" \
      "The root manifest marks the materialized projection family as rebuild-by-default, and ${materialized_count} tracked files remain under this root." \
      "find" \
      ".octon/octon.yml,.octon/generated/cognition/projections/materialized/**"
  fi
}

detect_historical_release_gaps() {
  local active_release_root expected_glob register_entry_successor
  active_release_root="$(resolve_active_release_root_rel)"
  register_entry_successor="$(yq -r '.entries[] | select(.surface == "superseded-release-disclosure-bundles") | .canonical_successor_ref // ""' "$RETIREMENT_REGISTER_PATH")"

  while IFS= read -r release_id; do
    [[ -n "$release_id" ]] || continue
    expected_glob=".octon/state/evidence/disclosure/releases/${release_id}/**"
    if path_is_protected "${expected_glob%/**}"; then
      continue
    fi

    local registry_ok register_ok rationale blocking
    registry_ok="true"
    register_ok="true"
    blocking="false"
    rationale="Historical or superseded release bundle is already covered by retirement governance."

    if ! retirement_registry_has_path "$expected_glob"; then
      registry_ok="false"
      blocking="true"
      rationale="Release lineage marks the bundle historical or superseded, but the retirement registry does not cover it."
    fi

    if ! retirement_register_has_path "$expected_glob"; then
      register_ok="false"
      blocking="true"
      rationale="Release lineage marks the bundle historical or superseded, but the retirement register does not cover it."
    fi

    if [[ "$register_entry_successor" != "${active_release_root}/**" ]]; then
      blocking="true"
      rationale="Retirement register coverage for superseded release bundles points at a stale canonical successor instead of the current active release."
    fi

    if [[ "$blocking" == "true" ]]; then
      local finding_id
      finding_id="$(sanitize_id "rh-historical-release-gap-$release_id")"
      append_finding \
        "$finding_id" \
        "historical-retained-surface" \
        "high" \
        "register-for-future-retirement" \
        "true" \
        "$expected_glob" \
        "Historical release bundle missing or stale retirement coverage" \
        "$rationale" \
        "historical-release-reconciliation" \
        ".octon/instance/governance/disclosure/release-lineage.yml,.octon/instance/governance/contracts/retirement-registry.yml,.octon/instance/governance/retirement-register.yml"
    fi
  done < <(yq -r '.historical_releases[].release_id' "$RELEASE_LINEAGE_PATH")
}

render_blocking_findings() {
  FINDINGS_PATH="$FINDINGS_FILE" yq -n '
    (load(strenv(FINDINGS_PATH))) as $root |
    {
      "schema_version": "repo-hygiene-blocking-findings-v1",
      "audit_id": $root.audit_id,
      "mode": $root.mode,
      "generated_at": $root.generated_at,
      "policy_ref": $root.policy_ref,
      "findings": (($root.findings // []) | map(select(.blocking == true)))
    }
  ' >"$BLOCKING_FINDINGS_FILE"
}

update_audit_summary_counts() {
  local total_findings blocking_findings high_blocking packet_ready
  total_findings="$(yq -r '.findings | length' "$FINDINGS_FILE")"
  blocking_findings="$(yq -r '[.findings[] | select(.blocking == true)] | length' "$FINDINGS_FILE")"
  high_blocking="$(yq -r '[.findings[] | select(.blocking == true and .confidence == "high")] | length' "$FINDINGS_FILE")"

  if [[ "$blocking_findings" == "0" ]]; then
    packet_ready="true"
  else
    packet_ready="false"
  fi

  FINDINGS_PATH="$FINDINGS_FILE" yq -i '
    .summary.total_findings = '"$total_findings"' |
    .summary.blocking_findings = '"$blocking_findings"' |
    .summary.high_confidence_blocking_findings = '"$high_blocking"' |
    .summary.required_detector_failures = '"$REQUIRED_DETECTOR_FAILURES"' |
    .summary.packetization_ready = ('"$packet_ready"' == "true") |
    .summary.findings_by_class = ((load(strenv(FINDINGS_PATH)).findings // []) | group_by(.class) | map({"class": .[0].class, "count": length}) // []) |
    .summary.findings_by_action = ((load(strenv(FINDINGS_PATH)).findings // []) | group_by(.action) | map({"action": .[0].action, "count": length}) // []) |
    .summary.findings_by_confidence = ((load(strenv(FINDINGS_PATH)).findings // []) | group_by(.confidence) | map({"confidence": .[0].confidence, "count": length}) // [])
  ' "$AUDIT_SUMMARY_FILE"
}

write_summary_markdown() {
  local total_findings blocking_findings detector_failures
  total_findings="$(yq -r '.summary.total_findings' "$AUDIT_SUMMARY_FILE")"
  blocking_findings="$(yq -r '.summary.blocking_findings' "$AUDIT_SUMMARY_FILE")"
  detector_failures="$(yq -r '.summary.required_detector_failures' "$AUDIT_SUMMARY_FILE")"

  {
    echo "# Repo Hygiene ${MODE^}"
    echo
    echo "- Audit id: \`$AUDIT_ID\`"
    echo "- Generated at: \`$(yq -r '.generated_at' "$AUDIT_SUMMARY_FILE")\`"
    echo "- Active release: \`$(yq -r '.active_release_id' "$AUDIT_SUMMARY_FILE")\`"
    echo "- Latest build-to-delete packet: \`$(yq -r '.latest_review_packet_ref' "$AUDIT_SUMMARY_FILE")\`"
    echo "- Current governance review: \`$(yq -r '.current_governance_review_ref' "$AUDIT_SUMMARY_FILE")\`"
    if [[ -n "$HOST_TOOL_RESOLUTION_FILE" && -f "$HOST_TOOL_RESOLUTION_FILE" ]]; then
      echo "- Host tool resolution: \`host-tools.yml\`"
    fi
    echo "- Total findings: \`$total_findings\`"
    echo "- Blocking findings: \`$blocking_findings\`"
    echo "- Required detector failures: \`$detector_failures\`"
    echo
    echo "## Detector Status"
    while IFS=$'\t' read -r detector_id status required log_ref notes; do
      echo "- \`$detector_id\`: \`$status\` (required=\`$required\`, log=\`$log_ref\`)"
      if [[ -n "$notes" && "$notes" != "null" ]]; then
        echo "  notes: $notes"
      fi
    done < <(yq -r '.detectors[] | [.id, .status, .required_for_mode, .log_ref, .notes] | @tsv' "$AUDIT_SUMMARY_FILE")
    echo
    echo "## Findings"
    if [[ "$total_findings" == "0" ]]; then
      echo "No findings."
    else
      while IFS=$'\t' read -r finding_id finding_class confidence action blocking path_ref title; do
        echo "- \`$finding_id\` [class=\`$finding_class\`, confidence=\`$confidence\`, action=\`$action\`, blocking=\`$blocking\`]: \`$path_ref\`"
        echo "  $title"
      done < <(yq -r '.findings[] | [.id, .class, .confidence, .action, .blocking, .path, .title] | @tsv' "$FINDINGS_FILE")
    fi
  } >"$SUMMARY_MD_FILE"
}

run_scan_or_audit() {
  run_command_detector git-ls-files git -C "$ROOT_DIR" ls-files
  run_command_detector find bash -lc "find '$ROOT_DIR/.octon/generated/cognition/graph' '$ROOT_DIR/.octon/generated/cognition/projections/materialized' -maxdepth 6 -type f 2>/dev/null"
  run_command_detector reference-scan rg -n "shim|mirror|projection|compatibility|legacy|superseded|historical" \
    "$ROOT_DIR/.octon/instance" \
    "$ROOT_DIR/.octon/state/evidence/disclosure/releases" \
    "$ROOT_DIR/.octon/state/evidence/validation/publication/build-to-delete" \
    "$ROOT_DIR/.github"

  collect_tracked_files
  collect_shell_files

  if [[ "$MODE" != "scan" ]]; then
    resolve_host_tools_for_mode
    local cargo_env_prefix=""
    local cargo_machete_cmd=""
    local cargo_udeps_cmd=""
    if [[ -n "${OCTON_HOST_TOOL_CARGO_HOME:-}" ]]; then
      cargo_env_prefix+="CARGO_HOME='${OCTON_HOST_TOOL_CARGO_HOME}' "
    fi
    if [[ -n "${OCTON_HOST_TOOL_RUSTUP_HOME:-}" ]]; then
      cargo_env_prefix+="RUSTUP_HOME='${OCTON_HOST_TOOL_RUSTUP_HOME}' "
    fi
    if [[ -n "${OCTON_HOST_TOOL_RUSTUP_TOOLCHAIN:-}" ]]; then
      cargo_env_prefix+="RUSTUP_TOOLCHAIN='${OCTON_HOST_TOOL_RUSTUP_TOOLCHAIN}' "
    fi
    if [[ -n "${OCTON_HOST_TOOL_CARGO_MACHETE_BIN:-}" ]]; then
      cargo_machete_cmd="PATH='$(dirname "${OCTON_HOST_TOOL_CARGO_MACHETE_BIN}")':\$PATH ${cargo_env_prefix}cargo machete"
    else
      cargo_machete_cmd="${cargo_env_prefix}cargo machete"
    fi
    if [[ -n "${OCTON_HOST_TOOL_CARGO_UDEPS_BIN:-}" ]]; then
      cargo_udeps_cmd="PATH='$(dirname "${OCTON_HOST_TOOL_CARGO_UDEPS_BIN}")':\$PATH ${cargo_env_prefix}cargo +nightly udeps --workspace --all-targets --all-features"
    else
      cargo_udeps_cmd="${cargo_env_prefix}cargo +nightly udeps --workspace --all-targets --all-features"
    fi

    run_command_detector cargo-check cargo +stable check --manifest-path "$RUNTIME_WORKSPACE_MANIFEST" --workspace --all-targets --all-features
    run_command_detector cargo-clippy cargo +stable clippy --manifest-path "$RUNTIME_WORKSPACE_MANIFEST" --workspace --all-targets --all-features --message-format short -- -W dead_code -W unused_imports -W unused_variables
    run_command_detector cargo-machete bash -lc "cd '$ROOT_DIR/.octon/framework/engine/runtime/crates' && ${cargo_machete_cmd}"
    if [[ "$MODE" == "audit" ]]; then
      run_command_detector cargo-udeps bash -lc "cd '$ROOT_DIR/.octon/framework/engine/runtime/crates' && ${cargo_udeps_cmd}"
    fi
    run_shellcheck_detector
    run_shell_syntax_detector bash-syntax bash "$SHELL_FILES_FILE"
    run_shell_syntax_detector sh-syntax sh "$SH_ONLY_FILES_FILE"
  fi

  parse_clippy_findings
  parse_machete_findings
  parse_udeps_findings
  detect_shell_orphans
  detect_artifact_bloat
  detect_historical_release_gaps

  render_blocking_findings
  update_audit_summary_counts
  write_summary_markdown

  if [[ "$MODE" == "scan" ]]; then
    cat "$SUMMARY_MD_FILE"
  else
    note "audit evidence written to ${OUTPUT_DIR#$ROOT_DIR/}"
    cat "$SUMMARY_MD_FILE"
  fi
}

resolve_packetize_inputs() {
  if [[ -n "$AUDIT_DIR" ]]; then
    OUTPUT_DIR="$AUDIT_DIR"
  elif [[ -n "$AUDIT_ID" ]]; then
    OUTPUT_DIR="$ROOT_DIR/.octon/state/evidence/runs/ci/repo-hygiene/$AUDIT_ID"
  else
    OUTPUT_DIR="$(latest_audit_dir || true)"
  fi

  [[ -n "$OUTPUT_DIR" ]] || die "packetize requires --audit-id or --audit-dir when no prior audit exists"
  [[ -d "$OUTPUT_DIR" ]] || die "audit directory does not exist: $OUTPUT_DIR"
  AUDIT_SUMMARY_FILE="$OUTPUT_DIR/audit-summary.yml"
  FINDINGS_FILE="$OUTPUT_DIR/findings.yml"
  BLOCKING_FINDINGS_FILE="$OUTPUT_DIR/blocking-findings.yml"
  SUMMARY_MD_FILE="$OUTPUT_DIR/summary.md"
  HOST_TOOL_RESOLUTION_FILE="$OUTPUT_DIR/host-tools.yml"
  [[ -f "$AUDIT_SUMMARY_FILE" ]] || die "missing audit summary: $AUDIT_SUMMARY_FILE"
  [[ -f "$FINDINGS_FILE" ]] || die "missing findings: $FINDINGS_FILE"
  [[ -f "$BLOCKING_FINDINGS_FILE" ]] || die "missing blocking findings: $BLOCKING_FINDINGS_FILE"
  [[ -f "$SUMMARY_MD_FILE" ]] || die "missing summary: $SUMMARY_MD_FILE"
  AUDIT_ID="$(yq -r '.audit_id' "$AUDIT_SUMMARY_FILE")"
}

packetize() {
  resolve_packetize_inputs

  if [[ -z "$PACKET_ROOT" ]]; then
    PACKET_ROOT="$(rel_to_abs "$(resolve_latest_review_packet_rel)")"
  fi
  mkdir -p "$PACKET_ROOT"

  local packet_file="$PACKET_ROOT/repo-hygiene-findings.yml"
  local audit_ref=".octon/state/evidence/runs/ci/repo-hygiene/$AUDIT_ID"
  local host_tools_ref=""
  local total_findings blocking_findings detector_failures ready
  total_findings="$(yq -r '.summary.total_findings' "$AUDIT_SUMMARY_FILE")"
  blocking_findings="$(yq -r '.summary.blocking_findings' "$AUDIT_SUMMARY_FILE")"
  detector_failures="$(yq -r '.summary.required_detector_failures' "$AUDIT_SUMMARY_FILE")"
  ready="$(yq -r '.summary.packetization_ready' "$AUDIT_SUMMARY_FILE")"

  if [[ -f "$HOST_TOOL_RESOLUTION_FILE" ]]; then
    host_tools_ref="${audit_ref}/host-tools.yml"
  fi

  AUDIT_SUMMARY_PATH="$AUDIT_SUMMARY_FILE" \
  FINDINGS_PATH="$FINDINGS_FILE" \
  BLOCKING_PATH="$BLOCKING_FINDINGS_FILE" \
  PACKET_ROOT_REL="${PACKET_ROOT#$ROOT_DIR/}" \
  AUDIT_REF="$audit_ref" \
  HOST_TOOLS_REF="$host_tools_ref" \
  yq -n '
    {
      "schema_version": "repo-hygiene-packet-attachment-v1",
      "generated_at": "'"$(now_utc)"'",
      "policy_ref": ".octon/instance/governance/policies/repo-hygiene.yml",
      "audit_ref": strenv(AUDIT_REF),
      "latest_review_packet_ref": strenv(PACKET_ROOT_REL),
      "active_release_id": "'"$(resolve_active_release_id)"'",
      "active_release_root": "'"$(resolve_active_release_root_rel)"'",
      "current_governance_review_ref": "'"$(resolve_current_governance_review_rel)"'",
      "summary": (load(strenv(AUDIT_SUMMARY_PATH)).summary),
      "artifact_refs": {
        "audit_summary": (strenv(AUDIT_REF) + "/audit-summary.yml"),
        "findings": (strenv(AUDIT_REF) + "/findings.yml"),
        "blocking_findings": (strenv(AUDIT_REF) + "/blocking-findings.yml"),
        "summary": (strenv(AUDIT_REF) + "/summary.md"),
        "host_tools": strenv(HOST_TOOLS_REF)
      },
      "blocking_findings": (load(strenv(BLOCKING_PATH)).findings // []),
      "governance_relevant_findings": (
        (load(strenv(FINDINGS_PATH)).findings // [])
        | map(select(.class == "transitional-residue" or .class == "historical-retained-surface" or .class == "never-delete-surface"))
      )
    }
  ' >"$packet_file"

  note "packetized hygiene findings at ${packet_file#$ROOT_DIR/}"
  printf 'packetized audit=%s total_findings=%s blocking_findings=%s detector_failures=%s ready=%s\n' \
    "$AUDIT_ID" "$total_findings" "$blocking_findings" "$detector_failures" "$ready"

  if [[ "$ready" != "true" ]]; then
    return 1
  fi
  return 0
}

parse_args() {
  MODE="${1:-}"
  [[ -n "$MODE" ]] || {
    usage
    exit 1
  }
  shift || true

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --audit-id)
        AUDIT_ID="${2:-}"
        shift 2
        ;;
      --audit-dir)
        AUDIT_DIR="${2:-}"
        shift 2
        ;;
      --packet-root)
        PACKET_ROOT="${2:-}"
        shift 2
        ;;
      *)
        die "unknown argument: $1"
        ;;
    esac
  done
}

prepare_mode() {
  case "$MODE" in
    scan|enforce)
      AUDIT_ID="${AUDIT_ID:-$(default_audit_id)}"
      OUTPUT_DIR="$TMP_DIR/$MODE"
      ;;
    audit)
      AUDIT_ID="${AUDIT_ID:-$(default_audit_id)}"
      if [[ -n "$AUDIT_DIR" ]]; then
        OUTPUT_DIR="$AUDIT_DIR"
      else
        OUTPUT_DIR="$ROOT_DIR/.octon/state/evidence/runs/ci/repo-hygiene/$AUDIT_ID"
      fi
      ;;
    packetize)
      return 0
      ;;
    *)
      usage
      exit 1
      ;;
  esac

  LOG_DIR="$OUTPUT_DIR/detectors"
  AUDIT_SUMMARY_FILE="$OUTPUT_DIR/audit-summary.yml"
  FINDINGS_FILE="$OUTPUT_DIR/findings.yml"
  BLOCKING_FINDINGS_FILE="$OUTPUT_DIR/blocking-findings.yml"
  SUMMARY_MD_FILE="$OUTPUT_DIR/summary.md"
  TRACKED_FILES_FILE="$TMP_DIR/tracked-files.txt"
  SHELL_FILES_FILE="$TMP_DIR/shell-files.txt"
  SH_ONLY_FILES_FILE="$TMP_DIR/sh-only-files.txt"
  STATIC_PROTECTED_PREFIXES_FILE="$TMP_DIR/static-protected-prefixes.txt"
  init_report_files
  yq -r '.protected_surfaces.static_prefixes[]' "$POLICY_PATH" >"$STATIC_PROTECTED_PREFIXES_FILE"
  export REPO_HYGIENE_STATIC_PROTECTED_PREFIXES_FILE="$STATIC_PROTECTED_PREFIXES_FILE"
  export REPO_HYGIENE_ACTIVE_RELEASE_ROOT_REL="$(resolve_active_release_root_rel)"
  export REPO_HYGIENE_LATEST_REVIEW_PACKET_REL="$(resolve_latest_review_packet_rel)"
  export REPO_HYGIENE_CURRENT_GOVERNANCE_REVIEW_REL="$(resolve_current_governance_review_rel)"
}

main() {
  ensure_prerequisites
  parse_args "$@"
  prepare_mode

  case "$MODE" in
    scan)
      run_scan_or_audit
      ;;
    enforce)
      run_scan_or_audit
      local blocking_findings
      blocking_findings="$(yq -r '.summary.blocking_findings' "$AUDIT_SUMMARY_FILE")"
      if [[ "$blocking_findings" != "0" || "$REQUIRED_DETECTOR_FAILURES" != "0" ]]; then
        return 1
      fi
      ;;
    audit)
      run_scan_or_audit
      local blocking_findings
      blocking_findings="$(yq -r '.summary.blocking_findings' "$AUDIT_SUMMARY_FILE")"
      if [[ "$blocking_findings" != "0" || "$REQUIRED_DETECTOR_FAILURES" != "0" ]]; then
        return 1
      fi
      ;;
    packetize)
      packetize
      ;;
  esac
}

main "$@"
