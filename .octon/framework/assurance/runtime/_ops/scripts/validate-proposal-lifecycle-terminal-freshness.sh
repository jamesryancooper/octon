#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"

TARGET=""
CHILDREN_FILE=""
RUN_REGISTRY_CHECK=0
errors=0

usage() {
  cat <<'EOF'
usage:
  validate-proposal-lifecycle-terminal-freshness.sh --proposal <path> [--children-file <path>] [--run-registry-check] [--root <repo-root>]
  validate-proposal-lifecycle-terminal-freshness.sh --program <path> [--children-file <path>] [--run-registry-check] [--root <repo-root>]

Validates late proposal lifecycle freshness for the scoped packet set by
checking generated proposal registry freshness when requested, artifact index
freshness, and artifact spine freshness after the last proposal mutation.
EOF
}

pass() { printf '[OK] %s\n' "$1"; }
fail() { printf '[ERROR] %s\n' "$1" >&2; errors=$((errors + 1)); }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --proposal|--package|--program)
      shift
      TARGET="${1:-}"
      ;;
    --children-file)
      shift
      CHILDREN_FILE="${1:-}"
      ;;
    --run-registry-check)
      RUN_REGISTRY_CHECK=1
      ;;
    --root)
      shift
      ROOT_DIR="$(cd -- "${1:-}" && pwd)"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [[ -z "$TARGET" ]]; then
  usage >&2
  exit 2
fi

resolve_path() {
  local path="$1"
  if [[ "$path" = /* ]]; then
    printf '%s\n' "$path"
  else
    printf '%s/%s\n' "$ROOT_DIR" "$path"
  fi
}

rel_path() {
  local path="$1"
  if [[ "$path" == "$ROOT_DIR" ]]; then
    printf '.\n'
  else
    printf '%s\n' "${path#$ROOT_DIR/}"
  fi
}

run_check() {
  local label="$1"
  shift
  if "$@"; then
    pass "$label"
  else
    fail "$label"
  fi
}

TARGET_ABS="$(resolve_path "$TARGET")"
if [[ -d "$TARGET_ABS" && -f "$TARGET_ABS/proposal.yml" ]]; then
  pass "target proposal exists: $(rel_path "$TARGET_ABS")"
else
  fail "target proposal exists: $TARGET"
fi

declare -a PROPOSALS=("$TARGET_ABS")
if [[ -n "$CHILDREN_FILE" ]]; then
  if [[ "$RUN_REGISTRY_CHECK" -ne 1 ]]; then
    fail "scoped child validation requires --run-registry-check"
  fi
  CHILDREN_ABS="$(resolve_path "$CHILDREN_FILE")"
  if [[ -f "$CHILDREN_ABS" ]]; then
    pass "children file exists: $(rel_path "$CHILDREN_ABS")"
    while IFS= read -r child || [[ -n "$child" ]]; do
      child="${child%%#*}"
      child="${child#"${child%%[![:space:]]*}"}"
      child="${child%"${child##*[![:space:]]}"}"
      [[ -z "$child" ]] && continue
      PROPOSALS+=("$(resolve_path "$child")")
    done <"$CHILDREN_ABS"
  else
    fail "children file exists: $CHILDREN_FILE"
  fi
fi

if [[ "$RUN_REGISTRY_CHECK" -eq 1 ]]; then
  if [[ "$ROOT_DIR" != "$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)" ]]; then
    fail "registry freshness check requires the real repository root"
  else
  run_check "proposal registry projection is fresh" \
    bash "$SCRIPT_DIR/generate-proposal-registry.sh" --check
  fi
fi

for proposal in "${PROPOSALS[@]}"; do
  if [[ ! -d "$proposal" || ! -f "$proposal/proposal.yml" ]]; then
    fail "scoped proposal has manifest: $(rel_path "$proposal")"
    continue
  fi
  pass "scoped proposal has manifest: $(rel_path "$proposal")"
  run_check "proposal artifact index is fresh: $(rel_path "$proposal")" \
    bash "$SCRIPT_DIR/generate-proposal-artifact-index.sh" --root "$ROOT_DIR" --proposal "$proposal" --check
  run_check "proposal artifact spine validates: $(rel_path "$proposal")" \
    bash "$SCRIPT_DIR/validate-proposal-artifact-index-spine.sh" --root "$ROOT_DIR" --proposal "$proposal"
done

printf 'Terminal freshness validation summary: checked=%s errors=%s\n' "${#PROPOSALS[@]}" "$errors"
[[ "$errors" -eq 0 ]]
