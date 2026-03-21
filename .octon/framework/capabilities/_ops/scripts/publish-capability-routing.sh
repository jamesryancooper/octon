#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ -n "${OCTON_DIR_OVERRIDE:-}" ]]; then
  OCTON_DIR="$OCTON_DIR_OVERRIDE"
  ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
else
  OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../.." && pwd)"
  ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
fi

ROOT_MANIFEST="$OCTON_DIR/octon.yml"
COMMANDS_MANIFEST="$OCTON_DIR/framework/capabilities/runtime/commands/manifest.yml"
SKILLS_MANIFEST="$OCTON_DIR/framework/capabilities/runtime/skills/manifest.yml"
SKILLS_REGISTRY="$OCTON_DIR/framework/capabilities/runtime/skills/registry.yml"
SERVICES_MANIFEST="$OCTON_DIR/framework/capabilities/runtime/services/manifest.yml"
TOOLS_MANIFEST="$OCTON_DIR/framework/capabilities/runtime/tools/manifest.yml"
INSTANCE_COMMANDS_MANIFEST="$OCTON_DIR/instance/capabilities/runtime/commands/manifest.yml"
INSTANCE_SKILLS_MANIFEST="$OCTON_DIR/instance/capabilities/runtime/skills/manifest.yml"
LOCALITY_SCOPES_FILE="$OCTON_DIR/generated/effective/locality/scopes.effective.yml"
LOCALITY_LOCK_FILE="$OCTON_DIR/generated/effective/locality/generation.lock.yml"
EXTENSIONS_CATALOG="$OCTON_DIR/generated/effective/extensions/catalog.effective.yml"
EXTENSIONS_LOCK_FILE="$OCTON_DIR/generated/effective/extensions/generation.lock.yml"
EFFECTIVE_DIR="$OCTON_DIR/generated/effective/capabilities"
ROUTING_FILE="$EFFECTIVE_DIR/routing.effective.yml"
ARTIFACT_MAP_FILE="$EFFECTIVE_DIR/artifact-map.yml"
GENERATION_LOCK_FILE="$EFFECTIVE_DIR/generation.lock.yml"
LOCALITY_SCOPES_JSON='[]'
PUBLISHED_AT=""
GENERATOR_VERSION=""

hash_file() {
  local file="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
  else
    sha256sum "$file" | awk '{print $1}'
  fi
}

hash_text() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 | awk '{print $1}'
  else
    sha256sum | awk '{print $1}'
  fi
}

receipt_timestamp_slug() {
  local timestamp="$1"
  timestamp="${timestamp//:/-}"
  printf '%s\n' "$timestamp"
}

capability_publication_receipt_rel() {
  local timestamp_slug="$1" generation_id="$2"
  printf '.octon/state/evidence/validation/publication/capabilities/%s-%s.yml\n' "$timestamp_slug" "$generation_id"
}

write_capability_publication_receipt() {
  local output_file="$1" receipt_id="$2" generation_id="$3" publication_status="$4"
  local root_sha="$5" commands_sha="$6" skills_sha="$7" skills_registry_sha="$8" services_sha="$9" tools_sha="${10}"
  local instance_commands_sha="${11}" instance_skills_sha="${12}" locality_scopes_sha="${13}" locality_lock_sha="${14}" locality_status="${15}" extensions_sha="${16}" extensions_lock_sha="${17}" extensions_status="${18}"

  {
    printf 'schema_version: "octon-validation-publication-receipt-v1"\n'
    printf 'receipt_id: "%s"\n' "$receipt_id"
    printf 'publication_family: "capabilities"\n'
    printf 'generation_id: "%s"\n' "$generation_id"
    printf 'result: "%s"\n' "$publication_status"
    printf 'validated_at: "%s"\n' "$PUBLISHED_AT"
    printf 'validator_version: "%s"\n' "$GENERATOR_VERSION"
    printf 'contract_refs:\n'
    printf '  - ".octon/framework/cognition/_meta/architecture/generated/effective/capabilities/schemas/capability-routing-effective.schema.json"\n'
    printf '  - ".octon/framework/cognition/_meta/architecture/generated/effective/capabilities/schemas/capability-routing-generation-lock.schema.json"\n'
    printf 'source_digests:\n'
    printf '  root_manifest_sha256: "%s"\n' "$root_sha"
    printf '  framework_commands_manifest_sha256: "%s"\n' "$commands_sha"
    printf '  framework_skills_manifest_sha256: "%s"\n' "$skills_sha"
    printf '  framework_skills_registry_sha256: "%s"\n' "$skills_registry_sha"
    printf '  framework_services_manifest_sha256: "%s"\n' "$services_sha"
    printf '  framework_tools_manifest_sha256: "%s"\n' "$tools_sha"
    printf '  instance_commands_manifest_sha256: "%s"\n' "$instance_commands_sha"
    printf '  instance_skills_manifest_sha256: "%s"\n' "$instance_skills_sha"
    printf '  locality_scopes_sha256: "%s"\n' "$locality_scopes_sha"
    printf '  locality_generation_lock_sha256: "%s"\n' "$locality_lock_sha"
    printf '  extensions_catalog_sha256: "%s"\n' "$extensions_sha"
    printf '  extensions_generation_lock_sha256: "%s"\n' "$extensions_lock_sha"
    if [[ "$publication_status" == "published" ]]; then
      printf 'blocked_reasons: []\n'
      printf 'quarantined_subjects: []\n'
    else
      printf 'blocked_reasons:\n'
      if [[ "$locality_status" != "published" ]]; then
        printf '  - "locality:%s"\n' "$locality_status"
      fi
      if [[ "$extensions_status" != "published" ]]; then
        printf '  - "extensions:%s"\n' "$extensions_status"
      fi
      printf 'quarantined_subjects:\n'
      if [[ "$locality_status" != "published" ]]; then
        printf '  - subject_kind: "repo"\n'
        printf '    subject_id: "locality"\n'
        printf '    reason_code: "%s"\n' "$locality_status"
        printf '    manifest_path: ".octon/generated/effective/locality/scopes.effective.yml"\n'
      fi
      if [[ "$extensions_status" != "published" ]]; then
        printf '  - subject_kind: "repo"\n'
        printf '    subject_id: "extensions"\n'
        printf '    reason_code: "%s"\n' "$extensions_status"
        printf '    manifest_path: ".octon/generated/effective/extensions/catalog.effective.yml"\n'
      fi
    fi
    printf 'published_paths:\n'
    printf '  - ".octon/generated/effective/capabilities/routing.effective.yml"\n'
    printf '  - ".octon/generated/effective/capabilities/artifact-map.yml"\n'
    printf '  - ".octon/generated/effective/capabilities/generation.lock.yml"\n'
    printf 'required_inputs:\n'
    printf '  - ".octon/octon.yml"\n'
    printf '  - ".octon/framework/capabilities/runtime/commands/manifest.yml"\n'
    printf '  - ".octon/framework/capabilities/runtime/skills/manifest.yml"\n'
    printf '  - ".octon/framework/capabilities/runtime/skills/registry.yml"\n'
    printf '  - ".octon/framework/capabilities/runtime/services/manifest.yml"\n'
    printf '  - ".octon/framework/capabilities/runtime/tools/manifest.yml"\n'
    printf '  - ".octon/instance/capabilities/runtime/commands/manifest.yml"\n'
    printf '  - ".octon/instance/capabilities/runtime/skills/manifest.yml"\n'
    printf '  - ".octon/generated/effective/locality/scopes.effective.yml"\n'
    printf '  - ".octon/generated/effective/locality/generation.lock.yml"\n'
    printf '  - ".octon/generated/effective/extensions/catalog.effective.yml"\n'
    printf '  - ".octon/generated/effective/extensions/generation.lock.yml"\n'
  } >"$output_file"
}

normalize_path() {
  local value="$1"
  value="${value#./}"
  value="${value%/}"
  if [[ -z "$value" ]]; then
    value="."
  fi
  printf '%s\n' "$value"
}

glob_anchor_path() {
  local pattern="$1"
  local prefix=""
  local segment
  local IFS='/'
  read -r -a segments <<<"$pattern"
  for segment in "${segments[@]}"; do
    if [[ "$segment" == *'*'* || "$segment" == *'?'* || "$segment" == *'['* || "$segment" == *']'* || "$segment" == *'{'* || "$segment" == *'}'* ]]; then
      break
    fi
    [[ -n "$segment" ]] || continue
    if [[ -z "$prefix" ]]; then
      prefix="$segment"
    else
      prefix="$prefix/$segment"
    fi
  done
  if [[ -z "$prefix" ]]; then
    printf '.\n'
  else
    printf '%s\n' "$prefix"
  fi
}

path_depth() {
  local path="$1"
  path="$(normalize_path "$path")"
  if [[ "$path" == "." ]]; then
    printf '0\n'
  else
    awk -F'/' '{print NF}' <<<"$path"
  fi
}

selector_specificity() {
  local selectors_json="$1"
  local total=0
  local pattern anchor depth
  while IFS= read -r pattern; do
    [[ -n "$pattern" ]] || continue
    anchor="$(glob_anchor_path "$pattern")"
    depth="$(path_depth "$anchor")"
    total=$((total + depth))
  done < <(jq -r '(.include // [])[]?, (.exclude // [])[]?' <<<"$selectors_json")
  printf '%s\n' "$total"
}

origin_rank() {
  case "$1" in
    instance) printf '0\n' ;;
    framework) printf '1\n' ;;
    extension) printf '2\n' ;;
    *) printf '9\n' ;;
  esac
}

source_kind_for_origin() {
  case "$1" in
    framework) printf 'framework-native\n' ;;
    instance) printf 'instance-native\n' ;;
    extension) printf 'extension-export\n' ;;
    *) printf 'unknown\n' ;;
  esac
}

precedence_tier_for_origin() {
  case "$1" in
    extension) printf 'additive-extension\n' ;;
    *) printf 'native-authority\n' ;;
  esac
}

json_string() {
  jq -r "$2 // \"\"" "$1"
}

json_compact() {
  jq -c "$2" "$1"
}

json_value_from_text() {
  jq -cn --argjson value "$1" '$value'
}

skill_registry_entry_json() {
  local skill_id="$1"
  yq -o=json ".skills.\"$skill_id\" // {}" "$SKILLS_REGISTRY"
}

active_locality_scopes_json() {
  yq -o=json '.' "$LOCALITY_SCOPES_FILE" | jq -c '
    . as $doc
    | ($doc.scopes // []) as $scopes
    | if ($doc | has("active_scope_ids")) then
        ($doc.active_scope_ids // []) as $active
        | $scopes | map(. as $scope | select($active | index($scope.scope_id)))
      else
        $scopes | map(select((.status // "active") == "active"))
      end
  '
}

scope_relevance_json() {
  local domain="$1"
  local capability_kind="$2"
  local fingerprints_json="$3"
  jq -cn \
    --arg domain "$domain" \
    --arg capability_kind "$capability_kind" \
    --argjson fingerprints "$fingerprints_json" \
    --argjson scopes "$LOCALITY_SCOPES_JSON" '
      $scopes as $allScopes
      | reduce $allScopes[] as $scope (
          {
            matching_scope_ids: [],
            tech_tag_matches: [],
            language_tag_matches: [],
            preferred_domain_match_scope_ids: [],
            preferred_kind_match_scope_ids: [],
            score: 0
          };
          ($scope.tech_tags // []) as $scopeTech
          | ($scope.language_tags // []) as $scopeLang
          | ($scope.routing_hints.preferred_capability_domains // []) as $preferredDomains
          | ($scope.routing_hints.ranking_hints.preferred_capability_kinds // []) as $preferredKinds
          | (($fingerprints.tech_tags // []) | map(select($scopeTech | index(.)))) as $techMatches
          | (($fingerprints.language_tags // []) | map(select($scopeLang | index(.)))) as $languageMatches
          | (($preferredDomains | index($domain)) != null and ($domain | length > 0)) as $domainMatch
          | (($preferredKinds | index($capability_kind)) != null) as $kindMatch
          | if ($techMatches | length) > 0 or ($languageMatches | length) > 0 or $domainMatch or $kindMatch then
              .matching_scope_ids += [$scope.scope_id]
              | .tech_tag_matches += $techMatches
              | .language_tag_matches += $languageMatches
              | if $domainMatch then .preferred_domain_match_scope_ids += [$scope.scope_id] else . end
              | if $kindMatch then .preferred_kind_match_scope_ids += [$scope.scope_id] else . end
              | .score += (($techMatches | length) + ($languageMatches | length) + (if $domainMatch then 1 else 0 end) + (if $kindMatch then 1 else 0 end))
            else
              .
            end
        )
    '
}

framework_commands_digest() { hash_file "$COMMANDS_MANIFEST"; }
framework_skills_manifest_digest() { hash_file "$SKILLS_MANIFEST"; }
framework_skills_registry_digest() { hash_file "$SKILLS_REGISTRY"; }
framework_services_digest() { hash_file "$SERVICES_MANIFEST"; }
framework_tools_digest() { hash_file "$TOOLS_MANIFEST"; }
instance_commands_manifest_digest() { hash_file "$INSTANCE_COMMANDS_MANIFEST"; }
instance_skills_manifest_digest() { hash_file "$INSTANCE_SKILLS_MANIFEST"; }
locality_scopes_digest() { hash_file "$LOCALITY_SCOPES_FILE"; }
locality_lock_digest() { hash_file "$LOCALITY_LOCK_FILE"; }
extensions_catalog_digest() { hash_file "$EXTENSIONS_CATALOG"; }
extensions_lock_digest() { hash_file "$EXTENSIONS_LOCK_FILE"; }

native_entry_routing_json() {
  local entry_json="$1"
  jq -c '
    (.routing // {}) as $routing
    | {
        selectors: {
          include: ($routing.selectors.include // ["**"]),
          exclude: ($routing.selectors.exclude // [])
        },
        fingerprints: {
          tech_tags: ($routing.fingerprints.tech_tags // []),
          language_tags: ($routing.fingerprints.language_tags // [])
        }
      }
  ' <<<"$entry_json"
}

native_host_adapters_json() {
  local entry_json="$1"
  jq -c '(.host_adapters // [])' <<<"$entry_json"
}

emit_candidate() {
  local output_file="$1"
  local effective_id="$2"
  local artifact_map_id="$3"
  local origin_class="$4"
  local capability_kind="$5"
  local capability_id="$6"
  local display_name="$7"
  local summary="$8"
  local status="$9"
  local source_manifest="${10}"
  local interface_type="${11}"
  local domain="${12}"
  local host_adapters_json="${13}"
  local selectors_json="${14}"
  local fingerprints_json="${15}"
  local scope_relevance_json="${16}"
  local precedence_tier="${17}"
  local stable_sort_key="${18}"
  local projection_name="${19}"

  jq -cn \
    --arg effective_id "$effective_id" \
    --arg artifact_map_id "$artifact_map_id" \
    --arg origin_class "$origin_class" \
    --arg capability_kind "$capability_kind" \
    --arg capability_id "$capability_id" \
    --arg display_name "$display_name" \
    --arg summary "$summary" \
    --arg status "$status" \
    --arg source_manifest "$source_manifest" \
    --arg interface_type "$interface_type" \
    --arg capability_domain "$domain" \
    --arg precedence_tier "$precedence_tier" \
    --arg stable_sort_key "$stable_sort_key" \
    --arg projection_name "$projection_name" \
    --argjson host_adapters "$host_adapters_json" \
    --argjson selectors "$selectors_json" \
    --argjson fingerprints "$fingerprints_json" \
    --argjson scope_relevance "$scope_relevance_json" \
    '
      {
        effective_id: $effective_id,
        artifact_map_id: $artifact_map_id,
        origin_class: $origin_class,
        capability_kind: $capability_kind,
        capability_id: $capability_id,
        display_name: $display_name,
        summary: $summary,
        status: $status,
        source_manifest: $source_manifest,
        capability_domain: $capability_domain,
        host_adapters: $host_adapters,
        selectors: $selectors,
        fingerprints: $fingerprints,
        scope_relevance: $scope_relevance,
        precedence_tier: $precedence_tier,
        stable_sort_key: $stable_sort_key,
        projection_name: $projection_name
      }
      | if ($interface_type | length) > 0 then .interface_type = $interface_type else . end
    ' >>"$output_file"
  printf '\n' >>"$output_file"
}

emit_artifact() {
  local output_file="$1"
  local artifact_map_id="$2"
  local effective_id="$3"
  local origin_class="$4"
  local capability_kind="$5"
  local capability_id="$6"
  local display_name="$7"
  local source_manifest_path="$8"
  local source_manifest_sha256="$9"
  local source_path="${10}"
  local source_sha256="${11}"
  local source_kind="${12}"
  local extension_pack_id="${13}"
  local extension_source_id="${14}"
  local extension_export_kind="${15}"
  local extension_export_id="${16}"

  jq -cn \
    --arg artifact_map_id "$artifact_map_id" \
    --arg effective_id "$effective_id" \
    --arg origin_class "$origin_class" \
    --arg capability_kind "$capability_kind" \
    --arg capability_id "$capability_id" \
    --arg display_name "$display_name" \
    --arg source_manifest_path "$source_manifest_path" \
    --arg source_manifest_sha256 "$source_manifest_sha256" \
    --arg source_path "$source_path" \
    --arg source_sha256 "$source_sha256" \
    --arg source_kind "$source_kind" \
    --arg extension_pack_id "$extension_pack_id" \
    --arg extension_source_id "$extension_source_id" \
    --arg extension_export_kind "$extension_export_kind" \
    --arg extension_export_id "$extension_export_id" \
    '
      {
        artifact_map_id: $artifact_map_id,
        effective_id: $effective_id,
        origin_class: $origin_class,
        capability_kind: $capability_kind,
        capability_id: $capability_id,
        display_name: $display_name,
        source_kind: $source_kind,
        source_manifest_path: $source_manifest_path,
        source_manifest_sha256: $source_manifest_sha256,
        source_path: $source_path,
        source_sha256: $source_sha256
      }
      | if ($extension_pack_id | length) > 0 then
          .extension_pack_id = $extension_pack_id
          | .extension_source_id = $extension_source_id
          | .extension_export_kind = $extension_export_kind
          | .extension_export_id = $extension_export_id
        else
          .
        end
    ' >>"$output_file"
  printf '\n' >>"$output_file"
}

stable_sort_key_for_candidate() {
  local selectors_json="$1"
  local scope_relevance_json="$2"
  local origin_class="$3"
  local capability_kind="$4"
  local effective_id="$5"
  local specificity scope_score rank
  specificity="$(selector_specificity "$selectors_json")"
  scope_score="$(jq -r '.score // 0' <<<"$scope_relevance_json")"
  rank="$(origin_rank "$origin_class")"
  printf '%04d-%04d-%01d-%s-%s\n' \
    $((9999 - specificity)) \
    $((9999 - scope_score)) \
    "$rank" \
    "$capability_kind" \
    "$effective_id"
}

framework_command_source_path() {
  printf '.octon/framework/capabilities/runtime/commands/%s\n' "$1"
}

framework_skill_source_path() {
  printf '.octon/framework/capabilities/runtime/skills/%s/SKILL.md\n' "${1%/}"
}

framework_service_source_path() {
  printf '.octon/framework/capabilities/runtime/services/%s/SERVICE.md\n' "${1%/}"
}

framework_tool_source_path() {
  printf '.octon/framework/capabilities/runtime/tools/manifest.yml\n'
}

instance_command_source_path() {
  printf '.octon/instance/capabilities/runtime/commands/%s\n' "$1"
}

instance_skill_source_path() {
  printf '.octon/instance/capabilities/runtime/skills/%s/SKILL.md\n' "${1%/}"
}

collect_framework_commands() {
  local candidates_file="$1" artifacts_file="$2"
  local manifest_sha entry_json capability_id capability_path display_name summary status source_path source_sha routing_json selectors_json fingerprints_json host_adapters_json scope_json stable_sort_key
  manifest_sha="$(framework_commands_digest)"
  while IFS= read -r entry_json; do
    [[ -n "$entry_json" ]] || continue
    capability_id="$(jq -r '.id' <<<"$entry_json")"
    capability_path="$(jq -r '.path' <<<"$entry_json")"
    display_name="$(jq -r '.display_name' <<<"$entry_json")"
    summary="$(jq -r '.summary' <<<"$entry_json")"
    status="active"
    source_path="$(framework_command_source_path "$capability_path")"
    source_sha="$(hash_file "$ROOT_DIR/$source_path")"
    routing_json="$(native_entry_routing_json "$entry_json")"
    selectors_json="$(jq -c '.selectors' <<<"$routing_json")"
    fingerprints_json="$(jq -c '.fingerprints' <<<"$routing_json")"
    host_adapters_json="$(native_host_adapters_json "$entry_json")"
    scope_json="$(scope_relevance_json "command" "command" "$fingerprints_json")"
    stable_sort_key="$(stable_sort_key_for_candidate "$selectors_json" "$scope_json" framework command "framework.command.$capability_id")"
    emit_candidate "$candidates_file" "framework.command.$capability_id" "framework-command-$capability_id" framework command "$capability_id" "$display_name" "$summary" "$status" ".octon/framework/capabilities/runtime/commands/manifest.yml" "" "command" "$host_adapters_json" "$selectors_json" "$fingerprints_json" "$scope_json" "$(precedence_tier_for_origin framework)" "$stable_sort_key" "$capability_id"
    emit_artifact "$artifacts_file" "framework-command-$capability_id" "framework.command.$capability_id" framework command "$capability_id" "$display_name" ".octon/framework/capabilities/runtime/commands/manifest.yml" "$manifest_sha" "$source_path" "$source_sha" "$(source_kind_for_origin framework)" "" "" "" ""
  done < <(yq -o=json '.commands[]?' "$COMMANDS_MANIFEST" | jq -c '.')
}

collect_framework_skills() {
  local candidates_file="$1" artifacts_file="$2"
  local manifest_sha registry_sha manifest_json registry_json capability_id skill_path display_name summary status source_path source_sha routing_json selectors_json fingerprints_json host_adapters_json scope_json stable_sort_key skill_group
  manifest_sha="$(framework_skills_manifest_digest)"
  registry_sha="$(framework_skills_registry_digest)"
  while IFS= read -r manifest_json; do
    [[ -n "$manifest_json" ]] || continue
    capability_id="$(jq -r '.id' <<<"$manifest_json")"
    skill_path="$(jq -r '.path' <<<"$manifest_json")"
    display_name="$(jq -r '.display_name' <<<"$manifest_json")"
    summary="$(jq -r '.summary' <<<"$manifest_json")"
    status="$(jq -r '.status // "active"' <<<"$manifest_json")"
    skill_group="$(jq -r '.group // ""' <<<"$manifest_json")"
    source_path="$(framework_skill_source_path "$skill_path")"
    source_sha="$(hash_file "$ROOT_DIR/$source_path")"
    registry_json="$(skill_registry_entry_json "$capability_id")"
    routing_json="$(native_entry_routing_json "$registry_json")"
    selectors_json="$(jq -c '.selectors' <<<"$routing_json")"
    fingerprints_json="$(jq -c '.fingerprints' <<<"$routing_json")"
    host_adapters_json="$(native_host_adapters_json "$registry_json")"
    scope_json="$(scope_relevance_json "$skill_group" skill "$fingerprints_json")"
    stable_sort_key="$(stable_sort_key_for_candidate "$selectors_json" "$scope_json" framework skill "framework.skill.$capability_id")"
    emit_candidate "$candidates_file" "framework.skill.$capability_id" "framework-skill-$capability_id" framework skill "$capability_id" "$display_name" "$summary" "$status" ".octon/framework/capabilities/runtime/skills/manifest.yml" "" "$skill_group" "$host_adapters_json" "$selectors_json" "$fingerprints_json" "$scope_json" "$(precedence_tier_for_origin framework)" "$stable_sort_key" "$capability_id"
    emit_artifact "$artifacts_file" "framework-skill-$capability_id" "framework.skill.$capability_id" framework skill "$capability_id" "$display_name" ".octon/framework/capabilities/runtime/skills/registry.yml" "$registry_sha" "$source_path" "$source_sha" "$(source_kind_for_origin framework)" "" "" "" ""
  done < <(yq -o=json '.skills[]?' "$SKILLS_MANIFEST" | jq -c '.')
}

collect_framework_services() {
  local candidates_file="$1" artifacts_file="$2"
  local manifest_sha entry_json capability_id service_path display_name summary status interface_type source_path source_sha routing_json selectors_json fingerprints_json host_adapters_json scope_json stable_sort_key category
  manifest_sha="$(framework_services_digest)"
  while IFS= read -r entry_json; do
    [[ -n "$entry_json" ]] || continue
    capability_id="$(jq -r '.id' <<<"$entry_json")"
    service_path="$(jq -r '.path' <<<"$entry_json")"
    display_name="$(jq -r '.display_name' <<<"$entry_json")"
    summary="$(jq -r '.summary' <<<"$entry_json")"
    status="$(jq -r '.status // "active"' <<<"$entry_json")"
    interface_type="$(jq -r '.interface_type // ""' <<<"$entry_json")"
    category="$(jq -r '.category // ""' <<<"$entry_json")"
    source_path="$(framework_service_source_path "$service_path")"
    source_sha="$(hash_file "$ROOT_DIR/$source_path")"
    routing_json="$(native_entry_routing_json "$entry_json")"
    selectors_json="$(jq -c '.selectors' <<<"$routing_json")"
    fingerprints_json="$(jq -c '.fingerprints' <<<"$routing_json")"
    host_adapters_json="$(native_host_adapters_json "$entry_json")"
    scope_json="$(scope_relevance_json "$category" service "$fingerprints_json")"
    stable_sort_key="$(stable_sort_key_for_candidate "$selectors_json" "$scope_json" framework service "framework.service.$capability_id")"
    emit_candidate "$candidates_file" "framework.service.$capability_id" "framework-service-$capability_id" framework service "$capability_id" "$display_name" "$summary" "$status" ".octon/framework/capabilities/runtime/services/manifest.yml" "$interface_type" "$category" "$host_adapters_json" "$selectors_json" "$fingerprints_json" "$scope_json" "$(precedence_tier_for_origin framework)" "$stable_sort_key" "$capability_id"
    emit_artifact "$artifacts_file" "framework-service-$capability_id" "framework.service.$capability_id" framework service "$capability_id" "$display_name" ".octon/framework/capabilities/runtime/services/manifest.yml" "$manifest_sha" "$source_path" "$source_sha" "$(source_kind_for_origin framework)" "" "" "" ""
  done < <(yq -o=json '.services[]?' "$SERVICES_MANIFEST" | jq -c '.')
}

collect_framework_tools() {
  local candidates_file="$1" artifacts_file="$2"
  local manifest_sha entry_json capability_id display_name summary status source_path source_sha routing_json selectors_json fingerprints_json host_adapters_json scope_json stable_sort_key
  manifest_sha="$(framework_tools_digest)"
  while IFS= read -r entry_json; do
    [[ -n "$entry_json" ]] || continue
    capability_id="$(jq -r '.id' <<<"$entry_json")"
    display_name="$(jq -r '.display_name' <<<"$entry_json")"
    summary="$(jq -r '.summary' <<<"$entry_json")"
    status="active"
    source_path="$(framework_tool_source_path)"
    source_sha="$(hash_file "$ROOT_DIR/$source_path")"
    routing_json="$(native_entry_routing_json "$entry_json")"
    selectors_json="$(jq -c '.selectors' <<<"$routing_json")"
    fingerprints_json="$(jq -c '.fingerprints' <<<"$routing_json")"
    host_adapters_json="$(native_host_adapters_json "$entry_json")"
    scope_json="$(scope_relevance_json "tools" tool "$fingerprints_json")"
    stable_sort_key="$(stable_sort_key_for_candidate "$selectors_json" "$scope_json" framework tool "framework.tool.$capability_id")"
    emit_candidate "$candidates_file" "framework.tool.$capability_id" "framework-tool-$capability_id" framework tool "$capability_id" "$display_name" "$summary" "$status" ".octon/framework/capabilities/runtime/tools/manifest.yml" "" "tools" "$host_adapters_json" "$selectors_json" "$fingerprints_json" "$scope_json" "$(precedence_tier_for_origin framework)" "$stable_sort_key" "$capability_id"
    emit_artifact "$artifacts_file" "framework-tool-$capability_id" "framework.tool.$capability_id" framework tool "$capability_id" "$display_name" ".octon/framework/capabilities/runtime/tools/manifest.yml" "$manifest_sha" "$source_path" "$source_sha" "$(source_kind_for_origin framework)" "" "" "" ""
  done < <(yq -o=json '.packs[]?' "$TOOLS_MANIFEST" | jq -c '.')
}

collect_instance_commands() {
  local candidates_file="$1" artifacts_file="$2"
  local manifest_sha entry_json capability_id command_path display_name summary status source_path source_sha routing_json selectors_json fingerprints_json host_adapters_json scope_json stable_sort_key
  manifest_sha="$(instance_commands_manifest_digest)"
  while IFS= read -r entry_json; do
    [[ -n "$entry_json" ]] || continue
    capability_id="$(jq -r '.id' <<<"$entry_json")"
    command_path="$(jq -r '.path // (.id + ".md")' <<<"$entry_json")"
    display_name="$(jq -r '.display_name // .id' <<<"$entry_json")"
    summary="$(jq -r '.summary // "Repo-native command capability."' <<<"$entry_json")"
    status="$(jq -r '.status // "active"' <<<"$entry_json")"
    source_path="$(instance_command_source_path "$command_path")"
    source_sha="$(hash_file "$ROOT_DIR/$source_path")"
    routing_json="$(native_entry_routing_json "$entry_json")"
    selectors_json="$(jq -c '.selectors' <<<"$routing_json")"
    fingerprints_json="$(jq -c '.fingerprints' <<<"$routing_json")"
    host_adapters_json="$(native_host_adapters_json "$entry_json")"
    scope_json="$(scope_relevance_json "command" command "$fingerprints_json")"
    stable_sort_key="$(stable_sort_key_for_candidate "$selectors_json" "$scope_json" instance command "instance.command.$capability_id")"
    emit_candidate "$candidates_file" "instance.command.$capability_id" "instance-command-$capability_id" instance command "$capability_id" "$display_name" "$summary" "$status" ".octon/instance/capabilities/runtime/commands/manifest.yml" "" "command" "$host_adapters_json" "$selectors_json" "$fingerprints_json" "$scope_json" "$(precedence_tier_for_origin instance)" "$stable_sort_key" "$capability_id"
    emit_artifact "$artifacts_file" "instance-command-$capability_id" "instance.command.$capability_id" instance command "$capability_id" "$display_name" ".octon/instance/capabilities/runtime/commands/manifest.yml" "$manifest_sha" "$source_path" "$source_sha" "$(source_kind_for_origin instance)" "" "" "" ""
  done < <(yq -o=json '.commands[]?' "$INSTANCE_COMMANDS_MANIFEST" | jq -c '.')
}

collect_instance_skills() {
  local candidates_file="$1" artifacts_file="$2"
  local manifest_sha entry_json capability_id skill_path display_name summary status source_path source_sha routing_json selectors_json fingerprints_json host_adapters_json scope_json stable_sort_key domain
  manifest_sha="$(instance_skills_manifest_digest)"
  while IFS= read -r entry_json; do
    [[ -n "$entry_json" ]] || continue
    capability_id="$(jq -r '.id' <<<"$entry_json")"
    skill_path="$(jq -r '.path // .id' <<<"$entry_json")"
    skill_path="${skill_path%/}"
    display_name="$(jq -r '.display_name // .id' <<<"$entry_json")"
    summary="$(jq -r '.summary // "Repo-native skill capability."' <<<"$entry_json")"
    status="$(jq -r '.status // "active"' <<<"$entry_json")"
    domain="$(jq -r '.group // ""' <<<"$entry_json")"
    source_path="$(instance_skill_source_path "$skill_path")"
    source_sha="$(hash_file "$ROOT_DIR/$source_path")"
    routing_json="$(native_entry_routing_json "$entry_json")"
    selectors_json="$(jq -c '.selectors' <<<"$routing_json")"
    fingerprints_json="$(jq -c '.fingerprints' <<<"$routing_json")"
    host_adapters_json="$(native_host_adapters_json "$entry_json")"
    scope_json="$(scope_relevance_json "$domain" skill "$fingerprints_json")"
    stable_sort_key="$(stable_sort_key_for_candidate "$selectors_json" "$scope_json" instance skill "instance.skill.$capability_id")"
    emit_candidate "$candidates_file" "instance.skill.$capability_id" "instance-skill-$capability_id" instance skill "$capability_id" "$display_name" "$summary" "$status" ".octon/instance/capabilities/runtime/skills/manifest.yml" "" "$domain" "$host_adapters_json" "$selectors_json" "$fingerprints_json" "$scope_json" "$(precedence_tier_for_origin instance)" "$stable_sort_key" "$capability_id"
    emit_artifact "$artifacts_file" "instance-skill-$capability_id" "instance.skill.$capability_id" instance skill "$capability_id" "$display_name" ".octon/instance/capabilities/runtime/skills/manifest.yml" "$manifest_sha" "$source_path" "$source_sha" "$(source_kind_for_origin instance)" "" "" "" ""
  done < <(yq -o=json '.skills[]?' "$INSTANCE_SKILLS_MANIFEST" | jq -c '.')
}

collect_extension_exports() {
  local candidates_file="$1" artifacts_file="$2"
  local catalog_sha pack_json pack_id source_id command_json skill_json capability_id display_name summary status routing_json selectors_json fingerprints_json host_adapters_json scope_json stable_sort_key projection_source_path path
  catalog_sha="$(extensions_catalog_digest)"
  while IFS= read -r pack_json; do
    [[ -n "$pack_json" ]] || continue
    pack_id="$(jq -r '.pack_id' <<<"$pack_json")"
    source_id="$(jq -r '.source_id' <<<"$pack_json")"

    while IFS= read -r command_json; do
      [[ -n "$command_json" ]] || continue
      capability_id="$(jq -r '.capability_id' <<<"$command_json")"
      display_name="$(jq -r '.display_name' <<<"$command_json")"
      summary="$(jq -r '.summary' <<<"$command_json")"
      status="$(jq -r '.status // "active"' <<<"$command_json")"
      routing_json="$(jq -c '{selectors: .selectors, fingerprints: .fingerprints}' <<<"$command_json")"
      selectors_json="$(jq -c '.selectors' <<<"$routing_json")"
      fingerprints_json="$(jq -c '.fingerprints' <<<"$routing_json")"
      host_adapters_json="$(jq -c '.host_adapters // []' <<<"$command_json")"
      scope_json="$(scope_relevance_json "extension" command "$fingerprints_json")"
      stable_sort_key="$(stable_sort_key_for_candidate "$selectors_json" "$scope_json" extension command "extension.command.$pack_id.$capability_id")"
      emit_candidate "$candidates_file" "extension.command.$pack_id.$capability_id" "extension-command-$pack_id-$capability_id" extension command "$capability_id" "$display_name" "$summary" "$status" ".octon/generated/effective/extensions/catalog.effective.yml" "" "extension" "$host_adapters_json" "$selectors_json" "$fingerprints_json" "$scope_json" "$(precedence_tier_for_origin extension)" "$stable_sort_key" "$capability_id"
      emit_artifact "$artifacts_file" "extension-command-$pack_id-$capability_id" "extension.command.$pack_id.$capability_id" extension command "$capability_id" "$display_name" ".octon/generated/effective/extensions/catalog.effective.yml" "$catalog_sha" ".octon/generated/effective/extensions/catalog.effective.yml" "$catalog_sha" "$(source_kind_for_origin extension)" "$pack_id" "$source_id" command "$capability_id"
    done < <(jq -c '.routing_exports.commands[]?' <<<"$pack_json")

    while IFS= read -r skill_json; do
      [[ -n "$skill_json" ]] || continue
      capability_id="$(jq -r '.capability_id' <<<"$skill_json")"
      display_name="$(jq -r '.display_name' <<<"$skill_json")"
      summary="$(jq -r '.summary' <<<"$skill_json")"
      status="$(jq -r '.status // "active"' <<<"$skill_json")"
      routing_json="$(jq -c '{selectors: .selectors, fingerprints: .fingerprints}' <<<"$skill_json")"
      selectors_json="$(jq -c '.selectors' <<<"$routing_json")"
      fingerprints_json="$(jq -c '.fingerprints' <<<"$routing_json")"
      host_adapters_json="$(jq -c '.host_adapters // []' <<<"$skill_json")"
      scope_json="$(scope_relevance_json "extension" skill "$fingerprints_json")"
      stable_sort_key="$(stable_sort_key_for_candidate "$selectors_json" "$scope_json" extension skill "extension.skill.$pack_id.$capability_id")"
      emit_candidate "$candidates_file" "extension.skill.$pack_id.$capability_id" "extension-skill-$pack_id-$capability_id" extension skill "$capability_id" "$display_name" "$summary" "$status" ".octon/generated/effective/extensions/catalog.effective.yml" "" "extension" "$host_adapters_json" "$selectors_json" "$fingerprints_json" "$scope_json" "$(precedence_tier_for_origin extension)" "$stable_sort_key" "$capability_id"
      emit_artifact "$artifacts_file" "extension-skill-$pack_id-$capability_id" "extension.skill.$pack_id.$capability_id" extension skill "$capability_id" "$display_name" ".octon/generated/effective/extensions/catalog.effective.yml" "$catalog_sha" ".octon/generated/effective/extensions/catalog.effective.yml" "$catalog_sha" "$(source_kind_for_origin extension)" "$pack_id" "$source_id" skill "$capability_id"
    done < <(jq -c '.routing_exports.skills[]?' <<<"$pack_json")
  done < <(yq -o=json '.packs[]?' "$EXTENSIONS_CATALOG" | jq -c '.')
}

sort_candidates() {
  local input_file="$1"
  local output_file="$2"
  jq -cs 'sort_by(.stable_sort_key)' "$input_file" | jq -c '.[]' >"$output_file"
}

assert_unique_field() {
  local file="$1"
  local field="$2"
  local description="$3"
  local duplicates
  duplicates="$(jq -r "$field" "$file" 2>/dev/null | awk 'NF' | LC_ALL=C sort | uniq -d)"
  if [[ -n "$duplicates" ]]; then
    echo "[ERROR] duplicate $description detected: $duplicates" >&2
    exit 1
  fi
}

normalize_payload() {
  sed -E \
    -e 's/^published_at: "?[^"]*"?/published_at: "__PUBLISHED_AT__"/' \
    -e 's#^publication_receipt_path: "?[^"]*"?#publication_receipt_path: "__PUBLICATION_RECEIPT_PATH__"#' \
    -e 's/^publication_receipt_sha256: "?[^"]*"?/publication_receipt_sha256: "__PUBLICATION_RECEIPT_SHA256__"/'
}

maybe_reuse_published_at() {
  local candidate_routing="$1"
  local candidate_map="$2"
  local candidate_lock="$3"
  local fallback="$4"

  if [[ ! -f "$ROUTING_FILE" || ! -f "$ARTIFACT_MAP_FILE" || ! -f "$GENERATION_LOCK_FILE" ]]; then
    printf '%s\n' "$fallback"
    return 0
  fi

  local current_published_at
  current_published_at="$(awk -F'"' '/^published_at:/ {print $2; exit}' "$ROUTING_FILE")"
  if [[ -z "$current_published_at" ]]; then
    printf '%s\n' "$fallback"
    return 0
  fi

  if [[ "$(normalize_payload < "$candidate_routing")" == "$(normalize_payload < "$ROUTING_FILE")" ]] \
    && [[ "$(normalize_payload < "$candidate_map")" == "$(normalize_payload < "$ARTIFACT_MAP_FILE")" ]] \
    && [[ "$(normalize_payload < "$candidate_lock")" == "$(normalize_payload < "$GENERATION_LOCK_FILE")" ]]; then
    printf '%s\n' "$current_published_at"
  else
    printf '%s\n' "$fallback"
  fi
}

main() {
  local root_sha commands_sha skills_sha skills_registry_sha services_sha tools_sha instance_commands_sha instance_skills_sha locality_scopes_sha locality_lock_sha locality_generation_id extensions_sha extensions_lock_sha extensions_generation_id
  local locality_publication_status extensions_publication_status publication_status
  local tmpdir candidates_raw candidates_sorted artifacts_raw routing_tmp artifact_tmp lock_tmp receipt_tmp
  local generation_seed generation_sha generation_id default_published_at published_at routing_context_json resolution_order_json
  local receipt_slug receipt_rel receipt_abs receipt_id receipt_sha
  local invalidation_conditions=(
    "root-manifest-sha-changed"
    "native-capability-manifest-changed"
    "locality-effective-sha-changed"
    "locality-lock-sha-changed"
    "extensions-effective-sha-changed"
    "extensions-lock-sha-changed"
  )

  mkdir -p "$EFFECTIVE_DIR"
  GENERATOR_VERSION="$(yq -r '.versioning.harness.release_version // ""' "$ROOT_MANIFEST")"
  LOCALITY_SCOPES_JSON="$(active_locality_scopes_json)"
  root_sha="$(hash_file "$ROOT_MANIFEST")"
  commands_sha="$(framework_commands_digest)"
  skills_sha="$(framework_skills_manifest_digest)"
  skills_registry_sha="$(framework_skills_registry_digest)"
  services_sha="$(framework_services_digest)"
  tools_sha="$(framework_tools_digest)"
  instance_commands_sha="$(instance_commands_manifest_digest)"
  instance_skills_sha="$(instance_skills_manifest_digest)"
  locality_scopes_sha="$(locality_scopes_digest)"
  locality_lock_sha="$(locality_lock_digest)"
  locality_generation_id="$(yq -r '.generation_id // ""' "$LOCALITY_LOCK_FILE")"
  locality_publication_status="$(yq -r '.publication_status // "published"' "$LOCALITY_SCOPES_FILE")"
  extensions_sha="$(extensions_catalog_digest)"
  extensions_lock_sha="$(extensions_lock_digest)"
  extensions_generation_id="$(yq -r '.generation_id // ""' "$EXTENSIONS_LOCK_FILE")"
  extensions_publication_status="$(yq -r '.publication_status // "published"' "$EXTENSIONS_CATALOG")"
  publication_status="published"
  if [[ "$locality_publication_status" != "published" || "$extensions_publication_status" != "published" ]]; then
    publication_status="published_with_quarantine"
  fi

  tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/octon-capabilities.XXXXXX")"
  trap '[[ -n "${tmpdir:-}" ]] && rm -rf "$tmpdir"' EXIT
  candidates_raw="$tmpdir/candidates.raw.ndjson"
  candidates_sorted="$tmpdir/candidates.sorted.ndjson"
  artifacts_raw="$tmpdir/artifacts.raw.ndjson"
  routing_tmp="$tmpdir/routing.effective.yml"
  artifact_tmp="$tmpdir/artifact-map.yml"
  lock_tmp="$tmpdir/generation.lock.yml"
  receipt_tmp="$tmpdir/publication.receipt.yml"

  : >"$candidates_raw"
  : >"$artifacts_raw"

  collect_framework_commands "$candidates_raw" "$artifacts_raw"
  collect_framework_skills "$candidates_raw" "$artifacts_raw"
  collect_framework_services "$candidates_raw" "$artifacts_raw"
  collect_framework_tools "$candidates_raw" "$artifacts_raw"
  collect_instance_commands "$candidates_raw" "$artifacts_raw"
  collect_instance_skills "$candidates_raw" "$artifacts_raw"
  collect_extension_exports "$candidates_raw" "$artifacts_raw"

  sort_candidates "$candidates_raw" "$candidates_sorted"
  assert_unique_field "$candidates_sorted" '.effective_id' "effective_id"
  assert_unique_field "$artifacts_raw" '.artifact_map_id' "artifact_map_id"

  generation_seed="$(
    printf 'root %s\ncommands %s\nskills %s\nskills-registry %s\nservices %s\ntools %s\ninstance-commands %s\ninstance-skills %s\nlocality-scopes %s\nlocality-lock %s\nextensions %s\nextensions-lock %s\n' \
      "$root_sha" "$commands_sha" "$skills_sha" "$skills_registry_sha" "$services_sha" "$tools_sha" "$instance_commands_sha" "$instance_skills_sha" "$locality_scopes_sha" "$locality_lock_sha" "$extensions_sha" "$extensions_lock_sha"
  )"
  generation_sha="$(printf '%s' "$generation_seed" | hash_text)"
  generation_id="capabilities-${generation_sha:0:12}"
  default_published_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  routing_context_json="$(jq -cn \
    --arg selector_schema_version "octon-capability-routing-selectors-v1" \
    --arg locality_generation_id "$locality_generation_id" \
    --arg extension_generation_id "$extensions_generation_id" \
    --arg host_projection_mode "materialized-copy-v1" \
    --arg locality_publication_status "$locality_publication_status" \
    --arg extension_publication_status "$extensions_publication_status" \
    --arg resolution_mode "$(yq -r '.resolution_mode // "single-active-scope"' "$LOCALITY_SCOPES_FILE")" \
    '
      {
        selector_schema_version: $selector_schema_version,
        locality_generation_id: $locality_generation_id,
        extension_generation_id: $extension_generation_id,
        host_projection_mode: $host_projection_mode,
        locality_publication_status: $locality_publication_status,
        extension_publication_status: $extension_publication_status,
        scope_resolution_mode: $resolution_mode
      }
    ')"
  resolution_order_json="$(jq -cs '[.[] | .effective_id]' "$candidates_sorted")"

  receipt_slug="$(receipt_timestamp_slug "__PUBLISHED_AT__")"
  receipt_rel="$(capability_publication_receipt_rel "$receipt_slug" "$generation_id")"
  receipt_abs="$ROOT_DIR/$receipt_rel"
  receipt_id="capabilities-${generation_id}"

  jq -n \
    --arg schema_version "octon-capability-routing-effective-v3" \
    --arg generator_version "$GENERATOR_VERSION" \
    --arg generation_id "$generation_id" \
    --arg published_at "__PUBLISHED_AT__" \
    --arg publication_status "$publication_status" \
    --arg publication_receipt_path "__PUBLICATION_RECEIPT_PATH__" \
    --arg root_sha "$root_sha" \
    --arg commands_sha "$commands_sha" \
    --arg skills_sha "$skills_sha" \
    --arg skills_registry_sha "$skills_registry_sha" \
    --arg services_sha "$services_sha" \
    --arg tools_sha "$tools_sha" \
    --arg instance_commands_sha "$instance_commands_sha" \
    --arg instance_skills_sha "$instance_skills_sha" \
    --arg locality_scopes_sha "$locality_scopes_sha" \
    --arg locality_lock_sha "$locality_lock_sha" \
    --arg locality_generation_id "$locality_generation_id" \
    --arg extensions_sha "$extensions_sha" \
    --arg extensions_lock_sha "$extensions_lock_sha" \
    --arg extensions_generation_id "$extensions_generation_id" \
    --argjson routing_context "$routing_context_json" \
    --argjson routing_candidates "$(jq -cs '.' "$candidates_sorted")" \
    --argjson resolution_order "$resolution_order_json" \
    '
      {
        schema_version: $schema_version,
        generator_version: $generator_version,
        generation_id: $generation_id,
        published_at: $published_at,
        publication_status: $publication_status,
        publication_receipt_path: $publication_receipt_path,
        invalidation_conditions: [
          "root-manifest-sha-changed",
          "native-capability-manifest-changed",
          "locality-effective-sha-changed",
          "locality-lock-sha-changed",
          "extensions-effective-sha-changed",
          "extensions-lock-sha-changed"
        ],
        source: {
          root_manifest_path: ".octon/octon.yml",
          root_manifest_sha256: $root_sha,
          framework_commands_manifest_path: ".octon/framework/capabilities/runtime/commands/manifest.yml",
          framework_commands_manifest_sha256: $commands_sha,
          framework_skills_manifest_path: ".octon/framework/capabilities/runtime/skills/manifest.yml",
          framework_skills_manifest_sha256: $skills_sha,
          framework_skills_registry_path: ".octon/framework/capabilities/runtime/skills/registry.yml",
          framework_skills_registry_sha256: $skills_registry_sha,
          framework_services_manifest_path: ".octon/framework/capabilities/runtime/services/manifest.yml",
          framework_services_manifest_sha256: $services_sha,
          framework_tools_manifest_path: ".octon/framework/capabilities/runtime/tools/manifest.yml",
          framework_tools_manifest_sha256: $tools_sha,
          instance_commands_manifest_path: ".octon/instance/capabilities/runtime/commands/manifest.yml",
          instance_commands_manifest_sha256: $instance_commands_sha,
          instance_skills_manifest_path: ".octon/instance/capabilities/runtime/skills/manifest.yml",
          instance_skills_manifest_sha256: $instance_skills_sha,
          locality_scopes_effective_path: ".octon/generated/effective/locality/scopes.effective.yml",
          locality_scopes_effective_sha256: $locality_scopes_sha,
          locality_generation_lock_path: ".octon/generated/effective/locality/generation.lock.yml",
          locality_generation_lock_sha256: $locality_lock_sha,
          locality_generation_id: $locality_generation_id,
          extensions_catalog_path: ".octon/generated/effective/extensions/catalog.effective.yml",
          extensions_catalog_sha256: $extensions_sha,
          extensions_generation_lock_path: ".octon/generated/effective/extensions/generation.lock.yml",
          extensions_generation_lock_sha256: $extensions_lock_sha,
          extensions_generation_id: $extensions_generation_id
        },
        routing_context: $routing_context,
        routing_candidates: $routing_candidates,
        resolution_order: $resolution_order
      }
    ' | yq -P - >"$routing_tmp"

  jq -n \
    --arg schema_version "octon-capability-routing-artifact-map-v3" \
    --arg generator_version "$GENERATOR_VERSION" \
    --arg generation_id "$generation_id" \
    --arg published_at "__PUBLISHED_AT__" \
    --argjson artifacts "$(jq -cs 'sort_by(.artifact_map_id)' "$artifacts_raw")" \
    '
      {
        schema_version: $schema_version,
        generator_version: $generator_version,
        generation_id: $generation_id,
        published_at: $published_at,
        artifacts: $artifacts
      }
    ' | yq -P - >"$artifact_tmp"

  jq -n \
    --arg schema_version "octon-capability-routing-generation-lock-v3" \
    --arg generator_version "$GENERATOR_VERSION" \
    --arg generation_id "$generation_id" \
    --arg published_at "__PUBLISHED_AT__" \
    --arg publication_status "$publication_status" \
    --arg publication_receipt_path "__PUBLICATION_RECEIPT_PATH__" \
    --arg publication_receipt_sha "__PUBLICATION_RECEIPT_SHA256__" \
    --arg root_sha "$root_sha" \
    --arg commands_sha "$commands_sha" \
    --arg skills_sha "$skills_sha" \
    --arg skills_registry_sha "$skills_registry_sha" \
    --arg services_sha "$services_sha" \
    --arg tools_sha "$tools_sha" \
    --arg instance_commands_sha "$instance_commands_sha" \
    --arg instance_skills_sha "$instance_skills_sha" \
    --arg locality_scopes_sha "$locality_scopes_sha" \
    --arg locality_lock_sha "$locality_lock_sha" \
    --arg locality_generation_id "$locality_generation_id" \
    --arg extensions_sha "$extensions_sha" \
    --arg extensions_lock_sha "$extensions_lock_sha" \
    --arg extensions_generation_id "$extensions_generation_id" \
    '
      {
        schema_version: $schema_version,
        generator_version: $generator_version,
        generation_id: $generation_id,
        published_at: $published_at,
        publication_status: $publication_status,
        publication_receipt_path: $publication_receipt_path,
        publication_receipt_sha256: $publication_receipt_sha,
        root_manifest_sha256: $root_sha,
        framework_commands_manifest_sha256: $commands_sha,
        framework_skills_manifest_sha256: $skills_sha,
        framework_skills_registry_sha256: $skills_registry_sha,
        framework_services_manifest_sha256: $services_sha,
        framework_tools_manifest_sha256: $tools_sha,
        instance_commands_manifest_sha256: $instance_commands_sha,
        instance_skills_manifest_sha256: $instance_skills_sha,
        locality_scopes_sha256: $locality_scopes_sha,
        locality_generation_lock_sha256: $locality_lock_sha,
        locality_generation_id: $locality_generation_id,
        extensions_catalog_sha256: $extensions_sha,
        extensions_generation_lock_sha256: $extensions_lock_sha,
        extensions_generation_id: $extensions_generation_id,
        required_inputs: [
          ".octon/octon.yml",
          ".octon/framework/capabilities/runtime/commands/manifest.yml",
          ".octon/framework/capabilities/runtime/skills/manifest.yml",
          ".octon/framework/capabilities/runtime/skills/registry.yml",
          ".octon/framework/capabilities/runtime/services/manifest.yml",
          ".octon/framework/capabilities/runtime/tools/manifest.yml",
          ".octon/instance/capabilities/runtime/commands/manifest.yml",
          ".octon/instance/capabilities/runtime/skills/manifest.yml",
          ".octon/generated/effective/locality/scopes.effective.yml",
          ".octon/generated/effective/locality/generation.lock.yml",
          ".octon/generated/effective/extensions/catalog.effective.yml",
          ".octon/generated/effective/extensions/generation.lock.yml"
        ],
        invalidation_conditions: [
          "root-manifest-sha-changed",
          "native-capability-manifest-changed",
          "locality-effective-sha-changed",
          "locality-lock-sha-changed",
          "extensions-effective-sha-changed",
          "extensions-lock-sha-changed"
        ],
        published_files: [
          {path: ".octon/generated/effective/capabilities/routing.effective.yml"},
          {path: ".octon/generated/effective/capabilities/artifact-map.yml"},
          {path: ".octon/generated/effective/capabilities/generation.lock.yml"}
        ]
      }
    ' | yq -P - >"$lock_tmp"

  published_at="$(maybe_reuse_published_at "$routing_tmp" "$artifact_tmp" "$lock_tmp" "$default_published_at")"
  receipt_slug="$(receipt_timestamp_slug "$published_at")"
  receipt_rel="$(capability_publication_receipt_rel "$receipt_slug" "$generation_id")"
  receipt_abs="$ROOT_DIR/$receipt_rel"
  receipt_id="capabilities-$receipt_slug-$generation_id"
  PUBLISHED_AT="$published_at"
  write_capability_publication_receipt "$receipt_tmp" "$receipt_id" "$generation_id" "$publication_status" "$root_sha" "$commands_sha" "$skills_sha" "$skills_registry_sha" "$services_sha" "$tools_sha" "$instance_commands_sha" "$instance_skills_sha" "$locality_scopes_sha" "$locality_lock_sha" "$locality_publication_status" "$extensions_sha" "$extensions_lock_sha" "$extensions_publication_status"
  receipt_sha="$(hash_file "$receipt_tmp")"
  perl -0pi -e 's/__PUBLISHED_AT__/'"$published_at"'/g; s#__PUBLICATION_RECEIPT_PATH__#'"$receipt_rel"'#g' "$routing_tmp" "$artifact_tmp" "$lock_tmp"
  perl -0pi -e 's/__PUBLICATION_RECEIPT_SHA256__/'"$receipt_sha"'/g' "$lock_tmp"

  mkdir -p "$(dirname "$receipt_abs")"
  mv "$receipt_tmp" "$receipt_abs"
  mv "$routing_tmp" "$ROUTING_FILE"
  mv "$artifact_tmp" "$ARTIFACT_MAP_FILE"
  mv "$lock_tmp" "$GENERATION_LOCK_FILE"

  echo "[OK] published capability routing: $generation_id"
}

main "$@"
