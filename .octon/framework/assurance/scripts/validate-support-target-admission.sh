#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_validator_common.sh"
release_id="$(resolve_validator_release_id "${1:-}")"
support_targets="$OCTON_DIR/instance/governance/support-targets.yml"
coverage="$(release_root "$release_id")/closure/support-universe-coverage.yml"
yq -e '.live_support_universe.model_classes[] | select(. == "repo-local-governed")' "$support_targets" >/dev/null
yq -e '.resolved_non_live_surfaces.model_classes[] | select(. == "frontier-governed")' "$support_targets" >/dev/null
yq -e '.resolved_non_live_surfaces.host_adapters[] | select(. == "github-control-plane")' "$support_targets" >/dev/null
yq -e '.live_support_universe.host_adapters[] | select(. == "ci-control-plane")' "$support_targets" >/dev/null
yq -e '.resolved_non_live_surfaces.host_adapters[] | select(. == "studio-control-plane")' "$support_targets" >/dev/null
yq -e '[.live_support_universe.capability_packs[] | select(. == "browser" or . == "api")] | length == 0' "$support_targets" >/dev/null
yq -e '(.excluded_surfaces | length) >= 1' "$coverage" >/dev/null
while IFS= read -r file; do
  [[ -n "$file" ]] || continue
  yq -e '.status == "supported" or .status == "stage_only"' "$file" >/dev/null
done < <(find "$OCTON_DIR"/instance/governance/support-target-admissions -type f -name '*.yml' | LC_ALL=C sort)
write_validator_report "$release_id" "support-target-consistency-report.yml" "V-SUP-001" "pass" "Support-target declarations, tuple admissions, and coverage ledgers distinguish the bounded admitted live claim from explicit stage-only or non-live surfaces."
