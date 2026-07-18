# Proposal Reading and Precedence Map

## Authority Boundary

Current constitutional, product, runtime, and instance governance outrank this
packet. The intake, reconciliation, parent program, Revision 2 proposal, this
packet, provider session state, sandbox state, generated views, and retained
evidence are non-authoritative.

## Proposal-Local Precedence

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `resources/packet-contract.yml`
4. `resources/engineering-disposition-ed001.yml`
5. `architecture/target-architecture.md`
6. `architecture/acceptance-criteria.md`
7. `architecture/implementation-plan.md`
8. supporting architecture and resource documents
9. `navigation/artifact-catalog.md`
10. `.octon/generated/proposals/registry.yml`
11. `README.md`

## Durable Ownership Split

| Concern | Planned owner | Boundary |
| --- | --- | --- |
| Authority decision, exact one-shot guard, and guard-owning launch API | RP-01 | RP-02 consumes the frozen interface and may not issue, widen, or reinterpret authority. |
| Candidate environment, HOME, FD policy, sandbox, independent repo, inference-only one-run relay, and commit export | RP-02 | Isolation mechanics only; the relay consumes a pre-existing upstream transport and provides no credential custody, provider administration, or privileged effect. |
| Credential enrollment/custody and privileged effect IPC | RP-04 | RP-02 candidates cannot access broker credentials or privileged IPC. |
| Generic prepare/launch/observe/cancel/usage/retire adapter contract | RP-11 | RP-02 may provide a primary-provider isolation binding but cannot redefine generic adapter semantics. |
| Candidate runtime evidence | packet evidence root and later run evidence | Evidence records facts and cannot authorize a launch or effect. |

## Derived and Host Surfaces

- Upstream provider transport, one-run relay, and macOS sandbox process state
  are deployment-local, non-authoritative, and excluded from promotion targets.
- Candidate repositories are disposable work areas, not canonical Git or
  retained authority.
- Adapter and generated runtime views remain subordinate to current durable
  contracts and freshness checks.
- `.octon/generated/proposals/registry.yml` remains discovery-only and changes
  only through its canonical owning generator.

## Conflict and Failure Rules

- If RP-01 guard semantics are not frozen, RP-02 implementation does not start.
- If the exact client/relay/native profile is unavailable, the candidate can
  reach any non-relay network target, or the route requires candidate-readable
  durable secrets, UE-003 fails and the route remains disabled.
- If the independent repository shares canonical refs, objects, config, hooks,
  or common directory, the boundary fails.
- Missing sandbox, session, environment, FD, export, cleanup, or positive-task
  proof blocks exit.
- A new generic adapter or broker/control plane is prohibited.
