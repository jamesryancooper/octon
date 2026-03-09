#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_PIPELINES_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
PIPELINES_DIR="${HARMONY_PIPELINES_DIR:-$DEFAULT_PIPELINES_DIR}"
RUNTIME_DIR="$(cd -- "$PIPELINES_DIR/.." && pwd)"
ORCHESTRATION_DIR="$(cd -- "$RUNTIME_DIR/.." && pwd)"
HARMONY_DIR="${HARMONY_DIR_OVERRIDE:-$(cd -- "$ORCHESTRATION_DIR/.." && pwd)}"
ROOT_DIR="${HARMONY_ROOT_DIR:-$(cd -- "$HARMONY_DIR/.." && pwd)}"

PIPELINE_MANIFEST="$PIPELINES_DIR/manifest.yml"
OUTPUT_ROOT="$ROOT_DIR"
FILTER_PIPELINE_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output-root)
      OUTPUT_ROOT="$2"
      shift 2
      ;;
    --pipeline-id)
      FILTER_PIPELINE_ID="$2"
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

yaml_quote() {
  printf '"%s"' "$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')"
}

require_file "$PIPELINE_MANIFEST"

mapfile -t pipeline_rows < <(yq -r '.pipelines[] | to_json | @base64' "$PIPELINE_MANIFEST")

for row in "${pipeline_rows[@]}"; do
  row_json="$(printf '%s' "$row" | base64 --decode)"
  pipeline_id="$(printf '%s' "$row_json" | yq -p=json -r '.id')"
  if [[ -n "$FILTER_PIPELINE_ID" && "$pipeline_id" != "$FILTER_PIPELINE_ID" ]]; then
    continue
  fi
  rel_path="$(printf '%s' "$row_json" | yq -p=json -r '.path')" 
  pipeline_dir="$PIPELINES_DIR/${rel_path%/}"
  pipeline_file="$pipeline_dir/pipeline.yml"

  require_file "$pipeline_file"

  workflow_path="$(yq -r '.projection.workflow_path' "$pipeline_file")"
  projection_format="$(yq -r '.projection.projection_format // "directory"' "$pipeline_file")"
  description="$(yq -r '.description // ""' "$pipeline_file")"
  version="$(yq -r '.version // "1.0.0"' "$pipeline_file")"
  execution_profile="$(yq -r '.execution_profile // "core"' "$pipeline_file")"
  workflow_target="$OUTPUT_ROOT/$workflow_path"
  mapfile -t input_rows < <(yq -r '.inputs[]? | to_json | @base64' "$pipeline_file")
  mapfile -t artifact_rows < <(yq -r '.artifacts[]? | to_json | @base64' "$pipeline_file")

  if [[ "$projection_format" == "single-file" ]]; then
    mkdir -p "$(dirname "$workflow_target")"
    rm -f "$workflow_target"
    body_file="$(yq -r '.stages[0].asset' "$pipeline_file")"
    body_path="$pipeline_dir/$body_file"
    {
      printf '%s\n' '---'
      printf '%s\n' "name: $(yaml_quote "$pipeline_id")"
      printf '%s\n' "description: $(yaml_quote "$description")"
      printf '%s\n' '---'
      printf '\n'
      printf '# %s\n\n' "$(title_case "$pipeline_id")"
      printf '_Generated projection from canonical pipeline `%s`._\n\n' "$pipeline_id"
      printf '## Usage\n\n```text\n/%s\n```\n\n' "$pipeline_id"
      printf '## Target\n\n'
      printf 'This projection wraps the canonical pipeline `%s` for staged human review and slash-facing compatibility.\n\n' "$pipeline_id"
      printf '## Prerequisites\n\n'
      printf -- '- Required pipeline inputs are available.\n'
      printf -- '- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/%s`.\n' "${rel_path%/}"
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
      printf -- '- The backing canonical pipeline contract or stage assets are missing.\n'
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
      cat "$body_path"
      printf '\n## Version History\n\n'
      printf '| Version | Changes |\n|---------|---------|\n| %s | Generated from canonical pipeline `%s` |\n' "$version" "$pipeline_id"
      printf '\n'
    } >"$workflow_target"
    continue
  fi

  rm -rf "$workflow_target"
  mkdir -p "$workflow_target"
  mapfile -t stage_rows < <(yq -r '.stages[] | to_json | @base64' "$pipeline_file")

  workflow_md="$workflow_target/WORKFLOW.md"
  {
    printf '%s\n' '---'
    printf '%s\n' "name: $(yaml_quote "$pipeline_id")"
    printf '%s\n' "description: $(yaml_quote "$description")"
    printf '%s\n' 'steps:'
    for stage_row in "${stage_rows[@]}"; do
      stage_json="$(printf '%s' "$stage_row" | base64 --decode)"
      stage_id="$(printf '%s' "$stage_json" | yq -p=json -r '.id')"
      stage_asset="$(printf '%s' "$stage_json" | yq -p=json -r '.asset')"
      stage_file="$(basename "$stage_asset")"
      printf '%s\n' "  - id: $(yaml_quote "$stage_id")"
      printf '%s\n' "    file: $(yaml_quote "$stage_file")"
      printf '%s\n' "    description: $(yaml_quote "$stage_id")"
    done
    printf '%s\n' '---'
    printf '\n'
    printf '# %s\n\n' "$(title_case "$pipeline_id")"
    printf '_Generated projection from canonical pipeline `%s`._\n\n' "$pipeline_id"
    printf '## Usage\n\n```text\n/%s\n```\n\n' "$pipeline_id"
    printf '## Target\n\n'
    printf 'This projection wraps the canonical pipeline `%s` for staged human review and slash-facing compatibility.\n\n' "$pipeline_id"
    printf '## Prerequisites\n\n'
    printf -- '- Required pipeline inputs are available.\n'
    printf -- '- Canonical pipeline assets exist under `.harmony/orchestration/runtime/pipelines/%s`.\n' "${rel_path%/}"
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
    printf -- '- The backing canonical pipeline contract or stage assets are missing.\n'
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
      stage_file="$(basename "$stage_asset")"
      printf '%s. [%s](./%s)\n' "$idx" "$stage_id" "$stage_file"
      idx=$((idx + 1))
    done
    printf '\n## Verification Gate\n\n'
    while IFS= read -r check; do
      [[ -z "$check" || "$check" == "null" ]] && continue
      printf '%s\n' "- [ ] $check"
    done < <(yq -r '.done_gate.checks[]?' "$pipeline_file")
    printf '\n## Version History\n\n'
    printf '| Version | Changes |\n|---------|---------|\n| %s | Generated from canonical pipeline `%s` |\n' "$version" "$pipeline_id"
    printf '\n## References\n\n'
    printf '%s\n' "- Canonical pipeline: \`.harmony/orchestration/runtime/pipelines/${rel_path}\`"
  } >"$workflow_md"

  for stage_row in "${stage_rows[@]}"; do
    stage_json="$(printf '%s' "$stage_row" | base64 --decode)"
    stage_asset="$(printf '%s' "$stage_json" | yq -p=json -r '.asset')"
    cp "$pipeline_dir/$stage_asset" "$workflow_target/$(basename "$stage_asset")"
  done
done

echo "Generated workflow projections from canonical pipelines."
