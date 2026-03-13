#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_WORKFLOWS_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
WORKFLOWS_DIR="${OCTON_WORKFLOWS_DIR:-$DEFAULT_WORKFLOWS_DIR}"
RUNTIME_DIR="$(cd -- "$WORKFLOWS_DIR/.." && pwd)"
ORCHESTRATION_DIR="$(cd -- "$RUNTIME_DIR/.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$(cd -- "$ORCHESTRATION_DIR/.." && pwd)}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

MANIFEST="$WORKFLOWS_DIR/manifest.yml"
OUTPUT_ROOT="$ROOT_DIR"
FILTER_WORKFLOW_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output-root)
      OUTPUT_ROOT="$2"
      shift 2
      ;;
    --workflow-id)
      FILTER_WORKFLOW_ID="$2"
      shift 2
      ;;
    *)
      echo "unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

require_file() {
  [[ -f "$1" ]] || { echo "missing file: $1" >&2; exit 1; }
}

title_case() {
  printf '%s' "$1" | tr '-' ' ' | awk '{for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1'
}

require_file "$MANIFEST"

mapfile -t workflow_rows < <(yq -r '.workflows[] | to_json | @base64' "$MANIFEST")

for row in "${workflow_rows[@]}"; do
  row_json="$(printf '%s' "$row" | base64 --decode)"
  workflow_id="$(printf '%s' "$row_json" | yq -p=json -r '.id')"
  if [[ -n "$FILTER_WORKFLOW_ID" && "$workflow_id" != "$FILTER_WORKFLOW_ID" ]]; then
    continue
  fi

  rel_path="$(printf '%s' "$row_json" | yq -p=json -r '.path')"
  workflow_dir="$WORKFLOWS_DIR/${rel_path%/}"
  workflow_file="$workflow_dir/workflow.yml"
  readme_path="$OUTPUT_ROOT/.octon/orchestration/runtime/workflows/$rel_path/README.md"

  require_file "$workflow_file"
  mkdir -p "$(dirname "$readme_path")"

  description="$(yq -r '.description // ""' "$workflow_file")"
  version="$(yq -r '.version // "1.0.0"' "$workflow_file")"
  execution_profile="$(yq -r '.execution_profile // "core"' "$workflow_file")"
  mapfile -t input_rows < <(yq -r '.inputs[]? | to_json | @base64' "$workflow_file")
  mapfile -t artifact_rows < <(yq -r '.artifacts[]? | to_json | @base64' "$workflow_file")
  mapfile -t stage_rows < <(yq -r '.stages[] | to_json | @base64' "$workflow_file")

  {
    printf '%s\n' '---'
    printf 'name: "%s"\n' "$workflow_id"
    printf 'description: "%s"\n' "$(printf '%s' "$description" | sed 's/"/\\"/g')"
    printf '%s\n' 'steps:'
    for stage_row in "${stage_rows[@]}"; do
      stage_json="$(printf '%s' "$stage_row" | base64 --decode)"
      stage_id="$(printf '%s' "$stage_json" | yq -p=json -r '.id')"
      stage_asset="$(printf '%s' "$stage_json" | yq -p=json -r '.asset')"
      printf '  - id: "%s"\n' "$stage_id"
      printf '    file: "%s"\n' "$stage_asset"
      printf '    description: "%s"\n' "$stage_id"
    done
    printf '%s\n' '---'
    printf '\n'
    printf '# %s\n\n' "$(title_case "$workflow_id")"
    printf '_Generated README from canonical workflow `%s`._\n\n' "$workflow_id"
    printf '## Usage\n\n```text\n/%s\n```\n\n' "$workflow_id"
    printf '## Purpose\n\n%s\n\n' "$description"
    printf '## Target\n\n'
    printf 'This README summarizes the canonical workflow unit at `.octon/orchestration/runtime/workflows/%s`.\n\n' "${rel_path%/}"
    printf '## Prerequisites\n\n'
    printf -- '- Required workflow inputs are available.\n'
    printf -- '- Canonical workflow contract exists at `.octon/orchestration/runtime/workflows/%sworkflow.yml`.\n' "$rel_path"
    if [[ "$execution_profile" == "external-dependent" ]]; then
      printf -- '- External runtime dependencies required by the target project are available.\n'
    fi
    printf '\n'
    if [[ "${#input_rows[@]}" -gt 0 ]]; then
      printf '## Parameters\n\n'
      for input_row in "${input_rows[@]}"; do
        input_json="$(printf '%s' "$input_row" | base64 --decode)"
        input_name="$(printf '%s' "$input_json" | yq -p=json -r '.name')"
        input_type="$(printf '%s' "$input_json" | yq -p=json -r '.type // "text"')"
        input_required="$(printf '%s' "$input_json" | yq -p=json -r '.required // false')"
        input_default="$(printf '%s' "$input_json" | yq -p=json -r '.default // ""')"
        input_description="$(printf '%s' "$input_json" | yq -p=json -r '.description // ""')"
        printf -- '- `%s` (%s, required=%s)%s%s\n' \
          "$input_name" "$input_type" "$input_required" \
          "${input_default:+, default=\`$input_default\`}" \
          "${input_description:+: $input_description}"
      done
      printf '\n'
    fi
    printf '## Failure Conditions\n\n'
    printf -- '- Required inputs are missing or invalid.\n'
    printf -- '- The canonical workflow contract or stage assets are missing.\n'
    printf -- '- Verification criteria are not satisfied.\n\n'
    if [[ "${#artifact_rows[@]}" -gt 0 ]]; then
      printf '## Outputs\n\n'
      for artifact_row in "${artifact_rows[@]}"; do
        artifact_json="$(printf '%s' "$artifact_row" | base64 --decode)"
        artifact_name="$(printf '%s' "$artifact_json" | yq -p=json -r '.name')"
        artifact_path="$(printf '%s' "$artifact_json" | yq -p=json -r '.path // ""')"
        artifact_description="$(printf '%s' "$artifact_json" | yq -p=json -r '.description // ""')"
        printf -- '- `%s` -> `%s`%s\n' \
          "$artifact_name" "$artifact_path" \
          "${artifact_description:+: $artifact_description}"
      done
      printf '\n'
    fi
    printf '## Steps\n\n'
    idx=1
    for stage_row in "${stage_rows[@]}"; do
      stage_json="$(printf '%s' "$stage_row" | base64 --decode)"
      stage_id="$(printf '%s' "$stage_json" | yq -p=json -r '.id')"
      stage_asset="$(printf '%s' "$stage_json" | yq -p=json -r '.asset')"
      printf '%s. [%s](./%s)\n' "$idx" "$stage_id" "$stage_asset"
      idx=$((idx + 1))
    done
    printf '\n## Verification Gate\n\n'
    while IFS= read -r check; do
      [[ -z "$check" || "$check" == "null" ]] && continue
      printf '%s\n' "- [ ] $check"
    done < <(yq -r '.done_gate.checks[]?' "$workflow_file")
    printf '\n## References\n\n'
    printf -- '- Canonical contract: `.octon/orchestration/runtime/workflows/%sworkflow.yml`\n' "$rel_path"
    printf -- '- Canonical stages: `.octon/orchestration/runtime/workflows/%sstages/`\n' "$rel_path"
    printf '\n## Version History\n\n'
    printf '| Version | Changes |\n|---------|---------|\n| %s | Generated from canonical workflow `%s` |\n' "$version" "$workflow_id"
  } >"$readme_path"
done

echo "Generated workflow READMEs from canonical workflows."
