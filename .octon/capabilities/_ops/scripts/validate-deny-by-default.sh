#!/usr/bin/env bash
# validate-deny-by-default.sh - Fast deny-by-default validation across services and skills.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPABILITIES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPO_ROOT="$(cd "$CAPABILITIES_DIR/../.." && pwd)"

SERVICES_MANIFEST="$CAPABILITIES_DIR/runtime/services/manifest.yml"
SKILLS_MANIFEST="$CAPABILITIES_DIR/runtime/skills/manifest.yml"
SERVICES_VALIDATOR="$CAPABILITIES_DIR/runtime/services/_ops/scripts/validate-services.sh"
SKILLS_VALIDATOR="$CAPABILITIES_DIR/runtime/skills/_ops/scripts/validate-skills.sh"
RUNTIME_TEST_SCRIPT="$CAPABILITIES_DIR/_ops/tests/test-deny-by-default-runtime.sh"
POLICY_RUNNER="$REPO_ROOT/.octon/engine/runtime/policy"
POLICY_V2_FILE="$CAPABILITIES_DIR/governance/policy/deny-by-default.v2.yml"
POLICY_V2_SCHEMA="$CAPABILITIES_DIR/governance/policy/deny-by-default.v2.schema.json"
POLICY_REASON_CODES="$CAPABILITIES_DIR/governance/policy/reason-codes.md"
FLAGS_METADATA_FILE="$CAPABILITIES_DIR/governance/policy/flags.metadata.json"
FLAGS_METADATA_SCHEMA="$CAPABILITIES_DIR/governance/policy/flags.metadata.schema.json"
FLAGS_METADATA_VALIDATOR="$CAPABILITIES_DIR/_ops/scripts/validate-flag-metadata.sh"
PROFILE_RESOLVER="$CAPABILITIES_DIR/_ops/scripts/policy-profile-resolve.sh"
GRANT_BROKER="$CAPABILITIES_DIR/_ops/scripts/policy-grant-broker.sh"
KILL_SWITCH_SCRIPT="$CAPABILITIES_DIR/_ops/scripts/policy-kill-switch.sh"
ROLLOUT_SCRIPT="$CAPABILITIES_DIR/_ops/scripts/policy-rollout-mode.sh"
RA_ACP_MIGRATION_GUARD="$CAPABILITIES_DIR/_ops/scripts/validate-ra-acp-migration.sh"
RA_ACP_MIGRATION_GUARD_TEST_SCRIPT="$CAPABILITIES_DIR/_ops/tests/test-ra-acp-migration-guard.sh"
CAPABILITY_ENGINE_CONSISTENCY_VALIDATOR="$REPO_ROOT/.octon/assurance/runtime/_ops/scripts/validate-capability-engine-consistency.sh"

PROFILE="${OCTON_VALIDATION_PROFILE:-dev-fast}"
MODE="changed"
GLOBAL_POLICY_CHANGE=false
RUN_RUNTIME_TESTS=true

declare -a TARGET_SERVICES=()
declare -a TARGET_SKILLS=()

usage() {
  cat <<'EOF'
Usage:
  .octon/capabilities/_ops/scripts/validate-deny-by-default.sh [options]

Options:
  --all                    Validate all services and skills
  --changed                Validate changed services and skills only (default)
  --profile strict|dev-fast
                           Validation profile (default: dev-fast)
  --service <service-id>   Validate a specific service (repeatable)
  --skill <skill-id>       Validate a specific skill (repeatable)
  --skip-runtime-tests     Skip runtime deny-by-default smoke tests (strict profile only)
  --help                   Show this help
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --all)
        MODE="all"
        shift
        ;;
      --changed)
        MODE="changed"
        shift
        ;;
      --profile)
        [[ $# -ge 2 ]] || { echo "Missing value for --profile" >&2; exit 1; }
        PROFILE="$2"
        shift 2
        ;;
      --profile=*)
        PROFILE="${1#--profile=}"
        shift
        ;;
      --service)
        [[ $# -ge 2 ]] || { echo "Missing value for --service" >&2; exit 1; }
        TARGET_SERVICES+=("$2")
        shift 2
        ;;
      --skill)
        [[ $# -ge 2 ]] || { echo "Missing value for --skill" >&2; exit 1; }
        TARGET_SKILLS+=("$2")
        shift 2
        ;;
      --skip-runtime-tests)
        RUN_RUNTIME_TESTS=false
        shift
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        usage >&2
        exit 1
        ;;
    esac
  done

  if [[ "$PROFILE" != "strict" && "$PROFILE" != "dev-fast" ]]; then
    echo "Invalid profile '$PROFILE' (expected strict|dev-fast)" >&2
    exit 1
  fi
}

manifest_service_id_for_path() {
  local service_path="$1"
  awk -v target="$service_path" '
    /^services:/ {in_services=1; next}
    in_services && /^[[:space:]]*- id:/ {
      id=$3
      gsub(/["'\'' ]/, "", id)
      next
    }
    in_services && /^[[:space:]]*path:/ {
      path=$2
      gsub(/["'\'' ]/, "", path)
      if (path == target && id != "") {
        print id
        exit
      }
    }
  ' "$SERVICES_MANIFEST"
}

manifest_skill_id_for_path() {
  local skill_path="$1"
  awk -v target="$skill_path" '
    /^skills:/ {in_skills=1; next}
    in_skills && /^[[:space:]]*- id:/ {
      id=$3
      gsub(/["'\'' ]/, "", id)
      next
    }
    in_skills && /^[[:space:]]*path:/ {
      path=$2
      gsub(/["'\'' ]/, "", path)
      if (path == target && id != "") {
        print id
        exit
      }
    }
  ' "$SKILLS_MANIFEST"
}

append_unique() {
  local value="$1"
  shift
  local existing
  for existing in "$@"; do
    [[ "$existing" == "$value" ]] && return 0
  done
  return 1
}

collect_changed_files() {
  {
    git -C "$REPO_ROOT" diff --name-only --relative
    git -C "$REPO_ROOT" diff --cached --name-only --relative
    git -C "$REPO_ROOT" ls-files --others --exclude-standard
  } | sed '/^[[:space:]]*$/d' | sort -u
}

collect_changed_targets() {
  local changed_file
  local -a changed_services=()
  local -a changed_skills=()

  while IFS= read -r changed_file; do
    [[ -z "$changed_file" ]] && continue

    if [[ "$changed_file" == .octon/capabilities/runtime/services/* ]]; then
      local service_path
      service_path="$(echo "$changed_file" | awk -F/ '
        $1==".octon" && $2=="capabilities" && $3=="runtime" && $4=="services" && $5 !~ /^_/ && $6 !~ /^_/ {print $5 "/" $6}
      ')"
      if [[ -n "$service_path" ]]; then
        local service_id
        service_id="$(manifest_service_id_for_path "$service_path")"
        if [[ -n "$service_id" ]]; then
          if append_unique "$service_id" "${changed_services[@]}"; then
            changed_services+=("$service_id")
          fi
        fi
      fi
    fi

    if [[ "$changed_file" == .octon/capabilities/runtime/skills/* ]]; then
      local skill_path
      skill_path="$(echo "$changed_file" | awk -F/ '
        $1==".octon" && $2=="capabilities" && $3=="runtime" && $4=="skills" && $5 !~ /^_/ && $6 !~ /^_/ {print $5 "/" $6}
      ')"
      if [[ -n "$skill_path" ]]; then
        local skill_id
        skill_id="$(manifest_skill_id_for_path "$skill_path")"
        if [[ -n "$skill_id" ]]; then
          if append_unique "$skill_id" "${changed_skills[@]}"; then
            changed_skills+=("$skill_id")
          fi
        fi
      fi
    fi

    case "$changed_file" in
      .octon/capabilities/_ops/state/deny-by-default-exceptions.yml|\
      .octon/capabilities/governance/policy/agent-only-governance.yml|\
      .octon/capabilities/_ops/scripts/*|\
      .octon/capabilities/runtime/services/_ops/scripts/*|\
      .octon/capabilities/runtime/skills/_ops/scripts/*)
        GLOBAL_POLICY_CHANGE=true
        ;;
    esac
  done < <(collect_changed_files)

  TARGET_SERVICES+=("${changed_services[@]}")
  TARGET_SKILLS+=("${changed_skills[@]}")
}

run_service_validation() {
  local service_id="$1"
  echo "Validating service policy: $service_id"
  OCTON_VALIDATION_PROFILE="$PROFILE" "$SERVICES_VALIDATOR" --profile "$PROFILE" "$service_id"
}

run_skill_validation() {
  local skill_id="$1"
  echo "Validating skill policy: $skill_id"
  OCTON_VALIDATION_PROFILE="$PROFILE" "$SKILLS_VALIDATOR" --profile "$PROFILE" "$skill_id"
}

run_runtime_tests_if_enabled() {
  if [[ "$PROFILE" != "strict" ]]; then
    return 0
  fi

  if [[ "$RUN_RUNTIME_TESTS" != "true" ]]; then
    return 0
  fi

  if [[ ! -x "$RUNTIME_TEST_SCRIPT" ]]; then
    echo "Missing runtime deny-by-default test script: $RUNTIME_TEST_SCRIPT" >&2
    return 1
  fi

  echo "Running runtime deny-by-default regression/smoke tests"
  "$RUNTIME_TEST_SCRIPT"
}

run_policy_contract_validation() {
  if [[ ! -x "$POLICY_RUNNER" ]]; then
    echo "Missing policy runner: $POLICY_RUNNER" >&2
    return 1
  fi

  if [[ ! -f "$POLICY_V2_FILE" || ! -f "$POLICY_V2_SCHEMA" ]]; then
    echo "Missing deny-by-default v2 policy contract files." >&2
    return 1
  fi

  local output rc=0
  output="$(
    "$POLICY_RUNNER" doctor \
      --policy "$POLICY_V2_FILE" \
      --schema "$POLICY_V2_SCHEMA" \
      --reason-codes "$POLICY_REASON_CODES" 2>&1
  )" || rc=$?

  if [[ $rc -ne 0 ]]; then
    echo "Deny-by-default v2 policy contract validation failed:" >&2
    echo "$output" >&2
    return $rc
  fi

  echo "Deny-by-default v2 policy contract validated"
  return 0
}

run_flag_metadata_validation() {
  if [[ ! -x "$FLAGS_METADATA_VALIDATOR" ]]; then
    echo "Missing flag metadata validator: $FLAGS_METADATA_VALIDATOR" >&2
    return 1
  fi
  if [[ ! -f "$FLAGS_METADATA_FILE" || ! -f "$FLAGS_METADATA_SCHEMA" ]]; then
    echo "Missing flag metadata contract files." >&2
    return 1
  fi

  local output rc=0
  output="$(
    "$FLAGS_METADATA_VALIDATOR" \
      --policy "$POLICY_V2_FILE" \
      --metadata "$FLAGS_METADATA_FILE" \
      --schema "$FLAGS_METADATA_SCHEMA" 2>&1
  )" || rc=$?
  if [[ $rc -ne 0 ]]; then
    echo "Flag metadata validation failed:" >&2
    echo "$output" >&2
    return $rc
  fi

  echo "Flag metadata contract validated"
  return 0
}

run_ra_acp_migration_guard() {
  if [[ "$PROFILE" != "strict" ]]; then
    return 0
  fi

  if [[ ! -x "$RA_ACP_MIGRATION_GUARD" ]]; then
    echo "Missing RA+ACP migration guard: $RA_ACP_MIGRATION_GUARD" >&2
    return 1
  fi

  "$RA_ACP_MIGRATION_GUARD"
}

run_ra_acp_migration_guard_tests() {
  if [[ "$PROFILE" != "strict" ]]; then
    return 0
  fi

  if [[ ! -x "$RA_ACP_MIGRATION_GUARD_TEST_SCRIPT" ]]; then
    echo "Missing RA+ACP migration guard test script: $RA_ACP_MIGRATION_GUARD_TEST_SCRIPT" >&2
    return 1
  fi

  "$RA_ACP_MIGRATION_GUARD_TEST_SCRIPT"
}

run_profile_contract_validation() {
  if [[ ! -x "$PROFILE_RESOLVER" ]]; then
    echo "Missing profile resolver: $PROFILE_RESOLVER" >&2
    return 1
  fi

  "$PROFILE_RESOLVER" --lint >/dev/null
  echo "Deny-by-default profile bundles validated"
}

run_capability_engine_consistency_validation() {
  if [[ ! -x "$CAPABILITY_ENGINE_CONSISTENCY_VALIDATOR" ]]; then
    echo "Missing capability/engine consistency validator: $CAPABILITY_ENGINE_CONSISTENCY_VALIDATOR" >&2
    return 1
  fi

  "$CAPABILITY_ENGINE_CONSISTENCY_VALIDATOR"
}

run_state_hygiene_sweeps() {
  if [[ "$PROFILE" != "strict" ]]; then
    return 0
  fi

  if [[ -x "$GRANT_BROKER" ]]; then
    "$GRANT_BROKER" sweep-expired >/dev/null || true
  fi

  if [[ -x "$KILL_SWITCH_SCRIPT" ]]; then
    "$KILL_SWITCH_SCRIPT" sweep-expired >/dev/null || true
  fi
}

run_observability_report() {
  local fail_on_breach="${1:-false}"
  if [[ ! -x "$ROLLOUT_SCRIPT" ]]; then
    return 0
  fi

  if [[ "$fail_on_breach" == "true" ]]; then
    "$ROLLOUT_SCRIPT" slo-report --fail-on-breach >/dev/null
    return 0
  fi

  "$ROLLOUT_SCRIPT" slo-report >/dev/null || true
}

main() {
  parse_args "$@"

  echo "Deny-by-default validation profile: $PROFILE"

  if ! run_policy_contract_validation; then
    exit 1
  fi
  if ! run_flag_metadata_validation; then
    exit 1
  fi
  if ! run_ra_acp_migration_guard; then
    exit 1
  fi
  if ! run_ra_acp_migration_guard_tests; then
    exit 1
  fi
  if ! run_profile_contract_validation; then
    exit 1
  fi
  if ! run_capability_engine_consistency_validation; then
    exit 1
  fi
  run_state_hygiene_sweeps

  if [[ ${#TARGET_SERVICES[@]} -eq 0 && ${#TARGET_SKILLS[@]} -eq 0 ]]; then
    if [[ "$MODE" == "changed" ]]; then
      collect_changed_targets
      if [[ "$GLOBAL_POLICY_CHANGE" == "true" ]]; then
        echo "Detected shared deny-by-default policy changes; running full validation."
        MODE="all"
      fi
      if [[ "$MODE" == "changed" && ${#TARGET_SERVICES[@]} -eq 0 && ${#TARGET_SKILLS[@]} -eq 0 ]]; then
        echo "No changed services/skills detected. Nothing to validate."
        exit 0
      fi
    fi
  fi

  local status=0
  local service_id
  local skill_id

  if [[ "$MODE" == "all" && ${#TARGET_SERVICES[@]} -eq 0 && ${#TARGET_SKILLS[@]} -eq 0 ]]; then
    OCTON_VALIDATION_PROFILE="$PROFILE" "$SERVICES_VALIDATOR" --profile "$PROFILE" || status=$?
    OCTON_VALIDATION_PROFILE="$PROFILE" "$SKILLS_VALIDATOR" --profile "$PROFILE" || status=$?
    if (( status == 0 )); then
      run_runtime_tests_if_enabled || status=$?
    fi
    if (( status == 0 )) && [[ "$PROFILE" == "strict" ]]; then
      run_observability_report true || status=$?
    fi
    exit "$status"
  fi

  for service_id in "${TARGET_SERVICES[@]}"; do
    run_service_validation "$service_id" || status=$?
  done

  for skill_id in "${TARGET_SKILLS[@]}"; do
    run_skill_validation "$skill_id" || status=$?
  done

  if (( status == 0 )); then
    run_runtime_tests_if_enabled || status=$?
  fi

  if (( status == 0 )) && [[ "$PROFILE" == "strict" ]]; then
    run_observability_report true || status=$?
  fi

  exit "$status"
}

main "$@"
