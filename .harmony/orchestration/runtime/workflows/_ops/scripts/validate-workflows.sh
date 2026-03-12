#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_WORKFLOWS_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
WORKFLOWS_DIR="${HARMONY_WORKFLOWS_DIR:-$DEFAULT_WORKFLOWS_DIR}"
RUNTIME_DIR="$(cd -- "$WORKFLOWS_DIR/.." && pwd)"
ORCHESTRATION_DIR="$(cd -- "$RUNTIME_DIR/.." && pwd)"
HARMONY_DIR="${HARMONY_DIR_OVERRIDE:-$(cd -- "$ORCHESTRATION_DIR/.." && pwd)}"
ROOT_DIR="${HARMONY_ROOT_DIR:-$(cd -- "$HARMONY_DIR/.." && pwd)}"

MANIFEST="$WORKFLOWS_DIR/manifest.yml"
REGISTRY="$WORKFLOWS_DIR/registry.yml"
GUIDE_GENERATOR="$WORKFLOWS_DIR/_ops/scripts/generate-workflow-guides.sh"
WORKFLOW_SYSTEM_AUDIT="$SCRIPT_DIR/audit-workflow-system.sh"
FILTER_WORKFLOW_ID=""

errors=0
warnings=0
HAS_RG=0

declare -A WORKFLOW_PATHS=()
declare -A WORKFLOW_PROFILES=()

if command -v rg >/dev/null 2>&1; then
  HAS_RG=1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workflow-id)
      shift
      [[ $# -gt 0 ]] || { echo "[ERROR] --workflow-id requires a value" >&2; exit 1; }
      FILTER_WORKFLOW_ID="$1"
      ;;
    *)
      echo "[ERROR] unknown argument: $1" >&2
      exit 1
      ;;
  esac
  shift
done

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

warn() {
  echo "[WARN] $1"
  warnings=$((warnings + 1))
}

pass() {
  echo "[OK] $1"
}

require_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    fail "missing file: ${file#$ROOT_DIR/}"
  else
    pass "found file: ${file#$ROOT_DIR/}"
  fi
}

require_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    fail "missing directory: ${dir#$ROOT_DIR/}"
  else
    pass "found directory: ${dir#$ROOT_DIR/}"
  fi
}

non_empty() {
  [[ -n "${1// }" && "$1" != "null" ]]
}

matches_path_regex() {
  local pattern="$1"
  local target="$2"
  if [[ "$HAS_RG" -eq 1 ]]; then
    rg -q -- "$pattern" "$target"
  else
    grep -RqsE -- "$pattern" "$target"
  fi
}

extract_manifest_workflows() {
  awk '
    function trim(v) {
      gsub(/["\047]/, "", v)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
      return v
    }
    function emit() {
      if (id == "") return
      profile_out = profile
      if (profile_out == "") profile_out = "core"
      print id "|" path "|" profile_out
      id = ""
      path = ""
      profile = ""
    }

    /^workflows:/ {in_workflows=1; next}
    in_workflows && (/^groups:/ || /^workflow_group_definitions:/) {emit(); in_workflows=0}

    in_workflows && /^[[:space:]]*-[[:space:]]+id:[[:space:]]*/ {
      emit()
      line = $0
      sub(/^.*id:[[:space:]]*/, "", line)
      id = trim(line)
      next
    }

    in_workflows && id != "" && /^[[:space:]]*path:[[:space:]]*/ {
      line = $0
      sub(/^[[:space:]]*path:[[:space:]]*/, "", line)
      path = trim(line)
      next
    }

    in_workflows && id != "" && /^[[:space:]]*execution_profile:[[:space:]]*/ {
      line = $0
      sub(/^[[:space:]]*execution_profile:[[:space:]]*/, "", line)
      profile = trim(line)
      next
    }

    END { emit() }
  ' "$MANIFEST"
}

extract_registry_workflow_keys() {
  awk '
    /^workflows:/ {in_workflows=1; next}
    in_workflows && /^  [a-z0-9][a-z0-9-]*:[[:space:]]*$/ {
      key=$1
      sub(/:$/, "", key)
      print key
    }
  ' "$REGISTRY"
}

extract_registry_paths() {
  awk '
    function trim(v) {
      gsub(/["\047]/, "", v)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", v)
      return v
    }
    /^workflows:/ {in_workflows=1; next}
    in_workflows && /^  [a-z0-9][a-z0-9-]*:[[:space:]]*$/ {
      workflow=$1
      sub(/:$/, "", workflow)
      next
    }
    in_workflows && workflow != "" && /^[[:space:]]+path:[[:space:]]*/ {
      line=$0
      sub(/^[[:space:]]*path:[[:space:]]*/, "", line)
      print workflow "|" trim(line)
    }
  ' "$REGISTRY"
}

load_manifest_index() {
  local entry id path profile matched=0
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    IFS='|' read -r id path profile <<< "$entry"
    if [[ -n "$FILTER_WORKFLOW_ID" && "$id" != "$FILTER_WORKFLOW_ID" ]]; then
      continue
    fi
    matched=1
    WORKFLOW_PATHS["$id"]="$path"
    WORKFLOW_PROFILES["$id"]="$profile"
    case "$profile" in
      core|external-dependent) pass "workflow '$id' execution profile: $profile" ;;
      *) fail "workflow '$id' has invalid execution_profile '$profile' (expected core|external-dependent)" ;;
    esac
  done < <(extract_manifest_workflows)

  if [[ -n "$FILTER_WORKFLOW_ID" && "$matched" -eq 0 ]]; then
    fail "unknown workflow id '$FILTER_WORKFLOW_ID'"
  fi
}

check_manifest_paths_exist() {
  local id rel_path target
  for id in "${!WORKFLOW_PATHS[@]}"; do
    rel_path="${WORKFLOW_PATHS[$id]}"
    target="$WORKFLOWS_DIR/$rel_path"
    if [[ -d "$target" ]]; then
      pass "workflow '$id' path resolves: ${target#$ROOT_DIR/}"
    else
      fail "workflow '$id' path missing: ${target#$ROOT_DIR/}"
    fi
  done
}

check_registry_entries() {
  local key
  local registry_keys
  registry_keys="$(extract_registry_workflow_keys)"
  for key in "${!WORKFLOW_PATHS[@]}"; do
    if printf '%s\n' "$registry_keys" | grep -Fxq "$key"; then
      pass "workflow '$key' registry entry exists"
    else
      fail "workflow '$key' missing registry entry"
    fi
  done
}

check_workflow_contract() {
  local id="$1"
  local rel_path="$2"
  local manifest_profile="$3"

  local workflow_dir="$WORKFLOWS_DIR/${rel_path%/}"
  local workflow_file="$workflow_dir/workflow.yml"
  local guide_readme="$workflow_dir/README.md"
  local registry_version registry_profile
  local name description version entry_mode execution_profile side_effect_class cancel_safe
  local coordination_kind coordination_source_fields coordination_format
  local executor_interface_version has_recurrence_fields stage_count done_gate_count

  require_file "$workflow_file"
  require_dir "$workflow_dir/stages"
  require_file "$guide_readme"

  if [[ "$(yq -r '.schema_version // ""' "$workflow_file")" == "workflow-contract-v1" ]]; then
    pass "workflow '$id' schema version is workflow-contract-v1"
  else
    fail "workflow '$id' has invalid or missing schema_version"
  fi

  name="$(yq -r '.name // ""' "$workflow_file")"
  description="$(yq -r '.description // ""' "$workflow_file")"
  version="$(yq -r '.version // ""' "$workflow_file")"
  entry_mode="$(yq -r '.entry_mode // ""' "$workflow_file")"
  execution_profile="$(yq -r '.execution_profile // ""' "$workflow_file")"
  side_effect_class="$(yq -r '.side_effect_class // ""' "$workflow_file")"
  cancel_safe="$(yq -r '.execution_controls.cancel_safe' "$workflow_file")"
  coordination_kind="$(yq -r '.coordination_key_strategy.kind // ""' "$workflow_file")"
  coordination_source_fields="$(yq -r '.coordination_key_strategy.source_fields | length // 0' "$workflow_file")"
  coordination_format="$(yq -r '.coordination_key_strategy.format // ""' "$workflow_file")"
  executor_interface_version="$(yq -r '.executor_interface_version // ""' "$workflow_file")"
  has_recurrence_fields="$(yq -r 'has("trigger") or has("schedule") or has("cadence") or has("timezone") or has("missed_run_policy")' "$workflow_file")"
  stage_count="$(yq -r '.stages | length' "$workflow_file")"
  done_gate_count="$(yq -r '.done_gate.checks | length' "$workflow_file")"
  registry_version="$(yq -r ".workflows.\"$id\".version // \"\"" "$REGISTRY")"
  registry_profile="$(yq -r ".workflows.\"$id\".execution_profile // \"\"" "$REGISTRY")"

  [[ "$name" == "$id" ]] && pass "workflow '$id' contract name matches id" || fail "workflow '$id' contract name mismatch"
  non_empty "$description" && pass "workflow '$id' description present" || fail "workflow '$id' missing description"
  non_empty "$version" && pass "workflow '$id' version present" || fail "workflow '$id' missing version"

  case "$entry_mode" in
    human|agent|hybrid) pass "workflow '$id' entry_mode valid: $entry_mode" ;;
    *) fail "workflow '$id' has invalid entry_mode '$entry_mode'" ;;
  esac

  case "$execution_profile" in
    core|external-dependent) pass "workflow '$id' execution_profile valid: $execution_profile" ;;
    *) fail "workflow '$id' has invalid execution_profile '$execution_profile'" ;;
  esac

  case "$side_effect_class" in
    none|read_only|mutating|destructive) pass "workflow '$id' side_effect_class valid: $side_effect_class" ;;
    *) fail "workflow '$id' has invalid side_effect_class '$side_effect_class'" ;;
  esac

  case "$cancel_safe" in
    true|false) pass "workflow '$id' execution_controls.cancel_safe declared" ;;
    *) fail "workflow '$id' must declare execution_controls.cancel_safe as boolean" ;;
  esac

  case "$coordination_kind" in
    none|workflow-target|mission-target|incident-target|explicit-input)
      pass "workflow '$id' coordination_key_strategy kind valid: $coordination_kind"
      ;;
    *)
      fail "workflow '$id' has invalid coordination_key_strategy.kind '$coordination_kind'"
      ;;
  esac

  if [[ "$coordination_kind" == "none" ]]; then
    case "$side_effect_class" in
      none|read_only) pass "workflow '$id' coordination none allowed for side_effect_class '$side_effect_class'" ;;
      *) fail "workflow '$id' side-effectful workflows may not use coordination_key_strategy.kind=none" ;;
    esac
  else
    [[ "$coordination_source_fields" -gt 0 ]] && pass "workflow '$id' coordination source_fields declared" || fail "workflow '$id' missing coordination_key_strategy.source_fields"
    non_empty "$coordination_format" && pass "workflow '$id' coordination format declared" || fail "workflow '$id' missing coordination_key_strategy.format"
  fi

  if [[ "$executor_interface_version" == "workflow-executor-v1" ]]; then
    pass "workflow '$id' executor interface version valid"
  else
    fail "workflow '$id' must declare executor_interface_version workflow-executor-v1"
  fi

  if [[ "$manifest_profile" == "$execution_profile" ]]; then
    pass "workflow '$id' manifest and contract execution_profile match"
  else
    fail "workflow '$id' manifest execution_profile '$manifest_profile' does not match contract '$execution_profile'"
  fi

  if [[ -n "$registry_profile" && "$registry_profile" != "$execution_profile" ]]; then
    fail "workflow '$id' registry execution_profile '$registry_profile' does not match contract '$execution_profile'"
  else
    pass "workflow '$id' registry execution_profile aligned"
  fi

  if [[ "$registry_version" == "$version" ]]; then
    pass "workflow '$id' registry version matches contract"
  else
    fail "workflow '$id' registry version '$registry_version' does not match contract '$version'"
  fi

  [[ "$stage_count" -gt 0 ]] && pass "workflow '$id' declares stages" || fail "workflow '$id' has no stages"
  [[ "$done_gate_count" -gt 0 ]] && pass "workflow '$id' declares done-gate checks" || fail "workflow '$id' missing done-gate checks"

  if [[ "$has_recurrence_fields" == "false" ]]; then
    pass "workflow '$id' does not carry recurrence semantics"
  else
    fail "workflow '$id' must not define recurrence or scheduler semantics"
  fi

  if yq -e '.projection' "$workflow_file" >/dev/null 2>&1; then
    fail "workflow '$id' retains deprecated projection block"
  else
    pass "workflow '$id' has no deprecated projection block"
  fi

  if [[ -f "$workflow_dir/WORKFLOW.md" ]]; then
    fail "workflow '$id' retains deprecated root WORKFLOW.md"
  else
    pass "workflow '$id' avoids deprecated root WORKFLOW.md"
  fi

  if [[ -d "$workflow_dir/guide" ]]; then
    fail "workflow '$id' retains deprecated guide directory"
  else
    pass "workflow '$id' avoids deprecated guide directory"
  fi

  if matches_path_regex '\.design-packages/' "$workflow_dir"; then
    if [[ "$id" == "audit-design-package" || "$id" == "create-design-package" ]]; then
      pass "workflow '$id' design-package references allowed by explicit exception"
    else
      fail "workflow '$id' depends on temporary .design-packages paths"
    fi
  else
    pass "workflow '$id' avoids temporary .design-packages paths"
  fi

  check_workflow_stages "$id" "$workflow_file" "$workflow_dir"
  check_registry_commands "$id"
}

check_workflow_stages() {
  local id="$1"
  local workflow_file="$2"
  local workflow_dir="$3"
  local stage_rows row stage_json stage_id asset kind asset_path mutation_scope_len
  local known_stage_ids=()

  mapfile -t stage_rows < <(yq -r '.stages[] | to_json | @base64' "$workflow_file")
  for row in "${stage_rows[@]}"; do
    stage_json="$(printf '%s' "$row" | base64 --decode)"
    known_stage_ids+=("$(printf '%s' "$stage_json" | yq -p=json -r '.id')")
  done

  for row in "${stage_rows[@]}"; do
    stage_json="$(printf '%s' "$row" | base64 --decode)"
    stage_id="$(printf '%s' "$stage_json" | yq -p=json -r '.id')"
    asset="$(printf '%s' "$stage_json" | yq -p=json -r '.asset')"
    kind="$(printf '%s' "$stage_json" | yq -p=json -r '.kind')"
    mutation_scope_len="$(printf '%s' "$stage_json" | yq -p=json -r '.mutation_scope | length')"
    asset_path="$workflow_dir/$asset"

    [[ "$asset" == stages/* ]] && pass "workflow '$id' stage '$stage_id' asset lives under stages/" || fail "workflow '$id' stage '$stage_id' asset must live under stages/"
    require_file "$asset_path"
    case "$kind" in
      analysis|mutation|projection|verification) pass "workflow '$id' stage '$stage_id' kind valid: $kind" ;;
      *) fail "workflow '$id' stage '$stage_id' has invalid kind '$kind'" ;;
    esac

    if [[ "$kind" == "mutation" ]]; then
      [[ "$mutation_scope_len" -gt 0 ]] && pass "workflow '$id' stage '$stage_id' mutation scope declared" || fail "workflow '$id' stage '$stage_id' missing mutation scope"
    else
      [[ "$mutation_scope_len" -eq 0 ]] && pass "workflow '$id' stage '$stage_id' mutation scope absent as expected" || fail "workflow '$id' non-mutation stage '$stage_id' declares mutation scope"
    fi

    check_stage_references "$id" "$stage_id" "$stage_json" "${known_stage_ids[@]}"
  done
}

check_stage_references() {
  local workflow_id="$1"
  local stage_id="$2"
  local stage_json="$3"
  shift 3
  local known_stage_ids=("$@")
  local token ref_id found

  while IFS= read -r token; do
    [[ -z "$token" || "$token" == "null" ]] && continue
    ref_id="${token#stage:}"
    found=0
    for known in "${known_stage_ids[@]}"; do
      if [[ "$known" == "$ref_id" ]]; then
        found=1
        break
      fi
    done
    if [[ "$found" -eq 1 ]]; then
      pass "workflow '$workflow_id' stage '$stage_id' reference resolves: $token"
    else
      fail "workflow '$workflow_id' stage '$stage_id' reference does not resolve: $token"
    fi
  done < <(printf '%s' "$stage_json" | yq -p=json -r '.consumes[]?, .produces[]?')
}

check_registry_commands() {
  local id="$1"
  local primary_command
  primary_command="$(yq -r ".workflows.\"$id\".commands[0] // \"\"" "$REGISTRY")"
  if [[ "$primary_command" == "/$id" ]]; then
    pass "workflow '$id' primary command matches id"
  else
    fail "workflow '$id' primary command must be '/$id'"
  fi
}

workflow_has_external_dependency_markers() {
  local path="$1"
  local target="$WORKFLOWS_DIR/$path"
  local dep_pattern
  dep_pattern='(pnpm[[:space:]]+flowkit:run|pnpm[[:space:]]+install|npm[[:space:]]+install|npx[[:space:]]|pip[[:space:]]+install|uv[[:space:]]+sync|swift[[:space:]]+build|swift[[:space:]]+test|docker(-compose)?|alembic)'
  matches_path_regex "$dep_pattern" "$target"
}

check_dependency_profiles_against_steps() {
  local id profile path
  for id in "${!WORKFLOW_PATHS[@]}"; do
    profile="${WORKFLOW_PROFILES[$id]}"
    path="${WORKFLOW_PATHS[$id]}"
    if workflow_has_external_dependency_markers "$path"; then
      if [[ "$profile" != "external-dependent" ]]; then
        fail "workflow '$id' has external dependency markers but execution_profile='$profile'"
      else
        pass "workflow '$id' external dependency markers correctly isolated"
      fi
    fi
  done
}

check_dependency_profiles_against_registry_io() {
  local row id path profile
  while IFS= read -r row; do
    [[ -z "$row" ]] && continue
    IFS='|' read -r id path <<< "$row"
    if [[ -n "$FILTER_WORKFLOW_ID" && "$id" != "$FILTER_WORKFLOW_ID" ]]; then
      continue
    fi
    profile="${WORKFLOW_PROFILES[$id]:-core}"

    if [[ "$path" =~ ^(src/|tests/|Package\.swift$|Sources/|Tests/|AGENT\.md$|CLAUDE\.md$) ]]; then
      if [[ "$profile" != "external-dependent" ]]; then
        fail "workflow '$id' has external I/O path '$path' but execution_profile='$profile'"
      else
        pass "workflow '$id' external I/O path allowed by external-dependent profile"
      fi
    fi
  done < <(extract_registry_paths)
}

check_guide_drift() {
  require_file "$GUIDE_GENERATOR"
  local tmp_root
  tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/harmony-workflow-guides.XXXXXX")"

  local generator_cmd=(bash "$GUIDE_GENERATOR" --output-root "$tmp_root")
  if [[ -n "$FILTER_WORKFLOW_ID" ]]; then
    generator_cmd+=(--workflow-id "$FILTER_WORKFLOW_ID")
  fi

  if ! "${generator_cmd[@]}" >/dev/null; then
    fail "workflow README generator failed"
    rm -rf "$tmp_root"
    return
  fi

  local id rel_path actual generated
  for id in "${!WORKFLOW_PATHS[@]}"; do
    rel_path="${WORKFLOW_PATHS[$id]}"
    actual="$WORKFLOWS_DIR/$rel_path/README.md"
    generated="$tmp_root/.harmony/orchestration/runtime/workflows/$rel_path/README.md"
    if [[ ! -f "$generated" ]]; then
      fail "workflow '$id' missing generated README in temp output"
      continue
    fi
    if diff -q "$actual" "$generated" >/dev/null 2>&1; then
      pass "workflow '$id' README matches canonical workflow"
    else
      fail "workflow '$id' README drift detected against canonical workflow"
    fi
  done

  rm -rf "$tmp_root"
}

check_legacy_paths_removed() {
  local legacy="$RUNTIME_DIR/pipelines"
  if [[ -e "$legacy" ]]; then
    fail "deprecated runtime/pipelines surface still exists"
  else
    pass "deprecated runtime/pipelines surface removed"
  fi
}

check_runtime_pipeline_references_absent() {
  local targets=(
    "$HARMONY_DIR/AGENTS.md"
    "$HARMONY_DIR/START.md"
    "$HARMONY_DIR/orchestration/runtime/workflows/manifest.yml"
    "$HARMONY_DIR/orchestration/runtime/workflows/registry.yml"
    "$HARMONY_DIR/orchestration/runtime/workflows/README.md"
    "$HARMONY_DIR/engine/runtime/crates/kernel/src/main.rs"
    "$HARMONY_DIR/engine/runtime/crates/kernel/src/pipeline.rs"
    "$HARMONY_DIR/engine/runtime/crates/kernel/src/workflow.rs"
    "$HARMONY_DIR/engine/runtime/run"
    "$HARMONY_DIR/engine/runtime/run.cmd"
    "$HARMONY_DIR/assurance/runtime/_ops/scripts/alignment-check.sh"
    "$HARMONY_DIR/assurance/runtime/_ops/scripts/validate-audit-design-package-workflow.sh"
    "$HARMONY_DIR/assurance/runtime/_ops/scripts/validate-create-design-package-workflow.sh"
    "$HARMONY_DIR/capabilities/runtime/commands"
  )
  if rg -n "runtime/pipelines|pipeline\\.yml|projection\\.pipeline_" "${targets[@]}" \
    --glob '!**/target/**' --glob '!**/output/**' >/dev/null 2>&1; then
    fail "repo still contains deprecated pipeline-surface references"
  else
    pass "deprecated pipeline-surface references removed"
  fi
}

check_workflow_system_audit_static() {
  if [[ -n "$FILTER_WORKFLOW_ID" ]]; then
    pass "workflow-system audit skipped for filtered validation"
    return
  fi

  if [[ ! -f "$WORKFLOW_SYSTEM_AUDIT" ]]; then
    warn "workflow-system audit engine missing: ${WORKFLOW_SYSTEM_AUDIT#$ROOT_DIR/}"
    return
  fi

  if bash "$WORKFLOW_SYSTEM_AUDIT" --mode ci-static --scope ".harmony/orchestration/runtime/workflows/"; then
    pass "workflow-system audit static gate passed"
  else
    fail "workflow-system audit static gate failed"
  fi
}

main() {
  echo "== Workflow Validation =="

  require_file "$MANIFEST"
  require_file "$REGISTRY"

  load_manifest_index
  check_manifest_paths_exist
  check_registry_entries

  local id
  for id in "${!WORKFLOW_PATHS[@]}"; do
    check_workflow_contract "$id" "${WORKFLOW_PATHS[$id]}" "${WORKFLOW_PROFILES[$id]}"
  done

  check_dependency_profiles_against_steps
  check_dependency_profiles_against_registry_io
  check_guide_drift
  check_legacy_paths_removed
  check_runtime_pipeline_references_absent
  check_workflow_system_audit_static

  echo
  echo "Validation summary: errors=$errors warnings=$warnings"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
