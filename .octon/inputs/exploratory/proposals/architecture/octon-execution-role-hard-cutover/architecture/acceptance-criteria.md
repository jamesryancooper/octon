# Acceptance Criteria

The hard cutover is complete only when all criteria are true.

1. `framework/agency/**` is absent from active authority.
2. `framework/execution-roles/**` exists and is the only execution-role subsystem.
3. No active `agents`, `assistants`, `teams`, or `subagents` registry exists.
4. `execution role` is the canonical noun in authoritative docs.
5. `orchestrator`, `specialist`, `verifier`, and `composition profile` are the only operator-facing role types.
6. `actor_ref` is absent from runtime request/receipt schemas.
7. `execution_role_ref` is required for consequential execution requests.
8. `run-contract` is the only atomic consequential execution unit.
9. Mission-only execution fallback is removed.
10. Workflows are retained only where governance/evidence/recovery/publication/support-proof value exists.
11. Context packs are mandatory for consequential runs.
12. Generated cognition is never authority and cannot satisfy evidence obligations.
13. Support-target live claims are schema-valid and tuple-admitted.
14. Browser/API/multimodal support is live only where runtime services and support dossiers exist.
15. Runtime event schema exists and records approval, checkpoint, evidence, replay, rollback, intervention, disclosure, and closeout events.
16. Network egress policy uses connector leases for external capability surfaces.
17. Execution budgets cover run, mission, model, tool, browser, API, wall-clock, retry, and evidence storage classes.
18. RunCards and HarnessCards are generated only from retained evidence.
19. Hard-cutover validator passes.
20. Retained promotion evidence exists under `state/evidence/validation/**`.
