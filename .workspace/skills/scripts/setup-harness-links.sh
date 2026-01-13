#!/bin/bash
# setup-harness-links.sh
# Creates symlinks from harness skill folders to .workspace/skills/
#
# Usage: ./setup-harness-links.sh [skill-id]
#   If skill-id is provided, only creates links for that skill
#   If no argument, creates links for all skills

set -e

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(cd "$SKILLS_DIR/../.." && pwd)"

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

# Function to create symlink for a single skill
create_skill_link() {
    local skill_id="$1"
    local skill_path="$SKILLS_DIR/$skill_id"

    # Verify skill exists
    if [[ ! -d "$skill_path" ]]; then
        echo "Error: Skill '$skill_id' not found at $skill_path" >&2
        return 1
    fi

    # Verify SKILL.md exists
    if [[ ! -f "$skill_path/SKILL.md" ]]; then
        echo "Warning: $skill_id has no SKILL.md, skipping" >&2
        return 1
    fi

    for harness in "${HARNESSES[@]}"; do
        harness_dir="$PROJECT_ROOT/$harness"
        link_path="$harness_dir/$skill_id"
        target="../../.workspace/skills/$skill_id"

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

# Main logic
echo "Setting up harness skill symlinks..."
echo "Project root: $PROJECT_ROOT"
echo "Skills dir: $SKILLS_DIR"
echo ""

if [[ -n "$1" ]]; then
    # Single skill mode
    echo "Creating links for skill: $1"
    create_skill_link "$1"
else
    # All skills mode
    echo "Creating links for all skills..."
    echo ""

    # Find all skill directories
    for skill_path in "$SKILLS_DIR"/*/; do
        skill_id="$(basename "$skill_path")"

        # Skip excluded directories
        if is_excluded "$skill_id"; then
            continue
        fi

        echo "Skill: $skill_id"
        create_skill_link "$skill_id" || true
        echo ""
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
