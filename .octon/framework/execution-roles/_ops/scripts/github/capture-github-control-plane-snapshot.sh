#!/usr/bin/env bash
set -euo pipefail

REPO=""
BASE_SHA=""
CANDIDATE_SHA=""
OUT_DIR=".octon/state/evidence/validation/analysis"
OUT_BASENAME=""
COMPARE_TO=""
GH_BIN="${OCTON_GH_BIN:-gh}"
API_VERSION="2026-03-10"

usage() {
  cat <<'USAGE'
Usage:
  capture-github-control-plane-snapshot.sh --repo <owner/repo> --base-sha <40-hex> --candidate-sha <40-hex> [--out-dir <path>] [--basename <name>] [--compare-to <snapshot.json>]

Performs exhaustive read-only GitHub API capture with --paginate/--slurp,
fails closed on any missing or malformed family, and writes canonical JSON and
Markdown evidence. The helper never captures secret values or mutates GitHub.
USAGE
}

error() { echo "[ERROR] $1" >&2; exit 1; }
require_cmd() { command -v "$1" >/dev/null 2>&1 || error "missing required command: $1"; }
exact_sha() { [[ "$1" =~ ^[0-9a-f]{40}$ ]]; }

repo_from_origin() {
  local remote path
  remote="$(git config --get remote.origin.url 2>/dev/null || true)"
  case "$remote" in
    https://github.com/*) path="${remote#https://github.com/}" ;;
    git@github.com:*) path="${remote#git@github.com:}" ;;
    *) return 1 ;;
  esac
  path="${path%.git}"
  [[ "$path" == */* ]] || return 1
  printf '%s\n' "$path"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) shift; REPO="${1:-}" ;;
    --base-sha) shift; BASE_SHA="${1:-}" ;;
    --candidate-sha) shift; CANDIDATE_SHA="${1:-}" ;;
    --out-dir) shift; OUT_DIR="${1:-}" ;;
    --basename) shift; OUT_BASENAME="${1:-}" ;;
    --compare-to) shift; COMPARE_TO="${1:-}" ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; error "unknown argument: $1" ;;
  esac
  shift
done

require_cmd jq
require_cmd git
require_cmd shasum
if [[ "$GH_BIN" == */* ]]; then
  [[ -x "$GH_BIN" ]] || error "GitHub API adapter is not executable: $GH_BIN"
else
  require_cmd "$GH_BIN"
fi

[[ -n "$REPO" ]] || REPO="$(repo_from_origin || true)"
[[ "$REPO" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || error "--repo must be owner/repo"
exact_sha "$BASE_SHA" || error "--base-sha must be an exact lowercase 40-hex SHA"
exact_sha "$CANDIDATE_SHA" || error "--candidate-sha must be an exact lowercase 40-hex SHA"
[[ "$BASE_SHA" != "$CANDIDATE_SHA" ]] || error "base and candidate SHAs must differ"
[[ -z "$COMPARE_TO" || -f "$COMPARE_TO" ]] || error "comparison snapshot missing: $COMPARE_TO"

mkdir -p "$OUT_DIR"
STAMP_UTC="${OCTON_FIXED_UTC:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"
DATE_UTC="${STAMP_UTC%%T*}"
[[ -n "$OUT_BASENAME" ]] || OUT_BASENAME="${DATE_UTC}-github-control-plane-baseline"
OUT_JSON="$OUT_DIR/$OUT_BASENAME.json"
OUT_MD="$OUT_DIR/$OUT_BASENAME.md"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/octon-github-snapshot.XXXXXX")"
trap 'rm -rf -- "$TMP_DIR"' EXIT

api() {
  "$GH_BIN" api -H "X-GitHub-Api-Version: $API_VERSION" "$@"
}

capture_single() {
  local key="$1" endpoint="$2" raw out
  raw="$TMP_DIR/$key.raw.json"
  out="$TMP_DIR/$key.json"
  api "$endpoint" >"$raw" || error "GitHub endpoint failed: $endpoint"
  jq -e . "$raw" >/dev/null 2>&1 || error "GitHub endpoint returned malformed JSON: $endpoint"
  jq -S -c . "$raw" >"$out"
}

capture_paginated() {
  local key="$1" endpoint="$2" filter="$3" raw out
  raw="$TMP_DIR/$key.raw.json"
  out="$TMP_DIR/$key.json"
  api --paginate --slurp "$endpoint" >"$raw" || error "paginated GitHub endpoint failed: $endpoint"
  jq -e 'type == "array" and length > 0' "$raw" >/dev/null 2>&1 || error "paginated endpoint returned no complete page set: $endpoint"
  jq -S -c "$filter" "$raw" >"$out" || error "paginated endpoint shape is incomplete: $endpoint"
  jq -e 'type == "array"' "$out" >/dev/null 2>&1 || error "normalized paginated family is not an array: $key"
}

capture_single repo_settings "repos/$REPO"
capture_paginated rulesets "repos/$REPO/rulesets?includes_parents=false&per_page=100" '[.[] | if type == "array" then .[] else error("rulesets page") end]'
capture_single branch_protection "repos/$REPO/branches/main/protection"
capture_single actions_permissions "repos/$REPO/actions/permissions"
capture_single workflow_permissions "repos/$REPO/actions/permissions/workflow"
capture_paginated workflows "repos/$REPO/actions/workflows?per_page=100" '[.[] | .workflows[]?]'
capture_paginated workflow_runs "repos/$REPO/actions/runs?per_page=100" '[.[] | .workflow_runs[]?]'
capture_paginated variables "repos/$REPO/actions/variables?per_page=100" '[.[] | .variables[]?]'
capture_paginated secrets "repos/$REPO/actions/secrets?per_page=100" '[.[] | .secrets[]? | {name, created_at, updated_at}]'
capture_paginated installations "repos/$REPO/installations?per_page=100" '[.[] | .installations[]? | {id, app_id, app_slug, target_id, target_type, permissions, events, suspended_at}]'
capture_paginated environments "repos/$REPO/environments?per_page=100" '[.[] | .environments[]?]'
capture_paginated deploy_keys "repos/$REPO/keys?per_page=100" '[.[] | if type == "array" then .[] else error("deploy-key page") end | {id, title, read_only, verified, enabled, created_at}]'
capture_paginated collaborators "repos/$REPO/collaborators?affiliation=all&permission=admin&per_page=100" '[.[] | if type == "array" then .[] else error("collaborator page") end | {login, id, type, site_admin, permissions, role_name}]'
capture_paginated base_check_runs "repos/$REPO/commits/$BASE_SHA/check-runs?per_page=100" '[.[] | .check_runs[]? | {id, name, head_sha, status, conclusion, app: {id: .app.id, slug: .app.slug}, external_id, details_url}]'
capture_paginated candidate_check_runs "repos/$REPO/commits/$CANDIDATE_SHA/check-runs?per_page=100" '[.[] | .check_runs[]? | {id, name, head_sha, status, conclusion, app: {id: .app.id, slug: .app.slug}, external_id, details_url}]'

environment_details="$TMP_DIR/environment_details.json"
printf '[]\n' >"$environment_details"
while IFS= read -r environment_name; do
  [[ -n "$environment_name" ]] || continue
  encoded_name="$(jq -rn --arg value "$environment_name" '$value|@uri')"
  detail_key="environment-$(printf '%s' "$environment_name" | shasum -a 256 | awk '{print substr($1,1,16)}')"
  capture_single "$detail_key" "repos/$REPO/environments/$encoded_name"
  jq -S -c --slurpfile detail "$TMP_DIR/$detail_key.json" '. + [$detail[0] | {id, name, protected_branches, protection_rules, deployment_branch_policy}]' "$environment_details" >"$environment_details.next"
  mv "$environment_details.next" "$environment_details"
done < <(jq -r '.[].name // empty' "$TMP_DIR/environments.json")

active_runs="$TMP_DIR/active_runs.json"
jq -S -c '[.[] | select(.status == "queued" or .status == "requested" or .status == "waiting" or .status == "pending" or .status == "in_progress") | {id, workflow_id, name, event, status, head_sha, head_branch, run_attempt, created_at, updated_at}]' "$TMP_DIR/workflow_runs.json" >"$active_runs"

required_checks="$TMP_DIR/required_checks.json"
jq -S -c --slurpfile protection "$TMP_DIR/branch_protection.json" '
  ([.[]? | .rules[]? | select(.type == "required_status_checks") | .parameters.required_status_checks[]?.context]
   + [$protection[0].required_status_checks.contexts[]?]
   + [$protection[0].required_status_checks.checks[]?.context]) | unique | sort
' "$TMP_DIR/rulesets.json" >"$required_checks"

base_producers="$TMP_DIR/base_producers.json"
candidate_producers="$TMP_DIR/candidate_producers.json"
jq -S -c '[.[] | {name, head_sha, status, conclusion, app_id: .app.id, app_slug: .app.slug, details_url}] | sort_by(.name, .app_id, .id)' "$TMP_DIR/base_check_runs.json" >"$base_producers"
jq -S -c '[.[] | {name, head_sha, status, conclusion, app_id: .app.id, app_slug: .app.slug, details_url}] | sort_by(.name, .app_id, .id)' "$TMP_DIR/candidate_check_runs.json" >"$candidate_producers"

jq -e --arg sha "$BASE_SHA" 'all(.[]; .head_sha == $sha)' "$base_producers" >/dev/null || error "base check-run family contains another SHA"
jq -e --arg sha "$CANDIDATE_SHA" 'all(.[]; .head_sha == $sha)' "$candidate_producers" >/dev/null || error "candidate check-run family contains another SHA"

payload="$TMP_DIR/payload.json"
jq -S -n \
  --arg repository "$REPO" \
  --arg base_sha "$BASE_SHA" \
  --arg candidate_sha "$CANDIDATE_SHA" \
  --arg api_version "$API_VERSION" \
  --slurpfile repo_settings "$TMP_DIR/repo_settings.json" \
  --slurpfile rulesets "$TMP_DIR/rulesets.json" \
  --slurpfile branch_protection "$TMP_DIR/branch_protection.json" \
  --slurpfile actions_permissions "$TMP_DIR/actions_permissions.json" \
  --slurpfile workflow_permissions "$TMP_DIR/workflow_permissions.json" \
  --slurpfile workflows "$TMP_DIR/workflows.json" \
  --slurpfile active_runs "$active_runs" \
  --slurpfile variables "$TMP_DIR/variables.json" \
  --slurpfile secrets "$TMP_DIR/secrets.json" \
  --slurpfile installations "$TMP_DIR/installations.json" \
  --slurpfile environments "$environment_details" \
  --slurpfile deploy_keys "$TMP_DIR/deploy_keys.json" \
  --slurpfile collaborators "$TMP_DIR/collaborators.json" \
  --slurpfile required_checks "$required_checks" \
  --slurpfile base_producers "$base_producers" \
  --slurpfile candidate_producers "$candidate_producers" '
  {
    binding: {repository: $repository, base_sha: $base_sha, candidate_sha: $candidate_sha, api_version: $api_version},
    captures: {
      repository: $repo_settings[0],
      rulesets: $rulesets[0],
      branch_protection: $branch_protection[0],
      actions_permissions: $actions_permissions[0],
      workflow_permissions: $workflow_permissions[0],
      workflows: $workflows[0],
      active_runs: $active_runs[0],
      variables: $variables[0],
      secret_names: $secrets[0],
      installations: $installations[0],
      environments: $environments[0],
      deploy_keys: $deploy_keys[0],
      admitted_admin_identities: $collaborators[0]
    },
    derived: {
      required_checks: $required_checks[0],
      check_run_producers: {base: $base_producers[0], candidate: $candidate_producers[0]},
      active_unsafe_statuses: ["queued", "requested", "waiting", "pending", "in_progress"],
      advisory_marker: ([ $variables[0][] | select(.name == "OCTON_RP00_OWNER_LANE_LEASE") ] | if length == 0 then {state:"expected-absent"} else {state:"present", records:.} end)
    }
  }
' >"$payload"

canonical_payload="$(jq -S -c . "$payload")"
canonical_sha256="sha256:$(printf '%s' "$canonical_payload" | shasum -a 256 | awk '{print $1}')"

family_digests="$TMP_DIR/family_digests.json"
jq -r '.captures | keys[]' "$payload" | while IFS= read -r family; do
  family_json="$(jq -S -c --arg family "$family" '.captures[$family]' "$payload")"
  family_digest="sha256:$(printf '%s' "$family_json" | shasum -a 256 | awk '{print $1}')"
  jq -n --arg family "$family" --arg digest "$family_digest" '{key:$family,value:$digest}'
done | jq -S -s 'from_entries' >"$family_digests"

comparison="$TMP_DIR/comparison.json"
if [[ -n "$COMPARE_TO" ]]; then
  jq -e '.schema_version == "github-control-plane-snapshot-v2" and .capture_complete == true' "$COMPARE_TO" >/dev/null 2>&1 || error "comparison snapshot is incomplete or wrong version"
  jq -S -n \
    --arg prior_ref "$COMPARE_TO" \
    --arg prior_digest "$(jq -r '.canonical_sha256' "$COMPARE_TO")" \
    --arg current_digest "$canonical_sha256" \
    --slurpfile prior "$COMPARE_TO" \
    --slurpfile current "$payload" \
    --slurpfile current_families "$family_digests" '
    ($prior[0].capture_family_sha256 // {}) as $prior_families |
    $current_families[0] as $current_family_map |
    {
      prior_ref: $prior_ref,
      prior_canonical_sha256: $prior_digest,
      current_canonical_sha256: $current_digest,
      binding_equal: ($prior[0].binding == $current[0].binding),
      changed_capture_families: ([($prior_families | keys[]), ($current_family_map | keys[])] | unique | map(select(($prior_families[.] // "") != ($current_family_map[.] // ""))))
    }
  ' >"$comparison"
else
  printf 'null\n' >"$comparison"
fi

jq -S -n \
  --arg schema_version "github-control-plane-snapshot-v2" \
  --arg generated_at_utc "$STAMP_UTC" \
  --arg canonical_sha256 "$canonical_sha256" \
  --slurpfile payload "$payload" \
  --slurpfile family_digests "$family_digests" \
  --slurpfile comparison "$comparison" '
  {
    schema_version: $schema_version,
    capture_complete: true,
    generated_at_utc: $generated_at_utc,
    binding: $payload[0].binding,
    canonical_sha256: $canonical_sha256,
    canonical_digest_scope: "binding,captures,derived; generated_at and comparison excluded",
    capture_family_sha256: $family_digests[0],
    captures: $payload[0].captures,
    derived: $payload[0].derived,
    comparison: $comparison[0],
    redaction: {secret_values_captured:false, raw_credentials_captured:false, authorization_headers_captured:false, provider_token_session_fingerprint_claimed:false},
    pagination: {mode:"gh api --paginate --slurp", complete:true}
  }
' >"$OUT_JSON"

{
  echo "# GitHub SI-00 Control-Plane Snapshot"
  echo
  echo "- Repository: \`$REPO\`"
  echo "- Base SHA: \`$BASE_SHA\`"
  echo "- Candidate SHA: \`$CANDIDATE_SHA\`"
  echo "- Generated UTC: \`$STAMP_UTC\`"
  echo "- Canonical digest: \`$canonical_sha256\`"
  echo "- Capture complete: \`true\`"
  echo
  echo "## Counts"
  jq -r '"- workflows: `\(.captures.workflows|length)`\n- active runs: `\(.captures.active_runs|length)`\n- rulesets: `\(.captures.rulesets|length)`\n- installations: `\(.captures.installations|length)`\n- environments: `\(.captures.environments|length)`\n- deploy keys: `\(.captures.deploy_keys|length)`\n- admitted admin identities: `\(.captures.admitted_admin_identities|length)`"' "$OUT_JSON"
  echo
  echo "## Required checks"
  jq -r '.derived.required_checks[]? | "- `" + . + "`"' "$OUT_JSON"
  echo
  echo "Secret values, raw credentials, Authorization headers, and claimed provider token/session fingerprints were not captured."
} >"$OUT_MD"

echo "[OK] Wrote snapshot JSON: $OUT_JSON"
echo "[OK] Wrote snapshot report: $OUT_MD"
