# Governance Decision Context

Packet-local decision context; candidate lineage only. This artifact
materializes operator-supplied governance direction so it is not left as
advisory conversation (per epistemic precedence, chat is advisory unless
materialized). It is **not** the formal acceptance act: acceptance still
occurs through the proposal lifecycle's governed review and acceptance steps.

- recorded_at: "2026-07-09"
- source: operator governance direction supplied to the Octon Architect
  review session guiding this packet (operator: Ryan Cooper
  <ryan@cooperonlineenterprises.com>; decision authority per
  `.octon/framework/constitution/ownership/roles.yml` governance_owner)
- status_effect: none by itself — packet remains `draft` until formal review
  and acceptance

## Recorded Direction

1. **Option B is the accepted target architecture direction:** remove ambient
   authority-affecting environment overrides; replace legitimate flexibility
   with explicit, typed, receipted, system-governed paths.
   (Packet representation: `proposal.yml#selected_direction`,
   `architecture/decision-options.md` Recommendation,
   `architecture/target-architecture.md`.)
2. **The self-governance hierarchy is accepted:** Tier 1 normal
   system-governed; Tier 2 exceptional-but-anticipated system-governed;
   Tier 3 human break-glass only.
   (Representation: `architecture/operational-flexibility-and-migration.md`
   §1; tier columns in the replacement and disposition tables.)
3. **Route-bundle publication bootstrap is confirmed Tier 2:** no human
   approval when the machine-provable preconditions hold — caller is the
   route-bundle publication path; stale tolerance is genuinely necessary;
   scope is bounded to one publication — with automatic denial when any
   precondition cannot be proven, and a retained receipt required.
   (Representation: flexibility table §2 row 1; target-architecture
   replacement table row 1; acceptance criteria 3, 4;
   validation plan §3.)
4. **Break-glass boundary confirmed:** human break-glass only for overriding
   a denial, bypassing failed preconditions, emergency recovery outside
   admitted policy, or governance-directed exceptional action; never the
   ordinary replacement for ambient env vars.
   (Representation: flexibility doc §§1, 3; acceptance criteria
   governance-tier rule; validation plan §9a.)
5. **Deprecation policy confirmed:** inventory first; skip the
   warning/deprecation phase only if the inventory proves zero external
   usage; otherwise stage warnings before hard enforcement.
   (Representation: migration phases 1, 4, 5 in the flexibility doc.)
6. **F-02 stays attached:** `stage_only_behavior` documented and bounded so
   it cannot become a soft allow.
   (Representation: acceptance criterion 4b; replacement table final row;
   validation plan §8.)
7. **F-03, F-04, F-05, and lower findings stay deferred:** this packet does
   not broaden into evidence-store governance, retirement-review
   maintenance, or spec-index maintenance.
   (Representation: `proposal.yml#findings_deferred`, which now records
   F-03, F-04, and F-05 explicitly.)
8. **Acceptance gates before implementation planning:** env-override
   invariance negative control; positive proof of the self-governed
   publication bootstrap; protected-mode rejection of ambient
   authority-affecting env vars; explicit request/config sourcing for policy
   mode, role, and intent; retained receipts for authority-affecting
   replacement paths; no routine operation newly requiring human approval.
   (Representation: acceptance criteria 2, 3, 4, 4a, 4d; validation plan
   §§2-6, 9b; implementation-plan preconditions.)

## What This Artifact Does Not Do

It does not set `status: accepted`, does not substitute for the proposal
review receipt, does not create an approval artifact under
`state/control/**`, and does not authorize implementation. The formal
acceptance path remains: proposal review (retained review receipt) →
governed acceptance (status transition by the lifecycle route) →
implementation planning gated on the acceptance criteria.
