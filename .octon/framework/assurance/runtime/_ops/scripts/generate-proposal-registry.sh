#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

REGISTRY_PATH="$ROOT_DIR/.octon/generated/proposals/registry.yml"
SCHEMA_PATH="$ROOT_DIR/.octon/framework/cognition/_meta/architecture/generated/proposals/schemas/proposal-registry.schema.json"
BASE_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh"

MODE=""
errors=0
GENERATOR_ACTIVE_VAR="OCTON_PROPOSAL_REGISTRY_GENERATOR_ACTIVE"
SKIP_SUBTYPE_VALIDATION_VAR="OCTON_PROPOSAL_REGISTRY_SKIP_SUBTYPE_VALIDATION"
PROJECTION_ONLY_VAR="OCTON_PROPOSAL_REGISTRY_PROJECTION_ONLY"

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

warn() {
  echo "[WARN] $1"
}

pass() {
  echo "[OK] $1"
}

usage() {
  cat <<'EOF'
usage:
  generate-proposal-registry.sh --write
  generate-proposal-registry.sh --check

environment:
  OCTON_PROPOSAL_REGISTRY_PROJECTION_ONLY=1
    Regenerate the derived registry from proposal manifests without running
    full per-packet validators for every historical proposal. This mode still
    parses manifests, enforces registry-critical identity/path/status/archive
    fields, detects duplicate proposal keys, renders the canonical registry,
    and validates generated YAML.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --write)
      MODE="write"
      ;;
    --check)
      MODE="check"
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

[[ -n "$MODE" ]] || {
  usage >&2
  exit 2
}

if [[ "${!GENERATOR_ACTIVE_VAR:-}" == "1" ]]; then
  pass "nested proposal registry generation skipped during registry validation"
  echo "Registry generation summary: errors=0"
  exit 0
fi
export "$GENERATOR_ACTIVE_VAR=1"

rel_path() {
  local path="$1"
  if [[ "$path" == "$ROOT_DIR" ]]; then
    printf '.\n'
  else
    printf '%s\n' "${path#$ROOT_DIR/}"
  fi
}

yaml_string() {
  local file="$1"
  local query="$2"
  yq -r "$query // \"\"" "$file"
}

yaml_quote() {
  python3 - "$1" <<'PY'
import json
import sys
print(json.dumps(sys.argv[1]))
PY
}

digest_file() {
  local file="$1"
  shasum -a 256 "$file" | awk '{print "sha256:" $1}'
}

emit_refresh_receipt() {
  local generated_registry="$1"
  local manifest_list="$2"
  local refresh_status="$3"
  local next_owning_route="$4"
  local output_digest current_digest manifest proposal_rel

  output_digest="$(digest_file "$generated_registry")"
  if [[ -f "$REGISTRY_PATH" ]]; then
    current_digest="$(digest_file "$REGISTRY_PATH")"
  else
    current_digest="missing"
  fi

  printf 'refresh_receipt:\n'
  printf '  schema_version: "generated-metadata-refresh-receipt-v1"\n'
  printf '  owning_generator: ".octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh"\n'
  printf '  owning_route: "proposal-registry-generator"\n'
  printf '  mode: %s\n' "$(yaml_quote "$MODE")"
  printf '  refresh_status: %s\n' "$(yaml_quote "$refresh_status")"
  printf '  output_ref: ".octon/generated/proposals/registry.yml"\n'
  printf '  expected_output_digest: %s\n' "$(yaml_quote "$output_digest")"
  printf '  current_output_digest: %s\n' "$(yaml_quote "$current_digest")"
  printf '  generated_output_authority: "derived-only"\n'
  printf '  non_authority_classification: "generated-output-non-authority"\n'
  printf '  next_owning_route: %s\n' "$(yaml_quote "$next_owning_route")"
  printf '  source_refs:\n'
  while IFS= read -r manifest; do
    [[ -n "$manifest" && -f "$manifest" ]] || continue
    proposal_rel="$(rel_path "$manifest")"
    printf '    - ref: %s\n' "$(yaml_quote "$proposal_rel")"
    printf '      sha256: %s\n' "$(yaml_quote "$(digest_file "$manifest")")"
  done <"$manifest_list"
}

python3_with_yaml() {
  local override="${OCTON_PYTHON3_WITH_YAML:-}"
  local candidate
  if [[ -n "$override" ]]; then
    if "$override" - <<'PY' >/dev/null 2>&1
import yaml  # noqa: F401
PY
    then
      printf '%s\n' "$override"
      return 0
    fi
  fi

  while IFS= read -r candidate; do
    [[ -n "$candidate" ]] || continue
    if "$candidate" - <<'PY' >/dev/null 2>&1
import yaml  # noqa: F401
PY
    then
      printf '%s\n' "$candidate"
      return 0
    fi
  done < <(type -P -a python3 2>/dev/null || true)
  return 1
}

value_in() {
  local value="$1"
  shift
  local allowed
  for allowed in "$@"; do
    [[ "$value" == "$allowed" ]] && return 0
  done
  return 1
}

validate_projection_manifest() {
  local manifest="$1"
  local proposal_rel="$2"
  local proposal_id kind scope status path_mode target_count archived_from_status disposition local_errors=0

  if ! yq -e '.' "$manifest" >/dev/null 2>&1; then
    fail "projection-only proposal '$proposal_rel' manifest parses as YAML"
    return 1
  fi
  pass "projection-only proposal '$proposal_rel' manifest parses as YAML"

  proposal_id="$(yaml_string "$manifest" '.proposal_id')"
  kind="$(yaml_string "$manifest" '.proposal_kind')"
  scope="$(yaml_string "$manifest" '.promotion_scope')"
  status="$(yaml_string "$manifest" '.status')"
  path_mode="invalid"

  if [[ "$proposal_id" =~ ^[a-z][a-z0-9-]*$ ]]; then
    pass "projection-only proposal '$proposal_rel' proposal_id matches format"
  else
    fail "projection-only proposal '$proposal_rel' proposal_id matches format"
    local_errors=$((local_errors + 1))
  fi
  if value_in "$kind" design migration policy architecture; then
    pass "projection-only proposal '$proposal_rel' kind valid"
  else
    fail "projection-only proposal '$proposal_rel' kind valid"
    local_errors=$((local_errors + 1))
  fi
  if value_in "$scope" octon-internal repo-local; then
    pass "projection-only proposal '$proposal_rel' scope valid"
  else
    fail "projection-only proposal '$proposal_rel' scope valid"
    local_errors=$((local_errors + 1))
  fi
  if value_in "$status" draft in-review accepted implemented rejected archived; then
    pass "projection-only proposal '$proposal_rel' status valid"
  else
    fail "projection-only proposal '$proposal_rel' status valid"
    local_errors=$((local_errors + 1))
  fi

  case "$proposal_rel" in
    .octon/inputs/exploratory/proposals/.archive/$kind/$proposal_id)
      pass "projection-only proposal '$proposal_rel' archived path matches kind/id"
      path_mode="archived"
      ;;
    .octon/inputs/exploratory/proposals/$kind/$proposal_id)
      pass "projection-only proposal '$proposal_rel' active path matches kind/id"
      path_mode="active"
      ;;
    *)
      fail "projection-only proposal '$proposal_rel' lives in a valid proposal path"
      local_errors=$((local_errors + 1))
      ;;
  esac

  target_count="$(yq -r '.promotion_targets | length' "$manifest")" || target_count=0
  if [[ "$target_count" =~ ^[1-9][0-9]*$ ]]; then
    pass "projection-only proposal '$proposal_rel' promotion_targets present"
  else
    fail "projection-only proposal '$proposal_rel' promotion_targets present"
    local_errors=$((local_errors + 1))
  fi

  if [[ "$status" == "archived" ]]; then
    if [[ "$path_mode" == "archived" ]]; then
      pass "projection-only proposal '$proposal_rel' archived proposals stay in archive paths"
    else
      fail "projection-only proposal '$proposal_rel' archived proposals stay in archive paths"
      local_errors=$((local_errors + 1))
    fi
    if [[ -n "$(yaml_string "$manifest" '.archive.archived_at')" ]]; then
      pass "projection-only proposal '$proposal_rel' archive metadata present"
    else
      fail "projection-only proposal '$proposal_rel' archive metadata present"
      local_errors=$((local_errors + 1))
    fi
    archived_from_status="$(yaml_string "$manifest" '.archive.archived_from_status')"
    if value_in "$archived_from_status" draft in-review accepted implemented rejected legacy-unknown; then
      pass "projection-only proposal '$proposal_rel' archived_from_status valid"
    else
      fail "projection-only proposal '$proposal_rel' archived_from_status valid"
      local_errors=$((local_errors + 1))
    fi
    disposition="$(yaml_string "$manifest" '.archive.disposition')"
    if value_in "$disposition" implemented rejected historical superseded; then
      pass "projection-only proposal '$proposal_rel' archive disposition valid"
    else
      fail "projection-only proposal '$proposal_rel' archive disposition valid"
      local_errors=$((local_errors + 1))
    fi
    if [[ -n "$(yaml_string "$manifest" '.archive.original_path')" ]]; then
      pass "projection-only proposal '$proposal_rel' archive original_path present"
    else
      fail "projection-only proposal '$proposal_rel' archive original_path present"
      local_errors=$((local_errors + 1))
    fi
    if [[ "$disposition" == "implemented" || "$disposition" == "superseded" ]]; then
      target_count="$(yq -r '.archive.promotion_evidence | length' "$manifest")" || target_count=0
      if [[ "$target_count" =~ ^[1-9][0-9]*$ ]]; then
        pass "projection-only proposal '$proposal_rel' $disposition archive keeps promotion evidence"
      else
        fail "projection-only proposal '$proposal_rel' $disposition archive keeps promotion evidence"
        local_errors=$((local_errors + 1))
      fi
    fi
  else
    if [[ "$path_mode" == "active" ]]; then
      pass "projection-only proposal '$proposal_rel' active proposals stay in active paths"
    else
      fail "projection-only proposal '$proposal_rel' active proposals stay in active paths"
      local_errors=$((local_errors + 1))
    fi
    if yq -e 'has("archive")' "$manifest" >/dev/null 2>&1; then
      fail "projection-only proposal '$proposal_rel' non-archived proposal must not contain archive block"
      local_errors=$((local_errors + 1))
    else
      pass "projection-only proposal '$proposal_rel' non-archived proposal omits archive block"
    fi
  fi

  [[ "$local_errors" -eq 0 ]]
}

subtype_validator_for_kind() {
  case "$1" in
    design)
      printf '%s\n' "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-design-proposal.sh"
      ;;
    migration)
      printf '%s\n' "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-migration-proposal.sh"
      ;;
    policy)
      printf '%s\n' "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-policy-proposal.sh"
      ;;
    architecture)
      printf '%s\n' "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh"
      ;;
    *)
      return 1
      ;;
  esac
}

only_missing_historical_supersession_evidence_errors() {
  local output="$1"
  local line saw_error=0

  while IFS= read -r line; do
    [[ "$line" == "[ERROR]"* ]] || continue
    saw_error=1
    case "$line" in
      *" superseded archive evidence path must exist: "*)
        ;;
      *)
        return 1
        ;;
    esac
  done <<<"$output"

  [[ "$saw_error" -eq 1 ]]
}

allow_historical_supersession_evidence_drift() {
  local manifest="$1"
  local output="$2"

  [[ "$(yaml_string "$manifest" '.status')" == "archived" ]] || return 1
  [[ "$(yaml_string "$manifest" '.archive.disposition')" == "superseded" ]] || return 1
  only_missing_historical_supersession_evidence_errors "$output"
}

emit_target_lines() {
  local manifest="$1"
  local indent="$2"
  local prefix targets
  prefix="$(printf '%*s' "$indent" '')"
  targets="$(yq -r '.promotion_targets[]?' "$manifest")" || return 1
  [[ -n "$targets" ]] || return 0
  while IFS= read -r target; do
    [[ -n "$target" ]] || continue
    printf '%s- %s\n' "$prefix" "$(yaml_quote "$target")"
  done <<<"$targets"
}

write_manifest_list() {
  local manifest_list="$1"
  local git_root
  git_root="$(git -C "$ROOT_DIR" rev-parse --show-toplevel 2>/dev/null || true)"
  if [[ -n "$git_root" && "$(cd -- "$git_root" && pwd)" == "$ROOT_DIR" ]]; then
    git -C "$ROOT_DIR" ls-files --cached --others --exclude-standard -- .octon/inputs/exploratory/proposals \
      | while IFS= read -r rel; do
        [[ -f "$ROOT_DIR/$rel" ]] || continue
        case "$rel" in
          */proposal.yml)
            printf '%s/%s\n' "$ROOT_DIR" "$rel"
            ;;
        esac
      done \
      | sort >"$manifest_list"
    pass "proposal manifest discovery uses git-visible corpus"
  else
    find "$ROOT_DIR/.octon/inputs/exploratory/proposals" -name proposal.yml -type f | sort >"$manifest_list"
    pass "proposal manifest discovery uses filesystem fallback"
  fi
}

validate_package() {
  local proposal_dir="$1"
  local proposal_rel="$2"
  local manifest="$proposal_dir/proposal.yml"
  local kind status archived_from_status validator validation_output

  kind="$(yaml_string "$manifest" '.proposal_kind')"
  status="$(yaml_string "$manifest" '.status')"
  archived_from_status="$(yaml_string "$manifest" '.archive.archived_from_status')"
  if [[ "$kind" == "design" \
    && "$status" == "archived" \
    && "$proposal_rel" == .octon/inputs/exploratory/proposals/.archive/design/* \
    && "$archived_from_status" == "legacy-unknown" ]]; then
    pass "legacy-unknown design import excluded from main registry projection: $proposal_rel"
    return 0
  fi
  if [[ "${!PROJECTION_ONLY_VAR:-}" == "1" ]]; then
    if ! validate_projection_manifest "$manifest" "$proposal_rel"; then
      return 1
    fi
    pass "proposal packet full validation skipped for projection-only registry recovery: $proposal_rel"
  else
    if ! validation_output="$(env "$GENERATOR_ACTIVE_VAR=1" bash "$BASE_VALIDATOR" --package "$proposal_rel" --skip-registry-check 2>&1)"; then
      printf '%s\n' "$validation_output"
      if allow_historical_supersession_evidence_drift "$manifest" "$validation_output"; then
        warn "superseded archive evidence path is missing during registry projection; preserving historical projection entry: $proposal_rel"
        pass "proposal packet validation tolerated historical supersession evidence drift: $proposal_rel"
      else
        fail "proposal packet validates without registry recursion: $proposal_rel"
        return 1
      fi
    else
      printf '%s\n' "$validation_output"
      pass "proposal packet validates without registry recursion: $proposal_rel"
    fi
  fi

  if [[ "$status" == "archived" ]]; then
    pass "archived proposal subtype validation skipped for registry projection: $proposal_rel"
    return 0
  fi

  if [[ "${!SKIP_SUBTYPE_VALIDATION_VAR:-}" == "1" || "${!PROJECTION_ONLY_VAR:-}" == "1" ]]; then
    pass "active proposal subtype validation skipped for projection-only registry recovery: $proposal_rel"
    return 0
  fi

  validator="$(subtype_validator_for_kind "$kind")" || {
    fail "subtype validator exists for proposal kind '$kind' ($proposal_rel)"
    return 1
  }

  if ! env "$GENERATOR_ACTIVE_VAR=1" bash "$validator" --package "$proposal_rel"; then
    fail "subtype validator passes for $proposal_rel"
    return 1
  fi
  pass "subtype validator passes for $proposal_rel"
}

render_registry() {
  local output_file="$1"
  local tmp_dir="$2"
  local active_dir="$tmp_dir/active"
  local archived_dir="$tmp_dir/archived"
  local active_fragments archived_fragments fragment

  active_fragments="$tmp_dir/active-fragments.list"
  archived_fragments="$tmp_dir/archived-fragments.list"
  find "$active_dir" -type f | sort >"$active_fragments"
  find "$archived_dir" -type f | sort >"$archived_fragments"

  {
    printf 'schema_version: "proposal-registry-v1"\n\n'
    if [[ -s "$active_fragments" ]]; then
      printf 'active:\n'
      while IFS= read -r fragment; do
        cat "$fragment"
      done <"$active_fragments"
    else
      printf 'active: []\n'
    fi

    if [[ -s "$archived_fragments" ]]; then
      printf 'archived:\n'
      while IFS= read -r fragment; do
        cat "$fragment"
      done <"$archived_fragments"
    else
      printf 'archived: []\n'
    fi
  } >"$output_file"
}

run_projection_only_fast_path() {
  local python_with_yaml
  python_with_yaml="$(python3_with_yaml || true)"
  if [[ -z "$python_with_yaml" ]]; then
    fail "python yaml module is required for proposal registry projection recovery"
    echo "Registry generation summary: errors=$errors"
    return 1
  fi

  "$python_with_yaml" - "$MODE" "$ROOT_DIR" "$REGISTRY_PATH" "$SCHEMA_PATH" <<'PY'
import difflib
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

import yaml

mode, root_arg, registry_arg, schema_arg = sys.argv[1:5]
root = Path(root_arg)
registry_path = Path(registry_arg)
schema_path = Path(schema_arg)
errors = 0


class ProjectionLoader(yaml.SafeLoader):
    pass


for resolver_key, resolvers in list(ProjectionLoader.yaml_implicit_resolvers.items()):
    ProjectionLoader.yaml_implicit_resolvers[resolver_key] = [
        resolver
        for resolver in resolvers
        if resolver[0] != "tag:yaml.org,2002:timestamp"
    ]


def fail(message: str) -> None:
    global errors
    print(f"[ERROR] {message}")
    errors += 1


def ok(message: str) -> None:
    print(f"[OK] {message}")


def rel(path: Path) -> str:
    try:
        return path.resolve().relative_to(root.resolve()).as_posix()
    except ValueError:
        return path.as_posix()


def sha256_path(path: Path) -> str:
    return "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()


def scalar(data, dotted: str) -> str:
    value = data
    for part in dotted.split("."):
        if not isinstance(value, dict) or part not in value:
            return ""
        value = value[part]
    if value is None:
        return ""
    if isinstance(value, (dict, list)):
        return ""
    return str(value)


def sequence(data, dotted: str) -> list[str]:
    value = data
    for part in dotted.split("."):
        if not isinstance(value, dict) or part not in value:
            return []
        value = value[part]
    if isinstance(value, list):
        return [str(item) for item in value if item is not None and str(item) != ""]
    return []


def quoted(value: str) -> str:
    return json.dumps(value)


def discover_manifests() -> list[Path]:
    git_root = subprocess.run(
        ["git", "-C", str(root), "rev-parse", "--show-toplevel"],
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
    )
    if git_root.returncode == 0 and Path(git_root.stdout.strip()).resolve() == root.resolve():
        listing = subprocess.run(
            [
                "git",
                "-C",
                str(root),
                "ls-files",
                "--cached",
                "--others",
                "--exclude-standard",
                "--",
                ".octon/inputs/exploratory/proposals",
            ],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        manifests = [
            root / line
            for line in listing.stdout.splitlines()
            if line.endswith("/proposal.yml") and (root / line).is_file()
        ]
        ok("proposal manifest discovery uses git-visible corpus")
    else:
        proposals_root = root / ".octon/inputs/exploratory/proposals"
        manifests = sorted(proposals_root.rglob("proposal.yml")) if proposals_root.is_dir() else []
        ok("proposal manifest discovery uses filesystem fallback")
    return sorted(manifests)


def validate_manifest(data, proposal_rel: str) -> bool:
    local_errors = 0
    proposal_id = scalar(data, "proposal_id")
    kind = scalar(data, "proposal_kind")
    scope = scalar(data, "promotion_scope")
    status = scalar(data, "status")
    path_mode = "invalid"

    def local_fail(message: str) -> None:
        nonlocal local_errors
        fail(message)
        local_errors += 1

    if re.match(r"^[a-z][a-z0-9-]*$", proposal_id):
        ok(f"projection-only proposal '{proposal_rel}' proposal_id matches format")
    else:
        local_fail(f"projection-only proposal '{proposal_rel}' proposal_id matches format")

    if kind in {"design", "migration", "policy", "architecture"}:
        ok(f"projection-only proposal '{proposal_rel}' kind valid")
    else:
        local_fail(f"projection-only proposal '{proposal_rel}' kind valid")

    if scope in {"octon-internal", "repo-local"}:
        ok(f"projection-only proposal '{proposal_rel}' scope valid")
    else:
        local_fail(f"projection-only proposal '{proposal_rel}' scope valid")

    if status in {"draft", "in-review", "accepted", "implemented", "rejected", "archived"}:
        ok(f"projection-only proposal '{proposal_rel}' status valid")
    else:
        local_fail(f"projection-only proposal '{proposal_rel}' status valid")

    archived_path = f".octon/inputs/exploratory/proposals/.archive/{kind}/{proposal_id}"
    active_path = f".octon/inputs/exploratory/proposals/{kind}/{proposal_id}"
    if proposal_rel == archived_path:
        ok(f"projection-only proposal '{proposal_rel}' archived path matches kind/id")
        path_mode = "archived"
    elif proposal_rel == active_path:
        ok(f"projection-only proposal '{proposal_rel}' active path matches kind/id")
        path_mode = "active"
    else:
        local_fail(f"projection-only proposal '{proposal_rel}' lives in a valid proposal path")

    if sequence(data, "promotion_targets"):
        ok(f"projection-only proposal '{proposal_rel}' promotion_targets present")
    else:
        local_fail(f"projection-only proposal '{proposal_rel}' promotion_targets present")

    if status == "archived":
        if path_mode == "archived":
            ok(f"projection-only proposal '{proposal_rel}' archived proposals stay in archive paths")
        else:
            local_fail(f"projection-only proposal '{proposal_rel}' archived proposals stay in archive paths")
        if scalar(data, "archive.archived_at"):
            ok(f"projection-only proposal '{proposal_rel}' archive metadata present")
        else:
            local_fail(f"projection-only proposal '{proposal_rel}' archive metadata present")
        archived_from_status = scalar(data, "archive.archived_from_status")
        if archived_from_status in {
            "draft",
            "in-review",
            "accepted",
            "implemented",
            "rejected",
            "legacy-unknown",
        }:
            ok(f"projection-only proposal '{proposal_rel}' archived_from_status valid")
        else:
            local_fail(f"projection-only proposal '{proposal_rel}' archived_from_status valid")
        disposition = scalar(data, "archive.disposition")
        if disposition in {"implemented", "rejected", "historical", "superseded"}:
            ok(f"projection-only proposal '{proposal_rel}' archive disposition valid")
        else:
            local_fail(f"projection-only proposal '{proposal_rel}' archive disposition valid")
        if scalar(data, "archive.original_path"):
            ok(f"projection-only proposal '{proposal_rel}' archive original_path present")
        else:
            local_fail(f"projection-only proposal '{proposal_rel}' archive original_path present")
        if disposition in {"implemented", "superseded"}:
            if sequence(data, "archive.promotion_evidence"):
                ok(f"projection-only proposal '{proposal_rel}' {disposition} archive keeps promotion evidence")
            else:
                local_fail(f"projection-only proposal '{proposal_rel}' {disposition} archive keeps promotion evidence")
    else:
        if path_mode == "active":
            ok(f"projection-only proposal '{proposal_rel}' active proposals stay in active paths")
        else:
            local_fail(f"projection-only proposal '{proposal_rel}' active proposals stay in active paths")
        if isinstance(data, dict) and "archive" in data:
            local_fail(f"projection-only proposal '{proposal_rel}' non-archived proposal must not contain archive block")
        else:
            ok(f"projection-only proposal '{proposal_rel}' non-archived proposal omits archive block")

    return local_errors == 0


ok("projection-only proposal registry fast path used")
if schema_path.is_file():
    ok("proposal registry schema exists")
    try:
        yaml.load(schema_path.read_text(), Loader=ProjectionLoader)
        ok("proposal registry schema parses as JSON")
    except Exception:
        fail("proposal registry schema parses as JSON")
else:
    fail("proposal registry schema exists")

active: list[dict[str, object]] = []
archived: list[dict[str, object]] = []
seen: dict[str, str] = {}
manifest_paths = discover_manifests()

for manifest in manifest_paths:
    proposal_rel = rel(manifest.parent)
    try:
        data = yaml.load(manifest.read_text(), Loader=ProjectionLoader) or {}
        if not isinstance(data, dict):
            raise TypeError("manifest root is not a mapping")
        ok(f"projection-only proposal '{proposal_rel}' manifest parses as YAML")
    except Exception:
        fail(f"projection-only proposal '{proposal_rel}' manifest parses as YAML")
        continue

    if not validate_manifest(data, proposal_rel):
        continue
    ok(f"proposal packet full validation skipped for projection-only registry recovery: {proposal_rel}")

    kind = scalar(data, "proposal_kind")
    proposal_id = scalar(data, "proposal_id")
    status = scalar(data, "status")
    archived_from_status = scalar(data, "archive.archived_from_status")

    if (
        kind == "design"
        and status == "archived"
        and proposal_rel.startswith(".octon/inputs/exploratory/proposals/.archive/design/")
        and archived_from_status == "legacy-unknown"
    ):
        ok(f"legacy-unknown design import excluded from main registry projection: {proposal_rel}")
        continue

    ok(
        "archived proposal subtype validation skipped for registry projection: "
        + proposal_rel
        if status == "archived"
        else "active proposal subtype validation skipped for projection-only registry recovery: "
        + proposal_rel
    )

    key = f"{kind}:{proposal_id}"
    if key in seen:
        fail(f"duplicate proposal key '{key}' across {seen[key]} and {proposal_rel}")
        continue
    seen[key] = proposal_rel

    common = {
        "id": proposal_id,
        "kind": kind,
        "scope": scalar(data, "promotion_scope"),
        "path": proposal_rel,
        "title": scalar(data, "title"),
        "status": status,
        "promotion_targets": sequence(data, "promotion_targets"),
    }
    if status == "archived":
        common.update(
            {
                "status": "archived",
                "disposition": scalar(data, "archive.disposition"),
                "archived_at": scalar(data, "archive.archived_at"),
                "archived_from_status": archived_from_status,
                "original_path": scalar(data, "archive.original_path"),
            }
        )
        archived.append(common)
    else:
        active.append(common)


def render_item(item: dict[str, object], archived_item: bool) -> list[str]:
    lines = [
        f"  - id: {quoted(item['id'])}",
        f"    kind: {quoted(item['kind'])}",
        f"    scope: {quoted(item['scope'])}",
        f"    path: {quoted(item['path'])}",
        f"    title: {quoted(item['title'])}",
    ]
    if archived_item:
        lines.extend(
            [
                '    status: "archived"',
                f"    disposition: {quoted(item['disposition'])}",
                f"    archived_at: {quoted(item['archived_at'])}",
                f"    archived_from_status: {quoted(item['archived_from_status'])}",
                f"    original_path: {quoted(item['original_path'])}",
            ]
        )
    else:
        lines.append(f"    status: {quoted(item['status'])}")
    lines.append("    promotion_targets:")
    lines.extend(f"      - {quoted(target)}" for target in item["promotion_targets"])
    return lines


def fragment_sort_key(item: dict[str, object]) -> str:
    return f"{item['kind']}__{item['id']}.yml"


lines = ['schema_version: "proposal-registry-v1"', ""]
if active:
    lines.append("active:")
    for item in sorted(active, key=fragment_sort_key):
        lines.extend(render_item(item, False))
else:
    lines.append("active: []")
if archived:
    lines.append("archived:")
    for item in sorted(archived, key=fragment_sort_key):
        lines.extend(render_item(item, True))
else:
    lines.append("archived: []")
generated = "\n".join(lines) + "\n"

try:
    yaml.load(generated, Loader=ProjectionLoader)
    ok("generated proposal registry parses as YAML")
except Exception:
    fail("generated proposal registry parses as YAML")

if errors:
    print(f"Registry generation summary: errors={errors}")
    sys.exit(1)

if mode == "check":
    refresh_status = "fresh"
    next_owning_route = "none"
    if not registry_path.is_file():
        fail("proposal registry exists at .octon/generated/proposals/registry.yml")
        refresh_status = "missing-output"
        next_owning_route = "generate-proposal-registry.sh --write"
    else:
        current = registry_path.read_text()
        if current == generated:
            ok("proposal registry matches generated projection")
        else:
            fail("proposal registry matches generated projection")
            refresh_status = "stale-output"
            next_owning_route = "generate-proposal-registry.sh --write"
            sys.stdout.writelines(
                difflib.unified_diff(
                    current.splitlines(keepends=True),
                    generated.splitlines(keepends=True),
                    fromfile=str(registry_path),
                    tofile="generated-registry.yml",
                )
            )
else:
    refresh_status = "fresh"
    next_owning_route = "none"
    registry_path.parent.mkdir(parents=True, exist_ok=True)
    if registry_path.is_file() and registry_path.read_text() == generated:
        ok("proposal registry already matches generated projection")
    else:
        tmp = registry_path.with_suffix(registry_path.suffix + ".tmp")
        tmp.write_text(generated)
        shutil.move(str(tmp), str(registry_path))
        ok("proposal registry written from manifest projection")
        refresh_status = "written"

current_digest = sha256_path(registry_path) if registry_path.is_file() else "missing"
expected_digest = "sha256:" + hashlib.sha256(generated.encode()).hexdigest()
print("refresh_receipt:")
print('  schema_version: "generated-metadata-refresh-receipt-v1"')
print('  owning_generator: ".octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh"')
print('  owning_route: "proposal-registry-generator"')
print(f"  mode: {json.dumps(mode)}")
print(f"  refresh_status: {json.dumps(refresh_status)}")
print('  output_ref: ".octon/generated/proposals/registry.yml"')
print(f"  expected_output_digest: {json.dumps(expected_digest)}")
print(f"  current_output_digest: {json.dumps(current_digest)}")
print('  generated_output_authority: "derived-only"')
print('  non_authority_classification: "generated-output-non-authority"')
print(f"  next_owning_route: {json.dumps(next_owning_route)}")
print("  source_refs:")
for manifest in manifest_paths:
    if manifest.is_file():
        print(f"    - ref: {json.dumps(rel(manifest))}")
        print(f"      sha256: {json.dumps(sha256_path(manifest))}")

print(f"Registry generation summary: errors={errors}")
sys.exit(0 if errors == 0 else 1)
PY
}

main() {
  local tmp_dir generated_registry seen_file manifest_list

  if [[ "${!PROJECTION_ONLY_VAR:-}" == "1" ]]; then
    run_projection_only_fast_path
    return $?
  fi

  if [[ -f "$SCHEMA_PATH" ]]; then
    pass "proposal registry schema exists"
    if yq -e '.' "$SCHEMA_PATH" >/dev/null 2>&1; then
      pass "proposal registry schema parses as JSON"
    else
      fail "proposal registry schema parses as JSON"
    fi
  else
    fail "proposal registry schema exists"
  fi

  tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/proposal-registry.XXXXXX")"
  trap '[[ -n "${tmp_dir:-}" && -d "${tmp_dir:-}" ]] && rm -r "$tmp_dir"' EXIT
  mkdir -p "$tmp_dir/active" "$tmp_dir/archived"
  seen_file="$tmp_dir/seen.tsv"
  manifest_list="$tmp_dir/manifests.list"
  : >"$seen_file"
  write_manifest_list "$manifest_list"

  while IFS= read -r manifest; do
    [[ -n "$manifest" ]] || continue

    local proposal_dir proposal_rel kind proposal_id scope title status key fragment archived_at archived_from_status disposition original_path previous_seen
    proposal_dir="$(dirname "$manifest")"
    proposal_rel="$(rel_path "$proposal_dir")"

    if ! validate_package "$proposal_dir" "$proposal_rel"; then
      continue
    fi

    kind="$(yaml_string "$manifest" '.proposal_kind')"
    proposal_id="$(yaml_string "$manifest" '.proposal_id')"
    scope="$(yaml_string "$manifest" '.promotion_scope')"
    title="$(yaml_string "$manifest" '.title')"
    status="$(yaml_string "$manifest" '.status')"
    archived_from_status="$(yaml_string "$manifest" '.archive.archived_from_status')"
    key="${kind}:${proposal_id}"

    if [[ "$kind" == "design" \
      && "$status" == "archived" \
      && "$proposal_rel" == .octon/inputs/exploratory/proposals/.archive/design/* \
      && "$archived_from_status" == "legacy-unknown" ]]; then
      pass "legacy-unknown design import excluded from main registry projection: $proposal_rel"
      continue
    fi

    previous_seen="$(awk -F '\t' -v key="$key" '$1 == key {print $2; exit}' "$seen_file")"
    if [[ -n "$previous_seen" ]]; then
      fail "duplicate proposal key '${key}' across $previous_seen and $proposal_rel"
      continue
    fi
    printf '%s\t%s\n' "$key" "$proposal_rel" >>"$seen_file"

    if [[ "$status" == "archived" ]]; then
      fragment="$tmp_dir/archived/${kind}__${proposal_id}.yml"
      archived_at="$(yaml_string "$manifest" '.archive.archived_at')"
      disposition="$(yaml_string "$manifest" '.archive.disposition')"
      original_path="$(yaml_string "$manifest" '.archive.original_path')"
      {
        printf '  - id: %s\n' "$(yaml_quote "$proposal_id")"
        printf '    kind: %s\n' "$(yaml_quote "$kind")"
        printf '    scope: %s\n' "$(yaml_quote "$scope")"
        printf '    path: %s\n' "$(yaml_quote "$proposal_rel")"
        printf '    title: %s\n' "$(yaml_quote "$title")"
        printf '    status: "archived"\n'
        printf '    disposition: %s\n' "$(yaml_quote "$disposition")"
        printf '    archived_at: %s\n' "$(yaml_quote "$archived_at")"
        printf '    archived_from_status: %s\n' "$(yaml_quote "$archived_from_status")"
        printf '    original_path: %s\n' "$(yaml_quote "$original_path")"
        printf '    promotion_targets:\n'
        emit_target_lines "$manifest" 6
      } >"$fragment"
    else
      fragment="$tmp_dir/active/${kind}__${proposal_id}.yml"
      {
        printf '  - id: %s\n' "$(yaml_quote "$proposal_id")"
        printf '    kind: %s\n' "$(yaml_quote "$kind")"
        printf '    scope: %s\n' "$(yaml_quote "$scope")"
        printf '    path: %s\n' "$(yaml_quote "$proposal_rel")"
        printf '    title: %s\n' "$(yaml_quote "$title")"
        printf '    status: %s\n' "$(yaml_quote "$status")"
        printf '    promotion_targets:\n'
        emit_target_lines "$manifest" 6
      } >"$fragment"
    fi
  done <"$manifest_list"

  generated_registry="$tmp_dir/registry.yml"
  render_registry "$generated_registry" "$tmp_dir"

  if yq -e '.' "$generated_registry" >/dev/null 2>&1; then
    pass "generated proposal registry parses as YAML"
  else
    fail "generated proposal registry parses as YAML"
  fi

  if [[ $errors -gt 0 ]]; then
    echo "Registry generation summary: errors=$errors"
    exit 1
  fi

  refresh_status="fresh"
  next_owning_route="none"
  if [[ "$MODE" == "check" ]]; then
    if [[ ! -f "$REGISTRY_PATH" ]]; then
      fail "proposal registry exists at .octon/generated/proposals/registry.yml"
      refresh_status="missing-output"
      next_owning_route="generate-proposal-registry.sh --write"
    elif cmp -s "$generated_registry" "$REGISTRY_PATH"; then
      pass "proposal registry matches generated projection"
    else
      fail "proposal registry matches generated projection"
      refresh_status="stale-output"
      next_owning_route="generate-proposal-registry.sh --write"
      diff -u "$REGISTRY_PATH" "$generated_registry" || true
    fi
  else
    mkdir -p "$(dirname "$REGISTRY_PATH")"
    if [[ -f "$REGISTRY_PATH" ]] && cmp -s "$generated_registry" "$REGISTRY_PATH"; then
      pass "proposal registry already matches generated projection"
      refresh_status="fresh"
    else
      cp "$generated_registry" "$REGISTRY_PATH"
      pass "proposal registry written from manifest projection"
      refresh_status="written"
    fi
  fi

  emit_refresh_receipt "$generated_registry" "$manifest_list" "$refresh_status" "$next_owning_route"
  echo "Registry generation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
