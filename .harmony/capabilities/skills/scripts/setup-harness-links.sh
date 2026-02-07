#!/bin/bash
# setup-harness-links.sh
# Creates symlinks from harness skill folders to skills in .harmony/capabilities/skills/
#
# Usage: ./setup-harness-links.sh [skill-id]
#   If skill-id is provided, only creates links for that skill
#   If no argument, creates links for all skills from both locations

set -e

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Skills directories (checked in order)
HARMONY_SKILLS_DIR="$PROJECT_ROOT/.harmony/skills"
WORKSPACE_SKILLS_DIR="$PROJECT_ROOT/.harmony/capabilities/skills"

# Harness folders to create symlinks in
HARNESSES=(".claude/skills" ".cursor/skills" ".codex/skills")

# Directories to exclude from skill discovery
EXCLUDE_DIRS=("_template" "outputs" "logs" "sources" "scripts")

# Function to check if directory should be excluded
is_excluded() {
    local dir="$1"
    for exclude in "${EXCLUDE_DIRS[@]}"; do
        if [[ "$dir" == "$exclude" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to find skill location (.harmony or .workspace)
find_skill_location() {
    local skill_id="$1"

    # Check .harmony/skills first
    if [[ -d "$HARMONY_SKILLS_DIR/$skill_id" ]] && [[ -f "$HARMONY_SKILLS_DIR/$skill_id/SKILL.md" ]]; then
        echo "harmony"
        return 0
    fi

    # Check capabilities/skills second
    if [[ -d "$WORKSPACE_SKILLS_DIR/$skill_id" ]] && [[ -f "$WORKSPACE_SKILLS_DIR/$skill_id/SKILL.md" ]]; then
        echo "workspace"
        return 0
    fi

    return 1
}

# Function to create symlink for a single skill
create_skill_link() {
    local skill_id="$1"
    local location

    # Find skill location
    location=$(find_skill_location "$skill_id") || {
        echo "Error: Skill '$skill_id' not found in .harmony/capabilities/skills/ or .harmony/capabilities/skills/" >&2
        return 1
    }

    # Set paths based on location
    local target
    if [[ "$location" == "harmony" ]]; then
        target="../../.harmony/capabilities/skills/$skill_id"
    else
        target="../../.harmony/capabilities/skills/$skill_id"
    fi

    for harness in "${HARNESSES[@]}"; do
        harness_dir="$PROJECT_ROOT/$harness"
        link_path="$harness_dir/$skill_id"

        # Create harness directory if needed
        mkdir -p "$harness_dir"

        # Skip if link already exists and is correct
        if [[ -L "$link_path" ]]; then
            existing_target="$(readlink "$link_path")"
            if [[ "$existing_target" == "$target" ]]; then
                echo "  [skip] $harness/$skill_id (already linked)"
                continue
            else
                echo "  [update] $harness/$skill_id"
                rm "$link_path"
            fi
        elif [[ -e "$link_path" ]]; then
            echo "  [skip] $harness/$skill_id (not a symlink, manual review needed)"
            continue
        fi

        # Create symlink
        ln -s "$target" "$link_path"
        echo "  [created] $harness/$skill_id -> $target"
    done
}

# Function to discover all skills from a directory
discover_skills() {
    local skills_dir="$1"
    local location_name="$2"

    if [[ ! -d "$skills_dir" ]]; then
        return
    fi

    for skill_path in "$skills_dir"/*/; do
        [[ -d "$skill_path" ]] || continue

        skill_id="$(basename "$skill_path")"

        # Skip excluded directories
        if is_excluded "$skill_id"; then
            continue
        fi

        # Skip if no SKILL.md
        if [[ ! -f "$skill_path/SKILL.md" ]]; then
            continue
        fi

        echo "$skill_id"
    done
}

# Main logic
echo "Setting up harness skill symlinks..."
echo "Project root: $PROJECT_ROOT"
echo "Harmony skills: $HARMONY_SKILLS_DIR"
echo "Workspace skills: $WORKSPACE_SKILLS_DIR"
echo ""

if [[ -n "$1" ]]; then
    # Single skill mode
    echo "Creating links for skill: $1"
    create_skill_link "$1"
else
    # All skills mode
    echo "Discovering skills from .harmony/capabilities/skills/..."
    echo ""

    # Collect unique skill IDs from both locations
    declare -A seen_skills

    # Harmony skills (primary)
    echo "=== .harmony/capabilities/skills/ ==="
    for skill_id in $(discover_skills "$HARMONY_SKILLS_DIR" "harmony"); do
        if [[ -z "${seen_skills[$skill_id]}" ]]; then
            seen_skills[$skill_id]=1
            echo "Skill: $skill_id (harmony)"
            create_skill_link "$skill_id" || true
            echo ""
        fi
    done

    # Workspace skills (secondary, only if not already in harmony)
    echo "=== .harmony/capabilities/skills/ ==="
    for skill_id in $(discover_skills "$WORKSPACE_SKILLS_DIR" "workspace"); do
        if [[ -z "${seen_skills[$skill_id]}" ]]; then
            seen_skills[$skill_id]=1
            echo "Skill: $skill_id (workspace)"
            create_skill_link "$skill_id" || true
            echo ""
        else
            echo "Skill: $skill_id (skipped, already linked from harmony)"
        fi
    done
fi

echo "Done."
echo ""
echo "Harness folders:"
for harness in "${HARNESSES[@]}"; do
    if [[ -d "$PROJECT_ROOT/$harness" ]]; then
        echo "  $harness/"
        ls -la "$PROJECT_ROOT/$harness" 2>/dev/null | grep "^l" | awk '{print "    " $9 " -> " $11}' || echo "    (empty)"
    fi
done
