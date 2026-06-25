#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
source "$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/extensions-common.sh"

ROUTING_FILE="$OCTON_DIR/generated/effective/capabilities/routing.effective.yml"
ARTIFACT_MAP_FILE="$OCTON_DIR/generated/effective/capabilities/artifact-map.yml"
EXTENSIONS_CATALOG="$OCTON_DIR/generated/effective/extensions/catalog.effective.yml"
HOSTS=(claude cursor codex)
EXTENSION_PUBLISHED_PREFIX=".octon/generated/effective/extensions/published/"
errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

if [[ "${OCTON_HOST_PROJECTIONS_LEGACY:-0}" != "1" ]]; then
  PYTHON_WITH_YAML="$(ext_python3_with_yaml || true)"
  if [[ -z "$PYTHON_WITH_YAML" ]]; then
    echo "[ERROR] python yaml module is required for host projection validation"
    exit 1
  fi
  set +e
  "$PYTHON_WITH_YAML" - "$ROOT_DIR" "$ROUTING_FILE" "$ARTIFACT_MAP_FILE" "$EXTENSIONS_CATALOG" <<'PY'
import hashlib
import os
import sys
from pathlib import Path

import yaml

ROOT_DIR = Path(sys.argv[1])
ROUTING_FILE = Path(sys.argv[2])
ARTIFACT_MAP_FILE = Path(sys.argv[3])
EXTENSIONS_CATALOG = Path(sys.argv[4])
HOSTS = ("claude", "cursor", "codex")
EXTENSION_PUBLISHED_PREFIX = ".octon/generated/effective/extensions/published/"


def load_yaml(path):
    with path.open("r", encoding="utf-8") as handle:
        return yaml.safe_load(handle) or {}


def rel(path):
    try:
        return str(path.relative_to(ROOT_DIR))
    except ValueError:
        return str(path)


def file_sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def command_title(path):
    with path.open("r", encoding="utf-8") as handle:
        for line in handle:
            if line.startswith("# "):
                return line[2:].strip()
    return ""


def operator_family(pack_id):
    return "octon-proposal" if pack_id == "octon-proposal-lifecycle" else pack_id


def is_extension_root_or_composite_command(artifact, capability_id):
    if artifact.get("source_kind") != "extension-export":
        return False
    pack_id = artifact.get("extension_pack_id") or ""
    return capability_id in {pack_id, operator_family(pack_id)}


def source_path_for(artifact, kind, capability_id, catalog):
    source_kind = artifact.get("source_kind")
    source_path = artifact.get("source_path") or ""
    if source_kind == "extension-export":
        pack_id = artifact.get("extension_pack_id")
        source_id = artifact.get("extension_source_id")
        for pack in catalog.get("packs") or []:
            if pack.get("pack_id") != pack_id or pack.get("source_id") != source_id:
                continue
            exports = ((pack.get("routing_exports") or {}).get(f"{kind}s") or [])
            for export in exports:
                if export.get("capability_id") == capability_id:
                    projected = export.get("projection_source_path") or ""
                    if not projected.startswith(EXTENSION_PUBLISHED_PREFIX):
                        return "", f"extension projection source must resolve to compiled publication output for {artifact.get('effective_id')}"
                    return projected, None
        return "", f"missing projection source path for {artifact.get('effective_id')}"
    if kind == "skill":
        return str(Path(source_path).parent), None
    return source_path, None


def file_list(root):
    return sorted(
        str(path.relative_to(root))
        for path in root.rglob("*")
        if path.is_file() and not path.is_symlink()
    )


def tree_has_symlink(root):
    return any(path.is_symlink() for path in root.rglob("*"))


def host_projection_read_only(host):
    host_root = ROOT_DIR / f".{host}"
    for kind in ("commands", "skills"):
        projection_dir = host_root / kind
        if projection_dir.exists() and not os.access(projection_dir, os.W_OK):
            return True
        if not projection_dir.exists() and host_root.exists() and not os.access(host_root, os.W_OK):
            return True
    return False


def validate():
    routing = load_yaml(ROUTING_FILE)
    artifact_map = load_yaml(ARTIFACT_MAP_FILE)
    catalog = load_yaml(EXTENSIONS_CATALOG)
    artifacts = {
        artifact.get("effective_id"): artifact
        for artifact in artifact_map.get("artifacts") or []
        if artifact.get("effective_id")
    }
    errors = []
    passes = []

    for host in HOSTS:
        if host_projection_read_only(host):
            passes.append(f"read-only host projection skipped as non-controlling: .{host}")
            continue
        for kind in ("command", "skill"):
            projection_dir = ROOT_DIR / f".{host}" / f"{kind}s"
            expected_names = []
            if projection_dir.is_dir():
                passes.append(f"host projection directory exists: {rel(projection_dir)}")
            else:
                errors.append(f"missing host projection directory: {rel(projection_dir)}")
                continue
            if tree_has_symlink(projection_dir):
                errors.append(f"host projection directory must not contain symlinks: {rel(projection_dir)}")
            else:
                passes.append(f"host projection directory contains no symlinks: {rel(projection_dir)}")

            rows = []
            for candidate in routing.get("routing_candidates") or []:
                if candidate.get("status") != "active":
                    continue
                if candidate.get("capability_kind") != kind:
                    continue
                if host not in (candidate.get("host_adapters") or []):
                    continue
                rows.append((candidate.get("effective_id") or "", candidate.get("capability_id") or ""))

            for effective_id, capability_id in sorted(rows):
                if not effective_id or not capability_id:
                    continue
                artifact = artifacts.get(effective_id)
                if artifact is None:
                    errors.append(f"missing artifact map entry for {effective_id}")
                    continue
                source_rel, source_error = source_path_for(artifact, kind, capability_id, catalog)
                if source_error:
                    errors.append(source_error)
                    continue
                if not source_rel:
                    errors.append(f"missing projection source path for {effective_id}")
                    continue
                source_abs = ROOT_DIR / source_rel
                if kind == "command":
                    expected_names.append(f"{capability_id}.md")
                    projected_path = projection_dir / f"{capability_id}.md"
                    if not projected_path.is_file():
                        errors.append(f"missing projected command: {rel(projected_path)}")
                        continue
                    passes.append(f"projected command exists: {rel(projected_path)}")
                    if not source_abs.is_file():
                        errors.append(f"projection source command missing: {source_rel}")
                        continue
                    if file_sha256(projected_path) == file_sha256(source_abs):
                        passes.append(f"projected command hash matches source: {rel(projected_path)}")
                    else:
                        errors.append(f"projected command hash differs from source: {rel(projected_path)}")
                    title = command_title(projected_path)
                    if title and len(title) <= 64:
                        passes.append(f"projected command title is concise: {rel(projected_path)}")
                    else:
                        errors.append(f"projected command title must be present and <=64 characters: {rel(projected_path)}")
                    if title.startswith("Octon ") and not is_extension_root_or_composite_command(artifact, capability_id):
                        errors.append(f"projected command title repeats redundant Octon namespace: {rel(projected_path)}")
                    else:
                        passes.append(f"projected command title namespace usage is allowed: {rel(projected_path)}")
                else:
                    expected_names.append(capability_id)
                    projected_path = projection_dir / capability_id
                    if not projected_path.is_dir():
                        errors.append(f"missing projected skill directory: {rel(projected_path)}")
                        continue
                    passes.append(f"projected skill directory exists: {rel(projected_path)}")
                    if (projected_path / "SKILL.md").is_file():
                        passes.append(f"projected skill includes SKILL.md: {rel(projected_path / 'SKILL.md')}")
                    else:
                        errors.append(f"projected skill missing SKILL.md: {rel(projected_path / 'SKILL.md')}")
                    if not source_abs.is_dir():
                        errors.append(f"projection source skill directory missing: {source_rel}")
                        continue
                    projected_files = file_list(projected_path)
                    source_files = file_list(source_abs)
                    if projected_files == source_files:
                        passes.append(f"projected skill file list matches source: {rel(projected_path)}")
                    else:
                        errors.append(f"projected skill file list differs from source: {rel(projected_path)}")
                    for item in source_files:
                        if item in projected_files and file_sha256(projected_path / item) == file_sha256(source_abs / item):
                            passes.append(f"projected skill file hash matches source: {rel(projected_path)}/{item}")
                        else:
                            errors.append(f"projected skill file hash differs from source: {rel(projected_path)}/{item}")

            existing_names = sorted(path.name for path in projection_dir.iterdir())
            if existing_names == sorted(expected_names):
                passes.append(f"host projection set matches routing for {rel(projection_dir)}")
            else:
                errors.append(f"host projection set differs from routing for {rel(projection_dir)}")

    for message in passes:
        print(f"[OK] {message}")
    for message in errors:
        print(f"[ERROR] {message}")
    print(f"Validation summary: errors={len(errors)}")
    return 0 if not errors else 1


sys.exit(validate())
PY
  rc=$?
  set -e
  exit "$rc"
fi

hash_file() {
  local file="$1"
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
  else
    sha256sum "$file" | awk '{print $1}'
  fi
}

command_title() {
  awk '/^# / { sub(/^# /, ""); print; exit }' "$1"
}

expected_projection_rows() {
  local host="$1"
  local kind="$2"
  yq -r ".routing_candidates[]? | select(.status == \"active\") | select(.capability_kind == \"$kind\") | select((.host_adapters // []) | contains([\"$host\"])) | [.effective_id, .capability_id] | @tsv" "$ROUTING_FILE" 2>/dev/null || true
}

artifact_field_for_effective_id() {
  local effective_id="$1"
  local query="$2"
  yq -r ".artifacts[]? | select(.effective_id == \"$effective_id\") | $query // \"\"" "$ARTIFACT_MAP_FILE" | head -n 1
}

extension_projection_source_path() {
  local pack_id="$1"
  local source_id="$2"
  local kind="$3"
  local capability_id="$4"
  yq -r ".packs[]? | select(.pack_id == \"$pack_id\" and .source_id == \"$source_id\") | .routing_exports.${kind}s[]? | select(.capability_id == \"$capability_id\") | .projection_source_path // \"\"" "$EXTENSIONS_CATALOG" | head -n 1
}

is_extension_root_or_composite_command() {
  local effective_id="$1" capability_id="$2"
  local source_kind pack_id operator_family

  source_kind="$(artifact_field_for_effective_id "$effective_id" '.source_kind')"
  [[ "$source_kind" == "extension-export" ]] || return 1

  pack_id="$(artifact_field_for_effective_id "$effective_id" '.extension_pack_id')"
  operator_family="$(ext_command_operator_family_for_pack "$pack_id")"
  [[ "$capability_id" == "$pack_id" || "$capability_id" == "$operator_family" ]]
}

verify_compiled_extension_projection_path() {
  local effective_id="$1"
  local source_rel="$2"
  if [[ "$source_rel" == ${EXTENSION_PUBLISHED_PREFIX}* ]]; then
    return 0
  else
    fail "extension projection source must resolve to compiled publication output for $effective_id"
    return 1
  fi
}

projection_source_path() {
  local effective_id="$1"
  local kind="$2"
  local source_kind source_path pack_id source_id capability_id
  source_kind="$(artifact_field_for_effective_id "$effective_id" '.source_kind')"
  source_path="$(artifact_field_for_effective_id "$effective_id" '.source_path')"
  if [[ "$source_kind" == "extension-export" ]]; then
    pack_id="$(artifact_field_for_effective_id "$effective_id" '.extension_pack_id')"
    source_id="$(artifact_field_for_effective_id "$effective_id" '.extension_source_id')"
    capability_id="$(artifact_field_for_effective_id "$effective_id" '.capability_id')"
    source_path="$(extension_projection_source_path "$pack_id" "$source_id" "$kind" "$capability_id")"
    verify_compiled_extension_projection_path "$effective_id" "$source_path" || return 1
    printf '%s\n' "$source_path"
  elif [[ "$kind" == "skill" ]]; then
    dirname "$source_path"
  else
    printf '%s\n' "$source_path"
  fi
}

verify_no_symlinks() {
  local dir="$1"
  if find "$dir" -type l -print | grep -q .; then
    fail "host projection directory must not contain symlinks: ${dir#$ROOT_DIR/}"
  else
    pass "host projection directory contains no symlinks: ${dir#$ROOT_DIR/}"
  fi
}

compare_skill_dirs() {
  local projected_dir="$1"
  local source_dir="$2"
  local projected_list source_list rel
  projected_list="$(cd "$projected_dir" && find . -type f | LC_ALL=C sort)"
  source_list="$(cd "$source_dir" && find . -type f | LC_ALL=C sort)"
  if [[ "$projected_list" == "$source_list" ]]; then
    pass "projected skill file list matches source: ${projected_dir#$ROOT_DIR/}"
  else
    fail "projected skill file list differs from source: ${projected_dir#$ROOT_DIR/}"
  fi
  while IFS= read -r rel; do
    [[ -n "$rel" ]] || continue
    if [[ "$(hash_file "$projected_dir/$rel")" == "$(hash_file "$source_dir/$rel")" ]]; then
      pass "projected skill file hash matches source: ${projected_dir#$ROOT_DIR/}/$rel"
    else
      fail "projected skill file hash differs from source: ${projected_dir#$ROOT_DIR/}/$rel"
    fi
  done < <(cd "$source_dir" && find . -type f | LC_ALL=C sort)
}

validate_host_kind() {
  local host="$1"
  local kind="$2"
  local projection_dir="$ROOT_DIR/.${host}/${kind}s"
  local expected_names=()
  local existing_names
  local effective_id capability_id source_rel projected_path title

  if [[ -d "$projection_dir" ]]; then
    pass "host projection directory exists: ${projection_dir#$ROOT_DIR/}"
  else
    fail "missing host projection directory: ${projection_dir#$ROOT_DIR/}"
    return
  fi

  verify_no_symlinks "$projection_dir"

  while IFS=$'\t' read -r effective_id capability_id; do
    [[ -n "$effective_id" ]] || continue
    source_rel="$(projection_source_path "$effective_id" "$kind")"
    if [[ -z "$source_rel" ]]; then
      fail "missing projection source path for $effective_id"
      continue
    fi
    if [[ "$kind" == "command" ]]; then
      projected_path="$projection_dir/$capability_id.md"
      expected_names+=("$capability_id.md")
      if [[ -f "$projected_path" ]]; then
        pass "projected command exists: ${projected_path#$ROOT_DIR/}"
      else
        fail "missing projected command: ${projected_path#$ROOT_DIR/}"
        continue
      fi
      if [[ "$(hash_file "$projected_path")" == "$(hash_file "$ROOT_DIR/$source_rel")" ]]; then
        pass "projected command hash matches source: ${projected_path#$ROOT_DIR/}"
      else
        fail "projected command hash differs from source: ${projected_path#$ROOT_DIR/}"
      fi
      title="$(command_title "$projected_path")"
      if [[ -n "$title" && "${#title}" -le 64 ]]; then
        pass "projected command title is concise: ${projected_path#$ROOT_DIR/}"
      else
        fail "projected command title must be present and <=64 characters: ${projected_path#$ROOT_DIR/}"
      fi
      if [[ "$title" == "Octon "* ]] && ! is_extension_root_or_composite_command "$effective_id" "$capability_id"; then
        fail "projected command title repeats redundant Octon namespace: ${projected_path#$ROOT_DIR/}"
      else
        pass "projected command title namespace usage is allowed: ${projected_path#$ROOT_DIR/}"
      fi
    else
      projected_path="$projection_dir/$capability_id"
      expected_names+=("$capability_id")
      if [[ -d "$projected_path" ]]; then
        pass "projected skill directory exists: ${projected_path#$ROOT_DIR/}"
      else
        fail "missing projected skill directory: ${projected_path#$ROOT_DIR/}"
        continue
      fi
      if [[ -f "$projected_path/SKILL.md" ]]; then
        pass "projected skill includes SKILL.md: ${projected_path#$ROOT_DIR/}/SKILL.md"
      else
        fail "projected skill missing SKILL.md: ${projected_path#$ROOT_DIR/}/SKILL.md"
      fi
      compare_skill_dirs "$projected_path" "$ROOT_DIR/$source_rel"
    fi
  done < <(expected_projection_rows "$host" "$kind")

  existing_names="$(find "$projection_dir" -mindepth 1 -maxdepth 1 -exec basename {} \; | LC_ALL=C sort)"
  if [[ "$existing_names" == "$(printf '%s\n' "${expected_names[@]}" | awk 'NF' | LC_ALL=C sort)" ]]; then
    pass "host projection set matches routing for ${projection_dir#$ROOT_DIR/}"
  else
    fail "host projection set differs from routing for ${projection_dir#$ROOT_DIR/}"
  fi
}

main() {
  local host
  echo "== Host Projection Validation =="

  [[ -f "$ROUTING_FILE" ]] && pass "found file: ${ROUTING_FILE#$ROOT_DIR/}" || fail "missing file: ${ROUTING_FILE#$ROOT_DIR/}"
  [[ -f "$ARTIFACT_MAP_FILE" ]] && pass "found file: ${ARTIFACT_MAP_FILE#$ROOT_DIR/}" || fail "missing file: ${ARTIFACT_MAP_FILE#$ROOT_DIR/}"
  [[ -f "$EXTENSIONS_CATALOG" ]] && pass "found file: ${EXTENSIONS_CATALOG#$ROOT_DIR/}" || fail "missing file: ${EXTENSIONS_CATALOG#$ROOT_DIR/}"

  for host in "${HOSTS[@]}"; do
    validate_host_kind "$host" command
    validate_host_kind "$host" skill
  done

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
