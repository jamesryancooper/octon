#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PIPELINES_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
ORCHESTRATION_DIR="$(cd -- "$PIPELINES_DIR/../.." && pwd)"
HARMONY_DIR="$(cd -- "$ORCHESTRATION_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$HARMONY_DIR/.." && pwd)"

WORKFLOWS_DIR="$HARMONY_DIR/orchestration/runtime/workflows"
WORKFLOW_MANIFEST="$WORKFLOWS_DIR/manifest.yml"
WORKFLOW_REGISTRY="$WORKFLOWS_DIR/registry.yml"
PIPELINE_MANIFEST="$PIPELINES_DIR/manifest.yml"
PIPELINE_REGISTRY="$PIPELINES_DIR/registry.yml"
WORKFLOW_REGISTRY_COPY="$(mktemp)"

require_file() {
  [[ -f "$1" ]] || { echo "missing file: $1" >&2; exit 1; }
}

extract_frontmatter() {
  local source="$1"
  local target="$2"
  awk '
    NR == 1 && $0 == "---" {in_frontmatter=1; next}
    in_frontmatter && $0 == "---" {exit}
    in_frontmatter {print}
  ' "$source" >"$target"
}

strip_frontmatter() {
  local source="$1"
  local target="$2"
  awk '
    NR == 1 && $0 == "---" {in_frontmatter=1; next}
    in_frontmatter && $0 == "---" {in_frontmatter=0; next}
    !in_frontmatter {print}
  ' "$source" >"$target"
}

yaml_quote() {
  printf '"%s"' "$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')"
}

emit_indented_block() {
  local indent="$1"
  local block="$2"
  if [[ -n "$block" && "$block" != "null" ]]; then
    printf '%s\n' "$block" | sed "s/^/${indent}/"
  fi
}

stage_kind_for_file() {
  local stage_id="$1"
  local file="$2"
  local source="$3"
  if [[ "$stage_id" == "verify" || "$file" == *verify* ]]; then
    printf 'verification\n'
    return
  fi
  if rg -qi 'CHANGE MANIFEST|zero-change receipt|update the target package|create or update|apply the hardening|specification gaps' "$source"; then
    printf 'mutation\n'
    return
  fi
  if [[ "$stage_id" == *report* || "$stage_id" == *plan* || "$stage_id" == *extract* || "$stage_id" == *merge* ]]; then
    printf 'projection\n'
    return
  fi
  printf 'analysis\n'
}

prepare_single_stage_asset() {
  local workflow_file="$1"
  local stages_dir="$2"
  mkdir -p "$stages_dir"
  strip_frontmatter "$workflow_file" "$stages_dir/01-inline.md"
}

require_file "$WORKFLOW_MANIFEST"
require_file "$WORKFLOW_REGISTRY"

mkdir -p "$PIPELINES_DIR"
mkdir -p "$PIPELINES_DIR/_ops/state"

tmp_manifest="$(mktemp)"
tmp_registry="$(mktemp)"
cp "$WORKFLOW_REGISTRY" "$WORKFLOW_REGISTRY_COPY"
trap 'rm -f "$tmp_manifest" "$tmp_registry" "$WORKFLOW_REGISTRY_COPY"' EXIT

printf '%s\n' 'schema_version: "pipeline-manifest-v1"' >"$tmp_manifest"
printf '%s\n' 'pipelines:' >>"$tmp_manifest"

printf '%s\n' 'schema_version: "pipeline-registry-v1"' >"$tmp_registry"
printf '%s\n' 'pipelines:' >>"$tmp_registry"

mapfile -t workflow_rows < <(yq -r '.workflows[] | to_json | @base64' "$WORKFLOW_MANIFEST")

for row in "${workflow_rows[@]}"; do
  row_json="$(printf '%s' "$row" | base64 --decode)"
  id="$(printf '%s' "$row_json" | yq -p=json -r '.id')"
  display_name="$(printf '%s' "$row_json" | yq -p=json -r '.display_name // .id')"
  group="$(printf '%s' "$row_json" | yq -p=json -r '.group')"
  domain="$(printf '%s' "$row_json" | yq -p=json -r '.domain // .group')"
  rel_path="$(printf '%s' "$row_json" | yq -p=json -r '.path')"
  summary="$(printf '%s' "$row_json" | yq -p=json -r '.summary // ""')"
  status="$(printf '%s' "$row_json" | yq -p=json -r '.status // "active"')"
  execution_profile="$(printf '%s' "$row_json" | yq -p=json -r '.execution_profile // "core"')"
  format="$(printf '%s' "$row_json" | yq -p=json -r '.format // "directory"')"

  workflow_target="$WORKFLOWS_DIR/$rel_path"
  workflow_dir="$workflow_target"
  workflow_file="$workflow_target/WORKFLOW.md"
  projection_format="directory"
  if [[ "$format" == "single-file" || "$rel_path" == *.md ]]; then
    workflow_file="$workflow_target"
    workflow_dir="$(dirname "$workflow_target")"
    projection_format="single-file"
  fi

  frontmatter_file="$(mktemp)"
  extract_frontmatter "$workflow_file" "$frontmatter_file"

  name="$(yq -r '.name // ""' "$frontmatter_file")"
  description="$(yq -r '.description // ""' "$frontmatter_file")"
  access="$(yq -r '.access // "human"' "$frontmatter_file")"
  version="$(yq -r ".workflows.\"$id\".version // \"1.0.0\"" "$WORKFLOW_REGISTRY")"
  parameters_block="$(yq -o=yaml ".workflows.\"$id\".parameters // []" "$WORKFLOW_REGISTRY")"
  outputs_block="$(yq -o=yaml ".workflows.\"$id\".io.outputs // []" "$WORKFLOW_REGISTRY")"

  pipeline_rel="${rel_path%.md}"
  pipeline_rel="${pipeline_rel%/}"
  pipeline_dir="$PIPELINES_DIR/$pipeline_rel"
  stages_dir="$pipeline_dir/stages"
  mkdir -p "$stages_dir"

  printf '%s\n' "  - id: $(yaml_quote "$id")" >>"$tmp_manifest"
  printf '%s\n' "    display_name: $(yaml_quote "$display_name")" >>"$tmp_manifest"
  printf '%s\n' "    group: $(yaml_quote "$group")" >>"$tmp_manifest"
  printf '%s\n' "    domain: $(yaml_quote "$domain")" >>"$tmp_manifest"
  printf '%s\n' "    path: $(yaml_quote "$pipeline_rel/")" >>"$tmp_manifest"
  printf '%s\n' "    execution_profile: $(yaml_quote "$execution_profile")" >>"$tmp_manifest"
  printf '%s\n' "    summary: $(yaml_quote "$summary")" >>"$tmp_manifest"
  printf '%s\n' "    status: $(yaml_quote "$status")" >>"$tmp_manifest"
  printf '%s\n' "    triggers:" >>"$tmp_manifest"
  while IFS= read -r trig; do
    [[ -z "$trig" || "$trig" == "null" ]] && continue
    printf '%s\n' "      - $(yaml_quote "$trig")" >>"$tmp_manifest"
  done < <(printf '%s' "$row_json" | yq -p=json -r '.triggers[]?')

  printf '%s\n' "  $id:" >>"$tmp_registry"
  printf '%s\n' "    version: $(yaml_quote "$version")" >>"$tmp_registry"
  printf '%s\n' "    entry_mode: $(yaml_quote "$access")" >>"$tmp_registry"
  printf '%s\n' "    execution_profile: $(yaml_quote "$execution_profile")" >>"$tmp_registry"
  printf '%s\n' "    inputs:" >>"$tmp_registry"
  emit_indented_block "      " "$parameters_block" >>"$tmp_registry"
  printf '%s\n' "    artifacts:" >>"$tmp_registry"
  emit_indented_block "      " "$outputs_block" >>"$tmp_registry"
  printf '%s\n' "    projection:" >>"$tmp_registry"
  printf '%s\n' "      workflow_id: $(yaml_quote "$id")" >>"$tmp_registry"
  printf '%s\n' "      workflow_path: $(yaml_quote ".harmony/orchestration/runtime/workflows/$rel_path")" >>"$tmp_registry"
  printf '%s\n' "      generated: true" >>"$tmp_registry"
  printf '%s\n' "      projection_format: $(yaml_quote "$projection_format")" >>"$tmp_registry"

  pipeline_file="$pipeline_dir/pipeline.yml"
  {
    printf '%s\n' 'schema_version: "pipeline-contract-v1"'
    printf '%s\n' "name: $(yaml_quote "$id")"
    printf '%s\n' "description: $(yaml_quote "${description:-$summary}")"
    printf '%s\n' "version: $(yaml_quote "$version")"
    printf '%s\n' "entry_mode: $(yaml_quote "$access")"
    printf '%s\n' "execution_profile: $(yaml_quote "$execution_profile")"
    printf '%s\n' "inputs:"
    emit_indented_block "  " "$parameters_block"
    printf '%s\n' "stages:"
  } >"$pipeline_file"

  if [[ "$projection_format" == "single-file" ]]; then
    prepare_single_stage_asset "$workflow_file" "$stages_dir"
    cat >>"$pipeline_file" <<EOF
  - id: "inline"
    asset: "stages/01-inline.md"
    kind: "analysis"
    produces: ["stage:inline"]
    consumes: []
    mutation_scope: []
EOF
  else
    mapfile -t step_rows < <(yq -r '.steps[] | to_json | @base64' "$frontmatter_file" 2>/dev/null || true)
    prev_stage=""
    if [[ "${#step_rows[@]}" -gt 0 ]]; then
      for step_row in "${step_rows[@]}"; do
        [[ -z "$step_row" ]] && continue
        step_json="$(printf '%s' "$step_row" | base64 --decode)"
        step_id="$(printf '%s' "$step_json" | yq -p=json -r '.id')"
        step_file="$(printf '%s' "$step_json" | yq -p=json -r '.file')"
        src="$workflow_dir/$step_file"
        cp "$src" "$stages_dir/$step_file"
        kind="$(stage_kind_for_file "$step_id" "$step_file" "$src")"
        {
          printf '%s\n' "  - id: $(yaml_quote "$step_id")"
          printf '%s\n' "    asset: $(yaml_quote "stages/$step_file")"
          printf '%s\n' "    kind: $(yaml_quote "$kind")"
          if [[ -n "$prev_stage" ]]; then
            printf '%s\n' "    consumes: [$(yaml_quote "stage:$prev_stage")]"
          else
            printf '%s\n' "    consumes: []"
          fi
          printf '%s\n' "    produces: [$(yaml_quote "stage:$step_id")]"
          if [[ "$kind" == "mutation" ]]; then
            printf '%s\n' "    mutation_scope: [$(yaml_quote "workflow-scope")]"
          else
            printf '%s\n' "    mutation_scope: []"
          fi
        } >>"$pipeline_file"
        prev_stage="$step_id"
      done
    fi
  fi

  {
    printf '%s\n' "artifacts:"
    emit_indented_block "  " "$outputs_block"
    printf '%s\n' "done_gate:"
    printf '%s\n' "  checks:"
    if [[ "$projection_format" == "single-file" ]]; then
      printf '%s\n' '    - "single stage completes successfully"'
    else
      while IFS= read -r check_line; do
        [[ -z "$check_line" ]] && continue
        printf '%s\n' "    - $(yaml_quote "$check_line")"
      done < <(awk '/^## Verification Gate/{flag=1;next} /^## /{if(flag) exit} flag && /^- \[ \] /{sub(/^- \[ \] /,""); print}' "$workflow_file")
      if ! awk '/^## Verification Gate/{flag=1;next} /^## /{if(flag) exit} flag && /^- \[ \] /{found=1} END{exit found?0:1}' "$workflow_file" 2>/dev/null; then
        printf '%s\n' '    - "verification stage passes"'
      fi
    fi
    printf '%s\n' "projection:"
    printf '%s\n' "  workflow_id: $(yaml_quote "$id")"
    printf '%s\n' "  workflow_path: $(yaml_quote ".harmony/orchestration/runtime/workflows/$rel_path")"
    printf '%s\n' "  generated: true"
    printf '%s\n' "  projection_format: $(yaml_quote "$projection_format")"
    printf '%s\n' "constraints:"
    printf '%s\n' "  fail_closed: true"
    printf '%s\n' "  forbid_design_packages: true"
    printf '%s\n' "  require_relative_local_assets: true"
  } >>"$pipeline_file"

  yq -i "
    .workflows.\"$id\".projection.pipeline_id = \"$id\" |
    .workflows.\"$id\".projection.pipeline_path = \".harmony/orchestration/runtime/pipelines/$pipeline_rel/\" |
    .workflows.\"$id\".projection.generated = true |
    .workflows.\"$id\".projection.projection_format = \"$projection_format\"
  " "$WORKFLOW_REGISTRY_COPY"

  rm -f "$frontmatter_file"
done

mv "$tmp_manifest" "$PIPELINE_MANIFEST"
mv "$tmp_registry" "$PIPELINE_REGISTRY"
mv "$WORKFLOW_REGISTRY_COPY" "$WORKFLOW_REGISTRY"

echo "Bootstrapped canonical pipelines from runtime workflows."
