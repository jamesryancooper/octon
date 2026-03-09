#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_PIPELINES_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
DEFAULT_RUNTIME_DIR="$(cd -- "$DEFAULT_PIPELINES_DIR/.." && pwd)"
DEFAULT_ORCHESTRATION_DIR="$(cd -- "$DEFAULT_RUNTIME_DIR/.." && pwd)"
DEFAULT_HARMONY_DIR="$(cd -- "$DEFAULT_ORCHESTRATION_DIR/.." && pwd)"
DEFAULT_ROOT_DIR="$(cd -- "$DEFAULT_HARMONY_DIR/.." && pwd)"

PIPELINES_DIR="${HARMONY_PIPELINES_DIR:-$DEFAULT_PIPELINES_DIR}"
RUNTIME_DIR="$(cd -- "$PIPELINES_DIR/.." && pwd)"
HARMONY_DIR="${HARMONY_DIR_OVERRIDE:-$(cd -- "$RUNTIME_DIR/../.." && pwd)}"
ROOT_DIR="${HARMONY_ROOT_DIR:-$(cd -- "$HARMONY_DIR/.." && pwd)}"
WORKFLOWS_DIR="${HARMONY_WORKFLOWS_DIR:-$RUNTIME_DIR/workflows}"

MANIFEST="$PIPELINES_DIR/manifest.yml"
REGISTRY="$PIPELINES_DIR/registry.yml"
FILTER_PIPELINE_ID=""

errors=0
HAS_RG=0

if command -v rg >/dev/null 2>&1; then
  HAS_RG=1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pipeline-id)
      shift
      [[ $# -gt 0 ]] || { echo "[ERROR] --pipeline-id requires a value" >&2; exit 1; }
      FILTER_PIPELINE_ID="$1"
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

check_pipeline_contract() {
  local id="$1"
  local rel_path="$2"
  local manifest_profile="$3"

  local pipeline_dir="$PIPELINES_DIR/${rel_path%/}"
  local pipeline_file="$pipeline_dir/pipeline.yml"
  local registry_version
  local name description version entry_mode execution_profile stage_count done_gate_count
  local projection_id projection_path projection_generated projection_format constraints_fail_closed

  require_file "$pipeline_file"
  require_dir "$pipeline_dir/stages"

  [[ -f "$pipeline_file" ]] || return

  registry_version="$(yq -r ".pipelines.\"$id\".version // \"\"" "$REGISTRY")"
  if non_empty "$registry_version"; then
    pass "pipeline '$id' registry entry exists"
  else
    fail "pipeline '$id' missing registry entry"
  fi

  if [[ "$(yq -r '.schema_version // ""' "$pipeline_file")" == "pipeline-contract-v1" ]]; then
    pass "pipeline '$id' schema version is pipeline-contract-v1"
  else
    fail "pipeline '$id' has invalid or missing schema_version"
  fi

  name="$(yq -r '.name // ""' "$pipeline_file")"
  description="$(yq -r '.description // ""' "$pipeline_file")"
  version="$(yq -r '.version // ""' "$pipeline_file")"
  entry_mode="$(yq -r '.entry_mode // ""' "$pipeline_file")"
  execution_profile="$(yq -r '.execution_profile // ""' "$pipeline_file")"
  projection_id="$(yq -r '.projection.workflow_id // ""' "$pipeline_file")"
  projection_path="$(yq -r '.projection.workflow_path // ""' "$pipeline_file")"
  projection_generated="$(yq -r '.projection.generated // ""' "$pipeline_file")"
  projection_format="$(yq -r '.projection.projection_format // ""' "$pipeline_file")"
  constraints_fail_closed="$(yq -r '.constraints.fail_closed // ""' "$pipeline_file")"
  stage_count="$(yq -r '.stages | length' "$pipeline_file")"
  done_gate_count="$(yq -r '.done_gate.checks | length' "$pipeline_file")"

  [[ "$name" == "$id" ]] && pass "pipeline '$id' contract name matches id" || fail "pipeline '$id' contract name mismatch"
  non_empty "$description" && pass "pipeline '$id' description present" || fail "pipeline '$id' missing description"
  non_empty "$version" && pass "pipeline '$id' version present" || fail "pipeline '$id' missing version"

  case "$entry_mode" in
    human|agent|hybrid) pass "pipeline '$id' entry_mode valid: $entry_mode" ;;
    *) fail "pipeline '$id' has invalid entry_mode '$entry_mode'" ;;
  esac

  case "$execution_profile" in
    core|external-dependent) pass "pipeline '$id' execution_profile valid: $execution_profile" ;;
    *) fail "pipeline '$id' has invalid execution_profile '$execution_profile'" ;;
  esac

  if [[ "$manifest_profile" == "$execution_profile" ]]; then
    pass "pipeline '$id' manifest and contract execution_profile match"
  else
    fail "pipeline '$id' manifest execution_profile '$manifest_profile' does not match contract '$execution_profile'"
  fi

  if [[ "$registry_version" == "$version" ]]; then
    pass "pipeline '$id' registry version matches contract"
  else
    fail "pipeline '$id' registry version '$registry_version' does not match contract '$version'"
  fi

  if [[ "$stage_count" -gt 0 ]]; then
    pass "pipeline '$id' declares stages"
  else
    fail "pipeline '$id' has no stages"
  fi

  if [[ "$done_gate_count" -gt 0 ]]; then
    pass "pipeline '$id' declares done-gate checks"
  else
    fail "pipeline '$id' missing done-gate checks"
  fi

  [[ "$projection_id" == "$id" ]] && pass "pipeline '$id' projection.workflow_id matches id" || fail "pipeline '$id' projection.workflow_id mismatch"

  if non_empty "$projection_path" && [[ -e "$ROOT_DIR/$projection_path" ]]; then
    pass "pipeline '$id' projection path resolves"
  else
    fail "pipeline '$id' projection path missing or invalid"
  fi

  [[ "$projection_generated" == "true" ]] && pass "pipeline '$id' projection marked generated" || fail "pipeline '$id' projection.generated must be true"

  case "$projection_format" in
    directory|single-file) pass "pipeline '$id' projection format valid: $projection_format" ;;
    *) fail "pipeline '$id' has invalid projection format '$projection_format'" ;;
  esac

  [[ "$constraints_fail_closed" == "true" ]] && pass "pipeline '$id' fail_closed enabled" || fail "pipeline '$id' must enable constraints.fail_closed"

  if matches_path_regex '\.design-packages/' "$pipeline_dir"; then
    fail "pipeline '$id' depends on temporary .design-packages paths"
  else
    pass "pipeline '$id' avoids temporary .design-packages paths"
  fi

  check_pipeline_stages "$id" "$pipeline_file" "$pipeline_dir"
  check_pipeline_artifacts "$id" "$pipeline_file"
  check_projection_registry_parity "$id" "$pipeline_file"
}

check_pipeline_stages() {
  local id="$1"
  local pipeline_file="$2"
  local pipeline_dir="$3"

  mapfile -t stage_rows < <(yq -r '.stages[] | to_json | @base64' "$pipeline_file")
  local known_stage_ids=()
  local row stage_json stage_id asset kind asset_path mutation_scope_len

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
    asset_path="$pipeline_dir/$asset"

    [[ "$asset" == stages/* ]] && pass "pipeline '$id' stage '$stage_id' asset lives under stages/" || fail "pipeline '$id' stage '$stage_id' asset must live under stages/"
    require_file "$asset_path"

    case "$kind" in
      analysis|mutation|projection|verification)
        pass "pipeline '$id' stage '$stage_id' kind valid: $kind"
        ;;
      *)
        fail "pipeline '$id' stage '$stage_id' has invalid kind '$kind'"
        ;;
    esac

    if [[ "$kind" == "mutation" ]]; then
      [[ "$mutation_scope_len" -gt 0 ]] && pass "pipeline '$id' stage '$stage_id' mutation scope declared" || fail "pipeline '$id' stage '$stage_id' missing mutation scope"
    else
      [[ "$mutation_scope_len" -eq 0 ]] && pass "pipeline '$id' stage '$stage_id' mutation scope absent as expected" || fail "pipeline '$id' non-mutation stage '$stage_id' declares mutation scope"
    fi

    check_stage_references "$id" "$stage_id" "$stage_json" "${known_stage_ids[@]}"
  done
}

check_stage_references() {
  local pipeline_id="$1"
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
      pass "pipeline '$pipeline_id' stage '$stage_id' reference resolves: $token"
    else
      fail "pipeline '$pipeline_id' stage '$stage_id' reference does not resolve: $token"
    fi
  done < <(printf '%s' "$stage_json" | yq -p=json -r '.consumes[]?, .produces[]?')
}

check_pipeline_artifacts() {
  local id="$1"
  local pipeline_file="$2"
  local artifact_count row artifact_json name path kind format description

  artifact_count="$(yq -r '.artifacts | length' "$pipeline_file")"
  [[ "$artifact_count" -ge 0 ]] && pass "pipeline '$id' artifacts field present"

  mapfile -t artifact_rows < <(yq -r '.artifacts[]? | to_json | @base64' "$pipeline_file")
  for row in "${artifact_rows[@]}"; do
    artifact_json="$(printf '%s' "$row" | base64 --decode)"
    name="$(printf '%s' "$artifact_json" | yq -p=json -r '.name // ""')"
    path="$(printf '%s' "$artifact_json" | yq -p=json -r '.path // ""')"
    kind="$(printf '%s' "$artifact_json" | yq -p=json -r '.kind // ""')"
    format="$(printf '%s' "$artifact_json" | yq -p=json -r '.format // ""')"
    description="$(printf '%s' "$artifact_json" | yq -p=json -r '.description // ""')"

    non_empty "$name" && pass "pipeline '$id' artifact '$name' has name" || fail "pipeline '$id' artifact missing name"
    non_empty "$path" && pass "pipeline '$id' artifact '${name:-unnamed}' has path" || fail "pipeline '$id' artifact '${name:-unnamed}' missing path"
    case "$kind" in
      file|directory) pass "pipeline '$id' artifact '${name:-unnamed}' kind valid: $kind" ;;
      *) fail "pipeline '$id' artifact '${name:-unnamed}' has invalid kind '$kind'" ;;
    esac
    non_empty "$format" && pass "pipeline '$id' artifact '${name:-unnamed}' has format" || fail "pipeline '$id' artifact '${name:-unnamed}' missing format"
    non_empty "$description" && pass "pipeline '$id' artifact '${name:-unnamed}' has description" || fail "pipeline '$id' artifact '${name:-unnamed}' missing description"
  done
}

check_projection_registry_parity() {
  local id="$1"
  local pipeline_file="$2"
  local reg_path reg_generated reg_format reg_profile reg_entry_mode
  local contract_path contract_generated contract_format contract_profile contract_entry_mode

  reg_path="$(yq -r ".pipelines.\"$id\".projection.workflow_path // \"\"" "$REGISTRY")"
  reg_generated="$(yq -r ".pipelines.\"$id\".projection.generated // \"\"" "$REGISTRY")"
  reg_format="$(yq -r ".pipelines.\"$id\".projection.projection_format // \"\"" "$REGISTRY")"
  reg_profile="$(yq -r ".pipelines.\"$id\".execution_profile // \"\"" "$REGISTRY")"
  reg_entry_mode="$(yq -r ".pipelines.\"$id\".entry_mode // \"\"" "$REGISTRY")"

  contract_path="$(yq -r '.projection.workflow_path // ""' "$pipeline_file")"
  contract_generated="$(yq -r '.projection.generated // ""' "$pipeline_file")"
  contract_format="$(yq -r '.projection.projection_format // ""' "$pipeline_file")"
  contract_profile="$(yq -r '.execution_profile // ""' "$pipeline_file")"
  contract_entry_mode="$(yq -r '.entry_mode // ""' "$pipeline_file")"

  [[ "$reg_path" == "$contract_path" ]] && pass "pipeline '$id' registry/workflow projection path aligned" || fail "pipeline '$id' registry projection path drift"
  [[ "$reg_generated" == "$contract_generated" ]] && pass "pipeline '$id' registry/generated flag aligned" || fail "pipeline '$id' registry projection.generated drift"
  [[ "$reg_format" == "$contract_format" ]] && pass "pipeline '$id' registry projection format aligned" || fail "pipeline '$id' registry projection format drift"
  [[ "$reg_profile" == "$contract_profile" ]] && pass "pipeline '$id' registry execution_profile aligned" || fail "pipeline '$id' registry execution_profile drift"
  [[ "$reg_entry_mode" == "$contract_entry_mode" ]] && pass "pipeline '$id' registry entry_mode aligned" || fail "pipeline '$id' registry entry_mode drift"
}

main() {
  echo "== Pipeline Validation =="

  require_file "$MANIFEST"
  require_file "$REGISTRY"

  local matched=0

  while IFS= read -r row; do
    [[ -z "$row" ]] && continue
    row_json="$(printf '%s' "$row" | base64 --decode)"
    id="$(printf '%s' "$row_json" | yq -p=json -r '.id')"
    if [[ -n "$FILTER_PIPELINE_ID" && "$id" != "$FILTER_PIPELINE_ID" ]]; then
      continue
    fi
    matched=1
    rel_path="$(printf '%s' "$row_json" | yq -p=json -r '.path')"
    manifest_profile="$(printf '%s' "$row_json" | yq -p=json -r '.execution_profile // "core"')"
    check_pipeline_contract "$id" "$rel_path" "$manifest_profile"
  done < <(yq -r '.pipelines[] | to_json | @base64' "$MANIFEST")

  if [[ -n "$FILTER_PIPELINE_ID" && "$matched" -eq 0 ]]; then
    fail "unknown pipeline id '$FILTER_PIPELINE_ID'"
  fi

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
