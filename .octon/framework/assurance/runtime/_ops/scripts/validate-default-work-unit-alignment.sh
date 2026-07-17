#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
errors=0

ok() { echo "[OK] $1"; }
fail() { echo "[ERROR] $1" >&2; errors=$((errors + 1)); }
check() { local label="$1"; shift; if "$@"; then ok "$label"; else fail "$label"; fi; }

POLICY="$OCTON_DIR/framework/product/contracts/default-work-unit.yml"
POLICY_DOC="$OCTON_DIR/framework/product/contracts/default-work-unit.md"
ADMISSION="$OCTON_DIR/instance/capabilities/runtime/packs/admissions/git.yml"
GOVERNANCE="$OCTON_DIR/instance/governance/capability-packs/git.yml"
STANDARDS="$OCTON_DIR/framework/execution-roles/practices/standards/commit-pr-standards.json"
REVIEW="$OCTON_DIR/framework/assurance/evaluators/review-routing.yml"
CLEANUP_SCHEMA="$OCTON_DIR/framework/product/contracts/branch-cleanup-authorization-v1.schema.json"

for file in "$POLICY" "$POLICY_DOC" "$ADMISSION" "$GOVERNANCE" "$STANDARDS" "$REVIEW" "$CLEANUP_SCHEMA"; do
  [[ -f "$file" ]] && ok "found ${file#$OCTON_DIR/}" || fail "missing ${file#$OCTON_DIR/}"
done

command -v yq >/dev/null 2>&1 || { echo "[ERROR] yq is required" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "[ERROR] jq is required" >&2; exit 1; }

check "policy is SI-00 atomic containment" yq -e '.containment.state == "SI-00" and .containment.change_profile == "atomic"' "$POLICY"
check "policy has exactly three active routes" yq -e '(.routes | length) == 3 and (.containment.active_route_ids | length) == 3' "$POLICY"
check "policy includes branch-no-pr" yq -e '.routes[].route_id | select(. == "branch-no-pr")' "$POLICY"
check "policy includes branch-pr" yq -e '.routes[].route_id | select(. == "branch-pr")' "$POLICY"
check "policy includes stage-only-escalate" yq -e '.routes[].route_id | select(. == "stage-only-escalate")' "$POLICY"
check "active policy routes exclude direct-main" bash -c '! yq -e '\'' .routes[].route_id | select(. == "direct-main") '\'' "$1" >/dev/null 2>&1' _ "$POLICY"
check "generic closeout preserves" yq -e '.closeout_defaults.target_lifecycle_outcome.unspecified_closeout_request == "preserved" and .routine_closeout_autonomy.generic_closeout_target == "preserved"' "$POLICY"
check "branch-no-pr cannot claim cleaned" bash -c '! yq -e '\'' .route_lifecycle_outcomes."branch-no-pr".allowed_outcomes[] | select(. == "cleaned") '\'' "$1" >/dev/null 2>&1' _ "$POLICY"
check "branch-no-pr landing is disabled" yq -e '.hosted_provider_ruleset.branch_no_pr_hosted_landing.mechanism == "disabled" and .hosted_provider_ruleset.branch_no_pr_hosted_landing.denial_reason == "RP00_CONTAINMENT_PUBLICATION_DISABLED"' "$POLICY"
check "Git admission excludes direct-main" bash -c '! yq -e '\'' .admitted_change_routes[] | select(. == "direct-main") '\'' "$1" >/dev/null 2>&1 && yq -e '\'' .containment.cleanup_denial_reason == "RP00_CONTAINMENT_CLEANUP_DISABLED" '\'' "$1" >/dev/null' _ "$ADMISSION"
check "Git governance denies effect routes" yq -e '(.route_posture."direct-main" == null) and .containment.branch_no_pr_landing == "denied" and .containment.branch_cleanup == "denied"' "$GOVERNANCE"
check "commit standards exclude direct-main" jq -e '(.change.route_ids | index("direct-main")) == null and .change.containment.direct_main == "denied"' "$STANDARDS"
check "review routing has no direct-main selector" yq -e '.run_requirements.route_requirements."direct-main" == null' "$REVIEW"
check "cleanup schema admits denial only" jq -e '.properties.authorization_result.const == "denied" and .properties.denial_reason.const == "RP00_CONTAINMENT_CLEANUP_DISABLED" and .properties.mutation_permitted.const == false' "$CLEANUP_SCHEMA"
check "policy documentation states both stable stops" grep -Fq 'RP00_CONTAINMENT_PUBLICATION_DISABLED' "$POLICY_DOC"
check "policy documentation states cleanup stop" grep -Fq 'RP00_CONTAINMENT_CLEANUP_DISABLED' "$POLICY_DOC"

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
