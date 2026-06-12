# Acceptance Criteria

1. `verify-governed-mechanism-integration` exists as a registered workflow with
   stages for binding inputs, validating the profile, collecting existing
   evidence refs, running validators, writing the support receipt, and retaining
   workflow evidence.
2. `governed-mechanism-integration-profile-v1` exists as a strict schema and
   fails closed when required surface classes are omitted without an explicit
   `not_applicable` rationale.
3. `governed-mechanism-integration-receipt-v1` exists as a strict schema for
   `support/governed-mechanism-integration-evaluation.yml`.
4. Receipt validation requires verdict, unresolved-item count, blockers,
   mechanism profile ref, current-state architecture review ref,
   implementation conformance ref, post-implementation drift ref, generated
   publication refs, validator refs, evidence refs, authority boundary verdict,
   surface coverage, non-authority classification, mode-specific coverage, and
   implemented packet digest binding.
5. The workflow composes existing implementation conformance, drift/churn,
   generated publication, and current-state mechanism architecture review
   evidence without replacing those owners.
6. Lifecycle postmortem remains optional, evidence-only, and outside hard-gate
   acceptance.
7. Mechanism proposal review requires a proposed mechanism integration profile
   before acceptance.
8. Mechanism proposal closeout and archive readiness require a current passing
   governed mechanism integration receipt tied to the implemented packet digest.
9. Merged or cleaned terminal outcomes require scoped freshness proof on main
   for generated projections, proposal registry, child spines, and mechanism
   docs touched by the mechanism proposal.
10. Validators reject stale aliases, stale proposal backrefs, placeholder-marker
    receipts, stale digests, omitted validators, and any authority claim made
    from raw inputs, generated outputs, proposal-local files, chat, model
    memory, host state, dashboards, or product feature navigation.
11. Findings and dispositions use existing `review-finding-v1` and
    `review-disposition-v1`.
12. Product feature catalog and governed mechanism index docs remain
    navigation or architecture guidance only; they do not become runtime,
    policy, support, closeout, cleanup, or retained-evidence authority.
13. Proposal standard, architecture proposal, implementation readiness,
    governed mechanism integration, governed cross-surface mechanism, product
    feature catalog, publication freshness, terminal freshness, and whitespace
    validation pass.
