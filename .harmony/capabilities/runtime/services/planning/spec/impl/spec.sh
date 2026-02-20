#!/usr/bin/env bash
# spec.sh - Native planning spec service implementation (no external Speckit runtime).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Enforce deny-by-default policy at runtime for this shell service.
source "$SCRIPT_DIR/../../../_ops/scripts/enforce-deny-by-default.sh"
harmony_enforce_service_policy "spec" "$0" "$@"


emit_output() {
  local status="$1"
  local command="$2"
  local result_json="$3"
  local artifacts_json="${4:-[]}"
  local warnings_json="${5:-[]}"

  jq -n \
    --arg status "$status" \
    --arg command "$command" \
    --argjson result "$result_json" \
    --argjson artifacts "$artifacts_json" \
    --argjson warnings "$warnings_json" \
    '{status:$status,command:$command,result:$result,artifacts:$artifacts,warnings:$warnings}'
}

fail_input() {
  local command="$1"
  local message="$2"
  emit_output "error" "$command" "{}" "[]" "$(jq -cn --arg m "$message" '[ $m ]')"
  exit 5
}

fail_runtime() {
  local command="$1"
  local message="$2"
  emit_output "error" "$command" "{}" "[]" "$(jq -cn --arg m "$message" '[ $m ]')"
  exit 4
}

if ! command -v jq >/dev/null 2>&1; then
  printf '%s\n' '{"status":"error","command":"unknown","result":{},"artifacts":[],"warnings":["jq is required"]}'
  exit 6
fi

payload="$(cat)"
if [[ -z "$(printf '%s' "$payload" | tr -d '[:space:]')" ]]; then
  fail_input "unknown" "Expected JSON payload"
fi

if ! printf '%s' "$payload" | jq -e . >/dev/null 2>&1; then
  fail_input "unknown" "Payload is not valid JSON"
fi

command="$(printf '%s' "$payload" | jq -r '.command // empty')"
target_path="$(printf '%s' "$payload" | jq -r '.targetPath // "."')"
feature_id="$(printf '%s' "$payload" | jq -r '.featureId // empty')"
dry_run="$(printf '%s' "$payload" | jq -r '.dryRun // false')"
options_json="$(printf '%s' "$payload" | jq -c '.options // {}')"

case "$command" in
  init|validate|render|diagram) ;;
  "") fail_input "unknown" "Missing command" ;;
  *) fail_input "$command" "Unsupported command: $command" ;;
esac

if [[ "$command" != "init" && ! -d "$target_path" ]]; then
  fail_runtime "$command" "targetPath does not exist: $target_path"
fi

list_markdown_files() {
  local root="$1"
  local name="$2"
  if [[ ! -d "$root" ]]; then
    printf '[]'
    return
  fi

  find "$root" -type f -name "$name" | LC_ALL=C sort | jq -R . | jq -s .
}

case "$command" in
  init)
    if [[ -z "$feature_id" ]]; then
      feature_id="feature"
    fi

    if [[ "$target_path" == "$feature_id" || "$target_path" == */"$feature_id" ]]; then
      local_feature_dir="$target_path"
    else
      local_feature_dir="$target_path/specs/$feature_id"
    fi
    templates=("spec.md" "plan.md" "tasks.md")
    created_files=()

    if [[ "$dry_run" != "true" ]]; then
      mkdir -p "$local_feature_dir"
      for file in "${templates[@]}"; do
        local_file_path="$local_feature_dir/$file"
        if [[ ! -f "$local_file_path" ]]; then
          cat > "$local_file_path" <<FILE
# ${feature_id} ${file%%.md}

- generated_by: planning/spec native service
- dry_run: false
FILE
          created_files+=("$local_file_path")
        fi
      done
    fi

    created_json="$(printf '%s\n' "${templates[@]}" | jq -R . | jq -s .)"
    artifacts_json="$(printf '%s\n' "${created_files[@]:-}" | sed '/^$/d' | jq -R . | jq -s .)"

    result_json="$(jq -cn \
      --arg targetPath "$target_path" \
      --arg featureId "$feature_id" \
      --arg featurePath "$local_feature_dir" \
      --argjson dryRun "$dry_run" \
      --argjson options "$options_json" \
      --argjson created "$created_json" \
      '{mode:"init",targetPath:$targetPath,featureId:$featureId,featurePath:$featurePath,dryRun:$dryRun,created:$created,options:$options}')"

    emit_output "success" "$command" "$result_json" "$artifacts_json" "[]"
    ;;

  validate)
    spec_files="$(list_markdown_files "$target_path" 'spec.md')"
    plan_files="$(list_markdown_files "$target_path" 'plan.md')"
    task_files="$(list_markdown_files "$target_path" 'tasks.md')"

    spec_count="$(jq 'length' <<<"$spec_files")"
    plan_count="$(jq 'length' <<<"$plan_files")"
    task_count="$(jq 'length' <<<"$task_files")"

    warnings_json='[]'
    if [[ "$spec_count" -eq 0 ]]; then
      warnings_json="$(jq -cn '["No spec.md files discovered under targetPath"]')"
    elif [[ "$plan_count" -eq 0 || "$task_count" -eq 0 ]]; then
      warnings_json="$(jq -cn '["Spec plan/task companion files are incomplete"]')"
    fi

    result_json="$(jq -cn \
      --arg targetPath "$target_path" \
      --argjson dryRun "$dry_run" \
      --argjson specCount "$spec_count" \
      --argjson planCount "$plan_count" \
      --argjson taskCount "$task_count" \
      --argjson specFiles "$spec_files" \
      --argjson planFiles "$plan_files" \
      --argjson taskFiles "$task_files" \
      '{mode:"validate",targetPath:$targetPath,dryRun:$dryRun,counts:{spec:$specCount,plan:$planCount,tasks:$taskCount},files:{spec:$specFiles,plan:$planFiles,tasks:$taskFiles}}')"

    emit_output "success" "$command" "$result_json" "[]" "$warnings_json"
    ;;

  render)
    spec_files="$(list_markdown_files "$target_path" 'spec.md')"
    feature_ids="$(jq -c '[.[] | capture("(?<id>[^/]+)/spec.md$")?.id // .]' <<<"$spec_files")"
    output_path="$target_path/output/spec-render-summary.json"

    result_json="$(jq -cn \
      --arg targetPath "$target_path" \
      --arg outputPath "$output_path" \
      --argjson dryRun "$dry_run" \
      --argjson features "$feature_ids" \
      '{mode:"render",targetPath:$targetPath,dryRun:$dryRun,featureIds:$features,outputPath:$outputPath}')"

    artifacts_json='[]'
    if [[ "$dry_run" != "true" ]]; then
      mkdir -p "$(dirname "$output_path")"
      jq -S . <<<"$result_json" > "$output_path"
      artifacts_json="$(jq -cn --arg p "$output_path" '[ $p ]')"
    fi

    emit_output "success" "$command" "$result_json" "$artifacts_json" "[]"
    ;;

  diagram)
    diagram_path="$target_path/output/spec-diagram.mmd"
    mermaid='flowchart TD\n  spec[spec] --> plan[plan]\n  plan --> tasks[tasks]\n  tasks --> execute[flow/agent]'

    result_json="$(jq -cn \
      --arg targetPath "$target_path" \
      --arg diagram "$mermaid" \
      --arg diagramPath "$diagram_path" \
      --argjson dryRun "$dry_run" \
      '{mode:"diagram",targetPath:$targetPath,dryRun:$dryRun,diagramFormat:"mermaid",diagram:$diagram,diagramPath:$diagramPath}')"

    artifacts_json='[]'
    if [[ "$dry_run" != "true" ]]; then
      mkdir -p "$(dirname "$diagram_path")"
      printf '%b\n' "$mermaid" > "$diagram_path"
      artifacts_json="$(jq -cn --arg p "$diagram_path" '[ $p ]')"
    fi

    emit_output "success" "$command" "$result_json" "$artifacts_json" "[]"
    ;;
esac
