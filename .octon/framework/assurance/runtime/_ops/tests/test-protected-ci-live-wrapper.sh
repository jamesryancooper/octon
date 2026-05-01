#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
WORKFLOW="$ROOT_DIR/.github/workflows/pr-auto-merge.yml"
WRAPPER="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/protected-ci-auto-merge.sh"
TMPDIR_CI="$(mktemp -d "${TMPDIR:-/tmp}/octon-protected-ci.XXXXXX")"
trap 'rm -fr -- "$TMPDIR_CI"' EXIT

LOG_FILE="$TMPDIR_CI/kernel-args.log"
FAKE_KERNEL="$TMPDIR_CI/octon"

cat >"$FAKE_KERNEL" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$@" > "$OCTON_TEST_LOG"
EOF
chmod +x "$FAKE_KERNEL"

rg -Fq 'protected-ci-auto-merge.sh' "$WORKFLOW"
rg -Fq -- '--control-json' "$WORKFLOW"
rg -Fq 'checkout_pr_head' "$WORKFLOW"
rg -Fq 'git fetch --no-tags --depth=1 origin "${head_sha}"' "$WORKFLOW"
rg -Fq 'git checkout --detach "${head_sha}"' "$WORKFLOW"
! rg -Fq 'repos/${GH_REPO}/pulls/${PR_NUMBER}/merge' "$WORKFLOW"
! rg -Fq 'repos/${GH_REPO}/git/refs/heads/' "$WORKFLOW"

EXPECTED="$TMPDIR_CI/expected.log"
printf '%s\n' \
  "protected-ci" \
  "auto-merge" \
  "--repo" \
  "example/repo" \
  "--pr-number" \
  "17" \
  "--control-json" \
  ".octon/generated/.tmp/pr-auto-merge/authority-17.json" > "$EXPECTED"

OCTON_KERNEL_BIN="$FAKE_KERNEL" OCTON_TEST_LOG="$LOG_FILE" \
  bash "$WRAPPER" \
    --repo example/repo \
    --pr-number 17 \
    --control-json .octon/generated/.tmp/pr-auto-merge/authority-17.json >/dev/null

diff -u "$EXPECTED" "$LOG_FILE" >/dev/null
