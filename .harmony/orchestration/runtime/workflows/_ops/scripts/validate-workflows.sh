#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOWS_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
ORCHESTRATION_DIR="$(cd -- "$WORKFLOWS_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$ORCHESTRATION_DIR/../.." && pwd)"

MANIFEST="$WORKFLOWS_DIR/manifest.yml"
REGISTRY="$WORKFLOWS_DIR/registry.yml"
WORKFLOW_SYSTEM_AUDIT="$SCRIPT_DIR/audit-workflow-system.sh"

errors=0
warnings=0

declare -A WORKFLOW_PATHS=()
declare -A WORKFLOW_PROFILES=()
HAS_RG=0

if command -v rg >/dev/null 2>&1; then
  HAS_RG=1
fi

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

matches_file_regex() {
  local pattern="$1"
  local file="$2"
  if [[ "$HAS_RG" -eq 1 ]]; then
    rg -q -- "$pattern" "$file"
  else
    grep -Eq -- "$pattern" "$file"
  fi
}

matches_file_fixed() {
  local token="$1"
  local file="$2"
  if [[ "$HAS_RG" -eq 1 ]]; then
    rg -Fq -- "$token" "$file"
  else
    grep -Fq -- "$token" "$file"
  fi
}

matches_markdown_tree_regex() {
  local pattern="$1"
  local target="$2"
  if [[ "$HAS_RG" -eq 1 ]]; then
    if [[ -d "$target" ]]; then
      rg -q --glob "*.md" -- "$pattern" "$target"
    else
      rg -q -- "$pattern" "$target"
    fi
  else
    if [[ -d "$target" ]]; then
      grep -RqsE --include='*.md' -- "$pattern" "$target"
    else
      grep -Eq -- "$pattern" "$target"
    fi
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

  matches_markdown_tree_regex "$dep_pattern" "$target"
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
    "$ROOT_DIR/.harmony/orchestration/runtime/workflows/audit/documentation-quality-gate"
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

extract_registry_workflow_block() {
  local workflow_id="$1"
  awk -v key="$workflow_id" '
    $0 ~ "^  " key ":" {in_block=1; print; next}
    in_block && $0 ~ "^  [A-Za-z0-9._-]+:" && $0 !~ "^    " {exit}
    in_block {print}
  ' "$REGISTRY"
}

check_bounded_audit_parameter_forwarding() {
  local files
  files=(
    "$WORKFLOWS_DIR/audit/audit-pre-release-workflow/02-migration-audit.md"
    "$WORKFLOWS_DIR/audit/audit-pre-release-workflow/03-health-audit.md"
    "$WORKFLOWS_DIR/audit/audit-pre-release-workflow/04-cross-subsystem-audit.md"
    "$WORKFLOWS_DIR/audit/audit-pre-release-workflow/05-freshness-audit.md"
    "$WORKFLOWS_DIR/audit/audit-change-risk-workflow/02-subsystem-health-audit.md"
    "$WORKFLOWS_DIR/audit/audit-change-risk-workflow/03-migration-impact-audit.md"
    "$WORKFLOWS_DIR/audit/audit-change-risk-workflow/04-api-contract-audit.md"
    "$WORKFLOWS_DIR/audit/audit-change-risk-workflow/05-test-quality-audit.md"
    "$WORKFLOWS_DIR/audit/audit-change-risk-workflow/06-operational-readiness-audit.md"
    "$WORKFLOWS_DIR/audit/audit-change-risk-workflow/07-cross-subsystem-audit.md"
    "$WORKFLOWS_DIR/audit/audit-change-risk-workflow/08-freshness-audit.md"
    "$WORKFLOWS_DIR/audit/audit-continuous-workflow/02-subsystem-health-audit.md"
    "$WORKFLOWS_DIR/audit/audit-continuous-workflow/03-observability-audit.md"
    "$WORKFLOWS_DIR/audit/audit-continuous-workflow/04-operational-readiness-audit.md"
    "$WORKFLOWS_DIR/audit/audit-continuous-workflow/05-api-contract-audit.md"
    "$WORKFLOWS_DIR/audit/audit-continuous-workflow/06-test-quality-audit.md"
    "$WORKFLOWS_DIR/audit/audit-continuous-workflow/07-security-audit.md"
    "$WORKFLOWS_DIR/audit/audit-continuous-workflow/08-data-governance-audit.md"
    "$WORKFLOWS_DIR/audit/audit-continuous-workflow/09-cross-subsystem-audit.md"
    "$WORKFLOWS_DIR/audit/audit-continuous-workflow/10-freshness-audit.md"
    "$WORKFLOWS_DIR/audit/audit-post-incident-workflow/02-operational-readiness-audit.md"
    "$WORKFLOWS_DIR/audit/audit-post-incident-workflow/03-observability-audit.md"
    "$WORKFLOWS_DIR/audit/audit-post-incident-workflow/04-security-audit.md"
    "$WORKFLOWS_DIR/audit/audit-post-incident-workflow/05-data-governance-audit.md"
    "$WORKFLOWS_DIR/audit/audit-post-incident-workflow/06-api-contract-audit.md"
    "$WORKFLOWS_DIR/audit/audit-post-incident-workflow/07-test-quality-audit.md"
    "$WORKFLOWS_DIR/audit/audit-post-incident-workflow/08-cross-subsystem-audit.md"
    "$WORKFLOWS_DIR/audit/audit-post-incident-workflow/09-freshness-audit.md"
    "$WORKFLOWS_DIR/audit/audit-orchestration-workflow/06-cross-subsystem-audit.md"
    "$WORKFLOWS_DIR/audit/audit-orchestration-workflow/07-freshness-audit.md"
    "$WORKFLOWS_DIR/audit/audit-release-readiness-workflow/02-release-core-audit.md"
    "$WORKFLOWS_DIR/audit/audit-release-readiness-workflow/03-operational-readiness-audit.md"
    "$WORKFLOWS_DIR/audit/audit-release-readiness-workflow/04-api-contract-audit.md"
    "$WORKFLOWS_DIR/audit/audit-release-readiness-workflow/05-test-quality-audit.md"
    "$WORKFLOWS_DIR/audit/audit-release-readiness-workflow/06-observability-audit.md"
    "$WORKFLOWS_DIR/audit/audit-release-readiness-workflow/07-security-audit.md"
    "$WORKFLOWS_DIR/audit/audit-release-readiness-workflow/08-data-governance-audit.md"
  )

  local file rel
  for file in "${files[@]}"; do
    rel="${file#$ROOT_DIR/}"

    if [[ ! -f "$file" ]]; then
      fail "missing bounded-audit forwarding file: $rel"
      continue
    fi

    if matches_file_fixed 'post_remediation="{{post_remediation}}"' "$file"; then
      pass "bounded-audit forwarding includes post_remediation: $rel"
    else
      fail "bounded-audit forwarding missing post_remediation: $rel"
    fi

    if matches_file_fixed 'convergence_k="{{convergence_k}}"' "$file"; then
      pass "bounded-audit forwarding includes convergence_k: $rel"
    else
      fail "bounded-audit forwarding missing convergence_k: $rel"
    fi

    if matches_file_fixed 'seed_list="{{seed_list}}"' "$file"; then
      pass "bounded-audit forwarding includes seed_list: $rel"
    else
      fail "bounded-audit forwarding missing seed_list: $rel"
    fi
  done
}

check_bounded_audit_contracts() {
  local audit_workflows
  audit_workflows=(audit-orchestration-workflow audit-pre-release-workflow audit-change-risk-workflow audit-continuous-workflow audit-post-incident-workflow audit-release-readiness-workflow audit-documentation-workflow audit-workflow-system-workflow)

  local workflow_id rel_path workflow_dir workflow_file block
  for workflow_id in "${audit_workflows[@]}"; do
    rel_path="${WORKFLOW_PATHS[$workflow_id]:-}"
    if [[ -z "$rel_path" ]]; then
      fail "bounded-audit workflow missing in manifest index: $workflow_id"
      continue
    fi

    workflow_dir="$WORKFLOWS_DIR/$rel_path"
    workflow_file="$workflow_dir/WORKFLOW.md"

    if [[ ! -f "$workflow_file" ]]; then
      fail "bounded-audit workflow missing WORKFLOW.md: ${workflow_file#$ROOT_DIR/}"
      continue
    fi

    if matches_file_regex "done-gate" "$workflow_file"; then
      pass "bounded-audit workflow defines done-gate semantics: ${workflow_file#$ROOT_DIR/}"
    else
      fail "bounded-audit workflow missing done-gate semantics: ${workflow_file#$ROOT_DIR/}"
    fi

    if matches_markdown_tree_regex "post_remediation" "$workflow_dir"; then
      pass "bounded-audit workflow references post_remediation: ${workflow_dir#$ROOT_DIR/}"
    else
      fail "bounded-audit workflow missing post_remediation references: ${workflow_dir#$ROOT_DIR/}"
    fi

    if matches_markdown_tree_regex "convergence_k" "$workflow_dir"; then
      pass "bounded-audit workflow references convergence_k: ${workflow_dir#$ROOT_DIR/}"
    else
      fail "bounded-audit workflow missing convergence_k references: ${workflow_dir#$ROOT_DIR/}"
    fi

    if matches_markdown_tree_regex "seed_list" "$workflow_dir"; then
      pass "bounded-audit workflow references seed_list: ${workflow_dir#$ROOT_DIR/}"
    else
      fail "bounded-audit workflow missing seed_list references: ${workflow_dir#$ROOT_DIR/}"
    fi

    if matches_markdown_tree_regex "findings\\.yml" "$workflow_dir"; then
      pass "bounded-audit workflow references findings.yml: ${workflow_dir#$ROOT_DIR/}"
    else
      fail "bounded-audit workflow missing findings.yml reference: ${workflow_dir#$ROOT_DIR/}"
    fi

    if matches_markdown_tree_regex "coverage\\.yml" "$workflow_dir"; then
      pass "bounded-audit workflow references coverage.yml: ${workflow_dir#$ROOT_DIR/}"
    else
      fail "bounded-audit workflow missing coverage.yml reference: ${workflow_dir#$ROOT_DIR/}"
    fi

    if matches_markdown_tree_regex "convergence\\.yml" "$workflow_dir"; then
      pass "bounded-audit workflow references convergence.yml: ${workflow_dir#$ROOT_DIR/}"
    else
      fail "bounded-audit workflow missing convergence.yml reference: ${workflow_dir#$ROOT_DIR/}"
    fi

    block="$(extract_registry_workflow_block "$workflow_id")"
    if [[ -z "$block" ]]; then
      fail "bounded-audit workflow missing registry block: $workflow_id"
      continue
    fi

    if printf '%s\n' "$block" | matches_stdin_regex "name:[[:space:]]+post_remediation"; then
      pass "registry bounded-audit parameter present (post_remediation): $workflow_id"
    else
      fail "registry bounded-audit parameter missing (post_remediation): $workflow_id"
    fi

    if printf '%s\n' "$block" | matches_stdin_regex "name:[[:space:]]+convergence_k"; then
      pass "registry bounded-audit parameter present (convergence_k): $workflow_id"
    else
      fail "registry bounded-audit parameter missing (convergence_k): $workflow_id"
    fi

    if printf '%s\n' "$block" | matches_stdin_regex "name:[[:space:]]+seed_list"; then
      pass "registry bounded-audit parameter present (seed_list): $workflow_id"
    else
      fail "registry bounded-audit parameter missing (seed_list): $workflow_id"
    fi

    if printf '%s\n' "$block" | matches_stdin_regex "output/reports/audits/"; then
      pass "registry bounded-audit output path present: $workflow_id"
    else
      fail "registry bounded-audit output path missing: $workflow_id"
    fi
  done

  check_bounded_audit_parameter_forwarding
}

check_workflow_system_audit_static() {
  if [[ ! -f "$WORKFLOW_SYSTEM_AUDIT" ]]; then
    fail "missing workflow-system audit engine: ${WORKFLOW_SYSTEM_AUDIT#$ROOT_DIR/}"
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
  check_dependency_profiles_against_steps
  check_dependency_profiles_against_registry_io
  check_bounded_audit_contracts
  check_workflow_system_audit_static
  check_deprecated_paths

  echo
  echo "Validation summary: errors=$errors warnings=$warnings"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
