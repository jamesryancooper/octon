# Full Concept Integration Assessment

## Component: Authorized Effect Token Enforcement

### What it is

A runtime enforcement layer in which every material side-effecting API consumes a typed token derived from a successful authorization decision. The token encodes what kind of effect is allowed, for which Run, scope, support target, capability pack, and validity window.

### Failure mode addressed

- direct material path bypass;
- generated/read-model or host projection acting as implicit authority;
- ambient GrantBundle reuse beyond intended scope;
- wrong API using right grant for wrong effect;
- stale grants after revocation or lifecycle transition;
- untraceable side effects;
- support-target claims without executable proof.

### Why it belongs in the Governed Agent Runtime

Token verification and consumption occur at the point of execution. That is runtime behavior, not constitutional authorship. The Constitutional Engineering Harness owns the authority model and proof obligations; the Governed Agent Runtime enforces them.

### Why it belongs partly in the broader Constitutional Engineering Harness

The harness must define:

- fail-closed obligations;
- support-target proof requirements;
- evidence expectations;
- proposal and promotion rules;
- generated/read-model non-authority;
- validation and assurance planes.

### Cost and complexity

- schema churn across request/grant/receipt/event contracts;
- Rust API signature changes;
- test fixture creation;
- compatibility-path retirement;
- extra evidence writes;
- operator-facing disclosure updates.

The cost is justified because it prevents the most damaging class of runtime failure: material action outside the authorized envelope.

### Tradeoffs

| Tradeoff | Resolution |
|---|---|
| More API ceremony | Accept for material effects; do not require tokens for pure read-only operations. |
| Potential false denials | Use stage-only/shadow cutover before hard enforcement. |
| More evidence volume | Compact only after preserving token lineage and receipts. |
| Token schema complexity | Keep token fields focused on authorization, scope, lifecycle, and proof. |
| Runtime portability | Keep effect classes portable; adapter-specific details live behind support-target refs. |

### Adopt / defer / reject

Adopt now for live material path families. Defer browser/API/frontier expansion. Reject any implementation that leaves material side effects callable without token verification.
