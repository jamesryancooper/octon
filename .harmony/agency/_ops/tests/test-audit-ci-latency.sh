#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
AGENCY_DIR="$(cd -- "$OPS_DIR/.." && pwd)"
HARMONY_DIR="$(cd -- "$AGENCY_DIR/.." && pwd)"
REPO_ROOT="$(cd -- "$HARMONY_DIR/.." && pwd)"
WRAPPER="$REPO_ROOT/.harmony/agency/_ops/scripts/ci/audit-ci-latency.sh"
CONTROL_PLANE="$REPO_ROOT/.harmony/agency/practices/standards/github-control-plane-contract.json"

pass_count=0
fail_count=0
cleanup_paths=()

cleanup() {
  local path
  for path in "${cleanup_paths[@]}"; do
    [[ -d "$path" ]] && rm -r "$path"
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

assert_file_exists() {
  local name="$1"
  local file="$2"
  if [[ -f "$file" ]]; then
    pass "$name"
  else
    fail "$name"
  fi
}

assert_jq() {
  local name="$1"
  local filter="$2"
  local file="$3"
  if jq -e "$filter" "$file" >/dev/null; then
    pass "$name"
  else
    fail "$name"
  fi
}

create_fixture_root() {
  local root
  root="$(mktemp -d "${TMPDIR:-/tmp}/ci-latency-fixture.XXXXXX")"
  cleanup_paths+=("$root")
  mkdir -p "$root/jobs" "$root/out"
  printf '%s\n' "$root"
}

write_policy_fixture() {
  local root="$1"
  local top="$2"
  cat > "$root/policy.json" <<EOF
{
  "version": "fixture",
  "window_runs": 4,
  "newest_bucket": 2,
  "previous_bucket": 2,
  "minimum_bucket_samples": 2,
  "required_checks_contract_path": "${CONTROL_PLANE}",
  "required_path_median_seconds": 420,
  "required_path_p90_seconds": 600,
  "workflow_regression_percent": 20,
  "duplicate_work_cumulative_seconds": 180,
  "top_workflows": ${top},
  "issue_title": "[ci-latency] weekly audit breach",
  "issue_label": "ci-latency",
  "duplicate_work_patterns": [
    {
      "id": "cargo-component-install",
      "description": "cargo-component installation repeated across workflows",
      "match": "cargo install --locked cargo-component",
      "severity": "high",
      "estimated_seconds_per_occurrence": 180
    },
    {
      "id": "filesystem-service-build",
      "description": "Filesystem service builds repeated across workflows",
      "match": ".harmony/engine/runtime/run service build interfaces/filesystem-snapshot",
      "severity": "high",
      "estimated_seconds_per_occurrence": 120
    }
  ]
}
EOF
}

write_healthy_fixtures() {
  local root="$1"
  cat > "$root/runs.json" <<'EOF'
[
  {"run_id": 1001, "workflow_name": "AI Review Gate / decision", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-1", "created_at": "2026-03-01T00:00:00Z", "duration_seconds": 35},
  {"run_id": 1002, "workflow_name": "enforce-ci-efficiency-policy", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-1", "created_at": "2026-03-01T00:00:00Z", "duration_seconds": 28},
  {"run_id": 1003, "workflow_name": "PR Quality Standards", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-1", "created_at": "2026-03-01T00:00:00Z", "duration_seconds": 52},
  {"run_id": 1004, "workflow_name": "Validate branch naming", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-1", "created_at": "2026-03-01T00:00:00Z", "duration_seconds": 24},
  {"run_id": 1005, "workflow_name": "Validate autonomy policy", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-1", "created_at": "2026-03-01T00:00:00Z", "duration_seconds": 26},

  {"run_id": 1101, "workflow_name": "AI Review Gate / decision", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-2", "created_at": "2026-03-02T00:00:00Z", "duration_seconds": 37},
  {"run_id": 1102, "workflow_name": "enforce-ci-efficiency-policy", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-2", "created_at": "2026-03-02T00:00:00Z", "duration_seconds": 29},
  {"run_id": 1103, "workflow_name": "PR Quality Standards", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-2", "created_at": "2026-03-02T00:00:00Z", "duration_seconds": 54},
  {"run_id": 1104, "workflow_name": "Validate branch naming", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-2", "created_at": "2026-03-02T00:00:00Z", "duration_seconds": 25},
  {"run_id": 1105, "workflow_name": "Validate autonomy policy", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-2", "created_at": "2026-03-02T00:00:00Z", "duration_seconds": 27},

  {"run_id": 1201, "workflow_name": "AI Review Gate / decision", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-1", "created_at": "2026-03-03T00:00:00Z", "duration_seconds": 36},
  {"run_id": 1202, "workflow_name": "enforce-ci-efficiency-policy", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-1", "created_at": "2026-03-03T00:00:00Z", "duration_seconds": 28},
  {"run_id": 1203, "workflow_name": "PR Quality Standards", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-1", "created_at": "2026-03-03T00:00:00Z", "duration_seconds": 53},
  {"run_id": 1204, "workflow_name": "Validate branch naming", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-1", "created_at": "2026-03-03T00:00:00Z", "duration_seconds": 24},
  {"run_id": 1205, "workflow_name": "Validate autonomy policy", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-1", "created_at": "2026-03-03T00:00:00Z", "duration_seconds": 26},

  {"run_id": 1301, "workflow_name": "AI Review Gate / decision", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-2", "created_at": "2026-03-04T00:00:00Z", "duration_seconds": 34},
  {"run_id": 1302, "workflow_name": "enforce-ci-efficiency-policy", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-2", "created_at": "2026-03-04T00:00:00Z", "duration_seconds": 27},
  {"run_id": 1303, "workflow_name": "PR Quality Standards", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-2", "created_at": "2026-03-04T00:00:00Z", "duration_seconds": 51},
  {"run_id": 1304, "workflow_name": "Validate branch naming", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-2", "created_at": "2026-03-04T00:00:00Z", "duration_seconds": 24},
  {"run_id": 1305, "workflow_name": "Validate autonomy policy", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-2", "created_at": "2026-03-04T00:00:00Z", "duration_seconds": 26},

  {"run_id": 6001, "workflow_name": "Harness Self-Containment Validation", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-1", "created_at": "2026-03-01T00:00:00Z", "duration_seconds": 81},
  {"run_id": 6002, "workflow_name": "Harness Self-Containment Validation", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-2", "created_at": "2026-03-02T00:00:00Z", "duration_seconds": 80},
  {"run_id": 6003, "workflow_name": "Harness Self-Containment Validation", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-1", "created_at": "2026-03-03T00:00:00Z", "duration_seconds": 79},
  {"run_id": 6004, "workflow_name": "Harness Self-Containment Validation", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-2", "created_at": "2026-03-04T00:00:00Z", "duration_seconds": 78}
]
EOF

  cat > "$root/workflow-scan.json" <<'EOF'
{
  "duplicates": []
}
EOF

  cat > "$root/jobs/6004.json" <<'EOF'
{
  "jobs": [
    {
      "name": "validate",
      "steps": [
        {
          "name": "Validate orchestration runtime surface hooks",
          "started_at": "2026-03-04T00:00:10Z",
          "completed_at": "2026-03-04T00:00:42Z"
        },
        {
          "name": "Validate workflow manifest and dependency profiles",
          "started_at": "2026-03-04T00:00:43Z",
          "completed_at": "2026-03-04T00:00:54Z"
        }
      ]
    }
  ]
}
EOF
}

write_breach_fixtures() {
  local root="$1"
  cat > "$root/runs.json" <<'EOF'
[
  {"run_id": 2001, "workflow_name": "AI Review Gate / decision", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-1", "created_at": "2026-03-05T00:00:00Z", "duration_seconds": 100},
  {"run_id": 2002, "workflow_name": "enforce-ci-efficiency-policy", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-1", "created_at": "2026-03-05T00:00:00Z", "duration_seconds": 80},
  {"run_id": 2003, "workflow_name": "PR Quality Standards", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-1", "created_at": "2026-03-05T00:00:00Z", "duration_seconds": 195},
  {"run_id": 2004, "workflow_name": "Validate branch naming", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-1", "created_at": "2026-03-05T00:00:00Z", "duration_seconds": 70},
  {"run_id": 2005, "workflow_name": "Validate autonomy policy", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-1", "created_at": "2026-03-05T00:00:00Z", "duration_seconds": 75},

  {"run_id": 2101, "workflow_name": "AI Review Gate / decision", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-2", "created_at": "2026-03-06T00:00:00Z", "duration_seconds": 105},
  {"run_id": 2102, "workflow_name": "enforce-ci-efficiency-policy", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-2", "created_at": "2026-03-06T00:00:00Z", "duration_seconds": 82},
  {"run_id": 2103, "workflow_name": "PR Quality Standards", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-2", "created_at": "2026-03-06T00:00:00Z", "duration_seconds": 190},
  {"run_id": 2104, "workflow_name": "Validate branch naming", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-2", "created_at": "2026-03-06T00:00:00Z", "duration_seconds": 72},
  {"run_id": 2105, "workflow_name": "Validate autonomy policy", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-2", "created_at": "2026-03-06T00:00:00Z", "duration_seconds": 76},

  {"run_id": 2201, "workflow_name": "AI Review Gate / decision", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-1", "created_at": "2026-03-07T00:00:00Z", "duration_seconds": 250},
  {"run_id": 2202, "workflow_name": "enforce-ci-efficiency-policy", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-1", "created_at": "2026-03-07T00:00:00Z", "duration_seconds": 238},
  {"run_id": 2203, "workflow_name": "PR Quality Standards", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-1", "created_at": "2026-03-07T00:00:00Z", "duration_seconds": 620},
  {"run_id": 2204, "workflow_name": "Validate branch naming", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-1", "created_at": "2026-03-07T00:00:00Z", "duration_seconds": 225},
  {"run_id": 2205, "workflow_name": "Validate autonomy policy", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-1", "created_at": "2026-03-07T00:00:00Z", "duration_seconds": 230},

  {"run_id": 2301, "workflow_name": "AI Review Gate / decision", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-2", "created_at": "2026-03-08T00:00:00Z", "duration_seconds": 245},
  {"run_id": 2302, "workflow_name": "enforce-ci-efficiency-policy", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-2", "created_at": "2026-03-08T00:00:00Z", "duration_seconds": 235},
  {"run_id": 2303, "workflow_name": "PR Quality Standards", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-2", "created_at": "2026-03-08T00:00:00Z", "duration_seconds": 640},
  {"run_id": 2304, "workflow_name": "Validate branch naming", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-2", "created_at": "2026-03-08T00:00:00Z", "duration_seconds": 222},
  {"run_id": 2305, "workflow_name": "Validate autonomy policy", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-2", "created_at": "2026-03-08T00:00:00Z", "duration_seconds": 224},

  {"run_id": 7001, "workflow_name": "filesystem-interfaces-runtime", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-1", "created_at": "2026-03-05T00:00:00Z", "duration_seconds": 500},
  {"run_id": 7002, "workflow_name": "filesystem-interfaces-runtime", "event": "pull_request", "conclusion": "success", "head_sha": "sha-prev-2", "created_at": "2026-03-06T00:00:00Z", "duration_seconds": 505},
  {"run_id": 7003, "workflow_name": "filesystem-interfaces-runtime", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-1", "created_at": "2026-03-07T00:00:00Z", "duration_seconds": 730},
  {"run_id": 7004, "workflow_name": "filesystem-interfaces-runtime", "event": "pull_request", "conclusion": "success", "head_sha": "sha-new-2", "created_at": "2026-03-08T00:00:00Z", "duration_seconds": 740}
]
EOF

  cat > "$root/workflow-scan.json" <<'EOF'
{
  "duplicates": [
    {
      "key": "cargo-component-install",
      "category": "duplicate-heavyweight-step",
      "workflows": [
        "filesystem-interfaces-runtime",
        "filesystem-interfaces-perf-regression"
      ],
      "occurrences": 2,
      "total_estimated_seconds": 360,
      "summary": "cargo-component installation repeats across the filesystem validation workflows"
    }
  ]
}
EOF

  cat > "$root/jobs/2303.json" <<'EOF'
{
  "jobs": [
    {
      "name": "PR Quality Standards",
      "steps": [
        {
          "name": "Run orchestration validation gate",
          "started_at": "2026-03-08T00:02:00Z",
          "completed_at": "2026-03-08T00:08:00Z"
        }
      ]
    }
  ]
}
EOF

  cat > "$root/jobs/7004.json" <<'EOF'
{
  "jobs": [
    {
      "name": "validate-ubuntu-latest",
      "steps": [
        {
          "name": "Install cargo-component",
          "started_at": "2026-03-08T00:00:30Z",
          "completed_at": "2026-03-08T00:03:40Z"
        },
        {
          "name": "Build split filesystem wasm services from source",
          "started_at": "2026-03-08T00:03:45Z",
          "completed_at": "2026-03-08T00:07:10Z"
        }
      ]
    }
  ]
}
EOF
}

run_wrapper() {
  local root="$1"
  bash "$WRAPPER" \
    --repository "example/harmony" \
    --policy "$root/policy.json" \
    --runs-json-file "$root/runs.json" \
    --workflow-scan-json-file "$root/workflow-scan.json" \
    --jobs-fixture-dir "$root/jobs" \
    --out-json "$root/out/summary.json" \
    --out-markdown "$root/out/report.md"
}

case_healthy_window_emits_outputs() {
  local root json_out md_out
  root="$(create_fixture_root)"
  write_policy_fixture "$root" 1
  write_healthy_fixtures "$root"
  run_wrapper "$root"
  json_out="$root/out/summary.json"
  md_out="$root/out/report.md"

  assert_file_exists "healthy summary json exists" "$json_out"
  assert_file_exists "healthy report markdown exists" "$md_out"
  assert_jq "healthy status recorded" '.status == "healthy"' "$json_out"
  assert_jq "healthy issue action is close-if-open" '.issue_action == "close_if_open"' "$json_out"
  assert_jq "healthy required-path median under target" '.required_path.median_seconds <= 420' "$json_out"
}

case_breach_window_surfaces_hotspots() {
  local root json_out md_out
  root="$(create_fixture_root)"
  write_policy_fixture "$root" 2
  write_breach_fixtures "$root"
  run_wrapper "$root"
  json_out="$root/out/summary.json"
  md_out="$root/out/report.md"

  assert_file_exists "breach summary json exists" "$json_out"
  assert_file_exists "breach report markdown exists" "$md_out"
  assert_jq "breach status recorded" '.status == "breach"' "$json_out"
  assert_jq "breach issue action escalates" '.issue_action == "open_or_update"' "$json_out"
  assert_jq "step hotspots emitted" '(.step_hotspots | length) >= 1' "$json_out"
  assert_jq "duplicate work candidates emitted" '(.duplicate_work_candidates | length) >= 1' "$json_out"
}

case_healthy_window_emits_outputs
case_breach_window_surfaces_hotspots

if (( fail_count > 0 )); then
  echo "FAILURES: $fail_count" >&2
  exit 1
fi

echo "PASS: all audit-ci-latency tests (${pass_count})"
