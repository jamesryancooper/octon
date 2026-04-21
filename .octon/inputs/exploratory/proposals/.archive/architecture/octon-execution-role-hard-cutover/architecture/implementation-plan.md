# Implementation Plan

## Implementation stance

This is one atomic hard cutover. There is no dual-path compatibility program.

## Workstream A — Authority and vocabulary replacement

1. Delete `framework/agency/**`.
2. Add `framework/execution-roles/**`.
3. Replace all canonical `agent`, `assistant`, `team`, `actor` ontology language with `execution role`, `orchestrator`, `specialist`, `verifier`, and `composition profile`.
4. Update `.octon/README.md`, `.octon/AGENTS.md`, and `instance/ingress/AGENTS.md`.

## Workstream B — Runtime schema hardening

1. Add `execution-request-v3.schema.json`.
2. Add `execution-receipt-v3.schema.json`.
3. Add `runtime-event-v1.schema.json`.
4. Modify `execution-authorization-v1.md` to require v3 shapes for all new material execution.
5. Replace `actor_ref` with `execution_role_ref`.
6. Replace `agent-augmented` runtime mode with `role-mediated` or remove mode if redundant.

## Workstream C — Support and capability proof

1. Align `charter.yml` support-universe mode with support schema.
2. Tighten `support-targets.yml` to live tuple truth only.
3. Remove unproven browser/API capability packs from live claims.
4. Add or prove browser/API runtime services before live admission.
5. Delete `experimental-external.yml` from active adapter discovery.

## Workstream D — Context, memory, and continuity

1. Make context packs mandatory for consequential runs.
2. Bind context-pack receipts to run evidence.
3. Ensure generated cognition is accepted only as derived context input.
4. Validate no execution role has canonical memory.

## Workstream E — Workflow catalog reduction

1. Classify every workflow as governance-critical or non-canonical.
2. Keep only run lifecycle, support admission, capability admission, proposal/promotion, release/readiness, rollback/recovery, browser/API high-risk path, and disclosure workflows.
3. Delete or demote foundation, project, ideation, generic task, and thinking-only workflows.

## Workstream F — Governance and proof automation

1. Replace network egress policy with connector leases.
2. Replace budget policy with run/mission/model/tool/browser/API budgets.
3. Add rollback/recovery drill expectations.
4. Add raw frontier-model baseline benchmark expectations.
5. Make RunCards/HarnessCards generated only from evidence.

## Final cutover gate

The cutover lands only when:

- all target files are present;
- all deleted surfaces are absent;
- support/overlay/schema/runtime validation passes;
- no proposal-path dependency exists in promoted targets;
- retained evidence bundle is produced under `state/evidence/validation/**`.

## Cutover rollback posture

Rollback is permitted only for repository integrity if the promoted tree cannot
validate. Rollback must revert the whole cutover commit set. Partial rollback is
not allowed because it would recreate dual ontology.
