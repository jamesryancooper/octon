#!/usr/bin/env bash
set -euo pipefail
yq -e '.entries | length > 0' .octon/instance/governance/contracts/retirement-registry.yml >/dev/null

