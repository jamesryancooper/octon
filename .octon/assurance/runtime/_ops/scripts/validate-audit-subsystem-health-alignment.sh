#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
OCTON_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

ALIGNMENT_CONTRACT="$OCTON_DIR/capabilities/runtime/skills/audit/audit-subsystem-health/references/alignment-contract.md"
SKILL_FILE="$OCTON_DIR/capabilities/runtime/skills/audit/audit-subsystem-health/SKILL.md"
PHASES_FILE="$OCTON_DIR/capabilities/runtime/skills/audit/audit-subsystem-health/references/phases.md"
VALIDATION_FILE="$OCTON_DIR/capabilities/runtime/skills/audit/audit-subsystem-health/references/validation.md"
IO_CONTRACT_FILE="$OCTON_DIR/capabilities/runtime/skills/audit/audit-subsystem-health/references/io-contract.md"
REGISTRY_FILE="$OCTON_DIR/capabilities/runtime/skills/registry.yml"

errors=0
warnings=0
base_ref="${AUDIT_ALIGNMENT_BASE_REF:-${BASE_REF:-}}"
static_only=0

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

usage() {
  cat <<'EOF'
Usage: validate-audit-subsystem-health-alignment.sh [options]

Options:
  --base-ref <git-ref>  Compare drift against this ref (default: HEAD~1 when available)
  --static-only         Skip git-diff drift checks; run contract/static checks only
  -h, --help            Show this help message
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --base-ref)
        [[ $# -lt 2 ]] && { echo "Missing value for --base-ref" >&2; exit 2; }
        base_ref="$2"
        shift 2
        ;;
      --static-only)
        static_only=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        usage
        exit 2
        ;;
    esac
  done
}

require_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    fail "missing file: ${file#$ROOT_DIR/}"
  else
    pass "found file: ${file#$ROOT_DIR/}"
  fi
}

extract_skill_version_from_stream() {
  awk '
    /^  audit-subsystem-health:/ {in_block=1; next}
    in_block && /^  [^[:space:]]/ {exit}
    in_block && /^[[:space:]]+version:/ {
      v=$2
      gsub(/"/, "", v)
      print v
      exit
    }
  '
}

extract_skill_version_from_file() {
  extract_skill_version_from_stream < "$1"
}

extract_skill_version_from_ref() {
  local ref="$1"
  git -C "$ROOT_DIR" show "${ref}:.octon/capabilities/runtime/skills/registry.yml" 2>/dev/null | extract_skill_version_from_stream || true
}

regex_matches_any() {
  local value="$1"
  shift
  local regex
  for regex in "$@"; do
    if [[ "$value" =~ $regex ]]; then
      return 0
    fi
  done
  return 1
}

collect_changed_files() {
  local tmp="$1"

  if ! git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    warn "not inside git repository; skipping drift diff checks"
    return 0
  fi

  if [[ -z "$base_ref" ]]; then
    if git -C "$ROOT_DIR" rev-parse --verify HEAD~1 >/dev/null 2>&1; then
      base_ref="HEAD~1"
    fi
  fi

  if [[ $static_only -eq 0 ]]; then
    if [[ -n "$base_ref" ]] && git -C "$ROOT_DIR" rev-parse --verify "$base_ref" >/dev/null 2>&1; then
      git -C "$ROOT_DIR" diff --name-only "${base_ref}"...HEAD -- .octon >> "$tmp" || true
      pass "collected git history diff against ${base_ref}"
    elif [[ -n "$base_ref" ]]; then
      warn "base ref not resolvable (${base_ref}); skipping history diff"
    fi

    git -C "$ROOT_DIR" diff --name-only -- .octon >> "$tmp" || true
    git -C "$ROOT_DIR" diff --name-only --cached -- .octon >> "$tmp" || true
  fi
}

check_static_contract() {
  require_file "$ALIGNMENT_CONTRACT"
  require_file "$SKILL_FILE"
  require_file "$PHASES_FILE"
  require_file "$VALIDATION_FILE"
  require_file "$IO_CONTRACT_FILE"
  require_file "$REGISTRY_FILE"

  if grep -q "alignment-contract.md" "$SKILL_FILE"; then
    pass "SKILL.md references alignment contract"
  else
    fail "SKILL.md missing reference to references/alignment-contract.md"
  fi

  if grep -q "validate-audit-subsystem-health-alignment.sh" "$VALIDATION_FILE"; then
    pass "validation reference includes alignment validator"
  else
    warn "validation reference does not mention alignment validator script"
  fi
}

check_drift_alignment() {
  local tmp changed_file
  tmp="$(mktemp)"

  collect_changed_files "$tmp"
  sort -u -o "$tmp" "$tmp"

  mapfile -t changed_files < "$tmp"
  if [[ ${#changed_files[@]} -eq 0 ]]; then
    pass "no .octon changes detected for drift check"
    return 0
  fi

  local watched_regexes=(
    '^\.octon/(START\.md|README\.md|octon\.yml|catalog\.md)$'
    '^\.octon/cognition/_meta/architecture/'
    '^\.octon/cognition/governance/'
    '^\.octon/cognition/practices/'
    '^\.octon/cognition/runtime/context/'
    '^\.octon/cognition/runtime/migrations/'
    '^\.octon/cognition/runtime/decisions/'
    '^\.octon/output/reports/decisions/'
    '^\.octon/[^/]+/_meta/architecture/'
    '^\.octon/orchestration/runtime/workflows/audit/audit-pre-release/'
    '^\.octon/assurance/practices/(complete\.md|session-exit\.md)$'
    '^\.octon/assurance/runtime/_ops/scripts/validate-harness-structure\.sh$'
    '^\.octon/assurance/runtime/_ops/scripts/validate-contract-governance\.sh$'
    '^\.octon/assurance/runtime/_ops/scripts/validate-bootstrap-ingress\.sh$'
    '^\.octon/assurance/runtime/_ops/scripts/validate-bootstrap-projections\.sh$'
    '^\.octon/scaffolding/runtime/bootstrap/'
  )
  local update_regexes=(
    '^\.octon/capabilities/runtime/skills/audit/audit-subsystem-health/'
    '^\.octon/capabilities/runtime/skills/registry\.yml$'
  )
  local logic_regexes=(
    '^\.octon/capabilities/runtime/skills/audit/audit-subsystem-health/SKILL\.md$'
    '^\.octon/capabilities/runtime/skills/audit/audit-subsystem-health/references/.*\.md$'
  )

  local watched_changed=0
  local update_changed=0
  local logic_changed=0

  for changed_file in "${changed_files[@]}"; do
    regex_matches_any "$changed_file" "${watched_regexes[@]}" && watched_changed=1
    regex_matches_any "$changed_file" "${update_regexes[@]}" && update_changed=1
    regex_matches_any "$changed_file" "${logic_regexes[@]}" && logic_changed=1
  done

  if [[ $watched_changed -eq 1 && $update_changed -eq 0 ]]; then
    fail "drift detected: watched architecture surfaces changed without updates to audit-subsystem-health artifacts"
  elif [[ $watched_changed -eq 1 ]]; then
    pass "watched architecture changes include audit-subsystem-health updates"
  else
    pass "no watched architecture surface changes detected"
  fi

  if [[ $logic_changed -eq 1 ]]; then
    local current_version baseline_version
    current_version="$(extract_skill_version_from_file "$REGISTRY_FILE")"
    baseline_version=""

    if [[ -n "$base_ref" ]]; then
      baseline_version="$(extract_skill_version_from_ref "$base_ref")"
    fi
    if [[ -z "$baseline_version" ]]; then
      baseline_version="$(extract_skill_version_from_ref "HEAD")"
    fi

    if [[ -z "$current_version" ]]; then
      fail "unable to resolve current audit-subsystem-health version in registry"
    elif [[ -z "$baseline_version" ]]; then
      warn "unable to resolve baseline audit-subsystem-health version; version bump check skipped"
    elif [[ "$current_version" == "$baseline_version" ]]; then
      fail "audit-subsystem-health logic changed without version bump (current=${current_version}, baseline=${baseline_version})"
    else
      pass "audit-subsystem-health version bump detected (${baseline_version} -> ${current_version})"
    fi
  else
    pass "no audit-subsystem-health logic change detected"
  fi

  rm -f "$tmp"
}

main() {
  parse_args "$@"
  echo "== Audit Subsystem Health Alignment Validation =="

  check_static_contract
  check_drift_alignment

  echo
  echo "Validation summary: errors=$errors warnings=$warnings"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
