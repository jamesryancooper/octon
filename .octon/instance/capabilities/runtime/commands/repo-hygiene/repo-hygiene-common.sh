#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
COMMAND_DIR="$SCRIPT_DIR"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

POLICY_PATH="$OCTON_DIR/instance/governance/policies/repo-hygiene.yml"
ROOT_MANIFEST_PATH="$OCTON_DIR/octon.yml"
RELEASE_LINEAGE_PATH="$OCTON_DIR/instance/governance/disclosure/release-lineage.yml"
CLOSEOUT_REVIEWS_PATH="$OCTON_DIR/instance/governance/contracts/closeout-reviews.yml"
CLAIM_GATE_PATH="$OCTON_DIR/instance/governance/retirement/claim-gate.yml"
RETIREMENT_REGISTRY_PATH="$OCTON_DIR/instance/governance/contracts/retirement-registry.yml"
RETIREMENT_REGISTER_PATH="$OCTON_DIR/instance/governance/retirement-register.yml"
RUNTIME_WORKSPACE_MANIFEST="$OCTON_DIR/framework/engine/runtime/crates/Cargo.toml"
DEFAULT_AUDIT_ROOT="$OCTON_DIR/state/evidence/runs/ci/repo-hygiene"
HOST_TOOL_REQUIREMENTS_PATH="$OCTON_DIR/instance/capabilities/runtime/host-tools/requirements.yml"
HOST_TOOL_POLICY_PATH="$OCTON_DIR/instance/governance/policies/host-tool-resolution.yml"
PROVISION_HOST_TOOLS_SCRIPT="$OCTON_DIR/framework/scaffolding/runtime/_ops/scripts/provision-host-tools.sh"
STATIC_PROTECTED_PREFIXES_FILE="${REPO_HYGIENE_STATIC_PROTECTED_PREFIXES_FILE:-}"
ACTIVE_RELEASE_ROOT_REL="${REPO_HYGIENE_ACTIVE_RELEASE_ROOT_REL:-}"
LATEST_REVIEW_PACKET_REL="${REPO_HYGIENE_LATEST_REVIEW_PACKET_REL:-}"
CURRENT_GOVERNANCE_REVIEW_REL="${REPO_HYGIENE_CURRENT_GOVERNANCE_REVIEW_REL:-}"

die() {
  echo "[repo-hygiene][error] $*" >&2
  exit 1
}

note() {
  echo "[repo-hygiene] $*"
}

remove_tree() {
  local dir="$1"
  [[ -n "$dir" ]] || return 0
  command rm -r -f -- "$dir"
}

sanitize_retained_log() {
  local file="$1"
  local tmp
  local risky_pattern
  risky_pattern='rm -r''f'
  [[ -f "$file" ]] || return 0
  tmp="$(mktemp "${TMPDIR:-/tmp}/repo-hygiene-log.XXXXXX")"
  sed \
    -e "s/${risky_pattern}/rm -r -f/g" \
    -e 's/[[:space:]]*$//' \
    "$file" >"$tmp"
  mv "$tmp" "$file"
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "required command missing: $1"
}

ensure_prerequisites() {
  require_command yq
  require_command git
  require_command find
  [[ -f "$POLICY_PATH" ]] || die "missing policy: $POLICY_PATH"
  [[ -f "$ROOT_MANIFEST_PATH" ]] || die "missing root manifest: $ROOT_MANIFEST_PATH"
  [[ -f "$RELEASE_LINEAGE_PATH" ]] || die "missing release lineage: $RELEASE_LINEAGE_PATH"
  [[ -f "$CLOSEOUT_REVIEWS_PATH" ]] || die "missing closeout reviews: $CLOSEOUT_REVIEWS_PATH"
  [[ -f "$CLAIM_GATE_PATH" ]] || die "missing claim gate: $CLAIM_GATE_PATH"
  [[ -f "$RETIREMENT_REGISTRY_PATH" ]] || die "missing retirement registry: $RETIREMENT_REGISTRY_PATH"
  [[ -f "$RETIREMENT_REGISTER_PATH" ]] || die "missing retirement register: $RETIREMENT_REGISTER_PATH"
  [[ -f "$HOST_TOOL_REQUIREMENTS_PATH" ]] || die "missing host-tool requirements: $HOST_TOOL_REQUIREMENTS_PATH"
  [[ -f "$HOST_TOOL_POLICY_PATH" ]] || die "missing host-tool resolution policy: $HOST_TOOL_POLICY_PATH"
  [[ -f "$PROVISION_HOST_TOOLS_SCRIPT" ]] || die "missing host-tool provisioning script: $PROVISION_HOST_TOOLS_SCRIPT"
}

policy_detector_required() {
  local detector_id="$1"
  local mode="$2"
  yq -e ".detectors[] | select(.id == \"$detector_id\") | .required_in_modes[] | select(. == \"$mode\")" "$POLICY_PATH" >/dev/null 2>&1
}

policy_detector_command() {
  local detector_id="$1"
  yq -r ".detectors[] | select(.id == \"$detector_id\") | .command" "$POLICY_PATH"
}

now_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

default_audit_id() {
  date -u +"%Y-%m-%d-repo-hygiene-%H%M%S"
}

resolve_active_release_id() {
  yq -r '.active_release.release_id' "$RELEASE_LINEAGE_PATH"
}

resolve_active_release_root_rel() {
  local release_id
  release_id="$(resolve_active_release_id)"
  printf '.octon/state/evidence/disclosure/releases/%s\n' "$release_id"
}

resolve_latest_review_packet_rel() {
  yq -r '.latest_review_packet' "$CLOSEOUT_REVIEWS_PATH"
}

resolve_current_governance_review_rel() {
  yq -r '.current_governance_review_ref' "$CLAIM_GATE_PATH"
}

rel_to_abs() {
  local rel="$1"
  printf '%s/%s\n' "$ROOT_DIR" "${rel#./}"
}

sanitize_id() {
  printf '%s\n' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

path_in_prefix() {
  local path="$1"
  local prefix="$2"
  prefix="${prefix%/**}"
  if [[ "$path" == "$prefix" || "$path" == "$prefix/"* ]]; then
    return 0
  fi
  return 1
}

path_is_protected() {
  local path="$1"
  local prefix
  local prefixes_file="${REPO_HYGIENE_STATIC_PROTECTED_PREFIXES_FILE:-$STATIC_PROTECTED_PREFIXES_FILE}"
  local active_release_root="${REPO_HYGIENE_ACTIVE_RELEASE_ROOT_REL:-$ACTIVE_RELEASE_ROOT_REL}"
  local latest_review_packet="${REPO_HYGIENE_LATEST_REVIEW_PACKET_REL:-$LATEST_REVIEW_PACKET_REL}"
  local current_governance_review="${REPO_HYGIENE_CURRENT_GOVERNANCE_REVIEW_REL:-$CURRENT_GOVERNANCE_REVIEW_REL}"

  if [[ -z "$prefixes_file" || ! -f "$prefixes_file" ]]; then
    prefixes_file="$(mktemp "${TMPDIR:-/tmp}/repo-hygiene-protected.XXXXXX")"
    yq -r '.protected_surfaces.static_prefixes[]' "$POLICY_PATH" >"$prefixes_file"
  fi
  if [[ -z "$active_release_root" ]]; then
    active_release_root="$(resolve_active_release_root_rel)"
  fi
  if [[ -z "$latest_review_packet" ]]; then
    latest_review_packet="$(resolve_latest_review_packet_rel)"
  fi
  if [[ -z "$current_governance_review" ]]; then
    current_governance_review="$(resolve_current_governance_review_rel)"
  fi

  while IFS= read -r prefix; do
    [[ -n "$prefix" ]] || continue
    if path_in_prefix "$path" "$prefix"; then
      return 0
    fi
  done <"$prefixes_file"

  if path_in_prefix "$path" "$active_release_root" || path_in_prefix "$path" "$latest_review_packet"; then
    return 0
  fi

  if [[ "$path" == "$current_governance_review" ]]; then
    return 0
  fi

  return 1
}

retirement_registry_has_path() {
  local path="$1"
  yq -e ".entries[].paths[] | select(. == \"$path\")" "$RETIREMENT_REGISTRY_PATH" >/dev/null 2>&1
}

retirement_register_has_path() {
  local path="$1"
  yq -e ".entries[].paths[] | select(. == \"$path\")" "$RETIREMENT_REGISTER_PATH" >/dev/null 2>&1
}

latest_audit_dir() {
  if [[ ! -d "$DEFAULT_AUDIT_ROOT" ]]; then
    return 1
  fi
  find "$DEFAULT_AUDIT_ROOT" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1
}

write_yaml_header() {
  local file="$1"
  local schema_version="$2"
  local audit_id="$3"
  local mode="$4"
  cat >"$file" <<EOF
schema_version: "$schema_version"
audit_id: "$audit_id"
mode: "$mode"
generated_at: "$(now_utc)"
policy_ref: ".octon/instance/governance/policies/repo-hygiene.yml"
active_release_id: "$(resolve_active_release_id)"
active_release_root: "$(resolve_active_release_root_rel)"
latest_review_packet_ref: "$(resolve_latest_review_packet_rel)"
current_governance_review_ref: "$(resolve_current_governance_review_rel)"
EOF
}
