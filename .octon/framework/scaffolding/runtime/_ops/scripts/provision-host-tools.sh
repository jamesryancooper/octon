#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

REGISTRY_PATH_OVERRIDE="${OCTON_HOST_TOOL_REGISTRY_PATH_OVERRIDE:-}"
REQUIREMENTS_PATH_OVERRIDE="${OCTON_HOST_TOOL_REQUIREMENTS_PATH_OVERRIDE:-}"
POLICY_PATH_OVERRIDE="${OCTON_HOST_TOOL_RESOLUTION_POLICY_PATH_OVERRIDE:-}"

ACTION=""
REPO_ROOT="$ROOT_DIR"
CONSUMER=""
CONSUMER_MODE=""
TOOL_ID=""
OCTON_HOME_OVERRIDE=""
EMIT_ENV_PATH=""
ALLOW_PATH_ADOPTION_OVERRIDE=""
QUIET=0

timestamp_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

note() {
  if [[ "$QUIET" != "1" ]]; then
    echo "[host-tools] $*" >&2
  fi
}

die() {
  echo "[host-tools][error] $*" >&2
  exit 1
}

remove_tree() {
  local dir="$1"
  [[ -n "$dir" ]] || die "remove_tree requires a non-empty path"
  command rm -r -f -- "$dir"
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "required command missing: $1"
}

usage() {
  cat <<'EOF'
Usage:
  provision-host-tools.sh verify [--repo-root <path>] [--consumer <id>] [--mode <mode>] [--tool-id <id>] [--octon-home <path>] [--emit-env <path>] [--allow-path-adoption true|false]
  provision-host-tools.sh install [--repo-root <path>] [--consumer <id>] [--mode <mode>] [--tool-id <id>] [--octon-home <path>] [--emit-env <path>] [--allow-path-adoption true|false]
  provision-host-tools.sh repair [--repo-root <path>] [--consumer <id>] [--mode <mode>] [--tool-id <id>] [--octon-home <path>] [--emit-env <path>] [--allow-path-adoption true|false]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    verify|install|repair)
      ACTION="$1"
      shift
      ;;
    --repo-root)
      REPO_ROOT="$2"
      shift 2
      ;;
    --consumer)
      CONSUMER="$2"
      shift 2
      ;;
    --mode)
      CONSUMER_MODE="$2"
      shift 2
      ;;
    --tool-id)
      TOOL_ID="$2"
      shift 2
      ;;
    --octon-home)
      OCTON_HOME_OVERRIDE="$2"
      shift 2
      ;;
    --emit-env)
      EMIT_ENV_PATH="$2"
      shift 2
      ;;
    --allow-path-adoption)
      ALLOW_PATH_ADOPTION_OVERRIDE="$2"
      shift 2
      ;;
    --quiet)
      QUIET=1
      shift
      ;;
    *)
      usage >&2
      die "unknown argument: $1"
      ;;
  esac
done

[[ -n "$ACTION" ]] || {
  usage >&2
  exit 2
}

canonical_repo_root() {
  local raw="$1"
  if [[ "$raw" = /* ]]; then
    printf '%s\n' "$raw"
  else
    printf '%s/%s\n' "$ROOT_DIR" "$raw"
  fi
}

REPO_ROOT="$(canonical_repo_root "$REPO_ROOT")"

registry_path() {
  if [[ -n "$REGISTRY_PATH_OVERRIDE" ]]; then
    printf '%s\n' "$REGISTRY_PATH_OVERRIDE"
  else
    printf '%s/framework/capabilities/runtime/host-tools/registry.yml\n' "$OCTON_DIR"
  fi
}

requirements_path() {
  if [[ -n "$REQUIREMENTS_PATH_OVERRIDE" ]]; then
    printf '%s\n' "$REQUIREMENTS_PATH_OVERRIDE"
  else
    printf '%s/.octon/instance/capabilities/runtime/host-tools/requirements.yml\n' "$REPO_ROOT"
  fi
}

policy_path() {
  if [[ -n "$POLICY_PATH_OVERRIDE" ]]; then
    printf '%s\n' "$POLICY_PATH_OVERRIDE"
  else
    printf '%s/.octon/instance/governance/policies/host-tool-resolution.yml\n' "$REPO_ROOT"
  fi
}

REGISTRY_PATH="$(registry_path)"
REQUIREMENTS_PATH="$(requirements_path)"
POLICY_PATH="$(policy_path)"

require_command yq
require_command find
[[ -f "$REGISTRY_PATH" ]] || die "missing host-tool registry: $REGISTRY_PATH"
[[ -f "$POLICY_PATH" ]] || die "missing host-tool resolution policy: $POLICY_PATH"
[[ -f "$REQUIREMENTS_PATH" ]] || die "missing host-tool requirements: $REQUIREMENTS_PATH"

resolve_os() {
  case "$(uname -s)" in
    Darwin) printf 'darwin\n' ;;
    Linux) printf 'linux\n' ;;
    MINGW*|MSYS*|CYGWIN*) printf 'windows\n' ;;
    *)
      die "unsupported operating system: $(uname -s)"
      ;;
  esac
}

resolve_arch() {
  case "$(uname -m)" in
    arm64|aarch64) printf 'aarch64\n' ;;
    x86_64|amd64) printf 'x86_64\n' ;;
    *)
      die "unsupported architecture: $(uname -m)"
      ;;
  esac
}

PLATFORM_OS="$(resolve_os)"
PLATFORM_ARCH="$(resolve_arch)"
PLATFORM_KEY="${PLATFORM_OS}-${PLATFORM_ARCH}"

default_octon_home() {
  case "$PLATFORM_OS" in
    darwin)
      printf '%s/Library/Application Support/Octon\n' "$HOME"
      ;;
    linux)
      printf '%s/octon\n' "${XDG_DATA_HOME:-$HOME/.local/share}"
      ;;
    windows)
      if [[ -n "${LOCALAPPDATA:-}" ]]; then
        printf '%s/Octon\n' "$LOCALAPPDATA"
      else
        printf '%s/Octon\n' "$HOME/AppData/Local"
      fi
      ;;
  esac
}

OCTON_HOME_ROOT="${OCTON_HOME_OVERRIDE:-${OCTON_HOME:-$(default_octon_home)}}"
HOST_HOME_MANIFEST="$OCTON_HOME_ROOT/manifest.yml"
ACTIVE_STATE="$OCTON_HOME_ROOT/state/control/host-tools/active.yml"
QUARANTINE_STATE="$OCTON_HOME_ROOT/state/control/host-tools/quarantine.yml"
PROVISIONING_EVIDENCE_ROOT="$OCTON_HOME_ROOT/state/evidence/provisioning/host-tools"
GENERATED_REPO_RESOLUTION_ROOT="$OCTON_HOME_ROOT/generated/effective/host-tools/repos"
HOST_CARGO_HOME="$OCTON_HOME_ROOT/toolchains/cargo-home"
HOST_RUSTUP_HOME="$OCTON_HOME_ROOT/toolchains/rustup"

ALLOW_PATH_ADOPTION_DEFAULT="$(yq -r '.resolution.allow_path_adoption // "true"' "$POLICY_PATH")"
if [[ -n "$ALLOW_PATH_ADOPTION_OVERRIDE" ]]; then
  ALLOW_PATH_ADOPTION="$ALLOW_PATH_ADOPTION_OVERRIDE"
else
  ALLOW_PATH_ADOPTION="$ALLOW_PATH_ADOPTION_DEFAULT"
fi

ensure_host_home_layout() {
  mkdir -p \
    "$OCTON_HOME_ROOT/tools" \
    "$OCTON_HOME_ROOT/state/control/host-tools" \
    "$PROVISIONING_EVIDENCE_ROOT" \
    "$GENERATED_REPO_RESOLUTION_ROOT" \
    "$HOST_CARGO_HOME" \
    "$HOST_RUSTUP_HOME"

  if [[ ! -f "$HOST_HOME_MANIFEST" ]]; then
    cat >"$HOST_HOME_MANIFEST" <<EOF
schema_version: "octon-host-tool-home-v1"
created_at: "$(timestamp_utc)"
platform: "$PLATFORM_KEY"
octon_home: "$OCTON_HOME_ROOT"
EOF
  fi

  if [[ ! -f "$ACTIVE_STATE" ]]; then
    cat >"$ACTIVE_STATE" <<EOF
schema_version: "octon-host-tool-active-state-v1"
updated_at: "$(timestamp_utc)"
tools: {}
EOF
  fi

  if [[ ! -f "$QUARANTINE_STATE" ]]; then
    cat >"$QUARANTINE_STATE" <<EOF
schema_version: "octon-host-tool-quarantine-state-v1"
updated_at: "$(timestamp_utc)"
tools: {}
EOF
  fi
}

sha256_text() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256
  else
    sha256sum
  fi
}

repo_fingerprint() {
  printf '%s' "$REPO_ROOT" | sha256_text | awk '{print substr($1, 1, 16)}'
}

ensure_repo_requirements() {
  if [[ -n "$TOOL_ID" && -z "$CONSUMER" && -z "$CONSUMER_MODE" ]]; then
    return 0
  fi
  [[ -n "$CONSUMER" ]] || die "--consumer is required"
  [[ -n "$CONSUMER_MODE" ]] || die "--mode is required"
  yq -e ".consumers.\"$CONSUMER\".mode_requirements.\"$CONSUMER_MODE\"" "$REQUIREMENTS_PATH" >/dev/null 2>&1 \
    || die "consumer '$CONSUMER' mode '$CONSUMER_MODE' not declared in requirements"
}

contract_ref_for_tool() {
  local tool_id="$1"
  yq -r ".tools[] | select(.tool_id == \"$tool_id\") | .contract_ref // \"\"" "$REGISTRY_PATH"
}

contract_path_for_tool() {
  local tool_id="$1"
  local ref
  ref="$(contract_ref_for_tool "$tool_id")"
  [[ -n "$ref" ]] || die "tool '$tool_id' missing from host-tool registry"
  if [[ "$ref" = /* ]]; then
    printf '%s\n' "$ref"
  else
    printf '%s/%s\n' "$ROOT_DIR" "${ref#./}"
  fi
}

tool_binary_name() {
  local contract="$1"
  yq -r '.entrypoint.binary_name' "$contract"
}

tool_command_style() {
  local contract="$1"
  yq -r '.entrypoint.command_style' "$contract"
}

tool_version_regex() {
  local contract="$1"
  yq -r '.verification.version_regex' "$contract"
}

required_tool_ids() {
  if [[ -n "$TOOL_ID" ]]; then
    printf '%s\n' "$TOOL_ID"
  else
    yq -r ".consumers.\"$CONSUMER\".mode_requirements.\"$CONSUMER_MODE\".mandatory_tools | keys | .[]" "$REQUIREMENTS_PATH"
  fi
}

tool_required_version() {
  local tool_id="$1"
  if [[ -z "$CONSUMER" || -z "$CONSUMER_MODE" ]]; then
    yq -r '.default_version' "$(contract_path_for_tool "$tool_id")"
    return 0
  fi
  local version
  version="$(yq -r ".consumers.\"$CONSUMER\".mode_requirements.\"$CONSUMER_MODE\".mandatory_tools.\"$tool_id\".version // \"\"" "$REQUIREMENTS_PATH")"
  if [[ -n "$version" ]]; then
    printf '%s\n' "$version"
  else
    yq -r '.default_version' "$(contract_path_for_tool "$tool_id")"
  fi
}

tool_version_policy() {
  local tool_id="$1"
  if [[ -z "$CONSUMER" || -z "$CONSUMER_MODE" ]]; then
    printf 'exact\n'
    return 0
  fi
  yq -r ".consumers.\"$CONSUMER\".mode_requirements.\"$CONSUMER_MODE\".mandatory_tools.\"$tool_id\".version_policy // \"exact\"" "$REQUIREMENTS_PATH"
}

version_satisfies() {
  local actual="$1"
  local policy="$2"
  local required="$3"

  case "$policy" in
    exact)
      [[ "$actual" == "$required" ]]
      ;;
    minimum)
      [[ "$(printf '%s\n%s\n' "$required" "$actual" | sort -V | head -n1)" == "$required" ]]
      ;;
    *)
      return 1
      ;;
  esac
}

extract_version() {
  local regex="$1"
  local text="$2"
  perl -ne "if (/${regex}/) { print qq{\$1}; exit 0 } END { exit 1 unless $. }" <<<"$text" 2>/dev/null || true
}

version_for_binary() {
  local contract="$1"
  local binary_path="$2"
  local output version command_style binary_name subcommand
  command_style="$(tool_command_style "$contract")"
  binary_name="$(tool_binary_name "$contract")"
  case "$command_style" in
    cargo-subcommand)
      subcommand="${binary_name#cargo-}"
      output="$(PATH="$(dirname "$binary_path"):$PATH" cargo "$subcommand" --version 2>&1 || true)"
      ;;
    *)
      output="$("$binary_path" --version 2>&1 || true)"
      ;;
  esac
  version="$(extract_version "$(tool_version_regex "$contract")" "$output")"
  printf '%s\n' "$version"
}

active_binary_path() {
  local tool_id="$1"
  yq -r ".tools.\"$tool_id\".binary_path // \"\"" "$ACTIVE_STATE"
}

active_version() {
  local tool_id="$1"
  yq -r ".tools.\"$tool_id\".version // \"\"" "$ACTIVE_STATE"
}

tool_install_root() {
  local tool_id="$1"
  local version="$2"
  printf '%s/tools/%s/%s/%s\n' "$OCTON_HOME_ROOT" "$tool_id" "$version" "$PLATFORM_KEY"
}

tool_install_bin_path() {
  local contract="$1"
  local tool_id="$2"
  local version="$3"
  printf '%s/bin/%s\n' "$(tool_install_root "$tool_id" "$version")" "$(tool_binary_name "$contract")"
}

record_active_tool() {
  local tool_id="$1"
  local version="$2"
  local source_kind="$3"
  local install_kind="$4"
  local install_root="$5"
  local binary_path="$6"

  TOOL_ID_KEY="$tool_id" \
  TOOL_VERSION="$version" \
  TOOL_SOURCE_KIND="$source_kind" \
  TOOL_INSTALL_KIND="$install_kind" \
  TOOL_INSTALL_ROOT="$install_root" \
  TOOL_BINARY_PATH="$binary_path" \
  TOOL_PLATFORM="$PLATFORM_KEY" \
  UPDATED_AT="$(timestamp_utc)" \
  yq -i '
    .updated_at = strenv(UPDATED_AT) |
    .tools[strenv(TOOL_ID_KEY)] = {
      "version": strenv(TOOL_VERSION),
      "platform": strenv(TOOL_PLATFORM),
      "source_kind": strenv(TOOL_SOURCE_KIND),
      "install_kind": strenv(TOOL_INSTALL_KIND),
      "install_root": strenv(TOOL_INSTALL_ROOT),
      "binary_path": strenv(TOOL_BINARY_PATH),
      "resolved_at": strenv(UPDATED_AT)
    }
  ' "$ACTIVE_STATE"

  TOOL_ID_KEY="$tool_id" UPDATED_AT="$(timestamp_utc)" yq -i '
    .updated_at = strenv(UPDATED_AT) |
    del(.tools[strenv(TOOL_ID_KEY)])
  ' "$QUARANTINE_STATE"
}

record_quarantine_tool() {
  local tool_id="$1"
  local reason="$2"

  TOOL_ID_KEY="$tool_id" \
  TOOL_REASON="$reason" \
  UPDATED_AT="$(timestamp_utc)" \
  yq -i '
    .updated_at = strenv(UPDATED_AT) |
    .tools[strenv(TOOL_ID_KEY)] = {
      "reason": strenv(TOOL_REASON),
      "observed_at": strenv(UPDATED_AT)
    }
  ' "$QUARANTINE_STATE"
}

try_path_adoption() {
  local contract="$1"
  local tool_id="$2"
  local required_version="$3"
  local version_policy="$4"
  local binary_name version

  binary_name="$(tool_binary_name "$contract")"
  if [[ "$ALLOW_PATH_ADOPTION" != "true" ]]; then
    return 1
  fi
  if ! command -v "$binary_name" >/dev/null 2>&1; then
    return 1
  fi

  local candidate
  candidate="$(command -v "$binary_name")"
  version="$(version_for_binary "$contract" "$candidate")"
  if [[ -z "$version" ]] || ! version_satisfies "$version" "$version_policy" "$required_version"; then
    return 1
  fi

  record_active_tool "$tool_id" "$version" "system-adopted" "system-adopt" "$(dirname "$candidate")" "$candidate"
  printf '%s\n' "$candidate"
}

try_host_cache() {
  local contract="$1"
  local tool_id="$2"
  local required_version="$3"
  local version_policy="$4"
  local cached_path cached_version

  cached_path="$(tool_install_bin_path "$contract" "$tool_id" "$required_version")"
  if [[ ! -x "$cached_path" ]]; then
    return 1
  fi

  cached_version="$(version_for_binary "$contract" "$cached_path")"
  if [[ -z "$cached_version" ]] || ! version_satisfies "$cached_version" "$version_policy" "$required_version"; then
    return 1
  fi

  record_active_tool "$tool_id" "$cached_version" "octon-managed" "cached" "$(dirname "$(dirname "$cached_path")")" "$cached_path"
  printf '%s\n' "$cached_path"
}

ensure_contract_prerequisites() {
  local contract="$1"
  local command_name
  while IFS= read -r command_name; do
    [[ -n "$command_name" ]] || continue
    command -v "$command_name" >/dev/null 2>&1 || die "missing host prerequisite '$command_name' for $(yq -r '.tool_id' "$contract")"
  done < <(yq -r '.prerequisites.required_commands[]? // ""' "$contract")
}

ensure_rustup_channels() {
  local contract="$1"
  local channel profile
  if command -v rustup >/dev/null 2>&1 && ! RUSTUP_HOME="$HOST_RUSTUP_HOME" rustup toolchain list | grep -Fq stable; then
    note "installing rustup channel 'stable' into $HOST_RUSTUP_HOME"
    RUSTUP_HOME="$HOST_RUSTUP_HOME" rustup toolchain install stable --profile minimal --no-self-update >/dev/null
  fi
  while IFS=$'\t' read -r channel profile; do
    [[ -n "$channel" ]] || continue
    if ! RUSTUP_HOME="$HOST_RUSTUP_HOME" rustup toolchain list | grep -Fq "$channel"; then
      note "installing rustup channel '$channel' into $HOST_RUSTUP_HOME"
      RUSTUP_HOME="$HOST_RUSTUP_HOME" rustup toolchain install "$channel" --profile "${profile:-minimal}" --no-self-update >/dev/null
    fi
  done < <(yq -r '.prerequisites.rustup_requirements[]? | [.channel, (.profile // "minimal")] | @tsv' "$contract")
}

archive_download_install() {
  local contract="$1"
  local tool_id="$2"
  local version="$3"
  local install_root archive_url format binary_relpath tmp_dir archive_path binary_path

  archive_url="$(yq -r ".installers[] | select(.kind == \"archive-download\") | .archives.\"$PLATFORM_KEY\".url // \"\"" "$contract")"
  format="$(yq -r ".installers[] | select(.kind == \"archive-download\") | .archives.\"$PLATFORM_KEY\".format // \"\"" "$contract")"
  binary_relpath="$(yq -r ".installers[] | select(.kind == \"archive-download\") | .archives.\"$PLATFORM_KEY\".binary_relpath // \"\"" "$contract")"
  [[ -n "$archive_url" && -n "$format" && -n "$binary_relpath" ]] || die "archive installer unsupported for $tool_id on $PLATFORM_KEY"

  require_command curl
  install_root="$(tool_install_root "$tool_id" "$version")"
  mkdir -p "$install_root/bin"
  tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/octon-host-tool.XXXXXX")"
  archive_path="$tmp_dir/archive"
  curl -L --fail --output "$archive_path" "$archive_url"
  case "$format" in
    tar.xz)
      require_command tar
      tar -xJf "$archive_path" -C "$install_root"
      ;;
    zip)
      require_command unzip
      unzip -q "$archive_path" -d "$install_root"
      ;;
    *)
      remove_tree "$tmp_dir"
      die "unsupported archive format '$format' for $tool_id"
      ;;
  esac
  binary_path="$install_root/bin/$(tool_binary_name "$contract")"
  cp "$install_root/$binary_relpath" "$binary_path"
  chmod +x "$binary_path"
  remove_tree "$tmp_dir"
  printf '%s\n' "$binary_path"
}

cargo_install_tool() {
  local contract="$1"
  local tool_id="$2"
  local version="$3"
  local install_root package_name install_args=() arg binary_path

  ensure_contract_prerequisites "$contract"
  ensure_rustup_channels "$contract"

  package_name="$(yq -r '.installers[] | select(.kind == "cargo-install") | .package_name' "$contract")"
  while IFS= read -r arg; do
    [[ -n "$arg" ]] || continue
    install_args+=("$arg")
  done < <(yq -r '.installers[] | select(.kind == "cargo-install") | .install_args[]? // ""' "$contract")

  install_root="$(tool_install_root "$tool_id" "$version")"
  mkdir -p "$install_root"
  CARGO_HOME="$HOST_CARGO_HOME" cargo install --root "$install_root" "$package_name" --version "$version" "${install_args[@]}"
  binary_path="$(tool_install_bin_path "$contract" "$tool_id" "$version")"
  printf '%s\n' "$binary_path"
}

install_tool() {
  local contract="$1"
  local tool_id="$2"
  local version="$3"
  local install_kind

  if yq -e '.installers[] | select(.kind == "archive-download")' "$contract" >/dev/null 2>&1; then
    install_kind="archive-download"
    archive_download_install "$contract" "$tool_id" "$version"
  elif yq -e '.installers[] | select(.kind == "cargo-install")' "$contract" >/dev/null 2>&1; then
    install_kind="cargo-install"
    cargo_install_tool "$contract" "$tool_id" "$version"
  else
    die "no install strategy available for $tool_id"
  fi
}

RESOLVED_RESULTS_FILE="$(mktemp "${TMPDIR:-/tmp}/octon-host-tool-results.XXXXXX")"
trap 'rm -f "$RESOLVED_RESULTS_FILE"' EXIT

resolve_one_tool() {
  local tool_id="$1"
  local contract required_version version_policy binary_path active_path active_version_text install_root result="unresolved" notes=""

  contract="$(contract_path_for_tool "$tool_id")"
  required_version="$(tool_required_version "$tool_id")"
  version_policy="$(tool_version_policy "$tool_id")"

  active_path="$(active_binary_path "$tool_id")"
  active_version_text="$(active_version "$tool_id")"
  if [[ -n "$active_path" && -x "$active_path" ]] && version_satisfies "$active_version_text" "$version_policy" "$required_version"; then
    binary_path="$active_path"
    result="resolved-active"
  else
    binary_path=""
  fi

  if [[ -z "$binary_path" ]]; then
    binary_path="$(try_host_cache "$contract" "$tool_id" "$required_version" "$version_policy" || true)"
    if [[ -n "$binary_path" ]]; then
      result="resolved-cache"
    fi
  fi

  if [[ -z "$binary_path" ]]; then
    binary_path="$(try_path_adoption "$contract" "$tool_id" "$required_version" "$version_policy" || true)"
    if [[ -n "$binary_path" ]]; then
      result="resolved-path"
    fi
  fi

  if [[ -z "$binary_path" && "$ACTION" != "verify" ]]; then
    binary_path="$(install_tool "$contract" "$tool_id" "$required_version")"
    install_root="$(dirname "$(dirname "$binary_path")")"
    record_active_tool "$tool_id" "$required_version" "octon-managed" "installed" "$install_root" "$binary_path"
    result="installed"
  fi

  if [[ -z "$binary_path" ]]; then
    notes="mandatory tool unresolved"
    record_quarantine_tool "$tool_id" "$notes"
  fi

  printf '%s\t%s\t%s\t%s\t%s\n' "$tool_id" "$required_version" "${binary_path:-}" "$result" "$notes" >>"$RESOLVED_RESULTS_FILE"

  [[ -n "$binary_path" ]]
}

write_repo_resolution_view() {
  local fingerprint consumer_key resolved_path="$GENERATED_REPO_RESOLUTION_ROOT/$(repo_fingerprint).yml"
  fingerprint="$(repo_fingerprint)"

  {
    echo 'schema_version: "octon-host-tool-resolution-view-v1"'
    printf 'repo_root: "%s"\n' "$REPO_ROOT"
    printf 'repo_fingerprint: "%s"\n' "$fingerprint"
    printf 'consumer: "%s"\n' "$CONSUMER"
    printf 'consumer_mode: "%s"\n' "$CONSUMER_MODE"
    printf 'generated_at: "%s"\n' "$(timestamp_utc)"
    printf 'octon_home: "%s"\n' "$OCTON_HOME_ROOT"
    echo 'resolved_tools:'
    while IFS=$'\t' read -r tool_id version binary_path result notes; do
      printf '  %s:\n' "$tool_id"
      printf '    required_version: "%s"\n' "$version"
      printf '    binary_path: "%s"\n' "$binary_path"
      printf '    result: "%s"\n' "$result"
      printf '    notes: "%s"\n' "$notes"
    done <"$RESOLVED_RESULTS_FILE"
  } >"$resolved_path"
}

write_receipt() {
  local receipt_id receipt_dir receipt_file repo_resolution_ref
  receipt_id="$(date -u +%Y-%m-%dT%H%M%SZ)-$(basename "$REPO_ROOT")-${CONSUMER}-${ACTION}"
  receipt_dir="$PROVISIONING_EVIDENCE_ROOT/$receipt_id"
  receipt_file="$receipt_dir/receipt.yml"
  repo_resolution_ref="$GENERATED_REPO_RESOLUTION_ROOT/$(repo_fingerprint).yml"
  mkdir -p "$receipt_dir"

  {
    echo 'schema_version: "octon-host-tool-provisioning-receipt-v1"'
    printf 'receipt_id: "%s"\n' "$receipt_id"
    printf 'action: "%s"\n' "$ACTION"
    printf 'generated_at: "%s"\n' "$(timestamp_utc)"
    printf 'repo_root: "%s"\n' "$REPO_ROOT"
    printf 'consumer: "%s"\n' "$CONSUMER"
    printf 'consumer_mode: "%s"\n' "$CONSUMER_MODE"
    printf 'octon_home: "%s"\n' "$OCTON_HOME_ROOT"
    printf 'platform: "%s"\n' "$PLATFORM_KEY"
    printf 'requirements_ref: "%s"\n' "${REQUIREMENTS_PATH#$REPO_ROOT/}"
    printf 'policy_ref: "%s"\n' "${POLICY_PATH#$REPO_ROOT/}"
    printf 'repo_resolution_view: "%s"\n' "$repo_resolution_ref"
    echo 'results:'
    while IFS=$'\t' read -r tool_id version binary_path result notes; do
      printf '  - tool_id: "%s"\n' "$tool_id"
      printf '    required_version: "%s"\n' "$version"
      printf '    binary_path: "%s"\n' "$binary_path"
      printf '    result: "%s"\n' "$result"
      printf '    notes: "%s"\n' "$notes"
    done <"$RESOLVED_RESULTS_FILE"
  } >"$receipt_file"
}

write_env_file() {
  local output_path="$1"
  local needs_managed_env=0
  mkdir -p "$(dirname "$output_path")"
  while IFS=$'\t' read -r tool_id version binary_path result notes; do
    [[ -n "$tool_id" ]] || continue
    if [[ "$(yq -r ".tools.\"$tool_id\".source_kind // \"\"" "$ACTIVE_STATE")" != "system-adopted" ]]; then
      needs_managed_env=1
    fi
  done <"$RESOLVED_RESULTS_FILE"

  {
    printf 'export OCTON_HOST_TOOLS_HOME=%q\n' "$OCTON_HOME_ROOT"
    if [[ "$needs_managed_env" == "1" ]]; then
      printf 'export OCTON_HOST_TOOL_CARGO_HOME=%q\n' "$HOST_CARGO_HOME"
      printf 'export OCTON_HOST_TOOL_RUSTUP_HOME=%q\n' "$HOST_RUSTUP_HOME"
      printf 'export OCTON_HOST_TOOL_RUSTUP_TOOLCHAIN=%q\n' "stable"
    fi
    while IFS=$'\t' read -r tool_id version binary_path result notes; do
      local key
      key="$(printf '%s' "$tool_id" | tr '[:lower:]-' '[:upper:]_')"
      if [[ -n "$binary_path" ]]; then
        printf 'export OCTON_HOST_TOOL_%s_BIN=%q\n' "$key" "$binary_path"
      fi
    done <"$RESOLVED_RESULTS_FILE"
  } >"$output_path"
}

main() {
  ensure_repo_requirements
  ensure_host_home_layout

  local failures=0
  while IFS= read -r tool_id; do
    [[ -n "$tool_id" ]] || continue
    if ! resolve_one_tool "$tool_id"; then
      failures=$((failures + 1))
    fi
  done < <(required_tool_ids)

  write_repo_resolution_view
  write_receipt
  if [[ -n "$EMIT_ENV_PATH" ]]; then
    write_env_file "$EMIT_ENV_PATH"
  fi

  if [[ "$failures" -ne 0 ]]; then
    die "$failures mandatory host tools unresolved for consumer '$CONSUMER' mode '$CONSUMER_MODE'"
  fi

  note "$ACTION completed for consumer '$CONSUMER' mode '$CONSUMER_MODE' using $OCTON_HOME_ROOT"
}

main
