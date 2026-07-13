# Target Architecture

## Target State: SI-02 Useful Credentialless Isolated Candidate

```text
RP-00 contained baseline
  -> trusted launcher receives a bounded candidate request
  -> new independent disposable repository/object database is created
  -> exact source baseline and allowed inputs are materialized without sharing
     canonical Git state
  -> fresh HOME and environment allowlist are constructed
  -> inherited FDs are closed and process-group ownership is established
  -> native macOS sandbox restricts filesystem, process, and network access
  -> provider-native non-exportable or short-lived primary-provider session is
     attached without readable durable secret material
  -> useful task runs
  -> exact candidate commit is exported through a non-executing,
     content-addressed boundary
  -> terminal evidence is retained and disposable workspace/session is retired
```

RP-02 may implement beside RP-01 after RP-00. Its isolated fixture does not
perform a privileged effect. Production integration consumes RP-01's frozen
guard-owning launch interface without redefining it.

## Boundary Ownership

- **RP-01:** authority evaluator, typed scope, exact one-shot guard, and the
  structural API that immediately precedes process creation.
- **RP-02:** workspace creation, independent Git state, environment/HOME/FD
  scrubbing, native sandbox, candidate-safe provider session, process boundary,
  non-executing export, cleanup, and isolation evidence.
- **RP-04:** credential enrollment/custody and privileged effect IPC. RP-02 is
  deliberately independent of the broker to avoid a dependency cycle.
- **RP-11:** generic executor adapter interface and conformance. RP-02 supplies
  an isolation implementation behind that interface but does not change
  provider replacement semantics.

## Invariants

1. The candidate repository has a different Git common directory, refs,
   object database, configuration, index, hooks, and worktree from canonical
   Git.
2. A linked worktree of the canonical repository is never sufficient.
3. Candidate processes cannot read durable provider, Git, SSH, Keychain, or
   environment credentials.
4. Only explicitly allowed environment variables, file descriptors,
   filesystem roots, network destinations, and child processes are available.
5. Provider authentication is useful but non-exportable or short-lived and
   independent of the future privileged effect broker.
6. Candidate output cannot mutate canonical Git or host state; export is exact,
   content-addressed, and non-executing.
7. The candidate never mints authority, chooses support, holds effect
   credentials, or invokes privileged broker IPC.
8. Failure preserves the exact candidate commit when available and otherwise
   reports an honest terminal state without unsafe retry or fallback.

## Unavailability Behavior

- If native sandbox enforcement is unavailable, automated candidate launch is
  disabled.
- If a candidate-safe provider session is unavailable, the task does not fall
  back to durable tokens in the candidate environment.
- If export fails, the workspace is retained in a non-authoritative recovery
  posture until the exact commit is recovered or explicitly abandoned.
- If cleanup fails, the workspace/session is quarantined and cannot be reused.

## Prohibited States

- canonical checkout or linked-worktree-only candidate execution;
- ambient HOME, environment, Keychain, SSH agent, parent FD, or Git config
  inheritance;
- unrestricted filesystem, process, or network access;
- candidate-readable durable API key or provider token;
- candidate canonical-ref mutation or trusted-side checkout of candidate
  content during export;
- real production credential/effect target in tests;
- VM infrastructure, Linux production support, privileged broker effects, or
  a second runtime/control plane.

## Unsupported Remainder

RP-02 does not establish credential custody, transactional state, brokered
effects, sanitized Git publication, immutable verifier identity, Class B
recovery, trust activation, generic multi-provider conformance, or a live
secondary-provider claim. Linux remains experimental and native Windows and VM
infrastructure remain outside the target.

