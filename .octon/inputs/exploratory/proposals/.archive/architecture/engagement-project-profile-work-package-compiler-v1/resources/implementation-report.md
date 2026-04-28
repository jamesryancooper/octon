# Implementation Report

## Summary

The proposal packet was implemented as a v1 prepare-only lifecycle layer from
Engagement start through Project Profile, per-engagement Objective Brief,
Work Package compilation, Decision Request generation, connector posture,
Evidence Profile selection, context-pack request preparation, and first
run-contract candidate preparation.

The promoted authority is no longer in this proposal packet. Durable contract
and runtime authority now lives under `framework/**` and `instance/**`; mutable
compiler truth lives under `state/control/**`; retained proof lives under
`state/evidence/**`; generated read models remain optional derived projections.

## Implemented Target State

- Added canonical schemas/specs for Engagement, Project Profile, Work Package,
  Decision Request, Evidence Profile, Preflight Evidence Lane, and Tool/MCP
  Connector Posture.
- Added constitutional contract mirrors and registry/family entries.
- Added instance governance policy for the compiler, evidence profiles,
  preflight lane, connector posture, connector registry, and engagement path
  families.
- Added runtime CLI flow:
  - `octon start`
  - `octon profile`
  - `octon plan`
  - `octon arm --prepare-only`
  - `octon decide`
  - `octon status`
- Added runtime writer for Project Profile authority under
  `.octon/instance/locality/project-profile.yml`, backed by retained source
  evidence.
- Added compiler output under
  `.octon/state/control/engagements/<engagement-id>/work-package.yml`.
- Added first run-contract candidate output under
  `.octon/state/control/engagements/<engagement-id>/run-candidates/<run-id>/run-contract.candidate.yml`.
- Added fail-closed handoff behavior: unresolved Decision Requests block
  candidate submission, and candidate submission is prepare-only through the
  existing `octon run start --contract` path.

## Validation Evidence

Commands run:

```text
cargo fmt -p octon_kernel
cargo check -p octon_kernel
cargo test -p octon_kernel commands::engagement
cargo test -p octon_kernel cli_parses_engagement
bash .octon/framework/assurance/runtime/_ops/scripts/validate-engagement-work-package-compiler.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-engagement-work-package-compiler.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-contract-family-version-coherence.sh
```

Results:

- `cargo check -p octon_kernel`: passed.
- `commands::engagement`: passed, 2/2.
- `cli_parses_engagement`: passed, 6/6.
- Engagement compiler validator: passed, `errors=0`, including the live
  validation Engagement and Work Package.
- Engagement compiler negative-control test: passed, 14/14.
- Architecture conformance: passed, `errors=0`.
- Contract family version coherence: passed, `errors=0`.

The live compiler exercise created:

- `.octon/state/control/engagements/engagement-compiler-v1-validation/engagement.yml`
- `.octon/instance/locality/project-profile.yml`
- `.octon/state/control/engagements/engagement-compiler-v1-validation/objective/objective-brief.yml`
- `.octon/state/control/engagements/engagement-compiler-v1-validation/work-package.yml`
- `.octon/state/control/engagements/engagement-compiler-v1-validation/decisions/engagement-compiler-v1-validation-authorize-run.yml`
- `.octon/state/control/engagements/engagement-compiler-v1-validation/run-candidates/engagement-compiler-v1-validation-run-1/run-contract.candidate.yml`

The attempted candidate handoff before Decision Request resolution failed
closed with an unresolved-Decision-Request error and did not create canonical
run execution roots.

## Known Limitation

The broad `cargo test -p octon_kernel` suite still fails because existing
runtime-effective route bundle and pack-route digests have drifted with
`FCR-025`. This is unrelated to the Engagement compiler implementation and was
observed before this migration slice. The migration does not republish generated
effective route bundles to avoid masking a separate publication/freshness
concern inside this proposal implementation.

## Deferred Scope

The implementation intentionally does not add broad live MCP execution,
arbitrary external API autonomy, browser-driving autonomy, deployment
automation, credential provisioning, multi-repo autonomy, autonomous
support-target widening, autonomous governance amendments, destructive external
operations, or a fully unattended long-horizon mission loop.

## Authority Confirmation

- No runtime or policy target depends on this proposal packet or the raw
  conversation file.
- The conversation file remains source lineage only under `inputs/**`.
- Generated compiler projections are operator read models only and carry
  non-authority posture.
- The run lifecycle and authorization boundary remain intact: material
  execution must still enter through `octon run start --contract`, runtime
  authorization, run lifecycle binding, and authorized-effect enforcement.
- No rival control plane was introduced. Decision Requests are wrappers that
  resolve into existing canonical approval, exception, revocation, and evidence
  roots.
