#!/usr/bin/env bash
set -euo pipefail

# Validate the Architecture Lens Bank's reference integrity. Fails closed when:
#   (A) a method profile references a lens id not defined in lenses[].id, or
#   (B) a bank-known suite method lacks a complete profile (missing entry or an
#       empty required set).
# The validator reads lens ids and method slugs from lens-bank.yml data; it does
# NOT hard-code companion method slugs (those are owned canonically by the
# phase-1 taxonomy-and-routing child). Follows the architectural-review validator
# conventions: [OK]/[ERROR] lines, a trailing `Validation summary: errors=N`, and
# a non-zero exit when errors>0.

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
BANK=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="$(cd -- "$2" && pwd)"
      shift 2
      ;;
    --lens-bank)
      BANK="$2"
      shift 2
      ;;
    *)
      printf '[ERROR] unknown argument: %s\n' "$1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "$BANK" ]]; then
  BANK="$ROOT_DIR/.octon/framework/cognition/practices/methodology/architectural-review/lens-bank.yml"
fi

errors=0
pass() { printf '[OK] %s\n' "$1"; }
fail() { printf '[ERROR] %s\n' "$1" >&2; errors=$((errors + 1)); }

if [[ -f "$BANK" ]]; then
  pass "lens bank exists: $BANK"
else
  fail "lens bank exists: $BANK"
  printf 'Validation summary: errors=%s\n' "$errors"
  exit 1
fi

if yq -e '.' "$BANK" >/dev/null 2>&1; then
  pass "lens bank parses as YAML"
else
  fail "lens bank parses as YAML"
  printf 'Validation summary: errors=%s\n' "$errors"
  exit 1
fi

# Collect the defined lens ids.
mapfile -t LENS_IDS < <(yq -r '.lenses[].id' "$BANK" 2>/dev/null || true)
if [[ "${#LENS_IDS[@]}" -gt 0 ]]; then
  pass "lens catalog declares ${#LENS_IDS[@]} lens ids"
else
  fail "lens catalog declares at least one lens id"
fi

declare -A LENS_DEFINED=()
for id in "${LENS_IDS[@]}"; do
  [[ -z "$id" || "$id" == "null" ]] && continue
  if [[ -n "${LENS_DEFINED[$id]:-}" ]]; then
    fail "duplicate lens id defined: $id"
  fi
  LENS_DEFINED["$id"]=1
done

# Valid tiers, and every lens carries a declared tier.
mapfile -t LENS_TIERS < <(yq -r '.lens_tiers[]' "$BANK" 2>/dev/null || true)
declare -A TIER_VALID=()
for t in "${LENS_TIERS[@]}"; do
  [[ -z "$t" || "$t" == "null" ]] && continue
  TIER_VALID["$t"]=1
done
while IFS=$'\t' read -r lid ltier; do
  [[ -z "$lid" ]] && continue
  if [[ -z "$ltier" || "$ltier" == "null" ]]; then
    fail "lens missing tier: $lid"
  elif [[ -z "${TIER_VALID[$ltier]:-}" ]]; then
    fail "lens $lid has undeclared tier: $ltier"
  fi
done < <(yq -r '.lenses[] | [.id, .tier] | @tsv' "$BANK" 2>/dev/null || true)

# Rule A: every lens id referenced by a method profile must be defined.
undefined_refs=0
while IFS=$'\t' read -r method lens_ref; do
  [[ -z "$method" || -z "$lens_ref" || "$lens_ref" == "null" ]] && continue
  if [[ -z "${LENS_DEFINED[$lens_ref]:-}" ]]; then
    fail "method profile '$method' references undefined lens id: $lens_ref"
    undefined_refs=$((undefined_refs + 1))
  fi
done < <(yq -r '.method_profiles | to_entries[] | .key as $m | ((.value.required // []) + (.value.optional // []))[] | [$m, .] | @tsv' "$BANK" 2>/dev/null || true)
[[ "$undefined_refs" -eq 0 ]] && pass "all method-profile lens references resolve to defined lens ids"

# Rule B: every bank-known suite method must have a complete profile
# (a method_profiles entry with a non-empty required set).
mapfile -t SUITE_METHODS < <(yq -r '.suite_methods[].slug' "$BANK" 2>/dev/null || true)
if [[ "${#SUITE_METHODS[@]}" -gt 0 ]]; then
  pass "bank declares ${#SUITE_METHODS[@]} suite methods"
else
  fail "bank declares at least one suite method"
fi

declare -A SUITE_KNOWN=()
for m in "${SUITE_METHODS[@]}"; do
  [[ -z "$m" || "$m" == "null" ]] && continue
  SUITE_KNOWN["$m"]=1
  if [[ "$(yq -r ".method_profiles | has(\"$m\")" "$BANK" 2>/dev/null)" != "true" ]]; then
    fail "suite method '$m' has no method_profiles entry"
    continue
  fi
  required_count="$(yq -r ".method_profiles.\"$m\".required | length" "$BANK" 2>/dev/null || echo 0)"
  if [[ "$required_count" =~ ^[0-9]+$ ]] && [[ "$required_count" -gt 0 ]]; then
    pass "suite method '$m' has a complete profile (required=$required_count)"
  else
    fail "suite method '$m' has an empty or missing required lens set"
  fi
done

# Integrity: no method_profiles entry for an unknown (non-suite) method.
while read -r pm; do
  [[ -z "$pm" || "$pm" == "null" ]] && continue
  if [[ -z "${SUITE_KNOWN[$pm]:-}" ]]; then
    fail "method_profiles declares profile for unknown suite method: $pm"
  fi
done < <(yq -r '.method_profiles | keys | .[]' "$BANK" 2>/dev/null || true)

printf 'Validation summary: errors=%s\n' "$errors"
[[ "$errors" -eq 0 ]]
