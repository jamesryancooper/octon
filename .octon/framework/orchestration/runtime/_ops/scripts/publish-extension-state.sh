#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/extensions-common.sh"

extensions_common_init "${BASH_SOURCE[0]}"

FRAMEWORK_COMMANDS_MANIFEST="$OCTON_DIR/framework/capabilities/runtime/commands/manifest.yml"
FRAMEWORK_SKILLS_MANIFEST="$OCTON_DIR/framework/capabilities/runtime/skills/manifest.yml"
INSTANCE_COMMANDS_MANIFEST="$OCTON_DIR/instance/capabilities/runtime/commands/manifest.yml"
INSTANCE_SKILLS_MANIFEST="$OCTON_DIR/instance/capabilities/runtime/skills/manifest.yml"

PUBLISHED_AT=""
GENERATION_ID=""
GENERATOR_VERSION=""
declare -a PUBLISHED_SELECTED_KEYS=()

write_string_array_yaml() {
  local indent="$1"
  shift
  if [[ "$#" -eq 0 ]]; then
    printf '%s[]\n' "$indent"
    return
  fi
  local value
  for value in "$@"; do
    printf '%s- "%s"\n' "$indent" "$value"
  done
}

receipt_timestamp_slug() {
  local timestamp="$1"
  timestamp="${timestamp//:/-}"
  printf '%s\n' "$timestamp"
}

extension_publication_receipt_rel() {
  local timestamp_slug="$1" generation_id="$2"
  printf '.octon/state/evidence/validation/publication/extensions/%s-%s.yml\n' "$timestamp_slug" "$generation_id"
}

write_publication_receipt_string_list() {
  local indent="$1"
  shift
  if [[ "$#" -eq 0 ]]; then
    printf '%s[]\n' "$indent"
    return
  fi
  local value
  for value in "$@"; do
    printf '%s- "%s"\n' "$indent" "$value"
  done
}

write_extension_publication_receipt() {
  local output_file="$1" receipt_id="$2" generation_id="$3" result="$4" desired_sha="$5" root_sha="$6" published_root_abs="$7"
  local key pack_id source_id manifest_rel manifest_sha payload_rel payload_sha record dependent
  local blocked_reasons=()
  local required_inputs=(".octon/instance/extensions.yml" ".octon/octon.yml")
  local published_paths=(
    ".octon/generated/effective/extensions/catalog.effective.yml"
    ".octon/generated/effective/extensions/artifact-map.yml"
    ".octon/generated/effective/extensions/generation.lock.yml"
  )

  for key in "${EXT_SELECTED_KEYS[@]}"; do
    pack_id="$(ext_key_pack_id "$key")"
    required_inputs+=(".octon/inputs/additive/extensions/${pack_id}/pack.yml")
  done

  while IFS= read -r payload_rel; do
    [[ -n "$payload_rel" ]] || continue
    published_paths+=(".octon/generated/effective/extensions/${payload_rel}")
  done < <(find "$published_root_abs" -mindepth 1 -printf '%P\n' 2>/dev/null | LC_ALL=C sort)

  {
    printf 'schema_version: "octon-validation-publication-receipt-v1"\n'
    printf 'receipt_id: "%s"\n' "$receipt_id"
    printf 'publication_family: "extensions"\n'
    printf 'generation_id: "%s"\n' "$generation_id"
    printf 'result: "%s"\n' "$result"
    printf 'validated_at: "%s"\n' "$PUBLISHED_AT"
    printf 'validator_version: "%s"\n' "$GENERATOR_VERSION"
    printf 'contract_refs:\n'
    printf '  - ".octon/framework/cognition/_meta/architecture/state/control/schemas/extension-active-state.schema.json"\n'
    printf '  - ".octon/framework/cognition/_meta/architecture/state/control/schemas/extension-quarantine-state.schema.json"\n'
    printf '  - ".octon/framework/cognition/_meta/architecture/generated/effective/extensions/schemas/extension-effective-catalog.schema.json"\n'
    printf '  - ".octon/framework/cognition/_meta/architecture/generated/effective/extensions/schemas/extension-generation-lock.schema.json"\n'
    printf 'source_digests:\n'
    printf '  desired_config_sha256: "%s"\n' "$desired_sha"
    printf '  root_manifest_sha256: "%s"\n' "$root_sha"
    for key in "${EXT_SELECTED_KEYS[@]}"; do
      pack_id="$(ext_key_pack_id "$key")"
      source_id="$(ext_key_source_id "$key")"
      manifest_rel=".octon/inputs/additive/extensions/${pack_id}/pack.yml"
      manifest_sha="$(ext_hash_file "$ROOT_DIR/$manifest_rel")"
      printf '  pack_manifest__%s__%s: "%s"\n' "$pack_id" "$source_id" "$manifest_sha"
    done
    if [[ "${#EXT_QUARANTINE_KEYS[@]}" -eq 0 ]]; then
      printf 'blocked_reasons: []\n'
    else
      for key in "${EXT_QUARANTINE_KEYS[@]}"; do
        blocked_reasons+=("${EXT_QUARANTINE_REASON["$key"]}")
      done
      printf 'blocked_reasons:\n'
      printf '%s\n' "${blocked_reasons[@]}" | awk 'NF' | LC_ALL=C sort -u | while IFS= read -r record; do
        printf '  - "%s"\n' "$record"
      done
    fi
    if [[ "${#EXT_QUARANTINE_KEYS[@]}" -eq 0 ]]; then
      printf 'quarantined_subjects: []\n'
    else
      printf 'quarantined_subjects:\n'
      for key in "${EXT_QUARANTINE_KEYS[@]}"; do
        pack_id="$(ext_key_pack_id "$key")"
        source_id="$(ext_key_source_id "$key")"
        printf '  - subject_kind: "pack"\n'
        printf '    subject_id: "%s:%s"\n' "$pack_id" "$source_id"
        printf '    reason_code: "%s"\n' "${EXT_QUARANTINE_REASON["$key"]}"
        printf '    manifest_path: ".octon/inputs/additive/extensions/%s/pack.yml"\n' "$pack_id"
        IFS=',' read -r -a dependents <<< "${EXT_QUARANTINE_AFFECTED["$key"]:-}"
        for dependent in "${dependents[@]}"; do
          dependent="$(ext_trim "$dependent")"
          [[ -n "$dependent" ]] || continue
          printf '  - subject_kind: "dependent"\n'
          printf '    subject_id: "%s"\n' "$dependent"
          printf '    reason_code: "dependency-unavailable:%s"\n' "$pack_id"
          printf '    manifest_path: null\n'
        done
      done
    fi
    printf 'published_paths:\n'
    printf '%s\n' "${published_paths[@]}" | awk 'NF' | LC_ALL=C sort -u | while IFS= read -r record; do
      printf '  - "%s"\n' "$record"
    done
    printf 'required_inputs:\n'
    printf '%s\n' "${required_inputs[@]}" | awk 'NF' | LC_ALL=C sort -u | while IFS= read -r record; do
      printf '  - "%s"\n' "$record"
    done
  } >"$output_file"
}

remove_key_from_pack_refs() {
  local remove_key="$1"
  local value
  local retained=()
  for value in "$@"; do
    [[ "$value" == "$remove_key" ]] && continue
    retained+=("$value")
  done
  printf '%s\n' "${retained[@]}"
}

drop_published_key() {
  local key="$1"
  mapfile -t EXT_PUBLISHED_KEYS < <(remove_key_from_pack_refs "$key" "${EXT_PUBLISHED_KEYS[@]}" | awk 'NF')
  mapfile -t PUBLISHED_SELECTED_KEYS < <(remove_key_from_pack_refs "$key" "${PUBLISHED_SELECTED_KEYS[@]}" | awk 'NF')
  unset 'EXT_PUBLISHED_VERSION[$key]'
  unset 'EXT_PUBLISHED_ORIGIN_CLASS[$key]'
  unset 'EXT_PUBLISHED_MANIFEST_REL[$key]'
  unset 'EXT_PUBLISHED_TRUST_DECISION[$key]'
  unset 'EXT_PUBLISHED_ACKNOWLEDGEMENT_ID[$key]'
  unset 'EXT_PUBLISHED_SOURCE_ID[$key]'
}

native_capability_ids() {
  local kind="$1"
  if [[ "$kind" == "command" ]]; then
    {
      yq -r '.commands[]?.id // ""' "$FRAMEWORK_COMMANDS_MANIFEST" 2>/dev/null || true
      yq -r '.commands[]?.id // ""' "$INSTANCE_COMMANDS_MANIFEST" 2>/dev/null || true
    } | awk 'NF' | LC_ALL=C sort -u
  else
    {
      yq -r '.skills[]?.id // ""' "$FRAMEWORK_SKILLS_MANIFEST" 2>/dev/null || true
      yq -r '.skills[]?.id // ""' "$INSTANCE_SKILLS_MANIFEST" 2>/dev/null || true
    } | awk 'NF' | LC_ALL=C sort -u
  fi
}

enforce_native_capability_collision_quarantine() {
  local native_commands native_skills key pack_id source_id manifest_abs commands_root_rel skills_root_rel fragment_file capability_id
  local collided_keys=()
  native_commands="$(native_capability_ids command)"
  native_skills="$(native_capability_ids skill)"

  for key in "${EXT_PUBLISHED_KEYS[@]}"; do
    pack_id="$(ext_key_pack_id "$key")"
    source_id="$(ext_key_source_id "$key")"
    manifest_abs="$ROOT_DIR/${EXT_PUBLISHED_MANIFEST_REL["$key"]}"

    commands_root_rel="$(yq -r '.content_entrypoints.commands // ""' "$manifest_abs")"
    if [[ -n "$commands_root_rel" && "$commands_root_rel" != "null" ]]; then
      fragment_file="$(ext_pack_root_abs "$pack_id")/${commands_root_rel%/}/manifest.fragment.yml"
      while IFS= read -r capability_id; do
        [[ -n "$capability_id" ]] || continue
        if grep -Fx "$capability_id" <<<"$native_commands" >/dev/null 2>&1; then
          ext_record_quarantine "$pack_id" "$source_id" "native-capability-collision:command:$capability_id" "$pack_id" ""
          collided_keys+=("$key")
          break
        fi
      done < <(yq -r '.commands[]?.id // ""' "$fragment_file" 2>/dev/null || true)
    fi

    skills_root_rel="$(yq -r '.content_entrypoints.skills // ""' "$manifest_abs")"
    if [[ -n "$skills_root_rel" && "$skills_root_rel" != "null" ]]; then
      fragment_file="$(ext_pack_root_abs "$pack_id")/${skills_root_rel%/}/manifest.fragment.yml"
      while IFS= read -r capability_id; do
        [[ -n "$capability_id" ]] || continue
        if grep -Fx "$capability_id" <<<"$native_skills" >/dev/null 2>&1; then
          ext_record_quarantine "$pack_id" "$source_id" "native-capability-collision:skill:$capability_id" "$pack_id" ""
          collided_keys+=("$key")
          break
        fi
      done < <(yq -r '.skills[]?.id // ""' "$fragment_file" 2>/dev/null || true)
    fi
  done

  if [[ "${#collided_keys[@]}" -eq 0 ]]; then
    return 0
  fi

  mapfile -t collided_keys < <(printf '%s\n' "${collided_keys[@]}" | awk 'NF' | LC_ALL=C sort -u)
  for key in "${collided_keys[@]}"; do
    drop_published_key "$key"
  done
}

prune_unsatisfied_dependents() {
  local changed=1 key pack_id source_id manifest_abs dep_pack_id dep_source dep_key
  local remove_key
  while [[ "$changed" -eq 1 ]]; do
    changed=0
    for key in "${EXT_PUBLISHED_KEYS[@]}"; do
      pack_id="$(ext_key_pack_id "$key")"
      source_id="$(ext_key_source_id "$key")"
      manifest_abs="$ROOT_DIR/${EXT_PUBLISHED_MANIFEST_REL["$key"]}"
      while IFS=$'\t' read -r dep_pack_id dep_range; do
        [[ -n "$dep_pack_id" ]] || continue
        dep_source="$(ext_detect_pack_source_id "$dep_pack_id" 2>/dev/null || true)"
        [[ -n "$dep_source" ]] || dep_source="$source_id"
        dep_key="$(ext_pack_key "$dep_pack_id" "$dep_source")"
        if [[ -z "${EXT_PUBLISHED_VERSION["$dep_key"]:-}" ]]; then
          ext_record_quarantine "$pack_id" "$source_id" "dependency-unavailable:$dep_pack_id" "$pack_id" ""
          drop_published_key "$key"
          changed=1
          break
        fi
      done < <(yq -r '.dependencies.requires[]? | [.pack_id, .version_range] | @tsv' "$manifest_abs" 2>/dev/null || true)
    done
  done
}

write_fragment_host_adapters() {
  local fragment_file="$1" item_query="$2"
  local adapters=()
  while IFS= read -r adapter; do
    [[ -n "$adapter" ]] || continue
    adapters+=("$adapter")
  done < <(yq -r "$item_query.host_adapters[]? // \"\"" "$fragment_file" 2>/dev/null || true)

  if [[ "${#adapters[@]}" -eq 0 ]]; then
    adapters=(claude cursor codex)
  fi

  printf '        host_adapters:\n'
  write_string_array_yaml '          ' "${adapters[@]}"
}

write_fragment_selectors() {
  local fragment_file="$1" item_query="$2"
  local include=()
  local exclude=()
  while IFS= read -r value; do
    [[ -n "$value" ]] || continue
    include+=("$value")
  done < <(yq -r "$item_query.routing.selectors.include[]? // \"\"" "$fragment_file" 2>/dev/null || true)
  while IFS= read -r value; do
    [[ -n "$value" ]] || continue
    exclude+=("$value")
  done < <(yq -r "$item_query.routing.selectors.exclude[]? // \"\"" "$fragment_file" 2>/dev/null || true)

  if [[ "${#include[@]}" -eq 0 ]]; then
    include=('**')
  fi

  printf '        selectors:\n'
  printf '          include:\n'
  write_string_array_yaml '            ' "${include[@]}"
  printf '          exclude:\n'
  write_string_array_yaml '            ' "${exclude[@]}"
}

write_fragment_fingerprints() {
  local fragment_file="$1" item_query="$2"
  local tech_tags=()
  local language_tags=()
  while IFS= read -r value; do
    [[ -n "$value" ]] || continue
    tech_tags+=("$value")
  done < <(yq -r "$item_query.routing.fingerprints.tech_tags[]? // \"\"" "$fragment_file" 2>/dev/null || true)
  while IFS= read -r value; do
    [[ -n "$value" ]] || continue
    language_tags+=("$value")
  done < <(yq -r "$item_query.routing.fingerprints.language_tags[]? // \"\"" "$fragment_file" 2>/dev/null || true)

  printf '        fingerprints:\n'
  printf '          tech_tags:\n'
  write_string_array_yaml '            ' "${tech_tags[@]}"
  printf '          language_tags:\n'
  write_string_array_yaml '            ' "${language_tags[@]}"
}

copy_projection_file() {
  local source_abs="$1" dest_abs="$2"
  mkdir -p "$(dirname "$dest_abs")"
  cp "$source_abs" "$dest_abs"
}

copy_projection_dir() {
  local source_abs="$1" dest_abs="$2"
  mkdir -p "$(dirname "$dest_abs")"
  rm -r -f "$dest_abs"
  cp -R "$source_abs" "$dest_abs"
}

stage_pack_command_projections() {
  local pack_id="$1" source_id="$2" manifest_abs="$3" published_root_abs="$4"
  local commands_root_rel fragment_file item_query path source_abs dest_abs

  commands_root_rel="$(yq -r '.content_entrypoints.commands // ""' "$manifest_abs")"
  if [[ -z "$commands_root_rel" || "$commands_root_rel" == "null" ]]; then
    return 0
  fi

  fragment_file="$(ext_pack_root_abs "$pack_id")/${commands_root_rel%/}/manifest.fragment.yml"
  [[ -f "$fragment_file" ]] || return 0

  local index
  index=0
  while true; do
    if ! yq -e ".commands[$index]" "$fragment_file" >/dev/null 2>&1; then
      break
    fi
    item_query=".commands[$index]"
    path="$(yq -r "$item_query.path // \"\"" "$fragment_file")"
    [[ -n "$path" ]] || {
      index=$((index + 1))
      continue
    }
    source_abs="$(ext_pack_root_abs "$pack_id")/${commands_root_rel%/}/$path"
    dest_abs="$published_root_abs/commands/$path"
    [[ -f "$source_abs" ]] || {
      index=$((index + 1))
      continue
    }
    copy_projection_file "$source_abs" "$dest_abs"
    index=$((index + 1))
  done
}

stage_pack_skill_projections() {
  local pack_id="$1" source_id="$2" manifest_abs="$3" published_root_abs="$4"
  local skills_root_rel fragment_file item_query path source_abs dest_abs

  skills_root_rel="$(yq -r '.content_entrypoints.skills // ""' "$manifest_abs")"
  if [[ -z "$skills_root_rel" || "$skills_root_rel" == "null" ]]; then
    return 0
  fi

  fragment_file="$(ext_pack_root_abs "$pack_id")/${skills_root_rel%/}/manifest.fragment.yml"
  [[ -f "$fragment_file" ]] || return 0

  local index
  index=0
  while true; do
    if ! yq -e ".skills[$index]" "$fragment_file" >/dev/null 2>&1; then
      break
    fi
    item_query=".skills[$index]"
    path="$(yq -r "$item_query.path // \"\"" "$fragment_file")"
    path="${path%/}"
    [[ -n "$path" ]] || {
      index=$((index + 1))
      continue
    }
    source_abs="$(ext_pack_root_abs "$pack_id")/${skills_root_rel%/}/$path"
    dest_abs="$published_root_abs/skills/$path"
    [[ -d "$source_abs" ]] || {
      index=$((index + 1))
      continue
    }
    copy_projection_dir "$source_abs" "$dest_abs"
    index=$((index + 1))
  done
}

stage_pack_projection_exports() {
  local pack_id="$1" source_id="$2" manifest_abs="$3" published_root_abs="$4"
  stage_pack_command_projections "$pack_id" "$source_id" "$manifest_abs" "$published_root_abs"
  stage_pack_skill_projections "$pack_id" "$source_id" "$manifest_abs" "$published_root_abs"
}

write_pack_command_routing_exports() {
  local pack_id="$1" source_id="$2" manifest_abs="$3" commands_root_rel fragment_file item_query path projection_source_path
  commands_root_rel="$(yq -r '.content_entrypoints.commands // ""' "$manifest_abs")"
  if [[ -z "$commands_root_rel" || "$commands_root_rel" == "null" ]]; then
    printf '      commands: []\n'
    return
  fi
  fragment_file="$(ext_pack_root_abs "$pack_id")/${commands_root_rel%/}/manifest.fragment.yml"
  if [[ ! -f "$fragment_file" ]]; then
    printf '      commands: []\n'
    return
  fi
  if [[ "$(yq -r '.commands | length' "$fragment_file" 2>/dev/null || echo 0)" == "0" ]]; then
    printf '      commands: []\n'
    return
  fi

  printf '      commands:\n'
  local index
  index=0
  while true; do
    if ! yq -e ".commands[$index]" "$fragment_file" >/dev/null 2>&1; then
      break
    fi
    item_query=".commands[$index]"
    path="$(yq -r "$item_query.path // \"\"" "$fragment_file")"
    projection_source_path="$(ext_published_command_projection_rel "$pack_id" "$source_id" "$path")"
    printf '        - capability_id: "%s"\n' "$(yq -r "$item_query.id // \"\"" "$fragment_file")"
    printf '          display_name: "%s"\n' "$(yq -r "$item_query.display_name // \"\"" "$fragment_file")"
    printf '          summary: "%s"\n' "$(yq -r "$item_query.summary // \"\"" "$fragment_file")"
    printf '          status: "active"\n'
    printf '          path: "%s"\n' "$path"
    printf '          access: "%s"\n' "$(yq -r "$item_query.access // \"agent\"" "$fragment_file")"
    printf '          manifest_fragment_path: ".octon/inputs/additive/extensions/%s/%s/manifest.fragment.yml"\n' "$pack_id" "${commands_root_rel%/}"
    printf '          projection_source_path: "%s"\n' "$projection_source_path"
    write_fragment_host_adapters "$fragment_file" "$item_query"
    write_fragment_selectors "$fragment_file" "$item_query"
    write_fragment_fingerprints "$fragment_file" "$item_query"
    index=$((index + 1))
  done
}

write_pack_skill_routing_exports() {
  local pack_id="$1" source_id="$2" manifest_abs="$3" skills_root_rel fragment_file item_query path projection_source_path
  skills_root_rel="$(yq -r '.content_entrypoints.skills // ""' "$manifest_abs")"
  if [[ -z "$skills_root_rel" || "$skills_root_rel" == "null" ]]; then
    printf '      skills: []\n'
    return
  fi
  fragment_file="$(ext_pack_root_abs "$pack_id")/${skills_root_rel%/}/manifest.fragment.yml"
  if [[ ! -f "$fragment_file" ]]; then
    printf '      skills: []\n'
    return
  fi
  if [[ "$(yq -r '.skills | length' "$fragment_file" 2>/dev/null || echo 0)" == "0" ]]; then
    printf '      skills: []\n'
    return
  fi

  printf '      skills:\n'
  local index
  index=0
  while true; do
    if ! yq -e ".skills[$index]" "$fragment_file" >/dev/null 2>&1; then
      break
    fi
    item_query=".skills[$index]"
    path="$(yq -r "$item_query.path // \"\"" "$fragment_file")"
    path="${path%/}"
    projection_source_path="$(ext_published_skill_projection_rel "$pack_id" "$source_id" "$path")"
    printf '        - capability_id: "%s"\n' "$(yq -r "$item_query.id // \"\"" "$fragment_file")"
    printf '          display_name: "%s"\n' "$(yq -r "$item_query.display_name // \"\"" "$fragment_file")"
    printf '          summary: "%s"\n' "$(yq -r "$item_query.summary // \"\"" "$fragment_file")"
    printf '          status: "%s"\n' "$(yq -r "$item_query.status // \"active\"" "$fragment_file")"
    printf '          path: "%s"\n' "${path}/"
    printf '          manifest_fragment_path: ".octon/inputs/additive/extensions/%s/%s/manifest.fragment.yml"\n' "$pack_id" "${skills_root_rel%/}"
    printf '          projection_source_path: "%s"\n' "$projection_source_path"
    write_fragment_host_adapters "$fragment_file" "$item_query"
    write_fragment_selectors "$fragment_file" "$item_query"
    write_fragment_fingerprints "$fragment_file" "$item_query"
    index=$((index + 1))
  done
}

write_routing_exports() {
  local pack_id="$1" source_id="$2" manifest_abs="$3"
  printf '    routing_exports:\n'
  write_pack_command_routing_exports "$pack_id" "$source_id" "$manifest_abs"
  write_pack_skill_routing_exports "$pack_id" "$source_id" "$manifest_abs"
}

write_effective_files() {
  local desired_sha="$1" root_sha="$2" tmpdir="$3" status="$4"
  local active_tmp quarantine_tmp family_tmp catalog_tmp artifact_map_tmp lock_tmp published_tmp receipt_tmp previous_family_tmp
  local key pack_id source_id manifest_abs manifest_rel trust_decision
  local rel_path bucket abs_path sha payload_lines payload_sha
  local receipt_slug receipt_rel receipt_abs receipt_id receipt_sha
  local invalidation_conditions=(
    "desired-config-sha-changed"
    "root-manifest-sha-changed"
    "pack-manifest-or-payload-changed"
    "published-pack-set-changed"
    "quarantine-state-changed"
  )

  active_tmp="$tmpdir/active.yml"
  quarantine_tmp="$tmpdir/quarantine.yml"
  family_tmp="$tmpdir/effective-extensions"
  catalog_tmp="$family_tmp/catalog.effective.yml"
  artifact_map_tmp="$family_tmp/artifact-map.yml"
  lock_tmp="$family_tmp/generation.lock.yml"
  published_tmp="$family_tmp/published"
  receipt_tmp="$tmpdir/publication.receipt.yml"

  mkdir -p "$published_tmp"

  for key in "${EXT_PUBLISHED_KEYS[@]}"; do
    pack_id="$(ext_key_pack_id "$key")"
    source_id="$(ext_key_source_id "$key")"
    manifest_abs="$ROOT_DIR/${EXT_PUBLISHED_MANIFEST_REL["$key"]}"
    stage_pack_projection_exports "$pack_id" "$source_id" "$manifest_abs" "$published_tmp/$pack_id/$source_id"
  done

  {
    printf 'schema_version: "octon-extension-quarantine-state-v3"\n'
    printf 'updated_at: "%s"\n' "$PUBLISHED_AT"
    ext_write_quarantine_records "$PUBLISHED_AT"
  } >"$quarantine_tmp"

  receipt_slug="$(receipt_timestamp_slug "$PUBLISHED_AT")"
  receipt_rel="$(extension_publication_receipt_rel "$receipt_slug" "$GENERATION_ID")"
  receipt_abs="$ROOT_DIR/$receipt_rel"
  receipt_id="extensions-$receipt_slug-$GENERATION_ID"
  write_extension_publication_receipt "$receipt_tmp" "$receipt_id" "$GENERATION_ID" "$status" "$desired_sha" "$root_sha" "$published_tmp"
  receipt_sha="$(ext_hash_file "$receipt_tmp")"

  {
    printf 'schema_version: "octon-extension-active-state-v3"\n'
    printf 'desired_config_revision:\n'
    printf '  path: ".octon/instance/extensions.yml"\n'
    printf '  sha256: "%s"\n' "$desired_sha"
    ext_emit_pack_ref_list "desired_selected_packs" "${EXT_SELECTED_KEYS[@]}"
    ext_emit_pack_ref_list "published_active_packs" "${PUBLISHED_SELECTED_KEYS[@]}"
    ext_emit_dependency_closure_list "dependency_closure" "${EXT_PUBLISHED_KEYS[@]}"
    printf 'generation_id: "%s"\n' "$GENERATION_ID"
    printf 'published_effective_catalog: ".octon/generated/effective/extensions/catalog.effective.yml"\n'
    printf 'published_artifact_map: ".octon/generated/effective/extensions/artifact-map.yml"\n'
    printf 'published_generation_lock: ".octon/generated/effective/extensions/generation.lock.yml"\n'
    printf 'publication_receipt_path: "%s"\n' "$receipt_rel"
    printf 'publication_receipt_sha256: "%s"\n' "$receipt_sha"
    printf 'invalidation_conditions:\n'
    write_string_array_yaml '  ' "${invalidation_conditions[@]}"
    printf 'required_inputs:\n'
    printf '  - ".octon/instance/extensions.yml"\n'
    printf '  - ".octon/octon.yml"\n'
    for key in "${EXT_SELECTED_KEYS[@]}"; do
      printf '  - ".octon/inputs/additive/extensions/%s/pack.yml"\n' "$(ext_key_pack_id "$key")"
    done
    printf 'validation_timestamp: "%s"\n' "$PUBLISHED_AT"
    printf 'status: "%s"\n' "$status"
  } >"$active_tmp"

  {
    printf 'schema_version: "octon-extension-effective-catalog-v4"\n'
    printf 'generator_version: "%s"\n' "$GENERATOR_VERSION"
    printf 'generation_id: "%s"\n' "$GENERATION_ID"
    printf 'published_at: "%s"\n' "$PUBLISHED_AT"
    printf 'publication_status: "%s"\n' "$status"
    printf 'publication_receipt_path: "%s"\n' "$receipt_rel"
    printf 'invalidation_conditions:\n'
    write_string_array_yaml '  ' "${invalidation_conditions[@]}"
    ext_emit_pack_ref_list "desired_selected_packs" "${EXT_SELECTED_KEYS[@]}"
    ext_emit_pack_ref_list "published_active_packs" "${PUBLISHED_SELECTED_KEYS[@]}"
    ext_emit_dependency_closure_list "dependency_closure" "${EXT_PUBLISHED_KEYS[@]}"
    if [[ "${#EXT_PUBLISHED_KEYS[@]}" -eq 0 ]]; then
      printf 'packs: []\n'
    else
      printf 'packs:\n'
      for key in "${EXT_PUBLISHED_KEYS[@]}"; do
        pack_id="$(ext_key_pack_id "$key")"
        source_id="$(ext_key_source_id "$key")"
        manifest_rel="${EXT_PUBLISHED_MANIFEST_REL["$key"]}"
        manifest_abs="$ROOT_DIR/$manifest_rel"
        trust_decision="${EXT_PUBLISHED_TRUST_DECISION["$key"]}"
        printf '  - pack_id: "%s"\n' "$pack_id"
        printf '    source_id: "%s"\n' "$source_id"
        printf '    version: "%s"\n' "${EXT_PUBLISHED_VERSION["$key"]}"
        printf '    origin_class: "%s"\n' "${EXT_PUBLISHED_ORIGIN_CLASS["$key"]}"
        printf '    manifest_path: "%s"\n' "$manifest_rel"
        printf '    trust_decision: "%s"\n' "$trust_decision"
        printf '    publication_status: "%s"\n' "$status"
        write_routing_exports "$pack_id" "$source_id" "$manifest_abs"
      done
    fi
    printf 'source:\n'
    printf '  desired_config_path: ".octon/instance/extensions.yml"\n'
    printf '  desired_config_sha256: "%s"\n' "$desired_sha"
    printf '  root_manifest_path: ".octon/octon.yml"\n'
    printf '  root_manifest_sha256: "%s"\n' "$root_sha"
  } >"$catalog_tmp"

  {
    printf 'schema_version: "octon-extension-artifact-map-v4"\n'
    printf 'generator_version: "%s"\n' "$GENERATOR_VERSION"
    printf 'generation_id: "%s"\n' "$GENERATION_ID"
    printf 'published_at: "%s"\n' "$PUBLISHED_AT"
    if [[ "${#EXT_PUBLISHED_KEYS[@]}" -eq 0 ]]; then
      printf 'artifacts: []\n'
    else
      printf 'artifacts:\n'
      for key in "${EXT_PUBLISHED_KEYS[@]}"; do
        pack_id="$(ext_key_pack_id "$key")"
        source_id="$(ext_key_source_id "$key")"
        while IFS= read -r abs_path; do
          [[ -n "$abs_path" ]] || continue
          rel_path="${abs_path#$(ext_pack_root_abs "$pack_id")/}"
          bucket="$(ext_bucket_for_relative_path "$rel_path")"
          sha="$(ext_hash_file "$abs_path")"
          printf '  - pack_id: "%s"\n' "$pack_id"
          printf '    source_id: "%s"\n' "$source_id"
          printf '    bucket: "%s"\n' "$bucket"
          printf '    relative_path: "%s"\n' "$rel_path"
          printf '    source_path: ".octon/inputs/additive/extensions/%s/%s"\n' "$pack_id" "$rel_path"
          printf '    sha256: "%s"\n' "$sha"
        done < <(find "$(ext_pack_root_abs "$pack_id")" -type f | sort)
      done
    fi
  } >"$artifact_map_tmp"

  {
    printf 'schema_version: "octon-extension-generation-lock-v4"\n'
    printf 'generator_version: "%s"\n' "$GENERATOR_VERSION"
    printf 'generation_id: "%s"\n' "$GENERATION_ID"
    printf 'published_at: "%s"\n' "$PUBLISHED_AT"
    printf 'publication_status: "%s"\n' "$status"
    printf 'publication_receipt_path: "%s"\n' "$receipt_rel"
    printf 'publication_receipt_sha256: "%s"\n' "$receipt_sha"
    printf 'desired_config_sha256: "%s"\n' "$desired_sha"
    printf 'root_manifest_sha256: "%s"\n' "$root_sha"
    printf 'published_files:\n'
    printf '  - path: ".octon/generated/effective/extensions/catalog.effective.yml"\n'
    printf '  - path: ".octon/generated/effective/extensions/artifact-map.yml"\n'
    printf '  - path: ".octon/generated/effective/extensions/generation.lock.yml"\n'
    while IFS= read -r abs_path; do
      [[ -n "$abs_path" ]] || continue
      rel_path="${abs_path#${family_tmp}/}"
      printf '  - path: ".octon/generated/effective/extensions/%s"\n' "$rel_path"
    done < <(find "$published_tmp" \( -type f -o -type d \) ! -path "$published_tmp" | sort)
    printf 'required_inputs:\n'
    printf '  - ".octon/instance/extensions.yml"\n'
    printf '  - ".octon/octon.yml"\n'
    for key in "${EXT_SELECTED_KEYS[@]}"; do
      printf '  - ".octon/inputs/additive/extensions/%s/pack.yml"\n' "$(ext_key_pack_id "$key")"
    done
    printf 'invalidation_conditions:\n'
    write_string_array_yaml '  ' "${invalidation_conditions[@]}"
    if [[ "${#EXT_PUBLISHED_KEYS[@]}" -eq 0 ]]; then
      printf 'pack_payload_digests: []\n'
    else
      printf 'pack_payload_digests:\n'
      for key in "${EXT_PUBLISHED_KEYS[@]}"; do
        pack_id="$(ext_key_pack_id "$key")"
        source_id="$(ext_key_source_id "$key")"
        payload_lines=""
        printf '  - pack_id: "%s"\n' "$pack_id"
        printf '    source_id: "%s"\n' "$source_id"
        printf '    manifest_path: "%s"\n' "${EXT_PUBLISHED_MANIFEST_REL["$key"]}"
        printf '    origin_class: "%s"\n' "${EXT_PUBLISHED_ORIGIN_CLASS["$key"]}"
        printf '    version: "%s"\n' "${EXT_PUBLISHED_VERSION["$key"]}"
        while IFS= read -r abs_path; do
          [[ -n "$abs_path" ]] || continue
          rel_path="${abs_path#$(ext_pack_root_abs "$pack_id")/}"
          sha="$(ext_hash_file "$abs_path")"
          payload_lines+="${sha} .octon/inputs/additive/extensions/${pack_id}/${rel_path}"$'\n'
        done < <(find "$(ext_pack_root_abs "$pack_id")" -type f | sort)
        payload_sha="$(printf '%s' "$payload_lines" | ext_hash_text)"
        printf '    payload_sha256: "%s"\n' "$payload_sha"
        printf '    files:\n'
        while IFS= read -r abs_path; do
          [[ -n "$abs_path" ]] || continue
          rel_path="${abs_path#$(ext_pack_root_abs "$pack_id")/}"
          sha="$(ext_hash_file "$abs_path")"
          printf '      - path: ".octon/inputs/additive/extensions/%s/%s"\n' "$pack_id" "$rel_path"
          printf '        sha256: "%s"\n' "$sha"
        done < <(find "$(ext_pack_root_abs "$pack_id")" -type f | sort)
      done
    fi
  } >"$lock_tmp"

  mkdir -p "$(dirname "$ACTIVE_STATE")" "$(dirname "$receipt_abs")"
  previous_family_tmp="$tmpdir/effective-extensions.previous"
  if [[ -d "$EFFECTIVE_DIR" ]]; then
    mv "$EFFECTIVE_DIR" "$previous_family_tmp"
  fi
  mv "$family_tmp" "$EFFECTIVE_DIR"
  mv "$receipt_tmp" "$receipt_abs"
  mv "$quarantine_tmp" "$QUARANTINE_STATE"
  mv "$active_tmp" "$ACTIVE_STATE"
}

main() {
  local desired_sha root_sha tmpdir status selected_key pack_id source_id

  PUBLISHED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  desired_sha="$(ext_hash_file "$EXTENSIONS_MANIFEST")"
  root_sha="$(ext_hash_file "$ROOT_MANIFEST")"
  GENERATOR_VERSION="$(yq -r '.versioning.harness.release_version // ""' "$ROOT_MANIFEST")"
  GENERATION_ID="extensions-$(printf '%s' "$desired_sha" | cut -c1-12)"

  ext_load_selected_keys_from_manifest
  tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/octon-extension-state.XXXXXX")"
  trap '[[ -n "${tmpdir:-}" ]] && rm -r -f -- "$tmpdir"' EXIT

  for selected_key in "${EXT_SELECTED_KEYS[@]}"; do
    pack_id="$(ext_key_pack_id "$selected_key")"
    source_id="$(ext_key_source_id "$selected_key")"
    ext_clear_candidate_state
    if ext_resolve_candidate_pack "$pack_id" "$source_id" 1; then
      ext_merge_candidate_into_published
      PUBLISHED_SELECTED_KEYS+=("$selected_key")
    else
      ext_record_quarantine "$pack_id" "$source_id" "$EXT_LAST_ERROR_REASON" "$pack_id" "$EXT_LAST_ERROR_ACKNOWLEDGEMENT_ID"
    fi
  done

  mapfile -t EXT_SELECTED_KEYS < <(ext_pack_key_sort "${EXT_SELECTED_KEYS[@]}")
  mapfile -t EXT_PUBLISHED_KEYS < <(ext_pack_key_sort "${EXT_PUBLISHED_KEYS[@]}")
  mapfile -t PUBLISHED_SELECTED_KEYS < <(ext_pack_key_sort "${PUBLISHED_SELECTED_KEYS[@]}")
  mapfile -t EXT_QUARANTINE_KEYS < <(ext_pack_key_sort "${EXT_QUARANTINE_KEYS[@]}")

  enforce_native_capability_collision_quarantine
  prune_unsatisfied_dependents

  if [[ "${#EXT_SELECTED_KEYS[@]}" -eq 0 ]]; then
    status="published"
  elif [[ "${#PUBLISHED_SELECTED_KEYS[@]}" -eq 0 ]]; then
    status="withdrawn"
  elif [[ "${#EXT_QUARANTINE_KEYS[@]}" -gt 0 ]]; then
    status="published_with_quarantine"
  else
    status="published"
  fi

  write_effective_files "$desired_sha" "$root_sha" "$tmpdir" "$status"
  echo "[OK] published extension state: $GENERATION_ID ($status)"
}

main "$@"
