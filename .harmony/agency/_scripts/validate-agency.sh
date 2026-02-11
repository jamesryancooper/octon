#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
AGENCY_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$AGENCY_DIR/.." && pwd)"

MANIFEST="$AGENCY_DIR/manifest.yml"
AGENTS_REG="$AGENCY_DIR/agents/registry.yml"
ASSISTANTS_REG="$AGENCY_DIR/assistants/registry.yml"
TEAMS_REG="$AGENCY_DIR/teams/registry.yml"

errors=0
warnings=0

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

extract_id_path_pairs() {
  local file="$1"
  awk '
    /^[[:space:]]*-[[:space:]]+id:[[:space:]]*/ {
      id=$2
      sub(/^id:/, "", id)
      gsub(/"/, "", id)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", id)
      if (id == "") {
        id=$3
        gsub(/"/, "", id)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", id)
      }
      next
    }
    /^[[:space:]]*path:[[:space:]]*/ {
      path=$2
      gsub(/"/, "", path)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", path)
      if (id != "" && path != "") {
        print id "|" path
        id=""
      }
    }
  ' "$file"
}

extract_ids() {
  local file="$1"
  awk '
    /^[[:space:]]*-[[:space:]]+id:[[:space:]]*/ {
      id=$2
      sub(/^id:/, "", id)
      gsub(/"/, "", id)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", id)
      if (id == "") {
        id=$3
        gsub(/"/, "", id)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", id)
      }
      if (id != "") print id
    }
  ' "$file"
}

check_registry_paths() {
  local registry_file="$1"
  local kind="$2"
  local contract_file="$3"

  local pair_count=0
  while IFS='|' read -r id relpath; do
    [[ -z "$id" || -z "$relpath" ]] && continue
    relpath="${relpath%/}"
    pair_count=$((pair_count + 1))

    local actor_dir="$AGENCY_DIR/$kind/$relpath"
    local actor_file="$actor_dir/$contract_file"

    if [[ ! -d "$actor_dir" ]]; then
      fail "$kind registry entry '$id' points to missing directory: $actor_dir"
      continue
    fi

    if [[ ! -f "$actor_file" ]]; then
      fail "$kind registry entry '$id' missing contract file: $actor_file"
      continue
    fi

    pass "$kind/$id -> ${actor_file#$ROOT_DIR/}"
  done < <(extract_id_path_pairs "$registry_file")

  if [[ $pair_count -eq 0 ]]; then
    warn "$kind registry has no id/path entries"
  fi
}

check_unique_ids() {
  local registry_file="$1"
  local label="$2"

  local dupes
  dupes="$(extract_ids "$registry_file" | sort | uniq -d || true)"

  if [[ -n "$dupes" ]]; then
    while IFS= read -r d; do
      [[ -z "$d" ]] && continue
      fail "$label has duplicate id: $d"
    done <<< "$dupes"
  else
    pass "$label IDs are unique"
  fi
}

check_assistant_aliases() {
  local dupes
  dupes="$(awk '
    /aliases:[[:space:]]*\[/ {
      line=$0
      sub(/.*\[/, "", line)
      sub(/\].*/, "", line)
      n=split(line, arr, ",")
      for (i=1; i<=n; i++) {
        a=arr[i]
        gsub(/"/, "", a)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", a)
        if (a != "") print a
      }
    }
  ' "$ASSISTANTS_REG" | sort | uniq -d || true)"

  if [[ -n "$dupes" ]]; then
    while IFS= read -r alias; do
      [[ -z "$alias" ]] && continue
      fail "assistant alias collision: $alias"
    done <<< "$dupes"
  else
    pass "assistant aliases are unique"
  fi

  local bad_aliases
  bad_aliases="$(awk '
    /aliases:[[:space:]]*\[/ {
      line=$0
      sub(/.*\[/, "", line)
      sub(/\].*/, "", line)
      n=split(line, arr, ",")
      for (i=1; i<=n; i++) {
        a=arr[i]
        gsub(/"/, "", a)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", a)
        if (a != "" && substr(a,1,1) != "@") print a
      }
    }
  ' "$ASSISTANTS_REG" || true)"

  if [[ -n "$bad_aliases" ]]; then
    while IFS= read -r alias; do
      [[ -z "$alias" ]] && continue
      fail "assistant alias must start with '@': $alias"
    done <<< "$bad_aliases"
  else
    pass "assistant aliases use @-prefix"
  fi
}

check_manifest_links() {
  grep -q 'agents:\s*"agents/registry.yml"' "$MANIFEST" || fail "manifest missing agents registry link"
  grep -q 'assistants:\s*"assistants/registry.yml"' "$MANIFEST" || fail "manifest missing assistants registry link"
  grep -q 'teams:\s*"teams/registry.yml"' "$MANIFEST" || fail "manifest missing teams registry link"

  local default_agent
  default_agent="$(awk '/^default_agent:\s*/ {print $2}' "$MANIFEST" | tr -d '"')"
  if [[ -z "$default_agent" || "$default_agent" == "null" ]]; then
    fail "manifest default_agent is not set"
    return
  fi

  if ! extract_ids "$AGENTS_REG" | grep -qx "$default_agent"; then
    fail "manifest default_agent '$default_agent' not found in agents registry"
  else
    pass "manifest default_agent resolves to agents registry"
  fi
}

check_deprecations() {
  if [[ -d "$AGENCY_DIR/subagents" ]]; then
    fail "deprecated path exists: ${AGENCY_DIR#$ROOT_DIR/}/subagents"
  else
    pass "deprecated subagents path removed"
  fi

  if grep -q 'agency/subagents/' "$ROOT_DIR/harmony.yml"; then
    fail "harmony.yml still exports deprecated agency/subagents path"
  else
    pass "harmony.yml portable paths do not include deprecated subagents"
  fi
}

main() {
  echo "== Agency Validation =="

  require_file "$MANIFEST"
  require_file "$AGENTS_REG"
  require_file "$ASSISTANTS_REG"
  require_file "$TEAMS_REG"

  check_manifest_links

  check_unique_ids "$AGENTS_REG" "agents registry"
  check_unique_ids "$ASSISTANTS_REG" "assistants registry"
  check_unique_ids "$TEAMS_REG" "teams registry"

  check_registry_paths "$AGENTS_REG" "agents" "agent.md"
  check_registry_paths "$ASSISTANTS_REG" "assistants" "assistant.md"
  check_registry_paths "$TEAMS_REG" "teams" "team.md"

  check_assistant_aliases
  check_deprecations

  echo ""
  echo "Validation summary: errors=$errors warnings=$warnings"

  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
