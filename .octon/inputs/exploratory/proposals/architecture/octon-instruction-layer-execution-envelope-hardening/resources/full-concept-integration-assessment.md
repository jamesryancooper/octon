# Full Concept Integration Assessment

## Concept 1 — Instruction-layer provenance, precedence, and progressive-disclosure hardening

### A. Upstream concept record
- **Mechanism:** make every consequential run emit a complete, inspectable record of what was loaded into the model-facing instruction layer and why
- **Why it mattered upstream:** the source separated prompt construction from generic context management and argued that high-signal, minimal, dynamically loaded context is essential for reliable long-running work
- **Verification correction:** the live repo already has an instruction-layer manifest plus precedence and output-budget surfaces, so this is a refinement, not a missing subsystem

### B. Current Octon coverage
Current evidence:
- `/.octon/framework/constitution/contracts/runtime/instruction-layer-manifest-v2.schema.json`
- `/.octon/framework/constitution/precedence/**`
- `/.octon/instance/ingress/AGENTS.md`
- `/.octon/instance/agency/runtime/tool-output-budgets.yml`

Authority / control / evidence posture:
- authoritative schema and precedence already exist
- no special new control root exists or is needed
- evidence obligation exists indirectly through support-target / pack requirements

Usability judgment:
- **partially usable** today, because a run can already emit a manifest, but the repo still relies on inference across several surfaces to understand active capability/tool surface and envelope posture

### C. Coverage judgment
- **coverage_status:** partially_covered
- **gap_type:** extension_needed; overlap_existing_surface

### D. Conflict / overlap / misalignment analysis
This concept overlaps the existing runtime family and runtime overlay point. That is a good sign. The misstep would be introducing a new “context assembly” family or derived effective prompt truth. The correct move is to deepen the current manifest, not duplicate it.

### E. Integration decision rubric outcome
- **Durable meaning:** framework runtime contract + instance runtime overlay
- **Live control:** unchanged existing run-control path
- **Retained proof:** enriched existing evidence practices
- **Continuity:** none new
- **Enforcement:** new validator + regression tests + CI
- **Touchpoints:** ingress / manifest emission / tool-output budget policy / conformance CI
- **Derived outputs:** not required for closeout

### F. Final disposition
**adapt**

---

## Concept 2 — Capability invocation and output-envelope normalization

### A. Upstream concept record
- **Mechanism:** normalize how a governed execution action is requested, granted, and evidenced so pack admission, execution class, and output envelope are inspectable without guesswork
- **Why it mattered upstream:** the source emphasized structured tool calls, schemas, and result handling; stage 2 translated that into engine/runtime and capability-pack surfaces
- **Verification correction:** the live repo already has request / grant / receipt and pack admission surfaces, so the remaining work is normalization, not invention

### B. Current Octon coverage
Current evidence:
- `/.octon/framework/engine/runtime/spec/execution-request-v2.schema.json`
- `/.octon/framework/engine/runtime/spec/execution-grant-v1.schema.json`
- `/.octon/framework/engine/runtime/spec/execution-receipt-v2.schema.json`
- `/.octon/instance/governance/policies/repo-shell-execution-classes.yml`
- `/.octon/framework/capabilities/packs/{shell,repo}/manifest.yml`
- `/.octon/instance/governance/capability-packs/shell.yml`
- `/.octon/instance/capabilities/runtime/packs/admissions/shell.yml`

Authority / control / evidence posture:
- authority already exists in engine spec + pack manifests + repo policy overlays
- control already exists through the authorization boundary and run roots
- evidence already exists through receipts and pack-required proof, but the semantic chain is not yet explicit enough

Usability judgment:
- **partially usable** today, because the repo can govern execution, but operators still need to stitch together multiple sources to prove which class / pack / envelope semantics applied

### C. Coverage judgment
- **coverage_status:** partially_covered
- **gap_type:** extension_needed; consolidation_needed; overlap_existing_surface

### D. Conflict / overlap / misalignment analysis
A new “tool contract family” would be a mistake. The repo already localizes broader action surfaces through capability packs and routes material execution through the engine boundary. The right move is to normalize those existing surfaces.

### E. Integration decision rubric outcome
- **Durable meaning:** engine runtime spec + framework packs + repo-local pack governance
- **Live control:** unchanged existing run-root / grant path
- **Retained proof:** enriched execution receipts + validator outputs
- **Continuity:** none new
- **Enforcement:** new coherence validator + tests + CI
- **Touchpoints:** authorization boundary, repo-shell class policy, pack admissions, conformance workflow
- **Derived outputs:** optional later; not required now

### F. Final disposition
**adapt**

---

## Excluded concept ledger

These remain out of scope for packetization because the live repo already covers them or they remain non-transferable:
- canonical run-loop contract — already covered by objective/runtime family
- engine-owned authorization boundary and tripwires — already covered
- continuity handoffs — already covered
- error taxonomy / retries — already covered
- verification evidence loops — already covered
- scoped delegation — already covered
- persistent memory as authority — non-transferable
- framework-specific harness packaging — non-material for Octon
