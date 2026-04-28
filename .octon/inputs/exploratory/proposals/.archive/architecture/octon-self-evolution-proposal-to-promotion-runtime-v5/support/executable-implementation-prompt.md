# Executable Implementation Prompt

Act as a senior Octon implementation orchestrator, constitutional self-evolution runtime engineer, proposal-promotion pipeline implementer, assurance/recertification engineer, and authority-boundary auditor.

Implement the proposal packet `octon-self-evolution-proposal-to-promotion-runtime-v5` in a single atomic migration.

Primary implementation target: **Self-Evolution Proposal-to-Promotion Runtime v5**.

Do not broaden into full v5. Implement the candidate -> proposal -> decision -> promotion -> recertification pipeline.

Mandatory behavior:
1. Inspect the live repo and proposal packet before edits.
2. Detect v1-v4 dependency presence. Do not silently implement missing v1-v4 layers.
3. Add canonical contracts for Evolution Program, Evolution Candidate, Proposal Compiler, Governance Impact Simulation, Constitutional Amendment Request, Promotion Runtime, Recertification Runtime, and Evolution Ledger.
4. Add repo-specific policies under `instance/governance/evolution/**`.
5. Add control/evidence/continuity root conventions under `state/**`.
6. Add runtime/CLI surfaces or fail-closed command stubs for `octon evolve`, `octon amend`, `octon promote`, and `octon recertify`.
7. Add validators and negative controls proving no self-authorization.
8. Keep proposal packets, evidence distillation, lab success, simulations, generated summaries, chat, and dashboards non-authoritative.
9. Ensure promotion writes only to declared durable targets after accepted decision.
10. Require retained promotion receipts and post-promotion recertification before closure.
11. Run validation; fix failures; report results.

Completion requires no unresolved blockers, correct root placement, passing validation, retained promotion/recertification evidence shape, and explicit deferred-scope documentation.
