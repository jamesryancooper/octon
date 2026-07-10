#!/usr/bin/env bash
# Deterministic doc/registry consistency check for the four companion
# architecture-review method docs (validation-plan.md §1 / AC-6, AC-11).
#
# Child-owned, re-runnable analysis tooling. Authorizes nothing and creates no
# authority; it only asserts that the four authored method docs agree with the
# canonical registries (naming.yml, lens-bank.yml, review-routing.yml).
#
# Extraction note: every architecture-review lens id and method slug contains a
# hyphen, so lens ids and method slugs are extracted with hyphen-token regexes
# (no backtick handling needed). The docs list their Required/Optional lens sets
# in the same order as the lens-bank profile.
#
# Usage (from repo root): bash <this-script>
# Exit: 0 if all assertions hold for all four docs, 1 otherwise.
set -u

REVIEW_DIR="${REVIEW_DIR:-.octon/framework/cognition/practices/methodology/architectural-review}"
NAMING="$REVIEW_DIR/naming.yml"
LENS="$REVIEW_DIR/lens-bank.yml"
ROUTING="$REVIEW_DIR/review-routing.yml"
IDRE='[a-z]+(-[a-z]+)+'

SLUGS="tradeoff-review-method failure-mode-review-method evolution-fitness-review-method boundary-authority-review-method"

CATALOG_SLUGS="$(yq -r '.methods.catalog[].slug' "$NAMING")"
LENS_IDS="$(yq -r '.lenses[].id' "$LENS")"
CONFLICT_ROUTE="$(yq -r '.method_selection.constitutional_conflict_routes_to' "$ROUTING")"

errors=0

for slug in $SLUGS; do
  echo "=== $slug ==="
  doc="$REVIEW_DIR/$slug.md"

  if [ ! -f "$doc" ]; then echo "[ERR] 1 doc missing"; errors=$((errors + 1)); continue; fi
  echo "[OK] 1 doc exists: $slug.md"

  role="$(yq -r ".methods.catalog[] | select(.slug==\"$slug\") | .role" "$NAMING")"
  if [ "$role" = companion ]; then echo "[OK] 2 canonical slug, role=companion"; else echo "[ERR] 2 role=$role"; errors=$((errors + 1)); fi

  docptr="$(yq -r ".methods.catalog[] | select(.slug==\"$slug\") | .doc" "$NAMING")"
  if [ "$docptr" = "$slug.md" ] && [ -f "$REVIEW_DIR/$docptr" ]; then echo "[OK] 3 doc: pointer resolves ($docptr)"; else echo "[ERR] 3 doc: pointer=$docptr"; errors=$((errors + 1)); fi

  ref="$(yq -r ".methods.catalog[] | select(.slug==\"$slug\") | .lens_profile_ref" "$NAMING")"
  if grep -qF "$ref" "$doc"; then echo "[OK] 4a doc cites profile pointer"; else echo "[ERR] 4a profile pointer missing"; errors=$((errors + 1)); fi
  if [ "$(yq -r ".method_profiles | has(\"$slug\")" "$LENS")" = true ]; then echo "[OK] 4b profile exists in lens-bank"; else echo "[ERR] 4b profile absent"; errors=$((errors + 1)); fi

  bank_req="$(yq -r ".method_profiles.$slug.required[]" "$LENS" | sort -u)"
  bank_opt="$(yq -r ".method_profiles.$slug.optional[]" "$LENS" | sort -u)"
  doc_req="$(grep -m1 '^\*\*Required (' "$doc" | grep -oE "$IDRE" | sort -u)"
  doc_opt="$(grep -m1 '^\*\*Optional (' "$doc" | grep -oE "$IDRE" | sort -u)"
  if [ "$doc_req" = "$bank_req" ]; then echo "[OK] 5a required set matches bank verbatim"; else echo "[ERR] 5a required set mismatch"; errors=$((errors + 1)); fi
  if [ "$doc_opt" = "$bank_opt" ]; then echo "[OK] 5b optional set matches bank verbatim"; else echo "[ERR] 5b optional set mismatch"; errors=$((errors + 1)); fi

  r1="$(grep -m1 '^\*\*Required (' "$doc" | grep -oE "$IDRE")"
  r2="$(grep -m1 '^\*\*Optional (' "$doc" | grep -oE "$IDRE")"
  r3="$(grep -oE 'Lenses: \[[^]]*\]' "$doc" | grep -oE "$IDRE")"
  cited="$(printf '%s\n%s\n%s\n' "$r1" "$r2" "$r3" | sort -u | grep -v '^$')"
  bad=""
  for id in $cited; do
    if ! printf '%s\n' "$LENS_IDS" | grep -qxF -- "$id"; then bad="$bad $id"; fi
  done
  if [ -z "$bad" ]; then echo "[OK] 6a all cited lens ids exist in lens-bank"; else echo "[ERR] 6a undefined lens id(s):$bad"; errors=$((errors + 1)); fi
  if grep -qiF 'no private lens catalog' "$doc"; then echo "[OK] 6b asserts no private lens catalog"; else echo "[ERR] 6b missing no-private-lens-catalog assertion"; errors=$((errors + 1)); fi

  esc_m="$(grep -oE '[a-z-]+-review-method' "$doc" | sort -u)"
  badm=""
  for m in $esc_m; do
    if ! printf '%s\n' "$CATALOG_SLUGS" | grep -qxF -- "$m"; then badm="$badm $m"; fi
  done
  if [ -z "$badm" ]; then echo "[OK] 7a all -review-method tokens are catalog slugs"; else echo "[ERR] 7a non-catalog method slug(s):$badm"; errors=$((errors + 1)); fi
  if grep -qF 'method_selection.constitutional_conflict_routes_to' "$doc" && [ "$CONFLICT_ROUTE" = constitutional-challenge ]; then echo "[OK] 7b constitutional-conflict routing cited (route=$CONFLICT_ROUTE)"; else echo "[ERR] 7b routing not cited or route=$CONFLICT_ROUTE"; errors=$((errors + 1)); fi

  if grep -qiF 'pre-integration architecture review support receipt remains the only' "$doc" && grep -qiF 'proposal input' "$doc"; then echo "[OK] 8 output-boundary invariant present"; else echo "[ERR] 8 output-boundary invariant missing"; errors=$((errors + 1)); fi

  case "$slug" in
    failure-mode-review-method)
      if grep -qF 'Mandatory Failure-Mode' "$doc" && grep -qF 'architecture-readiness/framework.md' "$doc" && grep -qiF 'no readiness verdict' "$doc"; then echo "[OK] 9 readiness-audit boundary statement present"; else echo "[ERR] 9 readiness-audit boundary statement missing"; errors=$((errors + 1)); fi
      ;;
    boundary-authority-review-method)
      if grep -qF 'Authority Model Classification' "$doc" && grep -qF 'audits/surface-architecture.md' "$doc" && grep -qiF 'octon-only' "$doc" && grep -qF 'contract-first' "$doc" && grep -qF 'markdown-first' "$doc" && grep -qF 'human-led' "$doc"; then echo "[OK] 9 surface-audit boundary + Octon-only statement present"; else echo "[ERR] 9 surface-audit boundary/Octon-only statement missing"; errors=$((errors + 1)); fi
      ;;
    *)
      echo "[OK] 9 no per-slug mandated boundary statement required"
      ;;
  esac
done

echo ""
if [ "$errors" -eq 0 ]; then
  echo "Consistency check summary: errors=0 (all four docs consistent with registries)"
else
  echo "Consistency check summary: errors=$errors"
fi
[ "$errors" -eq 0 ]
