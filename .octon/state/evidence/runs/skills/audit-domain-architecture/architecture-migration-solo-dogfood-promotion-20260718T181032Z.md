# Audit Domain Architecture Run

- target: `.octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-solo-dogfood-promotion`
- digest: `sha256:a5a2d541e1b1fe2517d36d95a32498cca0093955928d2cc325662365caf41a70`
- mode: pre-integration, observed, closed-book
- convergence: three passes, stable
- verdict: fail
- blocking findings: 2

The proof-only target and owner routing are coherent. Exact proof protocol,
result identity, adjudication, and non-circular evidence order remain
under-specified. No proof run, implementation, provider mutation, claim
admission, or external effect occurred.
