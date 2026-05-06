#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../../.." && pwd)"
PACK_ROOT="$REPO_ROOT/.octon/inputs/additive/extensions/octon-proposal-packet-lifecycle"
PUBLISHED_ROOT="$REPO_ROOT/.octon/generated/effective/extensions/published/octon-proposal-packet-lifecycle/bundled-first-party"

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
    --pack-id octon-proposal-packet-lifecycle \
    --dispatcher-id octon-proposal-packet-lifecycle \
    --inputs-json "$inputs_json"
}

resolve_route_failure() {
  local inputs_json="$1"
  local output status
  set +e
  output="$(
    bash "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-route.sh" \
      --pack-id octon-proposal-packet-lifecycle \
      --dispatcher-id octon-proposal-packet-lifecycle \
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
create-proposal-packet	octon-proposal-packet-create	octon-proposal-packet-lifecycle-create	octon-proposal-packet-lifecycle-create-proposal-packet	{"source_kind":"requirements"}
explain-proposal-packet	octon-proposal-packet-explain	octon-proposal-packet-lifecycle-explain	octon-proposal-packet-lifecycle-explain-proposal-packet	{"packet_path":".octon/inputs/exploratory/proposals/architecture/example"}
generate-implementation-prompt	octon-proposal-packet-generate-implementation-prompt	octon-proposal-packet-lifecycle-generate-implementation-prompt	octon-proposal-packet-lifecycle-generate-implementation-prompt	{"packet_path":".octon/inputs/exploratory/proposals/architecture/example"}
run-implementation	octon-proposal-packet-run-implementation	octon-proposal-packet-lifecycle-run-implementation	octon-proposal-packet-lifecycle-run-implementation	{"packet_path":".octon/inputs/exploratory/proposals/architecture/example"}
generate-verification-prompt	octon-proposal-packet-generate-verification-prompt	octon-proposal-packet-lifecycle-generate-verification-prompt	octon-proposal-packet-lifecycle-generate-verification-prompt	{"packet_path":".octon/inputs/exploratory/proposals/architecture/example"}
generate-correction-prompt	octon-proposal-packet-generate-correction-prompt	octon-proposal-packet-lifecycle-generate-correction-prompt	octon-proposal-packet-lifecycle-generate-correction-prompt	{"packet_path":".octon/inputs/exploratory/proposals/architecture/example","finding_id":"FINDING-001"}
run-verification-and-correction-loop	octon-proposal-packet-run-verification-and-correction-loop	octon-proposal-packet-lifecycle-run-verification-and-correction-loop	octon-proposal-packet-lifecycle-run-verification-and-correction-loop	{"packet_path":".octon/inputs/exploratory/proposals/architecture/example"}
generate-closeout-prompt	octon-proposal-packet-generate-closeout-prompt	octon-proposal-packet-lifecycle-generate-closeout-prompt	octon-proposal-packet-lifecycle-generate-closeout-prompt	{"packet_path":".octon/inputs/exploratory/proposals/architecture/example"}
closeout-proposal-packet	octon-proposal-packet-closeout	octon-proposal-packet-lifecycle-closeout	octon-proposal-packet-lifecycle-closeout-proposal-packet	{"packet_path":".octon/inputs/exploratory/proposals/architecture/example"}
create-proposal-program	octon-proposal-packet-create-program	octon-proposal-packet-lifecycle-create-program	octon-proposal-packet-lifecycle-create-proposal-program	{"child_packet_paths":[".octon/inputs/exploratory/proposals/architecture/child-a"]}
generate-program-implementation-prompt	octon-proposal-packet-generate-program-implementation-prompt	octon-proposal-packet-lifecycle-generate-program-implementation-prompt	octon-proposal-packet-lifecycle-generate-program-implementation-prompt	{"program_packet_path":".octon/inputs/exploratory/proposals/architecture/program"}
generate-program-verification-prompt	octon-proposal-packet-generate-program-verification-prompt	octon-proposal-packet-lifecycle-generate-program-verification-prompt	octon-proposal-packet-lifecycle-generate-program-verification-prompt	{"program_packet_path":".octon/inputs/exploratory/proposals/architecture/program"}
generate-program-correction-prompt	octon-proposal-packet-generate-program-correction-prompt	octon-proposal-packet-lifecycle-generate-program-correction-prompt	octon-proposal-packet-lifecycle-generate-program-correction-prompt	{"program_packet_path":".octon/inputs/exploratory/proposals/architecture/program","finding_id":"FINDING-001"}
run-program-verification-and-correction-loop	octon-proposal-packet-run-program-verification-and-correction-loop	octon-proposal-packet-lifecycle-run-program-verification-and-correction-loop	octon-proposal-packet-lifecycle-run-program-verification-and-correction-loop	{"program_packet_path":".octon/inputs/exploratory/proposals/architecture/program"}
generate-program-closeout-prompt	octon-proposal-packet-generate-program-closeout-prompt	octon-proposal-packet-lifecycle-generate-program-closeout-prompt	octon-proposal-packet-lifecycle-generate-program-closeout-prompt	{"program_packet_path":".octon/inputs/exploratory/proposals/architecture/program"}
closeout-proposal-program	octon-proposal-packet-closeout-program	octon-proposal-packet-lifecycle-closeout-program	octon-proposal-packet-lifecycle-closeout-proposal-program	{"program_packet_path":".octon/inputs/exploratory/proposals/architecture/program"}
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
    prompt_dir="${prompt#octon-proposal-packet-lifecycle-}"
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
  local route command skill prompt extras json inputs bundle_inputs
  publish_extensions

  while IFS=$'\t' read -r route command skill prompt extras; do
    [[ -n "$route" ]] || continue
    inputs="$(jq -cn --arg route "$route" --argjson extras "$extras" '$extras + {lifecycle_action: $route}')"
    assert_route_binding "action route resolves: $route" "$inputs" "$route" "$command" "$skill" "$prompt"
    bundle_inputs="$(jq -cn --arg route "$route" --argjson extras "$extras" '$extras + {bundle: $route}')"
    assert_route_binding "bundle route resolves: $route" "$bundle_inputs" "$route" "$command" "$skill" "$prompt"
  done < <(route_fixtures)

  json="$(resolve_route_success '{"source_kind":"audit"}')"
  assert_json "source-driven default creates packet" "$json" '.status == "resolved" and .selected_route_id == "create-proposal-packet"'

  json="$(resolve_route_success '{"source_kind":"audit","packet_path":".octon/inputs/exploratory/proposals/architecture/example"}')"
  assert_json "source-driven packet path still creates packet" "$json" '.status == "resolved" and .selected_route_id == "create-proposal-packet"'

  json="$(resolve_route_success '{"packet_path":".octon/inputs/exploratory/proposals/architecture/example"}')"
  assert_json "packet-path-only default explains packet" "$json" '.status == "resolved" and .selected_route_id == "explain-proposal-packet" and (.reason_codes | index("packet-path-read-only-default")) != null'

  json="$(resolve_route_success '{"child_packet_paths":[".octon/inputs/exploratory/proposals/architecture/child-a"]}')"
  assert_json "program input default creates program" "$json" '.status == "resolved" and .selected_route_id == "create-proposal-program"'

  json="$(resolve_route_success '{"lifecycle_action":"generate-correction-prompt","packet_path":".octon/inputs/exploratory/proposals/architecture/example","verification_finding_id":"FINDING-002"}')"
  assert_json "legacy verification_finding_id alias resolves correction" "$json" '.status == "resolved" and .selected_route_id == "generate-correction-prompt"'

  assert_route_failure "unsupported bundle denies" '{"bundle":"not-a-route"}' "unsupported-route-id" "unsupported-route-id"
  assert_route_failure "missing inputs escalate" '{}' "missing-routeable-inputs" "missing-routeable-inputs"
  assert_route_failure "finding-only inputs escalate" '{"finding_id":"FINDING-001"}' "missing-routeable-inputs" "missing-routeable-inputs"
  assert_route_failure "missing packet path escalates" '{"lifecycle_action":"closeout-proposal-packet"}' "missing-required-inputs" "missing-packet-path"
  assert_route_failure "missing correction finding escalates" '{"lifecycle_action":"generate-correction-prompt","packet_path":".octon/inputs/exploratory/proposals/architecture/example"}' "missing-required-inputs" "missing-finding-id"
  assert_route_failure "missing program path escalates" '{"lifecycle_action":"closeout-proposal-program"}' "missing-required-inputs" "missing-program-packet-path"
  assert_route_failure "missing program correction finding escalates" '{"lifecycle_action":"generate-program-correction-prompt","program_packet_path":".octon/inputs/exploratory/proposals/architecture/program"}' "missing-required-inputs" "missing-finding-id"
  assert_route_failure "program-packet-only route escalates" '{"program_packet_path":".octon/inputs/exploratory/proposals/architecture/program"}' "missing-required-inputs" "ambiguous-program-packet-route"

  json="$(
    bash "$REPO_ROOT/.octon/framework/orchestration/runtime/_ops/scripts/resolve-extension-prompt-bundle.sh" \
      --pack-id octon-proposal-packet-lifecycle \
      --prompt-set-id octon-proposal-packet-lifecycle-create-proposal-packet
  )"
  assert_json "prompt bundle resolves fresh" "$json" '.status == "fresh" and .safe_to_run == true'

  assert_source_and_published_binding_surfaces

  printf '\nPassed: %s\nFailed: %s\n' "$pass_count" "$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
