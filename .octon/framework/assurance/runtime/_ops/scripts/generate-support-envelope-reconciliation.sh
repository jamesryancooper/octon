#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/closure-packet-common.sh"

require_yq

SUPPORT_TARGETS="$OCTON_DIR/instance/governance/support-targets.yml"
GOVERNANCE_EXCLUSIONS="$OCTON_DIR/instance/governance/exclusions/action-classes.yml"
ROUTE_BUNDLE="$OCTON_DIR/generated/effective/runtime/route-bundle.yml"
ROUTE_LOCK="$OCTON_DIR/generated/effective/runtime/route-bundle.lock.yml"
PACK_ROUTES="$OCTON_DIR/generated/effective/capabilities/pack-routes.effective.yml"
PACK_LOCK="$OCTON_DIR/generated/effective/capabilities/pack-routes.lock.yml"
SUPPORT_MATRIX="$OCTON_DIR/generated/effective/governance/support-target-matrix.yml"
SUPPORT_CARD_ROOT="$OCTON_DIR/generated/cognition/projections/materialized/support-cards"
AUTHORED_HARNESS_CARD="$OCTON_DIR/instance/governance/disclosure/harness-card.yml"
RELEASE_LINEAGE="$OCTON_DIR/instance/governance/disclosure/release-lineage.yml"
REVOCATION_ROOT="$OCTON_DIR/state/control/execution/revocations"
OUT_PATH="${1:-$OCTON_DIR/generated/effective/governance/support-envelope-reconciliation.yml}"
CURRENT_DATE="${OCTON_CURRENT_DATE:-$(date -u +"%Y-%m-%d")}"

hash_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

yaml_quote() {
  local value="${1:-}"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  value="${value//$'\n'/\\n}"
  printf '"%s"' "$value"
}

resolve_repo_path() {
  local raw="$1"
  case "$raw" in
    /.octon/*|/.github/*)
      printf '%s/%s\n' "$ROOT_DIR" "${raw#/}"
      ;;
    .octon/*|.github/*)
      printf '%s/%s\n' "$ROOT_DIR" "$raw"
      ;;
    "")
      printf '\n'
      ;;
    *)
      printf '%s\n' "$raw"
      ;;
  esac
}

repo_rel() {
  local path="$1"
  case "$path" in
    "$ROOT_DIR"/*) printf '%s\n' "${path#$ROOT_DIR/}" ;;
    *) printf '%s\n' "$path" ;;
  esac
}

first_yq() {
  local expr="$1"
  local file="$2"
  if [[ -f "$file" ]]; then
    yq -r "$expr // \"\"" "$file" 2>/dev/null | head -n1
  fi
}

all_yq() {
  local expr="$1"
  local file="$2"
  if [[ -f "$file" ]]; then
    yq -r "$expr // \"\"" "$file" 2>/dev/null | awk 'NF'
  fi
}

tmpdir="$(mktemp -d)"
cleanup_tmpdir() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0
  find "$dir" -depth -mindepth 1 \( -type f -o -type l \) -exec rm -f {} +
  find "$dir" -depth -type d -empty -exec rmdir {} +
}
trap 'cleanup_tmpdir "$tmpdir"' EXIT

source_list="$tmpdir/source-files.txt"
tuple_list="$tmpdir/tuples.txt"
touch "$source_list" "$tuple_list"

add_source_file() {
  local raw="$1"
  local abs
  abs="$(resolve_repo_path "$raw")"
  [[ -n "$abs" && -f "$abs" ]] || return 0
  repo_rel "$abs" >>"$source_list"
}

add_tuple() {
  local tuple_id="$1"
  [[ -n "$tuple_id" && "$tuple_id" != "null" ]] || return 0
  printf '%s\n' "$tuple_id" >>"$tuple_list"
}

active_release_harness_card() {
  local ref
  ref="$(first_yq '.active_release.harness_card_ref' "$RELEASE_LINEAGE")"
  [[ -n "$ref" ]] || return 0
  resolve_repo_path "$ref"
}

for path in \
  "$SUPPORT_TARGETS" \
  "$GOVERNANCE_EXCLUSIONS" \
  "$ROUTE_BUNDLE" \
  "$ROUTE_LOCK" \
  "$PACK_ROUTES" \
  "$PACK_LOCK" \
  "$SUPPORT_MATRIX" \
  "$AUTHORED_HARNESS_CARD" \
  "$RELEASE_LINEAGE"
do
  add_source_file "$path"
done

active_harness="$(active_release_harness_card)"
[[ -f "$active_harness" ]] && add_source_file "$active_harness"

while IFS=$'\t' read -r tuple_id admission_ref dossier_ref proof_ref card_ref; do
  add_tuple "$tuple_id"
  add_source_file "$admission_ref"
  add_source_file "$dossier_ref"
  add_source_file "$proof_ref"
  add_source_file "$card_ref"
done < <(yq -r '.tuple_admissions[]? | [.tuple_id, (.admission_ref // ""), (.support_dossier_ref // ""), (.proof_bundle_ref // ""), (.support_card_ref // "")] | @tsv' "$SUPPORT_TARGETS" 2>/dev/null || true)

if [[ -d "$SUPPORT_CARD_ROOT" ]]; then
  find "$SUPPORT_CARD_ROOT" -type f -name '*.yml' -print | sort | while IFS= read -r card; do
    add_source_file "$card"
    add_tuple "$(first_yq '.tuple_id' "$card")"
  done
fi

if [[ -d "$REVOCATION_ROOT" ]]; then
  find "$REVOCATION_ROOT" -type f -name '*.yml' -print | sort | while IFS= read -r revocation; do
    add_source_file "$revocation"
  done
fi

all_yq '.routes[]?.tuple_id' "$ROUTE_BUNDLE" | while IFS= read -r tuple_id; do add_tuple "$tuple_id"; done
all_yq '.supported_tuples[]?.tuple_id' "$SUPPORT_MATRIX" | while IFS= read -r tuple_id; do add_tuple "$tuple_id"; done
all_yq '.packs[]?.tuple_routes[]?.tuple_id' "$PACK_ROUTES" | while IFS= read -r tuple_id; do add_tuple "$tuple_id"; done

sort -u "$source_list" -o "$source_list"
sort -u "$tuple_list" -o "$tuple_list"

source_digest_file="$tmpdir/source-digests.txt"
touch "$source_digest_file"
while IFS= read -r rel; do
  [[ -n "$rel" ]] || continue
  abs="$ROOT_DIR/$rel"
  [[ -f "$abs" ]] || continue
  printf '%s %s\n' "$rel" "$(hash_file "$abs")" >>"$source_digest_file"
done <"$source_list"

source_digest_hash="$(hash_file "$source_digest_file")"
generation_id="support-envelope-${source_digest_hash:0:12}"

global_freshness_error=0
global_freshness_reasons=()

add_global_freshness_reason() {
  local reason="$1"
  local item
  global_freshness_error=1
  for item in "${global_freshness_reasons[@]-}"; do
    [[ "$item" == "$reason" ]] && return 0
  done
  global_freshness_reasons[${#global_freshness_reasons[@]}]="$reason"
}

check_publication_receipt() {
  local lock_file="$1"
  local label="$2"
  local receipt_ref receipt_abs expected actual
  receipt_ref="$(first_yq '.publication_receipt_path // .publication_receipt_ref' "$lock_file")"
  if [[ -z "$receipt_ref" ]]; then
    add_global_freshness_reason "$label missing publication receipt ref"
    return 0
  fi
  receipt_abs="$(resolve_repo_path "$receipt_ref")"
  if [[ ! -f "$receipt_abs" ]]; then
    add_global_freshness_reason "$label missing publication receipt"
    return 0
  fi
  expected="$(first_yq '.publication_receipt_sha256' "$lock_file")"
  if [[ -n "$expected" ]]; then
    actual="$(hash_file "$receipt_abs")"
    [[ "$expected" == "$actual" ]] || add_global_freshness_reason "$label publication receipt digest drift"
  fi
}

check_lock_common() {
  local lock_file="$1"
  local label="$2"
  if [[ ! -f "$lock_file" ]]; then
    add_global_freshness_reason "$label lock missing"
    return 0
  fi
  case "$(first_yq '.freshness.mode' "$lock_file")" in
    digest_bound|ttl_bound|receipt_bound) ;;
    *) add_global_freshness_reason "$label invalid freshness mode" ;;
  esac
  yq -e '.freshness.invalidation_conditions | length > 0' "$lock_file" >/dev/null 2>&1 \
    || add_global_freshness_reason "$label missing invalidation conditions"
  [[ "$(first_yq '.publication_status' "$lock_file")" == "published" ]] \
    || add_global_freshness_reason "$label not published"
  check_publication_receipt "$lock_file" "$label"
}

check_digest_field() {
  local lock_file="$1"
  local expr="$2"
  local source_file="$3"
  local label="$4"
  [[ -f "$lock_file" && -f "$source_file" ]] || return 0
  local expected actual
  expected="$(first_yq "$expr" "$lock_file")"
  actual="$(hash_file "$source_file")"
  [[ -n "$expected" && "$expected" == "$actual" ]] || add_global_freshness_reason "$label digest drift"
}

check_lock_common "$ROUTE_LOCK" "runtime route bundle"
check_lock_common "$PACK_LOCK" "pack routes"
check_digest_field "$ROUTE_LOCK" '.route_bundle_sha256' "$ROUTE_BUNDLE" "runtime route bundle"
check_digest_field "$ROUTE_LOCK" '.source_digests.support_target_matrix_sha256' "$SUPPORT_MATRIX" "runtime route support matrix"
check_digest_field "$ROUTE_LOCK" '.source_digests.pack_routes_effective_sha256' "$PACK_ROUTES" "runtime route pack routes"
check_digest_field "$ROUTE_LOCK" '.source_digests.pack_routes_lock_sha256' "$PACK_LOCK" "runtime route pack lock"
check_digest_field "$PACK_LOCK" '.pack_routes_sha256' "$PACK_ROUTES" "pack routes output"
check_digest_field "$PACK_LOCK" '.support_targets_sha256' "$SUPPORT_TARGETS" "pack routes support targets"
check_digest_field "$PACK_LOCK" '.support_target_matrix_sha256' "$SUPPORT_MATRIX" "pack routes support matrix"

harness_overclaims=0
check_harness_list_subset() {
  local card="$1"
  local card_expr="$2"
  local support_expr="$3"
  local value
  [[ -f "$card" ]] || return 0
  while IFS= read -r value; do
    [[ -n "$value" ]] || continue
    if ! yq -e "$support_expr[]? | select(. == \"$value\")" "$SUPPORT_TARGETS" >/dev/null 2>&1; then
      harness_overclaims=1
    fi
  done < <(all_yq "$card_expr[]?" "$card")
}

check_harness_list_subset "$AUTHORED_HARNESS_CARD" '.support_universe.model_classes' '.live_support_universe.model_classes'
check_harness_list_subset "$AUTHORED_HARNESS_CARD" '.support_universe.workload_classes' '.live_support_universe.workload_classes'
check_harness_list_subset "$AUTHORED_HARNESS_CARD" '.support_universe.context_classes' '.live_support_universe.context_classes'
check_harness_list_subset "$AUTHORED_HARNESS_CARD" '.support_universe.locale_classes' '.live_support_universe.locale_classes'
check_harness_list_subset "$AUTHORED_HARNESS_CARD" '.retained_adapters.host_adapters' '.live_support_universe.host_adapters'
check_harness_list_subset "$AUTHORED_HARNESS_CARD" '.retained_adapters.model_adapters' '.live_support_universe.model_adapters'
check_harness_list_subset "$AUTHORED_HARNESS_CARD" '.capability_packs' '.live_support_universe.capability_packs'
if [[ -f "$active_harness" ]]; then
  check_harness_list_subset "$active_harness" '.support_universe.model_classes' '.live_support_universe.model_classes'
  check_harness_list_subset "$active_harness" '.support_universe.workload_classes' '.live_support_universe.workload_classes'
  check_harness_list_subset "$active_harness" '.support_universe.context_classes' '.live_support_universe.context_classes'
  check_harness_list_subset "$active_harness" '.support_universe.locale_classes' '.live_support_universe.locale_classes'
  check_harness_list_subset "$active_harness" '.retained_adapters.host_adapters' '.live_support_universe.host_adapters'
  check_harness_list_subset "$active_harness" '.retained_adapters.model_adapters' '.live_support_universe.model_adapters'
  check_harness_list_subset "$active_harness" '.capability_packs' '.live_support_universe.capability_packs'
fi

tuple_field() {
  local tuple_id="$1"
  local key="$2"
  local admission_ref admission_abs
  admission_ref="$(first_yq ".tuple_admissions[]? | select(.tuple_id == \"$tuple_id\") | .admission_ref" "$SUPPORT_TARGETS")"
  admission_abs="$(resolve_repo_path "$admission_ref")"
  if [[ -f "$admission_abs" ]]; then
    first_yq ".tuple.$key" "$admission_abs"
    return 0
  fi
  first_yq ".routes[]? | select(.tuple_id == \"$tuple_id\") | .tuple.$key" "$ROUTE_BUNDLE"
}

component_in_list() {
  local value="$1"
  local expr="$2"
  [[ -n "$value" ]] || return 1
  yq -e "$expr[]? | select(. == \"$value\")" "$SUPPORT_TARGETS" >/dev/null 2>&1
}

tuple_outside_live_or_in_non_live() {
  local tuple_id="$1"
  local model workload language locale host model_adapter
  model="$(tuple_field "$tuple_id" model_tier)"
  workload="$(tuple_field "$tuple_id" workload_tier)"
  language="$(tuple_field "$tuple_id" language_resource_tier)"
  locale="$(tuple_field "$tuple_id" locale_tier)"
  host="$(tuple_field "$tuple_id" host_adapter)"
  model_adapter="$(tuple_field "$tuple_id" model_adapter)"

  component_in_list "$model" '.resolved_non_live_surfaces.model_classes' && return 0
  component_in_list "$workload" '.resolved_non_live_surfaces.workload_classes' && return 0
  component_in_list "$language" '.resolved_non_live_surfaces.context_classes' && return 0
  component_in_list "$locale" '.resolved_non_live_surfaces.locale_classes' && return 0
  component_in_list "$host" '.resolved_non_live_surfaces.host_adapters' && return 0
  component_in_list "$model_adapter" '.resolved_non_live_surfaces.model_adapters' && return 0

  component_in_list "$model" '.live_support_universe.model_classes' || return 0
  component_in_list "$workload" '.live_support_universe.workload_classes' || return 0
  component_in_list "$language" '.live_support_universe.context_classes' || return 0
  component_in_list "$locale" '.live_support_universe.locale_classes' || return 0
  component_in_list "$host" '.live_support_universe.host_adapters' || return 0
  component_in_list "$model_adapter" '.live_support_universe.model_adapters' || return 0
  return 1
}

normalize_route() {
  case "${1:-}" in
    allow) printf 'allow\n' ;;
    stage_only|stage-only) printf 'stage_only\n' ;;
    deny|denied) printf 'deny\n' ;;
    *) printf 'unknown\n' ;;
  esac
}

normalize_declared() {
  case "${1:-}" in
    admitted-live-claim) printf 'live\n' ;;
    stage-only-non-live|stage_only|stage-only) printf 'stage_only\n' ;;
    unsupported|retired|unadmitted) printf 'unsupported\n' ;;
    excluded) printf 'excluded\n' ;;
    *) printf 'unknown\n' ;;
  esac
}

normalize_admitted() {
  local status="$1"
  local admission_ref="$2"
  case "$status" in
    supported) printf 'live\n' ;;
    stage_only|stage-only) printf 'stage_only\n' ;;
    unadmitted|retired|unsupported) printf 'unadmitted\n' ;;
    *)
      case "$admission_ref" in
        *"/stage-only/"*) printf 'stage_only\n' ;;
        *"/live/"*) printf 'live\n' ;;
        *) printf 'unknown\n' ;;
      esac
      ;;
  esac
}

proof_posture() {
  local proof_file="$1"
  local declared="$2"
  if [[ ! -f "$proof_file" ]]; then
    printf 'missing\n'
    return 0
  fi
  if [[ "$(first_yq '.result' "$proof_file")" != "pass" ]]; then
    printf 'insufficient\n'
    return 0
  fi
  if [[ -z "$(first_yq '.command_or_evaluator' "$proof_file")" && -z "$(first_yq '.evaluator_version' "$proof_file")" ]]; then
    printf 'insufficient\n'
    return 0
  fi
  if [[ "$(first_yq '.freshness.status' "$proof_file")" != "current" ]]; then
    printf 'stale\n'
    return 0
  fi
  local review_due review_due_date
  review_due="$(first_yq '.freshness.review_due_at // .review_due_at' "$proof_file")"
  review_due_date="${review_due%%T*}"
  if [[ -n "$review_due_date" && "$review_due_date" < "$CURRENT_DATE" ]]; then
    printf 'stale\n'
    return 0
  fi
  local sufficiency_status minimum_runs current_runs
  sufficiency_status="$(first_yq '.sufficiency.status' "$proof_file")"
  if [[ "$declared" == "live" && "$sufficiency_status" != "qualified" ]]; then
    printf 'insufficient\n'
    return 0
  fi
  minimum_runs="$(first_yq '.sufficiency.minimum_retained_runs' "$proof_file")"
  current_runs="$(first_yq '.sufficiency.current_retained_runs' "$proof_file")"
  if [[ -n "$minimum_runs" && -n "$current_runs" && "$current_runs" =~ ^[0-9]+$ && "$minimum_runs" =~ ^[0-9]+$ ]]; then
    if [[ "$current_runs" -lt "$minimum_runs" ]]; then
      printf 'insufficient\n'
      return 0
    fi
  fi
  printf 'fresh\n'
}

pack_route_posture() {
  local tuple_id="$1"
  local routes_file="$tmpdir/pack-route-values.txt"
  all_yq ".packs[]?.tuple_routes[]? | select(.tuple_id == \"$tuple_id\") | .route" "$PACK_ROUTES" \
    | sed 's/stage-only/stage_only/g' \
    | sort -u >"$routes_file"
  local count first
  count="$(awk 'NF { c++ } END { print c + 0 }' "$routes_file")"
  if [[ "$count" -eq 0 ]]; then
    printf 'unknown\n'
    return 0
  fi
  first="$(head -n1 "$routes_file")"
  if [[ "$count" -gt 1 ]]; then
    printf 'mixed\n'
    return 0
  fi
  normalize_route "$first"
}

matrix_posture() {
  local tuple_id="$1"
  if [[ ! -f "$SUPPORT_MATRIX" ]]; then
    printf 'unknown\n'
    return 0
  fi
  if yq -e ".supported_tuples[]? | select(.tuple_id == \"$tuple_id\")" "$SUPPORT_MATRIX" >/dev/null 2>&1; then
    printf 'supported\n'
  else
    printf 'not_supported\n'
  fi
}

run_id_from_ref() {
  local ref="$1"
  case "$ref" in
    *"/runs/"*)
      printf '%s\n' "$ref" | awk -F'/runs/' '{print $2}' | cut -d/ -f1
      ;;
  esac
}

run_is_revoked() {
  local run_id="$1"
  [[ -n "$run_id" && -d "$REVOCATION_ROOT" ]] || return 1
  local revocation
  while IFS= read -r revocation; do
    [[ "$(first_yq '.state' "$revocation")" == "active" ]] || continue
    [[ "$(first_yq '.run_id' "$revocation")" == "$run_id" ]] && return 0
  done < <(find "$REVOCATION_ROOT" -type f -name '*.yml' -print 2>/dev/null | sort)
  return 1
}

tuple_has_revoked_live_evidence() {
  local proof_file="$1"
  [[ -f "$proof_file" ]] || return 1
  local ref run_id
  while IFS= read -r ref; do
    run_id="$(run_id_from_ref "$ref")"
    if run_is_revoked "$run_id"; then
      return 0
    fi
  done < <(
    {
      all_yq '.scenario_evidence.representative_run_refs[]?' "$proof_file"
      all_yq '.disclosure_evidence.run_card_refs[]?' "$proof_file"
    } | awk 'NF' | sort -u
  )
  return 1
}

write_result() {
  local output="$1"
  local status="reconciled"
  local body="$tmpdir/tuples.yml"
  : >"$body"

  while IFS= read -r tuple_id; do
    [[ -n "$tuple_id" ]] || continue
    diagnostics=()
    add_diag() {
      local diag="$1"
      local existing
      for existing in "${diagnostics[@]-}"; do
        [[ "$existing" == "$diag" ]] && return 0
      done
      diagnostics[${#diagnostics[@]}]="$diag"
    }

    support_claim_effect="$(first_yq ".tuple_admissions[]? | select(.tuple_id == \"$tuple_id\") | .claim_effect" "$SUPPORT_TARGETS")"
    declared="$(normalize_declared "$support_claim_effect")"
    admission_ref="$(first_yq ".tuple_admissions[]? | select(.tuple_id == \"$tuple_id\") | .admission_ref" "$SUPPORT_TARGETS")"
    dossier_ref="$(first_yq ".tuple_admissions[]? | select(.tuple_id == \"$tuple_id\") | .support_dossier_ref" "$SUPPORT_TARGETS")"
    proof_ref="$(first_yq ".tuple_admissions[]? | select(.tuple_id == \"$tuple_id\") | .proof_bundle_ref" "$SUPPORT_TARGETS")"
    card_ref="$(first_yq ".tuple_admissions[]? | select(.tuple_id == \"$tuple_id\") | .support_card_ref" "$SUPPORT_TARGETS")"
    admission_abs="$(resolve_repo_path "$admission_ref")"
    dossier_abs="$(resolve_repo_path "$dossier_ref")"
    proof_abs="$(resolve_repo_path "$proof_ref")"
    card_abs="$(resolve_repo_path "$card_ref")"

    admission_status="$(first_yq '.status' "$admission_abs")"
    admitted="$(normalize_admitted "$admission_status" "$admission_ref")"
    proof="$(proof_posture "$proof_abs" "$declared")"
    route="$(normalize_route "$(first_yq ".routes[]? | select(.tuple_id == \"$tuple_id\") | .route" "$ROUTE_BUNDLE")")"
    route_claim_effect="$(first_yq ".routes[]? | select(.tuple_id == \"$tuple_id\") | .claim_effect" "$ROUTE_BUNDLE")"
    pack_route="$(pack_route_posture "$tuple_id")"
    generated_matrix="$(matrix_posture "$tuple_id")"
    disclosure="matches"

    if [[ -n "$card_ref" && ! -f "$card_abs" ]]; then
      disclosure="missing"
    elif [[ -z "$card_ref" && "$declared" != "unknown" ]]; then
      disclosure="missing"
    fi

    card_claim_effect="$(first_yq '.claim_effect' "$card_abs")"
    if [[ -n "$card_claim_effect" ]]; then
      if [[ "$card_claim_effect" == "admitted-live-claim" && "$declared" != "live" ]]; then
        add_diag "support_card_overclaims_reconciled_support"
        disclosure="overclaims"
      elif [[ "$declared" == "live" && "$card_claim_effect" != "$support_claim_effect" ]]; then
        add_diag "support_card_overclaims_reconciled_support"
        disclosure="overclaims"
      fi
    fi

    if [[ "$harness_overclaims" -eq 1 ]]; then
      add_diag "disclosure_overclaims_reconciled_support"
      disclosure="overclaims"
    fi

    if [[ "$declared" == "live" ]]; then
      [[ "$admitted" == "live" ]] || add_diag "declared_live_without_live_admission"
      [[ -f "$admission_abs" ]] || add_diag "missing_support_admission"
      [[ -f "$dossier_abs" ]] || add_diag "missing_support_dossier"
      case "$proof" in
        missing)
          add_diag "missing_proof_bundle"
          add_diag "declared_live_without_fresh_proof"
          ;;
        stale)
          add_diag "stale_proof_bundle"
          add_diag "declared_live_without_fresh_proof"
          ;;
        insufficient)
          add_diag "declared_live_without_fresh_proof"
          ;;
      esac
      if [[ "$route" == "stage_only" ]]; then
        add_diag "route_stage_only_but_support_declares_live"
      elif [[ "$route" != "allow" ]]; then
        add_diag "route_missing_for_declared_live"
      fi
      if [[ "$route_claim_effect" != "admitted-live-claim" ]]; then
        add_diag "route_claim_effect_mismatch"
      fi
      if [[ "$generated_matrix" != "supported" && "$proof" == "fresh" && "$admitted" == "live" && "$route" == "allow" ]]; then
        add_diag "generated_matrix_omits_declared_live_claim"
      fi
      if [[ "$disclosure" == "missing" ]]; then
        add_diag "support_card_missing"
      fi
      if tuple_outside_live_or_in_non_live "$tuple_id"; then
        add_diag "excluded_target_presented_live"
      fi
      if tuple_has_revoked_live_evidence "$proof_abs"; then
        add_diag "revoked_support_evidence"
      fi
      if [[ "$global_freshness_error" -eq 1 ]]; then
        add_diag "stale_lock_or_missing_freshness"
      fi
    fi

    if [[ "$route" == "allow" && "$declared" != "live" ]]; then
      add_diag "route_live_without_declared_support"
    fi
    if [[ "$route_claim_effect" == "admitted-live-claim" && "$declared" != "live" ]]; then
      add_diag "route_live_without_declared_support"
    fi
    if [[ "$generated_matrix" == "supported" && ! ( "$declared" == "live" && "$admitted" == "live" && "$proof" == "fresh" && "$route" == "allow" ) ]]; then
      add_diag "generated_matrix_widens_authority"
    fi
    if [[ "$route" != "allow" ]]; then
      if yq -e ".packs[]?.tuple_routes[]? | select(.tuple_id == \"$tuple_id\" and .route == \"allow\")" "$PACK_ROUTES" >/dev/null 2>&1; then
        add_diag "pack_route_widens_runtime_route"
      fi
    fi

    if [[ "$declared" == "live" ]]; then
      while IFS= read -r pack_id; do
        [[ -n "$pack_id" ]] || continue
        pack_status="$(first_yq ".packs[]? | select(.pack_id == \"$pack_id\") | .admission_status" "$PACK_ROUTES")"
        pack_tuple_route="$(first_yq ".packs[]? | select(.pack_id == \"$pack_id\") | .tuple_routes[]? | select(.tuple_id == \"$tuple_id\") | .route" "$PACK_ROUTES")"
        if [[ "$pack_status" != "admitted" || "$(normalize_route "$pack_tuple_route")" != "allow" ]]; then
          add_diag "capability_pack_inconsistent"
        fi
      done < <(all_yq '.allowed_capability_packs[]?' "$admission_abs")

      while IFS= read -r pack_id; do
        [[ -n "$pack_id" ]] || continue
        if ! yq -e ".allowed_capability_packs[]? | select(. == \"$pack_id\")" "$admission_abs" >/dev/null 2>&1; then
          add_diag "pack_route_widens_runtime_route"
        fi
      done < <(yq -r ".packs[]? | select(.tuple_routes[]? | select(.tuple_id == \"$tuple_id\" and .route == \"allow\")) | .pack_id" "$PACK_ROUTES" 2>/dev/null | awk 'NF' | sort -u)
    fi

    if [[ "$generated_matrix" == "supported" ]]; then
      while IFS= read -r pack_id; do
        [[ -n "$pack_id" ]] || continue
        if ! yq -e ".tuple_admissions[]? | select(.tuple_id == \"$tuple_id\") | .admission_ref as \$ref | true" "$SUPPORT_TARGETS" >/dev/null 2>&1; then
          add_diag "generated_matrix_widens_authority"
          continue
        fi
        if [[ -f "$admission_abs" ]] && ! yq -e ".allowed_capability_packs[]? | select(. == \"$pack_id\")" "$admission_abs" >/dev/null 2>&1; then
          add_diag "generated_matrix_widens_authority"
        fi
      done < <(all_yq ".supported_tuples[]? | select(.tuple_id == \"$tuple_id\") | .capability_packs[]?" "$SUPPORT_MATRIX")
    fi

    effective="unsupported"
    if [[ "${#diagnostics[@]}" -gt 0 ]]; then
      effective="blocked"
      status="failed"
    elif [[ "$declared" == "live" ]]; then
      effective="live"
    elif [[ "$declared" == "stage_only" || "$admitted" == "stage_only" || "$route" == "stage_only" ]]; then
      effective="stage_only"
    fi

    {
      printf '  - tuple_ref: %s\n' "$(yaml_quote "$tuple_id")"
      printf '    declared: %s\n' "$(yaml_quote "$declared")"
      printf '    admitted: %s\n' "$(yaml_quote "$admitted")"
      printf '    proof: %s\n' "$(yaml_quote "$proof")"
      printf '    route: %s\n' "$(yaml_quote "$route")"
      printf '    pack_route: %s\n' "$(yaml_quote "$pack_route")"
      printf '    generated_matrix: %s\n' "$(yaml_quote "$generated_matrix")"
      printf '    disclosure: %s\n' "$(yaml_quote "$disclosure")"
      printf '    effective: %s\n' "$(yaml_quote "$effective")"
      if [[ "${#diagnostics[@]}" -eq 0 ]]; then
        printf '    diagnostics: []\n'
      else
        printf '    diagnostics:\n'
        local_diag_i=0
        while [[ "$local_diag_i" -lt "${#diagnostics[@]}" ]]; do
          printf '      - %s\n' "$(yaml_quote "${diagnostics[$local_diag_i]}")"
          local_diag_i=$((local_diag_i + 1))
        done
      fi
    } >>"$body"
  done <"$tuple_list"

  {
    printf 'schema_version: "support-envelope-reconciliation-result-v1"\n'
    printf 'status: %s\n' "$(yaml_quote "$status")"
    printf 'generation_id: %s\n' "$(yaml_quote "$generation_id")"
    printf 'generated_at: %s\n' "$(yaml_quote "$(deterministic_generated_at)")"
    printf 'non_authority_classification: "derived-runtime-handle"\n'
    printf 'freshness:\n'
    printf '  mode: "digest_bound"\n'
    printf '  invalidation_conditions:\n'
    printf '    - "support-targets-sha-changed"\n'
    printf '    - "support-admission-or-dossier-sha-changed"\n'
    printf '    - "support-proof-bundle-sha-changed"\n'
    printf '    - "runtime-route-bundle-sha-changed"\n'
    printf '    - "pack-routes-sha-changed"\n'
    printf '    - "support-matrix-sha-changed"\n'
    printf '    - "support-card-or-disclosure-sha-changed"\n'
    printf 'allowed_consumers:\n'
    printf '  - "publication-workflows"\n'
    printf '  - "validators"\n'
    printf '  - "operators"\n'
    printf 'forbidden_consumers:\n'
    printf '  - "authority-minting"\n'
    printf '  - "support-claim-widening"\n'
    printf '  - "direct-runtime-raw-path-read"\n'
    printf 'source_refs:\n'
    while IFS= read -r rel; do
      [[ -n "$rel" ]] || continue
      printf '  - %s\n' "$(yaml_quote "$rel")"
    done <"$source_list"
    printf 'source_digests:\n'
    while IFS=' ' read -r rel digest; do
      [[ -n "$rel" && -n "$digest" ]] || continue
      printf '  %s: %s\n' "$(yaml_quote "$rel")" "$(yaml_quote "$digest")"
    done <"$source_digest_file"
    if [[ "${#global_freshness_reasons[@]}" -eq 0 ]]; then
      printf 'freshness_diagnostics: []\n'
    else
      printf 'freshness_diagnostics:\n'
      freshness_i=0
      while [[ "$freshness_i" -lt "${#global_freshness_reasons[@]}" ]]; do
        printf '  - %s\n' "$(yaml_quote "${global_freshness_reasons[$freshness_i]}")"
        freshness_i=$((freshness_i + 1))
      done
    fi
    printf 'tuples:\n'
    cat "$body"
  } >"$output"
}

if [[ "$OUT_PATH" == "-" ]]; then
  tmp_out="$tmpdir/support-envelope-reconciliation.yml"
  write_result "$tmp_out"
  cat "$tmp_out"
else
  mkdir -p "$(dirname "$OUT_PATH")"
  tmp_out="$tmpdir/support-envelope-reconciliation.yml"
  write_result "$tmp_out"
  cp "$tmp_out" "$OUT_PATH"
fi
