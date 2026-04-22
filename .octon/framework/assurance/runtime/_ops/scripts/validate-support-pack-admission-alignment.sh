#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

CONTRACT="$OCTON_DIR/instance/governance/contracts/support-pack-admission-alignment.yml"
SUPPORT_TARGETS="$OCTON_DIR/instance/governance/support-targets.yml"
GOV_REGISTRY="$OCTON_DIR/instance/governance/capability-packs/registry.yml"
RUNTIME_REGISTRY="$OCTON_DIR/instance/capabilities/runtime/packs/registry.yml"
PACK_ROUTES="$OCTON_DIR/generated/effective/capabilities/pack-routes.effective.yml"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

sorted_yaml_values() {
  local file="$1"
  local expr="$2"
  yq -r "$expr[]? // \"\"" "$file" 2>/dev/null | awk 'NF' | LC_ALL=C sort
}

main() {
  echo "== Support Pack Admission Alignment Validation =="

  [[ -f "$CONTRACT" ]] && pass "alignment contract present" || fail "missing alignment contract"
  [[ -f "$SUPPORT_TARGETS" ]] && pass "support target declaration present" || fail "missing support target declaration"
  [[ -f "$GOV_REGISTRY" ]] && pass "governance pack registry present" || fail "missing governance pack registry"
  [[ -f "$RUNTIME_REGISTRY" ]] && pass "runtime pack registry present" || fail "missing runtime pack registry"
  [[ -f "$PACK_ROUTES" ]] && pass "runtime pack routes present" || fail "missing runtime pack routes"

  while IFS= read -r pack_id; do
    [[ -n "$pack_id" ]] || continue
    gov_manifest="$OCTON_DIR/instance/governance/capability-packs/$pack_id.yml"
    runtime_admission="$OCTON_DIR/instance/capabilities/runtime/packs/admissions/$pack_id.yml"

    [[ -f "$gov_manifest" ]] && pass "$pack_id governance manifest present" || { fail "$pack_id governance manifest missing"; continue; }
    [[ -f "$runtime_admission" ]] && pass "$pack_id runtime admission present" || { fail "$pack_id runtime admission missing"; continue; }

    gov_status="$(yq -r '.status // ""' "$gov_manifest")"
    admission_status="$(yq -r '.status // ""' "$runtime_admission")"
    registry_status="$(yq -r ".packs[] | select(.pack_id == \"$pack_id\") | .admission_status // \"\"" "$RUNTIME_REGISTRY")"
    [[ "$gov_status" == "$admission_status" ]] && pass "$pack_id governance/runtime status aligned" || fail "$pack_id governance/runtime status drift"
    [[ "$admission_status" == "$registry_status" ]] && pass "$pack_id runtime registry status aligned" || fail "$pack_id runtime registry status drift"

    gov_route="$(yq -r '.default_route // ""' "$gov_manifest")"
    registry_route="$(yq -r ".packs[] | select(.pack_id == \"$pack_id\") | .default_route // \"\"" "$RUNTIME_REGISTRY")"
    [[ "$gov_route" == "$registry_route" ]] && pass "$pack_id default route aligned" || fail "$pack_id default route drift"

    gov_targets="$(sorted_yaml_values "$gov_manifest" '.support_target_refs')"
    admission_targets="$(sorted_yaml_values "$runtime_admission" '.support_target_refs')"
    registry_targets="$(sorted_yaml_values "$RUNTIME_REGISTRY" ".packs[] | select(.pack_id == \"$pack_id\") | .support_target_refs")"
    pack_route_targets="$(yq -r ".packs[] | select(.pack_id == \"$pack_id\") | .tuple_routes[]?.tuple_id // \"\"" "$PACK_ROUTES" 2>/dev/null | awk 'NF' | LC_ALL=C sort)"
    [[ "$gov_targets" == "$admission_targets" ]] && pass "$pack_id governance/runtime support targets aligned" || fail "$pack_id governance/runtime support target drift"
    [[ "$admission_targets" == "$registry_targets" ]] && pass "$pack_id runtime registry support targets aligned" || fail "$pack_id runtime registry support target drift"
    [[ "$admission_targets" == "$pack_route_targets" ]] && pass "$pack_id pack-route support targets aligned" || fail "$pack_id pack-route support target drift"

    admission_proof="$(sorted_yaml_values "$runtime_admission" '.required_proof')"
    registry_proof="$(sorted_yaml_values "$RUNTIME_REGISTRY" ".packs[] | select(.pack_id == \"$pack_id\") | .required_proof")"
    [[ "$admission_proof" == "$registry_proof" ]] && pass "$pack_id required proof aligned" || fail "$pack_id required proof drift"
  done < <(yq -r '.packs[]?.pack_id // ""' "$GOV_REGISTRY")

  while IFS= read -r tuple_id; do
    [[ -n "$tuple_id" ]] || continue
    claim_effect="$(yq -r ".tuple_admissions[] | select(.tuple_id == \"$tuple_id\") | .claim_effect // \"\"" "$SUPPORT_TARGETS")"
    dossier_ref="$(yq -r ".tuple_admissions[] | select(.tuple_id == \"$tuple_id\") | .support_dossier_ref // \"\"" "$SUPPORT_TARGETS")"
    dossier_path="$ROOT_DIR/$dossier_ref"
    [[ -f "$dossier_path" ]] || { fail "$tuple_id dossier missing: $dossier_ref"; continue; }

    while IFS= read -r pack_id; do
      [[ -n "$pack_id" ]] || continue
      registry_status="$(yq -r ".packs[] | select(.pack_id == \"$pack_id\") | .admission_status // \"\"" "$RUNTIME_REGISTRY")"
      if yq -e ".packs[] | select(.pack_id == \"$pack_id\") | .support_target_refs[] | select(. == \"$tuple_id\")" "$RUNTIME_REGISTRY" >/dev/null 2>&1; then
        pass "$tuple_id remains inside $pack_id support envelope"
      else
        fail "$tuple_id missing from $pack_id support envelope"
      fi
      if yq -e ".packs[] | select(.pack_id == \"$pack_id\") | .tuple_routes[] | select(.tuple_id == \"$tuple_id\" and .claim_effect == \"$claim_effect\")" "$PACK_ROUTES" >/dev/null 2>&1; then
        pass "$tuple_id claim effect remains explicit in pack route for $pack_id"
      else
        fail "$tuple_id claim effect missing from pack route for $pack_id"
      fi
      if [[ "$claim_effect" == "admitted-live-claim" && "$registry_status" != "admitted" ]]; then
        fail "$tuple_id is live but pack $pack_id is not admitted"
      fi
    done < <(yq -r '.admitted_capability_packs[]? // ""' "$dossier_path")
  done < <(yq -r '.tuple_admissions[]?.tuple_id // ""' "$SUPPORT_TARGETS")

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
