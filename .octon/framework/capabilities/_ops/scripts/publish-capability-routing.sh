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
SERVICES_MANIFEST="$OCTON_DIR/framework/capabilities/runtime/services/manifest.yml"
TOOLS_MANIFEST="$OCTON_DIR/framework/capabilities/runtime/tools/manifest.yml"
EXTENSIONS_CATALOG="$OCTON_DIR/generated/effective/extensions/catalog.effective.yml"
INSTANCE_CAPABILITIES_DIR="$OCTON_DIR/instance/capabilities/runtime"
EFFECTIVE_DIR="$OCTON_DIR/generated/effective/capabilities"
ROUTING_FILE="$EFFECTIVE_DIR/routing.effective.yml"
ARTIFACT_MAP_FILE="$EFFECTIVE_DIR/artifact-map.yml"
GENERATION_LOCK_FILE="$EFFECTIVE_DIR/generation.lock.yml"

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

yaml_escape() {
  printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'
}

trim_trailing_slash() {
  local value="$1"
  value="${value%/}"
  printf '%s' "$value"
}

normalized_payload() {
  sed -E 's/^published_at: "[^"]*"/published_at: "__PUBLISHED_AT__"/'
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

  if [[ "$(normalized_payload < "$candidate_routing")" == "$(normalized_payload < "$ROUTING_FILE")" ]] \
    && [[ "$(normalized_payload < "$candidate_map")" == "$(normalized_payload < "$ARTIFACT_MAP_FILE")" ]] \
    && [[ "$(normalized_payload < "$candidate_lock")" == "$(normalized_payload < "$GENERATION_LOCK_FILE")" ]]; then
    printf '%s\n' "$current_published_at"
  else
    printf '%s\n' "$fallback"
  fi
}

instance_capabilities_digest() {
  local payload=""
  local file rel sha
  while IFS= read -r file; do
    [[ -n "$file" ]] || continue
    rel="${file#$ROOT_DIR/}"
    sha="$(hash_file "$file")"
    payload+="${rel} ${sha}"$'\n'
  done < <(instance_definition_files)
  printf '%s' "$payload" | hash_text
}

instance_definition_files() {
  {
    find "$OCTON_DIR/instance/capabilities/runtime/commands" -type f -name '*.md' ! -name 'README.md'
    find "$OCTON_DIR/instance/capabilities/runtime/skills" -type f -name 'SKILL.md'
  } 2>/dev/null | sort
}

extension_capability_input_digest() {
  local payload=""
  local commands_root skills_root file rel sha
  while IFS=$'\t' read -r commands_root skills_root; do
    [[ -n "$commands_root$skills_root" ]] || continue
    if [[ -n "$commands_root" && "$commands_root" != "null" && -d "$ROOT_DIR/$commands_root" ]]; then
      while IFS= read -r file; do
        [[ -n "$file" ]] || continue
        rel="${file#$ROOT_DIR/}"
        sha="$(hash_file "$file")"
        payload+="${rel} ${sha}"$'\n'
      done < <(find "$ROOT_DIR/$commands_root" -type f | sort)
    fi
    if [[ -n "$skills_root" && "$skills_root" != "null" && -d "$ROOT_DIR/$skills_root" ]]; then
      while IFS= read -r file; do
        [[ -n "$file" ]] || continue
        rel="${file#$ROOT_DIR/}"
        sha="$(hash_file "$file")"
        payload+="${rel} ${sha}"$'\n'
      done < <(find "$ROOT_DIR/$skills_root" -type f | sort)
    fi
  done < <(yq -r '.packs[]? | [.content_roots.commands // "", .content_roots.skills // ""] | @tsv' "$EXTENSIONS_CATALOG" 2>/dev/null || true)
  printf '%s' "$payload" | hash_text
}

write_candidates() {
  local outfile="$1"
  local tsv="$2"

  if [[ ! -s "$tsv" ]]; then
    printf 'routing_candidates: []\n' >>"$outfile"
    return
  fi

  printf 'routing_candidates:\n' >>"$outfile"
  while IFS=$'\t' read -r effective_id artifact_map_id origin_class capability_kind capability_id display_name summary status source_manifest interface_type; do
    printf '  - effective_id: "%s"\n' "$(yaml_escape "$effective_id")" >>"$outfile"
    printf '    artifact_map_id: "%s"\n' "$(yaml_escape "$artifact_map_id")" >>"$outfile"
    printf '    origin_class: "%s"\n' "$(yaml_escape "$origin_class")" >>"$outfile"
    printf '    capability_kind: "%s"\n' "$(yaml_escape "$capability_kind")" >>"$outfile"
    printf '    capability_id: "%s"\n' "$(yaml_escape "$capability_id")" >>"$outfile"
    printf '    display_name: "%s"\n' "$(yaml_escape "$display_name")" >>"$outfile"
    printf '    summary: "%s"\n' "$(yaml_escape "$summary")" >>"$outfile"
    printf '    status: "%s"\n' "$(yaml_escape "$status")" >>"$outfile"
    printf '    source_manifest: "%s"\n' "$(yaml_escape "$source_manifest")" >>"$outfile"
    if [[ -n "$interface_type" ]]; then
      printf '    interface_type: "%s"\n' "$(yaml_escape "$interface_type")" >>"$outfile"
    fi
  done <"$tsv"
}

write_artifact_map() {
  local outfile="$1"
  local tsv="$2"

  if [[ ! -s "$tsv" ]]; then
    printf 'artifacts: []\n' >>"$outfile"
    return
  fi

  printf 'artifacts:\n' >>"$outfile"
  while IFS=$'\t' read -r effective_id artifact_map_id origin_class capability_kind capability_id display_name summary status source_manifest source_path source_manifest_sha256 source_sha256 extension_pack_id extension_source_id extension_entry_path; do
    printf '  - artifact_map_id: "%s"\n' "$(yaml_escape "$artifact_map_id")" >>"$outfile"
    printf '    effective_id: "%s"\n' "$(yaml_escape "$effective_id")" >>"$outfile"
    printf '    origin_class: "%s"\n' "$(yaml_escape "$origin_class")" >>"$outfile"
    printf '    capability_kind: "%s"\n' "$(yaml_escape "$capability_kind")" >>"$outfile"
    printf '    capability_id: "%s"\n' "$(yaml_escape "$capability_id")" >>"$outfile"
    printf '    display_name: "%s"\n' "$(yaml_escape "$display_name")" >>"$outfile"
    printf '    source_manifest_path: "%s"\n' "$(yaml_escape "$source_manifest")" >>"$outfile"
    printf '    source_manifest_sha256: "%s"\n' "$source_manifest_sha256" >>"$outfile"
    printf '    source_path: "%s"\n' "$(yaml_escape "$source_path")" >>"$outfile"
    printf '    source_sha256: "%s"\n' "$source_sha256" >>"$outfile"
    if [[ -n "$extension_pack_id" ]]; then
      printf '    extension_pack_id: "%s"\n' "$(yaml_escape "$extension_pack_id")" >>"$outfile"
      printf '    extension_source_id: "%s"\n' "$(yaml_escape "$extension_source_id")" >>"$outfile"
      printf '    extension_entry_path: "%s"\n' "$(yaml_escape "$extension_entry_path")" >>"$outfile"
    fi
  done <"$tsv"
}

main() {
  local tmpdir="" routing_tmp artifact_tmp lock_tmp candidates_tmp artifacts_tmp
  local root_sha commands_sha skills_sha services_sha tools_sha extensions_sha instance_sha extension_inputs_sha
  local generator_version generation_seed generation_sha generation_id published_at
  local default_published_at source_path source_sha manifest_rel manifest_sha capability_path display_name summary access status interface_type effective_id artifact_map_id capability_id

  mkdir -p "$EFFECTIVE_DIR"
  tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/octon-capabilities.XXXXXX")"
  trap '[[ -n "${tmpdir:-}" ]] && rm -rf "$tmpdir"' EXIT
  routing_tmp="$tmpdir/routing.effective.yml"
  artifact_tmp="$tmpdir/artifact-map.yml"
  lock_tmp="$tmpdir/generation.lock.yml"
  candidates_tmp="$tmpdir/candidates.tsv"
  artifacts_tmp="$tmpdir/artifacts.tsv"

  generator_version="$(yq -r '.versioning.harness.release_version // ""' "$ROOT_MANIFEST")"
  root_sha="$(hash_file "$ROOT_MANIFEST")"
  commands_sha="$(hash_file "$COMMANDS_MANIFEST")"
  skills_sha="$(hash_file "$SKILLS_MANIFEST")"
  services_sha="$(hash_file "$SERVICES_MANIFEST")"
  tools_sha="$(hash_file "$TOOLS_MANIFEST")"
  extensions_sha="$(hash_file "$EXTENSIONS_CATALOG")"
  instance_sha="$(instance_capabilities_digest)"
  extension_inputs_sha="$(extension_capability_input_digest)"

  : >"$candidates_tmp"
  : >"$artifacts_tmp"

  while IFS=$'\t' read -r capability_id capability_path display_name summary access; do
    source_path=".octon/framework/capabilities/runtime/commands/${capability_path}"
    source_sha="$(hash_file "$ROOT_DIR/$source_path")"
    manifest_rel=".octon/framework/capabilities/runtime/commands/manifest.yml"
    manifest_sha="$commands_sha"
    effective_id="framework.command.${capability_id}"
    artifact_map_id="framework-command-${capability_id}"
    printf '%s\t%s\tframework\tcommand\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$effective_id" "$artifact_map_id" "$capability_id" "$display_name" "$summary" "active" "$manifest_rel" "" >>"$candidates_tmp"
    printf '%s\t%s\tframework\tcommand\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$effective_id" "$artifact_map_id" "$capability_id" "$display_name" "$summary" "active" "$manifest_rel" "$source_path" "$manifest_sha" "$source_sha" >>"$artifacts_tmp"
  done < <(yq -r '.commands[]? | [.id, .path, .display_name, .summary, .access] | @tsv' "$COMMANDS_MANIFEST")

  while IFS=$'\t' read -r capability_id capability_path display_name summary status; do
    capability_path="$(trim_trailing_slash "$capability_path")"
    source_path=".octon/framework/capabilities/runtime/skills/${capability_path}/SKILL.md"
    if [[ ! -f "$ROOT_DIR/$source_path" ]]; then
      source_path=".octon/framework/capabilities/runtime/skills/manifest.yml"
    fi
    source_sha="$(hash_file "$ROOT_DIR/$source_path")"
    manifest_rel=".octon/framework/capabilities/runtime/skills/manifest.yml"
    manifest_sha="$skills_sha"
    effective_id="framework.skill.${capability_id}"
    artifact_map_id="framework-skill-${capability_id}"
    printf '%s\t%s\tframework\tskill\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$effective_id" "$artifact_map_id" "$capability_id" "$display_name" "$summary" "$status" "$manifest_rel" "" >>"$candidates_tmp"
    printf '%s\t%s\tframework\tskill\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$effective_id" "$artifact_map_id" "$capability_id" "$display_name" "$summary" "$status" "$manifest_rel" "$source_path" "$manifest_sha" "$source_sha" >>"$artifacts_tmp"
  done < <(yq -r '.skills[]? | [.id, .path, .display_name, .summary, .status] | @tsv' "$SKILLS_MANIFEST")

  while IFS=$'\t' read -r capability_id capability_path display_name summary status interface_type; do
    capability_path="$(trim_trailing_slash "$capability_path")"
    source_path=".octon/framework/capabilities/runtime/services/${capability_path}/SERVICE.md"
    if [[ ! -f "$ROOT_DIR/$source_path" ]]; then
      source_path=".octon/framework/capabilities/runtime/services/manifest.yml"
    fi
    source_sha="$(hash_file "$ROOT_DIR/$source_path")"
    manifest_rel=".octon/framework/capabilities/runtime/services/manifest.yml"
    manifest_sha="$services_sha"
    effective_id="framework.service.${capability_id}"
    artifact_map_id="framework-service-${capability_id}"
    printf '%s\t%s\tframework\tservice\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$effective_id" "$artifact_map_id" "$capability_id" "$display_name" "$summary" "$status" "$manifest_rel" "$interface_type" >>"$candidates_tmp"
    printf '%s\t%s\tframework\tservice\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$effective_id" "$artifact_map_id" "$capability_id" "$display_name" "$summary" "$status" "$manifest_rel" "$source_path" "$manifest_sha" "$source_sha" >>"$artifacts_tmp"
  done < <(yq -r '.services[]? | [.id, .path, .display_name, .summary, .status, .interface_type] | @tsv' "$SERVICES_MANIFEST")

  while IFS=$'\t' read -r capability_id display_name summary; do
    source_path=".octon/framework/capabilities/runtime/tools/manifest.yml"
    source_sha="$tools_sha"
    manifest_rel=".octon/framework/capabilities/runtime/tools/manifest.yml"
    manifest_sha="$tools_sha"
    effective_id="framework.tool-pack.${capability_id}"
    artifact_map_id="framework-tool-pack-${capability_id}"
    printf '%s\t%s\tframework\ttool-pack\t%s\t%s\t%s\tactive\t%s\t%s\n' \
      "$effective_id" "$artifact_map_id" "$capability_id" "$display_name" "$summary" "$manifest_rel" "" >>"$candidates_tmp"
    printf '%s\t%s\tframework\ttool-pack\t%s\t%s\t%s\tactive\t%s\t%s\t%s\t%s\n' \
      "$effective_id" "$artifact_map_id" "$capability_id" "$display_name" "$summary" "$manifest_rel" "$source_path" "$manifest_sha" "$source_sha" >>"$artifacts_tmp"
  done < <(yq -r '.packs[]? | [.id, .display_name, .summary] | @tsv' "$TOOLS_MANIFEST")

  while IFS= read -r source_path; do
    [[ -n "$source_path" ]] || continue
    capability_id="$(basename "$source_path" .md)"
    display_name="$capability_id"
    summary="Repo-native command capability."
    source_sha="$(hash_file "$ROOT_DIR/$source_path")"
    manifest_rel=".octon/instance/capabilities/runtime/commands/README.md"
    manifest_sha="$instance_sha"
    effective_id="instance.command.${capability_id}"
    artifact_map_id="instance-command-${capability_id}"
    printf '%s\t%s\tinstance\tcommand\t%s\t%s\t%s\tactive\t%s\t%s\n' \
      "$effective_id" "$artifact_map_id" "$capability_id" "$display_name" "$summary" "$manifest_rel" "" >>"$candidates_tmp"
    printf '%s\t%s\tinstance\tcommand\t%s\t%s\t%s\tactive\t%s\t%s\t%s\t%s\n' \
      "$effective_id" "$artifact_map_id" "$capability_id" "$display_name" "$summary" "$manifest_rel" "$source_path" "$manifest_sha" "$source_sha" >>"$artifacts_tmp"
  done < <(find "$OCTON_DIR/instance/capabilities/runtime/commands" -type f -name '*.md' ! -name 'README.md' | sort | sed "s#^$ROOT_DIR/##")

  while IFS= read -r source_path; do
    [[ -n "$source_path" ]] || continue
    capability_id="$(basename "$(dirname "$source_path")")"
    display_name="$capability_id"
    summary="Repo-native skill capability."
    source_sha="$(hash_file "$ROOT_DIR/$source_path")"
    manifest_rel=".octon/instance/capabilities/runtime/skills/README.md"
    manifest_sha="$instance_sha"
    effective_id="instance.skill.${capability_id}"
    artifact_map_id="instance-skill-${capability_id}"
    printf '%s\t%s\tinstance\tskill\t%s\t%s\t%s\tactive\t%s\t%s\n' \
      "$effective_id" "$artifact_map_id" "$capability_id" "$display_name" "$summary" "$manifest_rel" "" >>"$candidates_tmp"
    printf '%s\t%s\tinstance\tskill\t%s\t%s\t%s\tactive\t%s\t%s\t%s\t%s\n' \
      "$effective_id" "$artifact_map_id" "$capability_id" "$display_name" "$summary" "$manifest_rel" "$source_path" "$manifest_sha" "$source_sha" >>"$artifacts_tmp"
  done < <(find "$OCTON_DIR/instance/capabilities/runtime/skills" -type f -name 'SKILL.md' | sort | sed "s#^$ROOT_DIR/##")

  while IFS=$'\t' read -r pack_id source_id commands_root; do
    [[ -n "$commands_root" && "$commands_root" != "null" ]] || continue
    [[ -f "$ROOT_DIR/$commands_root/manifest.fragment.yml" ]] || continue
    while IFS=$'\t' read -r capability_id capability_path display_name summary access; do
      [[ -n "$capability_id" ]] || continue
      source_path=".octon/generated/effective/extensions/catalog.effective.yml"
      source_sha="$extensions_sha"
      manifest_rel=".octon/generated/effective/extensions/catalog.effective.yml"
      manifest_sha="$extensions_sha"
      effective_id="extension.command.${pack_id}.${capability_id}"
      artifact_map_id="extension-command-${pack_id}-${capability_id}"
      printf '%s\t%s\textension\tcommand\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$effective_id" "$artifact_map_id" "$capability_id" "$display_name" "$summary" "active" "$manifest_rel" "" >>"$candidates_tmp"
      printf '%s\t%s\textension\tcommand\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$effective_id" "$artifact_map_id" "$capability_id" "$display_name" "$summary" "active" "$manifest_rel" "$source_path" "$manifest_sha" "$source_sha" "$pack_id" "$source_id" "commands/${capability_path}" >>"$artifacts_tmp"
    done < <(yq -r '.commands[]? | [.id, .path, .display_name, .summary, .access] | @tsv' "$ROOT_DIR/$commands_root/manifest.fragment.yml")
  done < <(yq -r '.packs[]? | [.pack_id, .source_id, .content_roots.commands // ""] | @tsv' "$EXTENSIONS_CATALOG" 2>/dev/null || true)

  while IFS=$'\t' read -r pack_id source_id skills_root; do
    [[ -n "$skills_root" && "$skills_root" != "null" ]] || continue
    [[ -f "$ROOT_DIR/$skills_root/manifest.fragment.yml" ]] || continue
    while IFS=$'\t' read -r capability_id capability_path display_name summary status; do
      [[ -n "$capability_id" ]] || continue
      source_path=".octon/generated/effective/extensions/catalog.effective.yml"
      source_sha="$extensions_sha"
      manifest_rel=".octon/generated/effective/extensions/catalog.effective.yml"
      manifest_sha="$extensions_sha"
      effective_id="extension.skill.${pack_id}.${capability_id}"
      artifact_map_id="extension-skill-${pack_id}-${capability_id}"
      printf '%s\t%s\textension\tskill\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$effective_id" "$artifact_map_id" "$capability_id" "$display_name" "$summary" "$status" "$manifest_rel" "" >>"$candidates_tmp"
      printf '%s\t%s\textension\tskill\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
        "$effective_id" "$artifact_map_id" "$capability_id" "$display_name" "$summary" "$status" "$manifest_rel" "$source_path" "$manifest_sha" "$source_sha" "$pack_id" "$source_id" "skills/${capability_path}SKILL.md" >>"$artifacts_tmp"
    done < <(yq -r '.skills[]? | [.id, .path, .display_name, .summary, .status] | @tsv' "$ROOT_DIR/$skills_root/manifest.fragment.yml")
  done < <(yq -r '.packs[]? | [.pack_id, .source_id, .content_roots.skills // ""] | @tsv' "$EXTENSIONS_CATALOG" 2>/dev/null || true)

  LC_ALL=C sort "$candidates_tmp" -o "$candidates_tmp"
  LC_ALL=C sort "$artifacts_tmp" -o "$artifacts_tmp"

  generation_seed="$(
    printf 'root %s\ncommands %s\nskills %s\nservices %s\ntools %s\ninstance %s\nextensions %s\n' \
      "$root_sha" "$commands_sha" "$skills_sha" "$services_sha" "$tools_sha" "$instance_sha" "$extensions_sha" "$extension_inputs_sha"
  )"
  generation_sha="$(printf '%s' "$generation_seed" | hash_text)"
  generation_id="capabilities-${generation_sha:0:12}"
  default_published_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

  {
    printf 'schema_version: "octon-capability-routing-effective-v1"\n'
    printf 'generator_version: "__GENERATOR_VERSION__"\n'
    printf 'generation_id: "%s"\n' "$generation_id"
    printf 'published_at: "__PUBLISHED_AT__"\n'
    printf 'publication_status: "published"\n'
    printf 'source:\n'
    printf '  root_manifest_path: ".octon/octon.yml"\n'
    printf '  root_manifest_sha256: "%s"\n' "$root_sha"
    printf '  framework_commands_manifest_path: ".octon/framework/capabilities/runtime/commands/manifest.yml"\n'
    printf '  framework_commands_manifest_sha256: "%s"\n' "$commands_sha"
    printf '  framework_skills_manifest_path: ".octon/framework/capabilities/runtime/skills/manifest.yml"\n'
    printf '  framework_skills_manifest_sha256: "%s"\n' "$skills_sha"
    printf '  framework_services_manifest_path: ".octon/framework/capabilities/runtime/services/manifest.yml"\n'
    printf '  framework_services_manifest_sha256: "%s"\n' "$services_sha"
    printf '  framework_tools_manifest_path: ".octon/framework/capabilities/runtime/tools/manifest.yml"\n'
    printf '  framework_tools_manifest_sha256: "%s"\n' "$tools_sha"
    printf '  instance_capabilities_path: ".octon/instance/capabilities/runtime"\n'
    printf '  instance_capabilities_sha256: "%s"\n' "$instance_sha"
    printf '  extensions_catalog_path: ".octon/generated/effective/extensions/catalog.effective.yml"\n'
    printf '  extensions_catalog_sha256: "%s"\n' "$extensions_sha"
    printf '  extensions_capability_inputs_sha256: "%s"\n' "$extension_inputs_sha"
    write_candidates "$routing_tmp" "$candidates_tmp"
  } >"$routing_tmp"

  {
    printf 'schema_version: "octon-capability-routing-artifact-map-v1"\n'
    printf 'generator_version: "__GENERATOR_VERSION__"\n'
    printf 'generation_id: "%s"\n' "$generation_id"
    printf 'published_at: "__PUBLISHED_AT__"\n'
    write_artifact_map "$artifact_tmp" "$artifacts_tmp"
  } >"$artifact_tmp"

  {
    printf 'schema_version: "octon-capability-routing-generation-lock-v1"\n'
    printf 'generator_version: "__GENERATOR_VERSION__"\n'
    printf 'generation_id: "%s"\n' "$generation_id"
    printf 'published_at: "__PUBLISHED_AT__"\n'
    printf 'root_manifest_sha256: "%s"\n' "$root_sha"
    printf 'framework_commands_manifest_sha256: "%s"\n' "$commands_sha"
    printf 'framework_skills_manifest_sha256: "%s"\n' "$skills_sha"
    printf 'framework_services_manifest_sha256: "%s"\n' "$services_sha"
    printf 'framework_tools_manifest_sha256: "%s"\n' "$tools_sha"
    printf 'instance_capabilities_sha256: "%s"\n' "$instance_sha"
    printf 'extensions_catalog_sha256: "%s"\n' "$extensions_sha"
    printf 'extensions_capability_inputs_sha256: "%s"\n' "$extension_inputs_sha"
    printf 'published_files:\n'
    printf '  - path: ".octon/generated/effective/capabilities/routing.effective.yml"\n'
    printf '  - path: ".octon/generated/effective/capabilities/artifact-map.yml"\n'
    printf '  - path: ".octon/generated/effective/capabilities/generation.lock.yml"\n'
  } >"$lock_tmp"

  published_at="$(maybe_reuse_published_at "$routing_tmp" "$artifact_tmp" "$lock_tmp" "$default_published_at")"

  sed -e "s|__GENERATOR_VERSION__|$generator_version|" -e "s|__PUBLISHED_AT__|$published_at|" "$routing_tmp" >"$ROUTING_FILE"
  sed -e "s|__GENERATOR_VERSION__|$generator_version|" -e "s|__PUBLISHED_AT__|$published_at|" "$artifact_tmp" >"$ARTIFACT_MAP_FILE"
  sed -e "s|__GENERATOR_VERSION__|$generator_version|" -e "s|__PUBLISHED_AT__|$published_at|" "$lock_tmp" >"$GENERATION_LOCK_FILE"

  echo "[OK] published capability routing: $generation_id"
}

main "$@"
