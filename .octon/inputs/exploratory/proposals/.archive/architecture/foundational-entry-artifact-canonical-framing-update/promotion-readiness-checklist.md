# Promotion Readiness Checklist

_Status: In-review proposal packet artifact_


- [ ] Human operator accepts this proposal for implementation.
- [ ] Proposed `.octon/README.md` wording reviewed for operator clarity.
- [ ] Proposed `.octon/AGENTS.md` wording reviewed for adapter constraints.
- [ ] Repo-root `README.md` and `AGENTS.md` companion scope routed through a
  linked repo-local proposal before durable changes land there.
- [ ] `.octon/AGENTS.md` parity plan confirmed.
- [ ] Ingress manifest/read-order impact checked.
- [ ] Glossary update reviewed for compatibility with existing terms.
- [ ] Architecture specification edit reviewed for no new control plane.
- [ ] No runtime-statechart, agent-node, Durable Object, MCP, or external-engine implementation included.
- [ ] Proposal standard validator passes.
- [ ] Architecture proposal standard validator passes or equivalent manual check is retained.
- [ ] Implementation-readiness validator passes.
- [ ] Markdown links pass.
- [ ] SHA256SUMS verifies.
- [ ] Promotion evidence destination under `state/evidence/**` is identified.
- [ ] Rollback diff can restore previous entry-artifact wording.
