#!/bin/bash
# validate-skills.sh - Validate skill consistency across manifest, registry, and SKILL.md
#
# Usage: ./validate-skills.sh [options] [skill-id]
#   If skill-id is provided, validates only that skill
#   If no arguments, validates all skills
#
# Options:
#   --strict              Treat trigger duplicates as errors (not warnings)
#   --strict-display-name Treat display_name convention violations as errors
#   --fix                 Auto-fix issues where possible (scaffold missing entries)
#   --help                Show this help message
#
# Checks:
#   1. Directory exists
#   2. SKILL.md exists
#   3. SKILL.md name matches directory name (per agentskills.io spec)
#   4. Skill is in manifest
#   5. Skill is in registry
#   5b. display_name is present in manifest
#   6. No version in SKILL.md metadata (should be in registry only)
#   7. No requires.tools in io-contract.md (drift prevention)
#   8. No allowed tools list in safety.md (drift prevention)
#   9. No duplicated parameter/tool tables in SKILL.md
#   10. No duplicated parameter/tool tables in io-contract.md
#   11. No duplicated tool tables in safety.md body
#   12. No outputs in shared registry (should be in workspace registry)
#   13. Skill has I/O mappings in workspace registry
#   14. allowed-tools in SKILL.md is present and valid (single source of truth)
#   15. Trigger overlap detection (warns on duplicate/similar triggers)
#   16. Workspace I/O path scope validation
#   17. Token budget validation (SKILL.md < 5000 tokens, manifest entry < 100 tokens)
#   18. Description/summary alignment (summary should be subset of description)
#   19. Cross-reference validation (all manifest skills have registry entries and vice versa)
#   20. Reference file content validation (io-contract.md parameters match registry, examples use correct commands)
#   21. Placeholder format validation ({{snake_case}} in workspace registry paths)
#   22. Version staleness check (warns if version is 1.0.0 for mature skills)
#   23. Line count validation (SKILL.md < 500 lines per agentskills.io spec)
#   24. Reference file token budgets (io-contract, safety, examples, behaviors, validation)
#   25. Aggregate complexity budget (total reference file tokens vs complexity thresholds)
#   26. Capability-triggered file validation (references match declared capabilities)
#   27. Skill set and capability validation (valid values, reference file matching)
#
# Capability Model:
#   Skills declare skill_sets (bundles) and capabilities in manifest.yml and SKILL.md.
#   Each capability maps to specific reference files:
#   - phased → phases.md
#   - branching → decisions.md
#   - stateful/resumable → checkpoints.md
#   - self-validating → validation.md
#   - safety-bounded → safety.md
#   See: docs/architecture/workspaces/skills/capabilities.md
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

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(dirname "$SCRIPT_DIR")"
HARMONY_DIR="$(dirname "$SKILLS_DIR")"
REPO_ROOT="$(dirname "$HARMONY_DIR")"
MANIFEST="$SKILLS_DIR/manifest.yml"
REGISTRY="$SKILLS_DIR/registry.yml"
WORKSPACE_REGISTRY="$REPO_ROOT/.harmony/capabilities/skills/registry.yml"

# Configuration
STRICT_MODE=false
STRICT_DISPLAY_NAME=false
FIX_MODE=false
SKILL_MD_TOKEN_BUDGET=5000
SKILL_MD_LINE_BUDGET=500
MANIFEST_ENTRY_TOKEN_BUDGET=100

# Reference file token budgets (hard limits from reference-artifacts.md)
IO_CONTRACT_TOKEN_BUDGET=1000
SAFETY_TOKEN_BUDGET=1000
EXAMPLES_TOKEN_BUDGET=2000
PHASES_TOKEN_BUDGET=1500
VALIDATION_TOKEN_BUDGET=800

# Valid skill sets and capabilities
VALID_SKILL_SETS=("executor" "coordinator" "delegator" "collaborator" "integrator" "specialist" "guardian")
VALID_CAPABILITIES=("phased" "branching" "parallel" "task-coordinating" "agent-delegating" "human-collaborative" "stateful" "resumable" "self-validating" "error-resilient" "composable" "contract-driven" "domain-specialized" "safety-bounded" "idempotent" "cancellable" "external-dependent")

# Aggregate complexity budgets (from reference-artifacts.md Common Profiles section)
# These are soft limits that trigger warnings, not errors
AGGREGATE_STANDARD_BUDGET=7000    # Standard Complex skill
AGGREGATE_ENTERPRISE_BUDGET=12000 # Enterprise Complex skill
AGGREGATE_DOMAIN_BUDGET=15000     # Domain Expert skill (may legitimately exceed)

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
        --help)
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

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

# Extract skill IDs from manifest
get_manifest_skills() {
    grep -E "^\s*- id:" "$MANIFEST" | sed 's/.*id:\s*//' | tr -d '"' | tr -d "'" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# Get display_name for a skill from manifest
get_manifest_display_name() {
    local skill_id="$1"
    # Find the skill entry and extract display_name
    awk -v id="$skill_id" '
        $0 ~ "- id: "id {found=1; next}
        found && /display_name:/ {gsub(/.*display_name:\s*/, ""); gsub(/["'"'"']/, ""); gsub(/^[[:space:]]+|[[:space:]]+$/, ""); print; exit}
        found && /^  - id:/ {exit}
    ' "$MANIFEST"
}

# Convert skill id (kebab-case) to expected Title Case display_name
# Example: "synthesize-research" -> "Synthesize Research"
id_to_title_case() {
    local skill_id="$1"
    echo "$skill_id" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1'
}

# Validate display_name follows Title Case convention from id
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

    if [[ "$display_name" != "$expected_name" ]]; then
        echo "display_name '$display_name' does not match expected Title Case '$expected_name'"
        return 1
    fi

    return 0
}

# Get triggers for a skill from manifest
get_skill_triggers() {
    local skill_id="$1"
    # Extract triggers array for a skill
    awk -v id="$skill_id" '
        $0 ~ "- id: "id {found=1; next}
        found && /triggers:/ {in_triggers=1; next}
        found && in_triggers && /^      - / {gsub(/^      - ["'"'"']?/, ""); gsub(/["'"'"']$/, ""); print}
        found && in_triggers && /^    [a-z]/ {exit}
        found && /^  - id:/ {exit}
    ' "$MANIFEST"
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
# and the internal registry format used by Harmony routing.
#
# allowed-tools in SKILL.md is the SINGLE SOURCE OF TRUTH for tool permissions.
# ============================================================================

# Mapping table: allowed-tools (SKILL.md) -> internal format
# This is the authoritative mapping used for routing and validation.
#
# | allowed-tools (SKILL.md)   | Internal Format           | Description              |
# |----------------------------|---------------------------|--------------------------|
# | Read                       | filesystem.read           | Read files               |
# | Write(runs/*)              | filesystem.write.runs     | Write execution state (session recovery) |
# | Write(logs/*)              | filesystem.write.logs     | Write to logs dir        |
# | Write(../{category}/*)     | filesystem.write.deliverables | Write deliverables   |
# | Glob                       | filesystem.glob           | Pattern file discovery   |
# | Grep                       | filesystem.grep           | Content search           |
# | WebFetch                   | network.fetch             | HTTP requests (read)     |
# | Shell                      | shell.execute             | Execute shell commands   |
# | Task                       | agent.task                | Launch subagent tasks    |

# Convert a single allowed-tools entry to internal format
# Usage: map_allowed_to_internal "Read" -> "filesystem.read"
map_allowed_to_internal() {
    local allowed="$1"
    case "$allowed" in
        Read)                    echo "filesystem.read" ;;
        Write\(runs/\*\))        echo "filesystem.write.runs" ;;
        Write\(logs/\*\))        echo "filesystem.write.logs" ;;
        Write\(../*\))           echo "filesystem.write.deliverables" ;;
        Glob)                    echo "filesystem.glob" ;;
        Grep)                    echo "filesystem.grep" ;;
        WebFetch)                echo "network.fetch" ;;
        Shell)                   echo "shell.execute" ;;
        Task)                    echo "agent.task" ;;
        *)                       echo "" ;;  # Unknown mapping
    esac
}

# Convert all allowed-tools from SKILL.md to internal format
# Usage: get_internal_tools_from_skill "/path/to/skill"
# Returns space-separated list of internal tool names
get_internal_tools_from_skill() {
    local skill_dir="$1"
    local allowed_tools
    allowed_tools=$(get_skill_allowed_tools "$skill_dir")
    
    local internal_tools=""
    for allowed in $allowed_tools; do
        local mapped
        mapped=$(map_allowed_to_internal "$allowed")
        if [[ -n "$mapped" ]]; then
            internal_tools="$internal_tools $mapped"
        fi
    done
    echo "$internal_tools" | xargs  # Trim whitespace
}

# Validate allowed-tools format
# Returns 0 if valid, 1 if invalid with error message
validate_allowed_tools_format() {
    local skill_dir="$1"
    local allowed_tools
    allowed_tools=$(get_skill_allowed_tools "$skill_dir")
    
    if [[ -z "$allowed_tools" ]]; then
        echo "allowed-tools not found in SKILL.md frontmatter"
        return 1
    fi
    
    local invalid=""
    for allowed in $allowed_tools; do
        local mapped
        mapped=$(map_allowed_to_internal "$allowed")
        if [[ -z "$mapped" ]]; then
            invalid="${invalid}${allowed}, "
        fi
    done
    
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

# Get allowed-tools from SKILL.md frontmatter
get_skill_allowed_tools() {
    local skill_dir="$1"
    local skill_md="$skill_dir/SKILL.md"
    if [[ -f "$skill_md" ]]; then
        # Extract allowed-tools line and split by space
        grep -E "^allowed-tools:" "$skill_md" | head -1 | sed 's/allowed-tools:[[:space:]]*//' | tr ' ' '\n'
    fi
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

# Check if shared registry has outputs for a skill (drift issue - outputs should be in workspace registry)
check_shared_registry_outputs() {
    local skill_id="$1"
    # Check if the skill section in shared registry has an outputs: key
    awk -v skill="$skill_id" '
        $0 ~ "^  "skill":" {found=1; next}
        found && /^  [a-z]/ && $0 !~ "^  "skill":" {exit}
        found && /^\s*outputs:/ {print "found"; exit}
    ' "$REGISTRY" | grep -q "found"
}

# Check if workspace registry has I/O mappings for a skill
check_workspace_io_mappings() {
    local skill_id="$1"
    if [[ ! -f "$WORKSPACE_REGISTRY" ]]; then
        return 1  # No workspace registry
    fi
    # Check if skill_mappings section contains this skill
    grep -q "^  $skill_id:" "$WORKSPACE_REGISTRY" 2>/dev/null
}

# ============================================================================
# Workspace I/O Path Scope Validation
# ============================================================================
# Validates that output paths in workspace registry are within hierarchical scope.
# Paths must not escape upward (../) to ancestor workspaces.

# Get output paths for a skill from workspace registry
get_workspace_output_paths() {
    local skill_id="$1"
    if [[ ! -f "$WORKSPACE_REGISTRY" ]]; then
        return
    fi
    # Extract output paths from skill_mappings section
    awk -v skill="$skill_id" '
        /^skill_mappings:/ {in_mappings=1; next}
        in_mappings && $0 ~ "^  "skill":" {found=1; next}
        found && /^  [a-z]/ && $0 !~ "^  "skill":" {exit}
        found && /outputs:/ {in_outputs=1; next}
        found && in_outputs && /^      - path:/ {gsub(/^      - path:[[:space:]]*["'"'"']?/, ""); gsub(/["'"'"']$/, ""); print}
        found && in_outputs && /^    [a-z]/ && !/^      / {exit}
    ' "$WORKSPACE_REGISTRY"
}

# Validate that a path is within workspace scope
# Note: Paths starting with ../../ are allowed for deliverables that go to .harmony/output/{category}/
validate_path_scope() {
    local path="$1"
    local workspace_root="$2"
    
    # Allow ../ paths for deliverables going to .harmony/output/{category}/
    # These are intentional - deliverables go to final destination outside skills/
    if [[ "$path" == ../../* ]]; then
        # This is expected for deliverables like ../../drafts/ or ../../prompts/
        return 0
    fi
    
    # Check for deeper path traversal attempts (more than two levels up)
    if [[ "$path" == */../../../* ]]; then
        echo "Path escapes workspace scope: $path"
        return 1
    fi
    
    # Resolve the path and check it's within workspace
    local resolved_path
    if [[ "$path" == /* ]]; then
        # Absolute path - must start with workspace root
        if [[ "$path" != "$workspace_root"* ]]; then
            echo "Absolute path outside workspace: $path"
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
            validation_result=$(validate_path_scope "$output_path" "$REPO_ROOT/.harmony/capabilities/skills/")
            if [[ -n "$validation_result" ]]; then
                log_error "Skill '$skill_id': $validation_result"
                ((issues++)) || true
            fi
        fi
    done < <(get_workspace_output_paths "$skill_id")
    
    return $issues
}

# ============================================================================
# Placeholder Format Validation
# ============================================================================
# Validates that path placeholders in workspace registry use correct format.
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

# Validate all placeholders in workspace registry paths for a skill
validate_skill_placeholders() {
    local skill_id="$1"
    local issues=0

    if [[ ! -f "$WORKSPACE_REGISTRY" ]]; then
        return 0
    fi

    # Get all paths (inputs and outputs) for this skill
    local paths
    paths=$(awk -v skill="$skill_id" '
        /^skill_mappings:/ {in_mappings=1; next}
        in_mappings && $0 ~ "^  "skill":" {found=1; next}
        found && /^  [a-z]/ && $0 !~ "^  "skill":" {exit}
        found && /path:/ {gsub(/.*path:[[:space:]]*["'"'"']?/, ""); gsub(/["'"'"']$/, ""); print}
    ' "$WORKSPACE_REGISTRY")

    while IFS= read -r path; do
        if [[ -n "$path" ]]; then
            # Extract and validate each placeholder
            while IFS= read -r placeholder; do
                if [[ -n "$placeholder" ]]; then
                    local validation_result
                    validation_result=$(validate_placeholder_format "$placeholder" 2>&1)
                    if [[ $? -ne 0 ]]; then
                        log_warning "Path '$path': $validation_result"
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

    if [[ ! -f "$WORKSPACE_REGISTRY" ]]; then
        return 0
    fi

    # Check for <placeholder> format (deprecated)
    if awk -v skill="$skill_id" '
        /^skill_mappings:/ {in_mappings=1; next}
        in_mappings && $0 ~ "^  "skill":" {found=1; next}
        found && /^  [a-z]/ && $0 !~ "^  "skill":" {exit}
        found && /path:/ && /<[a-z_]+>/ {print; found_dep=1}
        END {exit !found_dep}
    ' "$WORKSPACE_REGISTRY" 2>/dev/null; then
        log_warning "Deprecated <placeholder> format found (use {{placeholder}} instead)"
        return 1
    fi

    # Check for {placeholder} format (single braces - easy mistake)
    if awk -v skill="$skill_id" '
        /^skill_mappings:/ {in_mappings=1; next}
        in_mappings && $0 ~ "^  "skill":" {found=1; next}
        found && /^  [a-z]/ && $0 !~ "^  "skill":" {exit}
        found && /path:/ && /\{[a-z_]+\}/ && !/\{\{/ {print; found_dep=1}
        END {exit !found_dep}
    ' "$WORKSPACE_REGISTRY" 2>/dev/null; then
        log_warning "Single-brace {placeholder} format found (use {{placeholder}} instead)"
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
        $0 ~ "- id: "id {found=1}
        found {print}
        found && /^  - id:/ && $0 !~ "- id: "id {exit}
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
#   - Standard Complex: ~7000 tokens (2-4 reference files)
#   - Enterprise Complex: ~12000 tokens (4-6 reference files)
#   - Domain Expert: ~15000 tokens (5-8 reference files, domain knowledge extensive)
#
# See: docs/architecture/workspaces/skills/reference-artifacts.md#complexity-budget

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
        log_info "  See: docs/architecture/workspaces/skills/reference-artifacts.md#reducing-complexity"
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
        $0 ~ "- id: "id {found=1; next}
        found && /summary:/ {gsub(/.*summary:\s*["'"'"']?/, ""); gsub(/["'"'"']$/, ""); print; exit}
        found && /^  - id:/ {exit}
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
    local skill_dir="$SKILLS_DIR/$skill_id"
    
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
          path: \".harmony/\"
          description: \"Requires a .harmony directory\"
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
    local skill_dir="$SKILLS_DIR/$skill_id"
    
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
    
    # Truncate description for summary (first sentence or 80 chars)
    local summary
    summary=$(echo "$description" | cut -d. -f1 | head -c 80)
    
    local scaffold="
  - id: ${skill_id}
    display_name: ${display_name}
    path: ${skill_id}/
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

# Scaffold missing workspace I/O mapping
scaffold_workspace_mapping() {
    local skill_id="$1"
    
    log_info "  Scaffolding workspace I/O mapping for '$skill_id'..."
    
    local scaffold="
  ${skill_id}:
    inputs:
      - path: \"sources/{{category}}/\"
        kind: directory
        required: false
        description: \"Optional input source folder\"
    outputs:
      - name: result
        path: \"../../{category}/{{timestamp}}-${skill_id}.md\"
        kind: file
        format: markdown
        determinism: stable
        description: \"Skill output document\"
      - name: run_log
        path: \"logs/runs/{{timestamp}}-${skill_id}.md\"
        kind: file
        format: markdown
        determinism: unique
        description: \"Execution log\""
    
    echo ""
    echo "Add the following to ${WORKSPACE_REGISTRY} under skill_mappings:"
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
# Warns when a skill has version "1.0.0" but appears mature (has reference files).
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
        # Check if skill appears mature (has reference files)
        if has_reference_files "$skill_dir"; then
            local ref_count
            ref_count=$(count_reference_files "$skill_dir")
            echo "Version is 1.0.0 but skill has $ref_count reference files (consider version bump if production-ready)"
            return 1
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

    # Look for human-in-the-loop indicators
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

    # Check 4: Human-in-the-loop patterns → suggest 'collaborator' skill set
    if has_interaction_patterns "$skill_dir"; then
        suggestions="${suggestions}\n  - Contains human-in-the-loop patterns → consider 'collaborator' skill set"
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
        log_info "  See: docs/architecture/workspaces/skills/capabilities.md"
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
# Pattern-triggered files include: io-contract, behaviors, safety, examples,
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
            log_info "  Add at least one of: io-contract.md, behaviors.md, safety.md, etc."
            log_info "  Or remove references/ directory if this is an Atomic skill"
        fi
    else
        log_success "Complex skill has $pattern_count pattern-triggered reference file(s)"
    fi

    return $issues
}

validate_skill() {
    local skill_id="$1"
    local skill_dir="$SKILLS_DIR/$skill_id"
    
    echo ""
    echo "Validating: $skill_id"
    echo "─────────────────────────────"
    
    # Skip template
    if [[ "$skill_id" == "_template" ]]; then
        log_info "Skipping template directory"
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
    
    # Check 3: SKILL.md name matches directory name
    local skill_name
    skill_name=$(get_skill_name "$skill_dir")
    if [[ "$skill_name" != "$skill_id" ]]; then
        log_error "SKILL.md name '$skill_name' does not match directory '$skill_id'"
    else
        log_success "SKILL.md name matches directory"
    fi
    
    # Check 4: Skill is in manifest
    if ! grep -q "id: $skill_id" "$MANIFEST"; then
        log_error "Skill not found in manifest.yml"
    else
        log_success "Listed in manifest.yml"
    fi
    
    # Check 5: Skill is in registry
    if ! grep -q "^  $skill_id:" "$REGISTRY"; then
        log_error "Skill not found in registry.yml"
    else
        log_success "Listed in registry.yml"
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
    
    # Check 12: No outputs in shared registry (should be in workspace registry only)
    if check_shared_registry_outputs "$skill_id"; then
        log_error "Outputs found in shared registry (should be in .harmony/capabilities/skills/registry.yml only)"
    else
        log_success "No outputs in shared registry"
    fi
    
    # Check 13: Skill has I/O mappings in workspace registry
    if [[ -f "$WORKSPACE_REGISTRY" ]]; then
        if ! check_workspace_io_mappings "$skill_id"; then
            log_warning "MISSING I/O MAPPINGS: Skill '$skill_id' has no workspace I/O configuration"
            log_info "  Skills without workspace mappings will use default output paths only."
            log_info "  To configure custom I/O paths, add an entry to:"
            log_info "    .harmony/capabilities/skills/registry.yml → skill_mappings.$skill_id"
            log_info "  See docs/architecture/workspaces/skills/discovery.md#workspace-registry"
            if [[ "$FIX_MODE" == "true" ]]; then
                scaffold_workspace_mapping "$skill_id"
            fi
        else
            log_success "I/O mappings present in workspace registry"
        fi
    else
        log_warning "Workspace registry not found: $WORKSPACE_REGISTRY"
    fi
    
    # Check 14: allowed-tools in SKILL.md is valid (single source of truth)
    local tool_check_result
    tool_check_result=$(validate_allowed_tools "$skill_id" "$skill_dir" 2>&1)
    local tool_check_status=$?
    
    if [[ $tool_check_status -eq 0 ]]; then
        local internal_tools
        internal_tools=$(get_skill_tools "$skill_dir")
        log_success "allowed-tools is valid: $internal_tools"
    else
        log_error "Invalid allowed-tools: $tool_check_result"
        log_info "  See docs/architecture/workspaces/skills/specification.md for allowed-tools format"
    fi
    
    # Check 15: Workspace I/O path scope validation
    if [[ -f "$WORKSPACE_REGISTRY" ]]; then
        local scope_issues=0
        while IFS= read -r output_path; do
            if [[ -n "$output_path" ]]; then
                local validation_result
                validation_result=$(validate_path_scope "$output_path" "$REPO_ROOT/.harmony/capabilities/skills/")
                if [[ -n "$validation_result" ]]; then
                    log_error "Output path scope violation: $validation_result"
                    ((scope_issues++)) || true
                fi
            fi
        done < <(get_workspace_output_paths "$skill_id")
        
        if [[ $scope_issues -eq 0 ]]; then
            log_success "Output paths within workspace scope"
        fi
    fi
    
    # Check 16: Token budget validation
    validate_token_budgets "$skill_id" "$skill_dir" || true

    # Check 17: Description/summary alignment
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

    # Check 19: Placeholder format validation in workspace registry paths
    if [[ -f "$WORKSPACE_REGISTRY" ]]; then
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
        log_info "  Update version in .harmony/capabilities/skills/registry.yml when making changes"
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
}

# Main
echo "================================"
echo "Skills Validation"
echo "================================"
echo "Skills directory: $SKILLS_DIR"
echo "Manifest: $MANIFEST"
echo "Shared registry: $REGISTRY"
echo "Workspace registry: $WORKSPACE_REGISTRY"

if [[ ! -f "$MANIFEST" ]]; then
    log_error "Manifest file not found: $MANIFEST"
    exit 1
fi

if [[ ! -f "$REGISTRY" ]]; then
    log_error "Registry file not found: $REGISTRY"
    exit 1
fi

if [[ ! -f "$WORKSPACE_REGISTRY" ]]; then
    log_warning "Workspace registry not found (I/O validation will be skipped)"
fi

# Report token counting method
if [[ "$TIKTOKEN_AVAILABLE" == "true" ]]; then
    echo "Token counting: tiktoken (accurate)"
else
    echo "Token counting: word count approximation (±20% variance)"
    log_info "  For accurate token validation, install: pip install tiktoken"
    log_info "  Recommended for CI environments."
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
    
    # Check for orphaned directories (directories not in manifest)
    echo ""
    echo "Checking for orphaned skill directories..."
    echo "─────────────────────────────"
    
    for dir in "$SKILLS_DIR"/*/; do
        dir_name=$(basename "$dir")
        if [[ "$dir_name" == "_template" ]] || [[ "$dir_name" == "scripts" ]]; then
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
