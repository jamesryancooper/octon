#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

PROPOSAL_PATH=""
SCAN_ALL=0
SKIP_REGISTRY_CHECK=0
SKIP_PROMOTION_TARGET_CHECKS=0
errors=0
warnings=0

GENERATOR_SCRIPT="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh"

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
  validate-proposal-standard.sh --package <path> [--skip-registry-check] [--skip-promotion-target-checks]
  validate-proposal-standard.sh --all-standard-proposals [--skip-registry-check] [--skip-promotion-target-checks]
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
    --skip-registry-check)
      SKIP_REGISTRY_CHECK=1
      ;;
    --skip-promotion-target-checks)
      SKIP_PROMOTION_TARGET_CHECKS=1
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

validate_regex() {
  local value="$1"
  local label="$2"
  local pattern="$3"
  if perl -e 'exit(($ARGV[0] =~ /$ARGV[1]/) ? 0 : 1)' -- "$value" "$pattern"; then
    pass "$label"
  else
    fail "$label"
  fi
}

validate_non_empty() {
  local value="$1"
  local label="$2"
  if [[ -n "$value" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

validate_subtype_manifest_count() {
  local proposal_dir="$1"
  local label="$2"
  local count=0
  local subtype
  for subtype in design-proposal.yml migration-proposal.yml policy-proposal.yml architecture-proposal.yml; do
    if [[ -f "$proposal_dir/$subtype" ]]; then
      count=$((count + 1))
    fi
  done

  if [[ "$count" -eq 1 ]]; then
    pass "$label has exactly one subtype manifest"
  else
    fail "$label has exactly one subtype manifest"
  fi
}

artifact_catalog_entries() {
  local artifact_catalog="$1"
  perl -ne 'while(/`([^`]+)`/g){print "$1\n"}' "$artifact_catalog" \
    | grep -E '^[^/[:space:]][^[:space:]]*\.[A-Za-z0-9._-]+$' \
    | grep -v '^\.octon/' \
    | sort -u || true
}

proposal_file_inventory() {
  local proposal_dir="$1"
  find "$proposal_dir" -type f | while IFS= read -r file; do
    local rel="${file#$proposal_dir/}"
    case "$rel" in
      .*|*/.*)
        continue
        ;;
    esac
    printf '%s\n' "$rel"
  done | sort
}

validate_artifact_catalog() {
  local proposal_dir="$1"
  local label="$2"
  local catalog="$proposal_dir/navigation/artifact-catalog.md"
  [[ -f "$catalog" ]] || return 0

  local tmp_dir actual listed
  tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/proposal-catalog.XXXXXX")"
  actual="$tmp_dir/actual.txt"
  listed="$tmp_dir/listed.txt"
  local missing stale

  proposal_file_inventory "$proposal_dir" >"$actual"
  artifact_catalog_entries "$catalog" >"$listed"

  missing="$(comm -23 "$actual" "$listed" || true)"
  stale="$(comm -13 "$actual" "$listed" || true)"

  if [[ -n "$stale" ]]; then
    fail "$label artifact catalog references only on-disk files"
    echo "--- artifact-catalog stale entries"
    printf '%s\n' "$stale"
  else
    pass "$label artifact catalog references only on-disk files"
  fi

  if [[ -n "$missing" ]]; then
    warn "$label artifact catalog omits some visible files; regenerate inventory for full coverage"
  else
    pass "$label artifact catalog covers visible files"
  fi

  if [[ -d "$tmp_dir" ]]; then
    rm -r "$tmp_dir"
  fi
}

validate_lifecycle() {
  local manifest="$1"
  local label="$2"

  if [[ "$(yaml_string "$manifest" '.lifecycle.temporary')" == "true" ]]; then
    pass "$label lifecycle.temporary remains true"
  else
    fail "$label lifecycle.temporary remains true"
  fi

  validate_non_empty "$(yaml_string "$manifest" '.lifecycle.exit_expectation')" "$label lifecycle.exit_expectation present"

  if yq -e 'has("exit_expectation")' "$manifest" >/dev/null 2>&1; then
    fail "$label top-level exit_expectation is forbidden"
  else
    pass "$label top-level exit_expectation is absent"
  fi
}

allow_legacy_mixed_scope() {
  local manifest="$1"
  [[ "$(yaml_string "$manifest" '.archive.archived_from_status')" == "legacy-unknown" ]]
}

is_legacy_archive() {
  local manifest="$1"
  [[ "$(yaml_string "$manifest" '.status')" == "archived" ]] && allow_legacy_mixed_scope "$manifest"
}

validate_promotion_targets() {
  local manifest="$1"
  local label="$2"
  local proposal_id="$3"
  local scope status target_rel saw_octon=0 saw_non_octon=0 allow_legacy=0
  status="$(yaml_string "$manifest" '.status')"

  scope="$(yaml_string "$manifest" '.promotion_scope')"
  if allow_legacy_mixed_scope "$manifest"; then
    allow_legacy=1
  fi
  while IFS= read -r target_rel; do
    [[ -n "$target_rel" ]] || continue
    if [[ "$target_rel" == .octon/inputs/exploratory/proposals/* ]]; then
      fail "$label promotion target must point outside .octon/inputs/exploratory/proposals/: $target_rel"
      continue
    fi

    if [[ "$target_rel" == .octon/* ]]; then
      saw_octon=1
    else
      saw_non_octon=1
    fi
  done < <(yq -r '.promotion_targets[]?' "$manifest")

  if [[ "$status" == "archived" ]]; then
    pass "$label archived proposal preserves promotion target provenance"
  elif [[ "$scope" == "octon-internal" && "$saw_non_octon" -eq 1 && "$allow_legacy" -ne 1 ]]; then
    fail "$label octon-internal scope includes non-.octon promotion targets"
  elif [[ "$scope" == "octon-internal" ]]; then
    pass "$label octon-internal targets stay under .octon/"
  fi

  if [[ "$status" == "archived" ]]; then
    true
  elif [[ "$scope" == "repo-local" && "$saw_octon" -eq 1 && "$allow_legacy" -ne 1 ]]; then
    fail "$label repo-local scope includes .octon promotion targets"
  elif [[ "$scope" == "repo-local" ]]; then
    pass "$label repo-local targets stay outside .octon/"
  fi

  if [[ "$status" == "archived" ]]; then
    true
  elif [[ "$saw_octon" -eq 1 && "$saw_non_octon" -eq 1 ]]; then
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
    if [[ "$status" == "archived" ]]; then
      pass "$label archived proposal skips proposal-path dependency scan for historical targets: $target_rel"
    else
      local found=""
      if command -v rg >/dev/null 2>&1; then
        found="$(rg -n -e "\\.octon/inputs/exploratory/proposals/(\\.archive/)?[a-z0-9-]+/${proposal_id}" "$target_abs" 2>/dev/null || true)"
      else
        found="$(grep -R -n -E "\\.octon/inputs/exploratory/proposals/(\\.archive/)?[a-z0-9-]+/${proposal_id}" "$target_abs" 2>/dev/null || true)"
      fi
      if [[ -n "$found" ]]; then
        fail "$label promotion target retains proposal-path dependency: $target_rel"
        printf '%s\n' "$found"
      else
        pass "$label promotion target avoids proposal-path backreferences: $target_rel"
      fi
    fi
  done < <(yq -r '.promotion_targets[]?' "$manifest")
}

validate_proposal() {
  local proposal_dir="$1"
  local manifest="$proposal_dir/proposal.yml"
  local proposal_rel proposal_id kind scope status path_mode target_count disposition

  path_mode="invalid"

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

  validate_regex "$proposal_id" "proposal '$proposal_rel' proposal_id matches format" '^[a-z][a-z0-9-]*$'
  validate_enum "$kind" "proposal '$proposal_rel' kind valid" "design" "migration" "policy" "architecture"
  validate_enum "$scope" "proposal '$proposal_rel' scope valid" "octon-internal" "repo-local"
  validate_enum "$status" "proposal '$proposal_rel' status valid" "draft" "in-review" "accepted" "implemented" "rejected" "archived"
  check_file "$proposal_dir/README.md" "proposal '$proposal_rel' README exists"
  if is_legacy_archive "$manifest"; then
    if [[ -f "$proposal_dir/navigation/artifact-catalog.md" ]]; then
      pass "proposal '$proposal_rel' artifact catalog exists"
    else
      warn "proposal '$proposal_rel' legacy archive omits artifact catalog"
    fi
    if [[ -f "$proposal_dir/navigation/source-of-truth-map.md" ]]; then
      pass "proposal '$proposal_rel' source-of-truth map exists"
    else
      warn "proposal '$proposal_rel' legacy archive omits source-of-truth map"
    fi
  else
    check_file "$proposal_dir/navigation/artifact-catalog.md" "proposal '$proposal_rel' artifact catalog exists"
    check_file "$proposal_dir/navigation/source-of-truth-map.md" "proposal '$proposal_rel' source-of-truth map exists"
  fi
  validate_subtype_manifest_count "$proposal_dir" "proposal '$proposal_rel'"
  if ! is_legacy_archive "$manifest"; then
    validate_artifact_catalog "$proposal_dir" "proposal '$proposal_rel'"
  fi
  validate_lifecycle "$manifest" "proposal '$proposal_rel'"

  if [[ "$(basename "$proposal_dir")" == "$proposal_id" ]]; then
    pass "proposal '$proposal_rel' id matches directory name"
  else
    fail "proposal '$proposal_rel' id matches directory name"
  fi

  case "$proposal_rel" in
    .octon/inputs/exploratory/proposals/.archive/$kind/$proposal_id)
      pass "proposal '$proposal_rel' archived path matches kind/id"
      path_mode="archived"
      ;;
    .octon/inputs/exploratory/proposals/$kind/$proposal_id)
      pass "proposal '$proposal_rel' active path matches kind/id"
      path_mode="active"
      ;;
    *)
      fail "proposal '$proposal_rel' lives in a valid proposal path"
      ;;
  esac

  target_count="$(yq -r '.promotion_targets | length' "$manifest")"
  if [[ "$target_count" =~ ^[1-9][0-9]*$ ]]; then
    pass "proposal '$proposal_rel' promotion_targets present"
  else
    fail "proposal '$proposal_rel' promotion_targets present"
  fi

  if [[ "$status" == "archived" ]]; then
    if [[ "$path_mode" == "archived" ]]; then
      pass "proposal '$proposal_rel' archived proposals stay in archive paths"
    else
      fail "proposal '$proposal_rel' archived proposals stay in archive paths"
    fi
    [[ -n "$(yaml_string "$manifest" '.archive.archived_at')" ]] && pass "proposal '$proposal_rel' archive metadata present" || fail "proposal '$proposal_rel' archive metadata present"
    validate_enum "$(yaml_string "$manifest" '.archive.archived_from_status')" "proposal '$proposal_rel' archived_from_status valid" "draft" "in-review" "accepted" "implemented" "rejected" "legacy-unknown"
    validate_enum "$(yaml_string "$manifest" '.archive.disposition')" "proposal '$proposal_rel' archive disposition valid" "implemented" "rejected" "historical" "superseded"
    validate_non_empty "$(yaml_string "$manifest" '.archive.original_path')" "proposal '$proposal_rel' archive original_path present"
    disposition="$(yaml_string "$manifest" '.archive.disposition')"
    if [[ "$disposition" == "implemented" ]]; then
      target_count="$(yq -r '.archive.promotion_evidence | length' "$manifest")"
      if [[ "$target_count" =~ ^[1-9][0-9]*$ ]]; then
        pass "proposal '$proposal_rel' implemented archive keeps promotion evidence"
      else
        fail "proposal '$proposal_rel' implemented archive keeps promotion evidence"
      fi
    fi
  else
    if [[ "$path_mode" == "active" ]]; then
      pass "proposal '$proposal_rel' active proposals stay in active paths"
    else
      fail "proposal '$proposal_rel' active proposals stay in active paths"
    fi
    if yq -e 'has("archive")' "$manifest" >/dev/null 2>&1; then
      fail "proposal '$proposal_rel' non-archived proposal must not contain archive block"
    else
      pass "proposal '$proposal_rel' non-archived proposal omits archive block"
    fi
  fi

  if [[ "$SKIP_PROMOTION_TARGET_CHECKS" -ne 1 ]]; then
    validate_promotion_targets "$manifest" "proposal '$proposal_rel'" "$proposal_id"
  fi
}

main() {
  if [[ "$SCAN_ALL" -eq 1 ]]; then
    while IFS= read -r manifest; do
      validate_proposal "$(dirname "$manifest")"
    done < <(find "$ROOT_DIR/.octon/inputs/exploratory/proposals" -name proposal.yml -type f | sort)
  else
    proposal_dir="$(resolve_dir "$PROPOSAL_PATH")"
    validate_proposal "$proposal_dir"
  fi

  if [[ "$SKIP_REGISTRY_CHECK" -ne 1 ]]; then
    if [[ -x "$GENERATOR_SCRIPT" || -f "$GENERATOR_SCRIPT" ]]; then
      if bash "$GENERATOR_SCRIPT" --check; then
        pass "proposal registry synchronized with manifest projection"
      else
        fail "proposal registry synchronized with manifest projection"
      fi
    else
      fail "proposal registry generator exists"
    fi
  fi

  echo "Validation summary: errors=$errors warnings=$warnings"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
