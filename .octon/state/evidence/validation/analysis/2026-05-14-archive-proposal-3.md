# Archive Proposal Summary

- workflow_id: `archive-proposal`
- lifecycle: `proposal-packet`
- proposal_path: `.octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails`
- target: `.octon/inputs/exploratory/proposals/architecture/framing-boundary-and-terminology-guardrails`
- archived_path: `not-computed`
- proposal_kind: `architecture`
- proposal_id: `framing-boundary-and-terminology-guardrails`
- disposition: `missing`
- promotion_evidence: `not-provided`
- final_verdict: `blocked-fail-closed`
- failed_stage: `input-validation`
- failure_class: `missing-required-workflow-input`
- bundle_root: `.octon/state/evidence/runs/workflows/2026-05-14-archive-proposal-octon-inputs-exploratory-proposals-architecture-framing-boundary-and-terminology-guardrails-missing-disposition`

The archive-proposal workflow failed closed before stage execution and before
repository mutation because the required workflow input `disposition` was not
provided. The workflow contract declares `disposition` as required and the
compatibility runner independently rejected the invocation with:

```text
Error: workflow 'archive-proposal' requires --set disposition=<value>
```

No archive move, `proposal.yml` rewrite, artifact catalog regeneration, or
proposal registry regeneration was performed.

The proposal manifest currently reports `status: implemented`, and the packet
contains proposal-local closeout and implementation receipts. Those packet
facts were recorded only as non-authoritative context; they were not used to
infer the missing archive disposition.

## Profile Selection Receipt

- release_state: `pre-1.0`
- change_profile: `atomic`
- rationale: Evidence-only fail-closed execution for a workflow leaf with
  incomplete required inputs. No transitional compatibility path or durable
  archive mutation was selected.

## Orchestrator Decision

**Goal:** Execute `archive-proposal` for the specified proposal packet and
produce workflow evidence.

**Plan:** Bind the workflow contract, validate supplied inputs, invoke the local
compatibility runner far enough to verify input handling, and persist an
evidence bundle.

**Delegations:** none.

**Verification:** Contract read, runner input-validation check, current proposal
manifest read, and worktree status check.

**Next Step:** Rerun the archive workflow with an explicit `disposition`
(`implemented`, `rejected`, `historical`, or `superseded`). If `implemented`,
also provide durable promotion evidence outside the proposal packet.

## Final Verdict

`blocked-fail-closed`
