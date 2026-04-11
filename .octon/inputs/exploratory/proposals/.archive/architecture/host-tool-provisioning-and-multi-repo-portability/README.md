# Host-Tool Provisioning and Multi-Repo Portability

This is a temporary, implementation-scoped architecture proposal for
`host-tool-provisioning-and-multi-repo-portability`. It translates the
current portability problem into one manifest-governed packet that can be
reviewed, promoted, and archived without relying on chat history.

## Packet purpose

This packet defines how Octon should provision and resolve host-scoped
external tools such as `shellcheck`, `cargo-machete`, and `cargo-udeps`
without violating Octon's authority boundaries.

The target state is a governed subsystem that:

- keeps durable repo authority inside `/.octon/**`;
- keeps OS- and machine-specific binaries outside the repo;
- supports multiple Octon-enabled repositories on one host without duplicate
  ad hoc installs;
- allows repo commands to declare tool requirements declaratively;
- provides one explicit provisioning command rather than hiding host mutation
  inside `/init`; and
- preserves fail-closed behavior when mandatory tools are unresolved.

## Governing thesis

> Octon should treat external analyzers and toolchains as host-scoped runtime
> dependencies with repo-scoped desired requirements, not as authored repo
> surfaces and not as throwaway `/tmp` side effects.

## Scope summary

In scope:

- architecture for framework host-tool contracts and repo-local desired
  requirements;
- host-scoped install, quarantine, evidence, and resolution model;
- multi-repo portability on one machine;
- integration posture for `repo-hygiene` as the first consumer;
- bootstrap, provisioning, and validation boundaries.

Out of scope:

- fully implementing the subsystem now;
- shipping third-party binaries inside `/.octon/**`;
- mutating global system package managers silently; and
- treating a one-off `/tmp` install as steady-state architecture.

## Reading order

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `README.md`
4. `PACKET_MANIFEST.md`
5. `navigation/source-of-truth-map.md`
6. `resources/input-baseline-and-source-normalization.md`
7. `resources/source-register.md`
8. `architecture/current-state-gap-map.md`
9. `architecture/target-architecture.md`
10. `architecture/file-change-map.md`
11. `architecture/implementation-plan.md`
12. `architecture/migration-cutover-plan.md`
13. `architecture/validation-plan.md`
14. `architecture/acceptance-criteria.md`
15. `architecture/closure-certification-plan.md`
16. `architecture/follow-up-gates.md`
17. `architecture/conformance-card.md`
18. `resources/risk-register.md`
19. `resources/assumptions-and-blockers.md`
20. `resources/evidence-plan.md`
21. `resources/rejection-ledger.md`
22. `resources/source_inputs/**`
23. `resources/repo_evidence/**`
24. `navigation/artifact-catalog.md`
25. `SHA256SUMS.txt`

## Promotion scope

This proposal uses `promotion_scope: octon-internal`. The durable outputs are
all repo-local `/.octon/**` surfaces. The actual host-scoped install cache and
provisioning receipts live outside the repo and are therefore architectural
runtime state, not proposal promotion targets.
