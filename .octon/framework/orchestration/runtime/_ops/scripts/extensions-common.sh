#!/usr/bin/env bash

extensions_common_init() {
  local caller_script="$1"
  EXT_COMMON_SCRIPT_DIR="$(cd -- "$(dirname -- "$caller_script")" && pwd)"
  if [[ -n "${OCTON_DIR_OVERRIDE:-}" ]]; then
    OCTON_DIR="$OCTON_DIR_OVERRIDE"
    ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
  else
    OCTON_DIR="$(cd -- "$EXT_COMMON_SCRIPT_DIR/../../../../../" && pwd)"
    ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
  fi

  ROOT_MANIFEST="$OCTON_DIR/octon.yml"
  EXTENSIONS_MANIFEST="$OCTON_DIR/instance/extensions.yml"
  ACTIVE_STATE="$OCTON_DIR/state/control/extensions/active.yml"
  QUARANTINE_STATE="$OCTON_DIR/state/control/extensions/quarantine.yml"
  EFFECTIVE_DIR="$OCTON_DIR/generated/effective/extensions"
  PUBLISHED_PROJECTIONS_DIR="$EFFECTIVE_DIR/published"
  CATALOG_FILE="$EFFECTIVE_DIR/catalog.effective.yml"
  ARTIFACT_MAP_FILE="$EFFECTIVE_DIR/artifact-map.yml"
  GENERATION_LOCK_FILE="$EFFECTIVE_DIR/generation.lock.yml"

  ext_reset_resolution_state
}

ext_reset_resolution_state() {
  declare -gA EXT_PUBLISHED_VERSION=()
  declare -gA EXT_PUBLISHED_ORIGIN_CLASS=()
  declare -gA EXT_PUBLISHED_MANIFEST_REL=()
  declare -gA EXT_PUBLISHED_TRUST_DECISION=()
  declare -gA EXT_PUBLISHED_ACKNOWLEDGEMENT_ID=()
  declare -gA EXT_PUBLISHED_SOURCE_ID=()
  declare -gA EXT_SELECTED_VERSION_PIN=()
  declare -gA EXT_QUARANTINE_REASON=()
  declare -gA EXT_QUARANTINE_AFFECTED=()
  declare -gA EXT_QUARANTINE_ACK=()
  declare -ga EXT_SELECTED_KEYS=()
  declare -ga EXT_PUBLISHED_KEYS=()
  declare -ga EXT_QUARANTINE_KEYS=()
  declare -gA EXT_COMPAT_RESULT_STATUS=()
  declare -gA EXT_COMPAT_PROFILE_REL=()
  declare -gA EXT_COMPAT_PROFILE_SHA=()
  declare -gA EXT_COMPAT_REQUIRED_INPUTS=()
  declare -gA EXT_COMPAT_MISSING_REQUIRED_FILES=()
  declare -gA EXT_COMPAT_MISSING_REQUIRED_DIRECTORIES=()
  declare -gA EXT_COMPAT_MISSING_REQUIRED_COMMANDS=()
  declare -gA EXT_COMPAT_MISSING_REQUIRED_BEHAVIORS=()
  declare -gA EXT_COMPAT_DEGRADED_FEATURES=()
  declare -gA EXT_COMPAT_BLOCKING_REASONS=()
  declare -g EXT_COMPAT_OVERALL_STATUS="compatible"
  declare -g EXT_LAST_ERROR_REASON=""
  declare -g EXT_LAST_ERROR_ACKNOWLEDGEMENT_ID=""
  declare -g EXT_VALIDATED_VERSION=""
  declare -g EXT_VALIDATED_ORIGIN_CLASS=""
  declare -g EXT_VALIDATED_MANIFEST_REL=""
  declare -g EXT_VALIDATED_TRUST_DECISION=""
  declare -g EXT_VALIDATED_ACKNOWLEDGEMENT_ID=""
  declare -g EXT_VALIDATED_COMPATIBILITY_STATUS=""
  declare -g EXT_VALIDATED_COMPATIBILITY_PROFILE_REL=""
  declare -g EXT_VALIDATED_COMPATIBILITY_PROFILE_SHA=""
  declare -g EXT_VALIDATED_COMPATIBILITY_REQUIRED_INPUTS=""
  declare -g EXT_VALIDATED_COMPATIBILITY_MISSING_REQUIRED_FILES=""
  declare -g EXT_VALIDATED_COMPATIBILITY_MISSING_REQUIRED_DIRECTORIES=""
  declare -g EXT_VALIDATED_COMPATIBILITY_MISSING_REQUIRED_COMMANDS=""
  declare -g EXT_VALIDATED_COMPATIBILITY_MISSING_REQUIRED_BEHAVIORS=""
  declare -g EXT_VALIDATED_COMPATIBILITY_DEGRADED_FEATURES=""
  declare -g EXT_VALIDATED_COMPATIBILITY_BLOCKING_REASONS=""
}

ext_hash_file() {
  local file="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
  else
    sha256sum "$file" | awk '{print $1}'
  fi
}

ext_hash_text() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 | awk '{print $1}'
  else
    sha256sum | awk '{print $1}'
  fi
}

ext_trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

ext_sorted_unique_lines() {
  printf '%s\n' "$@" | awk 'NF' | LC_ALL=C sort -u
}

ext_join_sorted_unique_lines() {
  ext_sorted_unique_lines "$@"
}

ext_pack_key() {
  printf '%s|%s' "$1" "$2"
}

ext_key_pack_id() {
  printf '%s' "${1%%|*}"
}

ext_key_source_id() {
  printf '%s' "${1#*|}"
}

ext_pack_manifest_abs() {
  printf '%s' "$OCTON_DIR/inputs/additive/extensions/$1/pack.yml"
}

ext_pack_manifest_rel() {
  printf '.octon/inputs/additive/extensions/%s/pack.yml' "$1"
}

ext_pack_root_rel() {
  printf '.octon/inputs/additive/extensions/%s' "$1"
}

ext_pack_root_abs() {
  printf '%s/inputs/additive/extensions/%s' "$OCTON_DIR" "$1"
}

ext_published_projection_root_rel() {
  printf '.octon/generated/effective/extensions/published/%s/%s' "$1" "$2"
}

ext_published_projection_root_abs() {
  printf '%s/generated/effective/extensions/published/%s/%s' "$OCTON_DIR" "$1" "$2"
}

ext_published_command_projection_rel() {
  printf '%s/commands/%s' "$(ext_published_projection_root_rel "$1" "$2")" "$3"
}

ext_published_skill_projection_rel() {
  printf '%s/skills/%s' "$(ext_published_projection_root_rel "$1" "$2")" "$3"
}

ext_published_prompt_projection_rel() {
  printf '%s/prompts/%s' "$(ext_published_projection_root_rel "$1" "$2")" "$3"
}

ext_bucket_for_relative_path() {
  case "$1" in
    pack.yml) printf 'manifest' ;;
    README.md) printf 'documentation' ;;
    skills/*) printf 'skills' ;;
    commands/*) printf 'commands' ;;
    templates/*) printf 'templates' ;;
    prompts/*) printf 'prompts' ;;
    context/*) printf 'context' ;;
    validation/*) printf 'validation' ;;
    *) printf 'unknown' ;;
  esac
}

ext_version_to_parts() {
  local version="$1"
  if [[ ! "$version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    return 1
  fi
  printf '%s %s %s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
}

ext_compare_versions() {
  local left="$1" right="$2"
  local lmaj lmin lpatch rmaj rmin rpatch
  read -r lmaj lmin lpatch < <(ext_version_to_parts "$left") || return 2
  read -r rmaj rmin rpatch < <(ext_version_to_parts "$right") || return 2
  if (( lmaj < rmaj )); then echo -1; return 0; fi
  if (( lmaj > rmaj )); then echo 1; return 0; fi
  if (( lmin < rmin )); then echo -1; return 0; fi
  if (( lmin > rmin )); then echo 1; return 0; fi
  if (( lpatch < rpatch )); then echo -1; return 0; fi
  if (( lpatch > rpatch )); then echo 1; return 0; fi
  echo 0
}

ext_version_satisfies() {
  local version="$1" range="$2"

  if [[ "$range" == "*" ]]; then
    return 0
  fi

  if [[ "$range" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    [[ "$version" == "$range" ]]
    return
  fi

  if [[ "$range" =~ ^\^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    local major="${BASH_REMATCH[1]}"
    local minor="${BASH_REMATCH[2]}"
    local patch="${BASH_REMATCH[3]}"
    local lower="${major}.${minor}.${patch}"
    local upper
    if (( major > 0 )); then
      upper="$((major + 1)).0.0"
    elif (( minor > 0 )); then
      upper="0.$((minor + 1)).0"
    else
      upper="0.0.$((patch + 1))"
    fi

    local lower_cmp upper_cmp
    lower_cmp="$(ext_compare_versions "$version" "$lower")" || return 1
    upper_cmp="$(ext_compare_versions "$version" "$upper")" || return 1
    [[ "$lower_cmp" != "-1" && "$upper_cmp" == "-1" ]]
    return
  fi

  return 1
}

ext_source_exists() {
  yq -e ".sources.catalog | has(\"$1\")" "$EXTENSIONS_MANIFEST" >/dev/null 2>&1
}

ext_source_root() {
  yq -r ".sources.catalog.\"$1\".root // \"\"" "$EXTENSIONS_MANIFEST"
}

ext_source_type() {
  yq -r ".sources.catalog.\"$1\".source_type // \"\"" "$EXTENSIONS_MANIFEST"
}

ext_source_allows_origin() {
  local source_id="$1" origin_class="$2"
  yq -r ".sources.catalog.\"$source_id\".allowed_origin_classes[]? // \"\"" "$EXTENSIONS_MANIFEST" 2>/dev/null \
    | grep -Fx "$origin_class" >/dev/null 2>&1
}

ext_contract_schema_path() {
  case "$1" in
    root-manifest) printf '%s' "$ROOT_MANIFEST" ;;
    framework-manifest) printf '%s' "$OCTON_DIR/framework/manifest.yml" ;;
    instance-manifest) printf '%s' "$OCTON_DIR/instance/manifest.yml" ;;
    instance-extensions) printf '%s' "$EXTENSIONS_MANIFEST" ;;
    extension-active-state) printf '%s' "$ACTIVE_STATE" ;;
    extension-quarantine-state) printf '%s' "$QUARANTINE_STATE" ;;
    extension-effective-catalog) printf '%s' "$CATALOG_FILE" ;;
    extension-artifact-map) printf '%s' "$ARTIFACT_MAP_FILE" ;;
    extension-generation-lock) printf '%s' "$GENERATION_LOCK_FILE" ;;
    *) return 1 ;;
  esac
}

ext_live_contract_schema_version() {
  local contract_id="$1" contract_path schema_version
  contract_path="$(ext_contract_schema_path "$contract_id" 2>/dev/null || true)"
  [[ -n "$contract_path" ]] || return 1
  [[ -f "$contract_path" ]] || return 1
  schema_version="$(yq -r '.schema_version // ""' "$contract_path" 2>/dev/null || true)"
  [[ -n "$schema_version" ]] || return 1
  printf '%s' "$schema_version"
}

ext_validate_required_contracts() {
  local manifest="$1" contract_id schema_version live_version
  declare -A seen_contract_ids=()

  yq -e '.compatibility.required_contracts | tag == "!!seq"' "$manifest" >/dev/null 2>&1 || {
    EXT_LAST_ERROR_REASON="missing-required-contracts"
    return 1
  }

  while IFS=$'\t' read -r contract_id schema_version; do
    [[ -n "$contract_id" ]] || continue
    if [[ -n "${seen_contract_ids["$contract_id"]:-}" ]]; then
      EXT_LAST_ERROR_REASON="duplicate-required-contract:$contract_id"
      return 1
    fi
    seen_contract_ids["$contract_id"]="1"
    live_version="$(ext_live_contract_schema_version "$contract_id" 2>/dev/null || true)"
    if [[ -z "$live_version" ]]; then
      EXT_LAST_ERROR_REASON="unsupported-required-contract:$contract_id"
      return 1
    fi
    if [[ "$schema_version" != "$live_version" ]]; then
      EXT_LAST_ERROR_REASON="required-contract-version-mismatch:$contract_id"
      return 1
    fi
  done < <(yq -r '.compatibility.required_contracts[]? | [.contract_id, .schema_version] | @tsv' "$manifest" 2>/dev/null || true)
}

ext_validate_provenance_contract() {
  local manifest="$1" origin_class="$2"
  local imported_from origin_uri digest_sha256

  yq -e '.provenance | tag == "!!map"' "$manifest" >/dev/null 2>&1 || {
    EXT_LAST_ERROR_REASON="missing-provenance"
    return 1
  }
  yq -e '.provenance | has("source_id")' "$manifest" >/dev/null 2>&1 || {
    EXT_LAST_ERROR_REASON="missing-provenance-source-id"
    return 1
  }
  yq -e '.provenance | has("imported_from")' "$manifest" >/dev/null 2>&1 || {
    EXT_LAST_ERROR_REASON="missing-imported-from"
    return 1
  }
  yq -e '.provenance | has("origin_uri")' "$manifest" >/dev/null 2>&1 || {
    EXT_LAST_ERROR_REASON="missing-origin-uri"
    return 1
  }
  yq -e '.provenance | has("digest_sha256")' "$manifest" >/dev/null 2>&1 || {
    EXT_LAST_ERROR_REASON="missing-digest-sha256"
    return 1
  }
  yq -e '.provenance | has("attestation_refs")' "$manifest" >/dev/null 2>&1 || {
    EXT_LAST_ERROR_REASON="missing-attestation-refs"
    return 1
  }
  yq -e '.provenance.attestation_refs | tag == "!!seq"' "$manifest" >/dev/null 2>&1 || {
    EXT_LAST_ERROR_REASON="invalid-attestation-refs"
    return 1
  }

  imported_from="$(yq -r '.provenance.imported_from // ""' "$manifest")"
  origin_uri="$(yq -r '.provenance.origin_uri // ""' "$manifest")"
  digest_sha256="$(yq -r '.provenance.digest_sha256 // ""' "$manifest")"

  if [[ -n "$digest_sha256" && ! "$digest_sha256" =~ ^[a-f0-9]{64}$ ]]; then
    EXT_LAST_ERROR_REASON="invalid-digest-sha256"
    return 1
  fi

  case "$origin_class" in
    first_party_bundled)
      return 0
      ;;
    first_party_external|third_party)
      if [[ -z "$imported_from" && -z "$origin_uri" && -z "$digest_sha256" ]]; then
        EXT_LAST_ERROR_REASON="external-provenance-required"
        return 1
      fi
      ;;
  esac
}

ext_manifest_source_id() {
  local manifest="$1"
  yq -r '.provenance.source_id // ""' "$manifest"
}

ext_default_trust_action() {
  yq -r ".trust.default_actions.\"$1\" // \"\"" "$EXTENSIONS_MANIFEST"
}

ext_source_override_action() {
  yq -r ".trust.source_overrides.\"$1\" // \"\"" "$EXTENSIONS_MANIFEST"
}

ext_pack_override_action() {
  yq -r ".trust.pack_overrides.\"$1\" // \"\"" "$EXTENSIONS_MANIFEST"
}

ext_acknowledgement_id_for_allow() {
  local pack_id="$1" source_id="$2"
  yq -r ".acknowledgements[]? | select(.pack_id == \"$pack_id\" and .source_id == \"$source_id\" and .action == \"allow\") | .acknowledgement_id" "$EXTENSIONS_MANIFEST" 2>/dev/null | head -n 1
}

ext_detect_pack_source_id() {
  local pack_id="$1"
  local manifest
  manifest="$(ext_pack_manifest_abs "$pack_id")"
  [[ -f "$manifest" ]] || return 1
  ext_manifest_source_id "$manifest"
}

ext_pack_has_allowed_top_level_shape() {
  local pack_root="$1"
  local entry name
  while IFS= read -r entry; do
    name="$(basename "$entry")"
    case "$name" in
      pack.yml|README.md|skills|commands|templates|prompts|context|validation)
        ;;
      *)
        EXT_LAST_ERROR_REASON="invalid-top-level-entry:$name"
        return 1
        ;;
    esac
  done < <(find "$pack_root" -mindepth 1 -maxdepth 1 ! -name '.DS_Store' -print | sort)
}

ext_validate_content_entrypoints() {
  local pack_id="$1" manifest="$2" pack_root="$3"
  local bucket rel dir_path
  for bucket in skills commands templates prompts context; do
    rel="$(yq -r ".content_entrypoints.$bucket // \"\"" "$manifest")"
    if [[ -z "$rel" || "$rel" == "null" ]]; then
      [[ ! -d "$pack_root/$bucket" ]] || {
        EXT_LAST_ERROR_REASON="unexpected-content-dir:$bucket"
        return 1
      }
      continue
    fi
    [[ "$rel" == "$bucket/" ]] || {
      EXT_LAST_ERROR_REASON="invalid-entrypoint:$bucket"
      return 1
    }
    dir_path="$pack_root/${rel%/}"
    [[ -d "$dir_path" ]] || {
      EXT_LAST_ERROR_REASON="missing-content-root:$bucket"
      return 1
    }
  done

  rel="$(yq -r '.content_entrypoints.validation // ""' "$manifest")"
  [[ -n "$rel" && "$rel" != "null" ]] || {
    EXT_LAST_ERROR_REASON="missing-content-root:validation"
    return 1
  }
  [[ "$rel" == "validation/" ]] || {
    EXT_LAST_ERROR_REASON="invalid-entrypoint:validation"
    return 1
  }
  dir_path="$pack_root/${rel%/}"
  [[ -d "$dir_path" ]] || {
    EXT_LAST_ERROR_REASON="missing-content-root:validation"
    return 1
  }
}

ext_validate_repo_relative_path_value() {
  local value="$1" label="$2"
  [[ -n "$value" ]] || {
    EXT_LAST_ERROR_REASON="empty-$label"
    return 1
  }
  [[ "$value" != /* ]] || {
    EXT_LAST_ERROR_REASON="absolute-$label:$value"
    return 1
  }
  [[ "$value" != *"../"* && "$value" != ../* && "$value" != *"/.." && "$value" != ".." ]] || {
    EXT_LAST_ERROR_REASON="invalid-$label:$value"
    return 1
  }
}

ext_validate_compatibility_behavior_map() {
  local profile_file="$1" query="$2" label="$3"
  yq -e "$query | tag == \"!!map\"" "$profile_file" >/dev/null 2>&1 || {
    EXT_LAST_ERROR_REASON="invalid-$label"
    return 1
  }

  local key value
  while IFS= read -r key; do
    [[ -n "$key" ]] || continue
    case "$key" in
      fail_closed_publication|compiled_runtime_consumption_only|host_generated_receipts)
        ;;
      *)
        EXT_LAST_ERROR_REASON="unsupported-$label:$key"
        return 1
        ;;
    esac
    value="$(yq -r "$query.$key" "$profile_file" 2>/dev/null || true)"
    case "$value" in
      true|false)
        ;;
      *)
        EXT_LAST_ERROR_REASON="invalid-$label:$key"
        return 1
        ;;
    esac
  done < <(yq -r "$query | keys[]? // \"\"" "$profile_file" 2>/dev/null || true)
}

ext_validate_compatibility_profile_contract() {
  local manifest="$1" pack_root="$2"
  local profile_rel profile_abs version feature_id
  declare -A seen_feature_ids=()

  profile_rel="$(yq -r '.compatibility.profile_path // ""' "$manifest" 2>/dev/null || true)"
  [[ "$profile_rel" == "validation/compatibility.yml" ]] || {
    EXT_LAST_ERROR_REASON="invalid-compatibility-profile-path"
    return 1
  }

  profile_abs="$pack_root/$profile_rel"
  [[ -f "$profile_abs" ]] || {
    EXT_LAST_ERROR_REASON="missing-compatibility-profile"
    return 1
  }
  yq -e '.' "$profile_abs" >/dev/null 2>&1 || {
    EXT_LAST_ERROR_REASON="invalid-compatibility-profile-yaml"
    return 1
  }
  [[ "$(yq -r '.schema_version // ""' "$profile_abs")" == "octon-extension-compatibility-profile-v1" ]] || {
    EXT_LAST_ERROR_REASON="invalid-compatibility-profile-schema-version"
    return 1
  }
  version="$(yq -r '.version // ""' "$profile_abs")"
  [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
    EXT_LAST_ERROR_REASON="invalid-compatibility-profile-version"
    return 1
  }

  yq -e '.compatibility | tag == "!!map"' "$profile_abs" >/dev/null 2>&1 || {
    EXT_LAST_ERROR_REASON="missing-compatibility-root"
    return 1
  }

  local query value
  for query in '.compatibility.required_files' '.compatibility.required_directories'; do
    yq -e "$query | tag == \"!!seq\"" "$profile_abs" >/dev/null 2>&1 || {
      EXT_LAST_ERROR_REASON="invalid-compatibility-array:${query#.compatibility.}"
      return 1
    }
    while IFS= read -r value; do
      [[ -n "$value" ]] || continue
      ext_validate_repo_relative_path_value "$value" "compatibility-path" || return 1
    done < <(yq -r "$query[]? // \"\"" "$profile_abs" 2>/dev/null || true)
  done

  yq -e '.compatibility.required_commands | tag == "!!seq"' "$profile_abs" >/dev/null 2>&1 || {
    EXT_LAST_ERROR_REASON="invalid-compatibility-array:required_commands"
    return 1
  }
  while IFS= read -r value; do
    [[ -n "$value" ]] || continue
  done < <(yq -r '.compatibility.required_commands[]? // ""' "$profile_abs" 2>/dev/null || true)

  ext_validate_compatibility_behavior_map "$profile_abs" '.compatibility.minimum_behavior' 'compatibility-minimum-behavior' || return 1

  yq -e '.compatibility.optional_features | tag == "!!seq"' "$profile_abs" >/dev/null 2>&1 || {
    EXT_LAST_ERROR_REASON="invalid-compatibility-array:optional_features"
    return 1
  }
  while IFS= read -r feature_id; do
    [[ -n "$feature_id" ]] || continue
    if [[ -n "${seen_feature_ids["$feature_id"]:-}" ]]; then
      EXT_LAST_ERROR_REASON="duplicate-optional-feature:$feature_id"
      return 1
    fi
    seen_feature_ids["$feature_id"]="1"
    [[ "$feature_id" =~ ^[a-z][a-z0-9-]*$ ]] || {
      EXT_LAST_ERROR_REASON="invalid-optional-feature-id:$feature_id"
      return 1
    }
  done < <(yq -r '.compatibility.optional_features[]?.feature_id // ""' "$profile_abs" 2>/dev/null || true)

  local index description
  index=0
  while yq -e ".compatibility.optional_features[$index]" "$profile_abs" >/dev/null 2>&1; do
    description="$(yq -r ".compatibility.optional_features[$index].description // \"\"" "$profile_abs" 2>/dev/null || true)"
    [[ -n "$description" ]] || {
      EXT_LAST_ERROR_REASON="missing-optional-feature-description:$index"
      return 1
    }
    for query in ".compatibility.optional_features[$index].required_files" ".compatibility.optional_features[$index].required_directories"; do
      yq -e "$query | tag == \"!!seq\"" "$profile_abs" >/dev/null 2>&1 || {
        EXT_LAST_ERROR_REASON="invalid-optional-feature-array:$index"
        return 1
      }
      while IFS= read -r value; do
        [[ -n "$value" ]] || continue
        ext_validate_repo_relative_path_value "$value" "optional-feature-path" || return 1
      done < <(yq -r "$query[]? // \"\"" "$profile_abs" 2>/dev/null || true)
    done
    yq -e ".compatibility.optional_features[$index].required_commands | tag == \"!!seq\"" "$profile_abs" >/dev/null 2>&1 || {
      EXT_LAST_ERROR_REASON="invalid-optional-feature-array:$index"
      return 1
    }
    ext_validate_compatibility_behavior_map "$profile_abs" ".compatibility.optional_features[$index].minimum_behavior" "optional-feature-minimum-behavior" || return 1
    index=$((index + 1))
  done
}

ext_validate_prompt_set_manifest_if_present() {
  local manifest="$1" pack_root="$2"
  local prompts_root_rel prompts_root prompt_manifest prompt_set_id schema_version prompt_dir
  local stage_count companion_count
  declare -A seen_prompt_set_ids=()

  prompts_root_rel="$(yq -r '.content_entrypoints.prompts // ""' "$manifest")"
  if [[ -z "$prompts_root_rel" || "$prompts_root_rel" == "null" ]]; then
    return 0
  fi

  prompts_root="$pack_root/${prompts_root_rel%/}"
  [[ -d "$prompts_root" ]] || return 0

  while IFS= read -r prompt_manifest; do
    [[ -n "$prompt_manifest" ]] || continue
    prompt_dir="$(dirname "$prompt_manifest")"

    yq -e '.' "$prompt_manifest" >/dev/null 2>&1 || {
      EXT_LAST_ERROR_REASON="invalid-prompt-set-manifest-yaml:$(basename "$(dirname "$prompt_manifest")")"
      return 1
    }

    schema_version="$(yq -r '.schema_version // ""' "$prompt_manifest")"
    [[ "$schema_version" == "octon-extension-prompt-set-v1" ]] || {
      EXT_LAST_ERROR_REASON="invalid-prompt-set-schema-version:$(basename "$(dirname "$prompt_manifest")")"
      return 1
    }

    [[ -f "$prompt_dir/README.md" ]] || {
      EXT_LAST_ERROR_REASON="missing-prompt-set-readme:$(basename "$prompt_dir")"
      return 1
    }

    [[ "$(dirname "$prompt_dir")" == "$prompts_root" ]] || {
      EXT_LAST_ERROR_REASON="invalid-prompt-set-layout:$(basename "$prompt_dir")"
      return 1
    }

    prompt_set_id="$(yq -r '.prompt_set_id // ""' "$prompt_manifest")"
    [[ "$prompt_set_id" =~ ^[a-z][a-z0-9-]*$ ]] || {
      EXT_LAST_ERROR_REASON="invalid-prompt-set-id:$(basename "$(dirname "$prompt_manifest")")"
      return 1
    }
    if [[ -n "${seen_prompt_set_ids["$prompt_set_id"]:-}" ]]; then
      EXT_LAST_ERROR_REASON="duplicate-prompt-set-id:$prompt_set_id"
      return 1
    fi
    seen_prompt_set_ids["$prompt_set_id"]="1"

    yq -e '.version | type == "!!str"' "$prompt_manifest" >/dev/null 2>&1 || {
      EXT_LAST_ERROR_REASON="missing-prompt-set-version:$prompt_set_id"
      return 1
    }

    yq -e '.stages | type == "!!seq"' "$prompt_manifest" >/dev/null 2>&1 || {
      EXT_LAST_ERROR_REASON="missing-prompt-set-stages:$prompt_set_id"
      return 1
    }
    stage_count="$(yq -r '.stages | length' "$prompt_manifest" 2>/dev/null || echo 0)"
    [[ "$stage_count" -gt 0 ]] || {
      EXT_LAST_ERROR_REASON="empty-prompt-set-stages:$prompt_set_id"
      return 1
    }

    yq -e '.companions | type == "!!seq"' "$prompt_manifest" >/dev/null 2>&1 || {
      EXT_LAST_ERROR_REASON="missing-prompt-set-companions:$prompt_set_id"
      return 1
    }
    companion_count="$(yq -r '.companions | length' "$prompt_manifest" 2>/dev/null || echo 0)"
    [[ "$companion_count" -gt 0 ]] || {
      EXT_LAST_ERROR_REASON="empty-prompt-set-companions:$prompt_set_id"
      return 1
    }

    yq -e '.required_repo_anchors | type == "!!seq"' "$prompt_manifest" >/dev/null 2>&1 || {
      EXT_LAST_ERROR_REASON="missing-prompt-set-anchors:$prompt_set_id"
      return 1
    }
    [[ "$(yq -r '.required_repo_anchors | length' "$prompt_manifest" 2>/dev/null || echo 0)" -gt 0 ]] || {
      EXT_LAST_ERROR_REASON="empty-prompt-set-anchors:$prompt_set_id"
      return 1
    }

    yq -e '.alignment_policy | type == "!!map"' "$prompt_manifest" >/dev/null 2>&1 || {
      EXT_LAST_ERROR_REASON="missing-prompt-set-alignment-policy:$prompt_set_id"
      return 1
    }
    yq -e '.alignment_policy.default_mode | type == "!!str"' "$prompt_manifest" >/dev/null 2>&1 || {
      EXT_LAST_ERROR_REASON="missing-prompt-set-default-mode:$prompt_set_id"
      return 1
    }
    yq -e '.alignment_policy.skip_mode_policy | type == "!!str"' "$prompt_manifest" >/dev/null 2>&1 || {
      EXT_LAST_ERROR_REASON="missing-prompt-set-skip-policy:$prompt_set_id"
      return 1
    }
    yq -e '.alignment_policy.receipt_root | type == "!!str"' "$prompt_manifest" >/dev/null 2>&1 || {
      EXT_LAST_ERROR_REASON="missing-prompt-set-receipt-root:$prompt_set_id"
      return 1
    }

    yq -e '.invalidation_conditions | type == "!!seq"' "$prompt_manifest" >/dev/null 2>&1 || {
      EXT_LAST_ERROR_REASON="missing-prompt-set-invalidation:$prompt_set_id"
      return 1
    }
    [[ "$(yq -r '.invalidation_conditions | length' "$prompt_manifest" 2>/dev/null || echo 0)" -gt 0 ]] || {
      EXT_LAST_ERROR_REASON="empty-prompt-set-invalidation:$prompt_set_id"
      return 1
    }

    yq -e '.artifact_policy.internal_artifacts | type == "!!seq"' "$prompt_manifest" >/dev/null 2>&1 || {
      EXT_LAST_ERROR_REASON="missing-prompt-set-internal-artifacts:$prompt_set_id"
      return 1
    }
    yq -e '.artifact_policy.packet_support_files | type == "!!seq"' "$prompt_manifest" >/dev/null 2>&1 || {
      EXT_LAST_ERROR_REASON="missing-prompt-set-packet-support:$prompt_set_id"
      return 1
    }
    yq -e '.references | type == "!!seq"' "$prompt_manifest" >/dev/null 2>&1 || {
      EXT_LAST_ERROR_REASON="missing-prompt-set-references:$prompt_set_id"
      return 1
    }
    yq -e '.shared_references | type == "!!seq"' "$prompt_manifest" >/dev/null 2>&1 || {
      EXT_LAST_ERROR_REASON="missing-prompt-set-shared-references:$prompt_set_id"
      return 1
    }

    while IFS=$'\t' read -r rel_path role_class; do
      [[ -n "$rel_path" ]] || continue
      [[ -f "$(dirname "$prompt_manifest")/$rel_path" ]] || {
        EXT_LAST_ERROR_REASON="missing-prompt-set-file:$prompt_set_id:$rel_path"
        return 1
      }
      case "$role_class" in
        stage|maintenance-companion|prompt-generation-companion)
          ;;
        *)
          EXT_LAST_ERROR_REASON="invalid-prompt-role-class:$prompt_set_id:$role_class"
          return 1
          ;;
      esac
    done < <(
      {
        yq -r '.stages[]? | [.path, .role_class] | @tsv' "$prompt_manifest" 2>/dev/null || true
        yq -r '.companions[]? | [.path, .role_class] | @tsv' "$prompt_manifest" 2>/dev/null || true
      }
    )

    while IFS= read -r anchor_path; do
      [[ -n "$anchor_path" ]] || continue
      [[ -e "$ROOT_DIR/$anchor_path" ]] || {
        EXT_LAST_ERROR_REASON="missing-prompt-set-anchor:$prompt_set_id:$anchor_path"
        return 1
      }
    done < <(yq -r '.required_repo_anchors[]? // ""' "$prompt_manifest" 2>/dev/null || true)

    while IFS= read -r rel_path; do
      [[ -n "$rel_path" ]] || continue
      [[ -f "$prompt_dir/$rel_path" ]] || {
        EXT_LAST_ERROR_REASON="missing-prompt-set-reference:$prompt_set_id:$rel_path"
        return 1
      }
    done < <(yq -r '.references[]?.path // ""' "$prompt_manifest" 2>/dev/null || true)

    while IFS= read -r rel_path; do
      [[ -n "$rel_path" ]] || continue
      [[ -f "$prompts_root/$rel_path" ]] || {
        EXT_LAST_ERROR_REASON="missing-prompt-set-shared-reference:$prompt_set_id:$rel_path"
        return 1
      }
    done < <(yq -r '.shared_references[]?.path // ""' "$prompt_manifest" 2>/dev/null || true)
  done < <(ext_prompt_bundle_manifest_files_for_pack "$manifest" "$pack_root")
}

ext_prompt_bundle_manifest_files_for_pack() {
  local manifest="$1" pack_root="$2"
  local prompts_root_rel prompts_root

  prompts_root_rel="$(yq -r '.content_entrypoints.prompts // ""' "$manifest" 2>/dev/null || true)"
  if [[ -z "$prompts_root_rel" || "$prompts_root_rel" == "null" ]]; then
    return 0
  fi

  prompts_root="$pack_root/${prompts_root_rel%/}"
  [[ -d "$prompts_root" ]] || return 0
  find "$prompts_root" -name manifest.yml -type f | sort
}

ext_routing_contract_abs_for_pack() {
  local manifest="$1" pack_root="$2"
  local context_root_rel contract_abs

  context_root_rel="$(yq -r '.content_entrypoints.context // ""' "$manifest" 2>/dev/null || true)"
  if [[ -z "$context_root_rel" || "$context_root_rel" == "null" ]]; then
    return 1
  fi

  contract_abs="$pack_root/${context_root_rel%/}/routing.contract.yml"
  [[ -f "$contract_abs" ]] || return 1
  printf '%s\n' "$contract_abs"
}

ext_routing_contract_rel_for_pack() {
  local pack_id="$1" manifest="$2" pack_root="$3"
  local context_root_rel contract_abs

  contract_abs="$(ext_routing_contract_abs_for_pack "$manifest" "$pack_root" 2>/dev/null || true)"
  [[ -n "$contract_abs" ]] || return 1
  context_root_rel="$(yq -r '.content_entrypoints.context // ""' "$manifest" 2>/dev/null || true)"
  printf '.octon/inputs/additive/extensions/%s/%s/routing.contract.yml\n' "$pack_id" "${context_root_rel%/}"
}

ext_validate_routing_contract_if_present() {
  local pack_id="$1" manifest="$2" pack_root="$3"
  local contract_abs dispatcher_count dispatcher_id default_route_id route_count
  local accepted_input input_name kind allowed_value matcher_id route_id status execution_binding_id binding_id binding_route_id predicate
  declare -A seen_dispatchers=()

  contract_abs="$(ext_routing_contract_abs_for_pack "$manifest" "$pack_root" 2>/dev/null || true)"
  [[ -n "$contract_abs" ]] || return 0

  yq -e '.' "$contract_abs" >/dev/null 2>&1 || {
    EXT_LAST_ERROR_REASON="invalid-routing-contract-yaml"
    return 1
  }

  [[ "$(yq -r '.schema_version // ""' "$contract_abs" 2>/dev/null || true)" == "octon-extension-routing-contract-v1" ]] || {
    EXT_LAST_ERROR_REASON="invalid-routing-contract-schema-version"
    return 1
  }

  yq -e '.dispatchers | tag == "!!seq"' "$contract_abs" >/dev/null 2>&1 || {
    EXT_LAST_ERROR_REASON="missing-routing-dispatchers"
    return 1
  }

  dispatcher_count="$(yq -r '.dispatchers | length' "$contract_abs" 2>/dev/null || echo 0)"
  [[ "$dispatcher_count" -gt 0 ]] || {
    EXT_LAST_ERROR_REASON="empty-routing-dispatchers"
    return 1
  }

  local dispatcher_index
  for ((dispatcher_index=0; dispatcher_index<dispatcher_count; dispatcher_index++)); do
    dispatcher_id="$(yq -r ".dispatchers[$dispatcher_index].dispatcher_id // \"\"" "$contract_abs" 2>/dev/null || true)"
    [[ "$dispatcher_id" =~ ^[a-z][a-z0-9-]*$ ]] || {
      EXT_LAST_ERROR_REASON="invalid-routing-dispatcher-id:$dispatcher_index"
      return 1
    }
    if [[ -n "${seen_dispatchers["$dispatcher_id"]:-}" ]]; then
      EXT_LAST_ERROR_REASON="duplicate-routing-dispatcher-id:$dispatcher_id"
      return 1
    fi
    seen_dispatchers["$dispatcher_id"]="1"

    default_route_id="$(yq -r ".dispatchers[$dispatcher_index].default_route_id // \"\"" "$contract_abs" 2>/dev/null || true)"
    [[ "$default_route_id" =~ ^[a-z][a-z0-9-]*$ ]] || {
      EXT_LAST_ERROR_REASON="invalid-routing-default-route:$dispatcher_id"
      return 1
    }

    yq -e ".dispatchers[$dispatcher_index].accepted_inputs | tag == \"!!seq\"" "$contract_abs" >/dev/null 2>&1 || {
      EXT_LAST_ERROR_REASON="missing-routing-accepted-inputs:$dispatcher_id"
      return 1
    }
    declare -A seen_inputs=()
    while IFS= read -r accepted_input; do
      [[ -n "$accepted_input" ]] || continue
      [[ "$accepted_input" =~ ^[a-z][a-z0-9_]*$ ]] || {
        EXT_LAST_ERROR_REASON="invalid-routing-input-name:$dispatcher_id:$accepted_input"
        return 1
      }
      if [[ -n "${seen_inputs["$accepted_input"]:-}" ]]; then
        EXT_LAST_ERROR_REASON="duplicate-routing-input-name:$dispatcher_id:$accepted_input"
        return 1
      fi
      seen_inputs["$accepted_input"]="1"
    done < <(yq -r ".dispatchers[$dispatcher_index].accepted_inputs[]? // \"\"" "$contract_abs" 2>/dev/null || true)

    yq -e ".dispatchers[$dispatcher_index].disambiguators | tag == \"!!seq\"" "$contract_abs" >/dev/null 2>&1 || {
      EXT_LAST_ERROR_REASON="missing-routing-disambiguators:$dispatcher_id"
      return 1
    }
    local disambiguator_index
    disambiguator_index=0
    while yq -e ".dispatchers[$dispatcher_index].disambiguators[$disambiguator_index]" "$contract_abs" >/dev/null 2>&1; do
      input_name="$(yq -r ".dispatchers[$dispatcher_index].disambiguators[$disambiguator_index].input_name // \"\"" "$contract_abs" 2>/dev/null || true)"
      kind="$(yq -r ".dispatchers[$dispatcher_index].disambiguators[$disambiguator_index].kind // \"\"" "$contract_abs" 2>/dev/null || true)"
      [[ -n "${seen_inputs["$input_name"]:-}" ]] || {
        EXT_LAST_ERROR_REASON="routing-disambiguator-unknown-input:$dispatcher_id:$input_name"
        return 1
      }
      case "$kind" in
        enum|route-id)
          ;;
        *)
          EXT_LAST_ERROR_REASON="invalid-routing-disambiguator-kind:$dispatcher_id:$kind"
          return 1
          ;;
      esac
      yq -e ".dispatchers[$dispatcher_index].disambiguators[$disambiguator_index].allowed_values | tag == \"!!seq\"" "$contract_abs" >/dev/null 2>&1 || {
        EXT_LAST_ERROR_REASON="missing-routing-disambiguator-values:$dispatcher_id:$input_name"
        return 1
      }
      [[ "$(yq -r ".dispatchers[$dispatcher_index].disambiguators[$disambiguator_index].allowed_values | length" "$contract_abs" 2>/dev/null || echo 0)" -gt 0 ]] || {
        EXT_LAST_ERROR_REASON="empty-routing-disambiguator-values:$dispatcher_id:$input_name"
        return 1
      }
      while IFS= read -r allowed_value; do
        [[ -n "$allowed_value" ]] || continue
        if [[ "$kind" == "route-id" && ! "$allowed_value" =~ ^[a-z][a-z0-9-]*$ ]]; then
          EXT_LAST_ERROR_REASON="invalid-routing-route-id-value:$dispatcher_id:$allowed_value"
          return 1
        fi
      done < <(yq -r ".dispatchers[$dispatcher_index].disambiguators[$disambiguator_index].allowed_values[]? // \"\"" "$contract_abs" 2>/dev/null || true)
      disambiguator_index=$((disambiguator_index + 1))
    done

    yq -e ".dispatchers[$dispatcher_index].precedence | tag == \"!!seq\"" "$contract_abs" >/dev/null 2>&1 || {
      EXT_LAST_ERROR_REASON="missing-routing-precedence:$dispatcher_id"
      return 1
    }
    [[ "$(yq -r ".dispatchers[$dispatcher_index].precedence | length" "$contract_abs" 2>/dev/null || echo 0)" -gt 0 ]] || {
      EXT_LAST_ERROR_REASON="empty-routing-precedence:$dispatcher_id"
      return 1
    }

    yq -e ".dispatchers[$dispatcher_index].routes | tag == \"!!seq\"" "$contract_abs" >/dev/null 2>&1 || {
      EXT_LAST_ERROR_REASON="missing-routing-routes:$dispatcher_id"
      return 1
    }
    route_count="$(yq -r ".dispatchers[$dispatcher_index].routes | length" "$contract_abs" 2>/dev/null || echo 0)"
    [[ "$route_count" -gt 0 ]] || {
      EXT_LAST_ERROR_REASON="empty-routing-routes:$dispatcher_id"
      return 1
    }

    declare -A seen_routes=()
    declare -A route_status_by_id=()
    declare -A seen_matchers=()
    declare -A matcher_route_by_id=()
    declare -A binding_route_by_id=()

    local route_index matcher_index condition_index
    for ((route_index=0; route_index<route_count; route_index++)); do
      route_id="$(yq -r ".dispatchers[$dispatcher_index].routes[$route_index].route_id // \"\"" "$contract_abs" 2>/dev/null || true)"
      status="$(yq -r ".dispatchers[$dispatcher_index].routes[$route_index].status // \"\"" "$contract_abs" 2>/dev/null || true)"
      execution_binding_id="$(yq -r ".dispatchers[$dispatcher_index].routes[$route_index].execution_binding_id // \"\"" "$contract_abs" 2>/dev/null || true)"

      [[ "$route_id" =~ ^[a-z][a-z0-9-]*$ ]] || {
        EXT_LAST_ERROR_REASON="invalid-routing-route-id:$dispatcher_id:$route_index"
        return 1
      }
      if [[ -n "${seen_routes["$route_id"]:-}" ]]; then
        EXT_LAST_ERROR_REASON="duplicate-routing-route-id:$dispatcher_id:$route_id"
        return 1
      fi
      seen_routes["$route_id"]="1"
      route_status_by_id["$route_id"]="$status"

      case "$status" in
        resolved|escalate|deny|blocked)
          ;;
        *)
          EXT_LAST_ERROR_REASON="invalid-routing-route-status:$dispatcher_id:$route_id"
          return 1
          ;;
      esac

      if [[ "$status" == "resolved" ]]; then
        [[ "$execution_binding_id" =~ ^[a-z][a-z0-9-]*$ ]] || {
          EXT_LAST_ERROR_REASON="missing-routing-execution-binding:$dispatcher_id:$route_id"
          return 1
        }
      elif [[ -n "$execution_binding_id" ]]; then
        EXT_LAST_ERROR_REASON="unexpected-routing-execution-binding:$dispatcher_id:$route_id"
        return 1
      fi

      yq -e ".dispatchers[$dispatcher_index].routes[$route_index].matchers | tag == \"!!seq\"" "$contract_abs" >/dev/null 2>&1 || {
        EXT_LAST_ERROR_REASON="missing-routing-matchers:$dispatcher_id:$route_id"
        return 1
      }
      [[ "$(yq -r ".dispatchers[$dispatcher_index].routes[$route_index].matchers | length" "$contract_abs" 2>/dev/null || echo 0)" -gt 0 ]] || {
        EXT_LAST_ERROR_REASON="empty-routing-matchers:$dispatcher_id:$route_id"
        return 1
      }

      matcher_index=0
      while yq -e ".dispatchers[$dispatcher_index].routes[$route_index].matchers[$matcher_index]" "$contract_abs" >/dev/null 2>&1; do
        matcher_id="$(yq -r ".dispatchers[$dispatcher_index].routes[$route_index].matchers[$matcher_index].matcher_id // \"\"" "$contract_abs" 2>/dev/null || true)"
        [[ "$matcher_id" =~ ^[a-z][a-z0-9-]*$ ]] || {
          EXT_LAST_ERROR_REASON="invalid-routing-matcher-id:$dispatcher_id:$route_id:$matcher_index"
          return 1
        }
        if [[ -n "${seen_matchers["$matcher_id"]:-}" ]]; then
          EXT_LAST_ERROR_REASON="duplicate-routing-matcher-id:$dispatcher_id:$matcher_id"
          return 1
        fi
        seen_matchers["$matcher_id"]="1"
        matcher_route_by_id["$matcher_id"]="$route_id"

        yq -e ".dispatchers[$dispatcher_index].routes[$route_index].matchers[$matcher_index].reason_codes | tag == \"!!seq\"" "$contract_abs" >/dev/null 2>&1 || {
          EXT_LAST_ERROR_REASON="missing-routing-reason-codes:$dispatcher_id:$matcher_id"
          return 1
        }
        [[ "$(yq -r ".dispatchers[$dispatcher_index].routes[$route_index].matchers[$matcher_index].reason_codes | length" "$contract_abs" 2>/dev/null || echo 0)" -gt 0 ]] || {
          EXT_LAST_ERROR_REASON="empty-routing-reason-codes:$dispatcher_id:$matcher_id"
          return 1
        }

        yq -e ".dispatchers[$dispatcher_index].routes[$route_index].matchers[$matcher_index].all_of | tag == \"!!seq\"" "$contract_abs" >/dev/null 2>&1 || {
          EXT_LAST_ERROR_REASON="missing-routing-matcher-conditions:$dispatcher_id:$matcher_id"
          return 1
        }
        [[ "$(yq -r ".dispatchers[$dispatcher_index].routes[$route_index].matchers[$matcher_index].all_of | length" "$contract_abs" 2>/dev/null || echo 0)" -gt 0 ]] || {
          EXT_LAST_ERROR_REASON="empty-routing-matcher-conditions:$dispatcher_id:$matcher_id"
          return 1
        }

        condition_index=0
        while yq -e ".dispatchers[$dispatcher_index].routes[$route_index].matchers[$matcher_index].all_of[$condition_index]" "$contract_abs" >/dev/null 2>&1; do
          input_name="$(yq -r ".dispatchers[$dispatcher_index].routes[$route_index].matchers[$matcher_index].all_of[$condition_index].input_name // \"\"" "$contract_abs" 2>/dev/null || true)"
          predicate="$(yq -r ".dispatchers[$dispatcher_index].routes[$route_index].matchers[$matcher_index].all_of[$condition_index].predicate // \"\"" "$contract_abs" 2>/dev/null || true)"
          [[ -n "${seen_inputs["$input_name"]:-}" ]] || {
            EXT_LAST_ERROR_REASON="routing-matcher-unknown-input:$dispatcher_id:$matcher_id:$input_name"
            return 1
          }
          case "$predicate" in
            present|absent)
              ;;
            equals)
              yq -e ".dispatchers[$dispatcher_index].routes[$route_index].matchers[$matcher_index].all_of[$condition_index] | has(\"value\")" "$contract_abs" >/dev/null 2>&1 || {
                EXT_LAST_ERROR_REASON="missing-routing-condition-value:$dispatcher_id:$matcher_id"
                return 1
              }
              ;;
            one_of|not_one_of)
              yq -e ".dispatchers[$dispatcher_index].routes[$route_index].matchers[$matcher_index].all_of[$condition_index].values | tag == \"!!seq\"" "$contract_abs" >/dev/null 2>&1 || {
                EXT_LAST_ERROR_REASON="missing-routing-condition-values:$dispatcher_id:$matcher_id"
                return 1
              }
              [[ "$(yq -r ".dispatchers[$dispatcher_index].routes[$route_index].matchers[$matcher_index].all_of[$condition_index].values | length" "$contract_abs" 2>/dev/null || echo 0)" -gt 0 ]] || {
                EXT_LAST_ERROR_REASON="empty-routing-condition-values:$dispatcher_id:$matcher_id"
                return 1
              }
              ;;
            *)
              EXT_LAST_ERROR_REASON="invalid-routing-predicate:$dispatcher_id:$matcher_id:$predicate"
              return 1
              ;;
          esac
          condition_index=$((condition_index + 1))
        done

        matcher_index=$((matcher_index + 1))
      done
    done

    yq -e ".dispatchers[$dispatcher_index].execution_bindings | tag == \"!!seq\"" "$contract_abs" >/dev/null 2>&1 || {
      EXT_LAST_ERROR_REASON="missing-routing-execution-bindings:$dispatcher_id"
      return 1
    }
    local binding_index
    binding_index=0
    declare -A seen_bindings=()
    while yq -e ".dispatchers[$dispatcher_index].execution_bindings[$binding_index]" "$contract_abs" >/dev/null 2>&1; do
      binding_id="$(yq -r ".dispatchers[$dispatcher_index].execution_bindings[$binding_index].binding_id // \"\"" "$contract_abs" 2>/dev/null || true)"
      binding_route_id="$(yq -r ".dispatchers[$dispatcher_index].execution_bindings[$binding_index].route_id // \"\"" "$contract_abs" 2>/dev/null || true)"
      [[ "$binding_id" =~ ^[a-z][a-z0-9-]*$ ]] || {
        EXT_LAST_ERROR_REASON="invalid-routing-binding-id:$dispatcher_id:$binding_index"
        return 1
      }
      if [[ -n "${seen_bindings["$binding_id"]:-}" ]]; then
        EXT_LAST_ERROR_REASON="duplicate-routing-binding-id:$dispatcher_id:$binding_id"
        return 1
      fi
      seen_bindings["$binding_id"]="1"
      [[ -n "${seen_routes["$binding_route_id"]:-}" ]] || {
        EXT_LAST_ERROR_REASON="routing-binding-unknown-route:$dispatcher_id:$binding_id"
        return 1
      }
      [[ "${route_status_by_id["$binding_route_id"]}" == "resolved" ]] || {
        EXT_LAST_ERROR_REASON="routing-binding-nonresolved-route:$dispatcher_id:$binding_id"
        return 1
      }
      local command_capability_id skill_capability_id prompt_set_id
      command_capability_id="$(yq -r ".dispatchers[$dispatcher_index].execution_bindings[$binding_index].command_capability_id // \"\"" "$contract_abs" 2>/dev/null || true)"
      skill_capability_id="$(yq -r ".dispatchers[$dispatcher_index].execution_bindings[$binding_index].skill_capability_id // \"\"" "$contract_abs" 2>/dev/null || true)"
      prompt_set_id="$(yq -r ".dispatchers[$dispatcher_index].execution_bindings[$binding_index].prompt_set_id // \"\"" "$contract_abs" 2>/dev/null || true)"
      if [[ -z "$command_capability_id" && -z "$skill_capability_id" && -z "$prompt_set_id" ]]; then
        EXT_LAST_ERROR_REASON="empty-routing-binding-targets:$dispatcher_id:$binding_id"
        return 1
      fi
      binding_route_by_id["$binding_id"]="$binding_route_id"
      binding_index=$((binding_index + 1))
    done

    [[ -n "${seen_routes["$default_route_id"]:-}" ]] || {
      EXT_LAST_ERROR_REASON="routing-default-route-missing:$dispatcher_id:$default_route_id"
      return 1
    }
    [[ "${route_status_by_id["$default_route_id"]}" == "resolved" ]] || {
      EXT_LAST_ERROR_REASON="routing-default-route-not-resolved:$dispatcher_id:$default_route_id"
      return 1
    }

    declare -A seen_precedence=()
    while IFS= read -r matcher_id; do
      [[ -n "$matcher_id" ]] || continue
      if [[ -n "${seen_precedence["$matcher_id"]:-}" ]]; then
        EXT_LAST_ERROR_REASON="duplicate-routing-precedence-entry:$dispatcher_id:$matcher_id"
        return 1
      fi
      seen_precedence["$matcher_id"]="1"
      [[ -n "${seen_matchers["$matcher_id"]:-}" ]] || {
        EXT_LAST_ERROR_REASON="routing-precedence-unknown-matcher:$dispatcher_id:$matcher_id"
        return 1
      }
    done < <(yq -r ".dispatchers[$dispatcher_index].precedence[]? // \"\"" "$contract_abs" 2>/dev/null || true)

    for matcher_id in "${!seen_matchers[@]}"; do
      [[ -n "${seen_precedence["$matcher_id"]:-}" ]] || {
        EXT_LAST_ERROR_REASON="routing-matcher-missing-from-precedence:$dispatcher_id:$matcher_id"
        return 1
      }
    done

    for route_id in "${!route_status_by_id[@]}"; do
      if [[ "${route_status_by_id["$route_id"]}" == "resolved" ]]; then
        execution_binding_id="$(yq -r ".dispatchers[$dispatcher_index].routes[]? | select(.route_id == \"$route_id\") | .execution_binding_id // \"\"" "$contract_abs" 2>/dev/null | head -n 1)"
        [[ -n "${binding_route_by_id["$execution_binding_id"]:-}" ]] || {
          EXT_LAST_ERROR_REASON="routing-route-binding-missing:$dispatcher_id:$route_id"
          return 1
        }
        [[ "${binding_route_by_id["$execution_binding_id"]}" == "$route_id" ]] || {
          EXT_LAST_ERROR_REASON="routing-route-binding-mismatch:$dispatcher_id:$route_id"
          return 1
        }
      fi
    done

    if yq -e ".dispatchers[$dispatcher_index] | has(\"reroute_policy\")" "$contract_abs" >/dev/null 2>&1; then
      local reroute_to_route_id max_reroutes
      reroute_to_route_id="$(yq -r ".dispatchers[$dispatcher_index].reroute_policy.reroute_to_route_id // \"\"" "$contract_abs" 2>/dev/null || true)"
      max_reroutes="$(yq -r ".dispatchers[$dispatcher_index].reroute_policy.max_reroutes // \"\"" "$contract_abs" 2>/dev/null || true)"
      [[ "$max_reroutes" =~ ^[0-9]+$ ]] || {
        EXT_LAST_ERROR_REASON="invalid-routing-reroute-count:$dispatcher_id"
        return 1
      }
      [[ -n "${seen_routes["$reroute_to_route_id"]:-}" ]] || {
        EXT_LAST_ERROR_REASON="routing-reroute-target-missing:$dispatcher_id:$reroute_to_route_id"
        return 1
      }
      yq -e ".dispatchers[$dispatcher_index].reroute_policy.allowed_source_route_ids | tag == \"!!seq\"" "$contract_abs" >/dev/null 2>&1 || {
        EXT_LAST_ERROR_REASON="missing-routing-reroute-sources:$dispatcher_id"
        return 1
      }
      yq -e ".dispatchers[$dispatcher_index].reroute_policy.trigger_reason_codes | tag == \"!!seq\"" "$contract_abs" >/dev/null 2>&1 || {
        EXT_LAST_ERROR_REASON="missing-routing-reroute-reasons:$dispatcher_id"
        return 1
      }
      while IFS= read -r route_id; do
        [[ -n "$route_id" ]] || continue
        [[ -n "${seen_routes["$route_id"]:-}" ]] || {
          EXT_LAST_ERROR_REASON="routing-reroute-source-missing:$dispatcher_id:$route_id"
          return 1
        }
      done < <(yq -r ".dispatchers[$dispatcher_index].reroute_policy.allowed_source_route_ids[]? // \"\"" "$contract_abs" 2>/dev/null || true)
      [[ "$(yq -r ".dispatchers[$dispatcher_index].reroute_policy.trigger_reason_codes | length" "$contract_abs" 2>/dev/null || echo 0)" -gt 0 ]] || {
        EXT_LAST_ERROR_REASON="empty-routing-reroute-reasons:$dispatcher_id"
        return 1
      }
    fi
  done
}

ext_validate_pack_core_contract() {
  local pack_id="$1"
  local manifest pack_root manifest_id version origin_class octon_range ext_api

  EXT_LAST_ERROR_REASON=""
  EXT_VALIDATED_VERSION=""
  EXT_VALIDATED_ORIGIN_CLASS=""
  EXT_VALIDATED_MANIFEST_REL=""
  manifest="$(ext_pack_manifest_abs "$pack_id")"
  [[ -f "$manifest" ]] || {
    EXT_LAST_ERROR_REASON="missing-pack"
    return 1
  }
  pack_root="$(ext_pack_root_abs "$pack_id")"

  [[ "$(yq -r '.schema_version // ""' "$manifest")" == "octon-extension-pack-v4" ]] || {
    EXT_LAST_ERROR_REASON="invalid-schema-version"
    return 1
  }

  manifest_id="$(yq -r '.pack_id // ""' "$manifest")"
  version="$(yq -r '.version // ""' "$manifest")"
  origin_class="$(yq -r '.origin_class // ""' "$manifest")"
  octon_range="$(yq -r '.compatibility.octon_version // ""' "$manifest")"
  ext_api="$(yq -r '.compatibility.extensions_api_version // ""' "$manifest")"

  [[ "$manifest_id" == "$pack_id" ]] || {
    EXT_LAST_ERROR_REASON="manifest-id-mismatch"
    return 1
  }
  [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
    EXT_LAST_ERROR_REASON="missing-version"
    return 1
  }
  case "$origin_class" in
    first_party_bundled|first_party_external|third_party)
      ;;
    *)
      EXT_LAST_ERROR_REASON="invalid-origin-class"
      return 1
      ;;
  esac
  [[ -n "$octon_range" ]] || {
    EXT_LAST_ERROR_REASON="missing-octon-version"
    return 1
  }
  [[ -n "$ext_api" ]] || {
    EXT_LAST_ERROR_REASON="missing-extensions-api"
    return 1
  }
  ext_validate_required_contracts "$manifest" || return 1
  [[ "$ext_api" == "$(yq -r '.versioning.extensions.api_version // ""' "$ROOT_MANIFEST")" ]] || {
    EXT_LAST_ERROR_REASON="extensions-api-mismatch"
    return 1
  }
  ext_version_satisfies "$(yq -r '.versioning.harness.release_version // ""' "$ROOT_MANIFEST")" "$octon_range" || {
    EXT_LAST_ERROR_REASON="compatibility-failure"
    return 1
  }

  yq -e '.dependencies.requires | tag == "!!seq"' "$manifest" >/dev/null 2>&1 || {
    EXT_LAST_ERROR_REASON="missing-requires"
    return 1
  }
  yq -e '.dependencies.conflicts | tag == "!!seq"' "$manifest" >/dev/null 2>&1 || {
    EXT_LAST_ERROR_REASON="missing-conflicts"
    return 1
  }

  ext_pack_has_allowed_top_level_shape "$pack_root" || return 1
  ext_validate_content_entrypoints "$pack_id" "$manifest" "$pack_root" || return 1
  ext_validate_prompt_set_manifest_if_present "$manifest" "$pack_root" || return 1
  ext_validate_routing_contract_if_present "$pack_id" "$manifest" "$pack_root" || return 1
  ext_validate_compatibility_profile_contract "$manifest" "$pack_root" || return 1

  EXT_VALIDATED_VERSION="$version"
  EXT_VALIDATED_ORIGIN_CLASS="$origin_class"
  EXT_VALIDATED_MANIFEST_REL="$(ext_pack_manifest_rel "$pack_id")"
}

ext_validate_pack_contract() {
  local pack_id="$1" source_id="$2" apply_trust="$3"
  local manifest pack_root origin_class manifest_source_id
  local trust_action source_override pack_override ack_id selected_key selected_version_pin

  EXT_LAST_ERROR_REASON=""
  EXT_LAST_ERROR_ACKNOWLEDGEMENT_ID=""
  EXT_VALIDATED_VERSION=""
  EXT_VALIDATED_ORIGIN_CLASS=""
  EXT_VALIDATED_MANIFEST_REL=""
  EXT_VALIDATED_TRUST_DECISION=""
  EXT_VALIDATED_ACKNOWLEDGEMENT_ID=""

  manifest="$(ext_pack_manifest_abs "$pack_id")"
  pack_root="$(ext_pack_root_abs "$pack_id")"
  ext_validate_pack_core_contract "$pack_id" || return 1
  origin_class="$EXT_VALIDATED_ORIGIN_CLASS"
  manifest_source_id="$(ext_manifest_source_id "$manifest")"

  ext_source_exists "$source_id" || {
    EXT_LAST_ERROR_REASON="source-not-declared"
    return 1
  }
  [[ "$(ext_source_type "$source_id")" == "internalized" ]] || {
    EXT_LAST_ERROR_REASON="source-type-invalid"
    return 1
  }
  [[ "$(ext_source_root "$source_id")" == ".octon/inputs/additive/extensions" ]] || {
    EXT_LAST_ERROR_REASON="source-root-mismatch"
    return 1
  }
  ext_validate_provenance_contract "$manifest" "$origin_class" || return 1
  [[ "$manifest_source_id" == "$source_id" ]] || {
    EXT_LAST_ERROR_REASON="provenance-source-mismatch"
    return 1
  }
  ext_source_allows_origin "$source_id" "$origin_class" || {
    EXT_LAST_ERROR_REASON="origin-class-not-allowed"
    return 1
  }

  ext_pack_has_allowed_top_level_shape "$pack_root" || return 1

  selected_key="$(ext_pack_key "$pack_id" "$source_id")"
  selected_version_pin="${EXT_SELECTED_VERSION_PIN["$selected_key"]:-}"
  if [[ -n "$selected_version_pin" ]]; then
    [[ "$selected_version_pin" == "$EXT_VALIDATED_VERSION" ]] || {
      EXT_LAST_ERROR_REASON="selected-version-pin-mismatch"
      return 1
    }
  fi

  trust_action="allow"
  if [[ "$apply_trust" == "1" ]]; then
    source_override="$(ext_source_override_action "$source_id")"
    pack_override="$(ext_pack_override_action "$pack_id")"
    trust_action="$(ext_default_trust_action "$origin_class")"
    [[ -n "$source_override" ]] && trust_action="$source_override"
    [[ -n "$pack_override" ]] && trust_action="$pack_override"
    case "$trust_action" in
      allow)
        ;;
      require_acknowledgement)
        ack_id="$(ext_acknowledgement_id_for_allow "$pack_id" "$source_id")"
        if [[ -z "$ack_id" ]]; then
          EXT_LAST_ERROR_REASON="trust-acknowledgement-required"
          return 1
        fi
        trust_action="allow"
        EXT_LAST_ERROR_ACKNOWLEDGEMENT_ID="$ack_id"
        ;;
      deny)
        EXT_LAST_ERROR_REASON="trust-denied"
        return 1
        ;;
      *)
        EXT_LAST_ERROR_REASON="invalid-trust-action"
        return 1
        ;;
    esac
  fi

  EXT_VALIDATED_VERSION="$(yq -r '.version // ""' "$manifest")"
  EXT_VALIDATED_ORIGIN_CLASS="$origin_class"
  EXT_VALIDATED_MANIFEST_REL="$(ext_pack_manifest_rel "$pack_id")"
  EXT_VALIDATED_TRUST_DECISION="$trust_action"
  EXT_VALIDATED_ACKNOWLEDGEMENT_ID="$EXT_LAST_ERROR_ACKNOWLEDGEMENT_ID"
  return 0
}

ext_command_requirement_is_satisfied() {
  local requirement="$1" abs_path
  if [[ "$requirement" == *"/"* || "$requirement" == .* ]]; then
    abs_path="$ROOT_DIR/$requirement"
    [[ -f "$abs_path" ]]
    return
  fi
  command -v "$requirement" >/dev/null 2>&1
}

ext_emit_behavior_requirements() {
  local behavior_key="$1"
  case "$behavior_key" in
    fail_closed_publication)
      printf 'command\t.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh\n'
      printf 'command\t.octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh\n'
      printf 'command\t.octon/framework/assurance/runtime/_ops/scripts/validate-extension-publication-state.sh\n'
      ;;
    compiled_runtime_consumption_only)
      printf 'file\t.octon/framework/engine/governance/extensions/README.md\n'
      printf 'directory\t.octon/generated/effective/extensions\n'
      ;;
    host_generated_receipts)
      printf 'file\t.octon/framework/cognition/_meta/architecture/state/evidence/validation/publication/schemas/validation-publication-receipt.schema.json\n'
      printf 'file\t.octon/framework/cognition/_meta/architecture/state/evidence/validation/compatibility/schemas/extension-compatibility-receipt.schema.json\n'
      printf 'directory\t.octon/state/evidence/validation/publication/extensions\n'
      printf 'directory\t.octon/state/evidence/validation/compatibility/extensions\n'
      ;;
  esac
}

ext_clear_validated_compatibility_state() {
  EXT_VALIDATED_COMPATIBILITY_STATUS=""
  EXT_VALIDATED_COMPATIBILITY_PROFILE_REL=""
  EXT_VALIDATED_COMPATIBILITY_PROFILE_SHA=""
  EXT_VALIDATED_COMPATIBILITY_REQUIRED_INPUTS=""
  EXT_VALIDATED_COMPATIBILITY_MISSING_REQUIRED_FILES=""
  EXT_VALIDATED_COMPATIBILITY_MISSING_REQUIRED_DIRECTORIES=""
  EXT_VALIDATED_COMPATIBILITY_MISSING_REQUIRED_COMMANDS=""
  EXT_VALIDATED_COMPATIBILITY_MISSING_REQUIRED_BEHAVIORS=""
  EXT_VALIDATED_COMPATIBILITY_DEGRADED_FEATURES=""
  EXT_VALIDATED_COMPATIBILITY_BLOCKING_REASONS=""
}

ext_set_validated_compatibility_lines() {
  local target="$1"
  shift
  printf -v "$target" '%s' "$(ext_join_sorted_unique_lines "$@")"
}

ext_evaluate_behavior_requirements() {
  local profile_file="$1" behavior_query="$2" required_inputs_name="$3" missing_files_name="$4" missing_dirs_name="$5" missing_commands_name="$6" missing_behaviors_name="$7"
  local behavior_key behavior_value kind requirement
  local -n required_inputs_ref="$required_inputs_name"
  local -n missing_files_ref="$missing_files_name"
  local -n missing_dirs_ref="$missing_dirs_name"
  local -n missing_commands_ref="$missing_commands_name"
  local -n missing_behaviors_ref="$missing_behaviors_name"

  while IFS= read -r behavior_key; do
    [[ -n "$behavior_key" ]] || continue
    behavior_value="$(yq -r "$behavior_query.$behavior_key" "$profile_file" 2>/dev/null || true)"
    [[ "$behavior_value" == "true" ]] || continue
    local behavior_missing=0
    while IFS=$'\t' read -r kind requirement; do
      [[ -n "$kind" ]] || continue
      required_inputs_ref+=("$requirement")
      case "$kind" in
        file)
          if [[ ! -f "$ROOT_DIR/$requirement" ]]; then
            missing_files_ref+=("$requirement")
            behavior_missing=1
          fi
          ;;
        directory)
          if [[ ! -d "$ROOT_DIR/$requirement" ]]; then
            missing_dirs_ref+=("$requirement")
            behavior_missing=1
          fi
          ;;
        command)
          if ! ext_command_requirement_is_satisfied "$requirement"; then
            missing_commands_ref+=("$requirement")
            behavior_missing=1
          fi
          ;;
      esac
    done < <(ext_emit_behavior_requirements "$behavior_key")
    if [[ "$behavior_missing" -eq 1 ]]; then
      missing_behaviors_ref+=("$behavior_key")
    fi
  done < <(yq -r "$behavior_query | keys[]? // \"\"" "$profile_file" 2>/dev/null || true)
}

ext_evaluate_optional_feature_requirements() {
  local profile_file="$1" required_inputs_name="$2" degraded_features_name="$3"
  local -n required_inputs_ref="$required_inputs_name"
  local -n degraded_features_ref="$degraded_features_name"
  local index feature_id value kind requirement feature_missing
  local tmp_required_inputs=() tmp_missing_files=() tmp_missing_dirs=() tmp_missing_commands=() tmp_missing_behaviors=()

  index=0
  while yq -e ".compatibility.optional_features[$index]" "$profile_file" >/dev/null 2>&1; do
    feature_id="$(yq -r ".compatibility.optional_features[$index].feature_id // \"\"" "$profile_file" 2>/dev/null || true)"
    feature_missing=0

    while IFS= read -r value; do
      [[ -n "$value" ]] || continue
      required_inputs_ref+=("$value")
      [[ -f "$ROOT_DIR/$value" ]] || feature_missing=1
    done < <(yq -r ".compatibility.optional_features[$index].required_files[]? // \"\"" "$profile_file" 2>/dev/null || true)

    while IFS= read -r value; do
      [[ -n "$value" ]] || continue
      required_inputs_ref+=("$value")
      [[ -d "$ROOT_DIR/$value" ]] || feature_missing=1
    done < <(yq -r ".compatibility.optional_features[$index].required_directories[]? // \"\"" "$profile_file" 2>/dev/null || true)

    while IFS= read -r value; do
      [[ -n "$value" ]] || continue
      required_inputs_ref+=("$value")
      ext_command_requirement_is_satisfied "$value" || feature_missing=1
    done < <(yq -r ".compatibility.optional_features[$index].required_commands[]? // \"\"" "$profile_file" 2>/dev/null || true)

    tmp_required_inputs=()
    tmp_missing_files=()
    tmp_missing_dirs=()
    tmp_missing_commands=()
    tmp_missing_behaviors=()
    ext_evaluate_behavior_requirements "$profile_file" ".compatibility.optional_features[$index].minimum_behavior" tmp_required_inputs tmp_missing_files tmp_missing_dirs tmp_missing_commands tmp_missing_behaviors
    required_inputs_ref+=("${tmp_required_inputs[@]}")
    if [[ "${#tmp_missing_files[@]}" -gt 0 || "${#tmp_missing_dirs[@]}" -gt 0 || "${#tmp_missing_commands[@]}" -gt 0 || "${#tmp_missing_behaviors[@]}" -gt 0 ]]; then
      feature_missing=1
    fi

    if [[ "$feature_missing" -eq 1 ]]; then
      degraded_features_ref+=("$feature_id")
    fi
    index=$((index + 1))
  done
}

ext_evaluate_pack_host_compatibility() {
  local pack_id="$1" source_id="$2" manifest="$3" pack_root="$4"
  local profile_rel profile_abs profile_sha prompt_manifest anchor_path value
  local required_inputs=() missing_files=() missing_dirs=() missing_commands=() missing_behaviors=() degraded_features=() blocking_reasons=()

  ext_clear_validated_compatibility_state

  profile_rel="$(yq -r '.compatibility.profile_path // ""' "$manifest" 2>/dev/null || true)"
  profile_abs="$pack_root/$profile_rel"
  profile_sha="$(ext_hash_file "$profile_abs")"

  required_inputs+=(".octon/inputs/additive/extensions/${pack_id}/pack.yml")
  required_inputs+=(".octon/inputs/additive/extensions/${pack_id}/${profile_rel}")

  while IFS= read -r value; do
    [[ -n "$value" ]] || continue
    required_inputs+=("$value")
    [[ -f "$ROOT_DIR/$value" ]] || missing_files+=("$value")
  done < <(yq -r '.compatibility.required_files[]? // ""' "$profile_abs" 2>/dev/null || true)

  while IFS= read -r value; do
    [[ -n "$value" ]] || continue
    required_inputs+=("$value")
    [[ -d "$ROOT_DIR/$value" ]] || missing_dirs+=("$value")
  done < <(yq -r '.compatibility.required_directories[]? // ""' "$profile_abs" 2>/dev/null || true)

  while IFS= read -r value; do
    [[ -n "$value" ]] || continue
    required_inputs+=("$value")
    ext_command_requirement_is_satisfied "$value" || missing_commands+=("$value")
  done < <(yq -r '.compatibility.required_commands[]? // ""' "$profile_abs" 2>/dev/null || true)

  while IFS= read -r prompt_manifest; do
    [[ -n "$prompt_manifest" ]] || continue
    required_inputs+=("${prompt_manifest#$ROOT_DIR/}")
    while IFS= read -r anchor_path; do
      [[ -n "$anchor_path" ]] || continue
      required_inputs+=("$anchor_path")
      [[ -e "$ROOT_DIR/$anchor_path" ]] || missing_files+=("$anchor_path")
    done < <(yq -r '.required_repo_anchors[]? // ""' "$prompt_manifest" 2>/dev/null || true)
  done < <(ext_prompt_bundle_manifest_files_for_pack "$manifest" "$pack_root")

  ext_evaluate_behavior_requirements "$profile_abs" '.compatibility.minimum_behavior' required_inputs missing_files missing_dirs missing_commands missing_behaviors
  ext_evaluate_optional_feature_requirements "$profile_abs" required_inputs degraded_features

  if [[ "${#missing_files[@]}" -gt 0 || "${#missing_dirs[@]}" -gt 0 || "${#missing_commands[@]}" -gt 0 || "${#missing_behaviors[@]}" -gt 0 ]]; then
    EXT_VALIDATED_COMPATIBILITY_STATUS="incompatible"
    blocking_reasons+=("missing-required-host-inputs")
    EXT_LAST_ERROR_REASON="compatibility-incompatible"
  elif [[ "${#degraded_features[@]}" -gt 0 ]]; then
    EXT_VALIDATED_COMPATIBILITY_STATUS="degraded"
  else
    EXT_VALIDATED_COMPATIBILITY_STATUS="compatible"
  fi

  EXT_VALIDATED_COMPATIBILITY_PROFILE_REL=".octon/inputs/additive/extensions/${pack_id}/${profile_rel}"
  EXT_VALIDATED_COMPATIBILITY_PROFILE_SHA="$profile_sha"
  ext_set_validated_compatibility_lines EXT_VALIDATED_COMPATIBILITY_REQUIRED_INPUTS "${required_inputs[@]}"
  ext_set_validated_compatibility_lines EXT_VALIDATED_COMPATIBILITY_MISSING_REQUIRED_FILES "${missing_files[@]}"
  ext_set_validated_compatibility_lines EXT_VALIDATED_COMPATIBILITY_MISSING_REQUIRED_DIRECTORIES "${missing_dirs[@]}"
  ext_set_validated_compatibility_lines EXT_VALIDATED_COMPATIBILITY_MISSING_REQUIRED_COMMANDS "${missing_commands[@]}"
  ext_set_validated_compatibility_lines EXT_VALIDATED_COMPATIBILITY_MISSING_REQUIRED_BEHAVIORS "${missing_behaviors[@]}"
  ext_set_validated_compatibility_lines EXT_VALIDATED_COMPATIBILITY_DEGRADED_FEATURES "${degraded_features[@]}"
  ext_set_validated_compatibility_lines EXT_VALIDATED_COMPATIBILITY_BLOCKING_REASONS "${blocking_reasons[@]}"

  [[ "$EXT_VALIDATED_COMPATIBILITY_STATUS" != "incompatible" ]]
}

ext_capture_pack_compatibility_result() {
  local key="$1"
  EXT_COMPAT_RESULT_STATUS["$key"]="$EXT_VALIDATED_COMPATIBILITY_STATUS"
  EXT_COMPAT_PROFILE_REL["$key"]="$EXT_VALIDATED_COMPATIBILITY_PROFILE_REL"
  EXT_COMPAT_PROFILE_SHA["$key"]="$EXT_VALIDATED_COMPATIBILITY_PROFILE_SHA"
  EXT_COMPAT_REQUIRED_INPUTS["$key"]="$EXT_VALIDATED_COMPATIBILITY_REQUIRED_INPUTS"
  EXT_COMPAT_MISSING_REQUIRED_FILES["$key"]="$EXT_VALIDATED_COMPATIBILITY_MISSING_REQUIRED_FILES"
  EXT_COMPAT_MISSING_REQUIRED_DIRECTORIES["$key"]="$EXT_VALIDATED_COMPATIBILITY_MISSING_REQUIRED_DIRECTORIES"
  EXT_COMPAT_MISSING_REQUIRED_COMMANDS["$key"]="$EXT_VALIDATED_COMPATIBILITY_MISSING_REQUIRED_COMMANDS"
  EXT_COMPAT_MISSING_REQUIRED_BEHAVIORS["$key"]="$EXT_VALIDATED_COMPATIBILITY_MISSING_REQUIRED_BEHAVIORS"
  EXT_COMPAT_DEGRADED_FEATURES["$key"]="$EXT_VALIDATED_COMPATIBILITY_DEGRADED_FEATURES"
  EXT_COMPAT_BLOCKING_REASONS["$key"]="$EXT_VALIDATED_COMPATIBILITY_BLOCKING_REASONS"
}

ext_collect_selected_compatibility_results() {
  local key pack_id source_id manifest pack_root profile_status incompatible=0 degraded=0
  local origin_class

  EXT_COMPAT_OVERALL_STATUS="compatible"
  for key in "${EXT_SELECTED_KEYS[@]}"; do
    pack_id="$(ext_key_pack_id "$key")"
    source_id="$(ext_key_source_id "$key")"
    manifest="$(ext_pack_manifest_abs "$pack_id")"
    pack_root="$(ext_pack_root_abs "$pack_id")"
    ext_clear_validated_compatibility_state

    if ! ext_validate_pack_core_contract "$pack_id"; then
      EXT_VALIDATED_COMPATIBILITY_STATUS="incompatible"
      EXT_VALIDATED_COMPATIBILITY_PROFILE_REL=".octon/inputs/additive/extensions/${pack_id}/validation/compatibility.yml"
      [[ -f "$pack_root/validation/compatibility.yml" ]] && EXT_VALIDATED_COMPATIBILITY_PROFILE_SHA="$(ext_hash_file "$pack_root/validation/compatibility.yml")"
      EXT_VALIDATED_COMPATIBILITY_REQUIRED_INPUTS=".octon/inputs/additive/extensions/${pack_id}/pack.yml"$'\n'".octon/inputs/additive/extensions/${pack_id}/validation/compatibility.yml"
      EXT_VALIDATED_COMPATIBILITY_BLOCKING_REASONS="$EXT_LAST_ERROR_REASON"
    else
      ext_evaluate_pack_host_compatibility "$pack_id" "$source_id" "$manifest" "$pack_root" || true
    fi

    ext_capture_pack_compatibility_result "$key"
    profile_status="${EXT_COMPAT_RESULT_STATUS["$key"]:-compatible}"
    if [[ "$profile_status" == "incompatible" ]]; then
      incompatible=1
    elif [[ "$profile_status" == "degraded" ]]; then
      degraded=1
    fi
  done

  if [[ "$incompatible" -eq 1 ]]; then
    EXT_COMPAT_OVERALL_STATUS="incompatible"
  elif [[ "$degraded" -eq 1 ]]; then
    EXT_COMPAT_OVERALL_STATUS="degraded"
  else
    EXT_COMPAT_OVERALL_STATUS="compatible"
  fi
}

ext_record_quarantine() {
  local pack_id="$1" source_id="$2" reason_code="$3" affected_dependents="$4" acknowledgement_id="$5"
  local key existing dependent merged
  key="$(ext_pack_key "$pack_id" "$source_id")"
  if [[ -z "${EXT_QUARANTINE_REASON["$key"]:-}" ]]; then
    EXT_QUARANTINE_REASON["$key"]="$reason_code"
    EXT_QUARANTINE_AFFECTED["$key"]=""
    EXT_QUARANTINE_ACK["$key"]="$acknowledgement_id"
    EXT_QUARANTINE_KEYS+=("$key")
  elif [[ -z "${EXT_QUARANTINE_ACK["$key"]:-}" && -n "$acknowledgement_id" ]]; then
    EXT_QUARANTINE_ACK["$key"]="$acknowledgement_id"
  fi

  if [[ -n "$affected_dependents" ]]; then
    existing="${EXT_QUARANTINE_AFFECTED["$key"]:-}"
    merged="$existing"
    IFS=',' read -r -a dependents <<< "$affected_dependents"
    for dependent in "${dependents[@]}"; do
      dependent="$(ext_trim "$dependent")"
      [[ -n "$dependent" ]] || continue
      if [[ -z "$merged" ]]; then
        merged="$dependent"
      elif [[ ",$merged," != *",$dependent,"* ]]; then
        merged="$merged,$dependent"
      fi
    done
    EXT_QUARANTINE_AFFECTED["$key"]="$merged"
  fi
}

ext_get_published_version() {
  printf '%s' "${EXT_PUBLISHED_VERSION["$1"]:-}"
}

ext_find_published_key_by_pack_id() {
  local pack_id="$1" key
  for key in "${EXT_PUBLISHED_KEYS[@]}"; do
    if [[ "$(ext_key_pack_id "$key")" == "$pack_id" ]]; then
      printf '%s' "$key"
      return 0
    fi
  done
  return 1
}

ext_clear_candidate_state() {
  declare -gA EXT_CANDIDATE_STATE=()
  declare -gA EXT_CANDIDATE_VERSION=()
  declare -gA EXT_CANDIDATE_ORIGIN_CLASS=()
  declare -gA EXT_CANDIDATE_MANIFEST_REL=()
  declare -gA EXT_CANDIDATE_TRUST_DECISION=()
  declare -gA EXT_CANDIDATE_ACKNOWLEDGEMENT_ID=()
  declare -ga EXT_CANDIDATE_KEYS=()
}

ext_get_candidate_version() {
  printf '%s' "${EXT_CANDIDATE_VERSION["$1"]:-}"
}

ext_find_candidate_key_by_pack_id() {
  local pack_id="$1" key
  for key in "${EXT_CANDIDATE_KEYS[@]}"; do
    if [[ "$(ext_key_pack_id "$key")" == "$pack_id" ]]; then
      printf '%s' "$key"
      return 0
    fi
  done
  return 1
}

ext_resolve_candidate_pack() {
  local pack_id="$1" source_id="$2" apply_trust="$3"
  local key state manifest dep_pack_id dep_range dep_source dep_key
  local conflict_pack_id conflict_range existing_key existing_version

  key="$(ext_pack_key "$pack_id" "$source_id")"

  if [[ -n "${EXT_PUBLISHED_VERSION["$key"]:-}" || -n "${EXT_CANDIDATE_VERSION["$key"]:-}" ]]; then
    return 0
  fi

  state="${EXT_CANDIDATE_STATE["$key"]:-}"
  if [[ "$state" == "visiting" ]]; then
    EXT_LAST_ERROR_REASON="dependency-cycle"
    ext_record_quarantine "$pack_id" "$source_id" "$EXT_LAST_ERROR_REASON" "" ""
    return 1
  fi

  EXT_CANDIDATE_STATE["$key"]="visiting"
  if ! ext_validate_pack_contract "$pack_id" "$source_id" "$apply_trust"; then
    ext_record_quarantine "$pack_id" "$source_id" "$EXT_LAST_ERROR_REASON" "" "$EXT_LAST_ERROR_ACKNOWLEDGEMENT_ID"
    return 1
  fi

  manifest="$(ext_pack_manifest_abs "$pack_id")"
  if ! ext_evaluate_pack_host_compatibility "$pack_id" "$source_id" "$manifest" "$(ext_pack_root_abs "$pack_id")"; then
    ext_record_quarantine "$pack_id" "$source_id" "compatibility-incompatible" "$pack_id" ""
    EXT_LAST_ERROR_REASON="compatibility-incompatible"
    return 1
  fi

  while IFS=$'\t' read -r dep_pack_id dep_range; do
    [[ -z "$dep_pack_id" ]] && continue
    dep_source="$(ext_detect_pack_source_id "$dep_pack_id" 2>/dev/null || true)"
    [[ -n "$dep_source" ]] || dep_source="$source_id"
    dep_key="$(ext_pack_key "$dep_pack_id" "$dep_source")"
    if ! ext_resolve_candidate_pack "$dep_pack_id" "$dep_source" "$apply_trust"; then
      ext_record_quarantine "$dep_pack_id" "$dep_source" "${EXT_QUARANTINE_REASON["$dep_key"]:-$EXT_LAST_ERROR_REASON}" "$pack_id" "${EXT_QUARANTINE_ACK["$dep_key"]:-}"
      EXT_LAST_ERROR_REASON="dependency-unavailable:$dep_pack_id"
      ext_record_quarantine "$pack_id" "$source_id" "$EXT_LAST_ERROR_REASON" "$pack_id" ""
      return 1
    fi
    existing_version="$(ext_get_candidate_version "$dep_key")"
    [[ -n "$existing_version" ]] || existing_version="$(ext_get_published_version "$dep_key")"
    ext_version_satisfies "$existing_version" "$dep_range" || {
      EXT_LAST_ERROR_REASON="dependency-version-mismatch:$pack_id->$dep_pack_id"
      ext_record_quarantine "$pack_id" "$source_id" "$EXT_LAST_ERROR_REASON" "$pack_id" ""
      return 1
    }
  done < <(yq -r '.dependencies.requires[]? | [.pack_id, .version_range] | @tsv' "$manifest")

  while IFS=$'\t' read -r conflict_pack_id conflict_range; do
    [[ -z "$conflict_pack_id" ]] && continue
    existing_key="$(ext_find_candidate_key_by_pack_id "$conflict_pack_id" || true)"
    if [[ -z "$existing_key" ]]; then
      existing_key="$(ext_find_published_key_by_pack_id "$conflict_pack_id" || true)"
    fi
    [[ -n "$existing_key" ]] || continue
    existing_version="$(ext_get_candidate_version "$existing_key")"
    [[ -n "$existing_version" ]] || existing_version="$(ext_get_published_version "$existing_key")"
    ext_version_satisfies "$existing_version" "$conflict_range" && {
      EXT_LAST_ERROR_REASON="declared-conflict:$pack_id->$conflict_pack_id"
      ext_record_quarantine "$pack_id" "$source_id" "$EXT_LAST_ERROR_REASON" "$pack_id" ""
      return 1
    }
  done < <(yq -r '.dependencies.conflicts[]? | [.pack_id, .version_range] | @tsv' "$manifest")

  EXT_CANDIDATE_STATE["$key"]="resolved"
  EXT_CANDIDATE_VERSION["$key"]="$EXT_VALIDATED_VERSION"
  EXT_CANDIDATE_ORIGIN_CLASS["$key"]="$EXT_VALIDATED_ORIGIN_CLASS"
  EXT_CANDIDATE_MANIFEST_REL["$key"]="$EXT_VALIDATED_MANIFEST_REL"
  EXT_CANDIDATE_TRUST_DECISION["$key"]="$EXT_VALIDATED_TRUST_DECISION"
  EXT_CANDIDATE_ACKNOWLEDGEMENT_ID["$key"]="$EXT_VALIDATED_ACKNOWLEDGEMENT_ID"
  EXT_CANDIDATE_KEYS+=("$key")
  return 0
}

ext_merge_candidate_into_published() {
  local key
  for key in "${EXT_CANDIDATE_KEYS[@]}"; do
    if [[ -n "${EXT_PUBLISHED_VERSION["$key"]:-}" ]]; then
      continue
    fi
    EXT_PUBLISHED_VERSION["$key"]="${EXT_CANDIDATE_VERSION["$key"]}"
    EXT_PUBLISHED_ORIGIN_CLASS["$key"]="${EXT_CANDIDATE_ORIGIN_CLASS["$key"]}"
    EXT_PUBLISHED_MANIFEST_REL["$key"]="${EXT_CANDIDATE_MANIFEST_REL["$key"]}"
    EXT_PUBLISHED_TRUST_DECISION["$key"]="${EXT_CANDIDATE_TRUST_DECISION["$key"]}"
    EXT_PUBLISHED_ACKNOWLEDGEMENT_ID["$key"]="${EXT_CANDIDATE_ACKNOWLEDGEMENT_ID["$key"]}"
    EXT_PUBLISHED_SOURCE_ID["$key"]="$(ext_key_source_id "$key")"
    EXT_PUBLISHED_KEYS+=("$key")
  done
}

ext_load_selected_keys_from_manifest() {
  local pack_id source_id version_pin key
  declare -A seen_pack_ids=()
  EXT_SELECTED_KEYS=()
  EXT_SELECTED_VERSION_PIN=()

  while IFS=$'\t' read -r pack_id source_id version_pin; do
    [[ -z "$pack_id" ]] && continue
    key="$(ext_pack_key "$pack_id" "$source_id")"
    if [[ -n "${seen_pack_ids["$pack_id"]:-}" ]]; then
      ext_record_quarantine "$pack_id" "$source_id" "duplicate-selection" "$pack_id" ""
      continue
    fi
    seen_pack_ids["$pack_id"]="1"
    EXT_SELECTED_KEYS+=("$key")
    EXT_SELECTED_VERSION_PIN["$key"]="$version_pin"
  done < <(yq -r '.selection.enabled[]? | [.pack_id, .source_id, (.version_pin // "")] | @tsv' "$EXTENSIONS_MANIFEST" 2>/dev/null || true)
}

ext_load_published_keys_from_active_state() {
  EXT_SELECTED_KEYS=()
  EXT_PUBLISHED_KEYS=()
  EXT_PUBLISHED_VERSION=()
  EXT_PUBLISHED_ORIGIN_CLASS=()
  EXT_PUBLISHED_MANIFEST_REL=()
  EXT_PUBLISHED_TRUST_DECISION=()
  EXT_PUBLISHED_ACKNOWLEDGEMENT_ID=()
  EXT_PUBLISHED_SOURCE_ID=()

  while IFS=$'\t' read -r pack_id source_id; do
    [[ -z "$pack_id" ]] && continue
    EXT_SELECTED_KEYS+=("$(ext_pack_key "$pack_id" "$source_id")")
  done < <(yq -r '.published_active_packs[]? | [.pack_id, .source_id] | @tsv' "$ACTIVE_STATE" 2>/dev/null || true)

  local closure_query
  if yq -e '.dependency_closure' "$ACTIVE_STATE" >/dev/null 2>&1; then
    closure_query='.dependency_closure[]? | [.pack_id, .source_id, .version, .origin_class, .manifest_path] | @tsv'
  else
    closure_query='.dependency_closure[]? | [.pack_id, .source_id, .version, .origin_class, .manifest_path] | @tsv'
  fi

  while IFS=$'\t' read -r pack_id source_id version origin_class manifest_path; do
    local key
    [[ -z "$pack_id" ]] && continue
    key="$(ext_pack_key "$pack_id" "$source_id")"
    EXT_PUBLISHED_KEYS+=("$key")
    EXT_PUBLISHED_VERSION["$key"]="$version"
    EXT_PUBLISHED_ORIGIN_CLASS["$key"]="$origin_class"
    EXT_PUBLISHED_MANIFEST_REL["$key"]="$manifest_path"
    EXT_PUBLISHED_SOURCE_ID["$key"]="$source_id"
  done < <(yq -r "$closure_query" "$CATALOG_FILE" 2>/dev/null || true)
}

ext_pack_key_sort() {
  printf '%s\n' "$@" | awk 'NF' | sort -u
}

ext_emit_pack_ref_list() {
  local key label="$1"
  shift
  if [[ "$#" -eq 0 ]]; then
    printf '%s: []\n' "$label"
    return
  fi
  printf '%s:\n' "$label"
  for key in "$@"; do
    printf '  - pack_id: "%s"\n' "$(ext_key_pack_id "$key")"
    printf '    source_id: "%s"\n' "$(ext_key_source_id "$key")"
  done
}

ext_emit_dependency_closure_list() {
  local key label="$1"
  shift
  if [[ "$#" -eq 0 ]]; then
    printf '%s: []\n' "$label"
    return
  fi
  printf '%s:\n' "$label"
  for key in "$@"; do
    printf '  - pack_id: "%s"\n' "$(ext_key_pack_id "$key")"
    printf '    source_id: "%s"\n' "$(ext_key_source_id "$key")"
    printf '    version: "%s"\n' "${EXT_PUBLISHED_VERSION["$key"]}"
    printf '    origin_class: "%s"\n' "${EXT_PUBLISHED_ORIGIN_CLASS["$key"]}"
    printf '    manifest_path: "%s"\n' "${EXT_PUBLISHED_MANIFEST_REL["$key"]}"
  done
}

ext_write_quarantine_records() {
  local now_timestamp="$1" key affected ack_id dependent
  if [[ "${#EXT_QUARANTINE_KEYS[@]}" -eq 0 ]]; then
    printf 'records: []\n'
    return
  fi
  printf 'records:\n'
  for key in "${EXT_QUARANTINE_KEYS[@]}"; do
    printf '  - pack_id: "%s"\n' "$(ext_key_pack_id "$key")"
    printf '    source_id: "%s"\n' "$(ext_key_source_id "$key")"
    printf '    reason_code: "%s"\n' "${EXT_QUARANTINE_REASON["$key"]}"
    if [[ -z "${EXT_QUARANTINE_AFFECTED["$key"]}" ]]; then
      printf '    affected_dependents: []\n'
    else
      printf '    affected_dependents:\n'
      IFS=',' read -r -a dependents <<< "${EXT_QUARANTINE_AFFECTED["$key"]}"
      for dependent in "${dependents[@]}"; do
        dependent="$(ext_trim "$dependent")"
        [[ -n "$dependent" ]] || continue
        printf '      - "%s"\n' "$dependent"
      done
    fi
    printf '    timestamp: "%s"\n' "$now_timestamp"
    ack_id="${EXT_QUARANTINE_ACK["$key"]:-}"
    if [[ -n "$ack_id" ]]; then
      printf '    acknowledgement_id: "%s"\n' "$ack_id"
    else
      printf '    acknowledgement_id: null\n'
    fi
  done
}
