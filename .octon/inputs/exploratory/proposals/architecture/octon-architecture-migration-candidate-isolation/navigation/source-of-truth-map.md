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
4. `architecture/target-architecture.md`
5. `architecture/acceptance-criteria.md`
6. `architecture/implementation-plan.md`
7. supporting architecture and resource documents
8. `navigation/artifact-catalog.md`
9. `.octon/generated/proposals/registry.yml`
10. `README.md`

## Durable Ownership Split

| Concern | Planned owner | Boundary |
| --- | --- | --- |
| Authority decision, exact one-shot guard, and guard-owning launch API | RP-01 | RP-02 consumes the frozen interface and may not issue, widen, or reinterpret authority. |
| Candidate environment, HOME, FD policy, sandbox, independent repo, provider session, and commit export | RP-02 | Isolation mechanics only; no credential custody or privileged effect. |
| Credential enrollment/custody and privileged effect IPC | RP-04 | RP-02 candidates cannot access broker credentials or privileged IPC. |
| Generic prepare/launch/observe/cancel/usage/retire adapter contract | RP-11 | RP-02 may provide a primary-provider isolation binding but cannot redefine generic adapter semantics. |
| Candidate runtime evidence | packet evidence root and later run evidence | Evidence records facts and cannot authorize a launch or effect. |

## Derived and Host Surfaces

- Provider session state and macOS sandbox process state are deployment-local,
  non-authoritative, and excluded from promotion targets.
- Candidate repositories are disposable work areas, not canonical Git or
  retained authority.
- Adapter and generated runtime views remain subordinate to current durable
  contracts and freshness checks.
- `.octon/generated/proposals/registry.yml` remains discovery-only and is not
  edited by this delegated child-authoring task.

## Conflict and Failure Rules

- If RP-01 guard semantics are not frozen, RP-02 implementation does not start.
- If the chosen provider session requires candidate-readable durable secrets,
  UE-003 fails and the route remains disabled.
- If the independent repository shares canonical refs, objects, config, hooks,
  or common directory, the boundary fails.
- Missing sandbox, session, environment, FD, export, cleanup, or positive-task
  proof blocks exit.
- A new generic adapter or broker/control plane is prohibited.
