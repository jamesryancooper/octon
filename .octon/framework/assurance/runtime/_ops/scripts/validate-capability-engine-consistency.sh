#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
OCTON_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

POLICY_FILE="$OCTON_DIR/capabilities/governance/policy/deny-by-default.v2.yml"
ENGINE_POLICY_LIB="$OCTON_DIR/engine/runtime/crates/policy_engine/src/lib.rs"
ENGINE_POLICY_CLI="$OCTON_DIR/engine/runtime/crates/policy_engine/src/bin/policy.rs"
ENGINE_POLICY_SPEC="$OCTON_DIR/engine/runtime/spec/policy-interface-v1.md"
CAPABILITIES_OPS_DIR="$OCTON_DIR/capabilities/_ops/scripts"

errors=0

declare -A ENGINE_TOOL_TOKENS=()
declare -A ENGINE_INTERFACE_COMMANDS=()
HAS_RG=0

if command -v rg >/dev/null 2>&1; then
  HAS_RG=1
fi

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
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

list_capability_runner_commands() {
  if [[ "$HAS_RG" -eq 1 ]]; then
    rg -No '"\$POLICY_RUNNER"[[:space:]]+[a-z-]+' "$CAPABILITIES_OPS_DIR" --glob '*.sh' \
      | awk '{print $NF}' \
      | sort -u
  else
    grep -RhoE --include='*.sh' '"\$POLICY_RUNNER"[[:space:]]+[a-z-]+' "$CAPABILITIES_OPS_DIR" \
      | awk '{print $NF}' \
      | sort -u
  fi
}

search_engine_internal_refs() {
  if [[ "$HAS_RG" -eq 1 ]]; then
    rg -n --no-heading -e 'runtime-crates-target/debug/octon-policy|engine/runtime/crates/policy_engine' \
      "$CAPABILITIES_OPS_DIR" \
      --glob '*.sh' || true
  else
    grep -RInE --include='*.sh' 'runtime-crates-target/debug/octon-policy|engine/runtime/crates/policy_engine' \
      "$CAPABILITIES_OPS_DIR" || true
  fi
}

load_engine_tool_tokens() {
  while IFS= read -r token; do
    [[ -z "$token" ]] && continue
    ENGINE_TOOL_TOKENS["$token"]=1
  done < <(
    awk '
      /^pub const ALLOWED_ATOM_TOOLS/ {in_list=1; next}
      in_list && /];/ {in_list=0; next}
      in_list {
        line=$0
        if (index(line, "\"") == 0) next
        sub(/^[^"]*"/, "", line)
        sub(/".*$/, "", line)
        if (line != "") print line
      }
    ' "$ENGINE_POLICY_LIB"
  )

  if [[ "${#ENGINE_TOOL_TOKENS[@]}" -eq 0 ]]; then
    fail "unable to load engine-enforced tool tokens from ${ENGINE_POLICY_LIB#$ROOT_DIR/}"
  else
    pass "loaded engine-enforced tool tokens (${#ENGINE_TOOL_TOKENS[@]})"
  fi
}

canonical_token_root() {
  local token="$1"
  if [[ "$token" == *"("* ]]; then
    printf '%s\n' "${token%%(*}"
    return 0
  fi
  printf '%s\n' "$token"
}

check_policy_tool_tokens() {
  local token root
  local checked=0

  while IFS= read -r token; do
    [[ -z "$token" ]] && continue
    root="$(canonical_token_root "$token")"
    checked=$((checked + 1))
    if [[ -z "${ENGINE_TOOL_TOKENS[$root]:-}" ]]; then
      fail "capability policy token '$token' resolves to root '$root' not enforced by engine runtime"
    fi
  done < <(
    awk '
      /tool_bundle:[[:space:]]*\[/ {
        line=$0
        sub(/^.*\[/, "", line)
        sub(/\].*$/, "", line)
        split(line, parts, ",")
        for (i in parts) {
          token=parts[i]
          gsub(/["\047[:space:]]/, "", token)
          if (token != "") print token
        }
      }
    ' "$POLICY_FILE" | sort -u
  )

  if [[ "$checked" -eq 0 ]]; then
    fail "no profile tool_bundle tokens parsed from ${POLICY_FILE#$ROOT_DIR/}"
  elif [[ "$errors" -eq 0 ]]; then
    pass "capability tool bundle tokens align with engine-enforced token roots"
  fi
}

load_engine_interface_commands() {
  while IFS= read -r command; do
    [[ -z "$command" ]] && continue
    ENGINE_INTERFACE_COMMANDS["$command"]=1
  done < <(
    awk '
      /^## Supported Command Surface/ {in_section=1; next}
      in_section && /^## / {in_section=0}
      in_section && $1 == "-" && $2 ~ /^`/ {
        cmd=$2
        gsub(/`/, "", cmd)
        if (cmd !~ /^--/) print cmd
      }
    ' "$ENGINE_POLICY_SPEC"
  )

  if [[ "${#ENGINE_INTERFACE_COMMANDS[@]}" -eq 0 ]]; then
    fail "unable to load engine policy interface commands from ${ENGINE_POLICY_SPEC#$ROOT_DIR/}"
    return
  fi
  pass "loaded engine policy interface commands (${#ENGINE_INTERFACE_COMMANDS[@]})"
}

to_cli_variant() {
  local command="$1"
  awk -v raw="$command" '
    BEGIN {
      n = split(raw, parts, "-")
      out = ""
      for (i = 1; i <= n; i++) {
        part = parts[i]
        out = out toupper(substr(part, 1, 1)) substr(part, 2)
      }
      print out
    }
  '
}

check_interface_spec_matches_cli() {
  local command variant
  for command in "${!ENGINE_INTERFACE_COMMANDS[@]}"; do
    variant="$(to_cli_variant "$command")"
    if matches_file_regex "^[[:space:]]*${variant}\\(" "$ENGINE_POLICY_CLI"; then
      :
    else
      fail "engine interface command '$command' missing CLI variant '$variant' in ${ENGINE_POLICY_CLI#$ROOT_DIR/}"
    fi
  done

  if [[ "$errors" -eq 0 ]]; then
    pass "engine policy interface spec matches CLI command surface"
  fi
}

check_capability_interface_usage() {
  local command
  local used=0

  while IFS= read -r command; do
    [[ -z "$command" ]] && continue
    used=$((used + 1))
    if [[ -z "${ENGINE_INTERFACE_COMMANDS[$command]:-}" ]]; then
      fail "capability script command '$command' is not declared in engine policy interface spec"
    fi
  done < <(list_capability_runner_commands)

  if [[ "$used" -eq 0 ]]; then
    fail "no capability policy runner command usage found under ${CAPABILITIES_OPS_DIR#$ROOT_DIR/}"
  elif [[ "$errors" -eq 0 ]]; then
    pass "capability scripts use only engine-declared policy interface commands"
  fi
}

check_no_engine_internal_runner_references() {
  local hits
  hits="$(search_engine_internal_refs)"
  if [[ -n "$hits" ]]; then
    fail "capability scripts reference engine implementation internals instead of engine/runtime/policy launcher"
    printf '%s\n' "$hits"
  else
    pass "capability scripts avoid engine implementation internals"
  fi
}

main() {
  echo "== Capability/Engine Consistency Validation =="
  load_engine_tool_tokens
  check_policy_tool_tokens
  load_engine_interface_commands
  check_interface_spec_matches_cli
  check_capability_interface_usage
  check_no_engine_internal_runner_references

  echo
  if [[ "$errors" -gt 0 ]]; then
    echo "[FAIL] capability/engine consistency validation failed with $errors error(s)"
    exit 1
  fi
  echo "[PASS] capability/engine consistency validation passed"
}

main "$@"
