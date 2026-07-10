#!/usr/bin/env bash
set -euo pipefail

# Doc-consistency check — child mandatory floor (child-packet-contract obligation 4)
# for greenfield-reference-architecture-review-method.
#
# Verifies, against the LIVE mechanism surfaces (repository wins):
#   (1) slug match   : doc slug == naming.yml catalog slug == lens-bank.yml suite_methods slug
#   (2) lens profile : the lens ids cited in the doc == lens-bank.yml
#                      method_profiles.greenfield-reference-architecture-review-method
#                      (required + optional) EXACTLY — no extra id, no missing id,
#                      no private catalog (the one non-profile catalog lens must be absent)
#   (3) structural   : five required output sections + three build-discipline subsections present
#   (4) fail-closed  : the reference-architecture-only output boundary is stated fail-closed
#
# Emits [OK]/[ERROR] lines and a trailing `Validation summary: errors=N`; exits
# non-zero when errors>0. This is retained evidence, not a durable validator.

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
MECH="$ROOT_DIR/.octon/framework/cognition/practices/methodology/architectural-review"
DOC="$MECH/greenfield-reference-architecture-review-method.md"
NAMING="$MECH/naming.yml"
BANK="$MECH/lens-bank.yml"
SLUG="greenfield-reference-architecture-review-method"

errors=0
pass() { printf '[OK] %s\n' "$1"; }
fail() { printf '[ERROR] %s\n' "$1" >&2; errors=$((errors + 1)); }

[[ -f "$DOC" ]] && pass "method doc exists: $DOC" || { fail "method doc exists: $DOC"; printf 'Validation summary: errors=%s\n' "$errors"; exit 1; }

# (1) slug match ---------------------------------------------------------------
naming_slug="$(yq -r '.methods.catalog[] | select(.doc == "greenfield-reference-architecture-review-method.md") | .slug' "$NAMING" 2>/dev/null || true)"
naming_doc="$(yq -r '.methods.catalog[] | select(.slug == "'"$SLUG"'") | .doc' "$NAMING" 2>/dev/null || true)"
bank_slug="$(yq -r '.suite_methods[] | select(.slug == "'"$SLUG"'") | .slug' "$BANK" 2>/dev/null || true)"
doc_basename="$(basename "$DOC" .md)"
doc_anchor="$(grep -c 'method_profiles\.greenfield-reference-architecture-review-method' "$DOC" || true)"

[[ "$naming_slug" == "$SLUG" ]] && pass "naming.yml catalog slug matches ($naming_slug)" || fail "naming.yml catalog slug matches (got '$naming_slug')"
[[ "$naming_doc" == "greenfield-reference-architecture-review-method.md" ]] && pass "naming.yml greenfield entry doc field points at the doc" || fail "naming.yml greenfield entry doc field points at the doc (got '$naming_doc')"
[[ "$bank_slug" == "$SLUG" ]] && pass "lens-bank.yml suite_methods slug matches ($bank_slug)" || fail "lens-bank.yml suite_methods slug matches (got '$bank_slug')"
[[ "$doc_basename" == "$SLUG" ]] && pass "doc filename slug matches ($doc_basename)" || fail "doc filename slug matches (got '$doc_basename')"
[[ "$doc_anchor" -ge 1 ]] && pass "doc cites the lens-bank greenfield profile anchor" || fail "doc cites the lens-bank greenfield profile anchor"

# (2) lens-profile exact match -------------------------------------------------
mapfile -t EXPECTED < <(yq -r '.method_profiles."'"$SLUG"'" | ((.required // []) + (.optional // []))[]' "$BANK" 2>/dev/null || true)
mapfile -t CATALOG  < <(yq -r '.lenses[].id' "$BANK" 2>/dev/null || true)
req_count="$(yq -r '.method_profiles."'"$SLUG"'".required | length' "$BANK" 2>/dev/null || echo 0)"
opt_count="$(yq -r '.method_profiles."'"$SLUG"'".optional | length' "$BANK" 2>/dev/null || echo 0)"
pass "lens-bank greenfield profile declares required=$req_count optional=$opt_count (total=${#EXPECTED[@]})"

declare -A IS_EXPECTED=()
for id in "${EXPECTED[@]}"; do [[ -n "$id" && "$id" != "null" ]] && IS_EXPECTED["$id"]=1; done

# Every expected lens id must be cited (backtick-wrapped) in the doc.
missing=0
for id in "${EXPECTED[@]}"; do
  [[ -z "$id" || "$id" == "null" ]] && continue
  if grep -Fq "\`$id\`" "$DOC"; then :; else fail "doc cites required/optional lens id: $id"; missing=$((missing + 1)); fi
done
[[ "$missing" -eq 0 ]] && pass "doc cites all ${#EXPECTED[@]} profile lens ids (no missing id)"

# No catalog lens id outside the profile may appear cited in the doc (no extra id).
extra=0
for id in "${CATALOG[@]}"; do
  [[ -z "$id" || "$id" == "null" ]] && continue
  [[ -n "${IS_EXPECTED[$id]:-}" ]] && continue
  if grep -Fq "\`$id\`" "$DOC"; then fail "doc cites a non-profile lens id (private-catalog drift): $id"; extra=$((extra + 1)); fi
done
[[ "$extra" -eq 0 ]] && pass "doc cites no lens id outside the greenfield profile (no extra id, no private catalog)"

# (3) structural ---------------------------------------------------------------
struct_fail=0
while IFS='|' read -r label needle; do
  if grep -Fq "$needle" "$DOC"; then pass "structural section present: $label"; else fail "structural section present: $label"; struct_fail=$((struct_fail + 1)); fi
done <<'SECTIONS'
domain/job model|### 1. Domain / Job Model
reference architecture|### 2. Reference Architecture
quality/security/ops model|### 3. Quality / Security / Ops Model
authority/evidence model|### 4. Authority / Evidence Model
evolution plan|### 5. Evolution Plan
initial-build sequencing|**Initial-build sequencing.**
minimum viable architecture|**Minimum viable architecture.**
what-not-to-build-yet|**What-not-to-build-yet list.**
SECTIONS

# (4) fail-closed output boundary ---------------------------------------------
if grep -Fq "## Output Boundary (Fail-Closed)" "$DOC" \
  && grep -Fq "never" "$DOC" \
  && grep -Fq "implementation authority" "$DOC" \
  && grep -Fq "pre-integration architecture review support receipt remains the only" "$DOC"; then
  pass "reference-architecture-only boundary is stated fail-closed"
else
  fail "reference-architecture-only boundary is stated fail-closed"
fi

printf 'Validation summary: errors=%s\n' "$errors"
[[ "$errors" -eq 0 ]]
