#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
OCTON_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

PROPOSAL_PATH=""
SCAN_ALL=0
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

usage() {
  cat <<'EOF'
usage:
  validate-proposal-standard.sh --package <path>
  validate-proposal-standard.sh --all-standard-proposals
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      PROPOSAL_PATH="$1"
      ;;
    --all-standard-proposals)
      SCAN_ALL=1
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [[ -n "$PROPOSAL_PATH" && "$SCAN_ALL" -eq 1 ]]; then
  usage >&2
  exit 2
fi

if [[ -z "$PROPOSAL_PATH" && "$SCAN_ALL" -ne 1 ]]; then
  usage >&2
  exit 2
fi

resolve_dir() {
  local raw="$1"
  local candidate
  if [[ "$raw" = /* ]]; then
    candidate="$raw"
  else
    candidate="$ROOT_DIR/$raw"
  fi
  if [[ -f "$candidate" ]]; then
    candidate="$(dirname "$candidate")"
  fi
  if [[ ! -d "$candidate" ]]; then
    fail "proposal path not found: ${candidate#$ROOT_DIR/}"
    return 1
  fi
  (
    cd "$candidate"
    pwd
  )
}

rel_path() {
  local path="$1"
  if [[ "$path" == "$ROOT_DIR" ]]; then
    printf '.\n'
  else
    printf '%s\n' "${path#$ROOT_DIR/}"
  fi
}

yaml_string() {
  local file="$1"
  local query="$2"
  yq -r "$query // \"\"" "$file"
}

check_file() {
  local file="$1"
  local label="$2"
  if [[ -f "$file" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

validate_enum() {
  local value="$1"
  local label="$2"
  shift 2
  local allowed
  for allowed in "$@"; do
    if [[ "$value" == "$allowed" ]]; then
      pass "$label"
      return 0
    fi
  done
  fail "$label"
  return 1
}

allow_legacy_mixed_scope() {
  local manifest="$1"
  [[ "$(yaml_string "$manifest" '.archive.archived_from_status')" == "legacy-unknown" ]]
}

validate_promotion_targets() {
  local manifest="$1"
  local label="$2"
  local proposal_id="$3"
  local proposal_rel="$4"
  local scope target_rel saw_octon=0 saw_non_octon=0 allow_legacy=0

  scope="$(yaml_string "$manifest" '.promotion_scope')"
  if allow_legacy_mixed_scope "$manifest"; then
    allow_legacy=1
  fi
  while IFS= read -r target_rel; do
    [[ -n "$target_rel" ]] || continue
    if [[ "$target_rel" == .proposals/* ]]; then
      fail "$label promotion target must point outside .proposals/: $target_rel"
      continue
    fi

    if [[ "$target_rel" == .octon/* ]]; then
      saw_octon=1
    else
      saw_non_octon=1
    fi
  done < <(yq -r '.promotion_targets[]?' "$manifest")

  if [[ "$scope" == "octon-internal" && "$saw_non_octon" -eq 1 && "$allow_legacy" -ne 1 ]]; then
    fail "$label octon-internal scope includes non-.octon promotion targets"
  elif [[ "$scope" == "octon-internal" ]]; then
    pass "$label octon-internal targets stay under .octon/"
  fi

  if [[ "$scope" == "repo-local" && "$saw_octon" -eq 1 && "$allow_legacy" -ne 1 ]]; then
    fail "$label repo-local scope includes .octon promotion targets"
  elif [[ "$scope" == "repo-local" ]]; then
    pass "$label repo-local targets stay outside .octon/"
  fi

  if [[ "$saw_octon" -eq 1 && "$saw_non_octon" -eq 1 ]]; then
    if [[ "$allow_legacy" -eq 1 ]]; then
      warn "$label preserves historical mixed targets under legacy-unknown archive lineage"
    else
      fail "$label mixes .octon and non-.octon promotion targets"
    fi
  else
    pass "$label avoids mixed target families"
  fi

  while IFS= read -r target_rel; do
    [[ -n "$target_rel" ]] || continue
    local target_abs="$ROOT_DIR/$target_rel"
    if [[ ! -e "$target_abs" ]]; then
      if [[ "$(yaml_string "$manifest" '.status')" == "archived" && "$(yaml_string "$manifest" '.archive.disposition')" == "implemented" ]]; then
        fail "$label implemented archive target must exist: $target_rel"
      else
        warn "$label promotion target not present yet: $target_rel"
      fi
      continue
    fi
    local found=""
    found="$(grep -R -n -E "\\.proposals/(\\.archive/)?[a-z0-9-]+/${proposal_id}" "$target_abs" 2>/dev/null || true)"
    if [[ -n "$found" ]]; then
      fail "$label promotion target retains proposal-path dependency: $target_rel"
      printf '%s\n' "$found"
    else
      pass "$label promotion target avoids proposal-path backreferences: $target_rel"
    fi
  done < <(yq -r '.promotion_targets[]?' "$manifest")
}

validate_registry_projection() {
  local manifest="$1"
  local label="$2"
  local proposal_id="$3"
  local proposal_kind="$4"
  local proposal_rel="$5"
  local registry="$ROOT_DIR/.proposals/registry.yml"
  local path_query

  check_file "$registry" "proposal registry exists"
  [[ -f "$registry" ]] || return 0
  if ! yq -e '.' "$registry" >/dev/null 2>&1; then
    fail "proposal registry parses as YAML"
    return 0
  fi
  pass "proposal registry parses as YAML"
  validate_enum "$(yaml_string "$registry" '.schema_version')" "proposal registry schema_version valid" "proposal-registry-v1"

  if [[ "$(yaml_string "$manifest" '.status')" == "archived" ]]; then
    path_query=".archived[] | select(.id == \"$proposal_id\" and .kind == \"$proposal_kind\") | .path"
  else
    path_query=".active[] | select(.id == \"$proposal_id\" and .kind == \"$proposal_kind\") | .path"
  fi

  local entry_path
  entry_path="$(yq -r "$path_query // \"\"" "$registry")"
  if [[ -z "$entry_path" ]]; then
    fail "$label registry entry exists"
  elif [[ "$entry_path" == "$proposal_rel" ]]; then
    pass "$label registry entry path matches manifest path"
  else
    fail "$label registry entry path matches manifest path"
  fi
}

validate_proposal() {
  local proposal_dir="$1"
  local manifest="$proposal_dir/proposal.yml"
  local proposal_rel proposal_id kind scope status

  proposal_rel="$(rel_path "$proposal_dir")"
  check_file "$manifest" "proposal '$proposal_rel' manifest exists"
  [[ -f "$manifest" ]] || return 0
  if ! yq -e '.' "$manifest" >/dev/null 2>&1; then
    fail "proposal '$proposal_rel' manifest parses as YAML"
    return 0
  fi
  pass "proposal '$proposal_rel' manifest parses as YAML"

  validate_enum "$(yaml_string "$manifest" '.schema_version')" "proposal '$proposal_rel' schema_version is proposal-v1" "proposal-v1"
  proposal_id="$(yaml_string "$manifest" '.proposal_id')"
  kind="$(yaml_string "$manifest" '.proposal_kind')"
  scope="$(yaml_string "$manifest" '.promotion_scope')"
  status="$(yaml_string "$manifest" '.status')"

  validate_enum "$kind" "proposal '$proposal_rel' kind valid" "design" "migration" "policy" "architecture"
  validate_enum "$scope" "proposal '$proposal_rel' scope valid" "octon-internal" "repo-local"
  validate_enum "$status" "proposal '$proposal_rel' status valid" "draft" "in-review" "accepted" "implemented" "rejected" "archived"

  if [[ "$(basename "$proposal_dir")" == "$proposal_id" ]]; then
    pass "proposal '$proposal_rel' id matches directory name"
  else
    fail "proposal '$proposal_rel' id matches directory name"
  fi

  case "$proposal_rel" in
    .proposals/.archive/$kind/$proposal_id) pass "proposal '$proposal_rel' archived path matches kind/id" ;;
    .proposals/$kind/$proposal_id) pass "proposal '$proposal_rel' active path matches kind/id" ;;
    *) fail "proposal '$proposal_rel' lives in a valid proposal path" ;;
  esac

  if [[ "$status" == "archived" ]]; then
    [[ -n "$(yaml_string "$manifest" '.archive.archived_at')" ]] && pass "proposal '$proposal_rel' archive metadata present" || fail "proposal '$proposal_rel' archive metadata present"
  else
    if yq -e 'has("archive")' "$manifest" >/dev/null 2>&1; then
      fail "proposal '$proposal_rel' non-archived proposal must not contain archive block"
    else
      pass "proposal '$proposal_rel' non-archived proposal omits archive block"
    fi
  fi

  validate_promotion_targets "$manifest" "proposal '$proposal_rel'" "$proposal_id" "$proposal_rel"
  validate_registry_projection "$manifest" "proposal '$proposal_rel'" "$proposal_id" "$kind" "$proposal_rel"
}

main() {
  if [[ "$SCAN_ALL" -eq 1 ]]; then
    while IFS= read -r manifest; do
      validate_proposal "$(dirname "$manifest")"
    done < <(find "$ROOT_DIR/.proposals" -name proposal.yml -type f | sort)
  else
    proposal_dir="$(resolve_dir "$PROPOSAL_PATH")"
    validate_proposal "$proposal_dir"
  fi

  echo "Validation summary: errors=$errors warnings=$warnings"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
