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
  declare -g EXT_LAST_ERROR_REASON=""
  declare -g EXT_LAST_ERROR_ACKNOWLEDGEMENT_ID=""
  declare -g EXT_VALIDATED_VERSION=""
  declare -g EXT_VALIDATED_ORIGIN_CLASS=""
  declare -g EXT_VALIDATED_MANIFEST_REL=""
  declare -g EXT_VALIDATED_TRUST_DECISION=""
  declare -g EXT_VALIDATED_ACKNOWLEDGEMENT_ID=""
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
  for bucket in skills commands templates prompts context validation; do
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
}

ext_validate_pack_contract() {
  local pack_id="$1" source_id="$2" apply_trust="$3"
  local manifest pack_root manifest_id version origin_class octon_range ext_api manifest_source_id
  local trust_action source_override pack_override ack_id selected_key selected_version_pin

  EXT_LAST_ERROR_REASON=""
  EXT_LAST_ERROR_ACKNOWLEDGEMENT_ID=""
  EXT_VALIDATED_VERSION=""
  EXT_VALIDATED_ORIGIN_CLASS=""
  EXT_VALIDATED_MANIFEST_REL=""
  EXT_VALIDATED_TRUST_DECISION=""
  EXT_VALIDATED_ACKNOWLEDGEMENT_ID=""

  manifest="$(ext_pack_manifest_abs "$pack_id")"
  [[ -f "$manifest" ]] || {
    EXT_LAST_ERROR_REASON="missing-pack"
    return 1
  }
  pack_root="$(ext_pack_root_abs "$pack_id")"

  [[ "$(yq -r '.schema_version // ""' "$manifest")" == "octon-extension-pack-v3" ]] || {
    EXT_LAST_ERROR_REASON="invalid-schema-version"
    return 1
  }

  manifest_id="$(yq -r '.pack_id // ""' "$manifest")"
  version="$(yq -r '.version // ""' "$manifest")"
  origin_class="$(yq -r '.origin_class // ""' "$manifest")"
  octon_range="$(yq -r '.compatibility.octon_version // ""' "$manifest")"
  ext_api="$(yq -r '.compatibility.extensions_api_version // ""' "$manifest")"
  manifest_source_id="$(ext_manifest_source_id "$manifest")"

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
  ext_validate_content_entrypoints "$pack_id" "$manifest" "$pack_root" || return 1

  selected_key="$(ext_pack_key "$pack_id" "$source_id")"
  selected_version_pin="${EXT_SELECTED_VERSION_PIN["$selected_key"]:-}"
  if [[ -n "$selected_version_pin" ]]; then
    [[ "$selected_version_pin" == "$version" ]] || {
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

  EXT_VALIDATED_VERSION="$version"
  EXT_VALIDATED_ORIGIN_CLASS="$origin_class"
  EXT_VALIDATED_MANIFEST_REL="$(ext_pack_manifest_rel "$pack_id")"
  EXT_VALIDATED_TRUST_DECISION="$trust_action"
  EXT_VALIDATED_ACKNOWLEDGEMENT_ID="$EXT_LAST_ERROR_ACKNOWLEDGEMENT_ID"
  return 0
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

  while IFS=$'\t' read -r pack_id source_id version origin_class manifest_path; do
    local key
    [[ -z "$pack_id" ]] && continue
    key="$(ext_pack_key "$pack_id" "$source_id")"
    EXT_PUBLISHED_KEYS+=("$key")
    EXT_PUBLISHED_VERSION["$key"]="$version"
    EXT_PUBLISHED_ORIGIN_CLASS["$key"]="$origin_class"
    EXT_PUBLISHED_MANIFEST_REL["$key"]="$manifest_path"
    EXT_PUBLISHED_SOURCE_ID["$key"]="$source_id"
  done < <(yq -r '.dependency_closure[]? | [.pack_id, .source_id, .version, .origin_class, .manifest_path] | @tsv' "$ACTIVE_STATE" 2>/dev/null || true)
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
