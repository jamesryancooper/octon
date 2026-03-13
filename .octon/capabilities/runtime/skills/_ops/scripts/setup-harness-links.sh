#!/bin/bash
# setup-harness-links.sh
# Creates symlinks from harness skill folders to skills in .octon/capabilities/runtime/skills/
#
# Usage: ./setup-harness-links.sh [skill-id]
#   If skill-id is provided, only creates links for that skill
#   If no argument, creates links for all manifest-listed skills

set -euo pipefail

# Resolve canonical locations from this script location.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
MANIFEST="$SKILLS_DIR/manifest.yml"
# skills/ -> capabilities/ -> .octon/ -> repo root
PROJECT_ROOT="$(cd "$SKILLS_DIR/../../.." && pwd)"

# Harness folders to create symlinks in
HARNESSES=(".claude/skills" ".cursor/skills" ".codex/skills")

# Find skill path by id from manifest (returns path relative to SKILLS_DIR)
find_skill_location() {
    local skill_id="$1"
    awk -v id="$skill_id" '
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
    ' "$MANIFEST"
}

# List "skill_id skill_path" pairs from manifest
discover_skills() {
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

# Create symlink for a single skill
create_skill_link() {
    local skill_id="$1"
    local skill_path
    skill_path="$(find_skill_location "$skill_id")"

    if [[ -z "$skill_path" ]]; then
        echo "Error: Skill '$skill_id' not found in manifest" >&2
        return 1
    fi

    if [[ ! -f "$SKILLS_DIR/$skill_path/SKILL.md" ]]; then
        echo "Error: SKILL.md not found at $SKILLS_DIR/$skill_path" >&2
        return 1
    fi

    # Links are created in .{harness}/skills/, so two levels up reaches repo root.
    local target="../../.octon/capabilities/runtime/skills/$skill_path"

    for harness in "${HARNESSES[@]}"; do
        local harness_dir="$PROJECT_ROOT/$harness"
        local link_path="$harness_dir/$skill_id"

        if ! mkdir -p "$harness_dir" 2>/dev/null; then
            echo "  [skip] $harness/$skill_id (cannot create harness directory)"
            continue
        fi

        if [[ -L "$link_path" ]]; then
            local existing_target
            existing_target="$(readlink "$link_path")"
            if [[ "$existing_target" == "$target" ]]; then
                echo "  [skip] $harness/$skill_id (already linked)"
                continue
            fi
            echo "  [update] $harness/$skill_id"
            if ! rm "$link_path" 2>/dev/null; then
                echo "  [skip] $harness/$skill_id (cannot update existing symlink)"
                continue
            fi
        elif [[ -e "$link_path" ]]; then
            echo "  [skip] $harness/$skill_id (not a symlink, manual review needed)"
            continue
        fi

        if ln -s "$target" "$link_path" 2>/dev/null; then
            echo "  [created] $harness/$skill_id -> $target"
        else
            echo "  [skip] $harness/$skill_id (cannot create symlink)"
        fi
    done
}

# Remove broken symlinks from harness folders
prune_stale_links() {
    for harness in "${HARNESSES[@]}"; do
        local harness_dir="$PROJECT_ROOT/$harness"
        [[ -d "$harness_dir" ]] || continue

        for link in "$harness_dir"/*; do
            [[ -L "$link" ]] || continue
            if [[ ! -e "$link" ]]; then
                echo "  [prune] $(basename "$link") (broken link)"
                if ! rm "$link" 2>/dev/null; then
                    echo "  [skip] $(basename "$link") (cannot remove broken link)"
                fi
            fi
        done
    done
}

# Main
echo "Setting up harness skill symlinks..."
echo "Project root: $PROJECT_ROOT"
echo "Skills dir: $SKILLS_DIR"
echo "Manifest: $MANIFEST"
echo ""

if [[ ! -f "$MANIFEST" ]]; then
    echo "Error: manifest not found: $MANIFEST" >&2
    exit 1
fi

if [[ -n "${1:-}" ]]; then
    echo "Creating links for skill: $1"
    create_skill_link "$1"
else
    echo "Discovering skills from manifest..."
    echo ""

    while IFS= read -r row; do
        local_skill_id="${row%% *}"
        local_skill_path="${row#* }"
        [[ -n "$local_skill_id" ]] || continue
        [[ -n "$local_skill_path" ]] || continue
        echo "Skill: $local_skill_id ($local_skill_path)"
        create_skill_link "$local_skill_id" || true
        echo ""
    done < <(discover_skills)
fi

echo "Pruning stale harness links..."
prune_stale_links

echo "Done."
echo ""
echo "Harness folders:"
for harness in "${HARNESSES[@]}"; do
    if [[ -d "$PROJECT_ROOT/$harness" ]]; then
        echo "  $harness/"
        ls -la "$PROJECT_ROOT/$harness" 2>/dev/null | grep "^l" | awk '{print "    " $9 " -> " $11}' || echo "    (empty)"
    fi
done
