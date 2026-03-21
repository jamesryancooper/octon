#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

ROOT_MANIFEST="$OCTON_DIR/octon.yml"
INSTANCE_MANIFEST="$OCTON_DIR/instance/manifest.yml"
LOCALITY_MANIFEST="$OCTON_DIR/instance/locality/manifest.yml"
LOCALITY_REGISTRY="$OCTON_DIR/instance/locality/registry.yml"
SCOPES_DIR="$OCTON_DIR/instance/locality/scopes"
QUARANTINE_STATE="$OCTON_DIR/state/control/locality/quarantine.yml"
EFFECTIVE_DIR="$OCTON_DIR/generated/effective/locality"
SCOPES_EFFECTIVE_FILE="$EFFECTIVE_DIR/scopes.effective.yml"
ARTIFACT_MAP_FILE="$EFFECTIVE_DIR/artifact-map.yml"
GENERATION_LOCK_FILE="$EFFECTIVE_DIR/generation.lock.yml"
SCOPE_SCHEMA_FILE="$OCTON_DIR/framework/cognition/_meta/architecture/instance/locality/schemas/scope.schema.json"
SCOPE_CONTINUITY_ROOT="$OCTON_DIR/state/continuity/scopes"

declare -A SCOPE_MANIFEST_PATHS=()
declare -A SCOPE_MANIFEST_DIGESTS=()
declare -A SCOPE_ROOT_PATHS=()
declare -A SCOPE_DISPLAY_NAMES=()
declare -A SCOPE_OWNERS=()
declare -A SCOPE_STATUSES=()
declare -A SCOPE_TECH_TAGS=()
declare -A SCOPE_LANGUAGE_TAGS=()
declare -A SCOPE_INCLUDE_GLOBS=()
declare -A SCOPE_EXCLUDE_GLOBS=()
declare -A SCOPE_ROUTING_HINTS=()
declare -A SCOPE_MISSION_DEFAULTS=()
declare -A QUARANTINED_SCOPE_IDS=()
declare -a DECLARED_SCOPE_IDS=()
declare -a ACTIVE_SCOPE_IDS=()
declare -a QUARANTINE_RECORDS=()

PUBLISHED_AT=""
GENERATION_ID=""
GENERATOR_VERSION=""
PUBLICATION_STATUS=""

hash_file() {
  local file="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
  else
    sha256sum "$file" | awk '{print $1}'
  fi
}

receipt_timestamp_slug() {
  local timestamp="$1"
  timestamp="${timestamp//:/-}"
  printf '%s\n' "$timestamp"
}

locality_publication_receipt_rel() {
  local timestamp_slug="$1" generation_id="$2"
  printf '.octon/state/evidence/validation/publication/locality/%s-%s.yml\n' "$timestamp_slug" "$generation_id"
}

normalize_path() {
  local path="$1"
  path="${path#./}"
  path="${path%/}"
  if [[ -z "$path" ]]; then
    path="."
  fi
  printf '%s\n' "$path"
}

is_safe_relative_pattern() {
  local pattern="$1"
  [[ -n "$pattern" ]] || return 1
  [[ "$pattern" != /* ]] || return 1
  [[ "$pattern" != *"../"* ]] || return 1
  [[ "$pattern" != "../"* ]] || return 1
  [[ "$pattern" != *"/.." ]] || return 1
  [[ "$pattern" != ".." ]] || return 1
  return 0
}

path_contains() {
  local parent="$1"
  local child="$2"
  if [[ "$parent" == "." ]]; then
    return 0
  fi
  [[ "$child" == "$parent" || "$child" == "$parent/"* ]]
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

glob_subordinate_to_root() {
  local root_path="$1"
  local pattern="$2"
  local anchor
  anchor="$(normalize_path "$(glob_anchor_path "$pattern")")"
  path_contains "$root_path" "$anchor"
}

is_canonical_scope_manifest_path() {
  local scope_id="$1"
  local manifest_path="$2"
  [[ "$manifest_path" == ".octon/instance/locality/scopes/$scope_id/scope.yml" ]]
}

append_quarantine_record() {
  local scope_id="$1"
  local manifest_path="$2"
  local reason_code="$3"
  QUARANTINE_RECORDS+=("$scope_id|$manifest_path|$reason_code")
}

is_publication_blocking_scope() {
  local scope_id="$1"
  [[ "$scope_id" == "repo-locality" || "$scope_id" == registry-entry-* ]]
}

mark_quarantined_scope_ids() {
  local record scope_id manifest_path reason_code
  QUARANTINED_SCOPE_IDS=()
  for record in "${QUARANTINE_RECORDS[@]}"; do
    IFS='|' read -r scope_id manifest_path reason_code <<<"$record"
    if ! is_publication_blocking_scope "$scope_id"; then
      QUARANTINED_SCOPE_IDS["$scope_id"]="1"
    fi
  done
}

is_scope_quarantined() {
  local scope_id="$1"
  [[ -n "${QUARANTINED_SCOPE_IDS["$scope_id"]:-}" ]]
}

write_locality_publication_receipt() {
  local output_file="$1" receipt_id="$2" generation_id="$3" result="$4" manifest_sha="$5" registry_sha="$6" quarantine_sha="$7"
  local record scope_id manifest_path reason_code
  local blocked_reasons=()
  local required_inputs=(
    ".octon/octon.yml"
    ".octon/instance/manifest.yml"
    ".octon/instance/locality/manifest.yml"
    ".octon/instance/locality/registry.yml"
  )
  local published_paths=()

  for scope_id in "${DECLARED_SCOPE_IDS[@]}"; do
    required_inputs+=("${SCOPE_MANIFEST_PATHS[$scope_id]}")
  done
  if [[ "$result" != "blocked" ]]; then
    published_paths=(
      ".octon/generated/effective/locality/scopes.effective.yml"
      ".octon/generated/effective/locality/artifact-map.yml"
      ".octon/generated/effective/locality/generation.lock.yml"
    )
  fi

  {
    printf 'schema_version: "octon-validation-publication-receipt-v1"\n'
    printf 'receipt_id: "%s"\n' "$receipt_id"
    printf 'publication_family: "locality"\n'
    printf 'generation_id: "%s"\n' "$generation_id"
    printf 'result: "%s"\n' "$result"
    printf 'validated_at: "%s"\n' "$PUBLISHED_AT"
    printf 'validator_version: "%s"\n' "$GENERATOR_VERSION"
    printf 'contract_refs:\n'
    printf '  - ".octon/framework/cognition/_meta/architecture/state/control/schemas/locality-quarantine-state.schema.json"\n'
    printf '  - ".octon/framework/cognition/_meta/architecture/generated/effective/locality/schemas/locality-effective-scopes.schema.json"\n'
    printf '  - ".octon/framework/cognition/_meta/architecture/generated/effective/locality/schemas/locality-generation-lock.schema.json"\n'
    printf 'source_digests:\n'
    printf '  root_manifest_sha256: "%s"\n' "$(hash_file "$ROOT_MANIFEST")"
    printf '  instance_manifest_sha256: "%s"\n' "$(hash_file "$INSTANCE_MANIFEST")"
    printf '  locality_manifest_sha256: "%s"\n' "$manifest_sha"
    printf '  locality_registry_sha256: "%s"\n' "$registry_sha"
    printf '  quarantine_sha256: "%s"\n' "$quarantine_sha"
    for scope_id in "${DECLARED_SCOPE_IDS[@]}"; do
      printf '  scope_manifest__%s: "%s"\n' "$scope_id" "${SCOPE_MANIFEST_DIGESTS[$scope_id]}"
      printf '  scope_continuity__%s: "%s"\n' "$scope_id" "$(scope_continuity_digest "$scope_id")"
      printf '  scope_decision_evidence__%s: "%s"\n' "$scope_id" "$(scope_decision_evidence_digest "$scope_id")"
    done
    if [[ "${#QUARANTINE_RECORDS[@]}" -eq 0 ]]; then
      printf 'blocked_reasons: []\n'
    else
      for record in "${QUARANTINE_RECORDS[@]}"; do
        IFS='|' read -r scope_id manifest_path reason_code <<<"$record"
        blocked_reasons+=("$reason_code")
      done
      printf 'blocked_reasons:\n'
      printf '%s\n' "${blocked_reasons[@]}" | awk 'NF' | LC_ALL=C sort -u | while IFS= read -r reason_code; do
        printf '  - "%s"\n' "$reason_code"
      done
    fi
    if [[ "${#QUARANTINE_RECORDS[@]}" -eq 0 ]]; then
      printf 'quarantined_subjects: []\n'
    else
      printf 'quarantined_subjects:\n'
      for record in "${QUARANTINE_RECORDS[@]}"; do
        IFS='|' read -r scope_id manifest_path reason_code <<<"$record"
        if is_publication_blocking_scope "$scope_id"; then
          printf '  - subject_kind: "repo"\n'
        else
          printf '  - subject_kind: "scope"\n'
        fi
        printf '    subject_id: "%s"\n' "$scope_id"
        printf '    reason_code: "%s"\n' "$reason_code"
        printf '    manifest_path: "%s"\n' "$manifest_path"
      done
    fi
    if [[ "${#published_paths[@]}" -eq 0 ]]; then
      printf 'published_paths: []\n'
    else
      printf 'published_paths:\n'
      for manifest_path in "${published_paths[@]}"; do
        printf '  - "%s"\n' "$manifest_path"
      done
    fi
    printf 'required_inputs:\n'
    printf '%s\n' "${required_inputs[@]}" | awk 'NF' | LC_ALL=C sort -u | while IFS= read -r manifest_path; do
      printf '  - "%s"\n' "$manifest_path"
    done
  } >"$output_file"
}

json_compact_or_default() {
  local query="$1"
  local file="$2"
  local default_json="$3"
  local value
  value="$(yq -o=json "$query" "$file" 2>/dev/null || true)"
  if [[ -z "$value" || "$value" == "null" ]]; then
    printf '%s\n' "$default_json"
  else
    printf '%s\n' "$value" | tr -d '\n'
    printf '\n'
  fi
}

validate_scope_routing_hints_for_publish() {
  local scope_id="$1"
  local manifest_path="$2"
  local manifest_file="$3"
  local key kind

  if ! yq -e 'has("routing_hints")' "$manifest_file" >/dev/null 2>&1; then
    return 0
  fi

  if ! yq -e '.routing_hints | type == "!!map"' "$manifest_file" >/dev/null 2>&1; then
    append_quarantine_record "$scope_id" "$manifest_path" "invalid-routing-hints"
    return 0
  fi

  while IFS= read -r key; do
    [[ -z "$key" ]] && continue
    case "$key" in
      preferred_capability_domains|preferred_pack_tags|ranking_hints)
        ;;
      *)
        append_quarantine_record "$scope_id" "$manifest_path" "invalid-routing-hints-key"
        ;;
    esac
  done < <(yq -r '.routing_hints | keys[]?' "$manifest_file" 2>/dev/null || true)

  if yq -e '.routing_hints.preferred_capability_domains' "$manifest_file" >/dev/null 2>&1 \
    && ! yq -e '.routing_hints.preferred_capability_domains | type == "!!seq"' "$manifest_file" >/dev/null 2>&1; then
    append_quarantine_record "$scope_id" "$manifest_path" "invalid-preferred-capability-domains"
  fi

  if yq -e '.routing_hints.preferred_pack_tags' "$manifest_file" >/dev/null 2>&1 \
    && ! yq -e '.routing_hints.preferred_pack_tags | type == "!!seq"' "$manifest_file" >/dev/null 2>&1; then
    append_quarantine_record "$scope_id" "$manifest_path" "invalid-preferred-pack-tags"
  fi

  if yq -e '.routing_hints.ranking_hints' "$manifest_file" >/dev/null 2>&1; then
    if ! yq -e '.routing_hints.ranking_hints | type == "!!map"' "$manifest_file" >/dev/null 2>&1; then
      append_quarantine_record "$scope_id" "$manifest_path" "invalid-ranking-hints"
      return 0
    fi
    while IFS= read -r key; do
      [[ -z "$key" ]] && continue
      if [[ "$key" != "preferred_capability_kinds" ]]; then
        append_quarantine_record "$scope_id" "$manifest_path" "invalid-ranking-hints-key"
      fi
    done < <(yq -r '.routing_hints.ranking_hints | keys[]?' "$manifest_file" 2>/dev/null || true)
    if yq -e '.routing_hints.ranking_hints.preferred_capability_kinds' "$manifest_file" >/dev/null 2>&1; then
      if ! yq -e '.routing_hints.ranking_hints.preferred_capability_kinds | type == "!!seq"' "$manifest_file" >/dev/null 2>&1; then
        append_quarantine_record "$scope_id" "$manifest_path" "invalid-preferred-capability-kinds"
      else
        while IFS= read -r kind; do
          [[ -z "$kind" ]] && continue
          case "$kind" in
            command|skill|service|tool) ;;
            *)
              append_quarantine_record "$scope_id" "$manifest_path" "invalid-preferred-capability-kind"
              ;;
          esac
        done < <(yq -r '.routing_hints.ranking_hints.preferred_capability_kinds[]?' "$manifest_file" 2>/dev/null || true)
      fi
    fi
  fi
}

yaml_string_list() {
  local query="$1"
  local file="$2"
  yq -r "$query[]?" "$file" 2>/dev/null || true
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
  hash_directory_payload "$SCOPE_CONTINUITY_ROOT/$scope_id" "__absent_scope_continuity__"
}

scope_decision_evidence_digest() {
  local scope_id="$1"
  hash_directory_payload "$OCTON_DIR/state/evidence/decisions/scopes/$scope_id" "__absent_scope_decision_evidence__"
}

decision_record_json_valid() {
  jq -e '
    .decision_id and
    .outcome and
    .surface and
    .action and
    .actor and
    .decided_at and
    (.reason_codes | type == "array" and length > 0) and
    .summary
  ' "$1" >/dev/null 2>&1
}

validate_scope_continuity_for_publish() {
  local scope_id="$1"
  local manifest_path="$2"
  local scope_dir="$SCOPE_CONTINUITY_ROOT/$scope_id"
  local continuity_file

  [[ -d "$scope_dir" ]] || return 0

  for continuity_file in log.md tasks.json entities.json next.md; do
    if [[ ! -f "$scope_dir/$continuity_file" ]]; then
      append_quarantine_record "$scope_id" "$manifest_path" "missing-scope-continuity-$continuity_file"
    fi
  done

  if [[ -f "$scope_dir/tasks.json" ]] && ! jq -e '.' "$scope_dir/tasks.json" >/dev/null 2>&1; then
    append_quarantine_record "$scope_id" "$manifest_path" "invalid-scope-continuity-tasks-json"
  fi
  if [[ -f "$scope_dir/entities.json" ]] && ! jq -e '.' "$scope_dir/entities.json" >/dev/null 2>&1; then
    append_quarantine_record "$scope_id" "$manifest_path" "invalid-scope-continuity-entities-json"
  fi
}

validate_scope_decision_evidence_for_publish() {
  local scope_id="$1"
  local manifest_path="$2"
  local evidence_dir="$OCTON_DIR/state/evidence/decisions/scopes/$scope_id"
  local evidence_file line_idx line

  [[ -d "$evidence_dir" ]] || return 0

  while IFS= read -r evidence_file; do
    [[ -n "$evidence_file" ]] || continue
    case "$evidence_file" in
      *.json)
        if ! jq -e '.' "$evidence_file" >/dev/null 2>&1 || ! decision_record_json_valid "$evidence_file"; then
          append_quarantine_record "$scope_id" "$manifest_path" "invalid-scope-decision-evidence-json"
        fi
        ;;
      *.jsonl)
        line_idx=0
        while IFS= read -r line || [[ -n "$line" ]]; do
          line_idx=$((line_idx + 1))
          [[ -n "$line" ]] || continue
          if ! jq -e '.' <<<"$line" >/dev/null 2>&1 || ! jq -e '
            .decision_id and
            .outcome and
            .surface and
            .action and
            .actor and
            .decided_at and
            (.reason_codes | type == "array" and length > 0) and
            .summary
          ' <<<"$line" >/dev/null 2>&1; then
            append_quarantine_record "$scope_id" "$manifest_path" "invalid-scope-decision-evidence-jsonl"
            break
          fi
        done <"$evidence_file"
        ;;
    esac
  done < <(find "$evidence_dir" -type f | LC_ALL=C sort)
}

collect_scope() {
  local scope_id="$1"
  local manifest_path="$2"
  local manifest_file="$ROOT_DIR/$manifest_path"

  if ! is_safe_relative_pattern "$manifest_path"; then
    append_quarantine_record "$scope_id" "$manifest_path" "invalid-manifest-path"
    return
  fi

  if ! is_canonical_scope_manifest_path "$scope_id" "$manifest_path"; then
    append_quarantine_record "$scope_id" "$manifest_path" "noncanonical-manifest-path"
    return
  fi

  if [[ ! -f "$manifest_file" ]]; then
    append_quarantine_record "$scope_id" "$manifest_path" "missing-scope-manifest"
    return
  fi

  if ! yq -e '.' "$manifest_file" >/dev/null 2>&1; then
    append_quarantine_record "$scope_id" "$manifest_path" "invalid-scope-yaml"
    return
  fi

  if [[ "$(yq -r '.schema_version // ""' "$manifest_file")" != "octon-locality-scope-v2" ]]; then
    append_quarantine_record "$scope_id" "$manifest_path" "invalid-scope-schema-version"
  fi

  local manifest_scope_id
  manifest_scope_id="$(yq -r '.scope_id // ""' "$manifest_file")"
  if [[ -z "$manifest_scope_id" || "$manifest_scope_id" != "$scope_id" ]]; then
    append_quarantine_record "$scope_id" "$manifest_path" "scope-id-mismatch"
  fi

  local root_path
  root_path="$(yq -r '.root_path // ""' "$manifest_file")"
  if ! yq -e '.root_path | type == "!!str"' "$manifest_file" >/dev/null 2>&1; then
    append_quarantine_record "$scope_id" "$manifest_path" "invalid-root-path-type"
  elif ! is_safe_relative_pattern "$root_path"; then
    append_quarantine_record "$scope_id" "$manifest_path" "invalid-root-path"
  else
    root_path="$(normalize_path "$root_path")"
  fi

  local required_field
  for required_field in display_name owner status; do
    if ! yq -e ".$required_field | type == \"!!str\" and . != \"\"" "$manifest_file" >/dev/null 2>&1; then
      append_quarantine_record "$scope_id" "$manifest_path" "missing-$required_field"
    fi
  done

  if ! yq -e '.tech_tags | type == "!!seq"' "$manifest_file" >/dev/null 2>&1; then
    append_quarantine_record "$scope_id" "$manifest_path" "invalid-tech-tags"
  fi

  if ! yq -e '.language_tags | type == "!!seq"' "$manifest_file" >/dev/null 2>&1; then
    append_quarantine_record "$scope_id" "$manifest_path" "invalid-language-tags"
  fi

  if yq -e 'has("include_globs")' "$manifest_file" >/dev/null 2>&1; then
    if ! yq -e '.include_globs | type == "!!seq"' "$manifest_file" >/dev/null 2>&1; then
      append_quarantine_record "$scope_id" "$manifest_path" "invalid-include-globs"
    else
      local glob
      while IFS= read -r glob; do
        [[ -z "$glob" ]] && continue
        if ! is_safe_relative_pattern "$glob"; then
          append_quarantine_record "$scope_id" "$manifest_path" "invalid-include-glob-pattern"
        elif ! glob_subordinate_to_root "$root_path" "$glob"; then
          append_quarantine_record "$scope_id" "$manifest_path" "include-glob-outside-root"
        fi
      done < <(yaml_string_list '.include_globs' "$manifest_file")
    fi
  fi

  if yq -e 'has("exclude_globs")' "$manifest_file" >/dev/null 2>&1; then
    if ! yq -e '.exclude_globs | type == "!!seq"' "$manifest_file" >/dev/null 2>&1; then
      append_quarantine_record "$scope_id" "$manifest_path" "invalid-exclude-globs"
    else
      local glob
      while IFS= read -r glob; do
        [[ -z "$glob" ]] && continue
        if ! is_safe_relative_pattern "$glob"; then
          append_quarantine_record "$scope_id" "$manifest_path" "invalid-exclude-glob-pattern"
        elif ! glob_subordinate_to_root "$root_path" "$glob"; then
          append_quarantine_record "$scope_id" "$manifest_path" "exclude-glob-outside-root"
        fi
      done < <(yaml_string_list '.exclude_globs' "$manifest_file")
    fi
  fi

  validate_scope_routing_hints_for_publish "$scope_id" "$manifest_path" "$manifest_file"

  if yq -e 'has("mission_defaults")' "$manifest_file" >/dev/null 2>&1; then
    if ! yq -e '.mission_defaults | type == "!!map"' "$manifest_file" >/dev/null 2>&1; then
      append_quarantine_record "$scope_id" "$manifest_path" "invalid-mission-defaults"
    fi
  fi

  if [[ ! -d "$OCTON_DIR/instance/cognition/context/scopes/$scope_id" ]]; then
    append_quarantine_record "$scope_id" "$manifest_path" "missing-scope-context-directory"
  fi

  validate_scope_continuity_for_publish "$scope_id" "$manifest_path"
  validate_scope_decision_evidence_for_publish "$scope_id" "$manifest_path"

  DECLARED_SCOPE_IDS+=("$scope_id")
  SCOPE_MANIFEST_PATHS["$scope_id"]="$manifest_path"
  SCOPE_MANIFEST_DIGESTS["$scope_id"]="$(hash_file "$manifest_file")"
  SCOPE_ROOT_PATHS["$scope_id"]="$(normalize_path "$root_path")"
  SCOPE_DISPLAY_NAMES["$scope_id"]="$(yq -r '.display_name // ""' "$manifest_file")"
  SCOPE_OWNERS["$scope_id"]="$(yq -r '.owner // ""' "$manifest_file")"
  SCOPE_STATUSES["$scope_id"]="$(yq -r '.status // ""' "$manifest_file")"
  SCOPE_TECH_TAGS["$scope_id"]="$(json_compact_or_default '.tech_tags' "$manifest_file" '[]')"
  SCOPE_LANGUAGE_TAGS["$scope_id"]="$(json_compact_or_default '.language_tags' "$manifest_file" '[]')"
  SCOPE_INCLUDE_GLOBS["$scope_id"]="$(json_compact_or_default '.include_globs' "$manifest_file" '[]')"
  SCOPE_EXCLUDE_GLOBS["$scope_id"]="$(json_compact_or_default '.exclude_globs' "$manifest_file" '[]')"
  SCOPE_ROUTING_HINTS["$scope_id"]="$(json_compact_or_default '.routing_hints' "$manifest_file" '{}')"
  SCOPE_MISSION_DEFAULTS["$scope_id"]="$(json_compact_or_default '.mission_defaults' "$manifest_file" '{}')"

  if [[ "${SCOPE_STATUSES[$scope_id]}" == "active" ]]; then
    ACTIVE_SCOPE_IDS+=("$scope_id")
  fi
}

write_quarantine_file() {
  local output_file="$1"
  {
    printf 'schema_version: "octon-locality-quarantine-state-v2"\n'
    printf 'updated_at: "%s"\n' "$PUBLISHED_AT"
    if [[ "${#QUARANTINE_RECORDS[@]}" -eq 0 ]]; then
      printf 'records: []\n'
    else
      printf 'records:\n'
      local record scope_id manifest_path reason_code
      for record in "${QUARANTINE_RECORDS[@]}"; do
        IFS='|' read -r scope_id manifest_path reason_code <<<"$record"
        printf '  - scope_id: "%s"\n' "$scope_id"
        printf '    manifest_path: "%s"\n' "$manifest_path"
        printf '    reason_code: "%s"\n' "$reason_code"
        printf '    quarantined_at: "%s"\n' "$PUBLISHED_AT"
        if is_publication_blocking_scope "$scope_id"; then
          printf '    publication_blocking: true\n'
        else
          printf '    publication_blocking: false\n'
        fi
      done
    fi
  } >"$output_file"
}

ensure_scope_continuity_scaffold() {
  local scope_id="$1"
  local scope_dir="$SCOPE_CONTINUITY_ROOT/$scope_id"

  mkdir -p "$scope_dir"

  if [[ ! -f "$scope_dir/log.md" ]]; then
    cat >"$scope_dir/log.md" <<EOF
---
title: Scope Progress Log
description: Chronological record of scope-local session work and decisions.
mutability: append-only
scope_id: "$scope_id"
---

# Scope Progress Log
EOF
  fi

  if [[ ! -f "$scope_dir/tasks.json" ]]; then
    cat >"$scope_dir/tasks.json" <<EOF
{
  "schema_version": "1.2",
  "goal": "Track active work that is primarily owned by the $scope_id scope.",
  "tasks": []
}
EOF
  fi

  if [[ ! -f "$scope_dir/entities.json" ]]; then
    cat >"$scope_dir/entities.json" <<EOF
{
  "schema_version": "1.1",
  "description": "Tracks state of scope-local entities relevant to $scope_id continuity planning",
  "entities": {}
}
EOF
  fi

  if [[ ! -f "$scope_dir/next.md" ]]; then
    cat >"$scope_dir/next.md" <<EOF
---
title: Scope Next Actions
description: Immediate actionable steps for the $scope_id scope.
scope_id: "$scope_id"
---

# Scope Next Actions

Immediate scope-local steps to take when work is primarily owned by the
$scope_id scope.

## Current

## Backlog
EOF
  fi
}

main() {
  mkdir -p "$EFFECTIVE_DIR" "$(dirname "$QUARANTINE_STATE")" "$SCOPE_CONTINUITY_ROOT"
  PUBLISHED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  if [[ ! -f "$INSTANCE_MANIFEST" || ! -f "$LOCALITY_MANIFEST" || ! -f "$LOCALITY_REGISTRY" ]]; then
    echo "[ERROR] missing required locality control files" >&2
    exit 1
  fi
  if [[ ! -f "$ROOT_MANIFEST" ]]; then
    echo "[ERROR] missing root manifest: ${ROOT_MANIFEST#$ROOT_DIR/}" >&2
    exit 1
  fi
  if [[ ! -f "$SCOPE_SCHEMA_FILE" ]]; then
    echo "[ERROR] missing locality scope schema contract: ${SCOPE_SCHEMA_FILE#$ROOT_DIR/}" >&2
    exit 1
  fi
  GENERATOR_VERSION="$(yq -r '.versioning.harness.release_version // ""' "$ROOT_MANIFEST" 2>/dev/null || true)"
  if [[ -z "$GENERATOR_VERSION" ]]; then
    echo "[ERROR] root manifest missing versioning.harness.release_version" >&2
    exit 1
  fi

  if [[ "$(yq -r '.locality.registry_path // ""' "$INSTANCE_MANIFEST")" != ".octon/instance/locality/registry.yml" ]]; then
    append_quarantine_record "repo-locality" ".octon/instance/locality/registry.yml" "instance-manifest-registry-path-mismatch"
  fi
  if [[ "$(yq -r '.locality.manifest_path // ""' "$INSTANCE_MANIFEST")" != ".octon/instance/locality/manifest.yml" ]]; then
    append_quarantine_record "repo-locality" ".octon/instance/locality/manifest.yml" "instance-manifest-manifest-path-mismatch"
  fi
  if [[ "$(yq -r '.registry_path // ""' "$LOCALITY_MANIFEST")" != ".octon/instance/locality/registry.yml" ]]; then
    append_quarantine_record "repo-locality" ".octon/instance/locality/manifest.yml" "locality-manifest-registry-path-mismatch"
  fi
  if [[ "$(yq -r '.resolution_mode // ""' "$LOCALITY_MANIFEST")" != "single-active-scope" ]]; then
    append_quarantine_record "repo-locality" ".octon/instance/locality/manifest.yml" "invalid-resolution-mode"
  fi

  if ! yq -e '.scopes | type == "!!seq"' "$LOCALITY_REGISTRY" >/dev/null 2>&1; then
    append_quarantine_record "repo-locality" ".octon/instance/locality/registry.yml" "invalid-registry-scopes"
  else
    local entry_index scope_id manifest_path
    while IFS='|' read -r entry_index scope_id manifest_path; do
      if [[ -z "$scope_id" ]]; then
        append_quarantine_record "registry-entry-$entry_index" ".octon/instance/locality/registry.yml" "missing-scope-id"
        continue
      fi
      collect_scope "$scope_id" "$manifest_path"
    done < <(
      yq -o=json '.scopes' "$LOCALITY_REGISTRY" 2>/dev/null \
        | jq -r 'to_entries[]? | [.key, (.value.scope_id // ""), (.value.manifest_path // "")] | join("|")'
    )
  fi

  local unique_count
  unique_count="$(printf '%s\n' "${DECLARED_SCOPE_IDS[@]}" | awk 'NF' | sort -u | wc -l | tr -d ' ')"
  if [[ "$unique_count" != "${#DECLARED_SCOPE_IDS[@]}" ]]; then
    local duplicate
    while IFS= read -r duplicate; do
      [[ -z "$duplicate" ]] && continue
      append_quarantine_record "$duplicate" "${SCOPE_MANIFEST_PATHS[$duplicate]:-.octon/instance/locality/registry.yml}" "duplicate-scope-id"
    done < <(printf '%s\n' "${DECLARED_SCOPE_IDS[@]}" | awk 'NF' | sort | uniq -d)
  fi

  local i j left_id right_id left_root right_root
  for ((i = 0; i < ${#ACTIVE_SCOPE_IDS[@]}; i += 1)); do
    left_id="${ACTIVE_SCOPE_IDS[$i]}"
    left_root="${SCOPE_ROOT_PATHS[$left_id]}"
    for ((j = i + 1; j < ${#ACTIVE_SCOPE_IDS[@]}; j += 1)); do
      right_id="${ACTIVE_SCOPE_IDS[$j]}"
      right_root="${SCOPE_ROOT_PATHS[$right_id]}"
      if path_contains "$left_root" "$right_root" || path_contains "$right_root" "$left_root"; then
        append_quarantine_record "$left_id" "${SCOPE_MANIFEST_PATHS[$left_id]}" "overlapping-active-scope"
        append_quarantine_record "$right_id" "${SCOPE_MANIFEST_PATHS[$right_id]}" "overlapping-active-scope"
      fi
    done
  done

  local tmpdir quarantine_tmp scopes_tmp artifact_map_tmp lock_tmp receipt_tmp
  local manifest_sha registry_sha quarantine_sha quarantine_generation_sha input_digest
  local receipt_slug receipt_rel receipt_abs receipt_id receipt_sha
  local invalidation_conditions=(
    "locality-manifest-sha-changed"
    "locality-registry-sha-changed"
    "quarantine-state-changed"
    "scope-manifest-sha-changed"
  )
  local has_blocking=0
  tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/octon-locality-publish.XXXXXX")"
  trap '[[ -n "${tmpdir:-}" ]] && rm -r -f -- "$tmpdir"' EXIT
  quarantine_tmp="$tmpdir/quarantine.yml"
  scopes_tmp="$tmpdir/scopes.effective.yml"
  artifact_map_tmp="$tmpdir/artifact-map.yml"
  lock_tmp="$tmpdir/generation.lock.yml"
  receipt_tmp="$tmpdir/publication.receipt.yml"
  write_quarantine_file "$quarantine_tmp"

  mark_quarantined_scope_ids
  for record in "${QUARANTINE_RECORDS[@]}"; do
    IFS='|' read -r scope_id manifest_path reason_code <<<"$record"
    if is_publication_blocking_scope "$scope_id"; then
      has_blocking=1
      break
    fi
  done

  manifest_sha="$(hash_file "$LOCALITY_MANIFEST")"
  registry_sha="$(hash_file "$LOCALITY_REGISTRY")"
  quarantine_sha="$(hash_file "$quarantine_tmp")"
  if command -v shasum >/dev/null 2>&1; then
    quarantine_generation_sha="$(yq -o=json '.records // []' "$quarantine_tmp" 2>/dev/null | tr -d '\n' | shasum -a 256 | awk '{print $1}')"
  else
    quarantine_generation_sha="$(yq -o=json '.records // []' "$quarantine_tmp" 2>/dev/null | tr -d '\n' | sha256sum | awk '{print $1}')"
  fi
  if command -v shasum >/dev/null 2>&1; then
    input_digest="$(printf '%s\n%s\n%s\n' "$manifest_sha" "$registry_sha" "$quarantine_generation_sha" | shasum -a 256 | awk '{print $1}')"
  else
    input_digest="$(printf '%s\n%s\n%s\n' "$manifest_sha" "$registry_sha" "$quarantine_generation_sha" | sha256sum | awk '{print $1}')"
  fi
  GENERATION_ID="locality-${input_digest:0:12}"
  receipt_slug="$(receipt_timestamp_slug "$PUBLISHED_AT")"
  receipt_rel="$(locality_publication_receipt_rel "$receipt_slug" "$GENERATION_ID")"
  receipt_abs="$ROOT_DIR/$receipt_rel"
  receipt_id="locality-$receipt_slug-$GENERATION_ID"

  if [[ "$has_blocking" -eq 1 ]]; then
    write_locality_publication_receipt "$receipt_tmp" "$receipt_id" "$GENERATION_ID" "blocked" "$manifest_sha" "$registry_sha" "$quarantine_sha"
    mkdir -p "$(dirname "$QUARANTINE_STATE")" "$(dirname "$receipt_abs")"
    mv "$quarantine_tmp" "$QUARANTINE_STATE"
    mv "$receipt_tmp" "$receipt_abs"
    echo "[ERROR] locality publication blocked; quarantined invalid scope state" >&2
    exit 1
  fi

  local scope_id
  local published_scope_ids=()
  local published_active_scope_ids=()
  for scope_id in "${DECLARED_SCOPE_IDS[@]}"; do
    if is_scope_quarantined "$scope_id"; then
      continue
    fi
    published_scope_ids+=("$scope_id")
    if [[ "${SCOPE_STATUSES[$scope_id]}" == "active" ]]; then
      published_active_scope_ids+=("$scope_id")
    fi
    ensure_scope_continuity_scaffold "$scope_id"
  done

  PUBLICATION_STATUS="published"
  if [[ "${#QUARANTINE_RECORDS[@]}" -gt 0 ]]; then
    PUBLICATION_STATUS="published_with_quarantine"
  fi
  write_locality_publication_receipt "$receipt_tmp" "$receipt_id" "$GENERATION_ID" "$PUBLICATION_STATUS" "$manifest_sha" "$registry_sha" "$quarantine_sha"
  receipt_sha="$(hash_file "$receipt_tmp")"

  {
    printf 'schema_version: "octon-locality-effective-scopes-v2"\n'
    printf 'generator_version: "%s"\n' "$GENERATOR_VERSION"
    printf 'generation_id: "%s"\n' "$GENERATION_ID"
    printf 'published_at: "%s"\n' "$PUBLISHED_AT"
    printf 'publication_status: "%s"\n' "$PUBLICATION_STATUS"
    printf 'publication_receipt_path: "%s"\n' "$receipt_rel"
    printf 'invalidation_conditions:\n'
    printf '  - "locality-manifest-sha-changed"\n'
    printf '  - "locality-registry-sha-changed"\n'
    printf '  - "quarantine-state-changed"\n'
    printf '  - "scope-manifest-sha-changed"\n'
    printf 'resolution_mode: "single-active-scope"\n'
    printf 'source:\n'
    printf '  locality_manifest_path: ".octon/instance/locality/manifest.yml"\n'
    printf '  locality_manifest_sha256: "%s"\n' "$manifest_sha"
    printf '  locality_registry_path: ".octon/instance/locality/registry.yml"\n'
    printf '  locality_registry_sha256: "%s"\n' "$registry_sha"
    printf '  quarantine_path: ".octon/state/control/locality/quarantine.yml"\n'
    printf '  quarantine_sha256: "%s"\n' "$quarantine_sha"
    if [[ "${#published_active_scope_ids[@]}" -eq 0 ]]; then
      printf 'active_scope_ids: []\n'
    else
      printf 'active_scope_ids:\n'
      for scope_id in "${published_active_scope_ids[@]}"; do
        printf '  - "%s"\n' "$scope_id"
      done
    fi
    if [[ "${#published_scope_ids[@]}" -eq 0 ]]; then
      printf 'scopes: []\n'
    else
      printf 'scopes:\n'
      for scope_id in "${published_scope_ids[@]}"; do
        printf '  - scope_id: "%s"\n' "$scope_id"
        printf '    manifest_path: "%s"\n' "${SCOPE_MANIFEST_PATHS[$scope_id]}"
        printf '    display_name: "%s"\n' "${SCOPE_DISPLAY_NAMES[$scope_id]}"
        printf '    root_path: "%s"\n' "${SCOPE_ROOT_PATHS[$scope_id]}"
        printf '    owner: "%s"\n' "${SCOPE_OWNERS[$scope_id]}"
        printf '    status: "%s"\n' "${SCOPE_STATUSES[$scope_id]}"
        printf '    tech_tags: %s\n' "${SCOPE_TECH_TAGS[$scope_id]}"
        printf '    language_tags: %s\n' "${SCOPE_LANGUAGE_TAGS[$scope_id]}"
        printf '    include_globs: %s\n' "${SCOPE_INCLUDE_GLOBS[$scope_id]}"
        printf '    exclude_globs: %s\n' "${SCOPE_EXCLUDE_GLOBS[$scope_id]}"
        printf '    routing_hints: %s\n' "${SCOPE_ROUTING_HINTS[$scope_id]}"
        printf '    mission_defaults: %s\n' "${SCOPE_MISSION_DEFAULTS[$scope_id]}"
      done
    fi
  } >"$scopes_tmp"

  {
    printf 'schema_version: "octon-locality-artifact-map-v2"\n'
    printf 'generator_version: "%s"\n' "$GENERATOR_VERSION"
    printf 'generation_id: "%s"\n' "$GENERATION_ID"
    printf 'published_at: "%s"\n' "$PUBLISHED_AT"
    if [[ "${#published_scope_ids[@]}" -eq 0 ]]; then
      printf 'artifacts: []\n'
    else
      printf 'artifacts:\n'
      local idx=0 scope_id
      for scope_id in "${DECLARED_SCOPE_IDS[@]}"; do
        if is_scope_quarantined "$scope_id"; then
          idx=$((idx + 1))
          continue
        fi
        printf '  - scope_id: "%s"\n' "$scope_id"
        printf '    registry_entry: ".octon/instance/locality/registry.yml#/scopes/%d"\n' "$idx"
        printf '    manifest_path: "%s"\n' "${SCOPE_MANIFEST_PATHS[$scope_id]}"
        printf '    manifest_sha256: "%s"\n' "${SCOPE_MANIFEST_DIGESTS[$scope_id]}"
        idx=$((idx + 1))
      done
    fi
  } >"$artifact_map_tmp"

  {
    printf 'schema_version: "octon-locality-generation-lock-v2"\n'
    printf 'generator_version: "%s"\n' "$GENERATOR_VERSION"
    printf 'generation_id: "%s"\n' "$GENERATION_ID"
    printf 'published_at: "%s"\n' "$PUBLISHED_AT"
    printf 'publication_status: "%s"\n' "$PUBLICATION_STATUS"
    printf 'publication_receipt_path: "%s"\n' "$receipt_rel"
    printf 'publication_receipt_sha256: "%s"\n' "$receipt_sha"
    printf 'locality_manifest_sha256: "%s"\n' "$manifest_sha"
    printf 'locality_registry_sha256: "%s"\n' "$registry_sha"
    printf 'quarantine_sha256: "%s"\n' "$quarantine_sha"
    printf 'published_files:\n'
    printf '  - path: ".octon/generated/effective/locality/scopes.effective.yml"\n'
    printf '  - path: ".octon/generated/effective/locality/artifact-map.yml"\n'
    printf '  - path: ".octon/generated/effective/locality/generation.lock.yml"\n'
    printf 'required_inputs:\n'
    printf '  - ".octon/octon.yml"\n'
    printf '  - ".octon/instance/manifest.yml"\n'
    printf '  - ".octon/instance/locality/manifest.yml"\n'
    printf '  - ".octon/instance/locality/registry.yml"\n'
    for scope_id in "${DECLARED_SCOPE_IDS[@]}"; do
      printf '  - "%s"\n' "${SCOPE_MANIFEST_PATHS[$scope_id]}"
    done
    printf 'invalidation_conditions:\n'
    printf '  - "locality-manifest-sha-changed"\n'
    printf '  - "locality-registry-sha-changed"\n'
    printf '  - "quarantine-state-changed"\n'
    printf '  - "scope-manifest-sha-changed"\n'
    if [[ "${#published_scope_ids[@]}" -eq 0 ]]; then
      printf 'scope_manifest_digests: []\n'
    else
      printf 'scope_manifest_digests:\n'
      for scope_id in "${published_scope_ids[@]}"; do
        printf '  - scope_id: "%s"\n' "$scope_id"
        printf '    manifest_path: "%s"\n' "${SCOPE_MANIFEST_PATHS[$scope_id]}"
        printf '    sha256: "%s"\n' "${SCOPE_MANIFEST_DIGESTS[$scope_id]}"
        printf '    continuity_sha256: "%s"\n' "$(scope_continuity_digest "$scope_id")"
        printf '    decision_evidence_sha256: "%s"\n' "$(scope_decision_evidence_digest "$scope_id")"
      done
    fi
  } >"$lock_tmp"

  mkdir -p "$(dirname "$receipt_abs")"
  mv "$quarantine_tmp" "$QUARANTINE_STATE"
  mv "$receipt_tmp" "$receipt_abs"
  mv "$scopes_tmp" "$SCOPES_EFFECTIVE_FILE"
  mv "$artifact_map_tmp" "$ARTIFACT_MAP_FILE"
  mv "$lock_tmp" "$GENERATION_LOCK_FILE"
}

main "$@"
