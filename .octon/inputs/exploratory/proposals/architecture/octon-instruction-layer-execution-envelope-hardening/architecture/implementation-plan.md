# Implementation Plan

## Posture

This packet is **proposal-first**. The live repo already has the right class roots and contract families, so the correct motion is not to invent new surfaces but to tighten the existing ones until the capability becomes closure-ready and operator-usable.

## Phase 0 — Packet acceptance and locating emitter/consumer code
1. Accept packet scope as a sibling refinement, not a bounded-UEC-packet amendment.
2. Locate the current code paths that emit:
   - instruction-layer manifests
   - execution requests
   - execution grants
   - execution receipts
3. Locate current evidence emission paths and confirm whether any existing validators already partially cover the proposed fields.
4. Freeze field-level naming before schema edits to avoid churn across surfaces.

**Exit criterion:** all emitter and consumer locations identified; no unresolved ambiguity about which runtime code actually writes the affected artifacts.

## Phase 1 — Instruction-layer provenance hardening
1. Extend `instruction-layer-manifest-v2.schema.json` with additive fields for:
   - capability pack disclosure
   - execution class disclosure
   - output-budget / envelope policy references
   - structured context-layer provenance
   - compaction references
2. Extend `tool-output-budgets.yml` so envelope policy is expressible per relevant pack/class path, not only as coarse defaults.
3. Update manifest emitters so every consequential run populates the new fields when governed capability usage occurs.
4. Create validator `validate-instruction-layer-manifest-depth.sh`.
5. Add regression test coverage.

**Incomplete if omitted:** without emitter updates and validator coverage, this concept would remain documentation-only.

## Phase 2 — Capability invocation / envelope normalization
1. Extend `execution-request-v2.schema.json` with additive pack/class/envelope request semantics.
2. Extend `execution-grant-v1.schema.json` with additive granted pack/class/envelope semantics.
3. Extend `execution-receipt-v2.schema.json` with additive retained proof of the same semantics.
4. Update `repo-shell-execution-classes.yml` so class policy clearly links to normalized receipt reasons and envelope expectations.
5. Update shell/repo capability pack manifests and shell admission artifacts to align evidence expectations.

**Incomplete if omitted:** pack governance would remain disconnected from retained receipt proof.

## Phase 3 — Assurance and CI hardening
1. Add `validate-capability-envelope-normalization.sh`.
2. Add regression tests for receipt coherence and budget/ref-offload behavior.
3. Extend `.github/workflows/architecture-conformance.yml` so both new validators run on relevant path changes.
4. Ensure validator failure is blocking before packet closeout.

## Phase 4 — Evidence and sample-run proof
1. Produce at least one reference run or synthetic fixture proving enriched instruction-layer manifest output.
2. Produce at least one reference receipt path proving request / grant / receipt / class / pack / envelope coherence.
3. Retain validation output sufficient for two consecutive clean passes.

## Phase 5 — Closeout review
1. Re-check support-target non-widening.
2. Re-check no new authority plane or generated truth was introduced.
3. Re-check operator/runtime touchpoints:
   - ingress / manifest emission
   - execution authorization boundary
   - repo-shell class policy
   - conformance workflow
4. Close only when acceptance criteria and closure certification conditions are met.

## Preferred Change Path

A single, additive refinement branch touching the existing runtime contract, engine spec, pack governance, and validator surfaces in one coherent set. This keeps the semantics aligned and avoids pseudo-coverage.

## Minimal Change Path fallback

Only if branch risk becomes unacceptable after packet acceptance:

- edit `tool-output-budgets.yml`
- edit `repo-shell-execution-classes.yml`
- add one validator that checks raw-payload-ref discipline

This fallback is **not** recommended as the default because it would leave request / grant / receipt normalization partially implicit.
