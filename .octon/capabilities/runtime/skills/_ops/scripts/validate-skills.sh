#!/usr/bin/env bash
# validate-skills.sh - Validate skill consistency across manifest, registry, and SKILL.md
#
# Usage: ./validate-skills.sh [options] [skill-id]
#   If skill-id is provided, validates only that skill
#   If no arguments, validates all skills
#
# Options:
#   --strict              Enable strict contract checks and treat trigger duplicates as errors
#   --strict-display-name Treat display_name convention violations as errors
#   --fix                 Auto-fix issues where possible (scaffold missing entries)
#   --profile             Validation profile: strict (default) or dev-fast
#   --help                Show this help message
#
# Checks:
#   1. Directory exists
#   2. SKILL.md exists
#   3. SKILL.md name matches skill id (grouped-directory variance is informational)
#   4. Skill is in manifest
#   5. Skill is in registry
#   5b. display_name is present in manifest
#   6. No version in SKILL.md metadata (should be in registry only)
#   7. No requires.tools in io-contract.md (drift prevention)
#   8. No allowed tools list in safety.md (drift prevention)
#   9. No duplicated parameter/tool tables in SKILL.md
#   10. No duplicated parameter/tool tables in io-contract.md
#   11. No duplicated tool tables in safety.md body
#   12. No deprecated top-level outputs in registry.yml (use skills.<id>.io.outputs)
#   13. Skill has I/O mappings in skills registry
#   14. allowed-tools in SKILL.md is present and valid (single source of truth)
#   15. allowed-services in SKILL.md resolves to services manifest entries
#   16. Trigger overlap detection (warns on duplicate/similar triggers)
#   17. I/O path scope validation
#   18. Token budget validation (SKILL.md < 5000 tokens, manifest entry < 150 tokens)
#   19. Description/summary alignment (summary should be subset of description)
#   20. Cross-reference validation (all manifest skills have registry entries and vice versa)
#   21. Reference file content validation (io-contract.md parameters match registry, examples use correct commands)
#   22. Placeholder format validation ({{snake_case}} in registry paths)
#   23. Version staleness check (warns if version is 1.0.0 for mature skills)
#   24. Line count validation (SKILL.md < 500 lines per agentskills.io spec)
#   25. Reference file token budgets (io-contract, safety, examples, phases, validation)
#   26. Aggregate complexity budget (total reference file tokens vs complexity thresholds)
#   27. Capability-triggered file validation (references match declared capabilities)
#   28. Skill set and capability validation (valid values, reference file matching)
#
# Capability Model:
#   Skills declare skill_sets (bundles) and capabilities in manifest.yml and SKILL.md.
#   Each capability maps to specific reference files:
#   - phased → phases.md
#   - branching → decisions.md
#   - stateful/resumable → checkpoints.md
#   - self-validating → validation.md
#   - safety-bounded → safety.md
#   See: .octon/capabilities/_meta/architecture/capabilities.md
#
# Tool Permission Model:
#   - allowed-tools in SKILL.md frontmatter is the SINGLE SOURCE OF TRUTH
#   - Use map_allowed_to_registry() to convert to internal format when needed
#   - Registry.yml no longer contains requires.tools (derived from SKILL.md)
#
# Token Counting:
#   For accurate token validation, install tiktoken:
#     pip install tiktoken
#   Without tiktoken, word count approximation is used (±20% variance).
#   CI environments should install tiktoken for consistent validation.

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
CAPABILITIES_DIR="$(cd "$SKILLS_DIR/../.." && pwd)"
OCTON_DIR="$(cd "$CAPABILITIES_DIR/.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"
MANIFEST="$SKILLS_DIR/manifest.yml"
REGISTRY="$SKILLS_DIR/registry.yml"
CAPABILITIES_SCHEMA="$SKILLS_DIR/capabilities.yml"
SKILLS_REGISTRY="$REPO_ROOT/.octon/capabilities/runtime/skills/registry.yml"
TOOLS_MANIFEST="$REPO_ROOT/.octon/capabilities/runtime/tools/manifest.yml"
SERVICES_MANIFEST="$REPO_ROOT/.octon/capabilities/runtime/services/manifest.yml"
EXCEPTIONS_FILE="$REPO_ROOT/.octon/capabilities/_ops/state/deny-by-default-exceptions.yml"
AGENT_ONLY_POLICY_FILE="$REPO_ROOT/.octon/capabilities/governance/policy/agent-only-governance.yml"
AGENT_ONLY_VALIDATOR="$REPO_ROOT/.octon/capabilities/_ops/scripts/validate-agent-only-governance.sh"
POLICY_V2_FILE="$REPO_ROOT/.octon/capabilities/governance/policy/deny-by-default.v2.yml"
POLICY_RUNNER="$REPO_ROOT/.octon/engine/runtime/policy"
TODAY="$(date +%F)"

# Configuration
STRICT_MODE=false
STRICT_DISPLAY_NAME=false
FIX_MODE=false
VALIDATION_PROFILE="${OCTON_VALIDATION_PROFILE:-strict}"
SKILL_MD_TOKEN_BUDGET=5000
SKILL_MD_LINE_BUDGET=500
MANIFEST_ENTRY_TOKEN_BUDGET=150

# Reference file token budgets (warning thresholds tuned to current skill corpus)
IO_CONTRACT_TOKEN_BUDGET=2000
SAFETY_TOKEN_BUDGET=1600
EXAMPLES_TOKEN_BUDGET=3000
PHASES_TOKEN_BUDGET=6000
VALIDATION_TOKEN_BUDGET=1500

# Schema-backed authority loaded from capabilities.yml
VALID_SKILL_SETS=()
VALID_CAPABILITIES=()
VALID_SKILL_CLASSES=()
VALID_STANDARD_PLACEHOLDERS=()
VALID_COMPOSITION_MODES=()
VALID_COMPOSITION_FAILURE_POLICIES=()
VALID_COMPOSITION_STEP_KINDS=()
VALID_COMPOSITION_STEP_ROLES=()
VALID_COMPOSITION_WHEN_OPERATORS=()
VALID_MANIFEST_STATUSES=("active" "deprecated" "experimental" "draft")
VALID_PARAMETER_TYPES=("text" "boolean" "file" "folder")
VALID_OUTPUT_DETERMINISM=("stable" "variable" "unique")

# Aggregate complexity budgets (soft warning thresholds)
# These are soft limits that trigger warnings, not errors
AGGREGATE_STANDARD_BUDGET=20000    # Standard Complex skill
AGGREGATE_ENTERPRISE_BUDGET=26000  # Enterprise Complex skill
AGGREGATE_DOMAIN_BUDGET=32000      # Domain Expert skill (may legitimately exceed)

# Version staleness heuristic threshold
VERSION_STALENESS_MIN_REFS=7

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

errors=0
warnings=0

# Parse command line options
show_help() {
    head -30 "$0" | tail -28
    exit 0
}

while [[ "$1" == --* ]]; do
    case "$1" in
        --strict)
            STRICT_MODE=true
            shift
            ;;
        --strict-display-name)
            STRICT_DISPLAY_NAME=true
            shift
            ;;
        --fix)
            FIX_MODE=true
            shift
            ;;
        --profile)
            if [[ -z "$2" ]]; then
                echo "Missing value for --profile (expected strict|dev-fast)"
                exit 1
            fi
            VALIDATION_PROFILE="$2"
            shift 2
            ;;
        --profile=*)
            VALIDATION_PROFILE="${1#--profile=}"
            shift
            ;;
        --help)
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [[ "$VALIDATION_PROFILE" != "strict" ]] && [[ "$VALIDATION_PROFILE" != "dev-fast" ]]; then
    echo "Invalid profile '$VALIDATION_PROFILE' (expected strict|dev-fast)"
    exit 1
fi

log_error() {
    echo -e "${RED}ERROR:${NC} $1"
    ((errors++)) || true
}

log_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
    ((warnings++)) || true
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_info() {
    echo "  $1"
}

check_deprecated_paths() {
    local deprecated path rel
    deprecated=(
        "$SKILLS_DIR/quality-gate"
    )

    for path in "${deprecated[@]}"; do
        rel="${path#$REPO_ROOT/}"
        if [[ -e "$path" ]]; then
            log_error "Deprecated skills path exists: $rel"
        else
            log_success "Deprecated skills path removed: $rel"
        fi
    done
}

# Returns 0 when the first argument exists in the remaining arguments.
contains() {
    local value="$1"
    shift
    local item
    for item in "$@"; do
        if [[ "$item" == "$value" ]]; then
            return 0
        fi
    done
    return 1
}

require_ruby() {
    if ! command -v ruby >/dev/null 2>&1; then
        log_error "ruby is required to validate YAML-backed skill contracts"
        exit 1
    fi
}

yaml_hash_keys() {
    local file="$1"
    local path="$2"
    ruby -r yaml -e '
        data = YAML.load_file(ARGV[0])
        value = ARGV[1].split(".").reduce(data) { |acc, key| acc.is_a?(Hash) ? acc[key] : nil }
        if value.is_a?(Hash)
          value.keys.each { |item| puts item }
        end
    ' "$file" "$path"
}

yaml_list_values() {
    local file="$1"
    local path="$2"
    ruby -r yaml -e '
        data = YAML.load_file(ARGV[0])
        value = ARGV[1].split(".").reduce(data) { |acc, key| acc.is_a?(Hash) ? acc[key] : nil }
        Array(value).each { |item| puts item }
    ' "$file" "$path"
}

load_capabilities_authority() {
    require_ruby

    if [[ ! -f "$CAPABILITIES_SCHEMA" ]]; then
        log_error "Missing capabilities schema: $CAPABILITIES_SCHEMA"
        exit 1
    fi

    mapfile -t VALID_SKILL_SETS < <(yaml_hash_keys "$CAPABILITIES_SCHEMA" "skill_set_definitions")
    mapfile -t VALID_CAPABILITIES < <(yaml_list_values "$CAPABILITIES_SCHEMA" "valid_capabilities")
    mapfile -t VALID_SKILL_CLASSES < <(yaml_hash_keys "$CAPABILITIES_SCHEMA" "skill_class_definitions")
    mapfile -t VALID_STANDARD_PLACEHOLDERS < <(yaml_list_values "$CAPABILITIES_SCHEMA" "standard_placeholders")
    mapfile -t VALID_COMPOSITION_MODES < <(yaml_list_values "$CAPABILITIES_SCHEMA" "composition_contract.modes")
    mapfile -t VALID_COMPOSITION_FAILURE_POLICIES < <(yaml_list_values "$CAPABILITIES_SCHEMA" "composition_contract.failure_policies")
    mapfile -t VALID_COMPOSITION_STEP_KINDS < <(yaml_list_values "$CAPABILITIES_SCHEMA" "composition_contract.step_kinds")
    mapfile -t VALID_COMPOSITION_STEP_ROLES < <(yaml_list_values "$CAPABILITIES_SCHEMA" "composition_contract.step_roles")
    mapfile -t VALID_COMPOSITION_WHEN_OPERATORS < <(yaml_list_values "$CAPABILITIES_SCHEMA" "composition_contract.when_operators")
}

trim_value() {
    local value="$1"
    value="${value#\"}"
    value="${value%\"}"
    value="${value#\'}"
    value="${value%\'}"
    echo "$value" | xargs
}

is_valid_date() {
    local value="$1"
    [[ "$value" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
}

get_exception_expiry() {
    local expected_scope="$1"
    local expected_target="$2"
    local expected_rule="$3"

    [[ -f "$EXCEPTIONS_FILE" ]] || return 0

    local in_exceptions=false
    local scope=""
    local target=""
    local rule=""
    local expires=""
    local line trimmed value

    while IFS= read -r line || [[ -n "$line" ]]; do
        trimmed="$(echo "$line" | sed 's/^[[:space:]]*//')"
        [[ -z "$trimmed" || "$trimmed" == \#* ]] && continue

        if [[ "$trimmed" == "exceptions:" ]]; then
            in_exceptions=true
            continue
        fi

        if [[ "$in_exceptions" != true ]]; then
            continue
        fi

        if [[ "$trimmed" == "- id:"* ]]; then
            if [[ "$scope" == "$expected_scope" && "$target" == "$expected_target" && "$rule" == "$expected_rule" ]]; then
                echo "$expires"
                return 0
            fi
            scope=""
            target=""
            rule=""
            expires=""
            continue
        fi

        if [[ "$trimmed" == scope:* ]]; then
            value="${trimmed#scope:}"
            scope="$(trim_value "$value")"
        elif [[ "$trimmed" == target:* ]]; then
            value="${trimmed#target:}"
            target="$(trim_value "$value")"
        elif [[ "$trimmed" == rule:* ]]; then
            value="${trimmed#rule:}"
            rule="$(trim_value "$value")"
        elif [[ "$trimmed" == expires:* ]]; then
            value="${trimmed#expires:}"
            expires="$(trim_value "$value")"
        fi
    done < "$EXCEPTIONS_FILE"

    if [[ "$scope" == "$expected_scope" && "$target" == "$expected_target" && "$rule" == "$expected_rule" ]]; then
        echo "$expires"
    fi
}

require_active_exception() {
    local scope="$1"
    local target="$2"
    local rule="$3"
    local reason="$4"

    local expires
    expires="$(get_exception_expiry "$scope" "$target" "$rule")"

    if [[ -z "$expires" ]]; then
        log_error "$reason requires active exception lease (${scope}/${target}/${rule}) in $EXCEPTIONS_FILE"
        return 1
    fi

    if ! is_valid_date "$expires"; then
        log_error "Exception lease has invalid expiry format for (${scope}/${target}/${rule}): $expires"
        return 1
    fi

    if [[ "$expires" < "$TODAY" ]]; then
        log_error "Exception lease expired for (${scope}/${target}/${rule}) on $expires"
        return 1
    fi

    log_success "Exception lease active for (${scope}/${target}/${rule}) until $expires"
    return 0
}

extract_policy_field() {
    local json="$1"
    local path="$2"

    if command -v jq >/dev/null 2>&1; then
        jq -r "$path // empty" <<<"$json" 2>/dev/null || true
        return
    fi

    echo ""
}

validate_skill_policy_with_engine() {
    local skill_id="$1"
    local skill_dir="$2"

    if [[ ! -x "$POLICY_RUNNER" || ! -f "$POLICY_V2_FILE" ]]; then
        log_error "Policy runner unavailable for skill '$skill_id': $POLICY_RUNNER"
        return 1
    fi

    local output rc=0
    output="$(
        "$POLICY_RUNNER" preflight \
            --kind skill \
            --id "$skill_id" \
            --manifest "$MANIFEST" \
            --artifact "$skill_dir/SKILL.md" \
            --policy "$POLICY_V2_FILE" \
            --exceptions "$EXCEPTIONS_FILE" 2>&1
    )" || rc=$?

    case "$rc" in
        0)
            log_success "deny-by-default preflight passed for skill '$skill_id'"
            return 0
            ;;
        13)
            local code message hint
            code="$(extract_policy_field "$output" '.deny.code')"
            message="$(extract_policy_field "$output" '.deny.message')"
            hint="$(extract_policy_field "$output" '.deny.remediation_hint')"
            [[ -n "$code" ]] || code="DDB025_RUNTIME_DECISION_ENGINE_ERROR"
            [[ -n "$message" ]] || message="Policy preflight denied."
            log_error "Skill '$skill_id' failed deny-by-default preflight [$code]: $message"
            if [[ -n "$hint" ]]; then
                log_info "  remediation: $hint"
            fi
            return 1
            ;;
        *)
            log_error "Policy engine preflight failed for '$skill_id': $output"
            return 1
            ;;
    esac
}

# Extract skill IDs from manifest
get_manifest_skills() {
    grep -E "^\s*- id:" "$MANIFEST" | sed 's/.*id:\s*//' | tr -d '"' | tr -d "'" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# Get display_name for a skill from manifest
get_manifest_display_name() {
    local skill_id="$1"
    # Find the skill entry and extract display_name
    awk -v id="$skill_id" '
        $1 == "-" && $2 == "id:" {
            if (found) {exit}
            if ($3 == id) {found=1; next}
        }
        found && /display_name:/ {gsub(/.*display_name:\s*/, ""); gsub(/["'"'"']/, ""); gsub(/^[[:space:]]+|[[:space:]]+$/, ""); print; exit}
    ' "$MANIFEST"
}

# Get status for a skill from manifest
get_manifest_status() {
    local skill_id="$1"
    awk -v id="$skill_id" '
        $1 == "-" && $2 == "id:" {
            if (found) {exit}
            if ($3 == id) {found=1; next}
        }
        found && /status:/ {
            gsub(/.*status:[[:space:]]*/, "")
            gsub(/["'"'"']/, "")
            gsub(/^[[:space:]]+|[[:space:]]+$/, "")
            print
            exit
        }
    ' "$MANIFEST"
}

get_manifest_skill_class() {
    local skill_id="$1"
    awk -v id="$skill_id" '
        $1 == "-" && $2 == "id:" {
            if (found) {exit}
            if ($3 == id) {found=1; next}
        }
        found && /skill_class:/ {
            gsub(/.*skill_class:[[:space:]]*/, "")
            gsub(/["'"'"']/, "")
            gsub(/^[[:space:]]+|[[:space:]]+$/, "")
            print
            exit
        }
    ' "$MANIFEST"
}

# Validate manifest status values in strict mode
validate_manifest_status_value() {
    local skill_id="$1"
    local status
    status=$(get_manifest_status "$skill_id")

    if [[ -z "$status" ]]; then
        log_error "Strict mode: missing status for skill '$skill_id' in manifest.yml"
        return 1
    fi

    if ! contains "$status" "${VALID_MANIFEST_STATUSES[@]}"; then
        log_error "Strict mode: invalid status '$status' for skill '$skill_id' (expected: active|deprecated|experimental|draft)"
        return 1
    fi

    log_success "Strict mode: manifest status is valid ($status)"
    return 0
}

# Extract parameter.type values from registry for a skill
get_registry_parameter_types() {
    local skill_id="$1"
    awk -v skill="$skill_id" '
        /^skills:/ {in_skills=1; next}
        in_skills && $0 ~ "^  "skill":" {found=1; next}
        found && /^  [a-z]/ && $0 !~ "^  "skill":" {exit}
        found && /parameters:/ {in_params=1; next}
        found && in_params && /^    [a-z]/ && !/^      / {exit}
        found && in_params && /^        type:/ {
            gsub(/^        type:[[:space:]]*/, "")
            gsub(/["'"'"']/, "")
            print
        }
    ' "$REGISTRY"
}

get_registry_parameter_names() {
    local skill_id="$1"
    awk -v skill="$skill_id" '
        /^skills:/ {in_skills=1; next}
        in_skills && $0 ~ "^  "skill":" {found=1; next}
        found && /^  [a-z0-9][a-z0-9-]*:/ && $0 !~ "^  "skill":" {exit}
        found && /parameters:/ {in_params=1; next}
        found && in_params && /^      - name:/ {
            gsub(/^      - name:[[:space:]]*/, "")
            gsub(/["'"'"']/, "")
            print
        }
        found && in_params && /^    [a-z]/ && !/^      / {exit}
    ' "$REGISTRY"
}

get_registry_command_count() {
    local skill_id="$1"
    awk -v skill="$skill_id" '
        /^skills:/ {in_skills=1; next}
        in_skills && $0 ~ "^  "skill":" {found=1; next}
        found && /^  [a-z0-9][a-z0-9-]*:/ && $0 !~ "^  "skill":" {exit}
        found && /commands:/ {in_commands=1; next}
        found && in_commands && /^      - / {count++; next}
        found && in_commands && /^    [a-z]/ && !/^      / {print count + 0; printed=1; exit}
        END {
            if (found && !printed) {
                print count + 0
            }
        }
    ' "$REGISTRY"
}

# Validate parameter.type values in strict mode
validate_registry_parameter_types() {
    local skill_id="$1"
    local issues=0
    local invalid_types=()
    local param_type

    while IFS= read -r param_type; do
        [[ -z "$param_type" ]] && continue
        if ! contains "$param_type" "${VALID_PARAMETER_TYPES[@]}"; then
            invalid_types+=("$param_type")
            ((issues++)) || true
        fi
    done < <(get_registry_parameter_types "$skill_id")

    if [[ $issues -gt 0 ]]; then
        log_error "Strict mode: invalid parameter type(s) for '$skill_id': ${invalid_types[*]} (expected: text|boolean|file|folder)"
        return 1
    fi

    log_success "Strict mode: registry parameter types are valid"
    return 0
}

# Extract io.outputs[].determinism values from registry for a skill
get_registry_output_determinism_values() {
    local skill_id="$1"
    awk -v skill="$skill_id" '
        /^skills:/ {in_skills=1; next}
        in_skills && $0 ~ "^  "skill":" {found=1; next}
        found && /^  [a-z]/ && $0 !~ "^  "skill":" {exit}
        found && /outputs:/ {in_outputs=1; next}
        found && in_outputs && /^    [a-z]/ && !/^      / {exit}
        found && in_outputs && /determinism:/ {
            gsub(/.*determinism:[[:space:]]*/, "")
            gsub(/["'"'"']/, "")
            print
        }
    ' "$REGISTRY"
}

# Validate io.outputs[].determinism values in strict mode
validate_registry_output_determinism() {
    local skill_id="$1"
    local issues=0
    local invalid_values=()
    local determinism

    while IFS= read -r determinism; do
        [[ -z "$determinism" ]] && continue
        if ! contains "$determinism" "${VALID_OUTPUT_DETERMINISM[@]}"; then
            invalid_values+=("$determinism")
            ((issues++)) || true
        fi
    done < <(get_registry_output_determinism_values "$skill_id")

    if [[ $issues -gt 0 ]]; then
        log_error "Strict mode: invalid output determinism value(s) for '$skill_id': ${invalid_values[*]} (expected: stable|variable|unique)"
        return 1
    fi

    log_success "Strict mode: output determinism values are valid"
    return 0
}

# Get manifest path for a skill (authoritative for grouped directories)
# Returns path relative to SKILLS_DIR (e.g., "synthesis/refine-prompt/")
# Falls back to "<skill_id>/" if no manifest path is found.
get_skill_path() {
    local skill_id="$1"
    local skill_path
    skill_path=$(awk -v id="$skill_id" '
        $1 == "-" && $2 == "id:" && $3 == id {found=1; next}
        found && $1 == "path:" {gsub(/["'"'"']/, "", $2); print $2; exit}
        found && $1 == "-" && $2 == "id:" {exit}
    ' "$MANIFEST")

    if [[ -n "$skill_path" ]]; then
        echo "$skill_path"
    else
        echo "${skill_id}/"
    fi
}

# Get manifest group for a skill. Falls back to first path segment.
get_skill_group() {
    local skill_id="$1"
    local skill_group
    skill_group=$(awk -v id="$skill_id" '
        $1 == "-" && $2 == "id:" && $3 == id {found=1; next}
        found && $1 == "group:" {gsub(/["'"'"']/, "", $2); print $2; exit}
        found && $1 == "-" && $2 == "id:" {exit}
    ' "$MANIFEST")

    if [[ -n "$skill_group" ]]; then
        echo "$skill_group"
        return
    fi

    local skill_path
    skill_path=$(get_skill_path "$skill_id")
    echo "${skill_path%%/*}"
}

# Convert skill id (kebab-case) to expected Title Case display_name
# Example: "synthesize-research" -> "Synthesize Research"
id_to_title_case() {
    local skill_id="$1"
    echo "$skill_id" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1'
}

# Validate display_name matches skill id words (case-insensitive)
# Returns 0 if valid, 1 if invalid with message to stdout
validate_display_name() {
    local skill_id="$1"
    local display_name="$2"

    if [[ -z "$display_name" ]]; then
        echo "display_name is missing"
        return 1
    fi

    local expected_name
    expected_name=$(id_to_title_case "$skill_id")

    local expected_norm
    expected_norm=$(echo "$skill_id" | tr '-' ' ' | tr '[:upper:]' '[:lower:]' | xargs)
    local display_norm
    display_norm=$(echo "$display_name" | tr '[:upper:]' '[:lower:]' | xargs)

    if [[ "$display_norm" != "$expected_norm" ]]; then
        echo "display_name '$display_name' does not match expected words '$expected_name'"
        return 1
    fi

    return 0
}

# Get triggers for a skill from manifest
get_skill_triggers() {
    local skill_id="$1"
    # Extract triggers array for a skill
    awk -v id="$skill_id" '
        $1 == "-" && $2 == "id:" {
            if (found) {exit}
            if ($3 == id) {found=1; next}
        }
        found && /triggers:/ {in_triggers=1; next}
        found && in_triggers && /^      - / {gsub(/^      - ["'"'"']?/, ""); gsub(/["'"'"']$/, ""); print}
        found && in_triggers && /^    [a-z]/ {exit}
    ' "$MANIFEST"
}

# Parse a YAML inline list into newline-delimited values.
# Example: "[executor, guardian]" -> executor\nguardian
parse_inline_yaml_list() {
    local raw="$1"

    raw="${raw#[}"
    raw="${raw%]}"
    raw="${raw//\"/}"
    raw="${raw//\'/}"

    IFS=',' read -ra items <<< "$raw"
    local item
    for item in "${items[@]}"; do
        item="$(echo "$item" | xargs)"
        [[ -n "$item" ]] && echo "$item"
    done
}

# Get an array field from SKILL.md frontmatter.
# Supports inline arrays (field: [a, b]) and block arrays:
# field:
#   - a
#   - b
get_skill_frontmatter_array() {
    local skill_dir="$1"
    local field="$2"
    local skill_md="$skill_dir/SKILL.md"
    if [[ ! -f "$skill_md" ]]; then
        return
    fi

    awk -v key="$field" '
        NR == 1 && /^---/ {in_frontmatter=1; next}
        in_frontmatter && /^---/ {exit}

        in_frontmatter && $0 ~ "^"key":[[:space:]]*\\[" {
            line = $0
            sub("^"key":[[:space:]]*\\[", "", line)
            sub("\\][[:space:]]*$", "", line)
            print line
            exit
        }

        in_frontmatter && $0 ~ "^"key":[[:space:]]*$" {
            in_list=1
            next
        }

        in_frontmatter && in_list {
            if ($0 ~ /^[[:space:]]*-[[:space:]]*/) {
                line = $0
                sub(/^[[:space:]]*-[[:space:]]*/, "", line)
                gsub(/["'\'']/, "", line)
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
                if (length(line) > 0) print line
                next
            }

            if ($0 ~ /^[a-zA-Z_][a-zA-Z0-9_-]*:/) {
                exit
            }
        }
    ' "$skill_md" | {
        IFS= read -r first_line || true
        if [[ -n "$first_line" ]] && [[ "$first_line" == *","* ]]; then
            parse_inline_yaml_list "$first_line"
        elif [[ -n "$first_line" ]]; then
            echo "$first_line"
            cat
        fi
    }
}

# Get an array field from manifest for a specific skill.
# Supports inline arrays and block arrays.
get_manifest_skill_array() {
    local skill_id="$1"
    local field="$2"

    awk -v id="$skill_id" -v key="$field" '
        $1 == "-" && $2 == "id:" {
            if (found) {exit}
            if ($3 == id) {found=1; next}
        }

        found && $0 ~ "^    "key":[[:space:]]*\\[" {
            line = $0
            sub("^    "key":[[:space:]]*\\[", "", line)
            sub("\\][[:space:]]*$", "", line)
            print line
            exit
        }

        found && $0 ~ "^    "key":[[:space:]]*$" {
            in_list=1
            next
        }

        found && in_list && /^      - / {
            line = $0
            sub(/^      - /, "", line)
            gsub(/["'\'']/, "", line)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
            if (length(line) > 0) print line
            next
        }

        found && in_list && /^    [a-z]/ {exit}
        found && $1 == "-" && $2 == "id:" {exit}
    ' "$MANIFEST" | {
        IFS= read -r first_line || true
        if [[ -n "$first_line" ]] && [[ "$first_line" == *","* ]]; then
            parse_inline_yaml_list "$first_line"
        elif [[ -n "$first_line" ]]; then
            echo "$first_line"
            cat
        fi
    }
}

# Normalize newline-delimited values into a deterministic CSV representation.
normalize_list_values() {
    local values="$1"
    if [[ -z "$values" ]]; then
        echo ""
        return
    fi

    echo "$values" | sed '/^[[:space:]]*$/d' | sort -u | paste -sd',' -
}

# Returns 0 if value is present in the provided array, 1 otherwise.
array_contains() {
    local value="$1"
    shift
    local item
    for item in "$@"; do
        if [[ "$item" == "$value" ]]; then
            return 0
        fi
    done
    return 1
}

# Extract skill IDs from registry
get_registry_skills() {
    # Look for skill IDs under the skills: section (indented entries that aren't nested)
    awk '/^skills:/{found=1; next} found && /^  [a-z]/ && !/^  [a-z].*:.*:/{gsub(/:.*/, ""); gsub(/^  /, ""); print}' "$REGISTRY"
}

# Get SKILL.md name field
get_skill_name() {
    local skill_dir="$1"
    local skill_md="$skill_dir/SKILL.md"
    if [[ -f "$skill_md" ]]; then
        grep -E "^name:" "$skill_md" | head -1 | sed 's/name:\s*//' | tr -d '"' | tr -d "'" | xargs
    fi
}

# Get tool permissions for a skill (from SKILL.md allowed-tools)
# This is the single source of truth for tool permissions
get_skill_tools() {
    local skill_dir="$1"
    get_internal_tools_from_skill "$skill_dir"
}

# ============================================================================
# Tool Permission Mapping Functions
# ============================================================================
# These functions convert between allowed-tools (agentskills.io spec format)
# and the internal registry format used by Octon routing.
#
# allowed-tools in SKILL.md is the SINGLE SOURCE OF TRUTH for tool permissions.
# ============================================================================

# Mapping table: allowed-tools (SKILL.md) -> internal format
# This is the authoritative mapping used for routing and validation.
#
# | allowed-tools (SKILL.md)   | Internal Format           | Description              |
# |----------------------------|---------------------------|--------------------------|
# | Read                       | filesystem.read           | Read files               |
# | Edit                       | filesystem.edit           | Edit files in-place      |
# | Write(_ops/state/runs/*)              | filesystem.write.runs     | Write execution state (session recovery) |
# | Write(_ops/state/logs/*)              | filesystem.write.logs     | Write to logs dir        |
# | Write(../{category}/*)     | filesystem.write.deliverables | Write deliverables   |
# | Write(...)                 | filesystem.write.scoped   | Write to explicit scoped path |
# | Glob                       | filesystem.glob           | Pattern file discovery   |
# | Grep                       | filesystem.grep           | Content search           |
# | WebFetch                   | network.fetch             | HTTP requests (read)     |
# | WebSearch                  | network.search            | HTTP search              |
# | Bash / Bash(...)           | shell.execute             | Execute shell commands   |
# | Shell                      | shell.execute             | Execute shell commands   |
# | Task                       | agent.task                | Launch subagent tasks    |

# Convert a single allowed-tools entry to internal format
# Usage: map_allowed_to_internal "Read" -> "filesystem.read"
map_allowed_to_internal() {
    local allowed="$1"
    case "$allowed" in
        Read)                    echo "filesystem.read" ;;
        Edit)                    echo "filesystem.edit" ;;
        Write)                   echo "filesystem.write" ;;
        Write\(_ops/state/runs/\*\))        echo "filesystem.write.runs" ;;
        Write\(_ops/state/logs/\*\))        echo "filesystem.write.logs" ;;
        Write\(../*\))           echo "filesystem.write.deliverables" ;;
        Write\(*\))              echo "filesystem.write.scoped" ;;
        Glob)                    echo "filesystem.glob" ;;
        Grep)                    echo "filesystem.grep" ;;
        WebFetch)                echo "network.fetch" ;;
        WebSearch)               echo "network.search" ;;
        Bash)                    echo "shell.execute" ;;
        Bash\(*\))               echo "shell.execute" ;;
        Shell)                   echo "shell.execute" ;;
        Task)                    echo "agent.task" ;;
        *)                       echo "" ;;  # Unknown mapping
    esac
}

# Extract tool pack IDs from tools manifest.
get_tool_pack_ids() {
    if [[ ! -f "$TOOLS_MANIFEST" ]]; then
        return
    fi

    awk '
        /^packs:/ {in_packs=1; next}
        /^tools:/ {in_packs=0}
        in_packs && /^[[:space:]]*- id:/ {
            id=$3
            gsub(/["'\'' ]/, "", id)
            print id
        }
    ' "$TOOLS_MANIFEST"
}

# Extract tools in a specific tool pack.
get_tool_pack_tools() {
    local pack_id="$1"
    if [[ ! -f "$TOOLS_MANIFEST" ]]; then
        return
    fi

    awk -v target="$pack_id" '
        /^packs:/ {in_packs=1; next}
        /^tools:/ {if (found) exit; in_packs=0}
        in_packs && /^[[:space:]]*- id:/ {
            id=$3
            gsub(/["'\'' ]/, "", id)
            found=(id==target)
            next
        }
        found && /tools:[[:space:]]*\[/ {
            line=$0
            sub(/.*tools:[[:space:]]*\[/, "", line)
            sub(/\].*/, "", line)
            gsub(/["'\'']/, "", line)

            n=split(line, arr, ",")
            for (i=1; i<=n; i++) {
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", arr[i])
                if (arr[i] != "") print arr[i]
            }
            exit
        }
    ' "$TOOLS_MANIFEST"
}

# Returns 0 when the provided pack id exists, 1 otherwise.
tool_pack_exists() {
    local pack_id="$1"
    if [[ ! -f "$TOOLS_MANIFEST" ]]; then
        return 1
    fi
    grep -q "^[[:space:]]*- id:[[:space:]]*${pack_id}[[:space:]]*$" "$TOOLS_MANIFEST"
}

# Convert all allowed-tools from SKILL.md to internal format
# Usage: get_internal_tools_from_skill "/path/to/skill"
# Returns space-separated list of internal tool names
get_internal_tools_from_skill() {
    local skill_dir="$1"
    
    local internal_tools=""
    while IFS= read -r allowed; do
        [[ -z "$allowed" ]] && continue
        if [[ "$allowed" == pack:* ]]; then
            local pack_id="${allowed#pack:}"
            while IFS= read -r expanded; do
                [[ -z "$expanded" ]] && continue
                local mapped_pack
                mapped_pack=$(map_allowed_to_internal "$expanded")
                if [[ -n "$mapped_pack" ]]; then
                    internal_tools="$internal_tools $mapped_pack"
                fi
            done < <(get_tool_pack_tools "$pack_id")
            continue
        fi

        local mapped
        mapped=$(map_allowed_to_internal "$allowed")
        if [[ -n "$mapped" ]]; then
            internal_tools="$internal_tools $mapped"
        fi
    done < <(get_skill_allowed_tools "$skill_dir")
    echo "$internal_tools" | tr ' ' '\n' | sed '/^[[:space:]]*$/d' | sort -u | xargs
}

# Validate allowed-tools format
# Returns 0 if valid, 1 if invalid with error message
validate_allowed_tools_format() {
    local skill_dir="$1"
    local has_tools=false
    
    local invalid=""
    while IFS= read -r allowed; do
        [[ -z "$allowed" ]] && continue
        has_tools=true

        if [[ "$allowed" == pack:* ]]; then
            local pack_id="${allowed#pack:}"
            if [[ ! -f "$TOOLS_MANIFEST" ]]; then
                invalid="${invalid}${allowed} (tools manifest missing), "
                continue
            fi

            if ! tool_pack_exists "$pack_id"; then
                invalid="${invalid}${allowed} (unknown pack), "
                continue
            fi

            local has_pack_members=false
            while IFS= read -r expanded; do
                [[ -z "$expanded" ]] && continue
                has_pack_members=true
                local expanded_mapped
                expanded_mapped=$(map_allowed_to_internal "$expanded")
                if [[ -z "$expanded_mapped" ]]; then
                    invalid="${invalid}${allowed}->${expanded} (unknown tool), "
                fi
            done < <(get_tool_pack_tools "$pack_id")

            if [[ "$has_pack_members" != "true" ]]; then
                invalid="${invalid}${allowed} (empty pack), "
            fi
            continue
        fi

        local mapped
        mapped=$(map_allowed_to_internal "$allowed")
        if [[ -z "$mapped" ]]; then
            invalid="${invalid}${allowed}, "
        fi
    done < <(get_skill_allowed_tools "$skill_dir")

    if [[ "$has_tools" != "true" ]]; then
        echo "allowed-tools not found in SKILL.md frontmatter"
        return 1
    fi
    
    if [[ -n "$invalid" ]]; then
        echo "Unknown tools: ${invalid%, }"
        return 1
    fi
    
    return 0
}

# Legacy alias for backwards compatibility
map_allowed_to_registry() {
    map_allowed_to_internal "$1"
}

# Split allowed-tools value by spaces outside parentheses.
# Example:
#   "Read Bash(vercel *) Write(_ops/state/logs/*)"
# becomes tokens:
#   Read
#   Bash(vercel *)
#   Write(_ops/state/logs/*)
split_allowed_tools() {
    local raw="$1"
    local token=""
    local depth=0
    local ch
    local i

    for ((i=0; i<${#raw}; i++)); do
        ch="${raw:i:1}"

            case "$ch" in
                "(")
                depth=$((depth + 1))
                token+="$ch"
                ;;
                ")")
                if [[ $depth -gt 0 ]]; then
                    depth=$((depth - 1))
                fi
                token+="$ch"
                ;;
            " " | $'\t')
                if [[ $depth -eq 0 ]]; then
                    if [[ -n "$token" ]]; then
                        echo "$token"
                        token=""
                    fi
                else
                    token+="$ch"
                fi
                ;;
            *)
                token+="$ch"
                ;;
        esac
    done

    if [[ -n "$token" ]]; then
        echo "$token"
    fi
}

# Get allowed-tools from SKILL.md frontmatter
get_skill_allowed_tools() {
    local skill_dir="$1"
    local skill_md="$skill_dir/SKILL.md"
    if [[ -f "$skill_md" ]]; then
        # Extract allowed-tools line and split by spaces outside parentheses.
        local raw
        raw=$(grep -E "^allowed-tools:" "$skill_md" | head -1 | sed 's/allowed-tools:[[:space:]]*//')
        split_allowed_tools "$raw"
    fi
}

# Returns 0 when any Bash permission exceeds harness-minimal file operations.
has_non_minimal_bash_permissions() {
    local skill_dir="$1"
    local allowed

    while IFS= read -r allowed; do
        [[ -z "$allowed" ]] && continue
        if [[ "$allowed" == "Bash" ]]; then
            return 0
        fi
        if [[ "$allowed" =~ ^Bash\((.*)\)$ ]]; then
            local command_scope="${BASH_REMATCH[1]}"
            case "$command_scope" in
                mkdir|cp|mv|ln)
                    ;;
                *)
                    return 0
                    ;;
            esac
        fi
    done < <(get_skill_allowed_tools "$skill_dir")

    return 1
}

# Returns 0 when any Write(...) scope is broad (contains **), 1 otherwise.
skill_has_broad_write_scope() {
    local skill_dir="$1"
    local allowed

    while IFS= read -r allowed; do
        [[ -z "$allowed" ]] && continue
        if [[ "$allowed" =~ ^Write\((.*)\)$ ]]; then
            local write_scope="${BASH_REMATCH[1]}"
            if [[ "$write_scope" == *"**"* ]]; then
                return 0
            fi
        fi
    done < <(get_skill_allowed_tools "$skill_dir")

    return 1
}

# Returns 0 when manifest capabilities explicitly acknowledge external dependencies.
declares_external_dependency_capability() {
    local skill_id="$1"
    local capability
    while IFS= read -r capability; do
        case "$capability" in
            external-dependent|external-output)
                return 0
                ;;
        esac
    done < <(get_manifest_skill_array "$skill_id" "capabilities")
    return 1
}

# Split allowed-services value by spaces.
split_allowed_services() {
    local raw="$1"
    local item
    for item in $raw; do
        [[ -n "$item" ]] && echo "$item"
    done
}

# Get allowed-services from SKILL.md frontmatter.
get_skill_allowed_services() {
    local skill_dir="$1"
    local skill_md="$skill_dir/SKILL.md"
    if [[ -f "$skill_md" ]]; then
        local raw
        raw=$(grep -E "^allowed-services:" "$skill_md" | head -1 | sed 's/allowed-services:[[:space:]]*//')
        if [[ -z "$raw" ]]; then
            return
        fi

        if [[ "$raw" == \[*\] ]]; then
            parse_inline_yaml_list "$raw"
        else
            split_allowed_services "$raw"
        fi
    fi
}

# Extract service IDs from services manifest.
get_service_ids() {
    if [[ ! -f "$SERVICES_MANIFEST" ]]; then
        return
    fi

    awk '
        /^services:/ {in_services=1; next}
        in_services && /^[[:space:]]*- id:/ {
            id=$3
            gsub(/["'\'' ]/, "", id)
            print id
        }
    ' "$SERVICES_MANIFEST"
}

# Validate allowed-services in SKILL.md.
# Returns 0 when absent or valid, 1 when invalid.
validate_allowed_services() {
    local skill_id="$1"
    local skill_dir="$2"
    local skill_md="$skill_dir/SKILL.md"

    if [[ ! -f "$skill_md" ]]; then
        echo "SKILL.md not found"
        return 1
    fi

    if ! grep -q "^allowed-services:" "$skill_md"; then
        return 0
    fi

    if [[ ! -f "$SERVICES_MANIFEST" ]]; then
        echo "allowed-services declared but services manifest is missing"
        return 1
    fi

    local service_ids
    mapfile -t service_ids < <(get_service_ids)
    if [[ ${#service_ids[@]} -eq 0 ]]; then
        echo "services manifest contains no service ids"
        return 1
    fi

    local invalid=""
    local allowed_service
    while IFS= read -r allowed_service; do
        [[ -z "$allowed_service" ]] && continue
        if ! contains "$allowed_service" "${service_ids[@]}"; then
            invalid="${invalid}${allowed_service}, "
        fi
    done < <(get_skill_allowed_services "$skill_dir")

    if [[ -n "$invalid" ]]; then
        echo "Unknown services: ${invalid%, }"
        return 1
    fi

    return 0
}

# Validate allowed-tools in SKILL.md
# Prints issues to stdout, returns 0 if valid, 1 if invalid
# allowed-tools is the SINGLE SOURCE OF TRUTH for tool permissions
validate_allowed_tools() {
    local skill_id="$1"
    local skill_dir="$2"
    
    # Check that allowed-tools exists and is valid
    local validation_result
    validation_result=$(validate_allowed_tools_format "$skill_dir" 2>&1)
    local validation_status=$?
    
    if [[ $validation_status -ne 0 ]]; then
        echo "$validation_result"
        return 1
    fi
    
    # Get the internal tool list for informational purposes
    local internal_tools
    internal_tools=$(get_skill_tools "$skill_dir")
    
    if [[ -z "$internal_tools" ]]; then
        echo "No valid tools found in allowed-tools"
        return 1
    fi
    
    return 0
}

# Check if io-contract.md has requires.tools (drift issue)
check_io_contract_drift() {
    local skill_dir="$1"
    local io_contract="$skill_dir/references/io-contract.md"
    if [[ -f "$io_contract" ]]; then
        # Check for requires.tools in YAML frontmatter
        if grep -q "^requires:" "$io_contract" 2>/dev/null; then
            # Check if it's just a comment or actual data
            if grep -A5 "^requires:" "$io_contract" | grep -q "tools:" 2>/dev/null; then
                return 1  # Found drift
            fi
        fi
    fi
    return 0  # No drift
}

# Check if safety.md has allowed tools list (drift issue)
check_safety_drift() {
    local skill_dir="$1"
    local safety_md="$skill_dir/references/safety.md"
    if [[ -f "$safety_md" ]]; then
        # Check for allowed: list with actual tools (not just comments)
        if awk '/^safety:/,/^---/' "$safety_md" | grep -q "^\s*allowed:" 2>/dev/null; then
            # Check if there are actual tool entries under allowed
            if awk '/allowed:/,/file_policy:/' "$safety_md" | grep -q "^\s*- filesystem\." 2>/dev/null; then
                return 1  # Found drift
            fi
        fi
    fi
    return 0  # No drift
}

# Check for duplicated parameter/tool tables in markdown files (human-readable drift)
check_table_drift() {
    local skill_dir="$1"
    local file="$2"
    local filepath="$skill_dir/$file"
    
    if [[ ! -f "$filepath" ]]; then
        return 0  # File doesn't exist, no drift
    fi
    
    # Check for parameter tables with | Parameter | or | Tool | headers after "source of truth" notes
    # This indicates duplicated data that could drift from the authoritative source
    if grep -q "| Parameter |" "$filepath" 2>/dev/null || grep -q "| Tool |.*| Purpose |" "$filepath" 2>/dev/null; then
        # Check if the table appears after a "source of truth" reference
        if grep -B5 "| Parameter \|" "$filepath" 2>/dev/null | grep -qi "source of truth" 2>/dev/null; then
            return 1  # Found potential drift
        fi
        if grep -B5 "| Tool |" "$filepath" 2>/dev/null | grep -qi "source of truth" 2>/dev/null; then
            return 1  # Found potential drift
        fi
    fi
    return 0  # No drift detected
}

# Check if a skill declares deprecated top-level outputs in registry.yml.
# Valid output declarations live under skills.<id>.io.outputs.
check_deprecated_top_level_outputs() {
    local skill_id="$1"
    # Check only for skills.<id>.outputs (top-level in skill block).
    # Do NOT match skills.<id>.io.outputs.
    awk -v skill="$skill_id" '
        /^skills:/ {in_skills=1; next}
        in_skills && /^[a-z0-9_-]+:/ && $0 !~ /^skills:/ {exit}
        in_skills && $0 ~ "^  "skill":" {in_skill=1; next}
        in_skill && /^  [a-z0-9][a-z0-9-]*:/ && $0 !~ "^  "skill":" {exit}
        in_skill && /^    outputs:/ {print "found"; exit}
    ' "$REGISTRY" | grep -q "found"
}

# Check if skills registry has I/O mappings for a skill
check_io_mappings() {
    local skill_id="$1"
    if [[ ! -f "$SKILLS_REGISTRY" ]]; then
        return 1  # No skills registry
    fi
    # Check if skills.<skill_id>.io exists
    awk -v skill="$skill_id" '
        /^skills:/ {in_skills=1; next}
        in_skills && $0 ~ "^  "skill":" {found=1; next}
        found && /^  [a-z0-9][a-z0-9-]*:/ && $0 !~ "^  "skill":" {exit}
        found && /^    io:/ {has_io=1; exit}
        END {exit !has_io}
    ' "$SKILLS_REGISTRY" 2>/dev/null
}

# ============================================================================
# I/O Path Scope Validation
# ============================================================================
# Validates that output paths in skills registry remain within the repo-root harness scope.
# Paths must not escape the repository boundary.

# Get output paths for a skill from skills registry
get_output_paths() {
    local skill_id="$1"
    if [[ ! -f "$SKILLS_REGISTRY" ]]; then
        return
    fi
    # Extract output paths from skills.<skill_id>.io.outputs
    awk -v skill="$skill_id" '
        /^skills:/ {in_skills=1; next}
        in_skills && $0 ~ "^  "skill":" {in_skill=1; next}
        in_skill && /^  [a-z0-9][a-z0-9-]*:/ && $0 !~ "^  "skill":" {exit}
        in_skill && /^    io:/ {in_io=1; next}
        in_skill && in_io && /^    [a-z]/ && !/^    io:/ {in_io=0}
        in_skill && in_io && /^      outputs:/ {in_outputs=1; next}
        in_skill && in_io && in_outputs && /^      [a-z]/ && !/^      outputs:/ {in_outputs=0}
        in_skill && in_io && in_outputs && /^          path:/ {
            line = $0
            sub(/^          path:[[:space:]]*["'"'"']?/, "", line)
            sub(/["'"'"']?[[:space:]]*$/, "", line)
            print line
        }
    ' "$SKILLS_REGISTRY"
}

# Validate that a path is within harness scope
# Deliverables may target .octon/output/, .octon/scaffolding/, or .octon/continuity/
# from skill-local paths (../../...).
normalize_path_lexical() {
    local input_path="$1"

    local is_abs=false
    if [[ "$input_path" == /* ]]; then
        is_abs=true
    fi

    local -a parts
    local IFS='/'
    read -ra parts <<< "$input_path"

    local -a stack=()
    local part
    for part in "${parts[@]}"; do
        [[ -z "$part" || "$part" == "." ]] && continue

        if [[ "$part" == ".." ]]; then
            if [[ ${#stack[@]} -gt 0 ]]; then
                unset 'stack[${#stack[@]}-1]'
            else
                return 1
            fi
            continue
        fi

        stack+=("$part")
    done

    local joined
    joined=$(IFS=/; echo "${stack[*]}")
    if [[ "$is_abs" == "true" ]]; then
        echo "/$joined"
    else
        echo "$joined"
    fi
}

validate_path_scope() {
    local path="$1"
    local workspace_root="$2"

    local skills_root="${workspace_root%/}"
    local octon_root="$REPO_ROOT/.octon"

    local resolved_input
    if [[ "$path" == /* ]]; then
        resolved_input="$path"
    else
        resolved_input="$skills_root/$path"
    fi

    local resolved_path
    resolved_path=$(normalize_path_lexical "$resolved_input")
    if [[ $? -ne 0 ]] || [[ -z "$resolved_path" ]]; then
        echo "Path escapes harness scope: $path"
        return 1
    fi

    if [[ "$resolved_path" != "$octon_root" ]] && [[ "$resolved_path" != "$octon_root/"* ]]; then
        echo "Path escapes .octon scope: $path"
        return 1
    fi

    if [[ "$path" == ../../* ]]; then
        if [[ "$resolved_path" == "$octon_root/output/"* ]] || \
           [[ "$resolved_path" == "$octon_root/scaffolding/"* ]] || \
           [[ "$resolved_path" == "$octon_root/continuity/"* ]]; then
            return 0
        fi
        echo "Path outside allowed deliverable scope (.octon/output|scaffolding|continuity): $path"
        return 1
    fi

    if [[ "$path" == ../* ]] || [[ "$path" == */../* ]]; then
        echo "Relative parent traversal is not allowed: $path"
        return 1
    fi

    if [[ "$path" != /* ]]; then
        if [[ "$resolved_path" != "$skills_root" ]] && [[ "$resolved_path" != "$skills_root/"* ]]; then
            echo "Path outside skills scope: $path"
            return 1
        fi
    fi

    return 0
}

# Validate all output paths for a skill
validate_skill_io_scope() {
    local skill_id="$1"
    local issues=0
    
    while IFS= read -r output_path; do
        if [[ -n "$output_path" ]]; then
            local validation_result
            validation_result=$(validate_path_scope "$output_path" "$REPO_ROOT/.octon/capabilities/runtime/skills/")
            if [[ -n "$validation_result" ]]; then
                log_error "Skill '$skill_id': $validation_result"
                ((issues++)) || true
            fi
        fi
    done < <(get_output_paths "$skill_id")
    
    return $issues
}

# ============================================================================
# Placeholder Format Validation
# ============================================================================
# Validates that path placeholders in skills registry use correct format.
# Valid format: {{snake_case}} (e.g., {{timestamp}}, {{project}}, {{topic}})
# Invalid formats: <placeholder>, {placeholder}, {{ spaces }}

# Valid placeholder pattern: {{word}} or {{word_word}}
PLACEHOLDER_PATTERN='\{\{[a-z][a-z0-9_]*\}\}'

# Get all placeholders from a path
extract_placeholders() {
    local path="$1"
    echo "$path" | grep -oE '\{\{[^}]+\}\}' | sort -u
}

# Validate a single placeholder format
validate_placeholder_format() {
    local placeholder="$1"

    # Check for correct {{snake_case}} format
    if [[ "$placeholder" =~ ^\{\{[a-z][a-z0-9_]*\}\}$ ]]; then
        return 0  # Valid
    fi

    # Check for common invalid formats
    if [[ "$placeholder" =~ ^\{\{[[:space:]] ]] || [[ "$placeholder" =~ [[:space:]]\}\}$ ]]; then
        echo "Placeholder has spaces: $placeholder (should be {{snake_case}})"
        return 1
    fi

    if [[ "$placeholder" =~ ^\{\{[A-Z] ]]; then
        echo "Placeholder uses uppercase: $placeholder (should be {{snake_case}})"
        return 1
    fi

    if [[ "$placeholder" =~ ^\{\{[0-9] ]]; then
        echo "Placeholder starts with number: $placeholder (should start with letter)"
        return 1
    fi

    echo "Invalid placeholder format: $placeholder (expected {{snake_case}})"
    return 1
}

# Validate all placeholders in registry paths for a skill
validate_skill_placeholders() {
    local skill_id="$1"
    local issues=0
    local parameter_names=()

    mapfile -t parameter_names < <(get_registry_parameter_names "$skill_id")

    if [[ ! -f "$SKILLS_REGISTRY" ]]; then
        return 0
    fi

    # Get all paths (inputs and outputs) for this skill
    local paths
    paths=$(awk -v skill="$skill_id" '
        /^skills:/ {in_skills=1; next}
        in_skills && $0 ~ "^  "skill":" {in_skill=1; next}
        in_skill && /^  [a-z0-9][a-z0-9-]*:/ && $0 !~ "^  "skill":" {exit}
        in_skill && /^    io:/ {in_io=1; next}
        in_skill && in_io && /^    [a-z]/ && !/^    io:/ {in_io=0}
        in_skill && in_io && /path:/ {
            line = $0
            sub(/.*path:[[:space:]]*["'"'"']?/, "", line)
            sub(/["'"'"']?[[:space:]]*$/, "", line)
            print line
        }
    ' "$SKILLS_REGISTRY")

    while IFS= read -r path; do
        if [[ -n "$path" ]]; then
            # Extract and validate each placeholder
            while IFS= read -r placeholder; do
                if [[ -n "$placeholder" ]]; then
                    local validation_result
                    validation_result=$(validate_placeholder_format "$placeholder" 2>&1)
                    if [[ $? -ne 0 ]]; then
                        log_error "Path '$path': $validation_result"
                        ((issues++)) || true
                        continue
                    fi

                    local placeholder_name="${placeholder#\{\{}"
                    placeholder_name="${placeholder_name%\}\}}"
                    if ! array_contains "$placeholder_name" "${VALID_STANDARD_PLACEHOLDERS[@]}" \
                        && ! array_contains "$placeholder_name" "${parameter_names[@]}"; then
                        log_error "Path '$path': unresolved placeholder '$placeholder' is not a declared parameter or standard placeholder"
                        ((issues++)) || true
                    fi
                fi
            done < <(extract_placeholders "$path")
        fi
    done <<< "$paths"

    return $issues
}

# Check for deprecated placeholder formats (angle brackets, single braces)
check_deprecated_placeholder_formats() {
    local skill_id="$1"

    if [[ ! -f "$SKILLS_REGISTRY" ]]; then
        return 0
    fi

    # Check for <placeholder> format (deprecated)
    if awk -v skill="$skill_id" '
        /^skills:/ {in_skills=1; next}
        in_skills && $0 ~ "^  "skill":" {in_skill=1; next}
        in_skill && /^  [a-z0-9][a-z0-9-]*:/ && $0 !~ "^  "skill":" {exit}
        in_skill && /^    io:/ {in_io=1; next}
        in_skill && in_io && /^    [a-z]/ && !/^    io:/ {in_io=0}
        in_skill && in_io && /path:/ && /<[a-z_]+>/ {print; found_dep=1}
        END {exit !found_dep}
    ' "$SKILLS_REGISTRY" 2>/dev/null; then
        log_error "Deprecated <placeholder> format found (use {{placeholder}} instead)"
        return 1
    fi

    # Check for {placeholder} format (single braces - easy mistake)
    if awk -v skill="$skill_id" '
        /^skills:/ {in_skills=1; next}
        in_skills && $0 ~ "^  "skill":" {in_skill=1; next}
        in_skill && /^  [a-z0-9][a-z0-9-]*:/ && $0 !~ "^  "skill":" {exit}
        in_skill && /^    io:/ {in_io=1; next}
        in_skill && in_io && /^    [a-z]/ && !/^    io:/ {in_io=0}
        in_skill && in_io && /path:/ && /\{[a-z_]+\}/ && !/\{\{/ {print; found_dep=1}
        END {exit !found_dep}
    ' "$SKILLS_REGISTRY" 2>/dev/null; then
        log_error "Single-brace {placeholder} format found (use {{placeholder}} instead)"
        return 1
    fi

    return 0
}

# ============================================================================
# Token Budget Validation
# ============================================================================
# Validates that files stay within recommended token budgets.
#
# Token Counting Methods (in order of preference):
#   1. tiktoken (Python) - Accurate tokenization using cl100k_base encoding
#   2. Word count approximation - Fallback using words * 1.3
#
# The word count approximation may vary ±20% from actual tokenization.
# Install tiktoken for more accurate results: pip install tiktoken
# ============================================================================

# Check if tiktoken is available
TIKTOKEN_AVAILABLE=false
if command -v python3 &>/dev/null && python3 -c "import tiktoken" 2>/dev/null; then
    TIKTOKEN_AVAILABLE=true
fi

# Estimate token count using tiktoken (accurate)
estimate_tokens_tiktoken() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo 0
        return
    fi
    python3 -c "
import tiktoken
enc = tiktoken.get_encoding('cl100k_base')
with open('$file', 'r') as f:
    content = f.read()
print(len(enc.encode(content)))
" 2>/dev/null || echo 0
}

# Estimate token count from word count (fallback)
estimate_tokens_wordcount() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        echo 0
        return
    fi
    local word_count
    word_count=$(wc -w < "$file" | tr -d ' ')
    # Conservative estimate: tokens ≈ words * 1.3 (may vary ±20%)
    echo $(( word_count * 13 / 10 ))
}

# Estimate token count - uses tiktoken if available, otherwise word count
estimate_tokens() {
    local file="$1"
    if [[ "$TIKTOKEN_AVAILABLE" == "true" ]]; then
        estimate_tokens_tiktoken "$file"
    else
        estimate_tokens_wordcount "$file"
    fi
}

# Get manifest entry for a skill (for token counting)
get_manifest_entry_tokens() {
    local skill_id="$1"
    local temp_file
    temp_file=$(mktemp)
    
    # Extract the skill entry from manifest
    awk -v id="$skill_id" '
        $1 == "-" && $2 == "id:" {
            if (found) {exit}
            if ($3 == id) {found=1}
        }
        found {print}
    ' "$MANIFEST" > "$temp_file"
    
    estimate_tokens "$temp_file"
    rm -f "$temp_file"
}

# Validate token budgets for a skill
validate_token_budgets() {
    local skill_id="$1"
    local skill_dir="$2"
    local issues=0

    # Check SKILL.md token budget
    local skill_md="$skill_dir/SKILL.md"
    if [[ -f "$skill_md" ]]; then
        local skill_tokens
        skill_tokens=$(estimate_tokens "$skill_md")
        if [[ $skill_tokens -gt $SKILL_MD_TOKEN_BUDGET ]]; then
            log_warning "SKILL.md exceeds token budget (~$skill_tokens > $SKILL_MD_TOKEN_BUDGET tokens)"
            log_info "  Consider moving detailed content to references/"
            ((issues++)) || true
        else
            log_success "SKILL.md within token budget (~$skill_tokens tokens)"
        fi
    fi

    # Check manifest entry token budget
    local manifest_tokens
    manifest_tokens=$(get_manifest_entry_tokens "$skill_id")
    if [[ $manifest_tokens -gt $MANIFEST_ENTRY_TOKEN_BUDGET ]]; then
        log_warning "Manifest entry exceeds token budget (~$manifest_tokens > $MANIFEST_ENTRY_TOKEN_BUDGET tokens)"
        log_info "  Consider shortening summary or reducing triggers"
        ((issues++)) || true
    else
        log_success "Manifest entry within token budget (~$manifest_tokens tokens)"
    fi

    return $issues
}

# Validate token budgets for reference files
validate_reference_token_budgets() {
    local skill_id="$1"
    local skill_dir="$2"
    local refs_dir="$skill_dir/references"

    if [[ ! -d "$refs_dir" ]]; then
        return 0  # No references directory, nothing to check
    fi

    local issues=0

    # Define reference files and their budgets
    declare -A ref_budgets=(
        ["io-contract.md"]=$IO_CONTRACT_TOKEN_BUDGET
        ["safety.md"]=$SAFETY_TOKEN_BUDGET
        ["examples.md"]=$EXAMPLES_TOKEN_BUDGET
        ["phases.md"]=$PHASES_TOKEN_BUDGET
        ["validation.md"]=$VALIDATION_TOKEN_BUDGET
    )

    for ref_file in "${!ref_budgets[@]}"; do
        local ref_path="$refs_dir/$ref_file"
        if [[ -f "$ref_path" ]]; then
            local tokens
            tokens=$(estimate_tokens "$ref_path")
            local budget=${ref_budgets[$ref_file]}

            if [[ $tokens -gt $budget ]]; then
                log_warning "$ref_file exceeds token budget (~$tokens > $budget tokens)"
                log_info "  Consider splitting content or extracting to domain-specific file"
                ((issues++)) || true
            else
                log_success "$ref_file within token budget (~$tokens tokens)"
            fi
        fi
    done

    return $issues
}

# ============================================================================
# Aggregate Complexity Budget Validation
# ============================================================================
# Validates that total reference file tokens stay within complexity budgets.
# These are soft limits (warnings) to prevent pattern explosion while
# preserving flexibility for domain-expert skills.
#
# Budget Tiers:
#   - Standard Complex: ~20000 tokens (2-4 reference files)
#   - Enterprise Complex: ~26000 tokens (4-6 reference files)
#   - Domain Expert: ~32000 tokens (5-8 reference files, domain knowledge extensive)
#
# See: .octon/capabilities/_meta/architecture/reference-artifacts.md#complexity-budget

# Calculate aggregate token count for all reference files in a skill
calculate_aggregate_reference_tokens() {
    local skill_dir="$1"
    local refs_dir="$skill_dir/references"
    local total=0

    if [[ ! -d "$refs_dir" ]]; then
        echo 0
        return
    fi

    # Sum tokens for all markdown files in references/
    for ref_file in "$refs_dir"/*.md; do
        if [[ -f "$ref_file" ]]; then
            local tokens
            tokens=$(estimate_tokens "$ref_file")
            total=$((total + tokens))
        fi
    done

    echo $total
}

# Validate aggregate complexity budget for a skill
# Returns 0 if OK, logs warnings if approaching/exceeding thresholds
validate_aggregate_complexity() {
    local skill_id="$1"
    local skill_dir="$2"
    local refs_dir="$skill_dir/references"

    # Only check Complex skills (those with reference files)
    if [[ ! -d "$refs_dir" ]]; then
        return 0  # Atomic skill, no aggregate check needed
    fi

    local ref_count
    ref_count=$(find "$refs_dir" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

    if [[ $ref_count -eq 0 ]]; then
        return 0  # No reference files
    fi

    local aggregate_tokens
    aggregate_tokens=$(calculate_aggregate_reference_tokens "$skill_dir")

    # Determine if this is a domain-expert skill (has glossary.md or <domain>.md files)
    local is_domain_skill=false
    if [[ -f "$refs_dir/glossary.md" ]]; then
        is_domain_skill=true
    fi
    # Check for domain-specific files (files other than standard pattern files)
    for ref_file in "$refs_dir"/*.md; do
        local basename
        basename=$(basename "$ref_file")
        case "$basename" in
            io-contract.md|phases.md|safety.md|examples.md|validation.md|\
            checkpoints.md|orchestration.md|decisions.md|interaction.md|\
            agents.md|composition.md|errors.md|glossary.md|\
            idempotency.md|cancellation.md|dependencies.md)
                # Standard capability-triggered file
                ;;
            *)
                # Domain-specific file
                is_domain_skill=true
                ;;
        esac
    done

    # Apply appropriate budget based on skill type
    local budget_label
    local budget_threshold
    local ceiling_threshold

    if [[ "$is_domain_skill" == "true" ]]; then
        budget_label="Domain Expert"
        budget_threshold=$AGGREGATE_ENTERPRISE_BUDGET
        ceiling_threshold=$AGGREGATE_DOMAIN_BUDGET
    else
        budget_label="Standard Complex"
        budget_threshold=$AGGREGATE_STANDARD_BUDGET
        ceiling_threshold=$AGGREGATE_ENTERPRISE_BUDGET
    fi

    # Report and warn based on thresholds
    if [[ $aggregate_tokens -le $AGGREGATE_STANDARD_BUDGET ]]; then
        log_success "Aggregate reference tokens within standard budget (~$aggregate_tokens tokens, $ref_count files)"
    elif [[ $aggregate_tokens -le $AGGREGATE_ENTERPRISE_BUDGET ]]; then
        log_warning "Aggregate reference tokens approaching complexity ceiling (~$aggregate_tokens > $AGGREGATE_STANDARD_BUDGET tokens)"
        log_info "  Consider: consolidate redundant content, extract shared domain knowledge"
        log_info "  See: .octon/capabilities/_meta/architecture/reference-artifacts.md#reducing-complexity"
    elif [[ $aggregate_tokens -le $AGGREGATE_DOMAIN_BUDGET ]]; then
        if [[ "$is_domain_skill" == "true" ]]; then
            log_success "Domain Expert skill within extended budget (~$aggregate_tokens tokens, $ref_count files)"
        else
            log_warning "Aggregate reference tokens exceed typical budget (~$aggregate_tokens > $AGGREGATE_ENTERPRISE_BUDGET tokens)"
            log_info "  This skill may be doing too much — consider decomposition"
            log_info "  Or add domain-specific files if this is a Domain Expert skill"
        fi
    else
        log_warning "Aggregate reference tokens significantly exceed budget (~$aggregate_tokens > $AGGREGATE_DOMAIN_BUDGET tokens)"
        log_info "  Even Domain Expert skills rarely need this much documentation"
        log_info "  Strongly consider: skill decomposition, extracting reusable domain files"
    fi

    return 0
}

# ============================================================================
# Line Count Validation
# ============================================================================
# Validates that SKILL.md stays under 500 lines per agentskills.io spec.
# Detailed content should be moved to references/ directory.

# Count lines in SKILL.md (excluding empty lines at end)
get_skill_line_count() {
    local skill_dir="$1"
    local skill_md="$skill_dir/SKILL.md"
    if [[ -f "$skill_md" ]]; then
        wc -l < "$skill_md" | tr -d ' '
    else
        echo 0
    fi
}

# Validate line count for SKILL.md
# Returns 0 if OK, 1 if over budget with message to stdout
validate_line_count() {
    local skill_dir="$1"
    local skill_md="$skill_dir/SKILL.md"

    if [[ ! -f "$skill_md" ]]; then
        echo "SKILL.md not found"
        return 1
    fi

    local line_count
    line_count=$(get_skill_line_count "$skill_dir")

    if [[ $line_count -gt $SKILL_MD_LINE_BUDGET ]]; then
        echo "SKILL.md exceeds line budget ($line_count > $SKILL_MD_LINE_BUDGET lines)"
        return 1
    fi

    return 0
}

# ============================================================================
# Description/Summary Alignment Validation
# ============================================================================
# Validates that manifest summary aligns with SKILL.md description.
# Summary should be a concise version of the description's first sentence.

# Get SKILL.md description
get_skill_description() {
    local skill_dir="$1"
    local skill_md="$skill_dir/SKILL.md"
    if [[ -f "$skill_md" ]]; then
        # Extract description field (handles multi-line YAML)
        awk '/^description:/{found=1; gsub(/^description:\s*>?\s*/, ""); if (length > 0) print; next}
             found && /^[a-z]/ {exit}
             found {gsub(/^\s+/, ""); print}' "$skill_md" | tr '\n' ' ' | xargs
    fi
}

# Get manifest summary for a skill
get_manifest_summary() {
    local skill_id="$1"
    awk -v id="$skill_id" '
        $1 == "-" && $2 == "id:" {
            if (found) {exit}
            if ($3 == id) {found=1; next}
        }
        found && /summary:/ {gsub(/.*summary:\s*["'"'"']?/, ""); gsub(/["'"'"']$/, ""); print; exit}
    ' "$MANIFEST"
}

# Check description/summary alignment
# Returns 0 if aligned, 1 if misaligned with message
check_description_summary_alignment() {
    local skill_id="$1"
    local skill_dir="$2"
    
    local description
    description=$(get_skill_description "$skill_dir")
    local summary
    summary=$(get_manifest_summary "$skill_id")
    
    if [[ -z "$description" ]]; then
        echo "Missing description in SKILL.md"
        return 1
    fi
    
    if [[ -z "$summary" ]]; then
        echo "Missing summary in manifest.yml"
        return 1
    fi
    
    # Convert to lowercase for comparison
    local desc_lower="${description,,}"
    local sum_lower="${summary,,}"
    
    # Extract key words from summary (ignore common words)
    local sum_words
    sum_words=$(echo "$sum_lower" | tr ' ' '\n' | grep -vE '^(a|an|the|and|or|to|for|with|in|on|of|is|are|this|that)$' | sort -u)
    
    # Check that most summary words appear in description
    local missing_count=0
    local total_count=0
    for word in $sum_words; do
        if [[ ${#word} -gt 3 ]]; then  # Only check words > 3 chars
            ((total_count++)) || true
            if ! echo "$desc_lower" | grep -q "$word"; then
                ((missing_count++)) || true
            fi
        fi
    done
    
    # If more than 50% of key words are missing, warn
    if [[ $total_count -gt 0 ]] && [[ $((missing_count * 100 / total_count)) -gt 50 ]]; then
        echo "Summary may not align with description (${missing_count}/${total_count} key words not found)"
        return 1
    fi
    
    return 0
}

# ============================================================================
# Cross-Reference Validation
# ============================================================================
# Validates that all manifest skills have registry entries and vice versa.

# Check for skills in manifest but not in registry
check_manifest_registry_sync() {
    local issues=0
    
    echo ""
    echo "Cross-reference validation..."
    echo "─────────────────────────────"
    
    # Get skills from manifest
    local manifest_skills
    manifest_skills=$(get_manifest_skills)
    
    # Get skills from registry
    local registry_skills
    registry_skills=$(get_registry_skills)
    
    # Check manifest skills are in registry
    for skill_id in $manifest_skills; do
        if ! echo "$registry_skills" | grep -q "^${skill_id}$"; then
            log_error "Skill '$skill_id' in manifest but NOT in registry"
            if [[ "$FIX_MODE" == "true" ]]; then
                scaffold_registry_entry "$skill_id"
            fi
            ((issues++)) || true
        fi
    done
    
    # Check registry skills are in manifest
    for skill_id in $registry_skills; do
        if ! echo "$manifest_skills" | grep -q "^${skill_id}$"; then
            log_error "Skill '$skill_id' in registry but NOT in manifest"
            if [[ "$FIX_MODE" == "true" ]]; then
                scaffold_manifest_entry "$skill_id"
            fi
            ((issues++)) || true
        fi
    done
    
    if [[ $issues -eq 0 ]]; then
        log_success "Manifest and registry are in sync"
    fi
    
    return $issues
}

# ============================================================================
# Fix Mode Functions
# ============================================================================
# Functions to auto-fix common issues when --fix flag is provided.

# Scaffold a missing registry entry
scaffold_registry_entry() {
    local skill_id="$1"
    local skill_dir="$SKILLS_DIR/$(get_skill_path "$skill_id")"
    
    if [[ ! -d "$skill_dir" ]]; then
        log_info "  Cannot scaffold registry entry: skill directory not found"
        return 1
    fi
    
    log_info "  Scaffolding registry entry for '$skill_id'..."
    
    # Get allowed-tools from SKILL.md for reference
    local allowed_tools
    allowed_tools=$(get_skill_allowed_tools "$skill_dir" | tr '\n' ' ')
    
    local scaffold="
  ${skill_id}:
    version: \"1.0.0\"
    commands:
      - /${skill_id}
    parameters: []
    requires:
      context:
        - type: directory_exists
          path: \".octon/\"
          description: \"Requires a .octon directory\"
    depends_on: []
    # TODO: Configure parameters based on SKILL.md
    # allowed-tools in SKILL.md: ${allowed_tools:-none specified}"
    
    echo ""
    echo "Add the following to ${REGISTRY}:"
    echo "─────────────────────────────"
    echo "$scaffold"
    echo "─────────────────────────────"
}

# Scaffold a missing manifest entry
scaffold_manifest_entry() {
    local skill_id="$1"
    local skill_dir="$SKILLS_DIR/$(get_skill_path "$skill_id")"
    
    if [[ ! -d "$skill_dir" ]]; then
        log_info "  Cannot scaffold manifest entry: skill directory not found"
        return 1
    fi
    
    log_info "  Scaffolding manifest entry for '$skill_id'..."
    
    # Get description from SKILL.md
    local description
    description=$(get_skill_description "$skill_dir")
    
    # Create display name from id (kebab-case to Title Case)
    local display_name
    display_name=$(echo "$skill_id" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')

    # Resolve grouped path prefix from manifest group when available
    local group
    group=$(get_skill_group "$skill_id")
    if [[ -z "$group" ]] || [[ "$group" == "$skill_id" ]]; then
        group="meta"
    fi

    # Truncate description for summary (first sentence or 80 chars)
    local summary
    summary=$(echo "$description" | cut -d. -f1 | head -c 80)
    
    local scaffold="
  - id: ${skill_id}
    display_name: ${display_name}
    path: ${group}/${skill_id}/
    summary: \"${summary}.\"
    status: experimental
    tags:
      - TODO
    triggers:
      - \"TODO: add natural language triggers\""
    
    echo ""
    echo "Add the following to ${MANIFEST}:"
    echo "─────────────────────────────"
    echo "$scaffold"
    echo "─────────────────────────────"
}

# Scaffold missing I/O mapping
scaffold_io_mapping() {
    local skill_id="$1"
    
    log_info "  Scaffolding I/O mapping for '$skill_id'..."
    
    local scaffold="
    io:
      inputs:
        - path: \"_ops/state/resources/${skill_id}/{{category}}/\"
          kind: directory
          required: false
          description: \"Optional input source folder\"
      outputs:
        - name: result
          path: \"../../output/{{category}}/{{timestamp}}-${skill_id}.md\"
          kind: file
          format: markdown
          determinism: stable
          description: \"Skill output document\"
        - name: run_log
          path: \"_ops/state/logs/${skill_id}/{{run_id}}.md\"
          kind: file
          format: markdown
          determinism: unique
          description: \"Execution log\""
    
    echo ""
    echo "Add the following to ${SKILLS_REGISTRY} under skills.${skill_id}:"
    echo "─────────────────────────────"
    echo "$scaffold"
    echo "─────────────────────────────"
}

# Check for trigger overlap between skills
# Warns when different skills have triggers that share significant word overlap
check_trigger_overlaps() {
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Collect all triggers from all skills into temp files
    local skill_id
    for skill_id in $(get_manifest_skills); do
        local trigger_file="$temp_dir/${skill_id}_triggers.txt"
        get_skill_triggers "$skill_id" | tr '[:upper:]' '[:lower:]' | tr -s ' ' > "$trigger_file" || true
    done
    
    # Check for exact duplicate triggers across skills
    local seen_triggers="$temp_dir/seen_triggers.txt"
    touch "$seen_triggers"
    
    for skill_id in $(get_manifest_skills); do
        local trigger_file="$temp_dir/${skill_id}_triggers.txt"
        if [[ -f "$trigger_file" ]]; then
            while IFS= read -r trigger; do
                if [[ -n "$trigger" ]]; then
                    # Check if this exact trigger was seen in another skill
                    local existing
                    existing=$(grep -F "|$trigger|" "$seen_triggers" 2>/dev/null | head -1 || true)
                    if [[ -n "$existing" ]]; then
                        local other_skill
                        other_skill=$(echo "$existing" | cut -d'|' -f1)
                        if [[ "$other_skill" != "$skill_id" ]]; then
                            if [[ "$STRICT_MODE" == "true" ]]; then
                                log_error "Duplicate trigger '$trigger' found in both '$other_skill' and '$skill_id'"
                            else
                                log_warning "Duplicate trigger '$trigger' found in both '$other_skill' and '$skill_id'"
                            fi
                        fi
                    fi
                    echo "${skill_id}|$trigger|" >> "$seen_triggers"
                fi
            done < "$trigger_file"
        fi
    done
    
    # Check for significant word overlap between triggers of different skills
    local skills_array
    skills_array=($(get_manifest_skills))
    local num_skills=${#skills_array[@]}
    
    local i j
    for ((i=0; i<num_skills; i++)); do
        for ((j=i+1; j<num_skills; j++)); do
            local skill_a="${skills_array[$i]}"
            local skill_b="${skills_array[$j]}"
            
            # Extract significant words from each skill's triggers
            local words_a_file="$temp_dir/${skill_a}_words.txt"
            local words_b_file="$temp_dir/${skill_b}_words.txt"
            
            cat "$temp_dir/${skill_a}_triggers.txt" 2>/dev/null | tr ' ' '\n' | grep -v '^$' | sort -u | grep -vE '^(my|the|a|an|this|it|to|for|in|on|of|and|or)$' > "$words_a_file" 2>/dev/null || touch "$words_a_file"
            cat "$temp_dir/${skill_b}_triggers.txt" 2>/dev/null | tr ' ' '\n' | grep -v '^$' | sort -u | grep -vE '^(my|the|a|an|this|it|to|for|in|on|of|and|or)$' > "$words_b_file" 2>/dev/null || touch "$words_b_file"
            
            # Find common significant words
            local common_words
            common_words=$(comm -12 "$words_a_file" "$words_b_file" 2>/dev/null | grep -v '^$' || true)
            
            # Count common significant words
            local common_count=0
            if [[ -n "$common_words" ]]; then
                common_count=$(echo "$common_words" | wc -l | tr -d ' ')
            fi
            
            if [[ $common_count -ge 2 ]]; then
                log_info "Note: Skills '$skill_a' and '$skill_b' share trigger words: $(echo $common_words | tr '\n' ' ')"
            fi
        done
    done
    
    # Cleanup
    rm -rf "$temp_dir"
    
    log_success "Trigger overlap check complete"
}

# ============================================================================
# Reference File Content Validation
# ============================================================================
# Validates that reference file content aligns with registry.yml values.
# This catches prose drift where documentation describes parameters or commands
# differently than the authoritative registry.

# Get parameter names from registry.yml for a skill
get_registry_parameters() {
    local skill_id="$1"
    awk -v skill="$skill_id" '
        $0 ~ "^  "skill":" {found=1; next}
        found && /^  [a-z]/ && $0 !~ "^  "skill":" {exit}
        found && /parameters:/ {in_params=1; next}
        found && in_params && /^      - name:/ {gsub(/.*name:\s*/, ""); gsub(/["'"'"']/, ""); print}
        found && in_params && /^    [a-z]/ && !/^      / {exit}
    ' "$REGISTRY"
}

# Get command names from registry.yml for a skill
get_registry_commands() {
    local skill_id="$1"
    awk -v skill="$skill_id" '
        $0 ~ "^  "skill":" {found=1; next}
        found && /^  [a-z]/ && $0 !~ "^  "skill":" {exit}
        found && /commands:/ {in_cmds=1; next}
        found && in_cmds && /^      - / {gsub(/^      - ["'"'"']?/, ""); gsub(/["'"'"']$/, ""); print}
        found && in_cmds && /^    [a-z]/ && !/^      / {exit}
    ' "$REGISTRY"
}

# Check if io-contract.md mentions registry parameters
# Returns 0 if all parameters are mentioned, 1 if some are missing
validate_io_contract_parameters() {
    local skill_id="$1"
    local skill_dir="$2"
    local io_contract="$skill_dir/references/io-contract.md"

    if [[ ! -f "$io_contract" ]]; then
        return 0  # No io-contract.md to validate
    fi

    local registry_params
    registry_params=$(get_registry_parameters "$skill_id")

    if [[ -z "$registry_params" ]]; then
        return 0  # No parameters in registry
    fi

    local missing=""
    local io_content
    io_content=$(cat "$io_contract" | tr '[:upper:]' '[:lower:]')

    for param in $registry_params; do
        local param_lower
        param_lower=$(echo "$param" | tr '[:upper:]' '[:lower:]')
        # Check if parameter is mentioned in io-contract (allow underscore/hyphen variants)
        local param_pattern="${param_lower//_/[-_]}"
        if ! echo "$io_content" | grep -qE "(^|[^a-z])${param_pattern}([^a-z]|$)"; then
            missing="${missing}${param}, "
        fi
    done

    if [[ -n "$missing" ]]; then
        echo "Parameters in registry but not in io-contract.md: ${missing%, }"
        return 1
    fi

    return 0
}

# Check if examples.md uses correct commands from registry
validate_examples_commands() {
    local skill_id="$1"
    local skill_dir="$2"
    local examples_md="$skill_dir/references/examples.md"

    if [[ ! -f "$examples_md" ]]; then
        return 0  # No examples.md to validate
    fi

    local registry_commands
    registry_commands=$(get_registry_commands "$skill_id")

    if [[ -z "$registry_commands" ]]; then
        return 0  # No commands in registry
    fi

    # Check that at least one command from registry is used in examples
    local found=false
    for cmd in $registry_commands; do
        if grep -q "$cmd" "$examples_md" 2>/dev/null; then
            found=true
            break
        fi
    done

    if [[ "$found" == "false" ]]; then
        echo "No registry commands found in examples.md (expected: $registry_commands)"
        return 1
    fi

    return 0
}

# Validate reference file content against registry
# Returns 0 if aligned, 1 if misaligned with issues to stdout
validate_reference_content() {
    local skill_id="$1"
    local skill_dir="$2"
    local issues=0
    local result=""

    # Check io-contract.md parameter alignment
    local param_result
    param_result=$(validate_io_contract_parameters "$skill_id" "$skill_dir" 2>&1)
    if [[ $? -ne 0 ]]; then
        result="${result}${param_result}; "
        ((issues++)) || true
    fi

    # Check examples.md command usage
    local cmd_result
    cmd_result=$(validate_examples_commands "$skill_id" "$skill_dir" 2>&1)
    if [[ $? -ne 0 ]]; then
        result="${result}${cmd_result}; "
        ((issues++)) || true
    fi

    if [[ $issues -gt 0 ]]; then
        echo "${result%, }"
        return 1
    fi

    return 0
}

# ============================================================================
# Version Staleness Check
# ============================================================================
# Warns when a skill has version "1.0.0" but appears mature (many reference files).
# This is a reminder to consider version bumps for production skills.

# Get version from registry for a skill
get_registry_version() {
    local skill_id="$1"
    awk -v skill="$skill_id" '
        $0 ~ "^  "skill":" {found=1; next}
        found && /^  [a-z]/ && $0 !~ "^  "skill":" {exit}
        found && /version:/ {gsub(/.*version:[[:space:]]*/, ""); gsub(/["'"'"']/, ""); print; exit}
    ' "$REGISTRY"
}

# Check if skill has reference files (indicates maturity beyond Atomic archetype)
has_reference_files() {
    local skill_dir="$1"
    [[ -d "$skill_dir/references" ]] && [[ -n "$(ls -A "$skill_dir/references" 2>/dev/null)" ]]
}

# Count reference files
count_reference_files() {
    local skill_dir="$1"
    if [[ -d "$skill_dir/references" ]]; then
        find "$skill_dir/references" -type f -name "*.md" | wc -l | tr -d ' '
    else
        echo 0
    fi
}

# Validate version staleness
# Returns 0 if OK, 1 if warning needed with message to stdout
check_version_staleness() {
    local skill_id="$1"
    local skill_dir="$2"

    local version
    version=$(get_registry_version "$skill_id")

    if [[ -z "$version" ]]; then
        echo "No version found in registry"
        return 1
    fi

    # Check if version is still at initial 1.0.0
    if [[ "$version" == "1.0.0" ]]; then
        # Check if skill appears mature enough to justify a version bump reminder.
        if has_reference_files "$skill_dir"; then
            local ref_count
            ref_count=$(count_reference_files "$skill_dir")
            if [[ $ref_count -ge $VERSION_STALENESS_MIN_REFS ]]; then
                echo "Version is 1.0.0 but skill has $ref_count reference files (consider version bump if production-ready)"
                return 1
            fi
        fi
    fi

    return 0
}

# ============================================================================
# Capability Validation
# ============================================================================
# Validates that skills have appropriate capabilities and matching reference files.
#
# Capability-to-Reference Mapping:
#   phased → phases.md
#   branching → decisions.md
#   stateful/resumable → checkpoints.md
#   self-validating → validation.md
#   safety-bounded → safety.md
#   human-collaborative → interaction.md
#   agent-delegating → agents.md
#   task-coordinating/parallel → orchestration.md
#   composable → composition.md
#   contract-driven → io-contract.md
#   domain-specialized → glossary.md
#   error-resilient → errors.md
#   idempotent → idempotency.md
#   cancellable → cancellation.md
#   external-dependent → dependencies.md

# Validate that SKILL.md skill_sets/capabilities are declared with known values.
# Returns 0 if valid, non-zero if any invalid declarations are found.
validate_declared_capabilities() {
    local skill_id="$1"
    local skill_dir="$2"
    local issues=0

    local skill_sets
    skill_sets=$(get_skill_frontmatter_array "$skill_dir" "skill_sets")
    local capabilities
    capabilities=$(get_skill_frontmatter_array "$skill_dir" "capabilities")

    local value
    while IFS= read -r value; do
        [[ -z "$value" ]] && continue
        if ! array_contains "$value" "${VALID_SKILL_SETS[@]}"; then
            log_error "Skill '$skill_id': unknown skill set in SKILL.md frontmatter: '$value'"
            ((issues++)) || true
        fi
    done <<< "$skill_sets"

    while IFS= read -r value; do
        [[ -z "$value" ]] && continue
        if ! array_contains "$value" "${VALID_CAPABILITIES[@]}"; then
            log_error "Skill '$skill_id': unknown capability in SKILL.md frontmatter: '$value'"
            ((issues++)) || true
        fi
    done <<< "$capabilities"

    if [[ $issues -eq 0 ]]; then
        log_success "Declared skill_sets/capabilities are valid"
    fi

    return $issues
}

# Validate parity between manifest and SKILL.md capability declarations.
# Returns 0 if aligned, non-zero when mismatches are found.
validate_manifest_skill_parity() {
    local skill_id="$1"
    local skill_dir="$2"
    local issues=0

    local manifest_skill_sets
    manifest_skill_sets=$(get_manifest_skill_array "$skill_id" "skill_sets")
    local manifest_capabilities
    manifest_capabilities=$(get_manifest_skill_array "$skill_id" "capabilities")

    local skillmd_skill_sets
    skillmd_skill_sets=$(get_skill_frontmatter_array "$skill_dir" "skill_sets")
    local skillmd_capabilities
    skillmd_capabilities=$(get_skill_frontmatter_array "$skill_dir" "capabilities")

    local manifest_skill_sets_norm
    manifest_skill_sets_norm=$(normalize_list_values "$manifest_skill_sets")
    local skillmd_skill_sets_norm
    skillmd_skill_sets_norm=$(normalize_list_values "$skillmd_skill_sets")

    local manifest_capabilities_norm
    manifest_capabilities_norm=$(normalize_list_values "$manifest_capabilities")
    local skillmd_capabilities_norm
    skillmd_capabilities_norm=$(normalize_list_values "$skillmd_capabilities")

    if [[ "$manifest_skill_sets_norm" != "$skillmd_skill_sets_norm" ]]; then
        log_error "Skill '$skill_id': skill_sets mismatch between manifest.yml and SKILL.md"
        log_info "  manifest.yml: [${manifest_skill_sets_norm}]"
        log_info "  SKILL.md:     [${skillmd_skill_sets_norm}]"
        ((issues++)) || true
    fi

    if [[ "$manifest_capabilities_norm" != "$skillmd_capabilities_norm" ]]; then
        log_error "Skill '$skill_id': capabilities mismatch between manifest.yml and SKILL.md"
        log_info "  manifest.yml: [${manifest_capabilities_norm}]"
        log_info "  SKILL.md:     [${skillmd_capabilities_norm}]"
        ((issues++)) || true
    fi

    if [[ $issues -eq 0 ]]; then
        log_success "Manifest and SKILL.md skill_sets/capabilities are aligned"
    fi

    return $issues
}

validate_skill_class_contract() {
    local skill_id="$1"
    local skill_dir="$2"
    local skill_class
    skill_class=$(get_manifest_skill_class "$skill_id")
    local command_count
    command_count=$(get_registry_command_count "$skill_id")

    if [[ -z "$skill_class" ]]; then
        log_error "Skill '$skill_id': missing skill_class in manifest.yml"
        return 1
    fi

    if ! array_contains "$skill_class" "${VALID_SKILL_CLASSES[@]}"; then
        log_error "Skill '$skill_id': invalid skill_class '$skill_class' (expected one of: ${VALID_SKILL_CLASSES[*]})"
        return 1
    fi

    if grep -qE "^user-invocable:" "$skill_dir/SKILL.md" 2>/dev/null; then
        log_error "Skill '$skill_id': SKILL.md still declares legacy user-invocable frontmatter"
        return 1
    fi

    case "$skill_class" in
        context)
            if [[ "${command_count:-0}" -ne 0 ]]; then
                log_error "Skill '$skill_id': context skills must not declare slash commands"
                return 1
            fi
            ;;
        invocable|ruleset)
            if [[ "${command_count:-0}" -eq 0 ]]; then
                log_error "Skill '$skill_id': $skill_class skills must declare at least one slash command"
                return 1
            fi
            ;;
    esac

    log_success "skill_class contract is valid: $skill_class"
    return 0
}

validate_skill_composition_contract() {
    local skill_id="$1"
    local skill_dir="$2"
    local allowed_services_csv
    allowed_services_csv=$(get_skill_allowed_services "$skill_dir" | paste -sd',' -)
    local skill_sets_csv
    skill_sets_csv=$(get_manifest_skill_array "$skill_id" "skill_sets" | paste -sd',' -)

    local validation_output
    validation_output="$(
        ruby -r yaml -e '
            registry = YAML.load_file(ARGV[0])
            manifest = YAML.load_file(ARGV[1])
            services = File.exist?(ARGV[2]) ? YAML.load_file(ARGV[2]) : { "services" => [] }
            caps = YAML.load_file(ARGV[3])
            skill_id = ARGV[4]
            allowed_services = ARGV[5].split(",").reject(&:empty?)
            skill_sets = ARGV[6].split(",").reject(&:empty?)

            entry = registry.fetch("skills").fetch(skill_id)
            composition = entry["composition"]
            exit 0 if composition.nil?

            valid_modes = caps.fetch("composition_contract").fetch("modes")
            valid_failure_policies = caps.fetch("composition_contract").fetch("failure_policies")
            valid_step_kinds = caps.fetch("composition_contract").fetch("step_kinds")
            valid_step_roles = caps.fetch("composition_contract").fetch("step_roles")
            valid_when_ops = caps.fetch("composition_contract").fetch("when_operators")
            manifest_skill_ids = manifest.fetch("skills").map { |item| item.fetch("id") }
            service_ids = services.fetch("services", []).map { |item| item.fetch("id") }
            parameter_names = Array(entry["parameters"]).map { |item| item.fetch("name") }
            parent_outputs = Array(entry.dig("io", "outputs")).map { |item| item.fetch("name") }

            errors = []
            mode = composition["mode"]
            failure_policy = composition["failure_policy"]
            steps = Array(composition["steps"])

            errors << "invalid composition.mode '#{mode}'" unless valid_modes.include?(mode)
            errors << "invalid composition.failure_policy '#{failure_policy}'" unless valid_failure_policies.include?(failure_policy)
            errors << "composition.steps must not be empty" if steps.empty?

            step_ids = []
            step_defs = {}
            service_refs = []
            invoke_present = false

            steps.each_with_index do |step, index|
                unless step.is_a?(Hash)
                    errors << "composition step #{index + 1} must be a mapping"
                    next
                end

                step_id = step["id"]
                kind = step["kind"]
                ref = step["ref"]
                role = step["role"]
                required = step["required"]
                when_clause = step["when"]
                bindings = step["bindings"] || {}
                expose_outputs = step["expose_outputs"] || {}

                errors << "composition step #{index + 1} missing id" if step_id.to_s.empty?
                errors << "composition step #{step_id || index + 1} has duplicate id" if !step_id.to_s.empty? && step_ids.include?(step_id)
                errors << "composition step #{step_id || index + 1} invalid kind '#{kind}'" unless valid_step_kinds.include?(kind)
                errors << "composition step #{step_id || index + 1} invalid role '#{role}'" unless valid_step_roles.include?(role)
                errors << "composition step #{step_id || index + 1} required must be boolean" unless required == true || required == false

                if kind == "skill" && !manifest_skill_ids.include?(ref)
                    errors << "composition step #{step_id || index + 1} references unknown skill '#{ref}'"
                elsif kind == "service"
                    if !service_ids.include?(ref)
                        errors << "composition step #{step_id || index + 1} references unknown service '#{ref}'"
                    end
                    service_refs << ref
                end

                if when_clause
                    if when_clause.is_a?(String)
                        errors << "composition step #{step_id || index + 1} invalid when '#{when_clause}'" unless when_clause == "always"
                    elsif when_clause.is_a?(Hash)
                        operator = when_clause["operator"]
                        parameter = when_clause["parameter"]
                        errors << "composition step #{step_id || index + 1} invalid when operator '#{operator}'" unless valid_when_ops.include?(operator)
                        if operator != "always" && !parameter_names.include?(parameter)
                            errors << "composition step #{step_id || index + 1} when.parameter '#{parameter}' is not a declared parameter"
                        end
                        if operator == "param_equals" && !when_clause.key?("value")
                            errors << "composition step #{step_id || index + 1} param_equals requires value"
                        end
                        if operator == "param_in"
                            values = when_clause["values"]
                            errors << "composition step #{step_id || index + 1} param_in requires non-empty values" unless values.is_a?(Array) && !values.empty?
                        end
                    else
                        errors << "composition step #{step_id || index + 1} when must be a string or mapping"
                    end
                end

                unless bindings.is_a?(Hash)
                    errors << "composition step #{step_id || index + 1} bindings must be a mapping"
                    bindings = {}
                end
                bindings.each do |binding_key, binding_value|
                    unless binding_value.is_a?(String)
                        errors << "composition step #{step_id || index + 1} binding '#{binding_key}' must be a string"
                        next
                    end
                    if binding_value.start_with?("parameter.")
                        param_name = binding_value.split(".", 2).last
                        errors << "composition step #{step_id || index + 1} binding '#{binding_key}' references unknown parameter '#{param_name}'" unless parameter_names.include?(param_name)
                    elsif binding_value =~ /^step\.([a-z0-9][a-z0-9-]*)\.([a-zA-Z_][a-zA-Z0-9_]*)$/
                        source_step = Regexp.last_match(1)
                        output_name = Regexp.last_match(2)
                        unless step_defs.key?(source_step)
                            errors << "composition step #{step_id || index + 1} binding '#{binding_key}' references unknown prior step '#{source_step}'"
                            next
                        end
                        output_defs =
                            case step_defs[source_step][:kind]
                            when "skill"
                                Array(registry.fetch("skills").fetch(step_defs[source_step][:ref]).dig("io", "outputs")).map { |item| item.fetch("name") }
                            else
                                []
                            end
                        errors << "composition step #{step_id || index + 1} binding '#{binding_key}' references unknown output '#{output_name}' from step '#{source_step}'" unless output_defs.include?(output_name)
                    else
                        errors << "composition step #{step_id || index + 1} binding '#{binding_key}' has invalid source '#{binding_value}'"
                    end
                end

                unless expose_outputs.is_a?(Hash)
                    errors << "composition step #{step_id || index + 1} expose_outputs must be a mapping"
                    expose_outputs = {}
                end
                expose_outputs.each do |parent_output, source_value|
                    errors << "composition step #{step_id || index + 1} expose_outputs references unknown parent output '#{parent_output}'" unless parent_outputs.include?(parent_output)
                    unless source_value.is_a?(String) && source_value =~ /^step\.([a-z0-9][a-z0-9-]*)\.([a-zA-Z_][a-zA-Z0-9_]*)$/
                        errors << "composition step #{step_id || index + 1} expose_outputs '#{parent_output}' has invalid source '#{source_value}'"
                        next
                    end
                    source_step = Regexp.last_match(1)
                    output_name = Regexp.last_match(2)
                    unless step_defs.key?(source_step) || step_id == source_step
                        errors << "composition step #{step_id || index + 1} expose_outputs '#{parent_output}' references unknown step '#{source_step}'"
                        next
                    end
                    source_ref = (step_defs[source_step] || { kind: kind, ref: ref })
                    if source_ref[:kind] == "skill"
                        output_defs = Array(registry.fetch("skills").fetch(source_ref[:ref]).dig("io", "outputs")).map { |item| item.fetch("name") }
                        errors << "composition step #{step_id || index + 1} expose_outputs '#{parent_output}' references unknown output '#{output_name}' from step '#{source_step}'" unless output_defs.include?(output_name)
                    end
                end

                invoke_present ||= role == "invoke"
                step_ids << step_id if step_id
                step_defs[step_id] = { kind: kind, ref: ref } if step_id
            end

            if mode == "parallel" && !skill_sets.include?("coordinator")
                errors << "parallel composition requires coordinator skill set"
            end
            if invoke_present && !skill_sets.include?("integrator")
                errors << "composition with invoke steps requires integrator skill set"
            end

            if service_refs.any?
                if allowed_services.sort != service_refs.uniq.sort
                    errors << "allowed-services must exactly match composed service refs (declared=#{allowed_services.sort.join(",")} composed=#{service_refs.uniq.sort.join(",")})"
                end
            end

            if errors.any?
                STDERR.puts(errors.join("\n"))
                exit 1
            end
        ' "$REGISTRY" "$MANIFEST" "$SERVICES_MANIFEST" "$CAPABILITIES_SCHEMA" "$skill_id" "$allowed_services_csv" "$skill_sets_csv" 2>&1
    )"
    local status=$?

    if [[ $status -ne 0 ]]; then
        while IFS= read -r line; do
            [[ -n "$line" ]] && log_error "Skill '$skill_id': $line"
        done <<< "$validation_output"
        return 1
    fi

    if ruby -r yaml -e 'entry = YAML.load_file(ARGV[0]).fetch("skills").fetch(ARGV[1]); exit(entry["composition"] ? 0 : 1)' "$REGISTRY" "$skill_id" >/dev/null 2>&1; then
        log_success "composition contract is valid"
    fi

    return 0
}

# Capability thresholds (for suggesting capabilities)
CAPABILITY_THRESHOLD_PHASES=3
CAPABILITY_THRESHOLD_TOKENS=3000
CAPABILITY_THRESHOLD_BRANCHES=3

# Count phases in SKILL.md (looks for ## Phase or numbered workflow steps)
count_skill_phases() {
    local skill_dir="$1"
    local skill_md="$skill_dir/SKILL.md"
    if [[ ! -f "$skill_md" ]]; then
        echo 0
        return
    fi

    # Count phase-like patterns:
    # - "## Phase N" or "### Phase N"
    # - "1. **Phase" or "1. Phase"
    # - Numbered workflow steps like "1. **Name** -"
    local phase_count=0

    # Count markdown headers with "Phase"
    local header_phases
    header_phases=$(grep -cE "^#{2,3}\s+(Phase|Step)\s+" "$skill_md" 2>/dev/null || echo 0)

    # Count numbered workflow items (e.g., "1. **Name** -" pattern in Core Workflow)
    local numbered_phases
    numbered_phases=$(grep -cE "^[0-9]+\.\s+\*\*[^*]+\*\*" "$skill_md" 2>/dev/null || echo 0)

    # Take the maximum (skills typically use one pattern or the other)
    if [[ $header_phases -gt $numbered_phases ]]; then
        echo "$header_phases"
    else
        echo "$numbered_phases"
    fi
}

# Count conditional branches in SKILL.md (if/else patterns, decision points)
count_skill_branches() {
    local skill_dir="$1"
    local skill_md="$skill_dir/SKILL.md"
    if [[ ! -f "$skill_md" ]]; then
        echo 0
        return
    fi

    # Count branch-like patterns:
    # - "If ... then" or "When ... then"
    # - Decision points like "Choose:", "Select:", "Option:"
    # - Conditional markers like "- If", "- When", "- Otherwise"
    local branch_count=0

    # Count "If/When" conditional statements
    local if_branches
    if_branches=$(grep -ciE "(^|\s)(if|when)\s+.*(then|:)" "$skill_md" 2>/dev/null || echo 0)

    # Count decision point markers
    local decision_branches
    decision_branches=$(grep -ciE "^-\s+(if|when|otherwise|else)" "$skill_md" 2>/dev/null || echo 0)

    # Count option/choice markers
    local option_branches
    option_branches=$(grep -ciE "(option|choice|alternative)\s*[0-9]*:" "$skill_md" 2>/dev/null || echo 0)

    echo $((if_branches + decision_branches + option_branches))
}

# Check for interaction/approval patterns in SKILL.md
has_interaction_patterns() {
    local skill_dir="$1"
    local skill_md="$skill_dir/SKILL.md"
    if [[ ! -f "$skill_md" ]]; then
        return 1
    fi

    # Look for human-collaboration indicators
    grep -qiE "(approval|approve|confirm|user input|ask user|human review|gate|checkpoint)" "$skill_md" 2>/dev/null
}

# Check for sub-agent/delegation patterns in SKILL.md
has_delegation_patterns() {
    local skill_dir="$1"
    local skill_md="$skill_dir/SKILL.md"
    if [[ ! -f "$skill_md" ]]; then
        return 1
    fi

    # Look for sub-agent/delegation indicators
    grep -qiE "(sub-agent|subagent|delegate|spawn|parallel agent|agent coordination)" "$skill_md" 2>/dev/null
}

# Check for state/checkpoint patterns in SKILL.md
has_state_patterns() {
    local skill_dir="$1"
    local skill_md="$skill_dir/SKILL.md"
    if [[ ! -f "$skill_md" ]]; then
        return 1
    fi

    # Look for state persistence indicators
    grep -qiE "(checkpoint|resume|state|persist|recovery|intermediate)" "$skill_md" 2>/dev/null
}

# Validate capability heuristics for minimal skills
# Returns suggestions if skill should add capabilities
validate_capability_heuristics() {
    local skill_id="$1"
    local skill_dir="$2"
    local suggestions=""
    local should_add_caps=false

    # Only check minimal skills (no declared capabilities)
    if has_capabilities "$skill_dir"; then
        return 0  # Already has capabilities, skip heuristics check
    fi

    # Check 1: Phase count threshold → suggest 'phased' capability
    local phase_count
    phase_count=$(count_skill_phases "$skill_dir")
    if [[ $phase_count -ge $CAPABILITY_THRESHOLD_PHASES ]]; then
        suggestions="${suggestions}\n  - Has $phase_count phases → consider 'executor' skill set or 'phased' capability"
        should_add_caps=true
    fi

    # Check 2: Token count threshold
    local token_count
    token_count=$(estimate_tokens "$skill_dir/SKILL.md")
    if [[ $token_count -gt $CAPABILITY_THRESHOLD_TOKENS ]]; then
        suggestions="${suggestions}\n  - SKILL.md has ~$token_count tokens → consider adding capabilities and reference files"
        should_add_caps=true
    fi

    # Check 3: Branch count threshold → suggest 'branching' capability
    local branch_count
    branch_count=$(count_skill_branches "$skill_dir")
    if [[ $branch_count -ge $CAPABILITY_THRESHOLD_BRANCHES ]]; then
        suggestions="${suggestions}\n  - Has $branch_count conditional branches → consider 'branching' capability"
        should_add_caps=true
    fi

    # Check 4: human-collaboration patterns → suggest 'collaborator' skill set
    if has_interaction_patterns "$skill_dir"; then
        suggestions="${suggestions}\n  - Contains human-collaboration patterns → consider 'collaborator' skill set"
        should_add_caps=true
    fi

    # Check 5: Sub-agent coordination patterns → suggest 'delegator' skill set
    if has_delegation_patterns "$skill_dir"; then
        suggestions="${suggestions}\n  - Contains sub-agent/delegation patterns → consider 'delegator' skill set"
        should_add_caps=true
    fi

    # Check 6: State persistence patterns → suggest 'stateful' or 'resumable' capability
    if has_state_patterns "$skill_dir"; then
        suggestions="${suggestions}\n  - Contains state/checkpoint patterns → consider 'stateful' or 'resumable' capability"
        should_add_caps=true
    fi

    # Report findings
    if [[ "$should_add_caps" == "true" ]]; then
        log_warning "Minimal skill may benefit from capability declarations:"
        echo -e "$suggestions"
        log_info "  Add skill_sets and capabilities to manifest.yml and SKILL.md"
        log_info "  See: .octon/capabilities/_meta/architecture/capabilities.md"
        return 1
    fi

    log_success "Minimal skill appropriate (complexity within thresholds)"
    return 0
}

# Check if skill has declared capabilities
has_capabilities() {
    local skill_dir="$1"
    local skill_md="$skill_dir/SKILL.md"
    if [[ ! -f "$skill_md" ]]; then
        return 1
    fi

    # Check for skill_sets or capabilities in frontmatter
    if grep -qE "^skill_sets:\s*\[" "$skill_md" 2>/dev/null; then
        # Check if the array is non-empty
        if grep -E "^skill_sets:\s*\[" "$skill_md" | grep -qv "\[\]"; then
            return 0
        fi
    fi
    if grep -qE "^capabilities:\s*\[" "$skill_md" 2>/dev/null; then
        if grep -E "^capabilities:\s*\[" "$skill_md" | grep -qv "\[\]"; then
            return 0
        fi
    fi

    return 1
}

# ============================================================================
# Complex Skill Reference File Validation
# ============================================================================
# Validates that Complex skills have at least one pattern-triggered reference file.
# Pattern-triggered files include: io-contract, phases, safety, examples,
# validation, checkpoints, orchestration, decisions, interaction, agents,
# composition, errors, glossary, or domain-specific files.

# List of capability-triggered reference files
# Mapping: capability → reference file
# phased → phases.md, branching → decisions.md, stateful/resumable → checkpoints.md
# self-validating → validation.md, safety-bounded → safety.md, etc.
PATTERN_TRIGGERED_FILES=(
    "io-contract.md"
    "phases.md"
    "safety.md"
    "examples.md"
    "validation.md"
    "checkpoints.md"
    "orchestration.md"
    "decisions.md"
    "interaction.md"
    "agents.md"
    "composition.md"
    "errors.md"
    "glossary.md"
    "idempotency.md"
    "cancellation.md"
    "dependencies.md"
)

# Check if skill is Complex archetype
# Complex skills have at least one pattern-triggered reference file
is_complex_skill() {
    local skill_dir="$1"
    local refs_dir="$skill_dir/references"

    if [[ ! -d "$refs_dir" ]]; then
        return 1  # No references directory = Atomic
    fi

    # Check for any pattern-triggered file
    for file in "${PATTERN_TRIGGERED_FILES[@]}"; do
        if [[ -f "$refs_dir/$file" ]]; then
            return 0  # Found at least one = Complex
        fi
    done

    # Also check for domain-specific files (any .md file in references/)
    local md_count
    md_count=$(find "$refs_dir" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    if [[ $md_count -gt 0 ]]; then
        return 0  # Has reference files = Complex
    fi

    return 1  # No pattern-triggered files = Atomic
}

# Count pattern-triggered files present
count_pattern_files() {
    local skill_dir="$1"
    local refs_dir="$skill_dir/references"
    local count=0

    if [[ ! -d "$refs_dir" ]]; then
        echo 0
        return
    fi

    for file in "${PATTERN_TRIGGERED_FILES[@]}"; do
        if [[ -f "$refs_dir/$file" ]]; then
            ((count++)) || true
        fi
    done

    echo $count
}

# Check for pattern-triggered files in Complex skills
# Complex skills must have at least one pattern-triggered reference file
check_complex_skill_files() {
    local skill_id="$1"
    local skill_dir="$2"
    local issues=0

    local refs_dir="$skill_dir/references"

    # If no references directory, this is an Atomic skill
    if [[ ! -d "$refs_dir" ]]; then
        return 0
    fi

    # Count pattern-triggered files
    local pattern_count
    pattern_count=$(count_pattern_files "$skill_dir")

    if [[ $pattern_count -eq 0 ]]; then
        # Check for any .md files (could be domain-specific)
        local md_count
        md_count=$(find "$refs_dir" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

        if [[ $md_count -eq 0 ]]; then
            log_warning "Skill has references/ directory but no pattern-triggered files"
            log_info "  Add at least one of: io-contract.md, phases.md, safety.md, etc."
            log_info "  Or remove references/ directory if this is an Atomic skill"
        fi
    else
        log_success "Complex skill has $pattern_count pattern-triggered reference file(s)"
    fi

    return $issues
}

validate_skill() {
    local skill_id="$1"
    local skill_dir="$SKILLS_DIR/$(get_skill_path "$skill_id")"
    
    echo ""
    echo "Validating: $skill_id"
    echo "─────────────────────────────"
    
    # Skip template
    if [[ "$skill_id" == "_template" ]]; then
        log_info "Skipping template directory"
        return 0
    fi
    if [[ "$skill_id" == "archive" ]] || [[ "$skill_dir" == */archive/* ]]; then
        log_info "Skipping archive directory"
        return 0
    fi
    
    # Check 1: Directory exists
    if [[ ! -d "$skill_dir" ]]; then
        log_error "Directory not found: $skill_dir"
        return 1
    fi
    log_success "Directory exists"
    
    # Check 2: SKILL.md exists
    if [[ ! -f "$skill_dir/SKILL.md" ]]; then
        log_error "SKILL.md not found in $skill_dir"
        return 1
    fi
    log_success "SKILL.md exists"
    
    # Check 3: SKILL.md name matches manifest id (grouped path variance is informational)
    local skill_name
    skill_name=$(get_skill_name "$skill_dir")
    local skill_path
    skill_path=$(get_skill_path "$skill_id")
    local parent_dir
    parent_dir=$(basename "${skill_path%/}")
    if [[ "$skill_name" != "$skill_id" ]]; then
        log_error "SKILL.md name '$skill_name' does not match manifest id '$skill_id'"
    elif [[ "$skill_name" != "$parent_dir" ]]; then
        log_info "Grouped-directory variance: SKILL.md name '$skill_name' matches id, parent dir is '$parent_dir' (intentional)"
    else
        log_success "SKILL.md name matches directory"
    fi
    
    # Check 4: Skill is in manifest
    if ! grep -q "id: $skill_id" "$MANIFEST"; then
        log_error "Skill not found in manifest.yml"
    else
        log_success "Listed in manifest.yml"
        if [[ "$STRICT_MODE" == "true" ]]; then
            validate_manifest_status_value "$skill_id" || true
        fi
    fi
    
    # Check 5: Skill is in registry
    if ! grep -q "^  $skill_id:" "$REGISTRY"; then
        log_error "Skill not found in registry.yml"
    else
        log_success "Listed in registry.yml"
        if [[ "$STRICT_MODE" == "true" ]]; then
            validate_registry_parameter_types "$skill_id" || true
            validate_registry_output_determinism "$skill_id" || true
        fi
    fi
    
    # Check 5b: display_name is present and follows Title Case convention
    local display_name
    display_name=$(get_manifest_display_name "$skill_id")
    if [[ -z "$display_name" ]]; then
        if [[ "$STRICT_DISPLAY_NAME" == "true" ]]; then
            log_error "Skill missing display_name in manifest.yml"
        else
            log_warning "Skill missing display_name in manifest.yml"
        fi
    else
        local display_name_result
        display_name_result=$(validate_display_name "$skill_id" "$display_name" 2>&1)
        local display_name_status=$?

        if [[ $display_name_status -eq 0 ]]; then
            log_success "display_name is valid: $display_name"
        else
            if [[ "$STRICT_DISPLAY_NAME" == "true" ]]; then
                log_error "display_name issue: $display_name_result"
            else
                log_warning "display_name issue: $display_name_result"
            fi
            log_info "  Expected: $(id_to_title_case "$skill_id")"
        fi
    fi
    
    # Check 6: No version in SKILL.md metadata (should be in registry only)
    if grep -q "^\s*version:" "$skill_dir/SKILL.md" 2>/dev/null; then
        # Check if it's under metadata
        if awk '/^metadata:/,/^[a-z]/' "$skill_dir/SKILL.md" | grep -q "version:"; then
            log_warning "Version found in SKILL.md metadata (should be in registry.yml only)"
        fi
    else
        log_success "No version drift in SKILL.md"
    fi
    
    # Check 7: No requires.tools in io-contract.md
    if ! check_io_contract_drift "$skill_dir"; then
        log_warning "requires.tools found in io-contract.md (should be in registry.yml only)"
    else
        log_success "No tool requirements drift in io-contract.md"
    fi
    
    # Check 8: No allowed tools list in safety.md
    if ! check_safety_drift "$skill_dir"; then
        log_warning "Allowed tools list found in safety.md (should be in registry.yml only)"
    else
        log_success "No tool requirements drift in safety.md"
    fi
    
    # Check 9: No duplicated tables in SKILL.md
    if ! check_table_drift "$skill_dir" "SKILL.md"; then
        log_warning "Parameter/tool table found in SKILL.md after 'source of truth' note (potential drift)"
    else
        log_success "No duplicated tables in SKILL.md"
    fi
    
    # Check 10: No duplicated tables in io-contract.md
    if ! check_table_drift "$skill_dir" "references/io-contract.md"; then
        log_warning "Parameter/tool table found in io-contract.md after 'source of truth' note (potential drift)"
    else
        log_success "No duplicated tables in io-contract.md"
    fi
    
    # Check 11: No duplicated tables in safety.md body
    if ! check_table_drift "$skill_dir" "references/safety.md"; then
        log_warning "Tool table found in safety.md after 'source of truth' note (potential drift)"
    else
        log_success "No duplicated tables in safety.md"
    fi
    
    # Check 12: No deprecated top-level outputs in registry.yml
    if check_deprecated_top_level_outputs "$skill_id"; then
        log_error "Deprecated outputs field found at skills.$skill_id.outputs (use skills.$skill_id.io.outputs)"
    else
        log_success "No deprecated top-level outputs in registry.yml"
    fi
    
    # Check 13: Skill has I/O mappings in skills registry
    if [[ -f "$SKILLS_REGISTRY" ]]; then
        if ! check_io_mappings "$skill_id"; then
            log_warning "MISSING I/O MAPPINGS: Skill '$skill_id' has no I/O configuration"
            log_info "  Skills without I/O mappings will use default output paths only."
            log_info "  To configure custom I/O paths, add an entry to:"
            log_info "    .octon/capabilities/runtime/skills/registry.yml → skills.$skill_id.io"
            log_info "  See .octon/capabilities/_meta/architecture/discovery.md#skills-registry"
            if [[ "$FIX_MODE" == "true" ]]; then
                scaffold_io_mapping "$skill_id"
            fi
        else
            log_success "I/O mappings present in skills registry"
        fi
    else
        log_warning "Skills registry not found: $SKILLS_REGISTRY"
    fi
    
    # Check 14: allowed-tools in SKILL.md is valid (single source of truth)
    local tool_check_result
    tool_check_result=$(validate_allowed_tools "$skill_id" "$skill_dir" 2>&1)
    local tool_check_status=$?
    
    if [[ $tool_check_status -eq 0 ]]; then
        local internal_tools
        internal_tools=$(get_skill_tools "$skill_dir")
        log_success "allowed-tools is valid: $internal_tools"

        local manifest_status
        manifest_status=$(get_manifest_status "$skill_id")

        validate_skill_policy_with_engine "$skill_id" "$skill_dir" || true

        # Active skills with external binary/toolchain usage must declare explicit capability.
        if [[ "$manifest_status" == "active" ]] && has_non_minimal_bash_permissions "$skill_dir"; then
            if declares_external_dependency_capability "$skill_id"; then
                log_success "External dependency capability declared for non-minimal Bash permissions"
            else
                log_error "Active skill uses non-minimal Bash permissions but does not declare external-dependent/external-output capability"
            fi
        fi
    else
        log_error "Invalid allowed-tools: $tool_check_result"
        log_info "  See .octon/capabilities/_meta/architecture/specification.md for allowed-tools format"
    fi

    # Check 15: allowed-services in SKILL.md resolves to services manifest entries
    local services_check_result
    services_check_result=$(validate_allowed_services "$skill_id" "$skill_dir" 2>&1)
    local services_check_status=$?

    if [[ $services_check_status -eq 0 ]]; then
        local allowed_services
        allowed_services=$(get_skill_allowed_services "$skill_dir" | tr '\n' ' ' | xargs)
        if [[ -n "$allowed_services" ]]; then
            log_success "allowed-services is valid: $allowed_services"
        else
            log_success "allowed-services not declared"
        fi
    else
        log_error "Invalid allowed-services: $services_check_result"
        log_info "  See .octon/capabilities/runtime/services/manifest.yml for valid service ids"
    fi

    # Check 15b: Declared skill sets and capabilities are valid values
    validate_declared_capabilities "$skill_id" "$skill_dir" || true

    # Check 15c: skill_class contract is valid
    validate_skill_class_contract "$skill_id" "$skill_dir" || true

    # Check 15d: Manifest and SKILL.md capability declarations are aligned
    validate_manifest_skill_parity "$skill_id" "$skill_dir" || true

    # Check 15e: composition contract is valid
    validate_skill_composition_contract "$skill_id" "$skill_dir" || true

    # Check 15f: Execution-profile governance contract for spec-to-implementation
    validate_spec_to_implementation_profile_contract "$skill_id" "$skill_dir" || true
    
    # Check 16: I/O path scope validation
    if [[ -f "$SKILLS_REGISTRY" ]]; then
        local scope_issues=0
        while IFS= read -r output_path; do
            if [[ -n "$output_path" ]]; then
                local validation_result
                validation_result=$(validate_path_scope "$output_path" "$REPO_ROOT/.octon/capabilities/runtime/skills/")
                if [[ -n "$validation_result" ]]; then
                    log_error "Output path scope violation: $validation_result"
                    ((scope_issues++)) || true
                fi
            fi
        done < <(get_output_paths "$skill_id")
        
        if [[ $scope_issues -eq 0 ]]; then
            log_success "Output paths within harness scope"
        fi
    fi
    
    if [[ "$VALIDATION_PROFILE" == "strict" ]]; then
        # Check 17: Token budget validation
        validate_token_budgets "$skill_id" "$skill_dir" || true

        # Check 18: Description/summary alignment
        local alignment_status=0
        check_description_summary_alignment "$skill_id" "$skill_dir" >/dev/null 2>&1 || alignment_status=$?

        if [[ $alignment_status -eq 0 ]]; then
            log_success "Description/summary alignment OK"
        else
            log_warning "Description/summary may need review (see SKILL.md description vs manifest summary)"
        fi

        # Check 18: Reference file content validation (io-contract.md, examples.md)
        local ref_content_status=0
        validate_reference_content "$skill_id" "$skill_dir" >/dev/null 2>&1 || ref_content_status=$?

        if [[ $ref_content_status -eq 0 ]]; then
            log_success "Reference file content aligns with registry"
        else
            log_warning "Reference content may need review (see io-contract.md vs registry.yml)"
        fi

        # Check 19: Placeholder format validation in registry paths
        if [[ -f "$SKILLS_REGISTRY" ]]; then
            local placeholder_issues=0
            validate_skill_placeholders "$skill_id" || placeholder_issues=$?
            check_deprecated_placeholder_formats "$skill_id" || ((placeholder_issues++)) || true

            if [[ $placeholder_issues -eq 0 ]]; then
                log_success "Placeholder formats valid ({{snake_case}})"
            fi
        fi

        # Check 20: Version staleness check
        local version_result version_status=0
        version_result=$(check_version_staleness "$skill_id" "$skill_dir" 2>&1) || version_status=$?

        if [[ $version_status -eq 0 ]]; then
            local current_version
            current_version=$(get_registry_version "$skill_id")
            log_success "Version OK: $current_version"
        else
            log_warning "Version review: $version_result"
            log_info "  Update version in .octon/capabilities/runtime/skills/registry.yml when making changes"
        fi

        # Check 21: Line count validation (per agentskills.io spec)
        local line_count
        line_count=$(get_skill_line_count "$skill_dir")

        if [[ $line_count -gt $SKILL_MD_LINE_BUDGET ]]; then
            log_warning "SKILL.md exceeds line budget ($line_count > $SKILL_MD_LINE_BUDGET lines)"
            log_info "  Per agentskills.io spec, move detailed content to references/"
        else
            log_success "SKILL.md within line budget ($line_count lines)"
        fi

        # Check 22: Reference file token budgets
        validate_reference_token_budgets "$skill_id" "$skill_dir" || true

        # Check 23: Aggregate complexity budget (total reference file tokens)
        validate_aggregate_complexity "$skill_id" "$skill_dir" || true

        # Check 24: Complex skill pattern-triggered files
        check_complex_skill_files "$skill_id" "$skill_dir" || true

        # Check 25: Capability heuristics (for minimal skills)
        validate_capability_heuristics "$skill_id" "$skill_dir" || true
    else
        log_info "dev-fast profile: skipped deep documentation/token checks"
    fi
}

validate_spec_to_implementation_profile_contract() {
    local skill_id="$1"
    local skill_dir="$2"

    if [[ "$skill_id" != "spec-to-implementation" ]]; then
        return 0
    fi

    local skill_md="$skill_dir/SKILL.md"
    local phases_ref="$skill_dir/references/phases.md"
    local io_ref="$skill_dir/references/io-contract.md"
    local validation_ref="$skill_dir/references/validation.md"
    local interaction_ref="$skill_dir/references/interaction.md"

    local missing=0
    local file
    for file in "$skill_md" "$phases_ref" "$io_ref" "$validation_ref" "$interaction_ref"; do
        if [[ ! -f "$file" ]]; then
            log_error "spec-to-implementation missing required reference file: ${file#$REPO_ROOT/}"
            ((missing++)) || true
        fi
    done
    if [[ $missing -gt 0 ]]; then
        return 1
    fi

    local key
    for key in "change_profile" "release_state" "transitional_exception_note"; do
        if ! grep -Fq "$key" "$skill_md"; then
            log_error "spec-to-implementation SKILL.md missing governance key: $key"
        fi
        if ! grep -Fq "$key" "$phases_ref"; then
            log_error "spec-to-implementation phases reference missing governance key: $key"
        fi
        if ! grep -Fq "$key" "$io_ref"; then
            log_error "spec-to-implementation io-contract reference missing governance key: $key"
        fi
    done

    local section
    for section in \
        "Profile Selection Receipt" \
        "Implementation Plan" \
        "Impact Map (code, tests, docs, contracts)" \
        "Compliance Receipt" \
        "Exceptions/Escalations"; do
        if ! grep -Fq "$section" "$skill_md"; then
            log_error "spec-to-implementation SKILL.md missing required output section: $section"
        fi
        if ! grep -Fq "$section" "$phases_ref"; then
            log_error "spec-to-implementation phases reference missing required output section: $section"
        fi
        if ! grep -Fq "$section" "$validation_ref"; then
            log_error "spec-to-implementation validation reference missing required output section: $section"
        fi
    done

    if ! grep -Fq 'pre-1.0' "$validation_ref"; then
        log_error "spec-to-implementation validation reference missing pre-1.0 rule checks"
    fi
    if ! grep -Fq 'tie-break' "$interaction_ref"; then
        log_error "spec-to-implementation interaction reference missing tie-break escalation behavior"
    fi

    if ! grep -Fq 'change_profile' "$SKILLS_REGISTRY"; then
        log_error "skills registry missing change_profile parameter for spec-to-implementation"
    fi
    if ! grep -Fq 'release_state' "$SKILLS_REGISTRY"; then
        log_error "skills registry missing release_state parameter for spec-to-implementation"
    fi
    if ! grep -Fq 'transitional_exception_note' "$SKILLS_REGISTRY"; then
        log_error "skills registry missing transitional_exception_note parameter for spec-to-implementation"
    fi

    log_success "spec-to-implementation execution-profile governance contract validated"
}

# Main
echo "================================"
echo "Skills Validation"
echo "================================"
echo "Skills directory: $SKILLS_DIR"
echo "Manifest: $MANIFEST"
echo "Registry: $REGISTRY"
echo "Validation profile: $VALIDATION_PROFILE"
if [[ "$REGISTRY" == "$SKILLS_REGISTRY" ]]; then
    echo "Skills registry: $SKILLS_REGISTRY (single-registry mode)"
else
    echo "Skills registry: $SKILLS_REGISTRY"
fi

load_capabilities_authority

if [[ ! -f "$MANIFEST" ]]; then
    log_error "Manifest file not found: $MANIFEST"
    exit 1
fi

if [[ ! -f "$REGISTRY" ]]; then
    log_error "Registry file not found: $REGISTRY"
    exit 1
fi

if [[ ! -f "$SKILLS_REGISTRY" ]]; then
    log_warning "Skills registry not found (I/O validation will be skipped)"
fi

if [[ ! -f "$EXCEPTIONS_FILE" ]]; then
    log_warning "Deny-by-default exceptions file not found: $EXCEPTIONS_FILE"
fi

if [[ -x "$AGENT_ONLY_VALIDATOR" ]]; then
    if ! "$AGENT_ONLY_VALIDATOR" "$AGENT_ONLY_POLICY_FILE" >/dev/null 2>&1; then
        if [[ "$VALIDATION_PROFILE" == "strict" ]]; then
            log_error "Agent-only governance policy validation failed: $AGENT_ONLY_POLICY_FILE"
        else
            log_warning "Agent-only governance policy validation failed: $AGENT_ONLY_POLICY_FILE"
        fi
    else
        log_success "Agent-only governance policy validated"
    fi
elif [[ "$VALIDATION_PROFILE" == "strict" ]]; then
    log_error "Missing agent-only governance validator: $AGENT_ONLY_VALIDATOR"
else
    log_warning "Missing agent-only governance validator: $AGENT_ONLY_VALIDATOR"
fi

# Report token counting method
if [[ "$VALIDATION_PROFILE" == "strict" ]]; then
    if [[ "$TIKTOKEN_AVAILABLE" == "true" ]]; then
        echo "Token counting: tiktoken (accurate)"
    else
        echo "Token counting: word count approximation (±20% variance)"
        log_info "  For accurate token validation, install: pip install tiktoken"
        log_info "  Recommended for CI environments."
    fi
else
    echo "Token counting: skipped (dev-fast profile)"
fi

# Report fix mode
if [[ "$FIX_MODE" == "true" ]]; then
    echo "Fix mode: ENABLED (will scaffold missing entries)"
fi

# Report strict modes
if [[ "$STRICT_MODE" == "true" ]]; then
    echo "Strict mode: ENABLED (trigger duplicates are errors)"
fi
if [[ "$STRICT_DISPLAY_NAME" == "true" ]]; then
    echo "Strict display_name: ENABLED (naming violations are errors)"
fi

if [[ -n "$1" ]]; then
    # Validate single skill
    validate_skill "$1"
else
    # Validate all skills from manifest
    echo ""
    echo "Scanning manifest for skills..."
    
    # Use for loop with skill list
    for skill_id in $(get_manifest_skills); do
        validate_skill "$skill_id" </dev/null
    done
    
    if [[ "$VALIDATION_PROFILE" == "strict" ]]; then
        # Check for orphaned directories (directories not in manifest)
        echo ""
        echo "Checking for orphaned skill directories..."
        echo "─────────────────────────────"

        # Skip known infrastructure directories and schema-defined groups.
        # Include legacy names for backward compatibility during migration windows.
        infra_dirs="_scaffold _ops archive _template _scripts _state"
        group_dirs=""
        group_dirs=$(yaml_hash_keys "$CAPABILITIES_SCHEMA" "skill_group_definitions" | sort -u)

        for dir in "$SKILLS_DIR"/*/; do
            dir_name=$(basename "$dir")
            if echo "$infra_dirs" | grep -qw "$dir_name"; then
                continue
            fi
            if echo "$group_dirs" | grep -qw "$dir_name"; then
                continue
            fi
            if ! grep -q "id: $dir_name" "$MANIFEST"; then
                log_warning "Directory '$dir_name' exists but not listed in manifest"
            fi
        done

        # Check for trigger overlap between skills
        echo ""
        echo "Checking for trigger overlaps..."
        echo "─────────────────────────────"
        check_trigger_overlaps

        # Cross-reference validation (manifest ↔ registry)
        check_manifest_registry_sync

        # Clean-break guardrails for retired registry surfaces
        if rg -q "^[[:space:]]*depends_on:" "$REGISTRY"; then
            log_error "Legacy depends_on contract still present in skills registry"
        fi
        if rg -q "^pipelines:" "$REGISTRY"; then
            log_error "Legacy top-level pipelines surface still present in skills registry"
        fi

        # Legacy path regression guard
        check_deprecated_paths
    else
        log_info "dev-fast profile: skipped global manifest drift checks (orphan dirs/triggers/cross-ref)"
    fi
fi

if [[ $errors -eq 0 ]]; then
    policy_compiler="$SKILLS_DIR/_ops/scripts/compile-deny-by-default-policy.sh"
    if [[ -x "$policy_compiler" ]]; then
        catalog_path="$("$policy_compiler" 2>/dev/null)"
        if [[ -n "$catalog_path" ]]; then
            log_success "Compiled deny-by-default skill policy catalog: $catalog_path"
        else
            log_warning "Failed to compile deny-by-default skill policy catalog"
        fi
    fi
fi

# Summary
echo ""
echo "================================"
echo "Validation Summary"
echo "================================"
if [[ $errors -gt 0 ]]; then
    echo -e "${RED}Errors: $errors${NC}"
fi
if [[ $warnings -gt 0 ]]; then
    echo -e "${YELLOW}Warnings: $warnings${NC}"
fi
if [[ $errors -eq 0 ]] && [[ $warnings -eq 0 ]]; then
    echo -e "${GREEN}All checks passed!${NC}"
fi

exit $errors
