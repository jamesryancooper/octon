#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOWS_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
ORCHESTRATION_DIR="$(cd -- "$WORKFLOWS_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$ORCHESTRATION_DIR/../.." && pwd)"

MANIFEST="$WORKFLOWS_DIR/manifest.yml"
REGISTRY="$WORKFLOWS_DIR/registry.yml"

errors=0
warnings=0

declare -A WORKFLOW_PATHS=()
declare -A WORKFLOW_PROFILES=()

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
    fail "missing file: $file"
  else
    pass "found file: ${file#$ROOT_DIR/}"
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
  local entry id path profile
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    IFS='|' read -r id path profile <<< "$entry"

    if [[ -z "$id" ]]; then
      fail "workflow manifest entry missing id"
      continue
    fi
    if [[ -z "$path" ]]; then
      fail "workflow '$id' missing path in manifest"
      continue
    fi

    WORKFLOW_PATHS["$id"]="$path"
    WORKFLOW_PROFILES["$id"]="$profile"

    case "$profile" in
      core|external-dependent)
        pass "workflow '$id' execution profile: $profile"
        ;;
      *)
        fail "workflow '$id' has invalid execution_profile '$profile' (expected core|external-dependent)"
        ;;
    esac
  done < <(extract_manifest_workflows)
}

check_manifest_paths_exist() {
  local id rel_path target
  for id in "${!WORKFLOW_PATHS[@]}"; do
    rel_path="${WORKFLOW_PATHS[$id]}"
    target="$WORKFLOWS_DIR/$rel_path"
    if [[ -e "$target" ]]; then
      pass "workflow '$id' path resolves: ${target#$ROOT_DIR/}"
    else
      fail "workflow '$id' path missing: ${target#$ROOT_DIR/}"
    fi
  done
}

workflow_has_external_dependency_markers() {
  local path="$1"
  local target="$WORKFLOWS_DIR/$path"

  local dep_pattern
  dep_pattern='(pnpm[[:space:]]+flowkit:run|pnpm[[:space:]]+install|npm[[:space:]]+install|npx[[:space:]]|pip[[:space:]]+install|uv[[:space:]]+sync|swift[[:space:]]+build|swift[[:space:]]+test|docker(-compose)?|alembic)'

  if [[ -d "$target" ]]; then
    rg -n "$dep_pattern" "$target" -g "*.md" >/dev/null 2>&1
    return $?
  fi

  rg -n "$dep_pattern" "$target" >/dev/null 2>&1
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
    profile="${WORKFLOW_PROFILES[$id]:-core}"

    # Paths that target non-harness project roots indicate external-dependent workflows.
    if [[ "$path" =~ ^(src/|tests/|Package\.swift$|Sources/|Tests/|AGENT\.md$|CLAUDE\.md$) ]]; then
      if [[ "$profile" != "external-dependent" ]]; then
        fail "workflow '$id' has external I/O path '$path' but execution_profile='$profile'"
      else
        pass "workflow '$id' external I/O path allowed by external-dependent profile"
      fi
    fi
  done < <(extract_registry_paths)
}

check_deprecated_paths() {
  local deprecated
  deprecated=(
    "$ROOT_DIR/.harmony/orchestration/workflows"
    "$ROOT_DIR/.harmony/orchestration/runtime/workflows/quality-gate"
  )

  local path rel
  for path in "${deprecated[@]}"; do
    rel="${path#$ROOT_DIR/}"
    if [[ -e "$path" ]]; then
      fail "deprecated workflows path exists: $rel"
    else
      pass "deprecated workflows path removed: $rel"
    fi
  done
}

main() {
  echo "== Workflow Validation =="

  require_file "$MANIFEST"
  require_file "$REGISTRY"

  load_manifest_index
  check_manifest_paths_exist
  check_dependency_profiles_against_steps
  check_dependency_profiles_against_registry_io
  check_deprecated_paths

  echo
  echo "Validation summary: errors=$errors warnings=$warnings"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
