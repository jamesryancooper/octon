# Program Plan

## Program objective

Drive Octon from **substantial near-target implementation** to **honest full target-state completion** without widening claims prematurely and without regressing the constitutional kernel that is already in place.

## Program rules

1. **No claim widening before runtime truth exists**
2. **No shim survives without owner + retirement trigger**
3. **No adapter or capability pack claims support without conformance**
4. **No supported consequential envelope without full proof-plane coverage**
5. **No release closeout without disclosure parity**
6. **Every remediation must prefer deletion over retention once safety/performance allow it**

## Milestone order

### M0 — Claim freeze and traceability freeze
Outputs:
- freeze finding IDs and workstream ownership
- publish claim criteria and checklists
- make all future progress report against this packet

### M1 — Runtime/objective cutover
Owns: WS0  
Exit condition:
- run-contract-first entrypoint is live
- mission demoted correctly
- stage/checkpoint emission becomes routine

### M2 — Authority cutover
Owns: WS1  
Exit condition:
- independent authority engine implemented
- runtime-native approval/grant/lease/revocation/quorum evaluation
- host projection no longer de facto authority

### M3 — Durable lifecycle/evidence cutover
Owns: WS2  
Exit condition:
- consequential runs are replayable, measurable, intervention-logged, and resumable
- external replay index is operational where required

### M4 — Proof and lab universalization
Owns: WS3  
Exit condition:
- all required proof planes are explicit and blocking
- lab scenario/shadow/fault runtime feeds promotion evidence

### M5 — Adapter/support/capability enforcement
Owns: WS4  
Exit condition:
- adapter conformance is gating
- capability packs exist for broader action surfaces
- support-target routing is runtime-real

### M6 — Disclosure/retention/closeout
Owns: WS5  
Exit condition:
- RunCard/HarnessCard are mandatory on the live supported path
- final claim predicate is encoded and blocking
- release closeout consumes governance overlays

### M7 — Simplification/deletion/brownfield adoption
Owns: WS6  
Exit condition:
- transitional shims retired or justified
- historical wave proof demoted to lineage
- brownfield retrofit path published and testable

## Dependency graph

- WS0 must land before WS1 and WS2 can be considered complete.
- WS1 must land before WS4 can honestly claim adapter/authority separation.
- WS2 must land before WS3 and WS5 can close proof and disclosure honestly.
- WS3 and WS4 are parallelizable after WS2, but both feed WS5.
- WS6 should not aggressively delete until WS5 has stabilized the new truth path.

## Program governance

### Required operating artifacts
- decision log entry for every material re-bound or deletion
- before/after evidence bundle for every workstream
- explicit unsupported-case notes whenever a new boundary is introduced
- retirement registry updates for any shim or transitional surface touched

### Required review roles
- constitutional owner
- runtime owner
- authority/governance owner
- assurance/lab owner
- disclosure/release owner

A single human may hold multiple roles in this repository, but each review concern must be explicitly accounted for.

## Risk register (summary)

- **R-01:** run-contract cutover leaves legacy mission semantics alive under a new name  
  Mitigation: remove mission-first execution entrypoints from supported paths.

- **R-02:** authority engine remains nominally separated but still host-coupled  
  Mitigation: runtime-native artifact consumers and host-independent tests.

- **R-03:** proof planes appear complete only in closure bundles  
  Mitigation: require them in routine supported consequential runs.

- **R-04:** capability-pack expansion widens attack surface faster than governance  
  Mitigation: adapter + support-target + disclosure parity gate.

- **R-05:** brownfield retrofit becomes silent entropy import  
  Mitigation: explicit retrofit checklist and deny-by-default adoption modes.

## Definition of done for the overall program

The program is done only when:
- every claim criterion in `01_TARGET_STATE_AND_CLAIM_CRITERIA.md` is green,
- every critical finding in `02_GAP_MODEL_AND_FINDINGS.md` is closed,
- every required artifact in `05_CONTRACT_COMPLETION_LEDGER.md` is completed in substance,
- every checklist in `06_CHECKLISTS/**` passes without waivers.
