#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HARMONY_DIR="$(cd -- "$SCRIPT_DIR/../../../.." && pwd)"
DEFAULT_REPO_ROOT="$(cd -- "$HARMONY_DIR/.." && pwd)"

REPO_ROOT="$DEFAULT_REPO_ROOT"
FORCE=0
DRY_RUN=0
LINK_CLAUDE=1
WITH_BOOT_FILES=0
WITH_AGENT_PLATFORM_ADAPTERS=0
AGENT_PLATFORM_ADAPTERS=""

usage() {
  cat <<'USAGE'
Usage: init-project.sh [--repo-root <path>] [--force] [--dry-run] [--no-claude-alias] [--with-boot-files] [--with-agent-platform-adapters] [--agent-platform-adapters <csv>]

Initializes project-level bootstrap files from .harmony templates.
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
AGENCY_MANIFEST="$HARMONY_DIR/agency/manifest.yml"
AGENTS_OUT="$REPO_ROOT/AGENTS.md"
CLAUDE_OUT="$REPO_ROOT/CLAUDE.md"
BOOT_OUT="$REPO_ROOT/BOOT.md"
BOOTSTRAP_OUT="$REPO_ROOT/BOOTSTRAP.md"
ADAPTER_REGISTRY="$REPO_ROOT/.harmony/capabilities/runtime/services/interfaces/agent-platform/adapters/registry.yml"
ADAPTER_ENABLED_OUT="$REPO_ROOT/.harmony/capabilities/runtime/services/interfaces/agent-platform/adapters/enabled.yml"

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

DEFAULT_AGENT="$(awk '/^default_agent:[[:space:]]*/ {print $2; exit}' "$AGENCY_MANIFEST" | tr -d '"')"
if [[ -z "$DEFAULT_AGENT" || "$DEFAULT_AGENT" == "null" ]]; then
  DEFAULT_AGENT="architect"
fi

DEFAULT_AGENT_EXECUTION_CONTRACT=".harmony/agency/runtime/agents/${DEFAULT_AGENT}/AGENT.md"
DEFAULT_AGENT_IDENTITY_CONTRACT=".harmony/agency/runtime/agents/${DEFAULT_AGENT}/SOUL.md"

if [[ ! -f "$REPO_ROOT/$DEFAULT_AGENT_EXECUTION_CONTRACT" ]]; then
  echo "[WARN] Missing execution contract for default agent: $DEFAULT_AGENT_EXECUTION_CONTRACT"
fi

if [[ ! -f "$REPO_ROOT/$DEFAULT_AGENT_IDENTITY_CONTRACT" ]]; then
  echo "[WARN] Missing identity contract for default agent: $DEFAULT_AGENT_IDENTITY_CONTRACT"
fi

render_template() {
  sed \
    -e "s|{{DEFAULT_AGENT}}|$DEFAULT_AGENT|g" \
    -e "s|{{DEFAULT_AGENT_EXECUTION_CONTRACT}}|$DEFAULT_AGENT_EXECUTION_CONTRACT|g" \
    -e "s|{{DEFAULT_AGENT_IDENTITY_CONTRACT}}|$DEFAULT_AGENT_IDENTITY_CONTRACT|g" \
    "$TEMPLATE_FILE"
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

write_agents() {
  if [[ -f "$AGENTS_OUT" && "$FORCE" -ne 1 ]]; then
    echo "[SKIP] AGENTS.md already exists: $AGENTS_OUT"
    return
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    if [[ -f "$AGENTS_OUT" ]]; then
      echo "[DRY] Would overwrite AGENTS.md from template: $AGENTS_OUT"
    else
      echo "[DRY] Would create AGENTS.md from template: $AGENTS_OUT"
    fi
    return
  fi

  render_template > "$AGENTS_OUT"
  if [[ "$FORCE" -eq 1 ]]; then
    echo "[OK] AGENTS.md overwritten from template: $AGENTS_OUT"
  else
    echo "[OK] AGENTS.md created from template: $AGENTS_OUT"
  fi
}

write_boot_files() {
  if [[ "$WITH_BOOT_FILES" -ne 1 ]]; then
    echo "[SKIP] BOOT/BOOTSTRAP templates not requested (use --with-boot-files)"
    return
  fi

  write_from_template "$BOOT_TEMPLATE_FILE" "$BOOT_OUT" "BOOT.md"
  write_from_template "$BOOTSTRAP_TEMPLATE_FILE" "$BOOTSTRAP_OUT" "BOOTSTRAP.md"
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

echo "== Project Init =="
echo "Repo root: $REPO_ROOT"
echo "Default agent: $DEFAULT_AGENT"
echo ""

write_agents
write_boot_files
write_agent_platform_adapter_bootstrap
write_claude_alias

echo ""
echo "Initialization complete."
