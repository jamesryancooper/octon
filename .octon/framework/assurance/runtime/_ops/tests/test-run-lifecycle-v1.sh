#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-v1.sh"
FIXTURE_ROOT="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/fixtures/run-lifecycle-v1"

pass_count=0
fail_count=0
cleanup_dirs=()

cleanup() {
  local dir
  for dir in "${cleanup_dirs[@]}"; do
    case "$dir" in
      "${TMPDIR:-/tmp}"/run-lifecycle-v1.*)
        [[ -d "$dir" ]] && rm -r -- "$dir"
        ;;
      *)
        echo "refusing to remove unexpected cleanup path: $dir" >&2
        ;;
    esac
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
  local label="$1"
  shift
  if "$@"; then
    pass "$label"
  else
    fail "$label"
  fi
}

create_fixture_copy() {
  local tmp
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/run-lifecycle-v1.XXXXXX")"
  cleanup_dirs+=("$tmp")
  cp -R "$FIXTURE_ROOT" "$tmp/fixtures"
  printf '%s\n' "$tmp/fixtures"
}

case_fixture_set_passes() {
  bash "$VALIDATOR" --no-report >/dev/null
}

case_single_positive_reconstructs() {
  bash "$VALIDATOR" --no-report --case successful-closeout >/dev/null
}

case_runtime_state_mutation_fails() {
  local fixtures
  fixtures="$(create_fixture_copy)"
  python3 - "$fixtures/lifecycle-fixtures.yml" <<'PY'
from pathlib import Path
import sys
import yaml

path = Path(sys.argv[1])
data = yaml.safe_load(path.read_text())
for case in data["cases"]:
    if case["case_id"] == "successful-closeout":
        case.setdefault("runtime_state", {})["state"] = "running"
        break
path.write_text(yaml.safe_dump(data, sort_keys=False), encoding="utf-8")
PY
  ! bash "$VALIDATOR" --no-report --fixtures-root "$fixtures" --case successful-closeout >/dev/null
}

case_closeout_mutation_fails() {
  local fixtures
  fixtures="$(create_fixture_copy)"
  python3 - "$fixtures/lifecycle-fixtures.yml" <<'PY'
from pathlib import Path
import sys
import yaml

path = Path(sys.argv[1])
data = yaml.safe_load(path.read_text())
for case in data["cases"]:
    if case["case_id"] == "successful-closeout":
        case["missing_artifacts"] = ["journal_snapshot"]
        break
path.write_text(yaml.safe_dump(data, sort_keys=False), encoding="utf-8")
PY
  ! bash "$VALIDATOR" --no-report --fixtures-root "$fixtures" --case successful-closeout >/dev/null
}

main() {
  assert_success "fixture set passes with positive and negative controls" case_fixture_set_passes
  assert_success "single positive reconstructs from journal" case_single_positive_reconstructs
  assert_success "runtime-state drift mutation fails closed" case_runtime_state_mutation_fails
  assert_success "closeout evidence mutation fails closed" case_closeout_mutation_fails

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
