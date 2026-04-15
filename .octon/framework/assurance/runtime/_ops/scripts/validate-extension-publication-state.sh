#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../../../orchestration/runtime/_ops/scripts/extensions-common.sh"

extensions_common_init "${BASH_SOURCE[0]}"

FRAMEWORK_COMMANDS_MANIFEST="$OCTON_DIR/framework/capabilities/runtime/commands/manifest.yml"
FRAMEWORK_SKILLS_MANIFEST="$OCTON_DIR/framework/capabilities/runtime/skills/manifest.yml"
INSTANCE_COMMANDS_MANIFEST="$OCTON_DIR/instance/capabilities/runtime/commands/manifest.yml"
INSTANCE_SKILLS_MANIFEST="$OCTON_DIR/instance/capabilities/runtime/skills/manifest.yml"

errors=0
PUBLISHED_EXTENSION_PREFIX=".octon/generated/effective/extensions/published/"

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

sorted_pack_refs_from_query() {
  local file="$1" query="$2"
  yq -r "$query[]? | [.pack_id, .source_id] | @tsv" "$file" 2>/dev/null \
    | awk 'NF' \
    | LC_ALL=C sort
}

sorted_closure_from_query() {
  local file="$1" query="$2"
  yq -r "$query[]? | [.pack_id, .source_id, .version, .origin_class, .manifest_path] | @tsv" "$file" 2>/dev/null \
    | awk 'NF' \
    | LC_ALL=C sort
}

sorted_published_files() {
  yq -r '.published_files[]?.path // ""' "$GENERATION_LOCK_FILE" 2>/dev/null \
    | awk 'NF' \
    | LC_ALL=C sort
}

sorted_projection_source_paths() {
  yq -r '.packs[]? | .routing_exports.commands[]?.projection_source_path, .routing_exports.skills[]?.projection_source_path, .prompt_bundles[]?.prompt_assets[]?.projection_source_path, .prompt_bundles[]?.reference_assets[]?.projection_source_path, .prompt_bundles[]?.shared_reference_assets[]?.projection_source_path // ""' "$CATALOG_FILE" 2>/dev/null \
    | awk 'NF' \
    | LC_ALL=C sort
}

main() {
  echo "== Extension Publication State Validation =="

  local file
  for file in "$EXTENSIONS_MANIFEST" "$ACTIVE_STATE" "$QUARANTINE_STATE" "$CATALOG_FILE" "$ARTIFACT_MAP_FILE" "$GENERATION_LOCK_FILE"; do
    if [[ -f "$file" ]]; then
      pass "found file: ${file#$ROOT_DIR/}"
      yq -e '.' "$file" >/dev/null 2>&1 && pass "${file#$ROOT_DIR/} parses as YAML" || fail "${file#$ROOT_DIR/} must parse as YAML"
    else
      fail "missing file: ${file#$ROOT_DIR/}"
    fi
  done

  local desired_sha root_sha generation_id status
  desired_sha="$(ext_hash_file "$EXTENSIONS_MANIFEST")"
  root_sha="$(ext_hash_file "$ROOT_MANIFEST")"
  local receipt_rel receipt_abs receipt_sha

  [[ "$(yq -r '.schema_version // ""' "$ACTIVE_STATE")" == "octon-extension-active-state-v3" ]] && pass "active state schema version valid" || fail "active state schema_version invalid"
  [[ "$(yq -r '.schema_version // ""' "$QUARANTINE_STATE")" == "octon-extension-quarantine-state-v3" ]] && pass "quarantine state schema version valid" || fail "quarantine state schema_version invalid"
  [[ "$(yq -r '.schema_version // ""' "$CATALOG_FILE")" == "octon-extension-effective-catalog-v4" ]] && pass "effective catalog schema version valid" || fail "effective catalog schema_version invalid"
  [[ "$(yq -r '.schema_version // ""' "$ARTIFACT_MAP_FILE")" == "octon-extension-artifact-map-v4" ]] && pass "artifact map schema version valid" || fail "artifact map schema_version invalid"
  [[ "$(yq -r '.schema_version // ""' "$GENERATION_LOCK_FILE")" == "octon-extension-generation-lock-v4" ]] && pass "generation lock schema version valid" || fail "generation lock schema_version invalid"
  local expected_generator_version
  expected_generator_version="extension-publication-v3"
  pass "extension publication generator version contract declared"
  [[ "$(yq -r '.generator_version // ""' "$CATALOG_FILE")" == "$expected_generator_version" ]] && pass "effective catalog generator_version current" || fail "effective catalog generator_version missing or stale"
  [[ "$(yq -r '.generator_version // ""' "$ARTIFACT_MAP_FILE")" == "$expected_generator_version" ]] && pass "artifact map generator_version current" || fail "artifact map generator_version missing or stale"
  [[ "$(yq -r '.generator_version // ""' "$GENERATION_LOCK_FILE")" == "$expected_generator_version" ]] && pass "generation lock generator_version current" || fail "generation lock generator_version missing or stale"

  generation_id="$(yq -r '.generation_id // ""' "$ACTIVE_STATE")"
  status="$(yq -r '.status // ""' "$ACTIVE_STATE")"
  [[ -n "$generation_id" ]] && pass "active state generation_id declared" || fail "active state missing generation_id"
  case "$status" in
    published|published_with_quarantine|withdrawn)
      pass "active state status valid"
      ;;
    *)
      fail "active state status invalid"
      ;;
  esac

  [[ "$(yq -r '.desired_config_revision.path // ""' "$ACTIVE_STATE")" == ".octon/instance/extensions.yml" ]] && pass "active state desired config path valid" || fail "active state desired config path invalid"
  [[ "$(yq -r '.desired_config_revision.sha256 // ""' "$ACTIVE_STATE")" == "$desired_sha" ]] && pass "active state desired config hash current" || fail "active state desired config hash stale"
  [[ "$(yq -r '.published_effective_catalog // ""' "$ACTIVE_STATE")" == ".octon/generated/effective/extensions/catalog.effective.yml" ]] && pass "active state catalog reference valid" || fail "active state catalog reference invalid"
  [[ "$(yq -r '.published_artifact_map // ""' "$ACTIVE_STATE")" == ".octon/generated/effective/extensions/artifact-map.yml" ]] && pass "active state artifact map reference valid" || fail "active state artifact map reference invalid"
  [[ "$(yq -r '.published_generation_lock // ""' "$ACTIVE_STATE")" == ".octon/generated/effective/extensions/generation.lock.yml" ]] && pass "active state generation lock reference valid" || fail "active state generation lock reference invalid"
  receipt_rel="$(yq -r '.publication_receipt_path // ""' "$ACTIVE_STATE")"
  [[ -n "$receipt_rel" ]] && pass "active state publication receipt path declared" || fail "active state missing publication receipt path"
  receipt_abs="$ROOT_DIR/$receipt_rel"
  if [[ -f "$receipt_abs" ]]; then
    pass "publication receipt file exists"
    yq -e '.' "$receipt_abs" >/dev/null 2>&1 && pass "publication receipt parses as YAML" || fail "publication receipt must parse as YAML"
  else
    fail "publication receipt file missing"
  fi
  [[ "$(yq -r '.schema_version // ""' "$receipt_abs" 2>/dev/null)" == "octon-validation-publication-receipt-v1" ]] && pass "publication receipt schema version valid" || fail "publication receipt schema version invalid"
  [[ "$(yq -r '.publication_family // ""' "$receipt_abs" 2>/dev/null)" == "extensions" ]] && pass "publication receipt family valid" || fail "publication receipt family invalid"
  [[ "$(yq -r '.generation_id // ""' "$receipt_abs" 2>/dev/null)" == "$generation_id" ]] && pass "publication receipt generation id matches active state" || fail "publication receipt generation id mismatch"
  [[ "$(yq -r '.result // ""' "$receipt_abs" 2>/dev/null)" == "$status" ]] && pass "publication receipt result matches active state" || fail "publication receipt result mismatch"
  yq -e '.contract_refs | length > 0' "$receipt_abs" >/dev/null 2>&1 && pass "publication receipt contract refs declared" || fail "publication receipt contract refs missing"
  receipt_sha="$(ext_hash_file "$receipt_abs")"
  [[ "$(yq -r '.publication_receipt_sha256 // ""' "$ACTIVE_STATE")" == "$receipt_sha" ]] && pass "active state receipt hash current" || fail "active state receipt hash stale"

  [[ "$(yq -r '.generation_id // ""' "$CATALOG_FILE")" == "$generation_id" ]] && pass "effective catalog generation_id matches active state" || fail "effective catalog generation_id mismatch"
  [[ "$(yq -r '.generation_id // ""' "$ARTIFACT_MAP_FILE")" == "$generation_id" ]] && pass "artifact map generation_id matches active state" || fail "artifact map generation_id mismatch"
  [[ "$(yq -r '.generation_id // ""' "$GENERATION_LOCK_FILE")" == "$generation_id" ]] && pass "generation lock generation_id matches active state" || fail "generation lock generation_id mismatch"
  [[ "$(yq -r '.publication_status // ""' "$CATALOG_FILE")" == "$status" ]] && pass "effective catalog status matches active state" || fail "effective catalog status mismatch"
  [[ "$(yq -r '.publication_receipt_path // ""' "$CATALOG_FILE")" == "$receipt_rel" ]] && pass "effective catalog receipt path matches active state" || fail "effective catalog receipt path mismatch"
  [[ "$(yq -r '.publication_status // ""' "$GENERATION_LOCK_FILE")" == "$status" ]] && pass "generation lock status matches active state" || fail "generation lock status mismatch"
  [[ "$(yq -r '.publication_receipt_path // ""' "$GENERATION_LOCK_FILE")" == "$receipt_rel" ]] && pass "generation lock receipt path matches active state" || fail "generation lock receipt path mismatch"
  [[ "$(yq -r '.publication_receipt_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$receipt_sha" ]] && pass "generation lock receipt hash current" || fail "generation lock receipt hash stale"

  [[ "$(yq -r '.source.desired_config_sha256 // ""' "$CATALOG_FILE")" == "$desired_sha" ]] && pass "effective catalog desired config hash current" || fail "effective catalog desired config hash stale"
  [[ "$(yq -r '.desired_config_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$desired_sha" ]] && pass "generation lock desired config hash current" || fail "generation lock desired config hash stale"
  [[ "$(yq -r '.source.root_manifest_sha256 // ""' "$CATALOG_FILE")" == "$root_sha" ]] && pass "effective catalog root manifest hash current" || fail "effective catalog root manifest hash stale"
  [[ "$(yq -r '.root_manifest_sha256 // ""' "$GENERATION_LOCK_FILE")" == "$root_sha" ]] && pass "generation lock root manifest hash current" || fail "generation lock root manifest hash stale"

  local desired_enabled active_desired catalog_desired active_published catalog_published active_closure catalog_closure
  desired_enabled="$(yq -r '.selection.enabled[]? | [.pack_id, .source_id] | @tsv' "$EXTENSIONS_MANIFEST" 2>/dev/null | awk 'NF' | LC_ALL=C sort)"
  active_desired="$(sorted_pack_refs_from_query "$ACTIVE_STATE" '.desired_selected_packs')"
  catalog_desired="$(sorted_pack_refs_from_query "$CATALOG_FILE" '.desired_selected_packs')"
  active_published="$(sorted_pack_refs_from_query "$ACTIVE_STATE" '.published_active_packs')"
  catalog_published="$(sorted_pack_refs_from_query "$CATALOG_FILE" '.published_active_packs')"
  active_closure="$(sorted_closure_from_query "$ACTIVE_STATE" '.dependency_closure')"
  catalog_closure="$(sorted_closure_from_query "$CATALOG_FILE" '.dependency_closure')"

  [[ "$desired_enabled" == "$active_desired" ]] && pass "active state desired_selected_packs match desired selection" || fail "active state desired_selected_packs do not match desired selection"
  [[ "$desired_enabled" == "$catalog_desired" ]] && pass "effective catalog desired_selected_packs match desired selection" || fail "effective catalog desired_selected_packs do not match desired selection"
  [[ "$active_published" == "$catalog_published" ]] && pass "effective catalog published_active_packs match active state" || fail "effective catalog published_active_packs mismatch"
  [[ "$active_closure" == "$catalog_closure" ]] && pass "effective catalog dependency_closure matches active state" || fail "effective catalog dependency_closure mismatch"

  local pack_id source_id
  while IFS=$'\t' read -r pack_id source_id; do
    [[ -z "$pack_id" ]] && continue
    yq -e ".packs[]? | select(.pack_id == \"$pack_id\" and .source_id == \"$source_id\") | .routing_exports.commands | type == \"!!seq\"" "$CATALOG_FILE" >/dev/null 2>&1 \
      && pass "routing_exports.commands valid for $pack_id" \
      || fail "routing_exports.commands invalid for $pack_id"
    yq -e ".packs[]? | select(.pack_id == \"$pack_id\" and .source_id == \"$source_id\") | .routing_exports.skills | type == \"!!seq\"" "$CATALOG_FILE" >/dev/null 2>&1 \
      && pass "routing_exports.skills valid for $pack_id" \
      || fail "routing_exports.skills invalid for $pack_id"

    local prompt_manifest_count catalog_prompt_bundle_count prompt_manifest prompt_set_id bundle_manifest_path bundle_manifest_sha alignment_receipt_rel
    prompt_manifest_count=0
    while IFS= read -r prompt_manifest; do
      [[ -n "$prompt_manifest" ]] || continue
      prompt_manifest_count=$((prompt_manifest_count + 1))
    done < <(ext_prompt_bundle_manifest_files_for_pack "$ROOT_DIR/.octon/inputs/additive/extensions/${pack_id}/pack.yml" "$ROOT_DIR/.octon/inputs/additive/extensions/${pack_id}")

    catalog_prompt_bundle_count="$(yq -r ".packs[]? | select(.pack_id == \"$pack_id\" and .source_id == \"$source_id\") | (.prompt_bundles // []) | length" "$CATALOG_FILE" 2>/dev/null || echo 0)"
    if [[ "$prompt_manifest_count" -eq "$catalog_prompt_bundle_count" ]]; then
      pass "prompt bundle count matches prompt manifests for $pack_id"
    else
      fail "prompt bundle count mismatch for $pack_id"
    fi

    while IFS= read -r prompt_manifest; do
      [[ -n "$prompt_manifest" ]] || continue
      local prompt_root_abs
      prompt_root_abs="$(dirname "$(dirname "$prompt_manifest")")"
      prompt_set_id="$(yq -r '.prompt_set_id // ""' "$prompt_manifest" 2>/dev/null || true)"
      [[ -n "$prompt_set_id" ]] || continue
      yq -e ".packs[]? | select(.pack_id == \"$pack_id\" and .source_id == \"$source_id\") | .prompt_bundles[]? | select(.prompt_set_id == \"$prompt_set_id\")" "$CATALOG_FILE" >/dev/null 2>&1 \
        && pass "prompt bundle published for $pack_id/$prompt_set_id" \
        || fail "prompt bundle missing for $pack_id/$prompt_set_id"

      bundle_manifest_path="$(yq -r ".packs[]? | select(.pack_id == \"$pack_id\" and .source_id == \"$source_id\") | .prompt_bundles[]? | select(.prompt_set_id == \"$prompt_set_id\") | .manifest_path // \"\"" "$CATALOG_FILE" 2>/dev/null | head -n 1)"
      bundle_manifest_sha="$(yq -r ".packs[]? | select(.pack_id == \"$pack_id\" and .source_id == \"$source_id\") | .prompt_bundles[]? | select(.prompt_set_id == \"$prompt_set_id\") | .manifest_sha256 // \"\"" "$CATALOG_FILE" 2>/dev/null | head -n 1)"
      [[ "$bundle_manifest_path" == "${prompt_manifest#$ROOT_DIR/}" ]] && pass "prompt bundle manifest path current for $pack_id/$prompt_set_id" || fail "prompt bundle manifest path mismatch for $pack_id/$prompt_set_id"
      [[ "$bundle_manifest_sha" == "$(ext_hash_file "$prompt_manifest")" ]] && pass "prompt bundle manifest digest current for $pack_id/$prompt_set_id" || fail "prompt bundle manifest digest stale for $pack_id/$prompt_set_id"

      alignment_receipt_rel="$(yq -r ".packs[]? | select(.pack_id == \"$pack_id\" and .source_id == \"$source_id\") | .prompt_bundles[]? | select(.prompt_set_id == \"$prompt_set_id\") | .alignment_receipt_path // \"\"" "$CATALOG_FILE" 2>/dev/null | head -n 1)"
      if [[ -n "$alignment_receipt_rel" && -f "$ROOT_DIR/$alignment_receipt_rel" ]]; then
        pass "prompt bundle alignment receipt exists for $pack_id/$prompt_set_id"
        yq -e '.' "$ROOT_DIR/$alignment_receipt_rel" >/dev/null 2>&1 && pass "prompt bundle alignment receipt parses for $pack_id/$prompt_set_id" || fail "prompt bundle alignment receipt must parse for $pack_id/$prompt_set_id"
        [[ "$(yq -r '.schema_version // ""' "$ROOT_DIR/$alignment_receipt_rel" 2>/dev/null)" == "octon-extension-prompt-alignment-receipt-v1" ]] && pass "prompt bundle alignment receipt schema version valid for $pack_id/$prompt_set_id" || fail "prompt bundle alignment receipt schema version invalid for $pack_id/$prompt_set_id"
        [[ "$(yq -r '.safe_to_run // ""' "$ROOT_DIR/$alignment_receipt_rel" 2>/dev/null)" == "true" ]] && pass "prompt bundle alignment receipt safe_to_run valid for $pack_id/$prompt_set_id" || fail "prompt bundle alignment receipt safe_to_run invalid for $pack_id/$prompt_set_id"
        [[ "$(yq -r '.bundle_sha256 // ""' "$ROOT_DIR/$alignment_receipt_rel" 2>/dev/null)" == "$(yq -r ".packs[]? | select(.pack_id == \"$pack_id\" and .source_id == \"$source_id\") | .prompt_bundles[]? | select(.prompt_set_id == \"$prompt_set_id\") | .bundle_sha256 // \"\"" "$CATALOG_FILE" 2>/dev/null | head -n 1)" ]] && pass "prompt bundle alignment receipt bundle digest matches for $pack_id/$prompt_set_id" || fail "prompt bundle alignment receipt bundle digest mismatch for $pack_id/$prompt_set_id"
      else
        fail "prompt bundle alignment receipt missing for $pack_id/$prompt_set_id"
      fi

      while IFS=$'\t' read -r anchor_path anchor_sha; do
        [[ -n "$anchor_path" ]] || continue
        [[ -e "$ROOT_DIR/$anchor_path" ]] || {
          fail "prompt bundle anchor missing for $pack_id/$prompt_set_id: $anchor_path"
          continue
        }
        [[ "$(ext_hash_file "$ROOT_DIR/$anchor_path")" == "$anchor_sha" ]] && pass "prompt bundle anchor digest current for $pack_id/$prompt_set_id: $anchor_path" || fail "prompt bundle anchor digest stale for $pack_id/$prompt_set_id: $anchor_path"
      done < <(yq -r ".packs[]? | select(.pack_id == \"$pack_id\" and .source_id == \"$source_id\") | .prompt_bundles[]? | select(.prompt_set_id == \"$prompt_set_id\") | .required_repo_anchors[]? | [.path, .sha256] | @tsv" "$CATALOG_FILE" 2>/dev/null || true)

      while IFS=$'\t' read -r asset_path asset_sha; do
        [[ -n "$asset_path" ]] || continue
        if [[ ! -f "$(dirname "$prompt_manifest")/$asset_path" ]]; then
          fail "prompt asset path missing for $pack_id/$prompt_set_id: $asset_path"
          continue
        fi
        [[ "$(ext_hash_file "$(dirname "$prompt_manifest")/$asset_path")" == "$asset_sha" ]] && pass "prompt asset digest current for $pack_id/$prompt_set_id: $asset_path" || fail "prompt asset digest stale for $pack_id/$prompt_set_id: $asset_path"
      done < <(yq -r ".packs[]? | select(.pack_id == \"$pack_id\" and .source_id == \"$source_id\") | .prompt_bundles[]? | select(.prompt_set_id == \"$prompt_set_id\") | .prompt_assets[]? | [.path, .sha256] | @tsv" "$CATALOG_FILE" 2>/dev/null || true)

      while IFS=$'\t' read -r asset_path asset_sha; do
        [[ -n "$asset_path" ]] || continue
        if [[ ! -f "$(dirname "$prompt_manifest")/$asset_path" ]]; then
          fail "reference asset path missing for $pack_id/$prompt_set_id: $asset_path"
          continue
        fi
        [[ "$(ext_hash_file "$(dirname "$prompt_manifest")/$asset_path")" == "$asset_sha" ]] && pass "reference asset digest current for $pack_id/$prompt_set_id: $asset_path" || fail "reference asset digest stale for $pack_id/$prompt_set_id: $asset_path"
      done < <(yq -r ".packs[]? | select(.pack_id == \"$pack_id\" and .source_id == \"$source_id\") | .prompt_bundles[]? | select(.prompt_set_id == \"$prompt_set_id\") | .reference_assets[]? | [.path, .sha256] | @tsv" "$CATALOG_FILE" 2>/dev/null || true)

      while IFS=$'\t' read -r asset_path asset_sha; do
        [[ -n "$asset_path" ]] || continue
        if [[ ! -f "$prompt_root_abs/$asset_path" ]]; then
          fail "shared reference asset path missing for $pack_id/$prompt_set_id: $asset_path"
          continue
        fi
        [[ "$(ext_hash_file "$prompt_root_abs/$asset_path")" == "$asset_sha" ]] && pass "shared reference asset digest current for $pack_id/$prompt_set_id: $asset_path" || fail "shared reference asset digest stale for $pack_id/$prompt_set_id: $asset_path"
      done < <(yq -r ".packs[]? | select(.pack_id == \"$pack_id\" and .source_id == \"$source_id\") | .prompt_bundles[]? | select(.prompt_set_id == \"$prompt_set_id\") | .shared_reference_assets[]? | [.path, .sha256] | @tsv" "$CATALOG_FILE" 2>/dev/null || true)
    done < <(ext_prompt_bundle_manifest_files_for_pack "$ROOT_DIR/.octon/inputs/additive/extensions/${pack_id}/pack.yml" "$ROOT_DIR/.octon/inputs/additive/extensions/${pack_id}")
  done < <(yq -r '.packs[]? | [.pack_id, .source_id] | @tsv' "$CATALOG_FILE" 2>/dev/null || true)

  local native_command_ids native_skill_ids collision_lines
  native_command_ids="$(
    {
      yq -r '.commands[]?.id // ""' "$FRAMEWORK_COMMANDS_MANIFEST" 2>/dev/null || true
      yq -r '.commands[]?.id // ""' "$INSTANCE_COMMANDS_MANIFEST" 2>/dev/null || true
    } | awk 'NF' | LC_ALL=C sort -u
  )"
  native_skill_ids="$(
    {
      yq -r '.skills[]?.id // ""' "$FRAMEWORK_SKILLS_MANIFEST" 2>/dev/null || true
      yq -r '.skills[]?.id // ""' "$INSTANCE_SKILLS_MANIFEST" 2>/dev/null || true
    } | awk 'NF' | LC_ALL=C sort -u
  )"
  collision_lines="$(
    {
      yq -r '.packs[]? as $pack | $pack.routing_exports.commands[]? | ["command", $pack.pack_id, .capability_id] | @tsv' "$CATALOG_FILE" 2>/dev/null || true
      yq -r '.packs[]? as $pack | $pack.routing_exports.skills[]? | ["skill", $pack.pack_id, .capability_id] | @tsv' "$CATALOG_FILE" 2>/dev/null || true
    } | while IFS=$'\t' read -r kind pack_id capability_id; do
      [[ -n "$capability_id" ]] || continue
      if [[ "$kind" == "command" ]] && grep -Fx "$capability_id" <<<"$native_command_ids" >/dev/null 2>&1; then
        printf '%s\t%s\n' "$kind" "$capability_id"
      fi
      if [[ "$kind" == "skill" ]] && grep -Fx "$capability_id" <<<"$native_skill_ids" >/dev/null 2>&1; then
        printf '%s\t%s\n' "$kind" "$capability_id"
      fi
    done | LC_ALL=C sort -u
  )"
  if [[ -z "$collision_lines" ]]; then
    pass "extension publication avoids native capability collisions"
  else
    while IFS=$'\t' read -r kind capability_id; do
      [[ -n "$capability_id" ]] || continue
      fail "extension publication collides with native ${kind} capability id: $capability_id"
    done <<<"$collision_lines"
  fi

  local quarantine_count
  quarantine_count="$(yq -r '.records | length' "$QUARANTINE_STATE" 2>/dev/null || printf '0')"
  case "$status" in
    published)
      [[ "$quarantine_count" == "0" ]] && pass "quarantine empty for published generation" || fail "quarantine must be empty when status=published"
      ;;
    published_with_quarantine)
      [[ "$quarantine_count" != "0" ]] && pass "quarantine present for published_with_quarantine" || fail "quarantine must be non-empty when status=published_with_quarantine"
      [[ -n "$active_published" ]] && pass "published_with_quarantine retains published_active_packs" || fail "published_with_quarantine must retain published_active_packs"
      ;;
    withdrawn)
      [[ "$quarantine_count" != "0" ]] && pass "quarantine present for withdrawn generation" || fail "withdrawn generation must record quarantine"
      [[ -z "$active_published" ]] && pass "withdrawn generation has no published_active_packs" || fail "withdrawn generation must have no published_active_packs"
      ;;
  esac

  if yq -e '.required_inputs[]? | select(. == ".octon/instance/extensions.yml")' "$GENERATION_LOCK_FILE" >/dev/null 2>&1 \
    && yq -e '.required_inputs[]? | select(. == ".octon/octon.yml")' "$GENERATION_LOCK_FILE" >/dev/null 2>&1; then
    pass "generation lock required inputs include authoritative manifests"
  else
    fail "generation lock required inputs missing authoritative manifests"
  fi

  while IFS=$'\t' read -r pack_id source_id; do
    [[ -n "$pack_id" ]] || continue
    while IFS= read -r prompt_manifest; do
      [[ -n "$prompt_manifest" ]] || continue
      if yq -e ".required_inputs[]? | select(. == \"${prompt_manifest#$ROOT_DIR/}\")" "$GENERATION_LOCK_FILE" >/dev/null 2>&1; then
        pass "generation lock includes prompt manifest input for $pack_id"
      else
        fail "generation lock missing prompt manifest input for $pack_id"
      fi
      while IFS= read -r anchor_path; do
        [[ -n "$anchor_path" ]] || continue
        if yq -e ".required_inputs[]? | select(. == \"$anchor_path\")" "$GENERATION_LOCK_FILE" >/dev/null 2>&1; then
          pass "generation lock includes prompt anchor input for $pack_id: $anchor_path"
        else
          fail "generation lock missing prompt anchor input for $pack_id: $anchor_path"
        fi
      done < <(yq -r '.required_repo_anchors[]? // ""' "$prompt_manifest" 2>/dev/null || true)
    done < <(ext_prompt_bundle_manifest_files_for_pack "$ROOT_DIR/.octon/inputs/additive/extensions/${pack_id}/pack.yml" "$ROOT_DIR/.octon/inputs/additive/extensions/${pack_id}")
  done < <(yq -r '.packs[]? | [.pack_id, .source_id] | @tsv' "$CATALOG_FILE" 2>/dev/null || true)

  if yq -e '.invalidation_conditions | length > 0' "$ACTIVE_STATE" >/dev/null 2>&1 \
    && yq -e '.invalidation_conditions | length > 0' "$CATALOG_FILE" >/dev/null 2>&1 \
    && yq -e '.invalidation_conditions | length > 0' "$GENERATION_LOCK_FILE" >/dev/null 2>&1; then
    pass "invalidation conditions declared across extension publication family"
  else
    fail "extension publication family must declare invalidation conditions"
  fi

  local lock_closure
  lock_closure="$(yq -r '.pack_payload_digests[]? | [.pack_id, .source_id, .version, .origin_class, .manifest_path] | @tsv' "$GENERATION_LOCK_FILE" 2>/dev/null | awk 'NF' | LC_ALL=C sort)"
  if [[ "$lock_closure" == "$active_closure" ]]; then
    pass "generation lock pack payload records match dependency closure"
  else
    fail "generation lock pack payload records do not match dependency closure"
  fi

  local artifact_paths_from_map artifact_paths_from_lock
  artifact_paths_from_map="$(yq -r '.artifacts[]?.source_path' "$ARTIFACT_MAP_FILE" 2>/dev/null | awk 'NF' | LC_ALL=C sort)"
  artifact_paths_from_lock="$(yq -r '.pack_payload_digests[]?.files[]?.path' "$GENERATION_LOCK_FILE" 2>/dev/null | awk 'NF' | LC_ALL=C sort)"
  [[ "$artifact_paths_from_map" == "$artifact_paths_from_lock" ]] && pass "artifact map paths match generation lock files" || fail "artifact map paths do not match generation lock files"
  local published_files core_published_files
  published_files="$(sorted_published_files)"
  core_published_files="$(printf '%s\n' "$published_files" | grep -v "^${PUBLISHED_EXTENSION_PREFIX}" || true)"
  if [[ "$core_published_files" == $'.octon/generated/effective/extensions/artifact-map.yml\n.octon/generated/effective/extensions/catalog.effective.yml\n.octon/generated/effective/extensions/generation.lock.yml' ]]; then
    pass "generation lock published_files set valid"
  else
    fail "generation lock published_files set invalid"
  fi

  local projection_source_path
  while IFS= read -r projection_source_path; do
    [[ -n "$projection_source_path" ]] || continue
    if [[ "$projection_source_path" == ${PUBLISHED_EXTENSION_PREFIX}* ]]; then
      pass "projection source path published under generated/effective/extensions: $projection_source_path"
    else
      fail "projection source path must stay behind compiled publication: $projection_source_path"
      continue
    fi
    if [[ -e "$ROOT_DIR/$projection_source_path" ]]; then
      pass "projection source path exists: $projection_source_path"
    else
      fail "projection source path missing: $projection_source_path"
    fi
    if grep -Fx "$projection_source_path" <<<"$published_files" >/dev/null 2>&1; then
      pass "projection source path recorded in generation lock: $projection_source_path"
    else
      fail "projection source path missing from generation lock: $projection_source_path"
    fi
  done < <(sorted_projection_source_paths)

  local source_path sha pack_payload_sha computed_payload_sha
  while IFS=$'\t' read -r source_path sha; do
    [[ -z "$source_path" ]] && continue
    if [[ ! -f "$ROOT_DIR/$source_path" ]]; then
      fail "artifact path missing: $source_path"
      continue
    fi
    [[ "$(ext_hash_file "$ROOT_DIR/$source_path")" == "$sha" ]] && pass "artifact digest current for $source_path" || fail "artifact digest stale for $source_path"
  done < <(yq -r '.artifacts[]? | [.source_path, .sha256] | @tsv' "$ARTIFACT_MAP_FILE" 2>/dev/null || true)

  local pack_id source_id payload_lines manifest_path version
  while IFS=$'\t' read -r pack_id source_id manifest_path version pack_payload_sha; do
    [[ -z "$pack_id" ]] && continue
    payload_lines=""
    while IFS=$'\t' read -r source_path sha; do
      [[ -z "$source_path" ]] && continue
      payload_lines+="${sha} ${source_path}"$'\n'
    done < <(yq -r ".pack_payload_digests[]? | select(.pack_id == \"$pack_id\" and .source_id == \"$source_id\") | .files[]? | [.path, .sha256] | @tsv" "$GENERATION_LOCK_FILE")
    computed_payload_sha="$(printf '%s' "$payload_lines" | ext_hash_text)"
    [[ "$computed_payload_sha" == "$pack_payload_sha" ]] && pass "payload digest current for $pack_id" || fail "payload digest stale for $pack_id"
    [[ -f "$ROOT_DIR/$manifest_path" ]] && pass "manifest path resolves for $pack_id" || fail "manifest path missing for $pack_id"
  done < <(yq -r '.pack_payload_digests[]? | [.pack_id, .source_id, .manifest_path, .version, .payload_sha256] | @tsv' "$GENERATION_LOCK_FILE" 2>/dev/null || true)

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
