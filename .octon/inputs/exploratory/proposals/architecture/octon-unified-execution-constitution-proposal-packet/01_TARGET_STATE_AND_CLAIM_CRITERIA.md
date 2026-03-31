# Target State and Claim Criteria

## Target-state definition

Octon reaches **full unified execution constitution** when the repository’s authored constitutional model, its runtime behavior, its evidence surfaces, and its release claims all collapse into the same governed system of truth.

That target state has eleven defining properties:

1. **Constitutional supremacy is real in runtime practice**  
   `framework/constitution/**` and `instance/**` are not only the authored authority surfaces; the runtime actually consumes them as the primary control plane.

2. **Objective model is correctly layered**  
   Workspace charter pair → mission charter pair → run contract → stage attempt / checkpoint / continuity.  
   Mission remains continuity/ownership, not the atomic execution primitive.

3. **Authority is first-class and artifact-native**  
   ApprovalRequest, ApprovalGrant, ExceptionLease, Revocation, QuorumPolicy, DecisionArtifact, and GrantBundle are runtime-consumed authority artifacts. Host-native surfaces only project or witness them.

4. **Run roots are the primary execution-time truth**  
   Every consequential run emits run contract, run manifest, runtime state, stage attempts, checkpoints, rollback posture, continuity, receipts, measurement, intervention, disclosure, and replay pointers.

5. **Lifecycle is durable and resumable**  
   Octon behaves as an event-sourced or equivalently durable lifecycle rather than a fragile conversation.

6. **Evidence is classed and replayable**  
   Git-inline control evidence, git-tracked manifests/pointers, and external immutable replay/telemetry storage are used intentionally and consistently.

7. **Proof is multi-plane and required**  
   Structural, functional, behavioral, governance, recovery, and maintainability proof exist and block unsupported claims.

8. **Lab is top-level and live in substance**  
   Scenarios, replay, shadow, fault, and adversarial discovery are real experimentation surfaces feeding behavioral proof.

9. **Portability is contract-mediated**  
   Model and host boundaries are replaceable adapters governed by formal contracts and conformance tests. Capability expansion lands through governed packs.

10. **Disclosure is mandatory**  
    RunCard and HarnessCard are canonical disclosure surfaces. They are subordinate to durable evidence but mandatory for claims.

11. **Build-to-delete is operational**  
    Legacy shims, transitional overlays, and certification-era scaffolds either carry explicit owners/removal triggers or are removed.

## What does *not* count as completion

The following are explicitly insufficient:

- Renaming a directory to match the target-state vocabulary
- Adding schemas without runtime consumers
- Adding roots/directories without emitted artifacts
- Keeping GitHub labels or comments as de facto authority
- Keeping run-contract or stage-attempt concepts on paper while the kernel still starts from workflow + mission
- Publishing RunCard/HarnessCard without routine live emission
- Using wave/migration/closure bundles as the primary evidence story after cutover
- Treating experimental or stage_only envelopes as supported
- Leaving critical closeout rules implicit in prose

## Exact closeout claim predicate

Octon may publish the final claim only if every claim criterion below is green:

### C-01 Objective cutover
- The live consequential execution entrypoint binds on RunContract or run id resolving to RunContract.
- `mission_id` is not the primary required runtime primitive on supported consequential flows.
- Ordinary supported runs emit stage-attempt records and checkpoints.

### C-02 Authority cutover
- `authority_engine` is a substantive independent subsystem.
- Runtime evaluates grants, leases, revocations, quorum, and decision artifacts without GitHub presence.
- Host adapters remain explicitly non-authoritative.

### C-03 Durable lifecycle
- Every supported consequential run emits run-manifest, runtime-state, continuity, rollback posture, receipts, measurement, interventions, disclosure, and replay pointers.
- Resume/reset/compensation behavior is validated.

### C-04 Evidence and replay
- Evidence classes are explicit and enforced.
- External immutable replay index exists for classes that must not rely on git alone.

### C-05 Multi-plane proof
- Structural, functional, behavioral, governance, recovery, and maintainability proof are all present and green for the supported live envelope.
- Hidden/held-out evaluators exist for claim protection.

### C-06 Lab substance
- Lab scenarios, replay, shadow, faults, and probes are exercised and retained as evidence.
- Behavioral and recovery claims depend on lab evidence, not only curated closure bundles.

### C-07 Adapter and capability governance
- Host/model adapters cannot ship or widen claims without conformance evidence.
- Browser/UI and broader API surfaces are admitted via governed capability packs.

### C-08 Support-target enforcement
- Runtime routing and release disclosure both consume the support-target matrix.
- Unsupported tuples deny by default; staged tuples remain stage_only until proof lands.

### C-09 Disclosure parity
- RunCard is mandatory for every supported consequential run.
- HarnessCard is mandatory for any release-scale claim.
- Disclosed envelope exactly matches supported evidence-backed envelope.

### C-10 Retirement and deletion
- Transitional shims are retired or explicitly justified with owner + review date + retirement trigger.
- Historical wave/certification evidence is clearly lineage-only once generalized runtime proof exists.

### C-11 Brownfield readiness
- Octon includes an explicit retrofit path for older repositories so adoption can be governed, not improvised.

## Preserve while finishing

These target-state-aligned assets must not be undone during remediation:
- constitutional kernel
- workspace charter pair
- non-authoritative host/model adapter stance
- top-level lab
- top-level observability
- RunCard/HarnessCard contracts
- support-target honesty
- orchestrator-first agency simplification
- build-to-delete overlays
