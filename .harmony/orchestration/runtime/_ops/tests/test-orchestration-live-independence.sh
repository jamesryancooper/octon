#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd -- "$OPS_DIR/.." && pwd)"
ORCHESTRATION_DIR="$(cd -- "$RUNTIME_DIR/.." && pwd)"
HARMONY_DIR="$(cd -- "$ORCHESTRATION_DIR/.." && pwd)"
REPO_ROOT="$(cd -- "$HARMONY_DIR/.." && pwd)"
VALIDATE_SCRIPT=".harmony/orchestration/runtime/_ops/scripts/validate-orchestration-live-independence.sh"

pass_count=0
fail_count=0
cleanup_paths=()

cleanup() {
  local path
  for path in "${cleanup_paths[@]}"; do
    [[ -n "$path" && -e "$path" ]] && rm -r "$path"
  done
}
trap cleanup EXIT

pass() {
  echo "PASS: $1"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

assert_success() {
  local name="$1"
  shift
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

assert_failure_contains() {
  local name="$1"
  local needle="$2"
  shift 2

  local output=""
  local rc=0
  output="$("$@" 2>&1)" || rc=$?

  if (( rc != 0 )) && grep -Fq "$needle" <<<"$output"; then
    pass "$name"
    return 0
  fi

  fail "$name"
  echo "  expected failure containing: $needle" >&2
  echo "  exit code: $rc" >&2
  echo "  output:" >&2
  echo "$output" >&2
  return 1
}

create_fixture_repo() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/orchestration-live-independence.XXXXXX")"
  cleanup_paths+=("$fixture_root")

  mkdir -p \
    "$fixture_root/.harmony/orchestration/runtime/_ops/scripts" \
    "$fixture_root/.harmony/orchestration/runtime/workflows/meta/create-design-proposal" \
    "$fixture_root/.harmony/orchestration/runtime/workflows/meta/create-migration-proposal" \
    "$fixture_root/.harmony/orchestration/practices" \
    "$fixture_root/.harmony/orchestration/runtime/queue"

  cp "$REPO_ROOT/$VALIDATE_SCRIPT" \
    "$fixture_root/.harmony/orchestration/runtime/_ops/scripts/validate-orchestration-live-independence.sh"

  cat > "$fixture_root/.harmony/orchestration/practices/workflow-authoring-standards.md" <<'EOF'
# Workflow Authoring Standards

`/.proposals/` may inform work, but must never be a live dependency.
EOF

  cat > "$fixture_root/.harmony/orchestration/runtime/workflows/manifest.yml" <<'EOF'
workflows:
  create-design-proposal:
    path: "meta/create-design-proposal/"
  create-migration-proposal:
    path: "meta/create-migration-proposal/"
EOF

  cat > "$fixture_root/.harmony/orchestration/runtime/workflows/registry.yml" <<'EOF'
workflows:
  create-design-proposal:
    parameters:
      - description: "Kebab-case design proposal id and directory name under .proposals/design/"
    outputs:
      - path: "../../../../../.proposals/design/{{proposal_id}}/"
      - path: "../../../../../.proposals/design/{{proposal_id}}/proposal.yml"
      - path: "../../../../../.proposals/design/{{proposal_id}}/design-proposal.yml"
  create-migration-proposal:
    parameters:
      - description: "Kebab-case migration proposal id and directory name under .proposals/migration/"
    outputs:
      - path: "../../../../../.proposals/migration/{{proposal_id}}/"
      - path: "../../../../../.proposals/migration/{{proposal_id}}/proposal.yml"
      - path: "../../../../../.proposals/migration/{{proposal_id}}/migration-proposal.yml"
  proposal-registry:
    outputs:
      - path: "../../../../../.proposals/registry.yml"
EOF

  cat > "$fixture_root/.harmony/orchestration/runtime/workflows/meta/create-design-proposal/README.md" <<'EOF'
# Create Design Proposal

Scaffold `.proposals/design/{{proposal_id}}/`.
EOF

  cat > "$fixture_root/.harmony/orchestration/runtime/workflows/meta/create-migration-proposal/README.md" <<'EOF'
# Create Migration Proposal

Scaffold `.proposals/migration/{{proposal_id}}/`.
EOF

  cat > "$fixture_root/.harmony/orchestration/runtime/queue/README.md" <<'EOF'
# Queue

Standalone live queue surface.
EOF

  printf '%s\n' "$fixture_root"
}

run_validator_in_fixture() {
  local fixture_root="$1"
  (
    cd "$fixture_root"
    bash "$VALIDATE_SCRIPT"
  )
}

case_allowlisted_proposal_references_pass() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  run_validator_in_fixture "$fixture_root"
}

case_live_backreference_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  printf '\nSee `.proposals/runtime-package/navigation/source-of-truth-map.md`.\n' >> \
    "$fixture_root/.harmony/orchestration/runtime/queue/README.md"
  run_validator_in_fixture "$fixture_root"
}

case_unexpected_workflow_index_backreference_fails() {
  local fixture_root
  fixture_root="$(create_fixture_repo)"
  cat >> "$fixture_root/.harmony/orchestration/runtime/workflows/registry.yml" <<'EOF'
  update-workflow:
    outputs:
      path: ".proposals/unexpected-package/"
EOF
  run_validator_in_fixture "$fixture_root"
}

main() {
  assert_success \
    "live-independence validator allows explicit proposal workflow exceptions" \
    case_allowlisted_proposal_references_pass

  assert_failure_contains \
    "live-independence validator rejects live orchestration backreferences" \
    "live orchestration artifacts must not depend on temporary .proposals paths" \
    case_live_backreference_fails

  assert_failure_contains \
    "live-independence validator rejects unexpected workflow index backreferences" \
    "live orchestration artifacts must not depend on temporary .proposals paths" \
    case_unexpected_workflow_index_backreference_fails

  echo
  echo "Passed: $pass_count"
  echo "Failed: $fail_count"

  if (( fail_count > 0 )); then
    exit 1
  fi
}

main "$@"
