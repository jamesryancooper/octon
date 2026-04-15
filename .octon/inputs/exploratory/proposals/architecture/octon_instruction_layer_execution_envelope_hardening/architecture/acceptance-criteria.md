# Acceptance Criteria

## Concept 1 — Instruction-layer provenance, precedence, and progressive-disclosure hardening

The concept is accepted only if all are true:

1. The existing instruction-layer manifest schema is refined without creating a parallel contract family.
2. Consequential runs or reference fixtures surface capability/class/envelope provenance in the manifest.
3. `tool-output-budgets.yml` is sufficient to express the envelope policy expected by the runtime.
4. A dedicated validator proves manifest completeness for governed capability use.
5. The validator is wired into blocking CI.
6. No raw `inputs/**`, generated outputs, or proposal artifacts become runtime truth.

## Concept 2 — Capability invocation and output-envelope normalization

The concept is accepted only if all are true:

1. Request / grant / receipt semantics are additive refinements of current engine-runtime spec, not a second execution protocol.
2. Repo-shell class policy, capability pack manifests, governance pack overlays, and runtime admissions agree on the normalized semantics.
3. A dedicated validator proves request / grant / receipt / class / pack / envelope coherence.
4. At least one retained example or fixture demonstrates raw-payload-ref compliance where required.
5. The support-target universe remains unchanged.
6. No new control plane, UI approval plane, or generated authority plane is introduced.

## Packet-level acceptance

- both concepts remain `adapt`
- zero unresolved blockers remain
- two consecutive validation passes succeed with no new blocking issue
- required evidence is retained
- operator/runtime touchpoints are materially wired, not merely described
