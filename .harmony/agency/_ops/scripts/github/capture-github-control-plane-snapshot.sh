#!/usr/bin/env bash
set -euo pipefail

REPO=""
OUT_DIR=".harmony/output/reports/analysis"
OUT_BASENAME=""

usage() {
  cat <<'USAGE'
Usage:
  capture-github-control-plane-snapshot.sh [--repo <owner/repo>] [--out-dir <path>] [--basename <name>]

Captures a GitHub control-plane snapshot used for autonomy workflow baseline and drift checks.
Writes:
  - <out-dir>/<basename>.json
  - <out-dir>/<basename>.md
USAGE
}

error() {
  echo "[ERROR] $1" >&2
  exit 1
}

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || error "Missing required command: $cmd"
}

repo_from_origin() {
  local remote
  remote="$(git config --get remote.origin.url 2>/dev/null || true)"
  if [[ -z "$remote" ]]; then
    return 1
  fi

  if [[ "$remote" =~ ^https?://github\.com/([^/]+)/([^/]+)\.git$ ]]; then
    echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
    return 0
  fi

  if [[ "$remote" =~ ^https?://github\.com/([^/]+)/([^/]+)$ ]]; then
    echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
    return 0
  fi

  if [[ "$remote" =~ ^git@github\.com:([^/]+)/([^/]+)\.git$ ]]; then
    echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
    return 0
  fi

  if [[ "$remote" =~ ^git@github\.com:([^/]+)/([^/]+)$ ]]; then
    echo "${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
    return 0
  fi

  return 1
}

capture_cmd() {
  local key="$1"
  shift
  local out_file="$TMP_DIR/${key}.json"
  local stdout_file stderr_file
  stdout_file="$(mktemp)"
  stderr_file="$(mktemp)"

  if "$@" >"${stdout_file}" 2>"${stderr_file}"; then
    jq -n \
      --arg status "ok" \
      --arg command "$*" \
      --arg stdout "$(cat "${stdout_file}")" \
      --arg stderr "$(cat "${stderr_file}")" \
      --argjson exit_code 0 \
      '{status:$status,command:$command,stdout:$stdout,stderr:$stderr,exit_code:$exit_code}' >"${out_file}"
  else
    local rc=$?
    jq -n \
      --arg status "error" \
      --arg command "$*" \
      --arg stdout "$(cat "${stdout_file}")" \
      --arg stderr "$(cat "${stderr_file}")" \
      --argjson exit_code "${rc}" \
      '{status:$status,command:$command,stdout:$stdout,stderr:$stderr,exit_code:$exit_code}' >"${out_file}"
  fi

  rm -f "${stdout_file}" "${stderr_file}"
}

extract_required_checks_from_rulesets() {
  local rulesets_payload="$1"
  jq -rc '
    [
      .[]?
      | .rules[]?
      | select(.type == "required_status_checks")
      | .parameters.required_status_checks[]?.context
    ]
    | unique
    | sort
  ' <<<"${rulesets_payload}" 2>/dev/null || echo '[]'
}

extract_required_checks_from_branch_protection() {
  local branch_payload="$1"
  jq -rc '
    [
      (.required_status_checks.contexts[]? // empty),
      (.required_status_checks.checks[]?.context // empty)
    ]
    | unique
    | sort
  ' <<<"${branch_payload}" 2>/dev/null || echo '[]'
}

build_markdown_report() {
  local json_path="$1"
  local md_path="$2"

  local repo generated
  repo="$(jq -r '.repository' "${json_path}")"
  generated="$(jq -r '.generated_at_utc' "${json_path}")"

  {
    echo "# GitHub Control-Plane Baseline"
    echo
    echo "- Repository: \`${repo}\`"
    echo "- Generated (UTC): \`${generated}\`"
    echo

    echo "## Capture Status"
    jq -r '
      .captures
      | to_entries[]
      | "- " + .key + ": " + .value.status + " (exit=" + (.value.exit_code|tostring) + ")"
    ' "${json_path}"
    echo

    echo "## Merge And Repo Settings"
    jq -r '
      if .captures.repo_settings.status != "ok" then
        "- unavailable (" + (.captures.repo_settings.stderr | gsub("\\n"; " ")) + ")"
      else
        (.captures.repo_settings.stdout | fromjson) as $repo
        | [
            "- default_branch: `\($repo.default_branch // "unknown")`",
            "- allow_auto_merge: `\($repo.allow_auto_merge // "unknown")`",
            "- allow_squash_merge: `\($repo.allow_squash_merge // "unknown")`",
            "- allow_merge_commit: `\($repo.allow_merge_commit // "unknown")`",
            "- allow_rebase_merge: `\($repo.allow_rebase_merge // "unknown")`",
            "- delete_branch_on_merge: `\($repo.delete_branch_on_merge // "unknown")`"
          ]
        | .[]
      end
    ' "${json_path}"
    echo

    echo "## Actions Workflow Permission"
    jq -r '
      if .captures.workflow_permissions.status != "ok" then
        "- unavailable (" + (.captures.workflow_permissions.stderr | gsub("\\n"; " ")) + ")"
      else
        (.captures.workflow_permissions.stdout | fromjson) as $wf
        | [
            "- can_approve_pull_request_reviews: `\($wf.can_approve_pull_request_reviews // "unknown")`",
            "- default_workflow_permissions: `\($wf.default_workflow_permissions // "unknown")`"
          ]
        | .[]
      end
    ' "${json_path}"
    echo

    echo "## Required Checks (Derived)"
    jq -r '
      if (.derived.required_checks | length) == 0 then
        "- none discovered"
      else
        .derived.required_checks[] | "- `" + . + "`"
      end
    ' "${json_path}"
    echo

    echo "## Required Label/Secret/Variable Presence"
    jq -r '
      .derived.required_presence
      | to_entries[]
      | "- " + .key + ": `" + (.value|tostring) + "`"
    ' "${json_path}"
    echo

    echo "## Ruleset Snapshot"
    jq -r '
      if .captures.rulesets.status != "ok" then
        "- unavailable (" + (.captures.rulesets.stderr | gsub("\\n"; " ")) + ")"
      else
        (.captures.rulesets.stdout | fromjson) as $rulesets
        | if ($rulesets | length) == 0 then
            "- no rulesets returned"
          else
            ($rulesets[] | "- id=\(.id) name=\(.name // "(unnamed)") target=\(.target // "unknown") enforcement=\(.enforcement // "unknown")")
          end
      end
    ' "${json_path}"
    echo

    echo "## Raw Snapshot"
    echo "- JSON artifact: \`$(basename "${json_path}")\`"
  } >"${md_path}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      shift
      [[ $# -gt 0 ]] || error "--repo requires a value"
      REPO="$1"
      ;;
    --out-dir)
      shift
      [[ $# -gt 0 ]] || error "--out-dir requires a value"
      OUT_DIR="$1"
      ;;
    --basename)
      shift
      [[ $# -gt 0 ]] || error "--basename requires a value"
      OUT_BASENAME="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      error "Unknown argument: $1"
      ;;
  esac
  shift
done

require_cmd gh
require_cmd jq
require_cmd git

if [[ -z "$REPO" ]]; then
  REPO="$(repo_from_origin || true)"
fi
[[ -n "$REPO" ]] || error "Unable to infer repository. Pass --repo <owner/repo>."

mkdir -p "${OUT_DIR}"

DATE_UTC="$(date -u +%Y-%m-%d)"
STAMP_UTC="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
if [[ -z "$OUT_BASENAME" ]]; then
  OUT_BASENAME="${DATE_UTC}-github-control-plane-baseline"
fi

OUT_JSON="${OUT_DIR}/${OUT_BASENAME}.json"
OUT_MD="${OUT_DIR}/${OUT_BASENAME}.md"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

capture_cmd repo_settings gh api "repos/${REPO}"
capture_cmd rulesets gh api "repos/${REPO}/rulesets?includes_parents=false"
capture_cmd actions_permissions gh api "repos/${REPO}/actions/permissions"
capture_cmd workflow_permissions gh api "repos/${REPO}/actions/permissions/workflow"
capture_cmd branch_protection_main gh api "repos/${REPO}/branches/main/protection"
capture_cmd secrets gh secret list --app actions --repo "${REPO}" --json name
capture_cmd variables gh variable list --repo "${REPO}" --json name

required_checks='[]'
if [[ "$(jq -r '.status' "${TMP_DIR}/rulesets.json")" == "ok" ]]; then
  required_checks="$(extract_required_checks_from_rulesets "$(jq -r '.stdout' "${TMP_DIR}/rulesets.json")")"
fi
if [[ "${required_checks}" == "[]" ]] && [[ "$(jq -r '.status' "${TMP_DIR}/branch_protection_main.json")" == "ok" ]]; then
  required_checks="$(extract_required_checks_from_branch_protection "$(jq -r '.stdout' "${TMP_DIR}/branch_protection_main.json")")"
fi

secret_names='[]'
if [[ "$(jq -r '.status' "${TMP_DIR}/secrets.json")" == "ok" ]]; then
  secret_names="$(jq -rc '[.[]?.name] | unique | sort' <<<"$(jq -r '.stdout' "${TMP_DIR}/secrets.json")")"
fi

variable_names='[]'
if [[ "$(jq -r '.status' "${TMP_DIR}/variables.json")" == "ok" ]]; then
  variable_names="$(jq -rc '[.[]?.name] | unique | sort' <<<"$(jq -r '.stdout' "${TMP_DIR}/variables.json")")"
fi

required_presence="$(jq -n \
  --argjson secret_names "${secret_names}" \
  --argjson variable_names "${variable_names}" \
  '{
    AUTONOMY_PAT_secret: ($secret_names | index("AUTONOMY_PAT") != null),
    OPENAI_API_KEY_secret: ($secret_names | index("OPENAI_API_KEY") != null),
    ANTHROPIC_API_KEY_secret: ($secret_names | index("ANTHROPIC_API_KEY") != null),
    AUTONOMY_AUTO_MERGE_ENABLED_variable: ($variable_names | index("AUTONOMY_AUTO_MERGE_ENABLED") != null),
    AUTONOMY_POLICY_ENFORCE_variable: ($variable_names | index("AUTONOMY_POLICY_ENFORCE") != null),
    AI_GATE_ENFORCE_variable: ($variable_names | index("AI_GATE_ENFORCE") != null)
  }'
)"

jq -n \
  --arg generated_at_utc "${STAMP_UTC}" \
  --arg repository "${REPO}" \
  --argjson repo_settings "$(cat "${TMP_DIR}/repo_settings.json")" \
  --argjson rulesets "$(cat "${TMP_DIR}/rulesets.json")" \
  --argjson actions_permissions "$(cat "${TMP_DIR}/actions_permissions.json")" \
  --argjson workflow_permissions "$(cat "${TMP_DIR}/workflow_permissions.json")" \
  --argjson branch_protection_main "$(cat "${TMP_DIR}/branch_protection_main.json")" \
  --argjson secrets "$(cat "${TMP_DIR}/secrets.json")" \
  --argjson variables "$(cat "${TMP_DIR}/variables.json")" \
  --argjson required_checks "${required_checks}" \
  --argjson required_presence "${required_presence}" \
  '{
    generated_at_utc: $generated_at_utc,
    repository: $repository,
    captures: {
      repo_settings: $repo_settings,
      rulesets: $rulesets,
      actions_permissions: $actions_permissions,
      workflow_permissions: $workflow_permissions,
      branch_protection_main: $branch_protection_main,
      secrets: $secrets,
      variables: $variables
    },
    derived: {
      required_checks: $required_checks,
      required_presence: $required_presence
    }
  }' >"${OUT_JSON}"

build_markdown_report "${OUT_JSON}" "${OUT_MD}"

echo "[OK] Wrote snapshot JSON: ${OUT_JSON}"
echo "[OK] Wrote snapshot report: ${OUT_MD}"
