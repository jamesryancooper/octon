#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TMPDIR_PUBLICATION="$(mktemp -d "${TMPDIR:-/tmp}/octon-publication-boundary.XXXXXX")"
trap 'rm -fr -- "$TMPDIR_PUBLICATION"' EXIT

LOG_FILE="$TMPDIR_PUBLICATION/kernel-args.log"
FAKE_KERNEL="$TMPDIR_PUBLICATION/octon"

cat >"$FAKE_KERNEL" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@" > "$OCTON_TEST_LOG"
EOF
chmod +x "$FAKE_KERNEL"

assert_kernel_args() {
  local label="$1"
  shift
  local script_rel="$1"
  shift
  local expected="$TMPDIR_PUBLICATION/expected.log"
  printf '%s\n' "$@" > "$expected"
  : > "$LOG_FILE"
  OCTON_KERNEL_BIN="$FAKE_KERNEL" OCTON_TEST_LOG="$LOG_FILE" \
    bash "$ROOT_DIR/$script_rel" >/dev/null
  diff -u "$expected" "$LOG_FILE" >/dev/null
  printf 'PASS: %s\n' "$label"
}

assert_runtime_env_without_manifest_fails() {
  local label="$1"
  local script_rel="$2"
  if OCTON_PUBLICATION_ENTRYPOINT=runtime bash "$ROOT_DIR/$script_rel" >/dev/null 2>&1; then
    printf 'FAIL: %s\n' "$label" >&2
    exit 1
  fi
  printf 'PASS: %s\n' "$label"
}

assert_kernel_args \
  "support-target matrix delegates to runtime boundary" \
  ".octon/framework/assurance/runtime/_ops/scripts/generate-support-target-matrix.sh" \
  "publish" "support-target-matrix"

assert_kernel_args \
  "pack-routes delegates to runtime boundary" \
  ".octon/framework/assurance/runtime/_ops/scripts/generate-pack-routes.sh" \
  "publish" "pack-routes"

assert_kernel_args \
  "runtime-route-bundle delegates to runtime boundary" \
  ".octon/framework/assurance/runtime/_ops/scripts/generate-runtime-effective-route-bundle.sh" \
  "publish" "runtime-route-bundle"

assert_kernel_args \
  "extension-state delegates to runtime boundary" \
  ".octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh" \
  "publish" "extension-state"

assert_kernel_args \
  "capability-routing delegates to runtime boundary" \
  ".octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh" \
  "publish" "capability-routing"

assert_kernel_args \
  "host-projections delegates to runtime boundary" \
  ".octon/framework/capabilities/_ops/scripts/publish-host-projections.sh" \
  "publish" "host-projections"

assert_runtime_env_without_manifest_fails \
  "support-target matrix forged runtime env without manifest fails closed" \
  ".octon/framework/assurance/runtime/_ops/scripts/generate-support-target-matrix.sh"

assert_runtime_env_without_manifest_fails \
  "pack-routes forged runtime env without manifest fails closed" \
  ".octon/framework/assurance/runtime/_ops/scripts/generate-pack-routes.sh"

assert_runtime_env_without_manifest_fails \
  "runtime-route-bundle forged runtime env without manifest fails closed" \
  ".octon/framework/assurance/runtime/_ops/scripts/generate-runtime-effective-route-bundle.sh"

assert_runtime_env_without_manifest_fails \
  "capability-routing forged runtime env without manifest fails closed" \
  ".octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh"

assert_runtime_env_without_manifest_fails \
  "extension-state forged runtime env without manifest fails closed" \
  ".octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh"

assert_runtime_env_without_manifest_fails \
  "host-projections forged runtime env without manifest fails closed" \
  ".octon/framework/capabilities/_ops/scripts/publish-host-projections.sh"
