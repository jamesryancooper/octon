#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
PROVISION_SCRIPT="$ROOT_DIR/.octon/framework/scaffolding/runtime/_ops/scripts/provision-host-tools.sh"

TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/host-tool-governance.XXXXXX")"

cleanup_tree() {
  local dir="$1"
  [[ -n "$dir" ]] || return 0
  command rm -r -f -- "$dir"
}

trap 'cleanup_tree "$TMP_ROOT"' EXIT

PLATFORM_OS="$(
  case "$(uname -s)" in
    Darwin) printf 'darwin' ;;
    Linux) printf 'linux' ;;
    *) printf 'linux' ;;
  esac
)"
PLATFORM_ARCH="$(
  case "$(uname -m)" in
    arm64|aarch64) printf 'aarch64' ;;
    *) printf 'x86_64' ;;
  esac
)"
PLATFORM_KEY="${PLATFORM_OS}-${PLATFORM_ARCH}"

REGISTRY="$TMP_ROOT/registry.yml"
CONTRACT="$TMP_ROOT/fake-tool.yml"
OCTON_HOME="$TMP_ROOT/octon-home"
REPO_A="$TMP_ROOT/repo-a"
REPO_B="$TMP_ROOT/repo-b"

mkdir -p "$REPO_A/.octon/instance/capabilities/runtime/host-tools" "$REPO_A/.octon/instance/governance/policies"
mkdir -p "$REPO_B/.octon/instance/capabilities/runtime/host-tools" "$REPO_B/.octon/instance/governance/policies"
mkdir -p "$OCTON_HOME/tools/fake-tool/1.0.0/$PLATFORM_KEY/bin" "$OCTON_HOME/tools/fake-tool/2.0.0/$PLATFORM_KEY/bin"

cat >"$CONTRACT" <<EOF
schema_version: "octon-host-tool-contract-v1"
tool_id: "fake-tool"
display_name: "Fake Tool"
default_version: "1.0.0"
entrypoint:
  binary_name: "fake-tool"
  command_style: "direct-binary"
resolution:
  allow_path_adoption: false
  shared_cache: true
  install_root_template: "tools/fake-tool/<version>/<platform>"
verification:
  command: "fake-tool --version"
  version_regex: 'fake-tool ([0-9]+\.[0-9]+\.[0-9]+)'
installers:
  - kind: "system-adopt"
supported_platforms:
  - os: "$PLATFORM_OS"
    arches: ["$PLATFORM_ARCH"]
EOF

cat >"$REGISTRY" <<EOF
schema_version: "octon-host-tool-registry-v1"
owner: "test"
tools:
  - tool_id: "fake-tool"
    contract_ref: "$CONTRACT"
    category: "test"
EOF

write_policy() {
  local repo_root="$1"
  cat >"$repo_root/.octon/instance/governance/policies/host-tool-resolution.yml" <<'EOF'
schema_version: "host-tool-resolution-policy-v1"
policy_id: "host-tool-resolution"
owner: "test"
status: "active"
octon_home:
  env_var: "OCTON_HOME"
  defaults:
    linux: "~/.local/share/octon"
resolution:
  prefer_octon_home_cache: true
  allow_path_adoption: false
  allow_side_by_side_versions: true
  unresolved_mandatory_route: "deny"
  unresolved_optional_route: "stage_only"
  repo_fingerprint_basis: "absolute-repo-root"
host_state:
  manifest_relpath: "manifest.yml"
  active_state_relpath: "state/control/host-tools/active.yml"
  quarantine_state_relpath: "state/control/host-tools/quarantine.yml"
  provisioning_evidence_root_relpath: "state/evidence/provisioning/host-tools"
  generated_repo_resolution_root_relpath: "generated/effective/host-tools/repos"
  toolchains:
    cargo_home_relpath: "toolchains/cargo-home"
    rustup_home_relpath: "toolchains/rustup"
installer_posture:
  require_explicit_command: true
  init_must_not_install: true
  system_package_manager_silent_mutation: "deny"
  allowed_installer_kinds:
    - "system-adopt"
bootstrap_boundary:
  repo_bootstrap_command: "/init"
  provisioning_command: "/provision-host-tools"
  rule: "Repo bootstrap may report missing host tools but must not install them."
EOF
}

write_requirements() {
  local repo_root="$1"
  local version="$2"
  cat >"$repo_root/.octon/instance/capabilities/runtime/host-tools/requirements.yml" <<EOF
schema_version: "octon-host-tool-requirements-v1"
owner: "test"
consumers:
  fake-consumer:
    surface_refs:
      - ".octon/test"
    mode_requirements:
      enforce:
        mandatory_tools:
          fake-tool:
            version_policy: "exact"
            version: "$version"
EOF
}

write_policy "$REPO_A"
write_policy "$REPO_B"
write_requirements "$REPO_A" "1.0.0"
write_requirements "$REPO_B" "2.0.0"

cat >"$OCTON_HOME/tools/fake-tool/1.0.0/$PLATFORM_KEY/bin/fake-tool" <<'EOF'
#!/usr/bin/env bash
echo "fake-tool 1.0.0"
EOF

cat >"$OCTON_HOME/tools/fake-tool/2.0.0/$PLATFORM_KEY/bin/fake-tool" <<'EOF'
#!/usr/bin/env bash
echo "fake-tool 2.0.0"
EOF

chmod +x \
  "$OCTON_HOME/tools/fake-tool/1.0.0/$PLATFORM_KEY/bin/fake-tool" \
  "$OCTON_HOME/tools/fake-tool/2.0.0/$PLATFORM_KEY/bin/fake-tool"

OCTON_HOST_TOOL_REGISTRY_PATH_OVERRIDE="$REGISTRY" OCTON_HOME="$OCTON_HOME" \
  bash "$PROVISION_SCRIPT" verify --repo-root "$REPO_A" --consumer fake-consumer --mode enforce --quiet
OCTON_HOST_TOOL_REGISTRY_PATH_OVERRIDE="$REGISTRY" OCTON_HOME="$OCTON_HOME" \
  bash "$PROVISION_SCRIPT" verify --repo-root "$REPO_B" --consumer fake-consumer --mode enforce --quiet

find "$OCTON_HOME/generated/effective/host-tools/repos" -type f | grep -q . || {
  echo "no repo resolution views written" >&2
  exit 1
}

grep -R "required_version: \"1.0.0\"" "$OCTON_HOME/generated/effective/host-tools/repos" >/dev/null || {
  echo "repo A resolution view missing version 1.0.0" >&2
  exit 1
}

grep -R "required_version: \"2.0.0\"" "$OCTON_HOME/generated/effective/host-tools/repos" >/dev/null || {
  echo "repo B resolution view missing version 2.0.0" >&2
  exit 1
}
