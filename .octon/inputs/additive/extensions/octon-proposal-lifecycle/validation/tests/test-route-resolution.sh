#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../../.." && pwd)"
PACK_ROOT="$REPO_ROOT/.octon/inputs/additive/extensions/octon-proposal-lifecycle"
PUBLISHED_ROOT="$REPO_ROOT/.octon/generated/effective/extensions/published/octon-proposal-lifecycle/bundled-first-party"

pass_count=0
fail_count=0

pass() { printf 'PASS: %s\n' "$1"; pass_count=$((pass_count + 1)); }
fail() { printf 'FAIL: %s\n' "$1" >&2; fail_count=$((fail_count + 1)); }

publish_extensions() {
  bash "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/publish-extension-state.sh" >/dev/null
}

resolve_route_success() {
  local inputs_json="$1"
  bash "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-route.sh" \
    --pack-id octon-proposal-lifecycle \
    --dispatcher-id octon-proposal-lifecycle \
    --inputs-json "$inputs_json"
}

resolve_route_failure() {
  local inputs_json="$1"
  local output status
  set +e
  output="$(
    bash "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-route.sh" \
      --pack-id octon-proposal-lifecycle \
      --dispatcher-id octon-proposal-lifecycle \
      --inputs-json "$inputs_json"
  )"
  status=$?
  set -e
  [[ "$status" -ne 0 ]] || return 1
  printf '%s\n' "$output"
}

assert_json() {
  local label="$1" json="$2" query="$3"
  if jq -e "$query" >/dev/null <<<"$json"; then
    pass "$label"
  else
    fail "$label"
  fi
}

assert_file() {
  local label="$1" file="$2"
  [[ -f "$file" ]] && pass "$label" || fail "$label"
}

route_fixtures() {
  cat <<'EOF'
create-packet	octon-proposal-create-packet	octon-proposal-lifecycle-create-packet	octon-proposal-lifecycle-create-packet	{"source_kind":"requirements"}
explain-packet	octon-proposal-explain-packet	octon-proposal-lifecycle-explain-packet	octon-proposal-lifecycle-explain-packet	{"packet_path":".octon/inputs/exploratory/proposals/architecture/example"}
review-packet	octon-proposal-review-packet	octon-proposal-lifecycle-review-packet	octon-proposal-lifecycle-review-packet	{"packet_path":".octon/inputs/exploratory/proposals/architecture/example"}
revise-packet	octon-proposal-revise-packet	octon-proposal-lifecycle-revise-packet	octon-proposal-lifecycle-revise-packet	{"packet_path":".octon/inputs/exploratory/proposals/architecture/example"}
generate-packet-implementation-prompt	octon-proposal-generate-packet-implementation-prompt	octon-proposal-lifecycle-generate-packet-implementation-prompt	octon-proposal-lifecycle-generate-packet-implementation-prompt	{"packet_path":".octon/inputs/exploratory/proposals/architecture/example"}
run-packet-implementation	octon-proposal-run-packet-implementation	octon-proposal-lifecycle-run-packet-implementation	octon-proposal-lifecycle-run-packet-implementation	{"packet_path":".octon/inputs/exploratory/proposals/architecture/example"}
generate-packet-verification-prompt	octon-proposal-generate-packet-verification-prompt	octon-proposal-lifecycle-generate-packet-verification-prompt	octon-proposal-lifecycle-generate-packet-verification-prompt	{"packet_path":".octon/inputs/exploratory/proposals/architecture/example"}
generate-packet-correction-prompt	octon-proposal-generate-packet-correction-prompt	octon-proposal-lifecycle-generate-packet-correction-prompt	octon-proposal-lifecycle-generate-packet-correction-prompt	{"packet_path":".octon/inputs/exploratory/proposals/architecture/example","finding_id":"FINDING-001"}
run-packet-verification-and-correction-loop	octon-proposal-run-packet-verification-and-correction-loop	octon-proposal-lifecycle-run-packet-verification-and-correction-loop	octon-proposal-lifecycle-run-packet-verification-and-correction-loop	{"packet_path":".octon/inputs/exploratory/proposals/architecture/example"}
generate-packet-closeout-prompt	octon-proposal-generate-packet-closeout-prompt	octon-proposal-lifecycle-generate-packet-closeout-prompt	octon-proposal-lifecycle-generate-packet-closeout-prompt	{"packet_path":".octon/inputs/exploratory/proposals/architecture/example"}
closeout-packet	octon-proposal-closeout-packet	octon-proposal-lifecycle-closeout-packet	octon-proposal-lifecycle-closeout-packet	{"packet_path":".octon/inputs/exploratory/proposals/architecture/example"}
create-program	octon-proposal-create-program	octon-proposal-lifecycle-create-program	octon-proposal-lifecycle-create-program	{"child_packet_paths":[".octon/inputs/exploratory/proposals/architecture/child-a"]}
explain-program	octon-proposal-explain-program	octon-proposal-lifecycle-explain-program	octon-proposal-lifecycle-explain-program	{"program_packet_path":".octon/inputs/exploratory/proposals/architecture/program"}
review-program	octon-proposal-review-program	octon-proposal-lifecycle-review-program	octon-proposal-lifecycle-review-program	{"program_packet_path":".octon/inputs/exploratory/proposals/architecture/program"}
revise-program	octon-proposal-revise-program	octon-proposal-lifecycle-revise-program	octon-proposal-lifecycle-revise-program	{"program_packet_path":".octon/inputs/exploratory/proposals/architecture/program"}
generate-program-implementation-prompt	octon-proposal-generate-program-implementation-prompt	octon-proposal-lifecycle-generate-program-implementation-prompt	octon-proposal-lifecycle-generate-program-implementation-prompt	{"program_packet_path":".octon/inputs/exploratory/proposals/architecture/program"}
generate-program-verification-prompt	octon-proposal-generate-program-verification-prompt	octon-proposal-lifecycle-generate-program-verification-prompt	octon-proposal-lifecycle-generate-program-verification-prompt	{"program_packet_path":".octon/inputs/exploratory/proposals/architecture/program"}
generate-program-correction-prompt	octon-proposal-generate-program-correction-prompt	octon-proposal-lifecycle-generate-program-correction-prompt	octon-proposal-lifecycle-generate-program-correction-prompt	{"program_packet_path":".octon/inputs/exploratory/proposals/architecture/program","finding_id":"FINDING-001"}
cleanup-lifecycle-residue	octon-proposal-cleanup-lifecycle-residue	octon-proposal-lifecycle-cleanup-lifecycle-residue	octon-proposal-lifecycle-cleanup-lifecycle-residue	{"program_packet_path":".octon/inputs/exploratory/proposals/architecture/program"}
run-program-verification-and-correction-loop	octon-proposal-run-program-verification-and-correction-loop	octon-proposal-lifecycle-run-program-verification-and-correction-loop	octon-proposal-lifecycle-run-program-verification-and-correction-loop	{"program_packet_path":".octon/inputs/exploratory/proposals/architecture/program"}
generate-program-closeout-prompt	octon-proposal-generate-program-closeout-prompt	octon-proposal-lifecycle-generate-program-closeout-prompt	octon-proposal-lifecycle-generate-program-closeout-prompt	{"program_packet_path":".octon/inputs/exploratory/proposals/architecture/program"}
closeout-program	octon-proposal-closeout-program	octon-proposal-lifecycle-closeout-program	octon-proposal-lifecycle-closeout-program	{"program_packet_path":".octon/inputs/exploratory/proposals/architecture/program"}
EOF
}

assert_route_binding() {
  local label="$1" inputs="$2" route="$3" command="$4" skill="$5" prompt="$6"
  local json
  json="$(resolve_route_success "$inputs")"
  assert_json "$label" "$json" \
    ".status == \"resolved\" and .safe_to_run == true and .selected_route_id == \"$route\" and .selected_execution_binding.command_capability_id == \"$command\" and .selected_execution_binding.skill_capability_id == \"$skill\" and .selected_execution_binding.prompt_set_id == \"$prompt\""
}

assert_route_failure() {
  local label="$1" inputs="$2" route="$3" reason="$4"
  local json
  json="$(resolve_route_failure "$inputs")"
  assert_json "$label" "$json" \
    ".safe_to_run == false and .selected_route_id == \"$route\" and (.reason_codes | index(\"$reason\")) != null"
}

assert_source_and_published_binding_surfaces() {
  local route command skill prompt prompt_dir
  while IFS=$'\t' read -r route command skill prompt _extras; do
    [[ -n "$route" ]] || continue
    prompt_dir="${prompt#octon-proposal-lifecycle-}"
    assert_file "source command exists for $route" "$PACK_ROOT/commands/$command.md"
    assert_file "source skill exists for $route" "$PACK_ROOT/skills/$skill/SKILL.md"
    assert_file "source prompt manifest exists for $route" "$PACK_ROOT/prompts/$prompt_dir/manifest.yml"
    assert_file "published command exists for $route" "$PUBLISHED_ROOT/commands/$command.md"
    assert_file "published skill exists for $route" "$PUBLISHED_ROOT/skills/$skill/SKILL.md"
    assert_file "published prompt manifest exists for $route" "$PUBLISHED_ROOT/prompts/$prompt_dir/manifest.yml"
    if yq -e ".commands[]? | select(.id == \"$command\")" "$PACK_ROOT/commands/manifest.fragment.yml" >/dev/null 2>&1; then
      pass "command manifest declares $command"
    else
      fail "command manifest missing $command"
    fi
    if yq -e ".skills[]? | select(.id == \"$skill\")" "$PACK_ROOT/skills/manifest.fragment.yml" >/dev/null 2>&1; then
      pass "skill manifest declares $skill"
    else
      fail "skill manifest missing $skill"
    fi
    if yq -e ".skills.\"$skill\"" "$PACK_ROOT/skills/registry.fragment.yml" >/dev/null 2>&1; then
      pass "skill registry declares $skill"
    else
      fail "skill registry missing $skill"
    fi
  done < <(route_fixtures)
}

main() {
  local route command skill prompt extras json inputs bundle_inputs removed_finding_key
  publish_extensions

  while IFS=$'\t' read -r route command skill prompt extras; do
    [[ -n "$route" ]] || continue
    inputs="$(jq -cn --arg route "$route" --argjson extras "$extras" '$extras + {lifecycle_action: $route}')"
    assert_route_binding "action route resolves: $route" "$inputs" "$route" "$command" "$skill" "$prompt"
    bundle_inputs="$(jq -cn --arg route "$route" --argjson extras "$extras" '$extras + {bundle: $route}')"
    assert_route_binding "bundle route resolves: $route" "$bundle_inputs" "$route" "$command" "$skill" "$prompt"
  done < <(route_fixtures)

  json="$(resolve_route_success '{"source_kind":"audit"}')"
  assert_json "source-driven default creates packet" "$json" '.status == "resolved" and .selected_route_id == "create-packet"'

  json="$(resolve_route_success '{"source_kind":"audit","packet_path":".octon/inputs/exploratory/proposals/architecture/example"}')"
  assert_json "source-driven packet path still creates packet" "$json" '.status == "resolved" and .selected_route_id == "create-packet"'

  json="$(resolve_route_success '{"packet_path":".octon/inputs/exploratory/proposals/architecture/example"}')"
  assert_json "packet-path-only default explains packet" "$json" '.status == "resolved" and .selected_route_id == "explain-packet" and (.reason_codes | index("packet-path-read-only-default")) != null'

  json="$(resolve_route_success '{"child_packet_paths":[".octon/inputs/exploratory/proposals/architecture/child-a"]}')"
  assert_json "program input default creates program" "$json" '.status == "resolved" and .selected_route_id == "create-program"'

  json="$(resolve_route_success '{"program_packet_path":".octon/inputs/exploratory/proposals/architecture/program"}')"
  assert_json "program-path-only default explains program" "$json" '.status == "resolved" and .selected_route_id == "explain-program" and (.reason_codes | index("program-packet-path-read-only-default")) != null'

  assert_route_failure "unsupported bundle denies" '{"bundle":"not-a-route"}' "unsupported-route-id" "unsupported-route-id"
  assert_route_failure "missing inputs escalate" '{}' "missing-routeable-inputs" "missing-routeable-inputs"
  assert_route_failure "finding-only inputs escalate" '{"finding_id":"FINDING-001"}' "missing-routeable-inputs" "missing-routeable-inputs"
  removed_finding_key="$(printf '%s_%s_%s' verification finding id)"
  json="$(jq -cn --arg key "$removed_finding_key" '{lifecycle_action:"generate-packet-correction-prompt",packet_path:".octon/inputs/exploratory/proposals/architecture/example"} + {($key): "FINDING-002"}')"
  assert_route_failure "removed finding alias does not satisfy correction finding" "$json" "missing-required-inputs" "missing-finding-id"
  assert_route_failure "missing packet path escalates" '{"lifecycle_action":"closeout-packet"}' "missing-required-inputs" "missing-packet-path"
  assert_route_failure "missing correction finding escalates" '{"lifecycle_action":"generate-packet-correction-prompt","packet_path":".octon/inputs/exploratory/proposals/architecture/example"}' "missing-required-inputs" "missing-finding-id"
  assert_route_failure "missing program path for explicit explain escalates" '{"bundle":"explain-program"}' "missing-required-inputs" "missing-program-packet-path"
  assert_route_failure "missing program path for explicit review escalates" '{"bundle":"review-program"}' "missing-required-inputs" "missing-program-packet-path"
  assert_route_failure "missing program path for explicit revise escalates" '{"bundle":"revise-program"}' "missing-required-inputs" "missing-program-packet-path"
  assert_route_failure "missing program path for explicit cleanup escalates" '{"bundle":"cleanup-lifecycle-residue"}' "missing-required-inputs" "missing-program-packet-path"
  assert_route_failure "missing program path for action explain escalates" '{"lifecycle_action":"explain-program"}' "missing-required-inputs" "missing-program-packet-path"
  assert_route_failure "missing program path for action review escalates" '{"lifecycle_action":"review-program"}' "missing-required-inputs" "missing-program-packet-path"
  assert_route_failure "missing program path for action revise escalates" '{"lifecycle_action":"revise-program"}' "missing-required-inputs" "missing-program-packet-path"
  assert_route_failure "missing program path for action cleanup escalates" '{"lifecycle_action":"cleanup-lifecycle-residue"}' "missing-required-inputs" "missing-program-packet-path"
  assert_route_failure "missing program path escalates" '{"lifecycle_action":"closeout-program"}' "missing-required-inputs" "missing-program-packet-path"
  assert_route_failure "missing program correction finding escalates" '{"lifecycle_action":"generate-program-correction-prompt","program_packet_path":".octon/inputs/exploratory/proposals/architecture/program"}' "missing-required-inputs" "missing-finding-id"

  json="$(
    bash "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-prompt-bundle.sh" \
      --pack-id octon-proposal-lifecycle \
      --prompt-set-id octon-proposal-lifecycle-create-packet
  )"
  assert_json "prompt bundle resolves fresh" "$json" '.status == "fresh" and .safe_to_run == true'

  assert_source_and_published_binding_surfaces

  printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
