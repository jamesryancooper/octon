# Governed Runtime Materialization v1

Status: **draft proposal packet**
Authority: **non-authoritative proposal input**
Packet id: `octon-governed-runtime-materialization-v1`

This packet defines a promotion-safe migration that makes Octon's controlled
autonomy more materially enforceable in the live repository. It combines three
capabilities that reinforce the same promise:

> Octon is not reckless autonomy. It is controlled autonomy.

The proposal is intentionally narrow. It does not redesign Octon, add new
adapters, broaden agent autonomy, or move authority into generated artifacts.
It focuses on the runtime-governance closure work needed so Octon can present
support claims, authorize material effects, and show operator health with the
same source-of-truth discipline.

## Implementation target

**Governed Runtime Materialization v1** introduces:

1. **Support-envelope reconciliation gate** — a hard validator/publication gate
   that reconciles support-target declarations, admission/proof records,
   runtime-effective route bundles, capability-pack routes, locks, generated
   support matrices, support cards, and disclosure artifacts.

2. **End-to-end typed effect-token enforcement** — completion of the runtime
   authorization boundary so every material side-effect path requires a typed
   authorized effect, verifies it, records consumption evidence, and rejects
   bypasses.

3. **Operator-facing run health read model** — a generated, non-authoritative
   per-run health surface that tells a solo operator whether a run is healthy,
   blocked, stale, unsupported, revoked, awaiting approval, evidence-incomplete,
   recoverable, or ready for closure.

## Why this packet exists

The live repository already contains the core constitutional and runtime
architecture: bounded admitted support, generated/effective route artifacts,
authorization contracts, effect-token contracts, evidence obligations, run
lifecycle state, and operator read-model rules. The remaining gap is material
closure across those surfaces.

The migration in this packet makes Octon's limits visible and enforceable:

> Octon is trustworthy because it knows its limits.

## Read order

1. `architecture/current-state-gap-map.md`
2. `architecture/target-architecture.md`
3. `architecture/implementation-plan.md`
4. `architecture/validation-plan.md`
5. `architecture/file-change-map.md`
6. `architecture/acceptance-criteria.md`
7. `architecture/closure-certification-plan.md`

Supporting analysis lives under `resources/`. Proposal navigation lives under
`navigation/`.

## Non-authority notice

This packet is proposal-input only. Nothing in this directory is runtime
authority, support authority, policy authority, generated truth, or evidence of
implemented behavior. Implementation is real only after selected changes are
promoted outside `.octon/inputs/exploratory/proposals/**`, validated, evidenced,
and closed under Octon's canonical governance process.
