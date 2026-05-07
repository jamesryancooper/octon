#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
CARGO_MANIFEST="$REPO_ROOT/.octon/framework/engine/runtime/crates/Cargo.toml"

pass_count=0
fail_count=0

pass() { printf 'PASS: %s\n' "$1"; pass_count=$((pass_count + 1)); }
fail() { printf 'FAIL: %s\n' "$1" >&2; fail_count=$((fail_count + 1)); }

new_fixture_repo() {
  local name="$1" root
  root="${TMPDIR:-/tmp}/octon-lifecycle-runner-${name}-$$-$RANDOM"
  mkdir -p "$root/.octon/generated/effective/extensions/published/test-extension/bundled/context"
  mkdir -p "$root/.octon/framework/assurance/runtime/_ops/scripts"
  printf '%s\n' "$root"
}

write_runner_fixture() {
  local root="$1"
  cat >"$root/.octon/generated/effective/extensions/catalog.effective.yml" <<'YAML'
schema_version: "octon-extension-effective-catalog-v6"
packs:
  - pack_id: "test-extension"
    source_id: "bundled"
    lifecycle_contracts:
      - lifecycle_id: "proposal-packet"
        projection_source_path: ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml"
YAML
  cat >"$root/.octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml" <<'YAML'
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target:
  input: "packet_path"
  manifest_path: "proposal.yml"
  status_field: "status"
  allowed_statuses: ["draft", "in-review", "accepted", "rejected", "archived"]
states:
  - state_id: "review"
  - state_id: "revise"
  - state_id: "generate-implementation-prompt"
terminal_outcomes:
  - outcome_id: "archived"
    when:
      manifest_status: "archived"
  - outcome_id: "rejected"
    when:
      all:
        - manifest_status: "rejected"
        - receipt_verdict:
            receipt_id: "proposal-review"
            value: "rejected"
        - receipt_fresh: "proposal-review"
        - receipt_complete: "proposal-review"
validators:
  - validator_id: "strict-review"
    argv: ["bash", ".octon/framework/assurance/runtime/_ops/scripts/review-gate.sh", "--package", "{{target}}", "--require-implementation-authorization"]
gates:
  - gate_id: "implementation-authorization"
    validator_id: "strict-review"
    required_before_routes: ["generate-implementation-prompt", "run-implementation", "promote-proposal"]
    on_fail_route_id: "review-proposal-packet"
receipts:
  - receipt_id: "proposal-review"
    path: "support/proposal-review.md"
    required_fields: ["review_id", "verdict", "implementation_prompt_authorized", "reviewed_packet_digest"]
    verdict_field: "verdict"
    freshness:
      digest_command: ["bash", ".octon/framework/assurance/runtime/_ops/scripts/review-gate.sh", "--package", "{{target}}", "--print-digest"]
      digest_field: "reviewed_packet_digest"
  - receipt_id: "implementation-run"
    path: "support/implementation-run.md"
    required_fields: ["verdict", "implemented_at", "promotion_evidence_count"]
    verdict_field: "verdict"
  - receipt_id: "implementation-conformance"
    path: "support/implementation-conformance-review.md"
    required_fields: ["verdict", "unresolved_items_count"]
    verdict_field: "verdict"
  - receipt_id: "post-implementation-drift"
    path: "support/post-implementation-drift-churn-review.md"
    required_fields: ["verdict", "unresolved_items_count"]
    verdict_field: "verdict"
  - receipt_id: "proposal-closeout"
    path: "support/proposal-closeout.md"
    required_fields: ["verdict", "closed_at", "archive_authorized"]
    verdict_field: "verdict"
loops:
  - loop_id: "proposal-review-revision"
    receipt_id: "proposal-review"
    verdict_field: "verdict"
    repeat_values: ["revision-required"]
    repeat_route_id: "revise-proposal-packet"
    terminal_values: ["accepted", "rejected"]
    max_iterations: 5
routes:
  - route_id: "review-proposal-packet"
    route_type: "extension"
    command_id: "octon-proposal-packet-review"
    skill_id: "octon-proposal-packet-lifecycle-review"
    prompt_set_id: "octon-proposal-packet-lifecycle-review-proposal-packet"
    enter_when:
      any:
        - manifest_status: "draft"
        - all:
            - manifest_status: "in-review"
            - receipt_absent: "proposal-review"
        - receipt_stale: "proposal-review"
  - route_id: "revise-proposal-packet"
    route_type: "extension"
    command_id: "octon-proposal-packet-revise"
    skill_id: "octon-proposal-packet-lifecycle-revise"
    prompt_set_id: "octon-proposal-packet-lifecycle-revise-proposal-packet"
    enter_when:
      all:
        - receipt_complete: "proposal-review"
        - receipt_verdict:
            receipt_id: "proposal-review"
            value: "revision-required"
  - route_id: "generate-implementation-prompt"
    route_type: "extension"
    command_id: "octon-proposal-packet-generate-implementation-prompt"
    skill_id: "octon-proposal-packet-lifecycle-generate-implementation-prompt"
    prompt_set_id: "octon-proposal-packet-lifecycle-generate-implementation-prompt"
    enter_when:
      all:
        - manifest_status: "accepted"
        - receipt_complete: "proposal-review"
        - receipt_verdict:
            receipt_id: "proposal-review"
            value: "accepted"
        - file_absent: "support/executable-implementation-prompt.md"
  - route_id: "run-implementation"
    route_type: "extension"
    command_id: "octon-proposal-packet-run-implementation"
    skill_id: "octon-proposal-packet-lifecycle-run-implementation"
    prompt_set_id: "octon-proposal-packet-lifecycle-run-implementation"
    enter_when:
      all:
        - manifest_status: "accepted"
        - receipt_complete: "proposal-review"
        - receipt_verdict:
            receipt_id: "proposal-review"
            value: "accepted"
        - file_present: "support/executable-implementation-prompt.md"
        - receipt_absent: "implementation-run"
  - route_id: "promote-proposal"
    route_type: "workflow"
    enter_when:
      all:
        - manifest_status: "accepted"
        - receipt_complete: "proposal-review"
        - receipt_verdict:
            receipt_id: "proposal-review"
            value: "accepted"
        - file_present: "support/executable-implementation-prompt.md"
        - receipt_complete: "implementation-run"
        - receipt_field_equals:
            receipt_id: "implementation-run"
            field: "verdict"
            value: "pass"
  - route_id: "closeout-proposal-packet"
    route_type: "extension"
    command_id: "octon-proposal-packet-closeout"
    skill_id: "octon-proposal-packet-lifecycle-closeout"
    prompt_set_id: "octon-proposal-packet-lifecycle-closeout-proposal-packet"
    enter_when:
      all:
        - manifest_status: "implemented"
        - receipt_complete: "implementation-conformance"
        - receipt_field_equals:
            receipt_id: "implementation-conformance"
            field: "verdict"
            value: "pass"
        - receipt_complete: "post-implementation-drift"
        - receipt_field_equals:
            receipt_id: "post-implementation-drift"
            field: "verdict"
            value: "pass"
        - receipt_absent: "proposal-closeout"
  - route_id: "archive-proposal"
    route_type: "workflow"
    enter_when:
      all:
        - manifest_status: "implemented"
        - receipt_complete: "implementation-conformance"
        - receipt_field_equals:
            receipt_id: "implementation-conformance"
            field: "verdict"
            value: "pass"
        - receipt_complete: "post-implementation-drift"
        - receipt_field_equals:
            receipt_id: "post-implementation-drift"
            field: "verdict"
            value: "pass"
        - receipt_complete: "proposal-closeout"
        - receipt_field_equals:
            receipt_id: "proposal-closeout"
            field: "verdict"
            value: "pass"
        - receipt_field_equals:
            receipt_id: "proposal-closeout"
            field: "archive_authorized"
            value: "yes"
YAML
  cat >"$root/.octon/framework/assurance/runtime/_ops/scripts/review-gate.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
package=""
print_digest=false
strict=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --package) shift; package="$1" ;;
    --print-digest) print_digest=true ;;
    --require-implementation-authorization) strict=true ;;
  esac
  shift
done
digest="sha256:$(shasum -a 256 "$package/proposal.yml" | awk '{print $1}')"
if [[ "$print_digest" == true ]]; then
  printf '%s\n' "$digest"
  exit 0
fi
receipt="$package/support/proposal-review.md"
[[ -f "$receipt" ]] || exit 1
grep -q '^verdict: accepted$' "$receipt" || exit 1
if [[ "$strict" == true ]]; then
  grep -q '^implementation_prompt_authorized: yes$' "$receipt" || exit 1
  grep -q "^reviewed_packet_digest: $digest$" "$receipt" || exit 1
fi
SH
  chmod +x "$root/.octon/framework/assurance/runtime/_ops/scripts/review-gate.sh"
}

octon_cli() {
  local root="$1"
  shift
  OCTON_ROOT_DIR="$root" cargo run --quiet --manifest-path "$CARGO_MANIFEST" -p octon_kernel --bin octon -- "$@"
}

write_packet() {
  local root="$1" name="$2" status="$3" verdict="${4:-}" authorized="${5:-no}"
  mkdir -p "$root/$name/support"
  printf 'status: %s\n' "$status" >"$root/$name/proposal.yml"
  if [[ -n "$verdict" ]]; then
    local digest
    digest="sha256:$(shasum -a 256 "$root/$name/proposal.yml" | awk '{print $1}')"
    {
      printf 'review_id: review-%s\n' "$name"
      printf 'verdict: %s\n' "$verdict"
      printf 'implementation_prompt_authorized: %s\n' "$authorized"
      printf 'reviewed_packet_digest: %s\n' "$digest"
    } >"$root/$name/support/proposal-review.md"
  fi
}

write_receipt() {
  local root="$1" name="$2" rel="$3"
  shift 3
  mkdir -p "$root/$name/$(dirname "$rel")"
  printf '%s\n' "$@" >"$root/$name/$rel"
}

assert_plan_route() {
  local label="$1" root="$2" target="$3" expected="$4" output
  output="$(octon_cli "$root" lifecycle plan --lifecycle proposal-packet --target "$target")"
  if yq -e ".next_route.route_id == \"$expected\"" >/dev/null <<<"$output"; then
    pass "$label"
  else
    printf '%s\n' "$output" >&2
    fail "$label"
  fi
}

assert_plan_terminal() {
  local label="$1" root="$2" target="$3" expected="$4" output
  output="$(octon_cli "$root" lifecycle plan --lifecycle proposal-packet --target "$target")"
  if yq -e ".terminal_outcome == \"$expected\" and .next_route == null" >/dev/null <<<"$output"; then
    pass "$label"
  else
    printf '%s\n' "$output" >&2
    fail "$label"
  fi
}

assert_plan_blocked_no_route() {
  local label="$1" root="$2" target="$3" output
  output="$(octon_cli "$root" lifecycle plan --lifecycle proposal-packet --target "$target")"
  if yq -e '.terminal_outcome == null and .next_route == null and .final_verdict == "blocked-no-route"' >/dev/null <<<"$output"; then
    pass "$label"
  else
    printf '%s\n' "$output" >&2
    fail "$label"
  fi
}

main() {
  local root output checkpoint raw_root missing_projection_root
  raw_root="$(new_fixture_repo raw-source)"
  write_runner_fixture "$raw_root"
  mkdir -p "$raw_root/.octon/inputs/additive/extensions/test-extension/context"
  cp \
    "$raw_root/.octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml" \
    "$raw_root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  rm -f "$raw_root/.octon/generated/effective/extensions/catalog.effective.yml"
  write_packet "$raw_root" source-only-packet draft
  if output="$(octon_cli "$raw_root" lifecycle plan --lifecycle proposal-packet --target source-only-packet 2>&1)"; then
    printf '%s\n' "$output" >&2
    fail "raw source lifecycle contract is ignored without effective catalog"
  elif grep -q 'effective extension catalog missing' <<<"$output"; then
    pass "raw source lifecycle contract is ignored without effective catalog"
  else
    printf '%s\n' "$output" >&2
    fail "raw source lifecycle contract is ignored without effective catalog"
  fi

  missing_projection_root="$(new_fixture_repo missing-projection)"
  write_runner_fixture "$missing_projection_root"
  mkdir -p "$missing_projection_root/.octon/inputs/additive/extensions/test-extension/context"
  cp \
    "$missing_projection_root/.octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml" \
    "$missing_projection_root/.octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
  cat >"$missing_projection_root/.octon/generated/effective/extensions/catalog.effective.yml" <<'YAML'
schema_version: "octon-extension-effective-catalog-v6"
packs:
  - pack_id: "test-extension"
    source_id: "bundled"
    lifecycle_contracts:
      - lifecycle_id: "proposal-packet"
        contract_path: ".octon/inputs/additive/extensions/test-extension/context/lifecycle.contract.yml"
        projection_source_path: ".octon/generated/effective/extensions/published/test-extension/missing/context/lifecycle.contract.yml"
YAML
  write_packet "$missing_projection_root" missing-projection-packet draft
  if output="$(octon_cli "$missing_projection_root" lifecycle plan --lifecycle proposal-packet --target missing-projection-packet 2>&1)"; then
    printf '%s\n' "$output" >&2
    fail "missing published lifecycle projection does not fall back to raw contract_path"
  elif grep -q 'published lifecycle contract projection missing' <<<"$output"; then
    pass "missing published lifecycle projection does not fall back to raw contract_path"
  else
    printf '%s\n' "$output" >&2
    fail "missing published lifecycle projection does not fall back to raw contract_path"
  fi

	  root="$(new_fixture_repo main)"
	  write_runner_fixture "$root"

	  if output="$(octon_cli "$root" lifecycle plan --lifecycle proposal-packet --target ../escaped-packet 2>&1)"; then
	    printf '%s\n' "$output" >&2
	    fail "parent-traversing lifecycle target is rejected"
	  elif grep -q 'lifecycle target must be repo-relative' <<<"$output"; then
	    pass "parent-traversing lifecycle target is rejected"
	  else
	    printf '%s\n' "$output" >&2
	    fail "parent-traversing lifecycle target is rejected"
	  fi

	  if output="$(octon_cli "$root" lifecycle plan --lifecycle proposal-packet --target "$root/absolute-packet" 2>&1)"; then
	    printf '%s\n' "$output" >&2
	    fail "absolute lifecycle target is rejected"
	  elif grep -q 'lifecycle target must be repo-relative' <<<"$output"; then
	    pass "absolute lifecycle target is rejected"
	  else
	    printf '%s\n' "$output" >&2
	    fail "absolute lifecycle target is rejected"
	  fi

	  local outside_dir
	  outside_dir="${TMPDIR:-/tmp}/octon-lifecycle-runner-outside-$$-$RANDOM"
	  mkdir -p "$outside_dir"
	  ln -s "$outside_dir" "$root/symlink-out"
	  if output="$(octon_cli "$root" lifecycle plan --lifecycle proposal-packet --target symlink-out/packet 2>&1)"; then
	    printf '%s\n' "$output" >&2
	    fail "symlink-escaping lifecycle target is rejected"
	  elif grep -q 'lifecycle target .*escapes repo root' <<<"$output"; then
	    pass "symlink-escaping lifecycle target is rejected"
	  else
	    printf '%s\n' "$output" >&2
	    fail "symlink-escaping lifecycle target is rejected"
	  fi

	  printf 'outside source\n' >"$outside_dir/source.txt"
	  ln -s "$outside_dir/source.txt" "$root/source-link.txt"
		  if output="$(octon_cli "$root" lifecycle run --lifecycle proposal-packet --target draft-packet --run-id symlink-source --executor mock --set-file source=source-link.txt 2>&1)"; then
		    printf '%s\n' "$output" >&2
		    fail "symlink-escaping lifecycle set-file input is rejected"
		  elif grep -q -- '--set-file path .*escapes repo root' <<<"$output"; then
		    pass "symlink-escaping lifecycle set-file input is rejected"
		  else
		    printf '%s\n' "$output" >&2
		    fail "symlink-escaping lifecycle set-file input is rejected"
		  fi

		  local bad_path_root
		  bad_path_root="$(new_fixture_repo bad-manifest-path)"
		  write_runner_fixture "$bad_path_root"
		  write_packet "$bad_path_root" draft-packet draft
		  yq -i '.target.manifest_path = "../outside.yml"' "$bad_path_root/.octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml"
		  if output="$(octon_cli "$bad_path_root" lifecycle plan --lifecycle proposal-packet --target draft-packet 2>&1)"; then
		    printf '%s\n' "$output" >&2
		    fail "target manifest path traversal is rejected"
		  elif grep -q 'target manifest path must be target-relative' <<<"$output"; then
		    pass "target manifest path traversal is rejected"
		  else
		    printf '%s\n' "$output" >&2
		    fail "target manifest path traversal is rejected"
		  fi

		  bad_path_root="$(new_fixture_repo bad-receipt-path)"
		  write_runner_fixture "$bad_path_root"
		  write_packet "$bad_path_root" draft-packet draft
		  yq -i '.receipts[0].path = "../outside-review.md"' "$bad_path_root/.octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml"
		  if output="$(octon_cli "$bad_path_root" lifecycle plan --lifecycle proposal-packet --target draft-packet 2>&1)"; then
		    printf '%s\n' "$output" >&2
		    fail "receipt path traversal is rejected"
		  elif grep -q 'receipt path proposal-review must be target-relative' <<<"$output"; then
		    pass "receipt path traversal is rejected"
		  else
		    printf '%s\n' "$output" >&2
		    fail "receipt path traversal is rejected"
		  fi

		  bad_path_root="$(new_fixture_repo bad-file-condition-path)"
		  write_runner_fixture "$bad_path_root"
		  write_packet "$bad_path_root" draft-packet draft
		  yq -i '.routes[0].enter_when = {"file_present": "../outside.md"}' "$bad_path_root/.octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml"
		  if output="$(octon_cli "$bad_path_root" lifecycle plan --lifecycle proposal-packet --target draft-packet 2>&1)"; then
		    printf '%s\n' "$output" >&2
		    fail "file_present condition traversal is rejected"
		  elif grep -q 'file_present condition path must be target-relative' <<<"$output"; then
		    pass "file_present condition traversal is rejected"
		  else
		    printf '%s\n' "$output" >&2
		    fail "file_present condition traversal is rejected"
		  fi

		  bad_path_root="$(new_fixture_repo bad-receipt-symlink)"
		  write_runner_fixture "$bad_path_root"
		  write_packet "$bad_path_root" draft-packet draft
		  mkdir -p "$outside_dir/receipt-support"
		  ln -s "$outside_dir/receipt-support" "$bad_path_root/draft-packet/support-link"
		  yq -i '.receipts[0].path = "support-link/proposal-review.md"' "$bad_path_root/.octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml"
		  if output="$(octon_cli "$bad_path_root" lifecycle plan --lifecycle proposal-packet --target draft-packet 2>&1)"; then
		    printf '%s\n' "$output" >&2
		    fail "receipt path symlink escape is rejected"
		  elif grep -q 'receipt path proposal-review symlink component escapes target root' <<<"$output"; then
		    pass "receipt path symlink escape is rejected"
		  else
		    printf '%s\n' "$output" >&2
		    fail "receipt path symlink escape is rejected"
		  fi
			
		  write_packet "$root" draft-packet draft
  assert_plan_route "draft packet routes to review" "$root" draft-packet review-proposal-packet

	  write_packet "$root" revision-packet in-review revision-required no
	  assert_plan_route "revision-required review routes to revise" "$root" revision-packet revise-proposal-packet
	  write_packet "$root" incomplete-revision-packet in-review revision-required no
	  sed -i.bak '/^implementation_prompt_authorized:/d' "$root/incomplete-revision-packet/support/proposal-review.md"
	  rm -f "$root/incomplete-revision-packet/support/proposal-review.md.bak"
	  assert_plan_blocked_no_route "incomplete revision-required review does not route to revise" "$root" incomplete-revision-packet

	  write_packet "$root" accepted-packet accepted accepted yes
	  output="$(octon_cli "$root" lifecycle plan --lifecycle proposal-packet --target accepted-packet)"
  if yq -e '.next_route.route_id == "generate-implementation-prompt" and .gate_results[0].passed == true' >/dev/null <<<"$output"; then
    pass "fresh accepted review authorizes implementation prompt route"
	  else
	    printf '%s\n' "$output" >&2
	    fail "fresh accepted review authorizes implementation prompt route"
	  fi
	  write_packet "$root" incomplete-accepted-packet accepted accepted yes
	  sed -i.bak '/^implementation_prompt_authorized:/d' "$root/incomplete-accepted-packet/support/proposal-review.md"
	  rm -f "$root/incomplete-accepted-packet/support/proposal-review.md.bak"
	  assert_plan_blocked_no_route "incomplete accepted review does not authorize implementation routes" "$root" incomplete-accepted-packet

	  printf 'status: accepted\nchanged: true\n' >"$root/accepted-packet/proposal.yml"
	  assert_plan_route "stale accepted review routes back to review" "$root" accepted-packet review-proposal-packet

  write_packet "$root" rejected-packet rejected rejected no
  assert_plan_terminal "rejected review stops lifecycle" "$root" rejected-packet rejected

  printf 'status: rejected\nchanged: true\n' >"$root/rejected-packet/proposal.yml"
  assert_plan_route "stale rejected review routes back to review" "$root" rejected-packet review-proposal-packet

  write_packet "$root" mismatched-rejected-packet accepted rejected no
  assert_plan_blocked_no_route "status-mismatched rejected review does not terminate lifecycle" "$root" mismatched-rejected-packet

  write_packet "$root" incomplete-rejected-packet rejected rejected no
  sed -i.bak '/^implementation_prompt_authorized:/d' "$root/incomplete-rejected-packet/support/proposal-review.md"
  rm -f "$root/incomplete-rejected-packet/support/proposal-review.md.bak"
  assert_plan_blocked_no_route "fresh incomplete rejected review does not terminate lifecycle" "$root" incomplete-rejected-packet

  write_packet "$root" archived-packet archived
  assert_plan_terminal "archived packet is no-op completed" "$root" archived-packet archived

	  write_packet "$root" implementation-ready-packet accepted accepted yes
	  touch "$root/implementation-ready-packet/support/executable-implementation-prompt.md"
	  assert_plan_route "executable prompt routes to run implementation before implementation receipt" "$root" implementation-ready-packet run-implementation
	  write_receipt "$root" implementation-ready-packet "support/implementation-run.md" \
	    "verdict: pass"
	  assert_plan_blocked_no_route "incomplete implementation run receipt does not route to promote" "$root" implementation-ready-packet
	  write_receipt "$root" implementation-ready-packet "support/implementation-run.md" \
	    "verdict: pass" \
	    "implemented_at:" \
	    "promotion_evidence_count: 1"
	  assert_plan_blocked_no_route "empty required implementation receipt field does not route to promote" "$root" implementation-ready-packet
	  write_receipt "$root" implementation-ready-packet "support/implementation-run.md" \
	    "verdict: pass" \
	    "implemented_at: 2026-05-06" \
	    "promotion_evidence_count: 1"
	  assert_plan_route "implementation run receipt routes to promote proposal" "$root" implementation-ready-packet promote-proposal

	  write_packet "$root" closeout-ready-packet implemented
	  write_receipt "$root" closeout-ready-packet "support/implementation-conformance-review.md" "verdict: pass"
	  write_receipt "$root" closeout-ready-packet "support/post-implementation-drift-churn-review.md" \
	    "verdict: pass" \
	    "unresolved_items_count: 0"
	  assert_plan_blocked_no_route "incomplete conformance receipt does not route to closeout" "$root" closeout-ready-packet
	  write_receipt "$root" closeout-ready-packet "support/implementation-conformance-review.md" \
	    "verdict: pass" \
	    "unresolved_items_count: 0"
	  assert_plan_route "implemented receipts route to closeout before closeout receipt" "$root" closeout-ready-packet closeout-proposal-packet
	  write_receipt "$root" closeout-ready-packet "support/proposal-closeout.md" \
	    "verdict: pass" \
	    "archive_authorized: yes"
	  assert_plan_blocked_no_route "incomplete closeout receipt does not route to archive" "$root" closeout-ready-packet
	  write_receipt "$root" closeout-ready-packet "support/proposal-closeout.md" \
	    "verdict: pass" \
	    "closed_at:" \
	    "archive_authorized: yes"
	  assert_plan_blocked_no_route "empty required closeout receipt field does not route to archive" "$root" closeout-ready-packet
	  write_receipt "$root" closeout-ready-packet "support/proposal-closeout.md" \
	    "verdict: pass" \
	    "closed_at: 2026-05-06" \
	    "archive_authorized: yes"
  assert_plan_route "closeout receipt routes to archive proposal" "$root" closeout-ready-packet archive-proposal

  output="$(octon_cli "$root" lifecycle run --lifecycle proposal-packet --target revision-packet --run-id runner-test --executor mock)"
  if yq -e '.final_verdict == "mock-route-executed" and .route_execution_mode == "mock-executed" and .selected_route.route_id == "revise-proposal-packet"' >/dev/null <<<"$output"; then
    pass "mock runner executes selected route and reports evidence"
  else
    printf '%s\n' "$output" >&2
    fail "mock runner executes selected route and reports evidence"
  fi
  checkpoint="$root/.octon/state/control/execution/runs/runner-test/lifecycle-checkpoint.yml"
  [[ -f "$checkpoint" ]] && pass "runner writes lifecycle checkpoint" || fail "runner writes lifecycle checkpoint"

  output="$(octon_cli "$root" lifecycle resume --run-id runner-test)"
  if yq -e '.run_id == "runner-test" and .selected_route.route_id == "revise-proposal-packet"' >/dev/null <<<"$output"; then
    pass "resume reconstructs target state from receipts"
  else
    printf '%s\n' "$output" >&2
    fail "resume reconstructs target state from receipts"
  fi

  write_packet "$root" revision-packet-other in-review revision-required no
  if output="$(octon_cli "$root" lifecycle run --lifecycle proposal-packet --target revision-packet-other --run-id runner-test --executor mock 2>&1)"; then
    printf '%s\n' "$output" >&2
    fail "run id reuse with different target is rejected"
  elif grep -q 'already bound to lifecycle proposal-packet target revision-packet' <<<"$output"; then
    pass "run id reuse with different target is rejected"
  else
    printf '%s\n' "$output" >&2
    fail "run id reuse with different target is rejected"
  fi
  if yq -e '.target == "revision-packet"' "$checkpoint" >/dev/null; then
    pass "run id mismatch does not overwrite checkpoint target"
  else
    fail "run id mismatch does not overwrite checkpoint target"
  fi

  local unsafe_run_id safe_run_id
  unsafe_run_id='unsafe/../resume id'
  safe_run_id="$(printf '%s' "$unsafe_run_id" | sed 's/[^A-Za-z0-9_-]/-/g')"
  output="$(octon_cli "$root" lifecycle run --lifecycle proposal-packet --target revision-packet --run-id "$unsafe_run_id" --executor mock)"
  if yq -e ".run_id == \"$safe_run_id\"" >/dev/null <<<"$output"; then
    pass "unsafe run id is sanitized during run"
  else
    printf '%s\n' "$output" >&2
    fail "unsafe run id is sanitized during run"
  fi
  output="$(octon_cli "$root" lifecycle resume --run-id "$unsafe_run_id")"
  if yq -e ".run_id == \"$safe_run_id\"" >/dev/null <<<"$output"; then
    pass "unsafe run id is sanitized during resume"
  else
    printf '%s\n' "$output" >&2
    fail "unsafe run id is sanitized during resume"
  fi
  if [[ -f "$root/.octon/state/evidence/runs/workflows/$safe_run_id/resume-plan.yml" \
    && ! -e "$root/.octon/state/evidence/runs/workflows/resume id/resume-plan.yml" ]]; then
    pass "resume evidence stays in sanitized workflow directory"
  else
    fail "resume evidence stays in sanitized workflow directory"
  fi
  if output="$(octon_cli "$root" lifecycle run --lifecycle proposal-packet --target revision-packet --run-id "" --executor mock 2>&1)"; then
    printf '%s\n' "$output" >&2
    fail "empty run id is rejected during run"
  elif grep -q 'lifecycle run id is empty after sanitization' <<<"$output" \
    && [[ ! -f "$root/.octon/state/evidence/runs/workflows/plan.yml" ]] \
    && [[ ! -f "$root/.octon/state/control/execution/runs/lifecycle-checkpoint.yml" ]]; then
    pass "empty run id is rejected during run"
  else
    printf '%s\n' "$output" >&2
    fail "empty run id is rejected during run"
  fi
  if output="$(octon_cli "$root" lifecycle resume --run-id "" 2>&1)"; then
    printf '%s\n' "$output" >&2
    fail "empty run id is rejected during resume"
  elif grep -q 'lifecycle run id is empty after sanitization' <<<"$output" \
    && [[ ! -f "$root/.octon/state/evidence/runs/workflows/resume-plan.yml" ]]; then
    pass "empty run id is rejected during resume"
  else
    printf '%s\n' "$output" >&2
    fail "empty run id is rejected during resume"
  fi

  write_packet "$root" nonmock-packet accepted accepted yes
  output="$(octon_cli "$root" lifecycle run --lifecycle proposal-packet --target nonmock-packet --run-id nonmock-handoff --executor codex)"
  if yq -e '.final_verdict == "route-ready" and .route_execution_mode == "route-handoff" and .selected_route.route_id == "generate-implementation-prompt"' >/dev/null <<<"$output"; then
    pass "non-mock runner emits route-ready handoff"
  else
    printf '%s\n' "$output" >&2
    fail "non-mock runner emits route-ready handoff"
  fi
  if [[ ! -e "$root/nonmock-packet/support/executable-implementation-prompt.md" ]]; then
    pass "non-mock handoff does not mutate target packet"
  else
    fail "non-mock handoff does not mutate target packet"
  fi
	  if grep -q 'route_execution_mode: route-handoff' "$root/.octon/state/evidence/runs/workflows/nonmock-handoff/summary.md" \
	    && grep -q 'did not invoke the prompt bundle' "$root/.octon/state/evidence/runs/workflows/nonmock-handoff/commands.md"; then
	    pass "non-mock evidence states handoff boundary"
	  else
	    fail "non-mock evidence states handoff boundary"
	  fi
	  output="$(octon_cli "$root" lifecycle run --lifecycle proposal-packet --target implementation-ready-packet --run-id workflow-handoff --executor codex)"
	  if yq -e '.final_verdict == "route-ready" and .route_execution_mode == "route-handoff" and .selected_route.route_id == "promote-proposal" and .selected_route.route_type == "workflow"' >/dev/null <<<"$output"; then
	    pass "non-mock workflow route emits handoff"
	  else
	    printf '%s\n' "$output" >&2
	    fail "non-mock workflow route emits handoff"
	  fi
	  if grep -q 'route_type: `workflow`' "$root/.octon/state/evidence/runs/workflows/workflow-handoff/commands.md" \
	    && grep -q 'octon workflow run promote-proposal --set proposal_path=' "$root/.octon/state/evidence/runs/workflows/workflow-handoff/commands.md"; then
	    pass "workflow handoff evidence names workflow entry surface"
	  else
	    fail "workflow handoff evidence names workflow entry surface"
	  fi

	  output="$(octon_cli "$root" lifecycle run --lifecycle proposal-packet --target revision-packet --run-id nonmock-loop --executor codex --max-iterations 1)"
  if yq -e '.final_verdict == "route-ready" and .route_execution_mode == "route-handoff" and .selected_route.route_id == "revise-proposal-packet"' >/dev/null <<<"$output"; then
    pass "non-mock loop route emits handoff"
  else
    printf '%s\n' "$output" >&2
    fail "non-mock loop route emits handoff"
  fi
  output="$(octon_cli "$root" lifecycle run --lifecycle proposal-packet --target revision-packet --run-id nonmock-loop --executor codex --max-iterations 1)"
  if yq -e '.final_verdict == "route-ready" and .route_execution_mode == "route-handoff"' >/dev/null <<<"$output"; then
    pass "non-mock handoff does not consume loop iteration budget"
  else
    printf '%s\n' "$output" >&2
    fail "non-mock handoff does not consume loop iteration budget"
  fi

  output="$(octon_cli "$root" lifecycle run --lifecycle proposal-packet --target revision-packet --run-id runner-test --executor mock --max-iterations 1)"
  if yq -e '.final_verdict == "blocked-max-iterations"' >/dev/null <<<"$output"; then
    pass "max review iteration bound blocks repeat route"
  else
    printf '%s\n' "$output" >&2
    fail "max review iteration bound blocks repeat route"
  fi
  output="$(octon_cli "$root" lifecycle resume --run-id runner-test)"
  if yq -e '.final_verdict == "blocked-max-iterations"' >/dev/null <<<"$output"; then
    pass "resume preserves blocked max-iterations checkpoint"
  else
    printf '%s\n' "$output" >&2
    fail "resume preserves blocked max-iterations checkpoint"
  fi

  if ! rg -n 'Command::new\("(codex|claude)"|find_binary\("(codex|claude)"' "$REPO_ROOT/.octon/framework/engine/runtime/crates/kernel/src/lifecycle.rs" >/dev/null; then
    pass "lifecycle runner keeps direct Codex and Claude execution out of lifecycle.rs"
  else
    fail "lifecycle runner keeps direct Codex and Claude execution out of lifecycle.rs"
  fi

  printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
