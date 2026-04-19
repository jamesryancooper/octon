#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
AGENCY_DIR="$(cd -- "$OPS_DIR/../.." && pwd)"
OCTON_DIR="$(cd -- "$AGENCY_DIR/.." && pwd)"
REPO_ROOT="$(cd -- "$OCTON_DIR/.." && pwd)"

POLICY_FILE="$REPO_ROOT/.octon/framework/execution-roles/practices/standards/ci-latency-policy.json"
DEFAULT_OUT_DIR="$REPO_ROOT/.octon/generated/reports"

repository="${GITHUB_REPOSITORY:-}"
window_runs=""
top_workflows=""
gate_scope="required"
out_json=""
out_markdown=""
runs_json_file=""
workflow_scan_json_file=""
jobs_fixture_dir=""

usage() {
  cat <<'EOF'
Usage:
  audit-ci-latency.sh [options]

Options:
  --repository <owner/repo>           Repository to audit (defaults to current origin remote or GITHUB_REPOSITORY)
  --policy <path>                     Policy JSON path
  --window-runs <n>                   Override audit window size
  --top-workflows <n>                 Override hotspot workflow limit
  --gate-scope <required|all|failing> Gate scope for downstream consumers (default: required)
  --out-json <path>                   Output JSON summary path
  --out-markdown <path>               Output Markdown report path
  --runs-json-file <path>             Use pre-fetched aggregated runs JSON instead of GitHub API
  --workflow-scan-json-file <path>    Use pre-built workflow scan JSON instead of scanning .github/workflows
  --jobs-fixture-dir <dir>            Directory containing <run_id>.json job API fixtures for second-pass analysis
  --help                              Show this message
EOF
}

require_tools() {
  local tool
  for tool in "$@"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      echo "required tool missing: $tool" >&2
      exit 1
    fi
  done
}

derive_repository_from_origin() {
  local remote url owner_repo
  remote="$(git -C "$REPO_ROOT" config --get remote.origin.url 2>/dev/null || true)"
  if [[ -z "$remote" ]]; then
    return 1
  fi

  case "$remote" in
    git@github.com:*)
      owner_repo="${remote#git@github.com:}"
      ;;
    https://github.com/*)
      owner_repo="${remote#https://github.com/}"
      ;;
    *)
      return 1
      ;;
  esac

  owner_repo="${owner_repo%.git}"
  printf '%s\n' "$owner_repo"
}

json_escape_file_value() {
  local value="$1"
  jq -Rn --arg value "$value" '$value'
}

scan_workflows() {
  local output_file="$1"
  local workflows_file patterns_tmp next_tmp
  workflows_file="$(mktemp "${TMPDIR:-/tmp}/ci-latency-workflows.XXXXXX")"
  printf '[]\n' > "$workflows_file"

  while IFS= read -r workflow_path; do
    [[ -n "$workflow_path" ]] || continue

    local workflow_name
    workflow_name="$(sed -nE 's/^name:[[:space:]]*//p' "$workflow_path" | head -n 1 | tr -d '"' | sed 's/[[:space:]]*$//')"
    if [[ -z "$workflow_name" ]]; then
      workflow_name="$(basename "$workflow_path")"
    fi

    patterns_tmp="$(mktemp "${TMPDIR:-/tmp}/ci-latency-patterns.XXXXXX")"
    printf '{}\n' > "$patterns_tmp"
    while IFS= read -r pattern_json; do
      [[ -n "$pattern_json" ]] || continue
      local pattern_id pattern_match count
      pattern_id="$(jq -r '.id' <<<"$pattern_json")"
      pattern_match="$(jq -r '.match' <<<"$pattern_json")"
      count="$(grep -F -c "$pattern_match" "$workflow_path" 2>/dev/null || true)"
      next_tmp="$(mktemp "${TMPDIR:-/tmp}/ci-latency-patterns-next.XXXXXX")"
      jq --arg id "$pattern_id" --argjson count "$count" '. + {($id): $count}' "$patterns_tmp" > "$next_tmp"
      mv "$next_tmp" "$patterns_tmp"
    done < <(jq -c '.duplicate_work_patterns[]' "$POLICY_FILE")

    next_tmp="$(mktemp "${TMPDIR:-/tmp}/ci-latency-workflows-next.XXXXXX")"
    jq \
      --arg path "${workflow_path#"$REPO_ROOT/"}" \
      --arg name "$workflow_name" \
      --slurpfile patterns "$patterns_tmp" \
      '. + [{path: $path, workflow_name: $name, patterns: $patterns[0]}]' \
      "$workflows_file" > "$next_tmp"
    mv "$next_tmp" "$workflows_file"
    rm -f "$patterns_tmp"
  done < <(find "$REPO_ROOT/.github/workflows" -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) | sort)

  jq \
    -n \
    --slurpfile workflows "$workflows_file" \
    --slurpfile policy "$POLICY_FILE" '
      {
        duplicates: [
          $policy[0].duplicate_work_patterns[]
          | . as $pattern
          | {
              key: $pattern.id,
              category: "duplicate-heavyweight-step",
              workflows: [
                $workflows[0][]
                | select((.patterns[$pattern.id] // 0) > 0)
                | .workflow_name
              ],
              occurrences: (
                [
                  $workflows[0][]
                  | (.patterns[$pattern.id] // 0)
                ] | add
              ),
              total_estimated_seconds: (
                (
                  [
                    $workflows[0][]
                    | (.patterns[$pattern.id] // 0)
                  ] | add
                ) * ($pattern.estimated_seconds_per_occurrence // 0)
              ),
              summary: $pattern.description
            }
        ]
      }
    ' > "$output_file"
  rm -f "$workflows_file"
}

fetch_live_runs() {
  local output_file="$1"
  local workflow_list workflow_entries runs_tmp next_tmp

  workflow_list="$(gh api "repos/$repository/actions/workflows" --paginate)"
  runs_tmp="$(mktemp "${TMPDIR:-/tmp}/ci-latency-runs.XXXXXX")"
  printf '[]\n' > "$runs_tmp"

  while IFS= read -r workflow_json; do
    [[ -n "$workflow_json" ]] || continue
    local workflow_id workflow_name workflow_path response response_tmp
    workflow_id="$(jq -r '.id' <<<"$workflow_json")"
    workflow_name="$(jq -r '.name' <<<"$workflow_json")"
    workflow_path="$(jq -r '.path' <<<"$workflow_json")"

    response="$(gh api "repos/$repository/actions/workflows/$workflow_id/runs?per_page=$window_runs&status=completed")"
    response_tmp="$(mktemp "${TMPDIR:-/tmp}/ci-latency-runs-part.XXXXXX")"
    jq \
      --arg workflow_name "$workflow_name" \
      --arg workflow_path "$workflow_path" \
      --argjson workflow_id "$workflow_id" \
      '
        .workflow_runs | map({
          run_id: .id,
          workflow_name: $workflow_name,
          workflow_path: $workflow_path,
          workflow_id: $workflow_id,
          event: .event,
          conclusion: .conclusion,
          head_sha: .head_sha,
          created_at: .created_at,
          duration_seconds: ((.updated_at | fromdateiso8601) - (.created_at | fromdateiso8601))
        })
      ' <<<"$response" > "$response_tmp"

    next_tmp="$(mktemp "${TMPDIR:-/tmp}/ci-latency-runs-next.XXXXXX")"
    jq -s '.[0] + .[1]' "$runs_tmp" "$response_tmp" > "$next_tmp"
    mv "$next_tmp" "$runs_tmp"
    rm -f "$response_tmp"
  done < <(jq -c '.workflows[] | select(.state == "active")' <<<"$workflow_list")

  mv "$runs_tmp" "$output_file"
}

fetch_jobs_for_candidates() {
  local summary_file="$1"
  local output_file="$2"
  local jobs_tmp next_tmp
  jobs_tmp="$(mktemp "${TMPDIR:-/tmp}/ci-latency-jobs.XXXXXX")"
  printf '[]\n' > "$jobs_tmp"

  while IFS= read -r candidate_json; do
    [[ -n "$candidate_json" ]] || continue

    local run_id workflow_name jobs_payload payload_file
    run_id="$(jq -r '.latest_success_run_id // empty' <<<"$candidate_json")"
    workflow_name="$(jq -r '.workflow_name // ""' <<<"$candidate_json")"
    if [[ -z "$run_id" ]]; then
      continue
    fi

    if [[ -n "$jobs_fixture_dir" ]]; then
      jobs_payload="$(cat "$jobs_fixture_dir/$run_id.json")"
    else
      jobs_payload="$(gh api "repos/$repository/actions/runs/$run_id/jobs")"
    fi

    payload_file="$(mktemp "${TMPDIR:-/tmp}/ci-latency-jobs-payload.XXXXXX")"
    printf '%s\n' "$jobs_payload" > "$payload_file"
    next_tmp="$(mktemp "${TMPDIR:-/tmp}/ci-latency-jobs-next.XXXXXX")"
    jq \
      --arg workflow_name "$workflow_name" \
      --argjson run_id "$run_id" \
      --slurpfile payload "$payload_file" \
      '. + [{run_id: $run_id, workflow_name: $workflow_name, jobs: ($payload[0].jobs // [])}]' \
      "$jobs_tmp" > "$next_tmp"
    mv "$next_tmp" "$jobs_tmp"
    rm -f "$payload_file"
  done < <(jq -c --argjson n "$top_workflows" '.workflow_metrics[:$n][]' "$summary_file")

  mv "$jobs_tmp" "$output_file"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repository) repository="$2"; shift 2 ;;
    --policy) POLICY_FILE="$2"; shift 2 ;;
    --window-runs) window_runs="$2"; shift 2 ;;
    --top-workflows) top_workflows="$2"; shift 2 ;;
    --gate-scope) gate_scope="$2"; shift 2 ;;
    --out-json) out_json="$2"; shift 2 ;;
    --out-markdown) out_markdown="$2"; shift 2 ;;
    --runs-json-file) runs_json_file="$2"; shift 2 ;;
    --workflow-scan-json-file) workflow_scan_json_file="$2"; shift 2 ;;
    --jobs-fixture-dir) jobs_fixture_dir="$2"; shift 2 ;;
    --help) usage; exit 0 ;;
    *) echo "unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

require_tools jq cargo
if [[ -z "$runs_json_file" ]]; then
  require_tools gh
fi

[[ -f "$POLICY_FILE" ]] || { echo "policy file not found: $POLICY_FILE" >&2; exit 1; }

if [[ -z "$repository" ]]; then
  repository="$(derive_repository_from_origin || true)"
fi
if [[ -z "$repository" ]]; then
  echo "repository could not be derived; pass --repository owner/repo" >&2
  exit 1
fi

if [[ -z "$window_runs" ]]; then
  window_runs="$(jq -r '.window_runs' "$POLICY_FILE")"
fi
if [[ -z "$top_workflows" ]]; then
  top_workflows="$(jq -r '.top_workflows' "$POLICY_FILE")"
fi

timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$DEFAULT_OUT_DIR"
if [[ -z "$out_json" ]]; then
  out_json="$DEFAULT_OUT_DIR/${timestamp}-ci-latency-audit.json"
fi
if [[ -z "$out_markdown" ]]; then
  out_markdown="$DEFAULT_OUT_DIR/${timestamp}-ci-latency-audit.md"
fi
mkdir -p "$(dirname "$out_json")" "$(dirname "$out_markdown")"

tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/ci-latency-audit.XXXXXX")"
trap '[[ -d "$tmpdir" ]] && rm -r "$tmpdir"' EXIT

runs_file="$tmpdir/runs.json"
workflow_scan_file="$tmpdir/workflow-scan.json"
jobs_file="$tmpdir/jobs.json"
first_pass_json="$tmpdir/summary-pass-1.json"

if [[ -n "$runs_json_file" ]]; then
  cp "$runs_json_file" "$runs_file"
else
  fetch_live_runs "$runs_file"
fi

if [[ -n "$workflow_scan_json_file" ]]; then
  cp "$workflow_scan_json_file" "$workflow_scan_file"
else
  scan_workflows "$workflow_scan_file"
fi

printf '[]\n' > "$jobs_file"

cargo run --quiet \
  --manifest-path "$REPO_ROOT/.octon/framework/engine/runtime/crates/Cargo.toml" \
  -p octon_assurance_tools \
  -- ci-latency analyze \
  --policy "$POLICY_FILE" \
  --runs "$runs_file" \
  --jobs "$jobs_file" \
  --workflow-scan "$workflow_scan_file" \
  --output-json "$first_pass_json"

fetch_jobs_for_candidates "$first_pass_json" "$jobs_file"

cargo run --quiet \
  --manifest-path "$REPO_ROOT/.octon/framework/engine/runtime/crates/Cargo.toml" \
  -p octon_assurance_tools \
  -- ci-latency analyze \
  --policy "$POLICY_FILE" \
  --runs "$runs_file" \
  --jobs "$jobs_file" \
  --workflow-scan "$workflow_scan_file" \
  --output-json "$out_json"

cargo run --quiet \
  --manifest-path "$REPO_ROOT/.octon/framework/engine/runtime/crates/Cargo.toml" \
  -p octon_assurance_tools \
  -- ci-latency render-markdown \
  --summary "$out_json" \
  --output-markdown "$out_markdown"

echo "CI latency audit report: ${out_markdown#$REPO_ROOT/}"
echo "CI latency audit summary: ${out_json#$REPO_ROOT/}"
