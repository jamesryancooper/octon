#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
COMMON_SCRIPT="$SCRIPT_DIR/../../../_ops/scripts/validate-surface-common.sh"
source "$COMMON_SCRIPT"

surface_common_init "${BASH_SOURCE[0]}" "watchers"

if ! surface_has_any_marker "README.md" "manifest.yml" "registry.yml" "_scaffold/template/watcher.yml"; then
  surface_skip_not_promoted
fi

require_file_rel "README.md"
require_file_rel "manifest.yml"
require_file_rel "registry.yml"

if [[ -d "$SURFACE_DIR/_scaffold/template" ]]; then
  require_file_rel "_scaffold/template/watcher.yml"
  require_file_rel "_scaffold/template/sources.yml"
  require_file_rel "_scaffold/template/rules.yml"
  require_file_rel "_scaffold/template/emits.yml"
fi

while IFS= read -r watcher_dir; do
  rel_dir="${watcher_dir#$SURFACE_DIR/}"
  require_file_rel "$rel_dir/watcher.yml"
  require_file_rel "$rel_dir/sources.yml"
  require_file_rel "$rel_dir/rules.yml"
  require_file_rel "$rel_dir/emits.yml"
done < <(find "$SURFACE_DIR" -mindepth 1 -maxdepth 1 -type d ! -name '_*' | sort)

finish_surface_validation "watchers"
