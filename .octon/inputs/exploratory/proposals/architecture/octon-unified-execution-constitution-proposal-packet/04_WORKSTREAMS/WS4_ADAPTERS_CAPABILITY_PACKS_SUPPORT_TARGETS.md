# WS4 — Adapter conformance, capability packs, and support-target enforcement

## Purpose

Finish the portability and support-envelope model so kernels stay portable, non-portabilities are explicit, and widening support requires evidence.

## Audit findings addressed

F-04, F-11, F-12, F-13, F-24

## Exact repo paths / subsystems to change

- `.octon/framework/constitution/contracts/adapters/**`
- `.octon/framework/engine/runtime/adapters/host/**`
- `.octon/framework/engine/runtime/adapters/model/**`
- `.octon/instance/governance/support-targets.yml`
- `.octon/framework/capabilities/**`
- `.github/workflows/**`

## Deliverables

- Universal adapter-conformance suites and admission gates.
- Governed capability-pack manifests for browser/UI and broader API surfaces (create the pack roots if absent).
- Runtime routing that reads support-target declarations directly for allow / stage_only / escalate / deny behavior.
- Evidence-driven widening of support tiers and adapter envelopes only after disclosure parity lands.

## Implementation sequence

1. **Stabilize the current path**
   - confirm the exact live behavior on the listed subsystems
   - write a red/green acceptance matrix before editing
2. **Implement the cutover in runtime terms**
   - make the new target-state surface real in code and emitted artifacts
   - keep compatibility only where the packet explicitly allows it
3. **Backfill evidence**
   - update run evidence, proof, disclosure, and governance overlays so the new truth path is inspectable
4. **Delete or demote obsolete scaffolding**
   - remove what is no longer load-bearing
   - where removal is unsafe in the same step, register a named retirement trigger and owner

## Acceptance criteria

- [ ] New host/model adapter or capability pack cannot ship without contract + conformance suite + retained proof.
- [ ] Support-target matrix drives runtime routing and release claims directly.
- [ ] Unsupported tuples fail closed automatically.
- [ ] Browser/API action surfaces exist as governed packs rather than incidental tools.

## Dependencies

- `WS1`
- `WS3`

## Claim criteria unlocked by this workstream

- Portable-kernel / adapter-governed claim
- Support-target-enforced claim
- Governed capability pack claim

## Required evidence before calling this workstream complete

- code diff showing the new live path
- updated contract/artifact examples where applicable
- routine run evidence from the supported consequential envelope
- validator or workflow output proving the new gate/path is enforced
- explicit deletion or retirement note for any legacy surface touched

## Anti-patterns to avoid

- leaving the old surface on the critical path while calling the new one canonical
- proving the workstream only with a special closure or migration run
- treating new schema files as sufficient evidence of runtime completion
- widening support or claims during the workstream before proof/disclosure catch up
