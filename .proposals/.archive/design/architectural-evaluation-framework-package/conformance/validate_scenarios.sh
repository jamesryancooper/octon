#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: validate_scenarios.sh <package-root>" >&2
  exit 2
fi

package_root="$1"
scenarios_root="$package_root/conformance/scenarios"

if [[ ! -d "$scenarios_root" ]]; then
  echo "[ERROR] missing conformance/scenarios in $package_root" >&2
  exit 1
fi

mapfile -t scenario_files < <(find "$scenarios_root" -type f -name '*.json' | sort)

if [[ ${#scenario_files[@]} -eq 0 ]]; then
  echo "[OK] no conformance scenarios declared"
  exit 0
fi

failures=0

for path in "${scenario_files[@]}"; do
  if yq -e '
    has("scenario_id") and
    has("suite") and
    has("description") and
    has("expected")
  ' "$path" >/dev/null 2>&1; then
    echo "[OK] scenario shape valid: $path"
  else
    echo "[ERROR] $path: missing one or more required keys (scenario_id, suite, description, expected)" >&2
    failures=$((failures + 1))
  fi
done

if [[ $failures -ne 0 ]]; then
  exit 1
fi
