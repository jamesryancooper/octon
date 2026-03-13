#!/bin/bash
# generate-reference-headers.sh - Generate/update reference file headers from authoritative sources
#
# Usage: ./generate-reference-headers.sh [skill-id]
#   If skill-id is provided, updates only that skill's reference files
#   If no arguments, updates all skills
#
# This script reads authoritative sources and generates standardized headers
# for io-contract.md and safety.md reference files. It preserves the body
# content while updating the header comments.
#
# Authoritative Sources:
#   - Tool permissions: SKILL.md frontmatter `allowed-tools`
#   - Parameters: .octon/capabilities/runtime/skills/registry.yml
#   - Output paths: .octon/capabilities/runtime/skills/registry.yml

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
OCTON_DIR="$(dirname "$(dirname "$SKILLS_DIR")")"
REPO_ROOT="$(dirname "$OCTON_DIR")"
MANIFEST="$SKILLS_DIR/manifest.yml"
REGISTRY="$SKILLS_DIR/registry.yml"
SKILLS_REGISTRY="$REPO_ROOT/.octon/capabilities/runtime/skills/registry.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_info() {
    echo "  $1"
}

log_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

log_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

# Get allowed-tools from SKILL.md
get_allowed_tools() {
    local skill_dir="$1"
    local skill_md="$skill_dir/SKILL.md"
    if [[ -f "$skill_md" ]]; then
        grep -E "^allowed-tools:" "$skill_md" | head -1 | sed 's/allowed-tools:[[:space:]]*//'
    fi
}

# Get parameters from registry for a skill
get_skill_parameters() {
    local skill_id="$1"
    awk -v skill="$skill_id" '
        /^skills:/ {in_skills=1; next}
        in_skills && $0 ~ "^  "skill":" {found=1; next}
        found && /^  [a-z]/ && $0 !~ "^  "skill":" {exit}
        found && /parameters:/ {in_params=1; next}
        found && in_params && /^      - name:/ {
            gsub(/^      - name:[[:space:]]*/, "")
            gsub(/["'"'"']/, "")
            print
        }
        found && in_params && /^    [a-z]/ && !/^      / {exit}
    ' "$REGISTRY"
}

# Generate io-contract.md header
generate_io_contract_header() {
    local skill_id="$1"
    local skill_dir="$2"
    local allowed_tools
    allowed_tools=$(get_allowed_tools "$skill_dir")
    
    cat << EOF
---
# I/O Contract Documentation
# This file provides extended documentation for human reference.
#
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter \`allowed-tools\`
#   - Parameters: .octon/capabilities/runtime/skills/registry.yml
#   - Output paths: .octon/capabilities/runtime/skills/registry.yml
#
# Current allowed-tools: $allowed_tools
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---
EOF
}

# Generate safety.md header  
generate_safety_header() {
    local skill_id="$1"
    local skill_dir="$2"
    local skill_name
    skill_name=$(basename "$skill_dir")
    local allowed_tools
    allowed_tools=$(get_allowed_tools "$skill_dir")
    
    cat << EOF
---
title: Safety Reference
description: Safety policies and constraints for the $skill_name skill.
# AUTHORITATIVE SOURCES (Single Source of Truth):
#   - Tool permissions: SKILL.md frontmatter \`allowed-tools\`
#   - Output paths: .octon/capabilities/runtime/skills/registry.yml
#
# Current allowed-tools: $allowed_tools
#
# Prose descriptions below are derived from these sources.
# If discrepancies exist, the authoritative sources are correct.
---
EOF
}

# Update a reference file with new header, preserving body
update_reference_file() {
    local file="$1"
    local new_header="$2"
    local temp_file
    temp_file=$(mktemp)
    local backup_file
    backup_file=$(mktemp)
    
    if [[ ! -f "$file" ]]; then
        log_warning "File not found: $file"
        return 1
    fi
    
    # Create backup before modifying
    cp "$file" "$backup_file"
    
    # Extract body content (everything after the closing ---)
    local body_start
    body_start=$(awk '/^---$/ {count++; if(count==2) {print NR; exit}}' "$file")
    
    if [[ -z "$body_start" ]]; then
        log_warning "Could not find frontmatter end in $file"
        rm -f "$backup_file"
        return 1
    fi
    
    # Count total lines
    local total_lines
    total_lines=$(wc -l < "$file" | tr -d ' ')
    
    # Ensure there's actual body content after frontmatter
    if [[ $body_start -ge $total_lines ]]; then
        log_warning "No body content found after frontmatter in $file"
        rm -f "$backup_file"
        return 1
    fi
    
    # Write new header
    echo "$new_header" > "$temp_file"
    echo "" >> "$temp_file"
    
    # Append body (skip blank line after frontmatter if present)
    # Use awk for cross-platform compatibility (BSD sed vs GNU sed)
    tail -n +$((body_start + 1)) "$file" | awk 'NR==1 && /^$/ {next} {print}' >> "$temp_file"
    
    # Verify the new file has meaningful content
    local new_lines
    new_lines=$(wc -l < "$temp_file" | tr -d ' ')
    
    if [[ $new_lines -lt 20 ]]; then
        log_error "Generated file too short ($new_lines lines), restoring backup"
        cp "$backup_file" "$file"
        rm -f "$temp_file" "$backup_file"
        return 1
    fi
    
    # Replace original file
    mv "$temp_file" "$file"
    rm -f "$backup_file"
    
    return 0
}

# Process a single skill
process_skill() {
    local skill_id="$1"
    local skill_path="$2"
    local skill_dir="$SKILLS_DIR/$skill_path"
    
    echo ""
    echo "Processing: $skill_id"
    echo "─────────────────────────────"
    
    # Skip template
    if [[ "$skill_id" == "_template" ]]; then
        log_info "Skipping template directory"
        return 0
    fi
    
    # Check skill directory exists
    if [[ ! -d "$skill_dir" ]]; then
        log_error "Skill directory not found: $skill_dir"
        return 1
    fi
    
    # Update io-contract.md
    local io_contract="$skill_dir/references/io-contract.md"
    if [[ -f "$io_contract" ]]; then
        local io_header
        io_header=$(generate_io_contract_header "$skill_id" "$skill_dir")
        if update_reference_file "$io_contract" "$io_header"; then
            log_success "Updated io-contract.md header"
        fi
    else
        log_info "No io-contract.md found"
    fi
    
    # Update safety.md
    local safety_md="$skill_dir/references/safety.md"
    if [[ -f "$safety_md" ]]; then
        local safety_header
        safety_header=$(generate_safety_header "$skill_id" "$skill_dir")
        if update_reference_file "$safety_md" "$safety_header"; then
            log_success "Updated safety.md header"
        fi
    else
        log_info "No safety.md found"
    fi
}

# Extract "skill_id skill_path" pairs from manifest
get_manifest_skill_paths() {
    awk '
        $1 == "-" && $2 == "id:" {
            id=$3
            gsub(/["'"'"']/, "", id)
            next
        }
        $1 == "path:" {
            path=$2
            gsub(/["'"'"']/, "", path)
            if (id != "") {
                print id, path
                id=""
            }
        }
    ' "$MANIFEST"
}

# Main
echo "================================"
echo "Generate Reference Headers"
echo "================================"
echo "Skills directory: $SKILLS_DIR"

if [[ -n "$1" ]]; then
    # Process single skill
    skill_path=$(awk -v id="$1" '
        $1 == "-" && $2 == "id:" {
            current=$3
            gsub(/["'"'"']/, "", current)
            found=(current == id)
            next
        }
        found && $1 == "path:" {
            path=$2
            gsub(/["'"'"']/, "", path)
            print path
            exit
        }
    ' "$MANIFEST")

    if [[ -z "$skill_path" ]]; then
        log_error "Skill '$1' not found in manifest"
        exit 1
    fi

    process_skill "$1" "$skill_path"
else
    # Process all skills from manifest
    while IFS= read -r row; do
        skill_id="${row%% *}"
        skill_path="${row#* }"
        [[ -n "$skill_id" ]] || continue
        [[ -n "$skill_path" ]] || continue
        process_skill "$skill_id" "$skill_path"
    done < <(get_manifest_skill_paths)
fi

echo ""
echo "================================"
echo "Done"
echo "================================"
