#!/usr/bin/env bash
set -euo pipefail
policy=".octon/instance/governance/policies/hidden-check-governance.yml"
dir=".octon/framework/lab/scenarios/hidden-checks"
[[ -f "$policy" && -d "$dir" ]]

