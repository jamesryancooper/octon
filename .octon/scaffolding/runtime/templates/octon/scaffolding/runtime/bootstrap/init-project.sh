#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
DEFAULT_REPO_ROOT="$(cd -- "$OCTON_DIR/.." && pwd)"
DEFAULT_OBJECTIVE_ID="general-purpose"
OBJECTIVE_BRIEF_SCHEMA_VERSION="objective-brief-v1"

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
OBJECTIVE_OWNER_EXPLICIT=0
OBJECTIVE_APPROVED_BY=""
OBJECTIVE_APPROVED_BY_EXPLICIT=0
INTENT_ID=""
INTENT_VERSION=""

usage() {
  cat <<'USAGE'
Usage: init-project.sh [--repo-root <path>] [--force] [--dry-run] [--list-objectives] [--objective <id>] [--objective-owner <name>] [--objective-approved-by <name>] [--no-claude-alias] [--with-boot-files] [--with-agent-platform-adapters] [--agent-platform-adapters <csv>]

Initializes canonical Octon bootstrap files and objective-contract artifacts.
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
      OBJECTIVE_OWNER_EXPLICIT=1
      ;;
    --objective-approved-by)
      shift
      [[ $# -gt 0 ]] || { echo "[ERROR] --objective-approved-by requires a value" >&2; exit 1; }
      OBJECTIVE_APPROVED_BY="$1"
      OBJECTIVE_APPROVED_BY_EXPLICIT=1
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
BOOTSTRAP_DIR="$OCTON_DIR/scaffolding/runtime/bootstrap"
AGENTS_TEMPLATE_FILE="$BOOTSTRAP_DIR/AGENTS.md"
BOOT_TEMPLATE_FILE="$BOOTSTRAP_DIR/BOOT.md"
BOOTSTRAP_TEMPLATE_FILE="$BOOTSTRAP_DIR/BOOTSTRAP.md"
ALIGNMENT_CHECK_TEMPLATE_FILE="$BOOTSTRAP_DIR/alignment-check"
OBJECTIVE_TEMPLATE_ROOT="$BOOTSTRAP_DIR/objectives"
OBJECTIVE_REGISTRY_FILE="$OBJECTIVE_TEMPLATE_ROOT/registry.txt"
AGENCY_MANIFEST="$OCTON_DIR/agency/manifest.yml"
CANONICAL_AGENTS_OUT="$REPO_ROOT/.octon/AGENTS.md"
ROOT_AGENTS_OUT="$REPO_ROOT/AGENTS.md"
CLAUDE_OUT="$REPO_ROOT/CLAUDE.md"
BOOT_OUT="$REPO_ROOT/BOOT.md"
BOOTSTRAP_OUT="$REPO_ROOT/BOOTSTRAP.md"
ALIGNMENT_CHECK_OUT="$REPO_ROOT/alignment-check"
OBJECTIVE_OUT="$REPO_ROOT/.octon/OBJECTIVE.md"
LEGACY_OBJECTIVE_OUT="$REPO_ROOT/OBJECTIVE.md"
INTENT_CONTRACT_OUT="$REPO_ROOT/.octon/cognition/runtime/context/intent.contract.yml"
ADAPTER_REGISTRY="$REPO_ROOT/.octon/capabilities/runtime/services/interfaces/agent-platform/adapters/registry.yml"
ADAPTER_ENABLED_OUT="$REPO_ROOT/.octon/capabilities/runtime/services/interfaces/agent-platform/adapters/enabled.yml"
CONTEXT_POLICY_FILE="$OCTON_DIR/capabilities/governance/policy/deny-by-default.v2.yml"
GENERATED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
REPO_NAME="$(basename "$REPO_ROOT")"
CANONICAL_INGRESS_TARGET=".octon/AGENTS.md"

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

frontmatter_field() {
  local file_path="$1"
  local key="$2"
  awk -v key="$key" '
    NR == 1 && $0 == "---" {in_frontmatter=1; next}
    in_frontmatter && $0 == "---" {exit}
    in_frontmatter && $0 ~ "^[[:space:]]*" key ":[[:space:]]*" {
      line=$0
      sub("^[[:space:]]*" key ":[[:space:]]*", "", line)
      sub(/[[:space:]]+#.*/, "", line)
      gsub(/^"/, "", line)
      gsub(/"$/, "", line)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
      print line
      exit
    }
  ' "$file_path"
}

yaml_scalar_field() {
  local file_path="$1"
  local key="$2"
  awk -v key="$key" '
    $0 ~ "^[[:space:]]*" key ":[[:space:]]*" {
      line=$0
      sub("^[[:space:]]*" key ":[[:space:]]*", "", line)
      sub(/[[:space:]]+#.*/, "", line)
      gsub(/^"/, "", line)
      gsub(/"$/, "", line)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
      print line
      exit
    }
  ' "$file_path"
}

objective_id_from_intent_id() {
  local intent_id="$1"
  printf '%s\n' "${intent_id##*/}"
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

intent_version_from_template() {
  local template_path="$1"
  awk '
    /^version:[[:space:]]*/ {
      value=$2
      gsub(/"/, "", value)
      print value
      exit
    }
  ' "$template_path"
}

hydrate_from_existing_objective_contract() {
  local existing_objective_id=""
  local existing_owner=""
  local existing_approved_by=""
  local existing_intent_id=""

  if [[ -f "$OBJECTIVE_OUT" ]]; then
    existing_objective_id="$(frontmatter_field "$OBJECTIVE_OUT" "objective_id")"
    existing_owner="$(frontmatter_field "$OBJECTIVE_OUT" "owner")"
    existing_approved_by="$(frontmatter_field "$OBJECTIVE_OUT" "approved_by")"
    existing_intent_id="$(frontmatter_field "$OBJECTIVE_OUT" "intent_id")"
  fi

  if [[ -z "$existing_intent_id" && -f "$INTENT_CONTRACT_OUT" ]]; then
    existing_intent_id="$(yaml_scalar_field "$INTENT_CONTRACT_OUT" "intent_id")"
  fi

  if [[ -z "$existing_objective_id" && -n "$existing_intent_id" ]]; then
    existing_objective_id="$(objective_id_from_intent_id "$existing_intent_id")"
  fi

  if [[ -z "$existing_owner" && -f "$INTENT_CONTRACT_OUT" ]]; then
    existing_owner="$(yaml_scalar_field "$INTENT_CONTRACT_OUT" "owner")"
  fi

  if [[ -z "$existing_approved_by" && -f "$INTENT_CONTRACT_OUT" ]]; then
    existing_approved_by="$(yaml_scalar_field "$INTENT_CONTRACT_OUT" "approved_by")"
  fi

  if [[ -z "$SELECTED_OBJECTIVE_ID" && -n "$existing_objective_id" ]] && objective_exists "$existing_objective_id"; then
    SELECTED_OBJECTIVE_ID="$existing_objective_id"
  fi
  if [[ "$OBJECTIVE_OWNER_EXPLICIT" -ne 1 && -z "$OBJECTIVE_OWNER" && -n "$existing_owner" ]]; then
    OBJECTIVE_OWNER="$existing_owner"
  fi
  if [[ "$OBJECTIVE_APPROVED_BY_EXPLICIT" -ne 1 && -z "$OBJECTIVE_APPROVED_BY" && -n "$existing_approved_by" ]]; then
    OBJECTIVE_APPROVED_BY="$existing_approved_by"
  fi
}

classify_objective_contract_state() {
  local objective_exists_on_disk=0
  local intent_exists_on_disk=0
  local objective_schema=""
  local objective_id=""
  local objective_intent_id=""
  local objective_intent_version=""
  local objective_owner=""
  local objective_approved_by=""
  local intent_schema=""
  local intent_id=""
  local intent_version=""
  local intent_owner=""
  local intent_approved_by=""

  [[ -f "$OBJECTIVE_OUT" ]] && objective_exists_on_disk=1
  [[ -f "$INTENT_CONTRACT_OUT" ]] && intent_exists_on_disk=1

  if [[ "$objective_exists_on_disk" -eq 0 && "$intent_exists_on_disk" -eq 0 ]]; then
    printf 'missing\n'
    return
  fi

  if [[ "$objective_exists_on_disk" -eq 0 || "$intent_exists_on_disk" -eq 0 ]]; then
    printf 'partial\n'
    return
  fi

  objective_schema="$(frontmatter_field "$OBJECTIVE_OUT" "schema_version")"
  objective_id="$(frontmatter_field "$OBJECTIVE_OUT" "objective_id")"
  objective_intent_id="$(frontmatter_field "$OBJECTIVE_OUT" "intent_id")"
  objective_intent_version="$(frontmatter_field "$OBJECTIVE_OUT" "intent_version")"
  objective_owner="$(frontmatter_field "$OBJECTIVE_OUT" "owner")"
  objective_approved_by="$(frontmatter_field "$OBJECTIVE_OUT" "approved_by")"

  intent_schema="$(yaml_scalar_field "$INTENT_CONTRACT_OUT" "schema_version")"
  intent_id="$(yaml_scalar_field "$INTENT_CONTRACT_OUT" "intent_id")"
  intent_version="$(yaml_scalar_field "$INTENT_CONTRACT_OUT" "version")"
  intent_owner="$(yaml_scalar_field "$INTENT_CONTRACT_OUT" "owner")"
  intent_approved_by="$(yaml_scalar_field "$INTENT_CONTRACT_OUT" "approved_by")"

  if [[ "$objective_schema" != "$OBJECTIVE_BRIEF_SCHEMA_VERSION" || "$intent_schema" != "intent-contract-v1" ]]; then
    printf 'invalid\n'
    return
  fi
  if [[ -z "$objective_id" || -z "$objective_intent_id" || -z "$objective_intent_version" || -z "$objective_owner" || -z "$objective_approved_by" ]]; then
    printf 'invalid\n'
    return
  fi
  if [[ -z "$intent_id" || -z "$intent_version" || -z "$intent_owner" || -z "$intent_approved_by" ]]; then
    printf 'invalid\n'
    return
  fi
  if [[ "$objective_intent_id" != "$intent_id" || "$objective_intent_version" != "$intent_version" ]]; then
    printf 'invalid\n'
    return
  fi
  if [[ "$objective_owner" != "$intent_owner" || "$objective_approved_by" != "$intent_approved_by" ]]; then
    printf 'invalid\n'
    return
  fi
  if [[ -n "$SELECTED_OBJECTIVE_ID" && "$SELECTED_OBJECTIVE_ID" != "$objective_id" ]]; then
    printf 'invalid\n'
    return
  fi
  if [[ "$OBJECTIVE_OWNER_EXPLICIT" -eq 1 && "$OBJECTIVE_OWNER" != "$objective_owner" ]]; then
    printf 'invalid\n'
    return
  fi
  if [[ "$OBJECTIVE_APPROVED_BY_EXPLICIT" -eq 1 && "$OBJECTIVE_APPROVED_BY" != "$objective_approved_by" ]]; then
    printf 'invalid\n'
    return
  fi

  printf 'aligned\n'
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

  echo "Select a Octon objective for this workspace:"
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

  hydrate_from_existing_objective_contract

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
    "$AGENTS_TEMPLATE_FILE"
}

render_objective_template() {
  local template_path="$1"
  local escaped_repo_name escaped_objective_id escaped_objective_label
  local escaped_objective_summary escaped_intent_id escaped_intent_version escaped_owner
  local escaped_approved_by escaped_generated_at escaped_schema_version

  escaped_repo_name="$(escape_sed_replacement "$REPO_NAME")"
  escaped_objective_id="$(escape_sed_replacement "$SELECTED_OBJECTIVE_ID")"
  escaped_objective_label="$(escape_sed_replacement "$OBJECTIVE_LABEL")"
  escaped_objective_summary="$(escape_sed_replacement "$OBJECTIVE_SUMMARY")"
  escaped_intent_id="$(escape_sed_replacement "$INTENT_ID")"
  escaped_intent_version="$(escape_sed_replacement "$INTENT_VERSION")"
  escaped_owner="$(escape_sed_replacement "$OBJECTIVE_OWNER")"
  escaped_approved_by="$(escape_sed_replacement "$OBJECTIVE_APPROVED_BY")"
  escaped_generated_at="$(escape_sed_replacement "$GENERATED_AT")"
  escaped_schema_version="$(escape_sed_replacement "$OBJECTIVE_BRIEF_SCHEMA_VERSION")"

  sed \
    -e "s|{{REPO_NAME}}|$escaped_repo_name|g" \
    -e "s|{{OBJECTIVE_ID}}|$escaped_objective_id|g" \
    -e "s|{{OBJECTIVE_LABEL}}|$escaped_objective_label|g" \
    -e "s|{{OBJECTIVE_SUMMARY}}|$escaped_objective_summary|g" \
    -e "s|{{OBJECTIVE_BRIEF_SCHEMA_VERSION}}|$escaped_schema_version|g" \
    -e "s|{{INTENT_ID}}|$escaped_intent_id|g" \
    -e "s|{{INTENT_VERSION}}|$escaped_intent_version|g" \
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

  mapfile -t allowed_sections < <(read_context_gate_allowed_sections)
  max_bytes="$(read_context_gate_max_value "max_bytes")"
  max_sections="$(read_context_gate_max_value "max_sections")"

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
  local existed=0

  [[ -f "$output_path" ]] && existed=1
  if [[ "$existed" -eq 1 && "$FORCE" -ne 1 ]]; then
    echo "[SKIP] ${label} already exists: $output_path"
    return
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ "$existed" -eq 1 ]]; then
      echo "[DRY] Would overwrite ${label} from template: $output_path"
    else
      echo "[DRY] Would create ${label} from template: $output_path"
    fi
    return
  fi

  mkdir -p "$(dirname "$output_path")"
  cat "$template_path" > "$output_path"
  if [[ "$existed" -eq 1 ]]; then
    echo "[OK] ${label} overwritten from template: $output_path"
  else
    echo "[OK] ${label} created from template: $output_path"
  fi
}

write_objective_file() {
  local template_path="$1"
  local output_path="$2"
  local label="$3"
  local existed=0
  local tmp_output=""

  [[ -f "$output_path" ]] && existed=1
  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ "$existed" -eq 1 ]]; then
      echo "[DRY] Would overwrite ${label} from template: $output_path"
    else
      echo "[DRY] Would create ${label} from template: $output_path"
    fi
    return
  fi

  mkdir -p "$(dirname "$output_path")"
  tmp_output="$(mktemp "${TMPDIR:-/tmp}/octon-init-objective.XXXXXX")"
  render_objective_template "$template_path" > "$tmp_output"
  mv "$tmp_output" "$output_path"
  if [[ "$existed" -eq 1 ]]; then
    echo "[OK] ${label} overwritten from template: $output_path"
  else
    echo "[OK] ${label} created from template: $output_path"
  fi
}

write_canonical_agents() {
  local existed=0
  local tmp_agents=""

  [[ -f "$CANONICAL_AGENTS_OUT" ]] && existed=1
  if [[ "$existed" -eq 1 && "$FORCE" -ne 1 ]]; then
    echo "[SKIP] .octon/AGENTS.md already exists: $CANONICAL_AGENTS_OUT"
    return
  fi

  tmp_agents="$(mktemp "${TMPDIR:-/tmp}/octon-init-agents.XXXXXX.md")"
  render_agents_template > "$tmp_agents"
  if ! validate_generated_agents_file "$tmp_agents"; then
    rm -f "$tmp_agents"
    echo "[ERROR] Refusing to write non-compliant .octon/AGENTS.md from template" >&2
    exit 1
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ "$existed" -eq 1 ]]; then
      echo "[DRY] Would overwrite .octon/AGENTS.md from template: $CANONICAL_AGENTS_OUT"
    else
      echo "[DRY] Would create .octon/AGENTS.md from template: $CANONICAL_AGENTS_OUT"
    fi
    rm -f "$tmp_agents"
    return
  fi

  mkdir -p "$(dirname "$CANONICAL_AGENTS_OUT")"
  mv "$tmp_agents" "$CANONICAL_AGENTS_OUT"
  if [[ "$existed" -eq 1 ]]; then
    echo "[OK] .octon/AGENTS.md overwritten from template: $CANONICAL_AGENTS_OUT"
  else
    echo "[OK] .octon/AGENTS.md created from template: $CANONICAL_AGENTS_OUT"
  fi
}

sync_ingress_adapter() {
  local output_path="$1"
  local label="$2"
  local existing_target=""

  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ -L "$output_path" ]]; then
      existing_target="$(readlink "$output_path")"
      if [[ "$existing_target" == "$CANONICAL_INGRESS_TARGET" ]]; then
        echo "[OK] ${label} adapter already points to ${CANONICAL_INGRESS_TARGET}"
      else
        echo "[DRY] Would repoint ${label} adapter to ${CANONICAL_INGRESS_TARGET}: $output_path"
      fi
      return
    fi
    if [[ -e "$output_path" ]]; then
      echo "[DRY] Would replace ${label} adapter with link or parity copy: $output_path"
    else
      echo "[DRY] Would create ${label} adapter to ${CANONICAL_INGRESS_TARGET}: $output_path"
    fi
    return
  fi

  if [[ -L "$output_path" ]]; then
    existing_target="$(readlink "$output_path")"
    if [[ "$existing_target" == "$CANONICAL_INGRESS_TARGET" ]]; then
      echo "[OK] ${label} adapter already points to ${CANONICAL_INGRESS_TARGET}"
      return
    fi
  fi

  if [[ -e "$output_path" || -L "$output_path" ]]; then
    rm -f "$output_path"
  fi

  if ln -s "$CANONICAL_INGRESS_TARGET" "$output_path" 2>/dev/null; then
    echo "[OK] ${label} adapter now points to ${CANONICAL_INGRESS_TARGET}: $output_path"
  else
    cat "$CANONICAL_AGENTS_OUT" > "$output_path"
    echo "[OK] ${label} adapter materialized as parity copy of ${CANONICAL_AGENTS_OUT}: $output_path"
  fi
}

sync_root_ingress_adapters() {
  sync_ingress_adapter "$ROOT_AGENTS_OUT" "AGENTS.md"
  if [[ "$LINK_CLAUDE" -ne 1 ]]; then
    echo "[WARN] --no-claude-alias is ignored; CLAUDE.md remains a required ingress adapter"
  fi
  sync_ingress_adapter "$CLAUDE_OUT" "CLAUDE.md"
}

write_objective_contract() {
  local state=""
  local objective_brief_template=""
  local intent_contract_template=""

  if [[ "$FORCE" -ne 1 ]]; then
    state="$(classify_objective_contract_state)"
    case "$state" in
      aligned)
        echo "[SKIP] Objective contract already exists and is aligned: $OBJECTIVE_OUT and $INTENT_CONTRACT_OUT"
        return
        ;;
      partial)
        echo "[INFO] Partial objective contract detected; rewriting both artifacts together."
        ;;
      invalid)
        echo "[ERROR] Objective contract diverges or is structurally invalid. Rerun with --force to rewrite both artifacts together." >&2
        exit 1
        ;;
    esac
  fi

  resolve_objective_selection
  objective_brief_template="$OBJECTIVE_TEMPLATE_ROOT/$SELECTED_OBJECTIVE_ID/OBJECTIVE.md"
  intent_contract_template="$OBJECTIVE_TEMPLATE_ROOT/$SELECTED_OBJECTIVE_ID/intent.contract.yml"
  INTENT_VERSION="$(intent_version_from_template "$intent_contract_template")"
  if [[ -z "$INTENT_VERSION" ]]; then
    echo "[ERROR] Unable to resolve intent contract version from template: $intent_contract_template" >&2
    exit 1
  fi

  echo "[INFO] Objective: $OBJECTIVE_LABEL ($SELECTED_OBJECTIVE_ID)"
  write_objective_file "$objective_brief_template" "$OBJECTIVE_OUT" ".octon/OBJECTIVE.md"
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

remove_legacy_root_objective() {
  if [[ ! -e "$LEGACY_OBJECTIVE_OUT" && ! -L "$LEGACY_OBJECTIVE_OUT" ]]; then
    return
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[DRY] Would remove deprecated root OBJECTIVE.md: $LEGACY_OBJECTIVE_OUT"
    return
  fi

  rm -f "$LEGACY_OBJECTIVE_OUT"
  echo "[OK] Removed deprecated root OBJECTIVE.md: $LEGACY_OBJECTIVE_OUT"
}

write_alignment_check_shim() {
  write_from_template "$ALIGNMENT_CHECK_TEMPLATE_FILE" "$ALIGNMENT_CHECK_OUT" "alignment-check shim"
  if [[ "$DRY_RUN" -ne 1 && -f "$ALIGNMENT_CHECK_OUT" ]]; then
    chmod +x "$ALIGNMENT_CHECK_OUT"
  fi
}

write_agent_platform_adapter_bootstrap() {
  local requested
  local available_ids=()
  local selected_ids=()
  local i selected available found

  if [[ "$WITH_AGENT_PLATFORM_ADAPTERS" -ne 1 ]]; then
    echo "[SKIP] Agent-platform adapter bootstrap not requested (use --with-agent-platform-adapters)"
    return
  fi

  if [[ ! -f "$ADAPTER_REGISTRY" ]]; then
    echo "[WARN] Adapter registry missing: $ADAPTER_REGISTRY"
    return
  fi

  requested="$AGENT_PLATFORM_ADAPTERS"
  if [[ -z "$requested" ]]; then
    requested="openclaw"
  fi

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

  IFS=',' read -r -a selected_ids <<< "$requested"
  for i in "${!selected_ids[@]}"; do
    selected_ids[$i]="$(echo "${selected_ids[$i]}" | tr -d '[:space:]')"
  done

  for selected in "${selected_ids[@]}"; do
    [[ -z "$selected" ]] && continue
    found=0
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
  echo "[OK] Adapter enablement config created: $ADAPTER_ENABLED_OUT"
}

if [[ "$LIST_OBJECTIVES" -eq 1 ]]; then
  print_available_objectives
  exit 0
fi

if [[ ! -d "$REPO_ROOT/.octon" ]]; then
  echo "[ERROR] No .octon directory found in repo root: $REPO_ROOT" >&2
  exit 1
fi

if [[ ! -f "$AGENTS_TEMPLATE_FILE" ]]; then
  echo "[ERROR] Missing AGENTS template: $AGENTS_TEMPLATE_FILE" >&2
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

DEFAULT_AGENT_EXECUTION_CONTRACT=".octon/agency/runtime/agents/${DEFAULT_AGENT}/AGENT.md"
DEFAULT_AGENT_IDENTITY_CONTRACT=".octon/agency/runtime/agents/${DEFAULT_AGENT}/SOUL.md"

echo "== Project Init =="
echo "Repo root: $REPO_ROOT"
echo "Default agent: $DEFAULT_AGENT"
echo ""

write_canonical_agents
write_objective_contract
remove_legacy_root_objective
sync_root_ingress_adapters
write_boot_files
write_alignment_check_shim
write_agent_platform_adapter_bootstrap

echo ""
echo "Initialization complete."
