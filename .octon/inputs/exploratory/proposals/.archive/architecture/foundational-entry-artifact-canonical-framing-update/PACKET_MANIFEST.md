# Packet Manifest

_Manifest for `foundational-entry-artifact-canonical-framing-update`._

## Intended repository location

`/.octon/inputs/exploratory/proposals/architecture/foundational-entry-artifact-canonical-framing-update/`

## Convention decision

Live proposal workspace rules require active proposals under `/.octon/inputs/exploratory/proposals/<kind>/<proposal_id>/`; architecture proposals require `architecture-proposal.yml`, `navigation/source-of-truth-map.md`, `navigation/artifact-catalog.md`, and `architecture/{target-architecture,acceptance-criteria,implementation-plan}.md`. This packet follows that convention and therefore uses the `architecture/` kind segment even though the user-provided fallback omitted it.

Active proposals may not mix `.octon/**` and non-`.octon/**` promotion target
families. The normalized packet is therefore `promotion_scope: octon-internal`;
repo-root `README.md` and `AGENTS.md` are retained as linked repo-local
companion scope instead of active promotion targets.

## Scope self-audit

- Packet type: architecture proposal.
- Selected implementation target: Foundational Entry-Artifact Canonical Framing Update.
- Runtime behavior impact: none.
- Deeper runtime packets are signposted only.
- Durable Objects are treated only as possible future live coordination adapters.
- Proposal files remain non-canonical inputs until promoted.
- Supplemental determinism conversation files are proposal-local background
  context only, not runtime, policy, authority, control truth, retained
  evidence, or promotion approval.

## File tree

```text
COMPATIBILITY-NOTES.md
COMPLETENESS-CHECK.md
DECISION-LOG.md
EXECUTIVE-SUMMARY.md
IMPLEMENTATION-TASKS.md
MIGRATION-NOTES.md
NON-GOALS.md
OPEN-QUESTIONS.md
PACKET_MANIFEST.md
README.md
RISK-REGISTER.md
SCOPE.md
TRACEABILITY-MATRIX.md
VALIDATION-MATRIX.md
acceptance-criteria.md
agents-edit-plan.md
architecture-meta-edit-plan.md
architecture-proposal.md
architecture-proposal.yml
architecture/acceptance-criteria.md
architecture/implementation-plan.md
architecture/target-architecture.md
authority-control-evidence-impact.md
canonical-framing-rules.md
current-state-framing-audit.md
current-state-gap-map.md
cutover-checklist.md
entry-artifact-change-strategy.md
file-change-map.md
follow-on-packet-sequence.md
implementation-plan.md
ingress-entry-artifact-edit-plan.md
navigation/artifact-catalog.md
navigation/source-of-truth-map.md
operator-disclosure.md
promotion-readiness-checklist.md
proposal.yml
proposed-entry-artifact-edits.md
readme-edit-plan.md
resources/agents-current-state-analysis.md
resources/authority-boundary-notes.md
resources/candidate-agents-wording.md
resources/candidate-octon-readme-wording.md
resources/candidate-readme-wording.md
resources/durable-coordination-framing-note.md
resources/evidence-citations.md
resources/follow-on-packet-rationale.md
resources/framing-audit-notes.md
resources/implementation-diff-sketch.md
resources/non-authority-surface-analysis.md
resources/octon-determinism-conversation-1.md
resources/octon-determinism-conversation-2.md
resources/phrase-risk-analysis.md
resources/product-vs-technical-framing-analysis.md
resources/readme-current-state-analysis.md
resources/rejected-scope-items.md
resources/repository-inspection-record.md
resources/source-path-inventory.md
resources/terminology-current-state-analysis.md
rollback-plan.md
support/executable-implementation-prompt.md
support/implementation-conformance-review.md
support/implementation-grade-completeness-review.md
support/implementation-run.md
support/post-implementation-drift-churn-review.md
support/proposal-closeout.md
support/proposal-review.md
support/revisions/foundational-entry-artifact-canonical-framing-update-final-semantic-readiness-2026-05-12.md
support/validation.md
target-architecture.md
terminology-map.md
validation-plan.md
SHA256SUMS.txt
```

## Required artifact coverage

- [x] `proposal.yml`
- [x] `PACKET_MANIFEST.md`
- [x] `SHA256SUMS.txt`
- [x] `README.md`
- [x] `EXECUTIVE-SUMMARY.md`
- [x] `SCOPE.md`
- [x] `NON-GOALS.md`
- [x] `DECISION-LOG.md`
- [x] `RISK-REGISTER.md`
- [x] Architecture and framing artifacts 10–17
- [x] Implementation artifacts 18–24
- [x] Validation and acceptance artifacts 25–31
- [x] Optional root artifacts 32–37 plus `COMPLETENESS-CHECK.md`
- [x] Required `resources/` artifacts 1–12
- [x] Optional useful `resources/` artifacts 13–18
- [x] Supplemental local context resources:
  `resources/octon-determinism-conversation-1.md` and
  `resources/octon-determinism-conversation-2.md`
- [x] Proposal lifecycle support receipts:
  `support/implementation-grade-completeness-review.md`,
  `support/proposal-review.md`, `support/implementation-run.md`,
  `support/validation.md`, `support/implementation-conformance-review.md`,
  `support/post-implementation-drift-churn-review.md`, and
  `support/proposal-closeout.md`
- [x] Live-convention artifacts: `architecture-proposal.yml`, `navigation/source-of-truth-map.md`, `navigation/artifact-catalog.md`, `architecture/*`

## Packet completeness gate

- [x] Every required packet-root artifact exists.
- [x] Every required `resources/` artifact exists.
- [x] Manifest lists every file.
- [x] `SHA256SUMS.txt` includes every file except itself.
- [x] All artifacts agree on packet scope.
- [x] Non-goals are consistently enforced.
- [x] No runtime packet work is included.
- [x] No authority is placed in generated projections, inputs, chat, MCP, Durable Objects, or external systems.
- [x] Active promotion targets stay under `.octon/**`; repo-root targets are
  linked companion scope.

## Notes

`navigation/artifact-catalog.md` is an inventory and not semantic authority. `proposal.yml` and `architecture-proposal.yml` are the proposal-local lifecycle authorities.
