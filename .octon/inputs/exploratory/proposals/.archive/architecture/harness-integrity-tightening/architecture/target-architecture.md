# Target Architecture

## Historical end state

The durable architecture promoted from this packet is:

1. authored authority remains in durable `framework/**` and `instance/**`
   surfaces rather than in proposal-local material
2. mutable execution control state lives under
   `/.octon/state/control/execution/**`
3. retained per-run execution evidence lives under
   `/.octon/state/evidence/runs/<run_id>/**`
4. ephemeral execution scratch is confined to rebuildable generated roots
5. repo-owned egress and budget policy define network and spend allowances
6. architecture-conformance automation and CI fail closed on write-root,
   egress, budget, and doc-alignment drift

## Boundary posture

- `framework/**/_ops/**` remains portable operational support only
- retained evidence and mutable repo-specific state do not live under
  framework `_ops/**`
- material execution authorization remains routed through the runtime
  authority boundary cited in the source-of-truth map
- proposal paths remain non-canonical after promotion and archival
