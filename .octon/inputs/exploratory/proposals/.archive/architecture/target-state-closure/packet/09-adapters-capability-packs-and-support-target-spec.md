# 09. Adapters, Capability Packs, and Support-Target Spec

## 1. Goal

Preserve the current portable-kernel / non-portable-adapter architecture while making support-tier admission and unsupported-case behavior provably consistent.

## 2. Preserve current architecture

Preserve:
- `.octon/framework/engine/runtime/adapters/host/**`
- `.octon/framework/engine/runtime/adapters/model/**`
- `.octon/framework/capabilities/**`
- `.octon/instance/governance/support-targets.yml`

## 3. Portable kernel vs adapters

### Portable kernel
Remain portable:
- constitutional kernel
- objective/authority/runtime/disclosure contract families
- route semantics
- evidence classes
- proof planes
- certification gates

### Non-portable adapters
Remain adapterized:
- host integrations
- model/provider specifics
- capability pack implementations
- browser/API connectors
- evaluator provider implementations

## 4. Host adapters

Rule:
- host adapters are projection-only and non-authoritative

Minimum host-adapter requirements:
- projected artifact set
- ingest surface mapping
- outbound action mapping
- auth scope
- rate-limit / timeout model
- projection receipt schema
- non-authority declaration

Keep current:
- `repo-shell`
- `github-control-plane`
and any other current host adapters

## 5. Model adapters

Rule:
- support exists only after conformance

For every admitted model adapter require:
- adapter contract
- conformance suite
- supported workload tiers
- supported locale/language-resource tiers
- contamination signatures
- reset policy
- known limitations

## 6. Capability packs

Keep current pack model.
Require every pack to declare:
- side-effect class
- required support tiers
- allowed host adapters
- required approvals
- redaction policy
- measurement hooks

Browser/UI and broader API surfaces remain governed packs and default to `stage_only` or `escalate` unless explicitly admitted.

## 7. Support-target matrix

Canonical authored path:
- `.octon/instance/governance/support-targets.yml`

Create support dossier root:
- `.octon/instance/governance/support-dossiers/<tuple-id>/dossier.yml`

Each dossier must contain:
- tuple identity
- admitted host adapters
- admitted model adapters
- admitted capability packs
- required proof planes
- required lab scenarios
- representative retained runs
- known exclusions
- recertification cadence

Support-targets file remains the compact machine-readable declaration.
Dossiers carry the evidence and rationale that justify admission.

## 8. Unsupported-case behavior

If tuple, adapter, or pack is unsupported:
- `deny` if the action would create material side effects outside policy
- `stage_only` if safe preview/packetization is still useful
- `escalate` only if policy allows a human to bridge the gap

No unsupported tuple may still appear as `support_status: supported` in any active claim-bearing artifact.

## 9. Admission criteria for new tiers

A new tuple is admitted only after:
1. adapter contracts exist
2. adapter conformance passes
3. required packs are admitted
4. support dossier exists
5. required proof planes pass
6. required lab scenarios pass
7. release bundle is regenerated
8. closure certification passes twice with the widened tuple included

## 10. Validators and generators

Create:
- `validate-support-target-matrix.sh`
- `validate-support-dossier-completeness.sh`
- `validate-admitted-pack-subset.sh`
- `validate-adapter-conformance-refs.sh`
- `validate-unsupported-case-routing.sh`

## 11. Migration

1. preserve current support-target matrix
2. introduce support dossiers for all currently active admitted tuples
3. rebind RunCards and HarnessCard to dossier-backed support tuples
4. fail closure if any active tuple lacks a dossier
5. widen support only through dossier + recertification

## 12. Acceptance criteria

- support-target matrix remains explicit and enforced
- every active admitted tuple has a support dossier
- unsupported host/model/pack combinations fail closed
- browser/API packs are admitted only through governed pack policy
- no active claim-bearing artifact overstates support beyond the matrix and dossiers
