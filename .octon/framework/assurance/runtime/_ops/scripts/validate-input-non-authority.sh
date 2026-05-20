#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
INPUTS_DIR="$OCTON_DIR/inputs"
ADDITIVE_INCOMING_DIR="$OCTON_DIR/inputs/additive/.incoming"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

rel_path() {
  local path="$1"
  case "$path" in
    "$ROOT_DIR"/*) printf '%s\n' "${path#$ROOT_DIR/}" ;;
    *) printf '%s\n' "$path" ;;
  esac
}

has_text() {
  local file="$1"
  local text="$2"
  rg -Fq -- "$text" "$file"
}

require_text_if_file_exists() {
  local rel="$1"
  local text="$2"
  local label="$3"
  local file="$ROOT_DIR/$rel"
  if [[ ! -f "$file" ]]; then
    return 0
  fi
  if has_text "$file" "$text"; then
    pass "$label"
  else
    fail "$label"
  fi
}

validate_input_root_entries() {
  if [[ ! -d "$INPUTS_DIR" ]]; then
    fail "missing inputs root: $(rel_path "$INPUTS_DIR")"
    return
  fi

  local entry base
  while IFS= read -r entry; do
    [[ -n "$entry" ]] || continue
    base="$(basename "$entry")"
    case "$base" in
      README.md|additive|exploratory)
        pass "allowed inputs root entry: $base"
        ;;
      *)
        fail "unexpected inputs root entry: $(rel_path "$entry")"
        ;;
    esac
  done < <(find "$INPUTS_DIR" -mindepth 1 -maxdepth 1 -print | sort)
}

validate_incoming_status_markers() {
  if [[ ! -d "$ADDITIVE_INCOMING_DIR" ]]; then
    fail "missing additive incoming root: $(rel_path "$ADDITIVE_INCOMING_DIR")"
    return
  fi

  if ! command -v yq >/dev/null 2>&1; then
    fail "yq is required for incoming intake status validation"
    return
  fi

  local entry base status_file schema intake_id authority_mode status reason next_step
  while IFS= read -r entry; do
    [[ -n "$entry" ]] || continue
    base="$(basename "$entry")"
    case "$base" in
      .gitkeep|README.md)
        continue
        ;;
      .DS_Store)
        fail "platform noise is not allowed in incoming intake root: $(rel_path "$entry")"
        continue
        ;;
    esac
    if [[ ! -d "$entry" ]]; then
      fail "incoming intake root may contain only documentation, .gitkeep, and intake directories: $(rel_path "$entry")"
      continue
    fi

    status_file="$entry/intake-status.yml"
    if [[ ! -f "$status_file" ]]; then
      fail "incoming intake directory requires intake-status.yml: $(rel_path "$entry")"
      continue
    fi

    schema="$(yq -r '.schema_version // ""' "$status_file")"
    intake_id="$(yq -r '.intake_id // ""' "$status_file")"
    authority_mode="$(yq -r '.authority_mode // ""' "$status_file")"
    status="$(yq -r '.status // ""' "$status_file")"
    reason="$(yq -r '.reason // ""' "$status_file")"
    next_step="$(yq -r '.next_step // ""' "$status_file")"

    [[ "$schema" == "octon-additive-incoming-intake-status-v1" ]] \
      && pass "incoming intake status schema current: $base" \
      || fail "incoming intake status schema must be octon-additive-incoming-intake-status-v1: $(rel_path "$status_file")"
    [[ "$intake_id" == "$base" ]] \
      && pass "incoming intake status id matches directory: $base" \
      || fail "incoming intake status intake_id must match directory: $(rel_path "$status_file")"
    [[ "$authority_mode" == "non_authoritative" ]] \
      && pass "incoming intake status is non_authoritative: $base" \
      || fail "incoming intake status authority_mode must be non_authoritative: $(rel_path "$status_file")"
    case "$status" in
      unclassified|classified-pending-normalization|rejected-pending-archive|blocked|intentionally-retained-temporarily)
        pass "incoming intake status is allowed: $base"
        ;;
      *)
        fail "incoming intake status is not allowed: $(rel_path "$status_file")"
        ;;
    esac
    [[ -n "$reason" ]] \
      && pass "incoming intake status has reason: $base" \
      || fail "incoming intake status requires reason: $(rel_path "$status_file")"
    [[ -n "$next_step" ]] \
      && pass "incoming intake status has next_step: $base" \
      || fail "incoming intake status requires next_step: $(rel_path "$status_file")"
  done < <(find "$ADDITIVE_INCOMING_DIR" -mindepth 1 -maxdepth 1 -print | sort)
}

line_has_input_path() {
  [[ "$1" =~ (\.octon/)?inputs/additive/(\.incoming|\.archive)/ ]] && return 0
  [[ "$1" =~ (\.octon/)?inputs/additive/extensions/\.(incoming|archive)(/|$) ]] && return 0
  [[ "$1" =~ (\.octon/)?inputs/exploratory/(proposals|ideation|plans|syntheses|reports|drafts|packages)(/|$) ]] && return 0
  return 1
}

line_is_explicit_authority_dependency() {
  local line="$1"
  [[ "$line" =~ (^|[[:space:]-])(authority_source|runtime_source|policy_source|source_path|source_ref|manifest_path|live_dependency|dependency_source|source|path):[[:space:]] ]] && return 0
  [[ "$line" =~ const[[:space:]]+[A-Z_]*SOURCE ]] && return 0
  [[ "$line" == *" as live "* && "$line" == *"authority"* ]] && return 0
  return 1
}

line_is_non_authority_or_producer_reference() {
  local line="$1"
  [[ "$line" == *"non-authoritative"* ]] && return 0
  [[ "$line" == *"non_authoritative"* ]] && return 0
  [[ "$line" == *"not authority"* ]] && return 0
  [[ "$line" == *"never"* && "$line" == *"authority"* ]] && return 0
  [[ "$line" == *"allowed-tools"* ]] && return 0
  [[ "$line" == *"Write("* ]] && return 0
  [[ "$line" == *"Write only to"* ]] && return 0
  [[ "$line" == *"Read("* ]] && return 0
  [[ "$line" == *"outputs:"* ]] && return 0
  [[ "$line" == *"Outputs are written"* ]] && return 0
  [[ "$line" == *"Output Location"* ]] && return 0
  [[ "$line" == *"output:"* ]] && return 0
  [[ "$line" == *"Output Structure"* ]] && return 0
  [[ "$line" == *"Primary Output"* ]] && return 0
  [[ "$line" == *"written to:"* ]] && return 0
  [[ "$line" == *"Output paths"* ]] && return 0
  [[ "$line" =~ ^[[:space:]-]*path:[[:space:]] ]] && return 0
  [[ "$line" == *"Path:"* ]] && return 0
  [[ "$line" == *"default:"* ]] && return 0
  [[ "$line" == *"artifact_globs"* ]] && return 0
  [[ "$line" == *"Materialize"* ]] && return 0
  [[ "$line" == *"packet-path"* ]] && return 0
  [[ "$line" == *"default package root"* ]] && return 0
  [[ "$line" == *"exists in"* ]] && return 0
  [[ "$line" == *"must exist"* ]] && return 0
  [[ "$line" == *"Synthesis"* ]] && return 0
  [[ "$line" == *"synthesis"* ]] && return 0
  [[ "$line" == *"plan"* && "$line" == *"inputs/exploratory/plans/"* ]] && return 0
  [[ "$line" == *"required artifacts"* ]] && return 0
  [[ "$line" == *"Example Path"* ]] && return 0
  [[ "$line" == *"Deliverables"* ]] && return 0
  [[ "$line" == *"report"* && "$line" == *"rooted"* ]] && return 0
  [[ "$line" == *"report"* && "$line" == *"inputs/exploratory/reports/"* ]] && return 0
  [[ "$line" == *"proposal"* && "$line" == *"inputs/exploratory/proposals/"* ]] && return 0
  [[ "$line" == *"Rename"* && "$line" == *"inputs/exploratory/ideation/"* ]] && return 0
  [[ "$line" == *"Renamed"* && "$line" == *"inputs/exploratory/ideation/"* ]] && return 0
  [[ "$line" == *"Directory:"* && "$line" == *"inputs/exploratory/ideation/"* ]] && return 0
  [[ "$line" == *"mv "* && "$line" == *"inputs/exploratory/ideation/"* ]] && return 0
  [[ "$line" == *"Retired exploratory surfaces"* ]] && return 0
  return 1
}

is_allowed_input_reference() {
  local rel="$1"
  local line="$2"

  case "$rel" in
    .octon/framework/cognition/_meta/architecture/inputs/*|\
    .octon/framework/cognition/_meta/architecture/*|\
    .octon/framework/capabilities/_meta/architecture/*|\
    .octon/framework/capabilities/practices/*|\
    .octon/framework/orchestration/practices/*|\
    .octon/framework/orchestration/governance/*|\
    .octon/framework/scaffolding/governance/patterns/*proposal-standard.md|\
    .octon/framework/scaffolding/runtime/templates/proposal-*/*|\
    .octon/framework/engine/governance/inputs/*|\
    .octon/framework/engine/governance/extensions/README.md|\
    .octon/framework/engine/runtime/spec/*.md|\
    .octon/instance/ingress/AGENTS.md|\
    .octon/instance/ingress/manifest.yml|\
    .octon/instance/governance/evolution/path-families.yml|\
    .octon/instance/governance/non-authority-register.yml|\
    .octon/instance/bootstrap/START.md|\
    .octon/framework/scaffolding/runtime/templates/octon/START.md|\
    .octon/framework/scaffolding/runtime/templates/octon/manifest.json|\
    .octon/framework/capabilities/runtime/commands/process-incoming-intake.md|\
    .claude/commands/process-incoming-intake.md|\
    .cursor/commands/process-incoming-intake.md|\
    .codex/commands/process-incoming-intake.md|\
    .octon/framework/orchestration/runtime/workflows/meta/process-incoming-intake/*|\
    .octon/framework/orchestration/runtime/workflows/meta/create-*-proposal/*|\
    .octon/framework/orchestration/runtime/workflows/meta/create-*-proposal/stages/*|\
    .octon/framework/orchestration/runtime/workflows/meta/migrate-harness/*|\
    .octon/framework/orchestration/runtime/workflows/ideation/*|\
    .octon/framework/orchestration/runtime/workflows/ideation/*/*|\
    .octon/framework/orchestration/runtime/workflows/projects/*|\
    .octon/framework/orchestration/runtime/workflows/projects/*/*|\
    .octon/framework/orchestration/runtime/workflows/refactor/*|\
    .octon/framework/orchestration/runtime/workflows/refactor/*/*|\
    .octon/framework/orchestration/runtime/workflows/_ops/scripts/validate-*.sh|\
    .octon/framework/orchestration/runtime/queue/_ops/scripts/validate-queue.sh|\
    .octon/framework/orchestration/runtime/_ops/scripts/validate-*.sh|\
    .octon/framework/orchestration/runtime/_ops/tests/*|\
    .octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh|\
    .octon/framework/assurance/runtime/_ops/scripts/validate-raw-input-dependency-ban.sh|\
    .octon/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh|\
    .octon/framework/assurance/runtime/_ops/scripts/validate-exploratory-input-surfaces.sh|\
    .octon/framework/assurance/runtime/_ops/scripts/validate-input-archive-retention.sh|\
    .octon/framework/assurance/runtime/_ops/scripts/validate-*.sh|\
    .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh|\
    .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh|\
    .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh|\
    .octon/framework/assurance/runtime/_ops/scripts/validate-framework-core-boundary.sh|\
    .octon/framework/assurance/runtime/_ops/tests/*|\
    .octon/framework/assurance/scripts/*|\
    .octon/framework/capabilities/_ops/scripts/*.sh|\
    .octon/framework/capabilities/_ops/tests/*|\
    .octon/framework/scaffolding/practices/prompts/*)
      return 0
      ;;
    .octon/state/evidence/validation/publication/*)
      ! line_is_explicit_authority_dependency "$line"
      return
      ;;
    .octon/framework/capabilities/runtime/skills/*|\
    .octon/framework/capabilities/runtime/commands/octon-drift-triage.md|\
    .octon/framework/capabilities/runtime/skills/registry.yml|\
    .octon/generated/effective/extensions/published/*|\
    .claude/commands/*|.claude/skills/*|\
    .cursor/commands/*|.cursor/skills/*|\
    .codex/commands/*|.codex/skills/*)
      [[ "$line" == *"inputs/exploratory/proposals/"* && "$line" == *"proposal"* ]] || \
        [[ "$line" == *"path:"* && "$line" == *"inputs/exploratory/syntheses/"* ]] || \
        [[ "$line" == *"path:"* && "$line" == *"inputs/exploratory/plans/"* ]] || \
        { ! line_is_explicit_authority_dependency "$line" && line_is_non_authority_or_producer_reference "$line"; }
      return
      ;;
    .octon/framework/engine/runtime/crates/kernel/src/main.rs|\
    .octon/framework/engine/runtime/crates/kernel/src/workflow.rs|\
    .octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs|\
    .octon/framework/engine/runtime/crates/runtime_bus/src/lib.rs|\
    .octon/framework/engine/runtime/crates/lifecycle_executor/src/observer.rs|\
    .octon/framework/engine/runtime/crates/authority_engine/src/implementation/runtime_state.rs)
      [[ "$line" == *"inputs/exploratory/proposals/"* || "$line" == *"\"exclusions\""* ]]
      return
      ;;
    .octon/generated/proposals/registry.yml)
      [[ "$line" == *"inputs/exploratory/proposals/"* ]]
      return
      ;;
    .octon/generated/effective/extensions/catalog.effective.yml|\
    .octon/generated/effective/extensions/generation.lock.yml)
      [[ "$line" == *"inputs/exploratory/proposals/README.md"* ]] || \
        [[ "$line" == *"inputs/exploratory/proposals/"* && "$line" == *"proposal"* ]] || \
        [[ "$line" == *"path:"* && "$line" == *"inputs/exploratory/syntheses/"* ]] || \
        [[ "$line" == *"path:"* && "$line" == *"inputs/exploratory/plans/"* ]] || \
        { ! line_is_explicit_authority_dependency "$line" && line_is_non_authority_or_producer_reference "$line"; }
      return
      ;;
    .octon/state/control/execution/runs/*)
      [[ "$line" == *"inputs/exploratory/proposals/"* || "$line" == *"inputs/exploratory/ideation/**"* ]]
      return
      ;;
    .octon/framework/orchestration/runtime/workflows/registry.yml)
      [[ "$line" == *"process-incoming-intake"* ]] || \
        [[ "$line" == *"incoming_intake"* ]] || \
        [[ "$line" == *"inputs/exploratory/proposals/"* ]] || \
        [[ "$line" == *"description:"* && "$line" == *"inputs/additive/.incoming/<intake-id>"* ]] || \
        [[ "$line" == *"inputs/additive/.incoming"* && "$line" == *"{{intake_id}}"* ]]
      return
      ;;
    *)
      return 1
      ;;
  esac
}

scan_targets() {
  local candidates=(
    "$OCTON_DIR/framework/constitution"
    "$OCTON_DIR/framework/product"
    "$OCTON_DIR/framework/overlay-points"
    "$OCTON_DIR/framework/execution-roles"
    "$OCTON_DIR/framework/engine"
    "$OCTON_DIR/framework/assurance"
    "$OCTON_DIR/framework/capabilities"
    "$OCTON_DIR/framework/cognition"
    "$OCTON_DIR/framework/orchestration"
    "$OCTON_DIR/framework/scaffolding"
    "$OCTON_DIR/instance/ingress"
    "$OCTON_DIR/instance/bootstrap"
    "$OCTON_DIR/instance/governance"
    "$OCTON_DIR/instance/capabilities"
    "$OCTON_DIR/instance/orchestration"
    "$OCTON_DIR/instance/assurance"
    "$OCTON_DIR/instance/execution-roles"
    "$OCTON_DIR/instance/locality"
    "$OCTON_DIR/generated"
    "$OCTON_DIR/state/control"
    "$OCTON_DIR/state/evidence/validation/publication"
    "$ROOT_DIR/.claude/commands"
    "$ROOT_DIR/.claude/skills"
    "$ROOT_DIR/.cursor/commands"
    "$ROOT_DIR/.cursor/skills"
    "$ROOT_DIR/.codex/commands"
    "$ROOT_DIR/.codex/skills"
  )

  local target
  for target in "${candidates[@]}"; do
    [[ -e "$target" ]] && printf '%s\n' "$target"
  done
}

main() {
  echo "== Input Non-Authority Validation =="

  require_text_if_file_exists \
    ".octon/inputs/README.md" \
    "never runtime, policy, generated, state/control, publication, retained" \
    "local inputs README states inputs are non-authoritative"
  require_text_if_file_exists \
    ".octon/inputs/additive/README.md" \
    "Everything in this tree is non-authoritative input" \
    "local additive README states raw inputs are non-authoritative"
  require_text_if_file_exists \
    ".octon/framework/cognition/_meta/architecture/inputs/README.md" \
    "never runtime, policy, generated, state/control, publication, retained" \
    "intake-wide architecture states inputs are non-authoritative"
  require_text_if_file_exists \
    ".octon/inputs/exploratory/README.md" \
    "never become runtime, policy" \
    "exploratory contract states raw inputs are non-authoritative"
  require_text_if_file_exists \
    ".octon/inputs/additive/.incoming/README.md" \
    "intake-status.yml" \
    "incoming contract documents status marker"
  require_text_if_file_exists \
    ".octon/framework/cognition/_meta/architecture/inputs/additive/README.md" \
    '`.incoming/**`, `.archive/**`, or' \
    "additive architecture covers all raw additive authority boundaries"
  require_text_if_file_exists \
    ".octon/framework/capabilities/runtime/commands/process-incoming-intake.md" \
    "does not process exploratory proposals, advisory plans, syntheses, or reports" \
    "incoming-intake command is additive-only"
  require_text_if_file_exists \
    ".octon/framework/engine/governance/inputs/additive/incoming-intake-processing.md" \
    "they are never runtime, policy, publication, generated, state/control, retained" \
    "incoming-intake governance states raw intake is non-authoritative"

  validate_input_root_entries
  validate_incoming_status_markers

  local target_args=()
  local target
  while IFS= read -r target; do
    [[ -n "$target" ]] && target_args+=("$target")
  done < <(scan_targets)

  if [[ ${#target_args[@]} -eq 0 ]]; then
    pass "no scan targets exist"
    echo "Validation summary: errors=$errors"
    return 0
  fi

  local matches line file line_no text rel
  matches="$(
    rg -n \
      -g '*.md' -g '*.yml' -g '*.yaml' -g '*.json' -g '*.sh' \
      -g '*.rs' -g '*.py' -g '*.toml' -g '*.js' -g '*.ts' -g '*.tsx' -g '*.mjs' -g '*.cjs' \
      '(\.octon/)?inputs/additive/(\.incoming|\.archive)/|(\.octon/)?inputs/additive/extensions/\.(incoming|archive)(/|$)|(\.octon/)?inputs/exploratory/(proposals|ideation|plans|syntheses|reports|drafts|packages)(/|$)' \
      "${target_args[@]}" || true
  )"

  if [[ -z "$matches" ]]; then
    pass "no raw input references detected in authority-sensitive surfaces"
  else
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      IFS=: read -r file line_no text <<<"$line"
      rel="$(rel_path "$file")"

      if line_has_input_path "$text"; then
        if ! is_allowed_input_reference "$rel" "$text"; then
          fail "raw input authority leak: ${rel}:${line_no}"
        fi
      fi
    done <<<"$matches"
  fi

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
