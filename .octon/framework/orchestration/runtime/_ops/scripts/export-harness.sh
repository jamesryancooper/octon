#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

ROOT_MANIFEST="$OCTON_DIR/octon.yml"
FRAMEWORK_MANIFEST="$OCTON_DIR/framework/manifest.yml"
INSTANCE_MANIFEST="$OCTON_DIR/instance/manifest.yml"
EXTENSIONS_MANIFEST="$OCTON_DIR/instance/extensions.yml"
ACTIVE_STATE="$OCTON_DIR/state/control/extensions/active.yml"
VALIDATOR_DIR="$OCTON_DIR/framework/assurance/runtime/_ops/scripts"
PUBLISH_EXTENSIONS_SCRIPT="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh"

PROFILE=""
OUTPUT_DIR=""
PACK_IDS_CSV=""
VALIDATE_ONLY="${EXPORT_HARNESS_VALIDATE_ONLY:-0}"

declare -A PACK_STATE=()
declare -A PACK_VERSIONS=()
declare -a RESOLVED_PACKS=()
declare -a SELECTED_PACKS=()

usage() {
  cat <<'USAGE'
Usage:
  export-harness.sh --profile repo_snapshot --output-dir <path>
  export-harness.sh --profile pack_bundle --output-dir <path> --pack-ids <csv>

Profiles:
  repo_snapshot  Export octon.yml, framework/**, instance/**, and enabled-pack dependency closure.
  pack_bundle    Export only selected packs plus dependency closure.

Notes:
  - full_fidelity is advisory only and must use a normal Git clone.
  - Output is written to <path>/.octon/ with export.receipt.yml at <path>/.
USAGE
}

fail() {
  echo "[ERROR] $1" >&2
  exit 1
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

version_to_parts() {
  local version="$1"
  if [[ ! "$version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    return 1
  fi
  printf '%s %s %s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}"
}

compare_versions() {
  local left="$1"
  local right="$2"
  local lmaj lmin lpatch rmaj rmin rpatch
  read -r lmaj lmin lpatch < <(version_to_parts "$left") || return 2
  read -r rmaj rmin rpatch < <(version_to_parts "$right") || return 2
  if (( lmaj < rmaj )); then echo -1; return 0; fi
  if (( lmaj > rmaj )); then echo 1; return 0; fi
  if (( lmin < rmin )); then echo -1; return 0; fi
  if (( lmin > rmin )); then echo 1; return 0; fi
  if (( lpatch < rpatch )); then echo -1; return 0; fi
  if (( lpatch > rpatch )); then echo 1; return 0; fi
  echo 0
}

version_satisfies() {
  local version="$1"
  local range="$2"

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
    lower_cmp="$(compare_versions "$version" "$lower")" || return 1
    upper_cmp="$(compare_versions "$version" "$upper")" || return 1
    [[ "$lower_cmp" != "-1" && "$upper_cmp" == "-1" ]]
    return
  fi

  fail "unsupported version range syntax '$range'"
}

pack_manifest_path() {
  local pack_id="$1"
  printf '%s\n' "$OCTON_DIR/inputs/additive/extensions/$pack_id/pack.yml"
}

ensure_pack_manifest() {
  local pack_id="$1"
  local manifest
  manifest="$(pack_manifest_path "$pack_id")"
  [[ -f "$manifest" ]] || fail "missing pack manifest for '$pack_id': ${manifest#$ROOT_DIR/}"
  printf '%s\n' "$manifest"
}

validate_pack_manifest() {
  local pack_id="$1"
  local manifest="$2"
  local manifest_id pack_version octon_range ext_api

  manifest_id="$(yq -r '.id // ""' "$manifest")"
  pack_version="$(yq -r '.version // ""' "$manifest")"
  octon_range="$(yq -r '.compatibility.octon_version // ""' "$manifest")"
  ext_api="$(yq -r '.compatibility.extensions_api_version // ""' "$manifest")"

  [[ "$manifest_id" == "$pack_id" ]] || fail "pack manifest id mismatch for '$pack_id' (found '${manifest_id:-<empty>}')"
  [[ -n "$pack_version" ]] || fail "pack '$pack_id' missing version"
  [[ -n "$octon_range" ]] || fail "pack '$pack_id' missing compatibility.octon_version"
  [[ -n "$ext_api" ]] || fail "pack '$pack_id' missing compatibility.extensions_api_version"
  yq -e '.dependencies.requires | tag == "!!seq"' "$manifest" >/dev/null 2>&1 || fail "pack '$pack_id' missing dependencies.requires list"
  yq -e '.dependencies.conflicts | tag == "!!seq"' "$manifest" >/dev/null 2>&1 || fail "pack '$pack_id' missing dependencies.conflicts list"

  local harness_release extensions_api
  harness_release="$(yq -r '.versioning.harness.release_version // ""' "$ROOT_MANIFEST")"
  extensions_api="$(yq -r '.versioning.extensions.api_version // ""' "$ROOT_MANIFEST")"
  version_satisfies "$harness_release" "$octon_range" || fail "pack '$pack_id' requires octon version '$octon_range' but harness release is '$harness_release'"
  [[ "$ext_api" == "$extensions_api" ]] || fail "pack '$pack_id' extensions_api_version '$ext_api' does not match root manifest '$extensions_api'"

  PACK_VERSIONS["$pack_id"]="$pack_version"
}

resolve_pack() {
  local pack_id="$1"
  local state="${PACK_STATE["$pack_id"]:-}"

  if [[ "$state" == "visiting" ]]; then
    fail "dependency cycle detected while resolving '$pack_id'"
  fi
  if [[ "$state" == "resolved" ]]; then
    return
  fi

  local manifest dep_id dep_range
  manifest="$(ensure_pack_manifest "$pack_id")"
  validate_pack_manifest "$pack_id" "$manifest"

  PACK_STATE["$pack_id"]="visiting"

  while IFS=$'\t' read -r dep_id dep_range; do
    [[ -z "$dep_id" ]] && continue
    resolve_pack "$dep_id"
    version_satisfies "${PACK_VERSIONS["$dep_id"]:-}" "$dep_range" || fail "pack '$pack_id' requires '$dep_id' version '$dep_range' but resolved '${PACK_VERSIONS["$dep_id"]:-<missing>}'"
  done < <(yq -r '.dependencies.requires[]? | [.id, .version_range] | @tsv' "$manifest")

  PACK_STATE["$pack_id"]="resolved"
  RESOLVED_PACKS+=("$pack_id")
}

check_conflicts() {
  local pack_id manifest conflict_id conflict_range
  for pack_id in "${RESOLVED_PACKS[@]}"; do
    manifest="$(ensure_pack_manifest "$pack_id")"
    while IFS=$'\t' read -r conflict_id conflict_range; do
      [[ -z "$conflict_id" ]] && continue
      if [[ -n "${PACK_STATE["$conflict_id"]:-}" ]]; then
        version_satisfies "${PACK_VERSIONS["$conflict_id"]:-}" "$conflict_range" && fail "pack '$pack_id' conflicts with resolved pack '$conflict_id' ($conflict_range)"
      fi
    done < <(yq -r '.dependencies.conflicts[]? | [.id, .version_range] | @tsv' "$manifest")
  done
}

normalize_selected_packs() {
  local raw="$1"
  local item
  IFS=',' read -r -a input_items <<< "$raw"
  for item in "${input_items[@]}"; do
    item="$(trim "$item")"
    [[ -n "$item" ]] || continue
    SELECTED_PACKS+=("$item")
  done
}

load_selected_packs_for_profile() {
  case "$PROFILE" in
    repo_snapshot)
      mapfile -t SELECTED_PACKS < <(yq -r '.resolved_active_packs[]?' "$ACTIVE_STATE" 2>/dev/null || true)
      mapfile -t RESOLVED_PACKS < <(yq -r '.dependency_closure[]?' "$ACTIVE_STATE" 2>/dev/null || true)
      ;;
    pack_bundle)
      [[ -n "$PACK_IDS_CSV" ]] || fail "pack_bundle requires --pack-ids <csv>"
      normalize_selected_packs "$PACK_IDS_CSV"
      [[ "${#SELECTED_PACKS[@]}" -gt 0 ]] || fail "pack_bundle requires at least one explicit pack id"
      ;;
    *)
      fail "unsupported profile '$PROFILE'"
      ;;
  esac
}

run_validators() {
  local validator
  for validator in \
    validate-harness-version-contract.sh \
    validate-root-manifest-profiles.sh \
    validate-companion-manifests.sh
  do
    OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" \
      bash "$VALIDATOR_DIR/$validator"
  done
}

ensure_output_dir() {
  if [[ -e "$OUTPUT_DIR" ]]; then
    if [[ ! -d "$OUTPUT_DIR" ]]; then
      fail "output path exists and is not a directory: $OUTPUT_DIR"
    fi
    if find "$OUTPUT_DIR" -mindepth 1 -print -quit | grep -q .; then
      fail "output directory must be empty: $OUTPUT_DIR"
    fi
  else
    mkdir -p "$OUTPUT_DIR"
  fi
}

copy_file() {
  local rel_path="$1"
  local source="$OCTON_DIR/$rel_path"
  local target_root="$OUTPUT_DIR/.octon"
  mkdir -p "$target_root/$(dirname "$rel_path")"
  cp "$source" "$target_root/$rel_path"
}

copy_dir() {
  local rel_path="$1"
  local source="$OCTON_DIR/$rel_path"
  local target_root="$OUTPUT_DIR/.octon"
  mkdir -p "$target_root/$(dirname "$rel_path")"
  cp -R "$source" "$target_root/$rel_path"
}

emit_receipt() {
  local receipt="$OUTPUT_DIR/export.receipt.yml"
  local selected_csv="" resolved_csv=""
  if [[ "${#SELECTED_PACKS[@]}" -gt 0 ]]; then
    selected_csv="$(printf '%s\n' "${SELECTED_PACKS[@]}" | sort | uniq | paste -sd ',' -)"
  fi
  if [[ "${#RESOLVED_PACKS[@]}" -gt 0 ]]; then
    resolved_csv="$(printf '%s\n' "${RESOLVED_PACKS[@]}" | sort | uniq | paste -sd ',' -)"
  fi

  {
    printf 'schema_version: "octon-export-receipt-v1"\n'
    printf 'profile: "%s"\n' "$PROFILE"
    printf 'generated_at: "%s"\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    printf 'export_root: "%s"\n' "$OUTPUT_DIR/.octon"
    printf 'manifest_schema_versions:\n'
    printf '  root: "%s"\n' "$(yq -r '.schema_version // ""' "$ROOT_MANIFEST")"
    printf '  framework: "%s"\n' "$(yq -r '.schema_version // ""' "$FRAMEWORK_MANIFEST")"
    printf '  instance: "%s"\n' "$(yq -r '.schema_version // ""' "$INSTANCE_MANIFEST")"
    printf '  extensions: "%s"\n' "$(yq -r '.schema_version // ""' "$EXTENSIONS_MANIFEST")"
    if [[ -n "$selected_csv" ]]; then
      printf 'selected_packs:\n'
      printf '%s\n' "$selected_csv" | tr ',' '\n' | sed 's/^/  - "/; s/$/"/'
    else
      printf 'selected_packs: []\n'
    fi
    if [[ -n "$resolved_csv" ]]; then
      printf 'resolved_dependency_closure:\n'
      printf '%s\n' "$resolved_csv" | tr ',' '\n' | sed 's/^/  - "/; s/$/"/'
    else
      printf 'resolved_dependency_closure: []\n'
    fi
    printf 'exported_paths:\n'
    if [[ "$PROFILE" == "repo_snapshot" ]]; then
      printf '  - ".octon/octon.yml"\n'
      printf '  - ".octon/framework/"\n'
      printf '  - ".octon/instance/"\n'
    fi
    if [[ "${#RESOLVED_PACKS[@]}" -gt 0 ]]; then
      printf '%s\n' "${RESOLVED_PACKS[@]}" | sort | uniq | sed 's#^#  - ".octon/inputs/additive/extensions/#; s#$#/\"#'
    fi
  } >"$receipt"
}

materialize_export() {
  mkdir -p "$OUTPUT_DIR/.octon"

  case "$PROFILE" in
    repo_snapshot)
      copy_file "octon.yml"
      copy_dir "framework"
      copy_dir "instance"
      ;;
    pack_bundle)
      ;;
    *)
      fail "unsupported profile '$PROFILE'"
      ;;
  esac

  local pack_id
  for pack_id in "${RESOLVED_PACKS[@]}"; do
    copy_dir "inputs/additive/extensions/$pack_id"
  done
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --profile)
        shift
        [[ $# -gt 0 ]] || fail "--profile requires a value"
        PROFILE="$1"
        ;;
      --output-dir)
        shift
        [[ $# -gt 0 ]] || fail "--output-dir requires a value"
        OUTPUT_DIR="$1"
        ;;
      --pack-ids)
        shift
        [[ $# -gt 0 ]] || fail "--pack-ids requires a value"
        PACK_IDS_CSV="$1"
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        usage >&2
        fail "unknown argument: $1"
        ;;
    esac
    shift
  done

  [[ -n "$PROFILE" ]] || fail "--profile is required"
  [[ -n "$OUTPUT_DIR" ]] || fail "--output-dir is required"

  if [[ "$PROFILE" == "full_fidelity" ]]; then
    fail "full_fidelity is advisory only; use a normal Git clone for exact repository reproduction"
  fi
  [[ "$PROFILE" == "repo_snapshot" || "$PROFILE" == "pack_bundle" ]] || fail "profile must be repo_snapshot or pack_bundle"

  run_validators
  if [[ "$PROFILE" == "repo_snapshot" && "$VALIDATE_ONLY" != "1" ]]; then
    OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" \
      bash "$PUBLISH_EXTENSIONS_SCRIPT"
  fi
  if [[ "$PROFILE" == "repo_snapshot" ]]; then
    OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" \
      bash "$VALIDATOR_DIR/validate-extension-publication-state.sh"
  fi
  ensure_output_dir
  load_selected_packs_for_profile

  local pack_id
  if [[ "$PROFILE" == "pack_bundle" ]]; then
    for pack_id in "${SELECTED_PACKS[@]}"; do
      resolve_pack "$pack_id"
    done
    check_conflicts
  fi

  if [[ "$PROFILE" == "pack_bundle" && "${#SELECTED_PACKS[@]}" -eq 0 ]]; then
    fail "pack_bundle requires explicit pack ids"
  fi

  if [[ "$VALIDATE_ONLY" == "1" ]]; then
    echo "[OK] export request validated for profile '$PROFILE'"
    exit 0
  fi

  materialize_export
  emit_receipt

  echo "[OK] export created at $OUTPUT_DIR"
}

main "$@"
