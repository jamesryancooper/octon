# Archive Proposal Summary

- workflow_id: `archive-proposal`
- lifecycle: `proposal-packet`
- proposal_path: `.octon/inputs/exploratory/proposals/architecture/foundational-entry-artifact-canonical-framing-update`
- archived_path: `.octon/inputs/exploratory/proposals/.archive/architecture/foundational-entry-artifact-canonical-framing-update`
- proposal_kind: `architecture`
- proposal_id: `foundational-entry-artifact-canonical-framing-update`
- disposition: `implemented`
- final_verdict: `archived`
- bundle_root: `.octon/state/evidence/runs/workflows/2026-05-14-archive-proposal-octon-inputs-exploratory-proposals-architecture-foundational-entry-artifact-canonical-framing-update-2`
- validator_log: `.octon/state/evidence/runs/workflows/2026-05-14-archive-proposal-octon-inputs-exploratory-proposals-architecture-foundational-entry-artifact-canonical-framing-update-2/standard-validator.log`

The source proposal validated before archival, was moved to the canonical
archive path, and `proposal.yml` now records `status: archived` with
`archive.disposition: implemented`. The proposal registry was regenerated and
checked against the deterministic manifest projection.

Executor note: the compatibility workflow runner failed before stage execution
because a fixed stage request id collided with an already closed retained stage
run. The successful bundle records direct stage execution against the workflow
contract and retains the failed runner attempts as evidence.
