#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

ROOT_MANIFEST="$OCTON_DIR/octon.yml"
LOCALITY_MANIFEST="$OCTON_DIR/instance/locality/manifest.yml"
LOCALITY_REGISTRY="$OCTON_DIR/instance/locality/registry.yml"
QUARANTINE_STATE="$OCTON_DIR/state/control/locality/quarantine.yml"
SCOPES_EFFECTIVE_FILE="$OCTON_DIR/generated/effective/locality/scopes.effective.yml"
ARTIFACT_MAP_FILE="$OCTON_DIR/generated/effective/locality/artifact-map.yml"
GENERATION_LOCK_FILE="$OCTON_DIR/generated/effective/locality/generation.lock.yml"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

hash_file() {
  local file="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
  else
    sha256sum "$file" | awk '{print $1}'
  fi
}

hash_text_stream() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 | awk '{print $1}'
  else
    sha256sum | awk '{print $1}'
  fi
}

hash_directory_payload() {
  local dir="$1"
  local marker="$2"
  if [[ ! -d "$dir" ]]; then
    printf '%s' "$marker" | hash_text_stream
    return 0
  fi
  find "$dir" -type f | LC_ALL=C sort | while IFS= read -r abs_path; do
    [[ -n "$abs_path" ]] || continue
    printf '%s %s\n' "$(hash_file "$abs_path")" "${abs_path#$ROOT_DIR/}"
  done | hash_text_stream
}

scope_continuity_digest() {
  local scope_id="$1"
  hash_directory_payload "$OCTON_DIR/state/continuity/scopes/$scope_id" "__absent_scope_continuity__"
}

scope_decision_evidence_digest() {
  local scope_id="$1"
  hash_directory_payload "$OCTON_DIR/state/evidence/decisions/scopes/$scope_id" "__absent_scope_decision_evidence__"
}

require_yaml_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    fail "missing file: ${file#$ROOT_DIR/}"
    return 1
  fi
  pass "found file: ${file#$ROOT_DIR/}"
  if yq -e '.' "$file" >/dev/null 2>&1; then
    pass "${file#$ROOT_DIR/} parses as YAML"
  else
    fail "${file#$ROOT_DIR/} must parse as YAML"
  fi
}

main() {
  echo "== Locality Publication State Validation =="

  require_yaml_file "$LOCALITY_MANIFEST"
  require_yaml_file "$LOCALITY_REGISTRY"
  require_yaml_file "$QUARANTINE_STATE"
  require_yaml_file "$SCOPES_EFFECTIVE_FILE"
  require_yaml_file "$ARTIFACT_MAP_FILE"
  require_yaml_file "$GENERATION_LOCK_FILE"
  require_yaml_file "$ROOT_MANIFEST"

  [[ "$(yq -r '.schema_version // ""' "$QUARANTINE_STATE")" == "octon-locality-quarantine-state-v2" ]] \
    && pass "locality quarantine schema version valid" \
    || fail "locality quarantine schema_version invalid"
  [[ "$(yq -r '.schema_version // ""' "$SCOPES_EFFECTIVE_FILE")" == "octon-locality-effective-scopes-v2" ]] \
    && pass "effective locality schema version valid" \
    || fail "effective locality schema_version invalid"
  [[ "$(yq -r '.schema_version // ""' "$ARTIFACT_MAP_FILE")" == "octon-locality-artifact-map-v2" ]] \
    && pass "locality artifact map schema version valid" \
    || fail "locality artifact map schema_version invalid"
  [[ "$(yq -r '.schema_version // ""' "$GENERATION_LOCK_FILE")" == "octon-locality-generation-lock-v2" ]] \
    && pass "locality generation lock schema version valid" \
    || fail "locality generation lock schema_version invalid"

  local expected_generator_version
  expected_generator_version="$(yq -r '.versioning.harness.release_version // ""' "$ROOT_MANIFEST" 2>/dev/null || true)"
  [[ -n "$expected_generator_version" ]] \
    && pass "root manifest generator version available" \
    || fail "root manifest missing versioning.harness.release_version"
  [[ "$(yq -r '.generator_version // ""' "$SCOPES_EFFECTIVE_FILE")" == "$expected_generator_version" ]] \
    && pass "effective locality generator_version current" \
    || fail "effective locality generator_version missing or stale"
  [[ "$(yq -r '.generator_version // ""' "$ARTIFACT_MAP_FILE")" == "$expected_generator_version" ]] \
    && pass "artifact map generator_version current" \
    || fail "artifact map generator_version missing or stale"
  [[ "$(yq -r '.generator_version // ""' "$GENERATION_LOCK_FILE")" == "$expected_generator_version" ]] \
    && pass "generation lock generator_version current" \
    || fail "generation lock generator_version missing or stale"

  local generation_id
  generation_id="$(yq -r '.generation_id // ""' "$SCOPES_EFFECTIVE_FILE")"
  [[ -n "$generation_id" ]] && pass "effective locality generation_id declared" || fail "effective locality missing generation_id"

  [[ "$(yq -r '.generation_id // ""' "$ARTIFACT_MAP_FILE")" == "$generation_id" ]] \
    && pass "artifact map generation_id matches effective locality" \
    || fail "artifact map generation_id mismatch"
  [[ "$(yq -r '.generation_id // ""' "$GENERATION_LOCK_FILE")" == "$generation_id" ]] \
    && pass "generation lock generation_id matches effective locality" \
    || fail "generation lock generation_id mismatch"

  local manifest_sha registry_sha quarantine_sha
  manifest_sha="$(hash_file "$LOCALITY_MANIFEST")"
  registry_sha="$(hash_file "$LOCALITY_REGISTRY")"
  quarantine_sha="$(hash_file "$QUARANTINE_STATE")"
  local publication_status receipt_rel receipt_abs receipt_sha quarantine_count
  publication_status="$(yq -r '.publication_status // ""' "$SCOPES_EFFECTIVE_FILE")"
  receipt_rel="$(yq -r '.publication_receipt_path // ""' "$SCOPES_EFFECTIVE_FILE")"
  receipt_abs="$ROOT_DIR/$receipt_rel"
  quarantine_count="$(yq -r '.records | length' "$QUARANTINE_STATE" 2>/dev/null || printf '0')"

  case "$publication_status" in
    published|published_with_quarantine)
      pass "effective locality publication status valid"
      ;;
    *)
      fail "effective locality publication status invalid"
      ;;
  esac
  [[ -n "$receipt_rel" ]] && pass "effective locality receipt path declared" || fail "effective locality missing receipt path"
  if [[ -f "$receipt_abs" ]]; then
    pass "locality publication receipt file exists"
    yq -e '.' "$receipt_abs" >/dev/null 2>&1 && pass "locality publication receipt parses as YAML" || fail "locality publication receipt must parse as YAML"
  else
    fail "locality publication receipt file missing"
  fi
  [[ "$(yq -r '.schema_version // ""' "$receipt_abs" 2>/dev/null)" == "octon-validation-publication-receipt-v1" ]] && pass "locality publication receipt schema version valid" || fail "locality publication receipt schema version invalid"
  [[ "$(yq -r '.publication_family // ""' "$receipt_abs" 2>/dev/null)" == "locality" ]] && pass "locality publication receipt family valid" || fail "locality publication receipt family invalid"
  [[ "$(yq -r '.generation_id // ""' "$receipt_abs" 2>/dev/null)" == "$generation_id" ]] && pass "locality publication receipt generation id matches" || fail "locality publication receipt generation id mismatch"
  [[ "$(yq -r '.result // ""' "$receipt_abs" 2>/dev/null)" == "$publication_status" ]] && pass "locality publication receipt result matches" || fail "locality publication receipt result mismatch"
  yq -e '.contract_refs | length > 0' "$receipt_abs" >/dev/null 2>&1 && pass "locality publication receipt contract refs declared" || fail "locality publication receipt contract refs missing"
  receipt_sha="$(hash_file "$receipt_abs")"
  [[ "$(yq -r '.publication_receipt_path // ""' "$GENERATION_LOCK_FILE")" == "$receipt_rel" ]] && pass "generation lock receipt path matches effective locality" || fail "generation lock receipt path mismatch"
  [[ "$(yq -r '.publication_receipt_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$receipt_sha" ]] && pass "generation lock receipt hash current" || fail "generation lock receipt hash stale"
  [[ "$(yq -r '.publication_status // ""' "$GENERATION_LOCK_FILE")" == "$publication_status" ]] && pass "generation lock publication status matches" || fail "generation lock publication status mismatch"

  [[ "$(yq -r '.source.locality_manifest_sha256 // ""' "$SCOPES_EFFECTIVE_FILE")" == "$manifest_sha" ]] \
    && pass "effective locality manifest hash current" \
    || fail "effective locality manifest hash stale"
  [[ "$(yq -r '.source.locality_registry_sha256 // ""' "$SCOPES_EFFECTIVE_FILE")" == "$registry_sha" ]] \
    && pass "effective locality registry hash current" \
    || fail "effective locality registry hash stale"
  [[ "$(yq -r '.source.quarantine_path // ""' "$SCOPES_EFFECTIVE_FILE")" == ".octon/state/control/locality/quarantine.yml" ]] \
    && pass "effective locality quarantine path valid" \
    || fail "effective locality quarantine path invalid"
  [[ "$(yq -r '.source.quarantine_sha256 // ""' "$SCOPES_EFFECTIVE_FILE")" == "$quarantine_sha" ]] \
    && pass "effective locality quarantine hash current" \
    || fail "effective locality quarantine hash stale"
  [[ "$(yq -r '.locality_manifest_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$manifest_sha" ]] \
    && pass "generation lock locality manifest hash current" \
    || fail "generation lock locality manifest hash stale"
  [[ "$(yq -r '.locality_registry_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$registry_sha" ]] \
    && pass "generation lock locality registry hash current" \
    || fail "generation lock locality registry hash stale"
  [[ "$(yq -r '.quarantine_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$quarantine_sha" ]] \
    && pass "generation lock quarantine hash current" \
    || fail "generation lock quarantine hash stale"
  local published_files
  published_files="$(yq -r '.published_files[]?.path // ""' "$GENERATION_LOCK_FILE" 2>/dev/null | awk 'NF' | LC_ALL=C sort)"
  if [[ "$published_files" == $'.octon/generated/effective/locality/artifact-map.yml\n.octon/generated/effective/locality/generation.lock.yml\n.octon/generated/effective/locality/scopes.effective.yml' ]]; then
    pass "generation lock published_files set valid"
  else
    fail "generation lock published_files set invalid"
  fi

  if [[ "$quarantine_count" == "0" && "$publication_status" == "published" ]]; then
    pass "published locality generation has no quarantined scopes"
  elif [[ "$quarantine_count" != "0" && "$publication_status" == "published_with_quarantine" ]]; then
    pass "locality publication records quarantine when required"
  else
    fail "locality publication/quarantine status mismatch"
  fi

  if yq -e '.records[]? | select(.publication_blocking == true)' "$QUARANTINE_STATE" >/dev/null 2>&1; then
    fail "published locality generation must not retain publication-blocking quarantine records"
  else
    pass "published locality generation excludes publication-blocking quarantine records"
  fi

  mapfile -t registry_scope_ids < <(yq -r '.scopes[]?.scope_id // ""' "$LOCALITY_REGISTRY" 2>/dev/null | awk 'NF' || true)
  mapfile -t quarantined_scope_ids < <(yq -r '.records[]? | select(.publication_blocking == false) | .scope_id // ""' "$QUARANTINE_STATE" 2>/dev/null | awk 'NF' | sort -u || true)
  mapfile -t effective_scope_ids < <(yq -r '.scopes[]?.scope_id // ""' "$SCOPES_EFFECTIVE_FILE" 2>/dev/null | awk 'NF' || true)
  mapfile -t artifact_scope_ids < <(yq -r '.artifacts[]?.scope_id // ""' "$ARTIFACT_MAP_FILE" 2>/dev/null | awk 'NF' || true)
  mapfile -t lock_scope_ids < <(yq -r '.scope_manifest_digests[]?.scope_id // ""' "$GENERATION_LOCK_FILE" 2>/dev/null | awk 'NF' || true)
  mapfile -t published_registry_scope_ids < <(
    {
      for value in "${registry_scope_ids[@]}"; do
        printf '%s\n' "$value"
      done
    } | awk 'NF' | while IFS= read -r value; do
      if printf '%s\n' "${quarantined_scope_ids[@]}" | grep -Fx "$value" >/dev/null 2>&1; then
        continue
      fi
      printf '%s\n' "$value"
    done | LC_ALL=C sort -u
  )

  if [[ "$(printf '%s\n' "${published_registry_scope_ids[@]}" | sort -u)" == "$(printf '%s\n' "${effective_scope_ids[@]}" | sort -u)" ]]; then
    pass "effective locality scope ids match registry"
  else
    fail "effective locality scope ids do not match registry"
  fi

  if [[ "$(printf '%s\n' "${published_registry_scope_ids[@]}" | sort -u)" == "$(printf '%s\n' "${artifact_scope_ids[@]}" | sort -u)" ]]; then
    pass "artifact map scope ids match registry"
  else
    fail "artifact map scope ids do not match registry"
  fi

  if [[ "$(printf '%s\n' "${published_registry_scope_ids[@]}" | sort -u)" == "$(printf '%s\n' "${lock_scope_ids[@]}" | sort -u)" ]]; then
    pass "generation lock scope ids match registry"
  else
    fail "generation lock scope ids do not match registry"
  fi

  local scope_id manifest_path recorded_sha recorded_continuity_sha recorded_decision_sha actual_sha active_status
  while IFS=$'\t' read -r scope_id manifest_path recorded_sha recorded_continuity_sha recorded_decision_sha; do
    [[ -z "$scope_id" ]] && continue
    actual_sha="$(hash_file "$ROOT_DIR/$manifest_path")"
    [[ "$actual_sha" == "$recorded_sha" ]] \
      && pass "generation lock digest current for $scope_id" \
      || fail "generation lock digest stale for $scope_id"
    [[ "$(scope_continuity_digest "$scope_id")" == "$recorded_continuity_sha" ]] \
      && pass "generation lock continuity digest current for $scope_id" \
      || fail "generation lock continuity digest stale for $scope_id"
    [[ "$(scope_decision_evidence_digest "$scope_id")" == "$recorded_decision_sha" ]] \
      && pass "generation lock decision-evidence digest current for $scope_id" \
      || fail "generation lock decision-evidence digest stale for $scope_id"
  done < <(yq -r '.scope_manifest_digests[]? | [.scope_id, .manifest_path, .sha256, (.continuity_sha256 // ""), (.decision_evidence_sha256 // "")] | @tsv' "$GENERATION_LOCK_FILE" 2>/dev/null || true)

  while IFS=$'\t' read -r scope_id active_status; do
    [[ -z "$scope_id" ]] && continue
    if [[ "$active_status" == "active" ]]; then
      if printf '%s\n' "${quarantined_scope_ids[@]}" | grep -Fx "$scope_id" >/dev/null 2>&1; then
        if yq -e ".active_scope_ids[]? | select(. == \"$scope_id\")" "$SCOPES_EFFECTIVE_FILE" >/dev/null 2>&1; then
          fail "quarantined active scope must not remain in effective active_scope_ids: $scope_id"
        else
          pass "quarantined active scope removed from effective active_scope_ids: $scope_id"
        fi
      elif yq -e ".active_scope_ids[]? | select(. == \"$scope_id\")" "$SCOPES_EFFECTIVE_FILE" >/dev/null 2>&1; then
        pass "active scope published: $scope_id"
      else
        fail "active scope missing from effective active_scope_ids: $scope_id"
      fi
    fi
  done < <(
    while IFS=$'\t' read -r scope_id manifest_path; do
      [[ -z "$scope_id" ]] && continue
      printf '%s\t%s\n' "$scope_id" "$(yq -r '.status // ""' "$ROOT_DIR/$manifest_path" 2>/dev/null || true)"
    done < <(yq -r '.scopes[]? | [.scope_id // "", .manifest_path // ""] | @tsv' "$LOCALITY_REGISTRY" 2>/dev/null || true)
  )

  if yq -e '.invalidation_conditions | length > 0' "$SCOPES_EFFECTIVE_FILE" >/dev/null 2>&1 \
    && yq -e '.invalidation_conditions | length > 0' "$GENERATION_LOCK_FILE" >/dev/null 2>&1; then
    pass "locality publication family declares invalidation conditions"
  else
    fail "locality publication family must declare invalidation conditions"
  fi

  if yq -e '.required_inputs[]? | select(. == ".octon/octon.yml")' "$GENERATION_LOCK_FILE" >/dev/null 2>&1 \
    && yq -e '.required_inputs[]? | select(. == ".octon/instance/locality/registry.yml")' "$GENERATION_LOCK_FILE" >/dev/null 2>&1; then
    pass "generation lock required inputs include locality authority"
  else
    fail "generation lock required inputs missing locality authority"
  fi

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
