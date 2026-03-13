#!/usr/bin/env bash
# validate-agent-only-governance.sh - Validate agent-only deny-by-default governance policy.

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPABILITIES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPO_ROOT="$(cd "$CAPABILITIES_DIR/../.." && pwd)"
POLICY_FILE="${1:-$CAPABILITIES_DIR/governance/policy/agent-only-governance.yml}"

errors=0

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

log_error() {
  echo -e "${RED}ERROR:${NC} $1"
  ((errors++)) || true
}

log_success() {
  echo -e "${GREEN}✓${NC} $1"
}

extract_min_distinct_agents() {
  local tier="$1"
  awk -v target="$tier" '
    /^agent_only:/ {in_agent=1; next}
    in_agent && /^[a-z_]+:/ && $1 != "risk_tiers:" {next}
    in_agent && /^[[:space:]]*risk_tiers:/ {in_tiers=1; next}
    in_tiers && $0 ~ "^[[:space:]]*"target":" {in_tier=1; next}
    in_tier && /^[[:space:]]*[a-z_]+:/ && $1 != "min_distinct_agents:" {
      if ($1 != "require_review:" && $1 != "require_quorum_token:") {
        in_tier=0
      }
    }
    in_tier && /^[[:space:]]*min_distinct_agents:/ {
      value=$2
      gsub(/["'\'' ]/, "", value)
      print value
      exit
    }
  ' "$POLICY_FILE"
}

if [[ ! -f "$POLICY_FILE" ]]; then
  log_error "Policy file not found: $POLICY_FILE"
  exit 1
fi

for key in \
  '^schema_version:' \
  '^agent_only:' \
  '^[[:space:]]*enabled:' \
  '^[[:space:]]*risk_tiers:' \
  '^[[:space:]]*low:' \
  '^[[:space:]]*medium:' \
  '^[[:space:]]*high:' \
  '^[[:space:]]*require_rollback_plan:' \
  '^[[:space:]]*kill_switch:' \
  '^[[:space:]]*kill_switches:' \
  '^[[:space:]]*state_dir:' \
  '^[[:space:]]*required_fields:' \
  '^[[:space:]]*fail_closed:' \
  '^[[:space:]]*rollback:' \
  '^[[:space:]]*rollback_plan_ref:'; do
  if ! grep -Eq "$key" "$POLICY_FILE"; then
    log_error "Missing required policy field pattern: $key"
  fi
done

for tier in low medium high; do
  value="$(extract_min_distinct_agents "$tier")"
  if [[ -z "$value" ]]; then
    log_error "Missing min_distinct_agents for tier '$tier'"
    continue
  fi
  if ! [[ "$value" =~ ^[0-9]+$ ]]; then
    log_error "min_distinct_agents for tier '$tier' must be numeric (got: $value)"
    continue
  fi
  if (( value < 1 )); then
    log_error "min_distinct_agents for tier '$tier' must be >= 1 (got: $value)"
  fi
done

kill_switch_state_dir="$(awk '
  /^[[:space:]]*kill_switches:/ {in_switches=1; next}
  in_switches && /^[[:space:]]*state_dir:/ {
    line=$0
    sub(/^[[:space:]]*state_dir:[[:space:]]*/, "", line)
    gsub(/["'\'']/, "", line)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
    print line
    exit
  }
  in_switches && /^[[:space:]]*[a-z_]+:/ && $1 != "state_dir:" && $1 != "required_fields:" && $1 != "default_state:" {
    in_switches=0
  }
' "$POLICY_FILE")"

if [[ -z "$kill_switch_state_dir" ]]; then
  log_error "Missing kill_switches.state_dir"
else
  case "$kill_switch_state_dir" in
    .octon/capabilities/_ops/state/*)
      log_success "kill_switches.state_dir scoped to capabilities state"
      ;;
    *)
      log_error "kill_switches.state_dir must stay within .octon/capabilities/_ops/state/* (got: $kill_switch_state_dir)"
      ;;
  esac
fi

required_fields_line="$(awk '
  /^[[:space:]]*kill_switches:/ {in_switches=1; next}
  in_switches && /^[[:space:]]*required_fields:/ {
    line=$0
    sub(/^[[:space:]]*required_fields:[[:space:]]*/, "", line)
    gsub(/["'\'']/, "", line)
    gsub(/[[:space:]]+/, "", line)
    print line
    exit
  }
' "$POLICY_FILE")"

for required_field in scope owner reason created expires state; do
  if [[ "$required_fields_line" != *"$required_field"* ]]; then
    log_error "kill_switches.required_fields must include '$required_field'"
  fi
done

rollback_plan_ref="$(awk '
  /^[[:space:]]*rollback_plan_ref:/ {
    line=$0
    sub(/^[[:space:]]*rollback_plan_ref:[[:space:]]*/, "", line)
    gsub(/["'\'']/, "", line)
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
    print line
    exit
  }
' "$POLICY_FILE")"

if [[ -n "$rollback_plan_ref" ]]; then
  if [[ ! -f "$REPO_ROOT/$rollback_plan_ref" ]]; then
    log_error "rollback_plan_ref points to missing file: $rollback_plan_ref"
  else
    log_success "rollback_plan_ref exists: $rollback_plan_ref"
  fi
fi

if [[ $errors -gt 0 ]]; then
  echo "Validation failed: $errors error(s)."
  exit 1
fi

echo "Validation passed: 0 errors."
