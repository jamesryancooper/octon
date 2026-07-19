#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
AI_GATE_DIR="$ROOT_DIR/.octon/framework/execution-roles/_ops/scripts/ai-gate"
POLICY="$ROOT_DIR/.octon/framework/execution-roles/practices/standards/ai-gate-policy.json"
SCHEMA="$ROOT_DIR/.octon/framework/execution-roles/practices/standards/ai-gate-findings.schema.json"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT

eval_word="ev""al"
delete_command="rm -""rf"
spawn_word="spa""wn"
safe_script="$TMP_DIR/safe-cleanup.sh"
openai_diff="$TMP_DIR/openai.diff"
anthropic_diff="$TMP_DIR/anthropic.diff"
openai_output="$TMP_DIR/openai.json"
anthropic_output="$TMP_DIR/anthropic.json"

printf '%s\n' 'TMP_DIR="$(mktemp -d)"' >"$safe_script"

{
  printf '%s\n' \
    'diff --git a/unsafe.sh b/unsafe.sh' \
    '+++ b/unsafe.sh' \
    '@@ -0,0 +1,3 @@'
  printf '+%s(user_input)\n' "$eval_word"
  printf "+grep -Eq '^%s[[:space:]]*\\(' input.sh\n" "$eval_word"
  printf '+%s /\n' "$delete_command"
  printf '%s\n' \
    "diff --git a/$safe_script b/$safe_script" \
    "+++ b/$safe_script" \
    '@@ -0,0 +1 @@'
  printf "+trap '%s -- \"\$TMP_DIR\"' EXIT\n" "$delete_command"
} >"$openai_diff"

OPENAI_API_KEY=test \
  bash "$AI_GATE_DIR/provider-openai.sh" \
  --policy "$POLICY" \
  --schema "$SCHEMA" \
  --diff "$openai_diff" \
  --output "$openai_output" >/dev/null

if ! jq -e '
  (.findings | length) == 2 and
  ([.findings[].title] | index("Potential unsafe eval introduced") != null) and
  ([.findings[].title] | index("Potential destructive command added") != null) and
  ([.findings[].file] | all(. == "unsafe.sh"))
' "$openai_output" >/dev/null; then
  jq . "$openai_output" >&2
  exit 1
fi

{
  printf '%s\n' \
    'diff --git a/.octon/inputs/exploratory/proposals/example/proposal.yml b/.octon/inputs/exploratory/proposals/example/proposal.yml' \
    '+++ b/.octon/inputs/exploratory/proposals/example/proposal.yml' \
    '@@ -0,0 +1 @@'
  printf '+spawn_anchor: "command.%s()"\n' "$spawn_word"
  printf '%s\n' \
    'diff --git a/launcher.js b/launcher.js' \
    '+++ b/launcher.js' \
    '@@ -0,0 +1 @@'
  printf '+child.%s(userInput)\n' "$spawn_word"
  printf '%s\n' \
    'diff --git a/.octon/framework/orchestration/runtime/workflows/example/workflow.yml b/.octon/framework/orchestration/runtime/workflows/example/workflow.yml' \
    '+++ b/.octon/framework/orchestration/runtime/workflows/example/workflow.yml' \
    '@@ -0,0 +1 @@'
  printf '+command: child.%s(userInput)\n' "$spawn_word"
} >"$anthropic_diff"

ANTHROPIC_API_KEY=test \
  bash "$AI_GATE_DIR/provider-anthropic.sh" \
  --policy "$POLICY" \
  --schema "$SCHEMA" \
  --diff "$anthropic_diff" \
  --output "$anthropic_output" >/dev/null

if ! jq -e '
  (.findings | length) == 2 and
  ([.findings[].title] | all(. == "Potential shell/process execution path added")) and
  ([.findings[].file] | sort) == [
    ".octon/framework/orchestration/runtime/workflows/example/workflow.yml",
    "launcher.js"
  ]
' "$anthropic_output" >/dev/null; then
  jq . "$anthropic_output" >&2
  exit 1
fi

echo "AI gate provider context tests passed"
