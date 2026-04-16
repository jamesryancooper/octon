#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$TEST_DIR/../fixture-lib.sh"

fixture_root="$(setup_publication_fixture)"
proposal_id="retirement-hygiene-packetizer-draft"
proposal_root="$fixture_root/.octon/inputs/exploratory/proposals/migration/$proposal_id"
trap 'rm -r -f -- "$fixture_root"' EXIT

render_template_to \
  "$fixture_root/$PACK_REL/templates/migration-proposal/README.md.tmpl" \
  "$proposal_root/README.md" \
  proposal_id "$proposal_id" \
  title "Retirement Hygiene Packetizer Draft" \
  promotion_target_one ".octon/inputs/additive/extensions/$PACK_ID/README.md" \
  promotion_target_two ".octon/inputs/additive/extensions/$PACK_ID/context/flow-matrix.md"

render_template_to \
  "$fixture_root/$PACK_REL/templates/migration-proposal/proposal.yml.tmpl" \
  "$proposal_root/proposal.yml" \
  proposal_id "$proposal_id" \
  title "Retirement Hygiene Packetizer Draft" \
  summary "Temporary non-authoritative cleanup-planning draft." \
  promotion_target_one ".octon/inputs/additive/extensions/$PACK_ID/README.md" \
  promotion_target_two ".octon/inputs/additive/extensions/$PACK_ID/context/flow-matrix.md"

render_template_to \
  "$fixture_root/$PACK_REL/templates/migration-proposal/migration-proposal.yml.tmpl" \
  "$proposal_root/migration-proposal.yml"

render_template_to \
  "$fixture_root/$PACK_REL/templates/migration-proposal/navigation/source-of-truth-map.md.tmpl" \
  "$proposal_root/navigation/source-of-truth-map.md"

render_template_to \
  "$fixture_root/$PACK_REL/templates/migration-proposal/navigation/artifact-catalog.md.tmpl" \
  "$proposal_root/navigation/artifact-catalog.md"

render_template_to \
  "$fixture_root/$PACK_REL/templates/migration-proposal/migration/plan.md.tmpl" \
  "$proposal_root/migration/plan.md" \
  selection_rationale "The extension remains additive and non-authoritative." \
  goal "Draft the next governed cleanup packet without mutating retirement authority." \
  current_state "Core retirement truth already exists, but operators need joined draft outputs." \
  target_state "A reviewed cleanup packet input draft and ablation plan exist for human review." \
  cutover_steps "- Reconcile findings against retirement coverage." \
  validation_steps "- Validate the draft package under proposal standards."

render_template_to \
  "$fixture_root/$PACK_REL/templates/migration-proposal/migration/release-notes.md.tmpl" \
  "$proposal_root/migration/release-notes.md" \
  release_notes "No live authority surfaces are changed by this draft."

render_template_to \
  "$fixture_root/$PACK_REL/templates/migration-proposal/migration/rollback.md.tmpl" \
  "$proposal_root/migration/rollback.md" \
  rollback_triggers "- The reviewed cleanup plan conflicts with protected or claim-adjacent surfaces." \
  audit_summary_ref ".octon/state/evidence/runs/ci/repo-hygiene/demo/audit-summary.yml" \
  findings_ref ".octon/state/evidence/runs/ci/repo-hygiene/demo/findings.yml"

mkdir -p "$proposal_root/support"
cat >"$proposal_root/support/reconciliation-summary.yml" <<'EOF'
schema_version: "retirement-hygiene-reconciliation-summary-v1"
authority_mode: "draft-non-authoritative"
EOF

render_template_to \
  "$fixture_root/$PACK_REL/templates/cleanup-packet-inputs.yml.tmpl" \
  "$proposal_root/support/cleanup-packet-inputs.yml" \
  draft_id "$proposal_id" \
  generated_at "2026-04-15T00:00:00Z" \
  audit_summary_ref ".octon/state/evidence/runs/ci/repo-hygiene/demo/audit-summary.yml" \
  findings_ref ".octon/state/evidence/runs/ci/repo-hygiene/demo/findings.yml" \
  blocking_findings_ref ".octon/state/evidence/runs/ci/repo-hygiene/demo/blocking-findings.yml"

render_template_to \
  "$fixture_root/$PACK_REL/templates/ablation-plan.md.tmpl" \
  "$proposal_root/support/ablation-plan.md" \
  title "Draft Ablation Plan" \
  audit_summary_ref ".octon/state/evidence/runs/ci/repo-hygiene/demo/audit-summary.yml" \
  findings_ref ".octon/state/evidence/runs/ci/repo-hygiene/demo/findings.yml" \
  candidate_targets "- candidate-for-governed-ablation-review: demo-target" \
  required_ablation_suite "- validate-repo-hygiene-governance.sh"

grep -Fq 'draft-non-authoritative' "$proposal_root/support/cleanup-packet-inputs.yml"
grep -Fq 'not a canonical runtime, documentation, policy, or contract authority' "$proposal_root/README.md"
grep -Fq 'temporary and non-authoritative' "$proposal_root/navigation/source-of-truth-map.md"

run_in_fixture "$fixture_root" \
  bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh" \
  --package ".octon/inputs/exploratory/proposals/migration/$proposal_id" \
  --skip-registry-check >/dev/null

run_in_fixture "$fixture_root" \
  bash "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-migration-proposal.sh" \
  --package ".octon/inputs/exploratory/proposals/migration/$proposal_id" >/dev/null
