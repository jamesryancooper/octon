#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
HARMONY_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
REPO_ROOT="$(cd -- "$HARMONY_DIR/.." && pwd)"

POLICY_FILE="$HARMONY_DIR/capabilities/governance/policy/deny-by-default.v2.yml"
errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

read_artifact_allowlist() {
  awk '
    /^[[:space:]]*artifact_paths:[[:space:]]*\[/ {
      line=$0
      sub(/^.*\[/, "", line)
      sub(/\].*$/, "", line)
      n=split(line, parts, /,/)
      for (i=1; i<=n; i++) {
        gsub(/["'\''[:space:]]/, "", parts[i])
        if (length(parts[i]) > 0) {
          print parts[i]
        }
      }
      exit
    }
  ' "$POLICY_FILE"
}

read_allowed_sections() {
  awk '
    /^[[:space:]]*allowed_sections:[[:space:]]*$/ {in_sections=1; next}
    in_sections && /^[[:space:]]*limits:[[:space:]]*$/ {in_sections=0}
    in_sections && /^[[:space:]]*-[[:space:]]*/ {
      line=$0
      sub(/^[[:space:]]*-[[:space:]]*/, "", line)
      gsub(/[[:space:]]+$/, "", line)
      if (length(line) > 0) {
        print line
      }
    }
  ' "$POLICY_FILE"
}

read_limit_value() {
  local key="$1"
  awk -v key="$key" '
    $1 == key ":" {
      print $2
      exit
    }
  ' "$POLICY_FILE"
}

check_allowlisted_artifacts() {
  local -a allowlist=("$@")
  local -a known_context_files=("AGENTS.md" "CLAUDE.md" "AGENT.md" "CURSOR.md" "RULES.md" ".cursorrules")
  local file rel allowed

  for file in "${known_context_files[@]}"; do
    rel="$file"
    [[ -f "$REPO_ROOT/$rel" ]] || continue
    allowed=0
    for item in "${allowlist[@]}"; do
      if [[ "$item" == "$rel" ]]; then
        allowed=1
        break
      fi
    done
    if [[ "$allowed" -ne 1 ]]; then
      fail "non-allowlisted developer context artifact detected at repo root: $rel"
    fi
  done
}

check_artifact_limits() {
  local max_bytes="$1"
  local max_sections="$2"
  shift 2
  local -a allowlist=("$@")
  local artifact_path bytes sections heading required

  for artifact_path in "${allowlist[@]}"; do
    if [[ ! -f "$REPO_ROOT/$artifact_path" ]]; then
      continue
    fi

    bytes="$(wc -c < "$REPO_ROOT/$artifact_path" | tr -d '[:space:]')"
    if [[ "$bytes" =~ ^[0-9]+$ ]] && (( bytes > max_bytes )); then
      fail "$artifact_path exceeds max_bytes ($bytes > $max_bytes)"
    else
      pass "$artifact_path within max_bytes ($bytes <= $max_bytes)"
    fi

    sections="$(rg -n '^## ' "$REPO_ROOT/$artifact_path" | wc -l | tr -d '[:space:]')"
    if [[ "$sections" =~ ^[0-9]+$ ]] && (( sections > max_sections )); then
      fail "$artifact_path exceeds max_sections ($sections > $max_sections)"
    else
      pass "$artifact_path within max_sections ($sections <= $max_sections)"
    fi
  done
}

check_required_sections_present() {
  local artifact="$1"
  shift
  local -a required_sections=("$@")
  local section

  [[ -f "$REPO_ROOT/$artifact" ]] || return 0
  for section in "${required_sections[@]}"; do
    if rg -n "^##[[:space:]]+$section([[:space:]]*$|[[:space:]])" "$REPO_ROOT/$artifact" >/dev/null; then
      :
    else
      fail "$artifact missing required section: $section"
    fi
  done
}

main() {
  if [[ ! -f "$POLICY_FILE" ]]; then
    fail "policy file not found: $POLICY_FILE"
    echo "[FAIL] developer context policy validation failed with $errors error(s)"
    exit 1
  fi

  mapfile -t allowlist < <(read_artifact_allowlist)
  mapfile -t required_sections < <(read_allowed_sections)
  local max_bytes max_sections
  max_bytes="$(read_limit_value "max_bytes")"
  max_sections="$(read_limit_value "max_sections")"

  if [[ ${#allowlist[@]} -eq 0 ]]; then
    fail "developer_context_gate.allowlist.artifact_paths is empty"
  fi
  if [[ -z "$max_bytes" || ! "$max_bytes" =~ ^[0-9]+$ ]]; then
    fail "developer_context_gate.limits.max_bytes is missing or invalid"
  fi
  if [[ -z "$max_sections" || ! "$max_sections" =~ ^[0-9]+$ ]]; then
    fail "developer_context_gate.limits.max_sections is missing or invalid"
  fi
  if (( errors > 0 )); then
    echo "[FAIL] developer context policy validation failed with $errors error(s)"
    exit 1
  fi

  check_allowlisted_artifacts "${allowlist[@]}"
  check_artifact_limits "$max_bytes" "$max_sections" "${allowlist[@]}"

  local artifact
  for artifact in "${allowlist[@]}"; do
    check_required_sections_present "$artifact" "${required_sections[@]}"
  done

  if (( errors > 0 )); then
    echo "[FAIL] developer context policy validation failed with $errors error(s)"
    exit 1
  fi

  echo "[PASS] developer context policy validation passed"
}

main "$@"
