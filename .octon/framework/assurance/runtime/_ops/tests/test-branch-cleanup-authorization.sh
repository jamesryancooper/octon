#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
AUTH_HELPER="$ROOT_DIR/.octon/framework/execution-roles/_ops/scripts/git/git-branch-authorize-cleanup.sh"
CLEANUP_HELPER="$ROOT_DIR/.octon/framework/execution-roles/_ops/scripts/git/git-branch-cleanup.sh"

pass_count=0
fail_count=0

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

assert_success() {
  local label="$1"
  shift
  if "$@"; then pass "$label"; else fail "$label"; fi
}

setup_stub_gh() {
  local bin_dir="$1"
  local open_count="${2:-0}"
  mkdir -p "$bin_dir"
  cat >"$bin_dir/gh" <<EOF
#!/usr/bin/env bash
if [[ "\$1" == "pr" && "\$2" == "list" ]]; then
  printf '%s\n' "$open_count"
  exit 0
fi
echo "unexpected gh invocation: \$*" >&2
exit 2
EOF
  chmod +x "$bin_dir/gh"
}

setup_repo() {
  local tmp_root="$1"
  local repo="$tmp_root/repo"
  git init --bare "$tmp_root/origin.git" >/dev/null
  git clone "$tmp_root/origin.git" "$repo" >/dev/null 2>&1
  git -C "$repo" config user.email "test@example.invalid"
  git -C "$repo" config user.name "Octon Test"
  printf 'base\n' >"$repo/README.md"
  git -C "$repo" add README.md
  git -C "$repo" commit -m "chore: base" >/dev/null
  git -C "$repo" branch -M main
  git -C "$repo" push origin main >/dev/null 2>&1
  git -C "$repo" checkout -b feature/cleanup >/dev/null 2>&1
  printf 'feature\n' >"$repo/feature.txt"
  git -C "$repo" add feature.txt
  git -C "$repo" commit -m "feat: cleanup fixture" >/dev/null
  git -C "$repo" push origin feature/cleanup >/dev/null 2>&1
  git -C "$repo" checkout main >/dev/null 2>&1
  git -C "$repo" merge --ff-only feature/cleanup >/dev/null 2>&1
  git -C "$repo" push origin main >/dev/null 2>&1
  git -C "$repo" checkout feature/cleanup >/dev/null 2>&1
  git -C "$repo" fetch origin >/dev/null 2>&1
  printf '%s\n' "$repo"
}

case_valid_authorization_permits_cleanup() {
  local tmp_root repo bin_dir auth landed
  tmp_root="$(mktemp -d /private/tmp/octon-branch-cleanup.XXXXXX)"
  trap "rm -rf '$tmp_root'" RETURN
  bin_dir="$tmp_root/bin"
  setup_stub_gh "$bin_dir" 0
  repo="$(setup_repo "$tmp_root")"
  landed="$(git -C "$repo" rev-parse HEAD)"
  auth="$tmp_root/cleanup-auth.json"

  (cd "$repo" && PATH="$bin_dir:$PATH" "$AUTH_HELPER" \
    --branch feature/cleanup \
    --landed-ref "$landed" \
    --retained-rollback-ref "revert:$landed" \
    --selected-route branch-no-pr \
    --delete-remote \
    --output "$auth" >/dev/null)

  (cd "$repo" && PATH="$bin_dir:$PATH" "$CLEANUP_HELPER" \
    --branch feature/cleanup \
    --landed-ref "$landed" \
    --retained-rollback-ref "revert:$landed" \
    --delete-remote \
    --authorization "$auth" \
    --confirm >/dev/null 2>&1)

  ! git -C "$repo" show-ref --verify --quiet refs/heads/feature/cleanup &&
    [[ -z "$(git -C "$repo" ls-remote --heads origin feature/cleanup)" ]] &&
    [[ "$(git -C "$repo" rev-parse main)" == "$(git -C "$repo" rev-parse origin/main)" ]]
}

case_cleanup_without_authorization_fails() {
  local tmp_root repo bin_dir landed
  tmp_root="$(mktemp -d /private/tmp/octon-branch-cleanup.XXXXXX)"
  trap "rm -rf '$tmp_root'" RETURN
  bin_dir="$tmp_root/bin"
  setup_stub_gh "$bin_dir" 0
  repo="$(setup_repo "$tmp_root")"
  landed="$(git -C "$repo" rev-parse HEAD)"

  ! (cd "$repo" && PATH="$bin_dir:$PATH" "$CLEANUP_HELPER" \
    --branch feature/cleanup \
    --landed-ref "$landed" \
    --retained-rollback-ref "revert:$landed" \
    --delete-remote \
    --confirm >/dev/null 2>&1)
}

case_stale_authorization_fails() {
  local tmp_root repo bin_dir auth landed
  tmp_root="$(mktemp -d /private/tmp/octon-branch-cleanup.XXXXXX)"
  trap "rm -rf '$tmp_root'" RETURN
  bin_dir="$tmp_root/bin"
  setup_stub_gh "$bin_dir" 0
  repo="$(setup_repo "$tmp_root")"
  landed="$(git -C "$repo" rev-parse HEAD)"
  auth="$tmp_root/cleanup-auth.json"

  (cd "$repo" && PATH="$bin_dir:$PATH" "$AUTH_HELPER" \
    --branch feature/cleanup \
    --landed-ref "$landed" \
    --retained-rollback-ref "revert:$landed" \
    --selected-route branch-no-pr \
    --delete-remote \
    --output "$auth" >/dev/null)
  jq '.origin_main_ref = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"' "$auth" >"$tmp_root/stale.json"

  ! (cd "$repo" && PATH="$bin_dir:$PATH" "$CLEANUP_HELPER" \
    --branch feature/cleanup \
    --landed-ref "$landed" \
    --retained-rollback-ref "revert:$landed" \
    --delete-remote \
    --authorization "$tmp_root/stale.json" \
    --confirm >/dev/null 2>&1)
}

case_protected_branch_authorization_fails() {
  local tmp_root repo bin_dir landed
  tmp_root="$(mktemp -d /private/tmp/octon-branch-cleanup.XXXXXX)"
  trap "rm -rf '$tmp_root'" RETURN
  bin_dir="$tmp_root/bin"
  setup_stub_gh "$bin_dir" 0
  repo="$(setup_repo "$tmp_root")"
  landed="$(git -C "$repo" rev-parse HEAD)"

  ! (cd "$repo" && PATH="$bin_dir:$PATH" "$AUTH_HELPER" \
    --branch main \
    --landed-ref "$landed" \
    --retained-rollback-ref "revert:$landed" \
    --selected-route branch-no-pr \
    --output "$tmp_root/protected.json" >/dev/null 2>&1)
}

case_open_pr_authorization_fails() {
  local tmp_root repo bin_dir landed
  tmp_root="$(mktemp -d /private/tmp/octon-branch-cleanup.XXXXXX)"
  trap "rm -rf '$tmp_root'" RETURN
  bin_dir="$tmp_root/bin"
  setup_stub_gh "$bin_dir" 1
  repo="$(setup_repo "$tmp_root")"
  landed="$(git -C "$repo" rev-parse HEAD)"

  ! (cd "$repo" && PATH="$bin_dir:$PATH" "$AUTH_HELPER" \
    --branch feature/cleanup \
    --landed-ref "$landed" \
    --retained-rollback-ref "revert:$landed" \
    --selected-route branch-no-pr \
    --output "$tmp_root/open-pr.json" >/dev/null 2>&1)
}

main() {
  assert_success "valid cleanup authorization permits local and remote cleanup" case_valid_authorization_permits_cleanup
  assert_success "cleanup without authorization fails closed" case_cleanup_without_authorization_fails
  assert_success "stale cleanup authorization fails closed" case_stale_authorization_fails
  assert_success "protected branch cleanup authorization fails" case_protected_branch_authorization_fails
  assert_success "open PR cleanup authorization fails" case_open_pr_authorization_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
