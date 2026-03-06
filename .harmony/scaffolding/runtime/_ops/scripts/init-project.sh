#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HARMONY_DIR="$(cd -- "$SCRIPT_DIR/../../../.." && pwd)"
DEFAULT_REPO_ROOT="$(cd -- "$HARMONY_DIR/.." && pwd)"
DEFAULT_OBJECTIVE_ID="general-purpose"

REPO_ROOT="$DEFAULT_REPO_ROOT"
FORCE=0
DRY_RUN=0
LINK_CLAUDE=1
WITH_BOOT_FILES=0
WITH_AGENT_PLATFORM_ADAPTERS=0
AGENT_PLATFORM_ADAPTERS=""
LIST_OBJECTIVES=0
SELECTED_OBJECTIVE_ID=""
OBJECTIVE_LABEL=""
OBJECTIVE_SUMMARY=""
OBJECTIVE_OWNER=""
OBJECTIVE_APPROVED_BY=""
INTENT_ID=""

usage() {
  cat <<'USAGE'
Usage: init-project.sh [--repo-root <path>] [--force] [--dry-run] [--list-objectives] [--objective <id>] [--objective-owner <name>] [--objective-approved-by <name>] [--no-claude-alias] [--with-boot-files] [--with-agent-platform-adapters] [--agent-platform-adapters <csv>]

Initializes project-level bootstrap files and objective-contract artifacts from .harmony templates.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-root)
      shift
      [[ $# -gt 0 ]] || { echo "[ERROR] --repo-root requires a value" >&2; exit 1; }
      REPO_ROOT="$1"
      ;;
    --force)
      FORCE=1
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    --list-objectives)
      LIST_OBJECTIVES=1
      ;;
    --objective)
      shift
      [[ $# -gt 0 ]] || { echo "[ERROR] --objective requires a value" >&2; exit 1; }
      SELECTED_OBJECTIVE_ID="$1"
      ;;
    --objective-owner)
      shift
      [[ $# -gt 0 ]] || { echo "[ERROR] --objective-owner requires a value" >&2; exit 1; }
      OBJECTIVE_OWNER="$1"
      ;;
    --objective-approved-by)
      shift
      [[ $# -gt 0 ]] || { echo "[ERROR] --objective-approved-by requires a value" >&2; exit 1; }
      OBJECTIVE_APPROVED_BY="$1"
      ;;
    --no-claude-alias)
      LINK_CLAUDE=0
      ;;
    --with-boot-files)
      WITH_BOOT_FILES=1
      ;;
    --with-agent-platform-adapters)
      WITH_AGENT_PLATFORM_ADAPTERS=1
      ;;
    --agent-platform-adapters)
      shift
      [[ $# -gt 0 ]] || { echo "[ERROR] --agent-platform-adapters requires a value" >&2; exit 1; }
      AGENT_PLATFORM_ADAPTERS="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

REPO_ROOT="$(cd -- "$REPO_ROOT" && pwd)"
TEMPLATE_FILE="$HARMONY_DIR/scaffolding/runtime/templates/AGENTS.md"
BOOT_TEMPLATE_FILE="$HARMONY_DIR/scaffolding/runtime/templates/BOOT.md"
BOOTSTRAP_TEMPLATE_FILE="$HARMONY_DIR/scaffolding/runtime/templates/BOOTSTRAP.md"
ALIGNMENT_CHECK_TEMPLATE_FILE="$HARMONY_DIR/scaffolding/runtime/templates/alignment-check"
OBJECTIVE_TEMPLATE_ROOT="$HARMONY_DIR/scaffolding/runtime/templates/objectives"
OBJECTIVE_REGISTRY_FILE="$OBJECTIVE_TEMPLATE_ROOT/registry.txt"
AGENCY_MANIFEST="$HARMONY_DIR/agency/manifest.yml"
AGENTS_OUT="$REPO_ROOT/AGENTS.md"
CLAUDE_OUT="$REPO_ROOT/CLAUDE.md"
BOOT_OUT="$REPO_ROOT/BOOT.md"
BOOTSTRAP_OUT="$REPO_ROOT/BOOTSTRAP.md"
ALIGNMENT_CHECK_OUT="$REPO_ROOT/alignment-check"
OBJECTIVE_OUT="$REPO_ROOT/OBJECTIVE.md"
INTENT_CONTRACT_OUT="$REPO_ROOT/.harmony/cognition/runtime/context/intent.contract.yml"
ADAPTER_REGISTRY="$REPO_ROOT/.harmony/capabilities/runtime/services/interfaces/agent-platform/adapters/registry.yml"
ADAPTER_ENABLED_OUT="$REPO_ROOT/.harmony/capabilities/runtime/services/interfaces/agent-platform/adapters/enabled.yml"
CONTEXT_POLICY_FILE="$HARMONY_DIR/capabilities/governance/policy/deny-by-default.v2.yml"
GENERATED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
REPO_NAME="$(basename "$REPO_ROOT")"

escape_sed_replacement() {
  printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'
}

objective_registry_lines() {
  awk -F'|' '
    /^[[:space:]]*#/ { next }
    NF < 3 { next }
    {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $1)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $3)
      if (length($1) > 0) print $1 "|" $2 "|" $3
    }
  ' "$OBJECTIVE_REGISTRY_FILE"
}

print_available_objectives() {
  local objective_id label summary found_default=0

  if [[ ! -f "$OBJECTIVE_REGISTRY_FILE" ]]; then
    echo "[ERROR] Missing objective registry: $OBJECTIVE_REGISTRY_FILE" >&2
    exit 1
  fi

  echo "Available objectives:"
  while IFS='|' read -r objective_id label summary; do
    printf "  - %s: %s\n" "$objective_id" "$label"
    printf "    %s\n" "$summary"
    if [[ "$objective_id" == "$DEFAULT_OBJECTIVE_ID" ]]; then
      found_default=1
    fi
  done < <(objective_registry_lines)

  if [[ "$found_default" -eq 1 ]]; then
    echo ""
    echo "Default objective: $DEFAULT_OBJECTIVE_ID"
  fi
}

objective_exists() {
  local requested_id="$1"
  local objective_id label summary

  while IFS='|' read -r objective_id label summary; do
    if [[ "$objective_id" == "$requested_id" ]]; then
      return 0
    fi
  done < <(objective_registry_lines)

  return 1
}

objective_field() {
  local requested_id="$1"
  local field_name="$2"
  local objective_id label summary

  while IFS='|' read -r objective_id label summary; do
    if [[ "$objective_id" == "$requested_id" ]]; then
      case "$field_name" in
        label)
          printf '%s\n' "$label"
          ;;
        summary)
          printf '%s\n' "$summary"
          ;;
      esac
      return 0
    fi
  done < <(objective_registry_lines)

  return 1
}

detect_default_actor() {
  local actor=""
  actor="$(id -un 2>/dev/null || true)"
  if [[ -z "$actor" ]]; then
    actor="$(whoami 2>/dev/null || true)"
  fi
  if [[ -z "$actor" ]]; then
    actor="workspace-owner"
  fi
  printf '%s\n' "$actor"
}

sanitize_repo_slug() {
  local raw="$1"
  local slug=""
  slug="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-')"
  slug="${slug#-}"
  slug="${slug%-}"
  if [[ -z "$slug" ]]; then
    slug="workspace"
  fi
  printf '%s\n' "$slug"
}

objective_contract_needs_write() {
  if [[ "$FORCE" -eq 1 ]]; then
    return 0
  fi

  if [[ ! -f "$OBJECTIVE_OUT" || ! -f "$INTENT_CONTRACT_OUT" ]]; then
    return 0
  fi

  return 1
}

prompt_for_objective() {
  local lines=()
  local default_index=1
  local choice=""
  local objective_id label summary
  local i

  mapfile -t lines < <(objective_registry_lines)
  if [[ ${#lines[@]} -eq 0 ]]; then
    echo "[ERROR] No objectives found in registry: $OBJECTIVE_REGISTRY_FILE" >&2
    exit 1
  fi

  echo "Select a Harmony objective for this workspace:"
  for i in "${!lines[@]}"; do
    IFS='|' read -r objective_id label summary <<< "${lines[$i]}"
    if [[ "$objective_id" == "$DEFAULT_OBJECTIVE_ID" ]]; then
      default_index=$((i + 1))
    fi
    printf "  %d) %s\n" "$((i + 1))" "$label"
    printf "     %s\n" "$summary"
  done
  echo ""
  printf "Enter a number [1-%d] (default %d): " "${#lines[@]}" "$default_index"
  read -r choice

  if [[ -z "$choice" ]]; then
    choice="$default_index"
  fi

  if [[ ! "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#lines[@]} )); then
    echo "[ERROR] Invalid objective selection: $choice" >&2
    exit 1
  fi

  IFS='|' read -r SELECTED_OBJECTIVE_ID OBJECTIVE_LABEL OBJECTIVE_SUMMARY <<< "${lines[$((choice - 1))]}"
}

resolve_objective_selection() {
  local repo_slug=""

  if ! objective_contract_needs_write; then
    return
  fi

  if [[ ! -f "$OBJECTIVE_REGISTRY_FILE" ]]; then
    echo "[ERROR] Missing objective registry: $OBJECTIVE_REGISTRY_FILE" >&2
    exit 1
  fi

  if [[ -z "$SELECTED_OBJECTIVE_ID" ]]; then
    if [[ -t 0 && -t 1 ]]; then
      prompt_for_objective
    else
      SELECTED_OBJECTIVE_ID="$DEFAULT_OBJECTIVE_ID"
      OBJECTIVE_LABEL="$(objective_field "$SELECTED_OBJECTIVE_ID" "label")"
      OBJECTIVE_SUMMARY="$(objective_field "$SELECTED_OBJECTIVE_ID" "summary")"
      echo "[INFO] Non-interactive init defaulted objective to '$SELECTED_OBJECTIVE_ID'. Use --objective or --list-objectives to choose a different common use case."
    fi
  fi

  if ! objective_exists "$SELECTED_OBJECTIVE_ID"; then
    echo "[ERROR] Unknown objective '$SELECTED_OBJECTIVE_ID'. Use --list-objectives to inspect available options." >&2
    exit 1
  fi

  if [[ -z "$OBJECTIVE_LABEL" ]]; then
    OBJECTIVE_LABEL="$(objective_field "$SELECTED_OBJECTIVE_ID" "label")"
  fi
  if [[ -z "$OBJECTIVE_SUMMARY" ]]; then
    OBJECTIVE_SUMMARY="$(objective_field "$SELECTED_OBJECTIVE_ID" "summary")"
  fi

  repo_slug="$(sanitize_repo_slug "$REPO_NAME")"
  INTENT_ID="intent://${repo_slug}/${SELECTED_OBJECTIVE_ID}"
}

render_agents_template() {
  local escaped_default_agent escaped_execution_contract escaped_identity_contract
  escaped_default_agent="$(escape_sed_replacement "$DEFAULT_AGENT")"
  escaped_execution_contract="$(escape_sed_replacement "$DEFAULT_AGENT_EXECUTION_CONTRACT")"
  escaped_identity_contract="$(escape_sed_replacement "$DEFAULT_AGENT_IDENTITY_CONTRACT")"

  sed \
    -e "s|{{DEFAULT_AGENT}}|$escaped_default_agent|g" \
    -e "s|{{DEFAULT_AGENT_EXECUTION_CONTRACT}}|$escaped_execution_contract|g" \
    -e "s|{{DEFAULT_AGENT_IDENTITY_CONTRACT}}|$escaped_identity_contract|g" \
    "$TEMPLATE_FILE"
}

render_objective_template() {
  local template_path="$1"
  local escaped_repo_name escaped_objective_id escaped_objective_label
  local escaped_objective_summary escaped_intent_id escaped_owner escaped_approved_by
  local escaped_generated_at

  escaped_repo_name="$(escape_sed_replacement "$REPO_NAME")"
  escaped_objective_id="$(escape_sed_replacement "$SELECTED_OBJECTIVE_ID")"
  escaped_objective_label="$(escape_sed_replacement "$OBJECTIVE_LABEL")"
  escaped_objective_summary="$(escape_sed_replacement "$OBJECTIVE_SUMMARY")"
  escaped_intent_id="$(escape_sed_replacement "$INTENT_ID")"
  escaped_owner="$(escape_sed_replacement "$OBJECTIVE_OWNER")"
  escaped_approved_by="$(escape_sed_replacement "$OBJECTIVE_APPROVED_BY")"
  escaped_generated_at="$(escape_sed_replacement "$GENERATED_AT")"

  sed \
    -e "s|{{REPO_NAME}}|$escaped_repo_name|g" \
    -e "s|{{OBJECTIVE_ID}}|$escaped_objective_id|g" \
    -e "s|{{OBJECTIVE_LABEL}}|$escaped_objective_label|g" \
    -e "s|{{OBJECTIVE_SUMMARY}}|$escaped_objective_summary|g" \
    -e "s|{{INTENT_ID}}|$escaped_intent_id|g" \
    -e "s|{{OBJECTIVE_OWNER}}|$escaped_owner|g" \
    -e "s|{{OBJECTIVE_APPROVED_BY}}|$escaped_approved_by|g" \
    -e "s|{{GENERATED_AT}}|$escaped_generated_at|g" \
    "$template_path"
}

read_context_gate_max_value() {
  local key="$1"
  awk -v key="$key" '
    $1 == key ":" {
      print $2
      exit
    }
  ' "$CONTEXT_POLICY_FILE"
}

read_context_gate_allowed_sections() {
  awk '
    /^[[:space:]]*allowed_sections:[[:space:]]*$/ {in_sections=1; next}
    in_sections && /^[[:space:]]*limits:[[:space:]]*$/ {in_sections=0}
    in_sections && /^[[:space:]]*-[[:space:]]*/ {
      line=$0
      sub(/^[[:space:]]*-[[:space:]]*/, "", line)
      gsub(/[[:space:]]+$/, "", line)
      if (length(line) > 0) print line
    }
  ' "$CONTEXT_POLICY_FILE"
}

validate_generated_agents_file() {
  local file_path="$1"
  local max_bytes max_sections bytes section_count heading allowed candidate
  local -a allowed_sections=()
  local -a headings=()

  if [[ ! -f "$CONTEXT_POLICY_FILE" ]]; then
    echo "[ERROR] Missing developer context policy: $CONTEXT_POLICY_FILE" >&2
    return 1
  fi

  mapfile -t allowed_sections < <(read_context_gate_allowed_sections)
  if [[ ${#allowed_sections[@]} -eq 0 ]]; then
    echo "[ERROR] Policy missing developer_context_gate.allowlist.allowed_sections" >&2
    return 1
  fi

  max_bytes="$(read_context_gate_max_value "max_bytes")"
  max_sections="$(read_context_gate_max_value "max_sections")"
  if [[ -z "$max_bytes" || ! "$max_bytes" =~ ^[0-9]+$ ]]; then
    echo "[ERROR] Policy max_bytes missing or invalid: $max_bytes" >&2
    return 1
  fi
  if [[ -z "$max_sections" || ! "$max_sections" =~ ^[0-9]+$ ]]; then
    echo "[ERROR] Policy max_sections missing or invalid: $max_sections" >&2
    return 1
  fi

  bytes="$(wc -c < "$file_path" | tr -d '[:space:]')"
  if (( bytes > max_bytes )); then
    echo "[ERROR] Generated AGENTS.md exceeds max_bytes ($bytes > $max_bytes)" >&2
    return 1
  fi

  mapfile -t headings < <(awk '/^## / {line=$0; sub(/^## /, "", line); print line}' "$file_path")
  section_count="${#headings[@]}"
  if (( section_count > max_sections )); then
    echo "[ERROR] Generated AGENTS.md exceeds max_sections ($section_count > $max_sections)" >&2
    return 1
  fi

  for heading in "${headings[@]}"; do
    allowed=0
    for candidate in "${allowed_sections[@]}"; do
      if [[ "$heading" == "$candidate" ]]; then
        allowed=1
        break
      fi
    done
    if [[ "$allowed" -ne 1 ]]; then
      echo "[ERROR] Generated AGENTS.md contains non-compliant section: $heading" >&2
      return 1
    fi
  done

  return 0
}

write_from_template() {
  local template_path="$1"
  local output_path="$2"
  local label="$3"

  if [[ ! -f "$template_path" ]]; then
    echo "[WARN] Missing ${label} template: $template_path"
    return
  fi

  if [[ -f "$output_path" && "$FORCE" -ne 1 ]]; then
    echo "[SKIP] ${label} already exists: $output_path"
    return
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ -f "$output_path" ]]; then
      echo "[DRY] Would overwrite ${label} from template: $output_path"
    else
      echo "[DRY] Would create ${label} from template: $output_path"
    fi
    return
  fi

  cat "$template_path" > "$output_path"
  if [[ "$FORCE" -eq 1 ]]; then
    echo "[OK] ${label} overwritten from template: $output_path"
  else
    echo "[OK] ${label} created from template: $output_path"
  fi
}

write_objective_file() {
  local template_path="$1"
  local output_path="$2"
  local label="$3"
  local tmp_output=""

  if [[ ! -f "$template_path" ]]; then
    echo "[ERROR] Missing ${label} template: $template_path" >&2
    exit 1
  fi

  if [[ -f "$output_path" && "$FORCE" -ne 1 ]]; then
    echo "[SKIP] ${label} already exists: $output_path"
    return
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ -f "$output_path" ]]; then
      echo "[DRY] Would overwrite ${label} from template: $output_path"
    else
      echo "[DRY] Would create ${label} from template: $output_path"
    fi
    return
  fi

  mkdir -p "$(dirname "$output_path")"
  tmp_output="$(mktemp "${TMPDIR:-/tmp}/harmony-init-objective.XXXXXX")"
  render_objective_template "$template_path" > "$tmp_output"
  mv "$tmp_output" "$output_path"

  if [[ "$FORCE" -eq 1 ]]; then
    echo "[OK] ${label} overwritten from template: $output_path"
  else
    echo "[OK] ${label} created from template: $output_path"
  fi
}

write_agents() {
  local tmp_agents=""
  if [[ -f "$AGENTS_OUT" && "$FORCE" -ne 1 ]]; then
    echo "[SKIP] AGENTS.md already exists: $AGENTS_OUT"
    return
  fi

  tmp_agents="$(mktemp "${TMPDIR:-/tmp}/harmony-init-agents.XXXXXX.md")"
  render_agents_template > "$tmp_agents"
  if ! validate_generated_agents_file "$tmp_agents"; then
    rm -f "$tmp_agents"
    echo "[ERROR] Refusing to write non-compliant AGENTS.md from template" >&2
    exit 1
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ -f "$AGENTS_OUT" ]]; then
      echo "[DRY] Would overwrite AGENTS.md from template: $AGENTS_OUT"
    else
      echo "[DRY] Would create AGENTS.md from template: $AGENTS_OUT"
    fi
    rm -f "$tmp_agents"
    return
  fi

  mv "$tmp_agents" "$AGENTS_OUT"
  if [[ "$FORCE" -eq 1 ]]; then
    echo "[OK] AGENTS.md overwritten from template: $AGENTS_OUT"
  else
    echo "[OK] AGENTS.md created from template: $AGENTS_OUT"
  fi
}

write_objective_contract() {
  local objective_brief_template=""
  local intent_contract_template=""

  if ! objective_contract_needs_write; then
    echo "[SKIP] Objective contract already exists: $OBJECTIVE_OUT and $INTENT_CONTRACT_OUT"
    return
  fi

  resolve_objective_selection
  objective_brief_template="$OBJECTIVE_TEMPLATE_ROOT/$SELECTED_OBJECTIVE_ID/OBJECTIVE.md"
  intent_contract_template="$OBJECTIVE_TEMPLATE_ROOT/$SELECTED_OBJECTIVE_ID/intent.contract.yml"

  echo "[INFO] Objective: $OBJECTIVE_LABEL ($SELECTED_OBJECTIVE_ID)"
  write_objective_file "$objective_brief_template" "$OBJECTIVE_OUT" "OBJECTIVE.md"
  write_objective_file "$intent_contract_template" "$INTENT_CONTRACT_OUT" "intent.contract.yml"
}

write_boot_files() {
  if [[ "$WITH_BOOT_FILES" -ne 1 ]]; then
    echo "[SKIP] BOOT/BOOTSTRAP templates not requested (use --with-boot-files)"
    return
  fi

  write_from_template "$BOOT_TEMPLATE_FILE" "$BOOT_OUT" "BOOT.md"
  write_from_template "$BOOTSTRAP_TEMPLATE_FILE" "$BOOTSTRAP_OUT" "BOOTSTRAP.md"
}

write_alignment_check_shim() {
  if [[ ! -f "$ALIGNMENT_CHECK_TEMPLATE_FILE" ]]; then
    echo "[WARN] Missing alignment-check template: $ALIGNMENT_CHECK_TEMPLATE_FILE"
    return
  fi

  if [[ -f "$ALIGNMENT_CHECK_OUT" && "$FORCE" -ne 1 ]]; then
    echo "[SKIP] alignment-check shim already exists: $ALIGNMENT_CHECK_OUT"
    return
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ -f "$ALIGNMENT_CHECK_OUT" ]]; then
      echo "[DRY] Would overwrite alignment-check shim from template: $ALIGNMENT_CHECK_OUT"
    else
      echo "[DRY] Would create alignment-check shim from template: $ALIGNMENT_CHECK_OUT"
    fi
    return
  fi

  cat "$ALIGNMENT_CHECK_TEMPLATE_FILE" > "$ALIGNMENT_CHECK_OUT"
  chmod +x "$ALIGNMENT_CHECK_OUT"

  if [[ "$FORCE" -eq 1 ]]; then
    echo "[OK] alignment-check shim overwritten from template: $ALIGNMENT_CHECK_OUT"
  else
    echo "[OK] alignment-check shim created from template: $ALIGNMENT_CHECK_OUT"
  fi
}

write_agent_platform_adapter_bootstrap() {
  if [[ "$WITH_AGENT_PLATFORM_ADAPTERS" -ne 1 ]]; then
    echo "[SKIP] Agent-platform adapter bootstrap not requested (use --with-agent-platform-adapters)"
    return
  fi

  if [[ ! -f "$ADAPTER_REGISTRY" ]]; then
    echo "[WARN] Adapter registry missing: $ADAPTER_REGISTRY"
    return
  fi

  local requested="$AGENT_PLATFORM_ADAPTERS"
  if [[ -z "$requested" ]]; then
    requested="openclaw"
  fi

  local available_ids=()
  mapfile -t available_ids < <(awk '
    /^[[:space:]]*-[[:space:]]id:/ {
      id=$3
      gsub(/["'\'' ]/, "", id)
      if (length(id) > 0) print id
    }
  ' "$ADAPTER_REGISTRY")

  if [[ ${#available_ids[@]} -eq 0 ]]; then
    echo "[WARN] No adapters discovered in registry: $ADAPTER_REGISTRY"
    return
  fi

  local selected_ids=()
  IFS=',' read -r -a selected_ids <<< "$requested"

  local i
  for i in "${!selected_ids[@]}"; do
    selected_ids[$i]="$(echo "${selected_ids[$i]}" | tr -d '[:space:]')"
  done

  local selected
  for selected in "${selected_ids[@]}"; do
    [[ -z "$selected" ]] && continue

    local found=0
    local available
    for available in "${available_ids[@]}"; do
      if [[ "$selected" == "$available" ]]; then
        found=1
        break
      fi
    done

    if [[ "$found" -ne 1 ]]; then
      echo "[ERROR] Unknown adapter id '$selected'. Available: ${available_ids[*]}" >&2
      exit 1
    fi
  done

  if [[ -f "$ADAPTER_ENABLED_OUT" && "$FORCE" -ne 1 ]]; then
    echo "[SKIP] Adapter enablement config already exists: $ADAPTER_ENABLED_OUT"
    return
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ -f "$ADAPTER_ENABLED_OUT" ]]; then
      echo "[DRY] Would overwrite adapter enablement config: $ADAPTER_ENABLED_OUT"
    else
      echo "[DRY] Would create adapter enablement config: $ADAPTER_ENABLED_OUT"
    fi
    return
  fi

  mkdir -p "$(dirname "$ADAPTER_ENABLED_OUT")"

  {
    echo "schema_version: \"1.0\""
    echo "interop_contract_version: \"1.0.0\""
    echo "mode: adapter"
    echo "native_fallback: true"
    echo "generated_by: init-project.sh"
    echo "generated_at: \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
    echo "enabled_adapters:"
    for selected in "${selected_ids[@]}"; do
      [[ -z "$selected" ]] && continue
      echo "  - id: $selected"
      echo "    enabled: true"
    done
  } > "$ADAPTER_ENABLED_OUT"

  if [[ "$FORCE" -eq 1 ]]; then
    echo "[OK] Adapter enablement config overwritten: $ADAPTER_ENABLED_OUT"
  else
    echo "[OK] Adapter enablement config created: $ADAPTER_ENABLED_OUT"
  fi
}

write_claude_alias() {
  if [[ "$LINK_CLAUDE" -ne 1 ]]; then
    echo "[SKIP] CLAUDE alias disabled by flag"
    return
  fi

  if [[ -L "$CLAUDE_OUT" ]]; then
    local target
    target="$(readlink "$CLAUDE_OUT")"
    if [[ "$target" == "AGENTS.md" ]]; then
      echo "[OK] CLAUDE.md alias already points to AGENTS.md"
    else
      echo "[WARN] CLAUDE.md symlink points to '$target'; leaving unchanged"
    fi
    return
  fi

  if [[ -e "$CLAUDE_OUT" ]]; then
    echo "[WARN] CLAUDE.md exists and is not a symlink; leaving unchanged"
    return
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY] Would create symlink CLAUDE.md -> AGENTS.md"
    return
  fi

  ln -s "AGENTS.md" "$CLAUDE_OUT"
  echo "[OK] Created CLAUDE.md symlink -> AGENTS.md"
}

if [[ "$LIST_OBJECTIVES" -eq 1 ]]; then
  print_available_objectives
  exit 0
fi

if [[ ! -d "$REPO_ROOT/.harmony" ]]; then
  echo "[ERROR] No .harmony directory found in repo root: $REPO_ROOT" >&2
  exit 1
fi

if [[ ! -f "$TEMPLATE_FILE" ]]; then
  echo "[ERROR] Missing AGENTS template: $TEMPLATE_FILE" >&2
  exit 1
fi

if [[ ! -f "$AGENCY_MANIFEST" ]]; then
  echo "[ERROR] Missing agency manifest: $AGENCY_MANIFEST" >&2
  exit 1
fi

if [[ ! -f "$OBJECTIVE_REGISTRY_FILE" ]]; then
  echo "[ERROR] Missing objective registry: $OBJECTIVE_REGISTRY_FILE" >&2
  exit 1
fi

if [[ -n "$SELECTED_OBJECTIVE_ID" ]] && ! objective_exists "$SELECTED_OBJECTIVE_ID"; then
  echo "[ERROR] Unknown objective '$SELECTED_OBJECTIVE_ID'. Use --list-objectives to inspect available options." >&2
  exit 1
fi

DEFAULT_AGENT="$(awk '/^default_agent:[[:space:]]*/ {print $2; exit}' "$AGENCY_MANIFEST" | tr -d '"')"
if [[ -z "$DEFAULT_AGENT" || "$DEFAULT_AGENT" == "null" ]]; then
  DEFAULT_AGENT="architect"
fi

if [[ -z "$OBJECTIVE_OWNER" ]]; then
  OBJECTIVE_OWNER="$(detect_default_actor)"
fi
if [[ -z "$OBJECTIVE_APPROVED_BY" ]]; then
  OBJECTIVE_APPROVED_BY="$OBJECTIVE_OWNER"
fi

DEFAULT_AGENT_EXECUTION_CONTRACT=".harmony/agency/runtime/agents/${DEFAULT_AGENT}/AGENT.md"
DEFAULT_AGENT_IDENTITY_CONTRACT=".harmony/agency/runtime/agents/${DEFAULT_AGENT}/SOUL.md"

if [[ ! -f "$REPO_ROOT/$DEFAULT_AGENT_EXECUTION_CONTRACT" ]]; then
  echo "[WARN] Missing execution contract for default agent: $DEFAULT_AGENT_EXECUTION_CONTRACT"
fi

if [[ ! -f "$REPO_ROOT/$DEFAULT_AGENT_IDENTITY_CONTRACT" ]]; then
  echo "[WARN] Missing identity contract for default agent: $DEFAULT_AGENT_IDENTITY_CONTRACT"
fi

echo "== Project Init =="
echo "Repo root: $REPO_ROOT"
echo "Default agent: $DEFAULT_AGENT"
echo ""

write_agents
write_objective_contract
write_boot_files
write_alignment_check_shim
write_agent_platform_adapter_bootstrap
write_claude_alias

echo ""
echo "Initialization complete."
