# Target Architecture

## Decision

Octon should perform one final **atomic closure-certification cutover** that
turns the next round into a binary certification event.

The packet is **not** a redesign packet. It is a **closeout** packet.
It lands one final repo-wide, pre-1.0, clean-break update that removes the last
claim-discipline and proof-discipline gaps still preventing an unqualified
closure verdict.

## Certified claim statement

After promotion, Octon may claim the following — and only the following — as a
fully realized unified execution constitution:

> **Octon is a fully realized unified execution constitution within its declared
> supported envelope for `MT-B / WT-2 / LT-REF / LOC-EN` using the
> `repo-shell` host adapter and the `repo-local-governed` model adapter, with
> canonical authority artifacts, run-contract-first lifecycle control,
> disclosure-canonical evidence, executable support-target enforcement,
> release-blocking disclosure parity, shim independence, and live
> build-to-delete evidence.**

Everything outside that envelope remains explicitly reduced, staged,
experimental, or denied.

## What this packet changes

This packet **does not**:

- widen support beyond the certified tuple
- make GitHub or CI authoritative control planes
- redesign the constitutional kernel
- create a second control plane or a second lifecycle source of truth
- introduce a fresh remediation backlog after merge

This packet **does**:

- freeze the bounded claim in one machine-readable closure manifest
- align release wording and disclosure with that frozen claim
- move any remaining consequential host decision logic into canonical authority
  artifacts or demote it outside the certified claim
- make the full consequential run bundle a mandatory proof contract
- make support targets executable through positive and negative tests
- require RunCard and HarnessCard proof-reference resolution before release
- prove retained shims are non-authoritative at runtime
- require at least one deletion or demotion receipt to prove retirement
  discipline is live

## Final architecture layers

### 1. Constitutional kernel

Canonical surfaces:

- `.octon/framework/constitution/**`

Role:

- supreme repo-local authority beneath non-waivable external obligations
- normative and epistemic precedence
- fail-closed obligations
- contract-family registry and shim status

### 2. Claim boundary and support-target layer

Canonical surfaces:

- `.octon/instance/governance/support-targets.yml`
- proposed `.octon/instance/governance/closure/unified-execution-constitution.yml`
- `.octon/instance/governance/disclosure/harness-card.yml`

Role:

- supported claim envelope
- explicit exclusions, reductions, and stage-only surfaces
- permitted release wording and required proof bundle

### 3. Authority-artifact layer

Canonical surfaces:

- `.octon/state/control/execution/approvals/**`
- `.octon/state/evidence/control/execution/**`
- `.octon/framework/engine/runtime/adapters/host/**`

Role:

- bind consequential authority to decision artifacts and grant bundles
- enforce that host surfaces project but never mint authority

### 4. Run-contract-first lifecycle layer

Canonical surfaces:

- `.octon/state/control/execution/runs/<run-id>/**`
- `.octon/state/continuity/runs/<run-id>/**`
- `.octon/state/evidence/runs/<run-id>/**`

Role:

- bind the execution-time unit of truth before side effects
- require the complete consequential run bundle
- retain continuity, replay, intervention, measurement, and assurance

### 5. Disclosure and publication layer

Canonical surfaces:

- `.octon/state/evidence/disclosure/runs/**`
- `.octon/state/evidence/disclosure/releases/**`
- `.octon/state/evidence/validation/publication/build-to-delete/**`

Role:

- disclose supported claims without substituting for source evidence
- fail release when proof references do not resolve
- publish deletion or demotion receipts as retirement evidence

## Final architecture invariants

1. **No certified claim beyond the bounded support envelope.**
2. **No hidden host authority within the certified envelope.**
3. **No consequential supported run without a complete run bundle.**
4. **No reduced or unsupported tuple may silently widen to allow.**
5. **No disclosure claim may ship with unresolved proof references.**
6. **No retained historical shim may remain path-critical to runtime,
   validation, ingress, or bootstrap authority.**
7. **No build-to-delete claim without at least one live deletion or demotion
   receipt.**
8. **No repo-local workflow may outrank canonical `.octon/**` authority.**
9. **No follow-on architecture packet is required for this claim after
   promotion; only certification maintenance remains.**
