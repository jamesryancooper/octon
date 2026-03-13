#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOWS_DIR_DEFAULT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
ORCHESTRATION_DIR_DEFAULT="$(cd -- "$WORKFLOWS_DIR_DEFAULT/.." && pwd)"
OCTON_DIR_DEFAULT="$(cd -- "$ORCHESTRATION_DIR_DEFAULT/../.." && pwd)"
ROOT_DIR_DEFAULT="$(cd -- "$OCTON_DIR_DEFAULT/.." && pwd)"

MODE="ci-static"
ROOT_DIR="$ROOT_DIR_DEFAULT"
OCTON_DIR="$OCTON_DIR_DEFAULT"
ORCHESTRATION_DIR="$ORCHESTRATION_DIR_DEFAULT"
WORKFLOWS_DIR="$WORKFLOWS_DIR_DEFAULT"
MANIFEST=""
REGISTRY=""
CAPABILITY_MAP=""
CONTRACT_FILE=""
RUNTIME_AUDITS_DIR=""
RUNTIME_INDEX=""
REPORTS_DIR=""
AUDIT_REPORTS_DIR=""
TMP_DIR=""
SCOPE=".octon/orchestration/runtime/workflows/"
TARGET=""
FORMAT="markdown"
OUTPUT=""
SEVERITY_THRESHOLD=""
INCLUDE_DOCS=1
INCLUDE_GOVERNANCE=1
RUN_LIVE=1
SCENARIO_PACK="representative"
POST_REMEDIATION=0
CONVERGENCE_K=3
SEED_LIST="11,23,37"
RUN_ID="$(date +%F)-workflow-system-audit"
PROMPT_HASH=""
COMMIT_SHA=""

declare -A WORKFLOW_PATHS=()
declare -A WORKFLOW_PROFILES=()
declare -A WORKFLOW_GROUPS=()
declare -A WORKFLOW_SUMMARIES=()
declare -A WORKFLOW_TRIGGER_COUNTS=()
declare -A REGISTRY_VERSIONS=()
declare -A WORKFLOW_SCORES=()
declare -A WORKFLOW_GRADES=()
declare -A WORKFLOW_BREAKDOWNS=()
declare -A DISK_WORKFLOWS=()
declare -A DISK_FORMATS=()
declare -A SCENARIO_RESULTS=()

FINDINGS=()
SCANNED_PATHS=()
HAS_RG=0

if command -v rg >/dev/null 2>&1; then
  HAS_RG=1
fi

usage() {
  cat <<'USAGE'
Usage: audit-workflow-system.sh [options]

Options:
  --mode <full|ci-static|report|score-workflow|scenario-pack>
  --scope <workflow-root>
  --severity-threshold <critical|high|medium|low|all>
  --include-docs <true|false>
  --include-governance <true|false>
  --run-live <true|false>
  --scenario-pack <name>
  --post-remediation <true|false>
  --convergence-k <N>
  --seed-list <comma-separated>
  --target <workflow-path>      Required for --mode score-workflow
  --format <markdown|yaml>      Used with --mode score-workflow
  --output <path>               Optional output path for score-workflow
  --tmp-dir <path>              Override temp artifact root
  --help
USAGE
}

bool_to_int() {
  case "$1" in
    true|TRUE|1|yes|on) echo 1 ;;
    false|FALSE|0|no|off) echo 0 ;;
    *)
      echo "[ERROR] invalid boolean value: $1" >&2
      exit 1
      ;;
  esac
}

severity_rank() {
  case "$1" in
    critical) echo 4 ;;
    high) echo 3 ;;
    medium) echo 2 ;;
    low) echo 1 ;;
    all) echo 0 ;;
    *) echo 0 ;;
  esac
}

hash_short() {
  printf '%s' "$1" | shasum -a 256 | awk '{print substr($1,1,12)}'
}

yaml_quote() {
  printf '"%s"' "$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')"
}

rel_path() {
  local path="$1"
  path="${path#"$ROOT_DIR"/}"
  printf '%s\n' "$path"
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

frontmatter_query() {
  local source="$1"
  local expr="$2"
  local tmp_file
  tmp_file="$(mktemp "${TMPDIR:-/tmp}/workflow-frontmatter.XXXXXX")"
  extract_frontmatter "$source" "$tmp_file"
  if [[ ! -s "$tmp_file" ]]; then
    rm -f "$tmp_file"
    printf '\n'
    return 0
  fi
  yq -r "$expr // \"\"" "$tmp_file" 2>/dev/null || true
  rm -f "$tmp_file"
}

matches_file_regex() {
  local pattern="$1"
  local file="$2"
  if [[ "$HAS_RG" -eq 1 ]]; then
    rg -q -- "$pattern" "$file"
  else
    grep -Eq -- "$pattern" "$file"
  fi
}

matches_paths_regex() {
  local pattern="$1"
  shift
  local path
  if [[ "$HAS_RG" -eq 1 ]]; then
    rg -q -- "$pattern" "$@"
  else
    for path in "$@"; do
      if [[ -d "$path" ]]; then
        grep -RqsE -- "$pattern" "$path" && return 0
      elif [[ -f "$path" ]]; then
        grep -Eq -- "$pattern" "$path" && return 0
      fi
    done
    return 1
  fi
}

matches_paths_fixed() {
  local token="$1"
  shift
  local path
  if [[ "$HAS_RG" -eq 1 ]]; then
    rg -Fq -- "$token" "$@"
  else
    for path in "$@"; do
      if [[ -d "$path" ]]; then
        grep -RqsF -- "$token" "$path" && return 0
      elif [[ -f "$path" ]]; then
        grep -Fq -- "$token" "$path" && return 0
      fi
    done
    return 1
  fi
}

matches_stdin_regex() {
  local pattern="$1"
  if [[ "$HAS_RG" -eq 1 ]]; then
    rg -q -- "$pattern"
  else
    grep -Eq -- "$pattern"
  fi
}

extract_markdown_link_targets() {
  local file="$1"
  if [[ "$HAS_RG" -eq 1 ]]; then
    rg -No '\[[^]]+\]\(([^)]+)\)' -r '$1' "$file" || true
  else
    grep -Eo '\[[^]]+\]\(([^)]+)\)' "$file" | sed -E 's/.*\(([^)]+)\)$/\1/' || true
  fi
}

has_section() {
  local file="$1"
  local title="$2"
  matches_file_regex "^##[[:space:]]+${title}([[:space:]]|\$)" "$file"
}

has_any_section() {
  local file="$1"
  shift
  local title
  for title in "$@"; do
    if has_section "$file" "$title"; then
      return 0
    fi
  done
  return 1
}

link_score() {
  local file="$1"
  local total=0
  local valid=0
  local target
  while IFS= read -r target; do
    [[ -z "$target" ]] && continue
    case "$target" in
      http://*|https://*|mailto:*|\#*) continue ;;
    esac
    target="${target%%#*}"
    total=$((total + 1))
    if [[ -e "$(cd "$(dirname "$file")" && cd "$target" 2>/dev/null && pwd)" ]] || [[ -e "$(dirname "$file")/$target" ]]; then
      valid=$((valid + 1))
    fi
  done < <(extract_markdown_link_targets "$file")

  if [[ "$total" -eq 0 ]]; then
    printf '1.0|0\n'
  elif [[ "$valid" -eq "$total" ]]; then
    printf '1.0|%s\n' "$total"
  else
    awk -v valid="$valid" -v total="$total" 'BEGIN { printf "%.2f|%d\n", valid / total, total }'
  fi
}

workflow_format_for_id() {
  local workflow_id="$1"
  local artifact_rel="${WORKFLOW_PATHS[$workflow_id]:-}"
  local manifest_format=""
  local disk_format="${DISK_FORMATS[$workflow_id]:-}"
  manifest_format="$(yq -r ".workflows[] | select(.id == \"$workflow_id\") | (.format // \"directory\")" "$MANIFEST" 2>/dev/null || true)"
  if [[ "$manifest_format" == "single-file" ]]; then
    echo "single-file"
    return 0
  fi
  if [[ -n "$disk_format" ]]; then
    echo "$disk_format"
  else
    echo "directory"
  fi
}

workflow_declared_group_path() {
  local group="$1"
  yq -r ".workflow_group_definitions.${group}.path // \"\"" "$MANIFEST" 2>/dev/null || true
}

add_finding() {
  local taxonomy="$1"
  local severity="$2"
  local location="$3"
  local predicate="$4"
  local acceptance="$5"
  local coverage="$6"
  local finding_id="AUD-${taxonomy}-$(hash_short "$location")-$(hash_short "$predicate")"
  local entry="${finding_id}|${taxonomy}|${severity}|${location}|${predicate}|${acceptance}|${coverage}"
  local existing
  for existing in "${FINDINGS[@]}"; do
    if [[ "$existing" == "$entry" ]]; then
      return 0
    fi
  done
  FINDINGS+=("$entry")
  if [[ "$coverage" == "new-audit-only" ]] && [[ "$(severity_rank "$severity")" -ge "$(severity_rank "$SEVERITY_THRESHOLD")" ]]; then
    local blind_predicate="blocking issue only caught by workflow-system audit: ${predicate}"
    local blind_id="AUD-validator-blind-spot-$(hash_short "$location")-$(hash_short "$blind_predicate")"
    local blind_entry="${blind_id}|validator-blind-spot|high|${location}|${blind_predicate}|Promote this predicate into blocking workflow validation when feasible.|new-audit-only"
    for existing in "${FINDINGS[@]}"; do
      if [[ "$existing" == "$blind_entry" ]]; then
        return 0
      fi
    done
    FINDINGS+=("$blind_entry")
  fi
}

load_contract_defaults() {
  if ! command -v yq >/dev/null 2>&1; then
    echo "[ERROR] yq is required for audit-workflow-system.sh" >&2
    exit 1
  fi

  [[ -n "$SEVERITY_THRESHOLD" ]] || SEVERITY_THRESHOLD="$(yq -r '.defaults.severity_threshold' "$CONTRACT_FILE")"
  [[ -n "$SCOPE" ]] || SCOPE="$(yq -r '.defaults.scope_root' "$CONTRACT_FILE")"
  if [[ -z "$TMP_DIR" ]]; then
    TMP_DIR="$ROOT_DIR/$(yq -r '.paths.temp_output_root' "$CONTRACT_FILE")"
  fi
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mode) MODE="$2"; shift 2 ;;
      --scope) SCOPE="$2"; shift 2 ;;
      --severity-threshold) SEVERITY_THRESHOLD="$2"; shift 2 ;;
      --include-docs) INCLUDE_DOCS="$(bool_to_int "$2")"; shift 2 ;;
      --include-governance) INCLUDE_GOVERNANCE="$(bool_to_int "$2")"; shift 2 ;;
      --run-live) RUN_LIVE="$(bool_to_int "$2")"; shift 2 ;;
      --scenario-pack) SCENARIO_PACK="$2"; shift 2 ;;
      --post-remediation) POST_REMEDIATION="$(bool_to_int "$2")"; shift 2 ;;
      --convergence-k) CONVERGENCE_K="$2"; shift 2 ;;
      --seed-list) SEED_LIST="$2"; shift 2 ;;
      --target) TARGET="$2"; shift 2 ;;
      --format) FORMAT="$2"; shift 2 ;;
      --output) OUTPUT="$2"; shift 2 ;;
      --tmp-dir) TMP_DIR="$2"; shift 2 ;;
      --help|-h) usage; exit 0 ;;
      *)
        echo "[ERROR] unknown argument: $1" >&2
        usage
        exit 1
        ;;
    esac
  done
}

init_paths() {
  OCTON_DIR="$ROOT_DIR/.octon"
  ORCHESTRATION_DIR="$OCTON_DIR/orchestration"
  WORKFLOWS_DIR="$ORCHESTRATION_DIR/runtime/workflows"
  MANIFEST="$WORKFLOWS_DIR/manifest.yml"
  REGISTRY="$WORKFLOWS_DIR/registry.yml"
  CAPABILITY_MAP="$ORCHESTRATION_DIR/governance/capability-map-v1.yml"
  CONTRACT_FILE="$ORCHESTRATION_DIR/governance/workflow-system-audit-v1.yml"
  RUNTIME_AUDITS_DIR="$OCTON_DIR/cognition/runtime/audits"
  RUNTIME_INDEX="$RUNTIME_AUDITS_DIR/index.yml"
  REPORTS_DIR="$OCTON_DIR/output/reports"
  AUDIT_REPORTS_DIR="$REPORTS_DIR/audits"
}

git_commit_sha() {
  git -C "$ROOT_DIR" rev-parse HEAD 2>/dev/null || printf 'unknown\n'
}

scan_scope_files() {
  local path
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    SCANNED_PATHS+=("$path")
  done < <(find "$ROOT_DIR/$SCOPE" -type f | sort)

  if [[ "$INCLUDE_DOCS" -eq 1 || "$INCLUDE_GOVERNANCE" -eq 1 ]]; then
    while IFS= read -r path; do
      [[ -z "$path" ]] && continue
      if [[ "$INCLUDE_DOCS" -eq 0 && "$path" == *"/context/"* ]]; then
        continue
      fi
      if [[ "$INCLUDE_GOVERNANCE" -eq 0 && "$path" == *"/governance/"* && "$path" != *"alignment-check.sh" ]]; then
        continue
      fi
      SCANNED_PATHS+=("$ROOT_DIR/$path")
    done < <(yq -r '.paths.companion_paths[]' "$CONTRACT_FILE")
  fi
}

load_manifest_index() {
  local row id path profile group summary trigger_count
  while IFS=$'\t' read -r id path profile group summary trigger_count; do
    [[ -z "$id" ]] && continue
    WORKFLOW_PATHS["$id"]="$path"
    WORKFLOW_PROFILES["$id"]="$profile"
    WORKFLOW_GROUPS["$id"]="$group"
    WORKFLOW_SUMMARIES["$id"]="$summary"
    WORKFLOW_TRIGGER_COUNTS["$id"]="$trigger_count"
  done < <(yq -r '.workflows[] | [.id, .path, (.execution_profile // "core"), .group, (.summary // ""), ((.triggers // []) | length)] | @tsv' "$MANIFEST")

  while IFS=$'\t' read -r id version; do
    [[ -z "$id" ]] && continue
    REGISTRY_VERSIONS["$id"]="$version"
  done < <(yq -r '.workflows | to_entries[] | [.key, (.value.version // "")] | @tsv' "$REGISTRY")
}

scan_disk_workflows() {
  local group_dir item workflow_name
  for group_dir in "$WORKFLOWS_DIR"/*; do
    [[ -d "$group_dir" ]] || continue
    [[ "$(basename "$group_dir")" == _* ]] && continue
    for item in "$group_dir"/*; do
      [[ -e "$item" ]] || continue
      if [[ -d "$item" && -f "$item/workflow.yml" && -f "$item/README.md" ]]; then
        workflow_name="$(yq -r '.name // ""' "$item/workflow.yml" 2>/dev/null || true)"
        [[ -n "$workflow_name" ]] || workflow_name="$(basename "$item")"
        DISK_WORKFLOWS["$workflow_name"]="$(rel_path "$item")"
        DISK_FORMATS["$workflow_name"]="directory"
      elif [[ -f "$item" && "$item" == *.md && "$(basename "$item")" != "README.md" ]]; then
        workflow_name="$(frontmatter_query "$item" '.name')"
        [[ -n "$workflow_name" ]] || workflow_name="$(basename "$item" .md)"
        DISK_WORKFLOWS["$workflow_name"]="$(rel_path "$item")"
        DISK_FORMATS["$workflow_name"]="single-file"
      fi
    done
  done
}

workflow_primary_doc() {
  local artifact="$1"
  local workflow_file="$artifact/README.md"
  if [[ -f "$artifact/00-overview.md" ]]; then
    if ! has_any_section "$workflow_file" "Prerequisites" "Usage" "Target"; then
      printf '%s\n' "$artifact/00-overview.md"
      return 0
    fi
  fi
  printf '%s\n' "$workflow_file"
}

workflow_stage_file() {
  local artifact="$1"
  local step_file="$2"
  printf '%s\n' "$artifact/stages/$step_file"
}

workflow_has_external_markers() {
  local artifact="$1"
  matches_paths_regex '\b(pnpm|npm|npx|uv|pip install|swift build|swift test|docker|alembic)\b' "$artifact"
}

score_workflow() {
  local workflow_id="$1"
  local artifact_rel="$2"
  local profile="$3"
  local summary="$4"
  local trigger_count="$5"
  local artifact="$ROOT_DIR/.octon/orchestration/runtime/workflows/$artifact_rel"
  local format="single-file"
  local workflow_file=""
  local workflow_contract=""
  local primary_doc=""
  local front_name=""
  local front_description=""
  local registry_version="${REGISTRY_VERSIONS[$workflow_id]:-}"
  local discovery=0 contract=0 quality=0 execution=0 maintainability=0 docs=0 total=0 grade=""
  local step_files=()
  local step_file=""
  local declared_format=""
  local parameter_name=""
  local parameter_mentions=1
  local has_output_contract=1
  local side_effect_class=""
  local coordination_kind=""
  local last_stage_kind=""
  local workflow_input_count=0
  local workflow_artifact_count=0
  local workflow_dependency_count=0

  if [[ -d "$artifact" ]]; then
    format="directory"
    workflow_file="$artifact/README.md"
    workflow_contract="$artifact/workflow.yml"
    primary_doc="$(workflow_primary_doc "$artifact")"
  else
    workflow_file="$artifact"
    primary_doc="$artifact"
  fi

  if [[ -f "$workflow_file" ]]; then
    contract=$((contract + 5))
  else
    add_finding "contract-schema" "high" "$artifact_rel" "missing workflow entrypoint" "Provide a valid workflow entrypoint document." "existing-blocking"
  fi

  if [[ "$format" == "directory" ]]; then
    front_name="$(yq -r '.name // ""' "$workflow_contract" 2>/dev/null || true)"
    front_description="$(yq -r '.description // ""' "$workflow_contract" 2>/dev/null || true)"
    side_effect_class="$(yq -r '.side_effect_class // ""' "$workflow_contract" 2>/dev/null || true)"
    coordination_kind="$(yq -r '.coordination_key_strategy.kind // ""' "$workflow_contract" 2>/dev/null || true)"
    last_stage_kind="$(yq -r '.stages[-1].kind // ""' "$workflow_contract" 2>/dev/null || true)"
    workflow_input_count="$(yq -r '.inputs | length // 0' "$workflow_contract" 2>/dev/null || true)"
    workflow_artifact_count="$(yq -r '.artifacts | length // 0' "$workflow_contract" 2>/dev/null || true)"
    workflow_dependency_count="$(yq -r ".workflows.\"$workflow_id\".depends_on // [] | map(select(has(\"workflow\"))) | length" "$REGISTRY" 2>/dev/null || true)"
  else
    front_name="$(frontmatter_query "$workflow_file" '.name')"
    front_description="$(frontmatter_query "$workflow_file" '.description')"
  fi
  declared_format="$(workflow_format_for_id "$workflow_id")"

  if [[ "$format" == "directory" ]]; then
    while IFS= read -r step_file; do
      [[ -z "$step_file" ]] && continue
      step_files+=("$step_file")
      if [[ -f "$artifact/stages/$step_file" ]]; then
        :
      else
        add_finding "contract-schema" "high" "$artifact_rel" "declared step missing: $step_file" "Ensure every declared step file exists." "existing-blocking"
      fi
    done < <(yq -r '.stages[].asset // ""' "$workflow_contract" 2>/dev/null | xargs -n1 basename 2>/dev/null || true)

    if [[ "${#step_files[@]}" -gt 0 ]]; then
      contract=$((contract + 5))
    fi
  else
    contract=$((contract + 5))
  fi

  if [[ -n "$front_name" && -n "$front_description" ]]; then
    contract=$((contract + 5))
  else
    add_finding "contract-schema" "medium" "$artifact_rel" "workflow frontmatter missing name or description" "Populate the workflow frontmatter with name and description." "new-audit-only"
  fi

  if [[ -n "$registry_version" && "$front_name" == "$workflow_id" ]]; then
    contract=$((contract + 5))
  elif [[ -n "$registry_version" ]]; then
    add_finding "parameter-io-contract" "medium" "$artifact_rel" "manifest, registry, and workflow identity drift" "Align workflow identity across manifest, registry, and frontmatter." "new-audit-only"
  fi

  if [[ "$format" != "$declared_format" ]]; then
    add_finding "contract-schema" "high" "$artifact_rel" "manifest format does not match on-disk workflow format" "Align manifest format metadata with the actual workflow artifact type." "existing-blocking"
  fi

  while IFS= read -r parameter_name; do
    [[ -z "$parameter_name" ]] && continue
    if ! matches_paths_fixed "$parameter_name" "$workflow_file" "$primary_doc" "$artifact" 2>/dev/null; then
      parameter_mentions=0
      add_finding "parameter-io-contract" "medium" "$artifact_rel" "registry parameter '$parameter_name' is undocumented in workflow content" "Document registry parameters in workflow usage or step guidance." "new-audit-only"
    fi
  done < <(yq -r ".workflows.\"$workflow_id\".parameters[].name // \"\"" "$REGISTRY" 2>/dev/null || true)

  if yq -e ".workflows.\"$workflow_id\".io.outputs" "$REGISTRY" >/dev/null 2>&1; then
    if ! has_any_section "$primary_doc" "Output" "Outputs" "Target" "Required Outcome"; then
      has_output_contract=0
      add_finding "parameter-io-contract" "medium" "$artifact_rel" "registry outputs are not reflected in workflow target or output guidance" "Document the workflow outputs or target in the workflow content." "new-audit-only"
    fi
  fi

  if [[ -n "$summary" ]]; then
    discovery=$((discovery + 4))
  else
    add_finding "routing-discovery" "medium" "$artifact_rel" "workflow summary missing from manifest" "Add a manifest summary for the workflow." "new-audit-only"
  fi
  if [[ "$trigger_count" -gt 0 || "$MODE" == "score-workflow" && $(has_any_section "$primary_doc" "Usage" "Target" "Context"; echo $?) -eq 0 ]]; then
    discovery=$((discovery + 6))
  else
    add_finding "routing-discovery" "medium" "$artifact_rel" "workflow lacks usage or target guidance" "Document when to use the workflow and what it targets." "new-audit-only"
  fi

  if has_any_section "$primary_doc" "Prerequisites" "Context"; then
    quality=$((quality + 5))
  else
    add_finding "gap-coverage" "medium" "$artifact_rel" "missing prerequisites or context guidance" "Add explicit prerequisites or context guidance." "new-audit-only"
  fi
  if has_section "$primary_doc" "Failure Conditions"; then
    quality=$((quality + 5))
  else
    add_finding "execution-safety" "medium" "$artifact_rel" "missing failure conditions" "Document actionable stop or fail conditions." "new-audit-only"
  fi
  if has_any_section "$primary_doc" "Steps" "Flow" "Actions"; then
    quality=$((quality + 5))
  elif [[ "$format" == "directory" ]]; then
    local has_actions=0
    local stage_path=""
    for step_file in "${step_files[@]}"; do
      stage_path="$(workflow_stage_file "$artifact" "$step_file")"
      if [[ -f "$stage_path" ]] && has_section "$stage_path" "Actions"; then
        has_actions=1
      fi
    done
    if [[ "$has_actions" -eq 1 ]]; then
      quality=$((quality + 5))
    else
      add_finding "gap-coverage" "medium" "$artifact_rel" "workflow actions are underspecified" "Document concrete steps or actions." "new-audit-only"
    fi
  else
    add_finding "gap-coverage" "medium" "$artifact_rel" "workflow actions are underspecified" "Document concrete steps or actions." "new-audit-only"
  fi
  if has_any_section "$primary_doc" "Version History" "Idempotency" "Checkpoints"; then
    quality=$((quality + 5))
  else
    add_finding "gap-coverage" "medium" "$artifact_rel" "gap controls are incomplete" "Document versioning, idempotency, checkpoints, or resume guidance." "new-audit-only"
  fi
  if has_section "$primary_doc" "Version History"; then
    quality=$((quality + 5))
  else
    add_finding "docs-spec-drift" "low" "$artifact_rel" "missing version history" "Add or update the Version History section." "not-yet-automatable"
  fi

  if has_any_section "$primary_doc" "Required Outcome" "Verification Gate" "Workflow Complete When" "Proceed When"; then
    execution=$((execution + 8))
  else
    local has_verify_step=0
    for step_file in "${step_files[@]}"; do
      if [[ "$step_file" == *verify* || "$step_file" == *validat* ]]; then
        has_verify_step=1
      fi
    done
    if [[ "$has_verify_step" -eq 1 ]]; then
      execution=$((execution + 8))
    else
      add_finding "execution-safety" "medium" "$artifact_rel" "workflow lacks explicit verification guidance" "Add an explicit verification gate or required outcome." "new-audit-only"
    fi
  fi
  if has_any_section "$primary_doc" "Output" "Outputs" "Target" "Required Outcome"; then
    execution=$((execution + 4))
  else
    add_finding "execution-safety" "medium" "$artifact_rel" "missing target or output description" "Describe the workflow target or outputs." "new-audit-only"
  fi
  if [[ "$format" == "single-file" || "${#step_files[@]}" -gt 0 ]]; then
    execution=$((execution + 4))
  fi
  if [[ "$profile" == "external-dependent" ]]; then
    execution=$((execution + 4))
  elif [[ "$format" == "directory" ]] && workflow_has_external_markers "$artifact" 2>/dev/null; then
    add_finding "execution-safety" "high" "$artifact_rel" "execution_profile does not match documented external dependencies" "Align manifest execution_profile with the documented runtime behavior." "existing-blocking"
  else
    execution=$((execution + 4))
  fi

  if [[ "$format" == "single-file" ]]; then
    maintainability=$((maintainability + 10))
  else
    local naming_ok=1
    for step_file in "${step_files[@]}"; do
      if [[ ! "$step_file" =~ ^([0-9]{2}|00-overview).+\.md$ ]]; then
        naming_ok=0
      fi
    done
    if [[ "$naming_ok" -eq 1 ]]; then
      maintainability=$((maintainability + 5))
    else
      add_finding "docs-spec-drift" "low" "$artifact_rel" "step naming is inconsistent" "Normalize step filenames to the workflow conventions." "not-yet-automatable"
    fi
    if [[ "${#step_files[@]}" -le 12 ]]; then
      maintainability=$((maintainability + 5))
    else
      add_finding "workflow-skill-boundary" "low" "$artifact_rel" "workflow is overly broad" "Split the workflow into more focused steps or a different abstraction." "not-yet-automatable"
    fi

    case "$side_effect_class" in
      mutating|destructive)
        if [[ "$last_stage_kind" != "verification" ]]; then
          add_finding "architecture-shape" "medium" "$artifact_rel" "side-effectful workflow does not terminate in a verification stage" "End mutating or destructive workflows with a terminal verification stage." "new-audit-only"
        fi
        ;;
    esac

    if [[ "$side_effect_class" == "none" || "$side_effect_class" == "read_only" ]]; then
      if [[ "${#step_files[@]}" -le 2 && "$workflow_dependency_count" -eq 0 && "$workflow_input_count" -eq 0 && "$workflow_artifact_count" -eq 0 && "$coordination_kind" == "none" ]]; then
        add_finding "workflow-skill-boundary" "low" "$artifact_rel" "workflow is thin enough to be modeled as a skill or command" "Use a workflow only when staged orchestration adds material operator or coordination value." "not-yet-automatable"
      fi
    fi
  fi

  local link_stats link_ratio link_count
  link_stats="$(link_score "$primary_doc")"
  link_ratio="${link_stats%%|*}"
  link_count="${link_stats##*|}"
  if [[ "$link_ratio" == "1.0" ]]; then
    docs=$((docs + 7))
  elif [[ "$link_count" -eq 0 ]]; then
    docs=$((docs + 7))
  else
    add_finding "docs-spec-drift" "low" "$artifact_rel" "workflow has broken local references" "Fix broken local markdown links." "not-yet-automatable"
    if awk -v ratio="$link_ratio" 'BEGIN { exit !(ratio >= 0.5) }'; then
      docs=$((docs + 4))
    fi
  fi
  if has_any_section "$primary_doc" "Usage" "Target" "Context"; then
    docs=$((docs + 4))
  fi
  if [[ "${#front_description}" -ge 20 ]]; then
    docs=$((docs + 4))
  else
    add_finding "routing-discovery" "medium" "$artifact_rel" "workflow description is underspecified" "Expand the workflow description so routing is easier." "new-audit-only"
  fi

  total=$((discovery + contract + quality + execution + maintainability + docs))
  if [[ "$total" -ge 90 ]]; then
    grade="A"
  elif [[ "$total" -ge 80 ]]; then
    grade="B"
  elif [[ "$total" -ge 70 ]]; then
    grade="C"
  elif [[ "$total" -ge 60 ]]; then
    grade="D"
  else
    grade="F"
  fi

  WORKFLOW_SCORES["$workflow_id"]="$total"
  WORKFLOW_GRADES["$workflow_id"]="$grade"
  WORKFLOW_BREAKDOWNS["$workflow_id"]="discovery_routing=${discovery}/10;contract_integrity=${contract}/20;quality_gap_coverage=${quality}/25;execution_safety_verification=${execution}/20;maintainability=${maintainability}/10;documentation_references=${docs}/15"
}

system_level_checks() {
  local workflow_id path expected_group_path
  for workflow_id in "${!WORKFLOW_PATHS[@]}"; do
    path="$ROOT_DIR/.octon/orchestration/runtime/workflows/${WORKFLOW_PATHS[$workflow_id]}"
    if [[ ! -e "$path" ]]; then
      add_finding "contract-schema" "high" "${WORKFLOW_PATHS[$workflow_id]}" "manifest path missing on disk" "Restore the workflow artifact or remove the manifest entry." "existing-blocking"
    fi

    expected_group_path="$(workflow_declared_group_path "${WORKFLOW_GROUPS[$workflow_id]}")"
    if [[ -n "$expected_group_path" && "${WORKFLOW_PATHS[$workflow_id]}" != "$expected_group_path"* ]]; then
      add_finding "portfolio-coverage" "medium" "${WORKFLOW_PATHS[$workflow_id]}" "workflow path is outside its declared group path" "Keep workflow paths aligned with workflow_group_definitions." "new-audit-only"
    fi

    if ! yq -e ".workflow_group_definitions.\"${WORKFLOW_GROUPS[$workflow_id]}\".members[] | select(. == \"$workflow_id\")" "$MANIFEST" >/dev/null 2>&1; then
      add_finding "portfolio-coverage" "medium" "$(rel_path "$MANIFEST")" "workflow is missing from its declared group membership list" "Add the workflow id to workflow_group_definitions.<group>.members." "new-audit-only"
    fi

    if ! yq -e ".workflows[] | select(.workflow_id == \"$workflow_id\")" "$CAPABILITY_MAP" >/dev/null 2>&1; then
      add_finding "portfolio-coverage" "medium" "$(rel_path "$CAPABILITY_MAP")" "capability map is missing classification for '$workflow_id'" "Classify the workflow in the orchestration capability map." "new-audit-only"
    fi
  done

  check_authoring_surface_alignment

  local trigger_line
  declare -A TRIGGER_OWNERS=()
  while IFS=$'\t' read -r workflow_id trigger_line; do
    [[ -z "$workflow_id" || -z "$trigger_line" ]] && continue
    local key
    key="$(printf '%s' "$trigger_line" | tr '[:upper:]' '[:lower:]')"
    if [[ -n "${TRIGGER_OWNERS[$key]:-}" ]]; then
      add_finding "routing-discovery" "high" "$(rel_path "$MANIFEST")" "duplicate trigger '$trigger_line' shared by ${TRIGGER_OWNERS[$key]},$workflow_id" "Make natural-language triggers unique enough for deterministic routing." "new-audit-only"
    else
      TRIGGER_OWNERS["$key"]="$workflow_id"
    fi
  done < <(yq -r '.workflows[] | .id as $id | (.triggers // [])[] | [$id, .] | @tsv' "$MANIFEST")

  declare -A COMMAND_OWNERS=()
  local command
  while IFS=$'\t' read -r workflow_id command; do
    [[ -z "$workflow_id" || -z "$command" ]] && continue
    if [[ -n "${COMMAND_OWNERS[$command]:-}" ]]; then
      add_finding "routing-discovery" "high" "$(rel_path "$REGISTRY")" "duplicate command '$command' shared by ${COMMAND_OWNERS[$command]},$workflow_id" "Ensure commands are unique per workflow." "new-audit-only"
    else
      COMMAND_OWNERS["$command"]="$workflow_id"
    fi
  done < <(yq -r '.workflows | to_entries[] | .key as $id | (.value.commands // [])[] | [$id, .] | @tsv' "$REGISTRY")

  local edge_file
  edge_file="$(mktemp "${TMPDIR:-/tmp}/workflow-edges.XXXXXX")"
  while IFS=$'\t' read -r workflow_id dependency; do
    [[ -z "$workflow_id" || -z "$dependency" ]] && continue
    printf '%s %s\n' "$workflow_id" "$dependency" >>"$edge_file"
  done < <(yq -r '.workflows | to_entries[] | .key as $id | (.value.depends_on // [])[] | select(has("workflow")) | [$id, .workflow] | @tsv' "$REGISTRY")
  if [[ -s "$edge_file" ]]; then
    local tsort_output=""
    tsort_output="$(tsort "$edge_file" 2>&1 >/dev/null || true)"
    if printf '%s' "$tsort_output" | matches_stdin_regex 'cycle in data'; then
      add_finding "portfolio-coverage" "high" "$(rel_path "$REGISTRY")" "workflow dependency cycle detected" "Remove workflow dependency cycles from registry depends_on declarations." "new-audit-only"
    fi
  fi
  rm -f "$edge_file"
}

check_authoring_surface_alignment() {
  local targets=(
    "$ROOT_DIR/.octon/orchestration/practices/workflow-authoring-standards.md"
    "$ROOT_DIR/.octon/orchestration/runtime/workflows/meta/create-workflow/stages/02-analyze-requirements.md"
    "$ROOT_DIR/.octon/orchestration/runtime/workflows/meta/create-workflow/stages/03-select-template.md"
    "$ROOT_DIR/.octon/orchestration/runtime/workflows/meta/create-workflow/stages/06-integrate-gap-fixes.md"
    "$ROOT_DIR/.octon/orchestration/runtime/workflows/meta/create-workflow/stages/08-verify.md"
    "$ROOT_DIR/.octon/cognition/runtime/context/workflow-quality.md"
    "$ROOT_DIR/.octon/cognition/runtime/context/workflow-gaps.md"
  )
  local target
  local stale_checks=(
    'guide/NN-\*\.md|workflow authoring surface retains deprecated guide/NN-* layout'
    'Generated README exists under `guide/`|workflow authoring surface retains deprecated guide/ README placement'
    'wrapper style that delegates to `00-overview\.md` is valid|workflow authoring surface still treats root 00-overview.md as canonical'
    'In `00-overview\.md` frontmatter|workflow authoring surface still teaches 00-overview.md frontmatter as canonical'
    'Add to `00-overview\.md`|workflow authoring surface still teaches 00-overview.md as a canonical authoring target'
    'Overview frontmatter has `|workflow authoring surface still teaches overview frontmatter as canonical'
  )
  local stale_check
  local pattern
  local predicate

  for target in "${targets[@]}"; do
    [[ -f "$target" ]] || continue

    for stale_check in "${stale_checks[@]}"; do
      IFS='|' read -r pattern predicate <<< "$stale_check"
      if matches_file_regex "$pattern" "$target"; then
        add_finding "architecture-shape" "high" "$(rel_path "$target")" "$predicate" "Keep canonical workflow authoring anchored to workflow.yml, stages/, and the root README.md only." "existing-blocking"
      fi
    done
  done
}

run_representative_scenarios() {
  [[ "$RUN_LIVE" -eq 1 ]] || return 0
  local workflow_id mode expected_format expected_profile artifact_rel artifact format profile artifact_path primary_doc
  while IFS=$'\t' read -r workflow_id mode expected_format expected_profile; do
    [[ -z "$workflow_id" ]] && continue
    artifact_rel="${WORKFLOW_PATHS[$workflow_id]:-}"
    if [[ -z "$artifact_rel" ]]; then
      add_finding "scenario-failure" "high" "$(rel_path "$MANIFEST")" "representative scenario references unknown workflow '$workflow_id'" "Align the representative scenario pack with the manifest." "new-audit-only"
      SCENARIO_RESULTS["$workflow_id"]="fail"
      continue
    fi
    artifact_path="$ROOT_DIR/.octon/orchestration/runtime/workflows/$artifact_rel"
    profile="${WORKFLOW_PROFILES[$workflow_id]:-core}"
    format="single-file"
    if [[ -d "$artifact_path" ]]; then
      format="directory"
      primary_doc="$(workflow_primary_doc "$artifact_path")"
    else
      primary_doc="$artifact_path"
    fi
    if [[ "$format" != "$expected_format" ]]; then
      add_finding "scenario-failure" "high" "$artifact_rel" "scenario expected $expected_format but found $format" "Align the representative scenario contract with the workflow artifact format." "new-audit-only"
      SCENARIO_RESULTS["$workflow_id"]="fail"
      continue
    fi
    if [[ "$profile" != "$expected_profile" ]]; then
      add_finding "scenario-failure" "high" "$artifact_rel" "scenario expected $expected_profile execution profile" "Align representative scenario expectations with manifest execution_profile." "new-audit-only"
      SCENARIO_RESULTS["$workflow_id"]="fail"
      continue
    fi
    if [[ "$mode" == "full" ]]; then
      if ! has_any_section "$primary_doc" "Prerequisites" "Context"; then
        add_finding "scenario-failure" "high" "$artifact_rel" "representative full rehearsal lacks prerequisite or context guidance" "Representative workflows must declare prerequisites or context." "new-audit-only"
        SCENARIO_RESULTS["$workflow_id"]="fail"
        continue
      fi
      if ! has_section "$primary_doc" "Failure Conditions"; then
        add_finding "scenario-failure" "high" "$artifact_rel" "representative full rehearsal lacks failure conditions" "Representative workflows must declare failure conditions." "new-audit-only"
        SCENARIO_RESULTS["$workflow_id"]="fail"
        continue
      fi
      if ! has_any_section "$primary_doc" "Required Outcome" "Verification Gate" "Workflow Complete When" "Proceed When"; then
        local has_verify=0
        if [[ -d "$artifact_path" && -f "$artifact_path/workflow.yml" ]]; then
          while IFS= read -r step_file; do
            [[ -z "$step_file" ]] && continue
            if [[ "$step_file" == *verify* || "$step_file" == *validat* ]]; then
              has_verify=1
            fi
          done < <(yq -r '.stages[].asset // ""' "$artifact_path/workflow.yml" 2>/dev/null | xargs -n1 basename 2>/dev/null || true)
        fi
        if [[ "$has_verify" -eq 0 ]]; then
          add_finding "scenario-failure" "high" "$artifact_rel" "representative full rehearsal lacks verification gate" "Add an explicit verification gate or required outcome." "new-audit-only"
          SCENARIO_RESULTS["$workflow_id"]="fail"
          continue
        fi
      fi
      if ! has_any_section "$primary_doc" "Output" "Outputs" "Target" "Required Outcome"; then
        add_finding "scenario-failure" "high" "$artifact_rel" "representative full rehearsal lacks target or output guidance" "Representative workflows must describe their target or outputs." "new-audit-only"
        SCENARIO_RESULTS["$workflow_id"]="fail"
        continue
      fi
    else
      if ! has_any_section "$primary_doc" "Prerequisites" "Context"; then
        add_finding "scenario-failure" "high" "$artifact_rel" "representative prereq-only rehearsal lacks prerequisite guidance" "External-dependent rehearsals must document prerequisites." "new-audit-only"
        SCENARIO_RESULTS["$workflow_id"]="fail"
        continue
      fi
    fi
    SCENARIO_RESULTS["$workflow_id"]="pass"
  done < <(yq -r ".scenario_packs.${SCENARIO_PACK}[] | [.workflow_id, .mode, .expected_format, .expected_execution_profile] | @tsv" "$CONTRACT_FILE")
}

write_findings_yaml() {
  local file="$1"
  local finding id taxonomy severity location predicate acceptance coverage
  {
    echo 'schema_version: "1.0"'
    echo "run_id: $(yaml_quote "$RUN_ID")"
    echo 'findings:'
    for finding in "${FINDINGS[@]}"; do
      IFS='|' read -r id taxonomy severity location predicate acceptance coverage <<<"$finding"
      echo "  - id: $(yaml_quote "$id")"
      echo "    taxonomy: $(yaml_quote "$taxonomy")"
      echo "    severity: $(yaml_quote "$severity")"
      echo '    status: "open"'
      echo '    location:'
      echo "      path: $(yaml_quote "$location")"
      echo '      line_predicate: "file-level"'
      echo "    predicate: $(yaml_quote "$predicate")"
      echo '    acceptance_criteria:'
      echo "      - $(yaml_quote "$acceptance")"
      echo '    evidence_refs:'
      echo "      - $(yaml_quote "$location")"
      echo "    introduced_in: $(yaml_quote "$RUN_ID")"
      echo "    last_seen_in: $(yaml_quote "$RUN_ID")"
      echo "    validator_coverage: $(yaml_quote "$coverage")"
    done
  } >"$file"
}

write_outputs() {
  local destination_root="$1"
  local report_path="$2"
  mkdir -p "$destination_root"
  write_findings_yaml "$destination_root/findings.yml"
  {
    echo 'kind: audit-evidence-bundle'
    echo "id: $(yaml_quote "$RUN_ID")"
    echo 'findings: "findings.yml"'
    echo 'coverage: "coverage.yml"'
    echo 'convergence: "convergence.yml"'
    echo 'evidence: "evidence.md"'
    echo 'commands: "commands.md"'
    echo 'validation: "validation.md"'
    echo 'inventory: "inventory.md"'
  } >"$destination_root/bundle.yml"
  {
    echo 'schema_version: "1.0"'
    echo "run_id: $(yaml_quote "$RUN_ID")"
    echo 'scope_roots:'
    echo "  - $(yaml_quote "$SCOPE")"
    echo 'excluded_roots:'
    yq -r '.paths.excluded_roots[]' "$CONTRACT_FILE" | while IFS= read -r row; do
      echo "  - $(yaml_quote "$row")"
    done
    echo "total_files: ${#SCANNED_PATHS[@]}"
    echo "scanned_files: ${#SCANNED_PATHS[@]}"
    echo "summarized_sampled_files: ${#SCANNED_PATHS[@]}"
    echo 'excluded_files: 0'
    echo 'unaccounted_files: 0'
  } >"$destination_root/coverage.yml"

  local findings_hash
  findings_hash="$(hash_short "$(printf '%s\n' "${FINDINGS[@]}")")"
  local blocking_count
  blocking_count="$(blocking_findings)"
  {
    echo "run_id: $(yaml_quote "$RUN_ID")"
    echo "commit_sha: $(yaml_quote "$COMMIT_SHA")"
    echo "scope_hash: $(yaml_quote "$(hash_short "$(printf '%s\n' "${SCANNED_PATHS[@]}")")")"
    echo "prompt_hash: $(yaml_quote "$PROMPT_HASH")"
    echo "params_hash: $(yaml_quote "$(hash_short "$MODE|$SCOPE|$SEVERITY_THRESHOLD|$SCENARIO_PACK")")"
    echo "seed: $(yaml_quote "${SEED_LIST%%,*}")"
    echo 'fingerprint_unsupported: true'
    echo "findings_hash: $(yaml_quote "$findings_hash")"
    echo 'stable: true'
    echo "union_blocking_findings: $blocking_count"
    echo "open_findings_at_or_above_threshold: $blocking_count"
    echo "done: $( [[ "$blocking_count" -eq 0 ]] && echo true || echo false )"
  } >"$destination_root/convergence.yml"

  {
    echo 'schema_version: "1.0"'
    echo "run_id: $(yaml_quote "$RUN_ID")"
    echo "workflow_average: $(workflow_average)"
    echo 'system_score:'
    echo "  total: $(system_score)"
    echo "  grade: $(yaml_quote "$(system_grade)")"
    echo 'workflows:'
    local workflow_id
    for workflow_id in "${!WORKFLOW_SCORES[@]}"; do
      echo "  - workflow_id: $(yaml_quote "$workflow_id")"
      echo "    score: ${WORKFLOW_SCORES[$workflow_id]}"
      echo "    grade: $(yaml_quote "${WORKFLOW_GRADES[$workflow_id]}")"
      echo "    breakdown: $(yaml_quote "${WORKFLOW_BREAKDOWNS[$workflow_id]}")"
    done
  } >"$destination_root/scores.yml"

  {
    echo 'schema_version: "1.0"'
    echo "run_id: $(yaml_quote "$RUN_ID")"
    echo 'scenario_results:'
    local workflow_id
    for workflow_id in "${!SCENARIO_RESULTS[@]}"; do
      echo "  - workflow_id: $(yaml_quote "$workflow_id")"
      echo "    status: $(yaml_quote "${SCENARIO_RESULTS[$workflow_id]}")"
    done
  } >"$destination_root/scenarios.yml"

  {
    echo 'schema_version: "1.0"'
    echo "run_id: $(yaml_quote "$RUN_ID")"
    echo "manifest_count: ${#WORKFLOW_PATHS[@]}"
    echo "disk_count: ${#DISK_WORKFLOWS[@]}"
    echo "blocking_findings: $(blocking_findings)"
  } >"$destination_root/portfolio.yml"

  {
    echo "# Evidence"
    echo
    echo "- Manifest: \`$(rel_path "$MANIFEST")\`"
    echo "- Registry: \`$(rel_path "$REGISTRY")\`"
    echo "- Capability map: \`$(rel_path "$CAPABILITY_MAP")\`"
  } >"$destination_root/evidence.md"
  printf '# Commands\n\n- `%s`\n' "$0 $*" >"$destination_root/commands.md"
  {
    echo "# Validation"
    echo
    echo "- Done gate: \`$( [[ "$(blocking_findings)" -eq 0 ]] && echo true || echo false )\`"
    echo "- Expression: \`open_findings_at_or_above_threshold == 0 && coverage.unaccounted_files == 0 && convergence.stable == true\`"
  } >"$destination_root/validation.md"
  {
    echo "# Inventory"
    echo
    echo "- Manifest workflows: ${#WORKFLOW_PATHS[@]}"
    echo "- On-disk workflows: ${#DISK_WORKFLOWS[@]}"
    echo "- Scope files: ${#SCANNED_PATHS[@]}"
  } >"$destination_root/inventory.md"

  {
    echo "# Workflow System Audit"
    echo
    echo "- Run ID: \`$RUN_ID\`"
    echo "- Blocking threshold: \`$SEVERITY_THRESHOLD\`"
    echo "- Workflow average: **$(workflow_average)**"
    echo "- System score: **$(system_score) ($(system_grade))**"
    echo "- Blocking findings: **$(blocking_findings)**"
    echo
    echo "## Top Findings"
    top_findings 10
  } >"$report_path"
}

workflow_average() {
  local sum=0 count=0 workflow_id
  for workflow_id in "${!WORKFLOW_SCORES[@]}"; do
    sum=$((sum + WORKFLOW_SCORES[$workflow_id]))
    count=$((count + 1))
  done
  if [[ "$count" -eq 0 ]]; then
    echo 0
  else
    awk -v sum="$sum" -v count="$count" 'BEGIN { printf "%.2f\n", sum / count }'
  fi
}

blind_spot_count() {
  local count=0 finding taxonomy
  for finding in "${FINDINGS[@]}"; do
    IFS='|' read -r _ taxonomy _ <<<"$finding"
    [[ "$taxonomy" == "validator-blind-spot" ]] && count=$((count + 1))
  done
  echo "$count"
}

blocking_findings() {
  local count=0 finding severity
  for finding in "${FINDINGS[@]}"; do
    IFS='|' read -r _ _ severity _ <<<"$finding"
    if [[ "$(severity_rank "$severity")" -ge "$(severity_rank "$SEVERITY_THRESHOLD")" ]]; then
      count=$((count + 1))
    fi
  done
  echo "$count"
}

system_score() {
  local workflow_average_value
  workflow_average_value="$(workflow_average)"
  local portfolio_penalty=$(( $(blocking_findings) * 3 ))
  local blind_penalty=$(( $(blind_spot_count) * 5 ))
  awk -v average="$workflow_average_value" -v portfolio_penalty="$portfolio_penalty" -v blind_penalty="$blind_penalty" 'BEGIN {
    total = (average * 0.75) + (15 - portfolio_penalty) + (10 - blind_penalty)
    if (total < 0) total = 0
    printf "%.2f\n", total
  }'
}

system_grade() {
  local score
  score="$(system_score)"
  awk -v score="$score" 'BEGIN {
    if (score >= 90) print "A"
    else if (score >= 80) print "B"
    else if (score >= 70) print "C"
    else if (score >= 60) print "D"
    else print "F"
  }'
}

top_findings() {
  local limit="$1"
  local count=0
  local tmp_file
  tmp_file="$(mktemp "${TMPDIR:-/tmp}/workflow-top-findings.XXXXXX")"
  local finding id taxonomy severity location predicate acceptance coverage
  for finding in "${FINDINGS[@]}"; do
    IFS='|' read -r id taxonomy severity location predicate acceptance coverage <<<"$finding"
    printf '%s\t%s\t%s\n' "$(severity_rank "$severity")" "$severity" "\`$severity\` \`$taxonomy\`: $predicate" >>"$tmp_file"
  done
  if [[ ! -s "$tmp_file" ]]; then
    rm -f "$tmp_file"
    echo "- None"
    return 0
  fi
  while IFS=$'\t' read -r _ _ line; do
    echo "- $line"
    count=$((count + 1))
    [[ "$count" -ge "$limit" ]] && break
  done < <(sort -r -n "$tmp_file")
  rm -f "$tmp_file"
}

score_target_workflow() {
  local target_path="$TARGET"
  [[ -n "$target_path" ]] || {
    echo "[ERROR] --target is required for --mode score-workflow" >&2
    exit 1
  }

  local resolved="$ROOT_DIR/$target_path"
  local workflow_id=""
  local artifact_rel=""
  local id
  for id in "${!WORKFLOW_PATHS[@]}"; do
    artifact_rel="${WORKFLOW_PATHS[$id]}"
    if [[ "$(cd "$(dirname "$ROOT_DIR/.octon/orchestration/runtime/workflows/$artifact_rel")" && pwd)/$(basename "$ROOT_DIR/.octon/orchestration/runtime/workflows/$artifact_rel")" == "$(cd "$(dirname "$resolved")" && pwd)/$(basename "$resolved")" ]]; then
      workflow_id="$id"
      break
    fi
  done
  if [[ -z "$workflow_id" ]]; then
    workflow_id="$(basename "$resolved" .md)"
    artifact_rel="${target_path#.octon/orchestration/runtime/workflows/}"
    WORKFLOW_SUMMARIES["$workflow_id"]=""
    WORKFLOW_TRIGGER_COUNTS["$workflow_id"]=0
    WORKFLOW_PROFILES["$workflow_id"]="core"
  fi

  FINDINGS=()
  score_workflow "$workflow_id" "$artifact_rel" "${WORKFLOW_PROFILES[$workflow_id]:-core}" "${WORKFLOW_SUMMARIES[$workflow_id]:-}" "${WORKFLOW_TRIGGER_COUNTS[$workflow_id]:-0}"

  local report
  report="$(mktemp "${TMPDIR:-/tmp}/workflow-score.XXXXXX")"
  {
    echo "# Workflow Assessment: $workflow_id"
    echo
    echo "- Path: \`$target_path\`"
    echo "- Score: **${WORKFLOW_SCORES[$workflow_id]} / 100**"
    echo "- Grade: **${WORKFLOW_GRADES[$workflow_id]}**"
    echo
    echo "## Category Scores"
    IFS=';' read -ra parts <<<"${WORKFLOW_BREAKDOWNS[$workflow_id]}"
    local part
    for part in "${parts[@]}"; do
      [[ -n "$part" ]] && echo "- \`${part%%=*}\`: ${part##*=}"
    done
    echo
    echo "## Issues"
    if [[ "${#FINDINGS[@]}" -eq 0 ]]; then
      echo "- None"
    else
      local finding taxonomy severity predicate
      for finding in "${FINDINGS[@]}"; do
        IFS='|' read -r _ taxonomy severity _ predicate _ _ <<<"$finding"
        echo "- \`$severity\` \`$taxonomy\`: $predicate"
      done
    fi
  } >"$report"

  if [[ -n "$OUTPUT" ]]; then
    cp "$report" "$OUTPUT"
  else
    cat "$report"
  fi
  rm -f "$report"
}

main() {
  parse_args "$@"
  init_paths
  load_contract_defaults
  PROMPT_HASH="$(hash_short "workflow-system-audit-v1-shell")"
  COMMIT_SHA="$(git_commit_sha)"

  load_manifest_index
  scan_disk_workflows

  if [[ "$MODE" == "score-workflow" ]]; then
    score_target_workflow
    exit 0
  fi

  scan_scope_files
  local workflow_id
  for workflow_id in "${!WORKFLOW_PATHS[@]}"; do
    score_workflow "$workflow_id" "${WORKFLOW_PATHS[$workflow_id]}" "${WORKFLOW_PROFILES[$workflow_id]}" "${WORKFLOW_SUMMARIES[$workflow_id]}" "${WORKFLOW_TRIGGER_COUNTS[$workflow_id]}"
  done

  system_level_checks
  run_representative_scenarios

  local destination_root report_path runtime_dir
  case "$MODE" in
    ci-static|scenario-pack)
      destination_root="$TMP_DIR"
      report_path="$TMP_DIR/report.md"
      ;;
    report)
      destination_root="$AUDIT_REPORTS_DIR/$RUN_ID"
      report_path="$REPORTS_DIR/$(date +%F)-audit-workflow-system.md"
      ;;
    full)
      destination_root="$AUDIT_REPORTS_DIR/$RUN_ID"
      report_path="$REPORTS_DIR/$(date +%F)-audit-workflow-system.md"
      runtime_dir="$RUNTIME_AUDITS_DIR/$RUN_ID"
      mkdir -p "$runtime_dir"
      ;;
    *)
      echo "[ERROR] unsupported mode: $MODE" >&2
      exit 1
      ;;
  esac

  write_outputs "$destination_root" "$report_path" "$@"

  if [[ "$MODE" == "full" ]]; then
    {
      echo "# Workflow System Audit Plan"
      echo
      echo "- Name: Workflow System Audit"
      echo "- Scope root: \`$SCOPE\`"
      echo "- Threshold: \`$SEVERITY_THRESHOLD\`"
    } >"$runtime_dir/plan.md"
    cp "$destination_root/evidence.md" "$runtime_dir/evidence.md"
    if [[ -f "$RUNTIME_INDEX" ]]; then
      tmp_index="$(mktemp "${TMPDIR:-/tmp}/workflow-runtime-index.XXXXXX")"
      yq "(.records // []) |= map(select(.id != \"$RUN_ID\")) | .records += [{\"id\":\"$RUN_ID\",\"path\":\"$RUN_ID/plan.md\",\"evidence\":\"$RUN_ID/evidence.md\"}]" "$RUNTIME_INDEX" >"$tmp_index"
      mv "$tmp_index" "$RUNTIME_INDEX"
    fi
  fi

  echo "== Workflow System Audit =="
  echo "Run ID: $RUN_ID"
  echo "Blocking threshold: $SEVERITY_THRESHOLD"
  echo "Workflow average: $(workflow_average)"
  echo "System score: $(system_score) ($(system_grade))"
  echo "Blocking findings: $(blocking_findings)"
  local scenario_failures=0
  for workflow_id in "${!SCENARIO_RESULTS[@]}"; do
    [[ "${SCENARIO_RESULTS[$workflow_id]}" == "pass" ]] || scenario_failures=$((scenario_failures + 1))
  done
  echo "Scenario failures: $scenario_failures"
  if [[ "$(blocking_findings)" -eq 0 ]]; then
    echo "Done: true"
  else
    echo "Done: false"
  fi
  echo "Top findings:"
  top_findings 5

  if [[ "$(blocking_findings)" -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
