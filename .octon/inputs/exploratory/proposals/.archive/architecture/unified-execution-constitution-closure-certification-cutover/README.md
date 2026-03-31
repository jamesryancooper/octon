# Unified Execution Constitution Closure Certification Cutover

This package is the **final, implementation-scoped architecture proposal** for
turning the next Octon evaluation into a **closure certification round** rather
than another open-ended architecture round.

It is a **big-bang, clean-break, atomic closeout packet**.

It does **not** redesign Octon. It does **not** widen the supported envelope.
It does **not** open a second remediation cycle. It closes the remaining
**claim-blocking** gaps that still prevent an honest, binary certification of
Octon as a **fully realized unified execution constitution within its declared
supported envelope**.

## Audit baseline

This packet is scoped directly against the normalized findings in:

- `resources/implementation-audit.md`
- `resources/closure-certification-baseline.md`
- `resources/current-state-gap-analysis.md`
- `resources/final-remediation-ledger.md`

The packet deliberately converts those findings into one bounded claim, one
proof contract, and one release-blocking certification program.

## Purpose

- proposal kind: `architecture`
- promotion scope: `octon-internal`
- cutover style:
  - `atomic`
  - `clean-break`
  - `repo-wide`
  - `pre-1.0`
  - `closure-certification`
- closure promise:
  - **the next round is judged as certification against a bounded claim, not as
    another architecture ideation round**
  - **no supported-surface claim may survive without canonical authority,
    universal run-bundle proof, disclosure parity, shim independence, and at
    least one live build-to-delete receipt**

## The bounded claim this packet certifies

The packet freezes the claim to the following certified release envelope:

- model tier: `MT-B`
- workload tier: `WT-2`
- language/resource tier: `LT-REF`
- locale tier: `LOC-EN`
- certified host adapter: `repo-shell`
- certified model adapter: `repo-local-governed`

Everything outside that envelope remains explicitly bounded, reduced,
`stage_only`, experimental, or denied.

This packet **does not** certify GitHub or CI as first-class authority-bearing
control planes. They remain downstream projection or binding surfaces until they
are proven by canonical artifact routing and the same closure gates.

## What this packet closes

This packet closes the remaining claim-blocking gaps by:

- freezing the exact release claim in one machine-readable closure manifest
- converting residual host-native governance into canonical authority artifacts
  or excluding it from the certified claim surface
- making the full consequential run bundle a release-blocking proof contract
- turning support targets into executable positive and negative certification
  tests
- making RunCard and HarnessCard disclosure parity release-blocking
- proving historical shims are non-authoritative or retirement-conditioned
- requiring at least one live build-to-delete receipt so retirement discipline
  is no longer aspirational

## Why this packet is still needed

Octon now visibly contains the target-state nouns: a constitutional kernel,
explicit normative and epistemic precedence, support-target declarations,
non-authoritative host/model adapters, run-control roots, disclosure roots, and
first-class lab/observability domains. What still prevents a clean closure
verdict is not architectural absence. It is **claim discipline and universal
proof discipline**.

The remaining blockers are smaller than before, but still material:

- the broad “fully unified execution constitution” claim is still easier to say
  than to prove unless it is bounded to the supported envelope
- GitHub-host workflow logic still appears too close to practical authority in
  at least one important path
- the run-first lifecycle is structurally correct, but the proof that **every**
  consequential supported run emits the complete constitutional bundle is not yet
  a binary release gate
- disclosure, proof-plane, and support-target parity are stronger than before
  but are not yet universally release-blocking
- historical shims are retained, but not yet statically proven non-authoritative
  across every live entrypoint
- build-to-delete is declared, but not yet evidenced strongly enough to survive
  final closure review

This packet closes those issues **without creating a new model, a second
constitution, a second control plane, or a follow-on remediation backlog**.

## Reading order

1. `architecture/target-architecture.md`
2. `resources/implementation-audit.md`
3. `resources/closure-certification-baseline.md`
4. `resources/audit-normalization-and-adjustments.md`
5. `resources/current-state-gap-analysis.md`
6. `resources/final-remediation-ledger.md`
7. `resources/closure-manifest-spec.md`
8. `resources/de-hosting-authority-closeout.md`
9. `resources/support-target-runtime-disclosure-shim-proof.md`
10. `architecture/implementation-plan.md`
11. `architecture/acceptance-criteria.md`
12. `architecture/validation-plan.md`
13. `navigation/source-of-truth-map.md`
14. `navigation/change-map.md`
15. `architecture/cutover-checklist.md`
16. `navigation/artifact-catalog.md`

## Non-negotiable cutover rules

1. **One bounded claim only.** No release wording may exceed the certified
   support envelope frozen by this packet.
2. **One live constitutional path only.** No second constitutional authority,
   side constitution, or host-native shadow authority may remain after merge.
3. **No hidden host authority.** GitHub and CI may only project or bind
   canonical authority artifacts; they may never mint authority.
4. **No consequential supported run without the full constitutional bundle.**
   Missing evidence blocks the claim.
5. **No support widening in this packet.** Reduced, experimental, and denied
   surfaces remain bounded exactly as declared.
6. **No disclosure overclaim.** RunCard and HarnessCard references must resolve
   to retained evidence or the release fails.
7. **No path-critical historical shims.** Retained shims must be static-audit
   clean and retirement-conditioned.
8. **No deferred deletions.** At least one live deletion or demotion receipt is
   required for closure.
9. **No repo-local binding surface may become authoritative by accident.**
   Downstream `.github/workflows/**` changes remain projections over `.octon/**`
   authorities.
10. **No further architecture packet for the same claim.** After promotion, the
    next round is pass/fail certification against this packet’s acceptance and
    validation contracts.

## Exit path

Promote the closure manifest, release-blocking validators, disclosure-alignment
rules, shim-independence audit, and retirement evidence into durable `.octon/**`
surfaces; wire any repo-local CI bindings as non-authoritative downstream
projections; cut the certification release; then archive this packet and treat
future review for this claim as certification maintenance unless a later ADR
explicitly widens scope.
