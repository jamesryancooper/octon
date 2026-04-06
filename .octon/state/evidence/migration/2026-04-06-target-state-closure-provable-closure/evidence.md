# Evidence

- Profile Selection Receipt recorded in the migration plan with
  `release_state: pre-1.0` and `change_profile: atomic`.
- Added packet-era schema surfaces for `mission-charter-v1`,
  `run-contract-v3`, `stage-attempt-v2`, `evidence-classification-v2`, and
  the new release-bundle/disclosure reports.
- Added support dossiers for all supported and stage-only tuple admissions
  under `/.octon/instance/governance/support-dossiers/**`.
- Rebound the live workspace and mission objective layer to the packet-era
  canonical refs and normalized the supported consequential quorum bindings.
- Backfilled the representative exemplar runs to `run-contract-v3`,
  `stage-attempt-v2`, and non-empty `octon-evidence-classification-v2`.
- Generated a new release bundle at
  `/.octon/state/evidence/disclosure/releases/2026-04-06-target-state-closure-provable-closure/`
  and promoted it in `release-lineage.yml`.
- Regenerated the active HarnessCard, gate-status, and closure-summary mirrors
  from that release bundle.
