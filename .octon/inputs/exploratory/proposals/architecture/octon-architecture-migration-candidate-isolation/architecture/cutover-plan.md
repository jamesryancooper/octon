# Cutover Plan

## Preconditions

- `octon-architecture-migration-containment` exits and its containment evidence
  is fresh for the exact integration baseline.
- ED-001 is applied to pinned macOS, hardware architecture, provider client,
  native sandbox, and non-exportable or short-lived provider-session forms.
- Independent review proves the selected session is useful without making
  durable credential material candidate-readable.
- RP-01 freezes the authority/guard decision and immediate-launch interface;
  exact shared-file symbols are allocated to RP-02.
- Proposal acceptance, implementation-grade completeness, and pre-integration
  architecture review pass.
- Sentinel credentials, disposable provider targets, an independent repository
  fixture, a route-neutral exact-candidate preservation/export fixture, and
  cleanup/rollback handles are prepared.

## Atomic Isolation Sequence

1. Pin the source commit, provider/client tuple, macOS build, sandbox-profile
   digest, and independent repository materialization recipe.
2. Create the candidate-only root, fresh HOME, and independent repository and
   object database; verify no canonical common directory, object alternate,
   config, hook, index, ref, or worktree link exists.
3. Construct the explicit environment, FD, executable, filesystem, process,
   IPC, and network allowlists and apply the native sandbox before provider
   client execution.
4. Attach the provider-native session without copying or exposing a durable
   credential to the candidate.
5. Run the deterministic useful task and all credential, host, Git, network,
   process, FD, and filesystem canaries.
6. Create and identify the exact candidate commit, then export it through a
   non-executing object boundary without canonical mutation.
7. Retire the provider session, process group, HOME, workspace, repository, and
   temporary identity; prove no reuse and no surviving descendant.
8. Publish UE-003, PO-FD-008/PG-02-MACOS-ISOLATION, the candidate-side
   PO-FD-006 evidence, rollback drill, conformance, and drift receipts.

The new route stays disabled until steps 1 through 7 pass together. Cutover is
atomic: Octon never treats ambient execution and isolated execution as two
supported autonomous routes for the same primary-provider task.

## Admission Ramp

After the full disposable fixture passes, run one bounded non-production
canary task. Admission remains limited to the exact proved tuple. A new macOS
build, provider client, provider-session class, sandbox profile, executable,
network destination, or repository materialization mechanism invalidates the
tuple and returns the route to disabled pending fresh proof.

## Safe Resting State

At SI-02, useful primary-provider work may run only through the admitted
credentialless native candidate route. Candidate commits may be exported for
preservation and later RP-06 route evaluation; export itself selects no
publication route. Protected PR is available only when RP-06 later evaluates a
fresh valid review-required predicate, never as isolation-failure recovery.
Candidate access to canonical Git, broker credentials, privileged IPC, or
provider effects remains prohibited. RP-02 can safely pause there without
waiting for RP-04.

## Handoff

- RP-01 receives the isolation binding and launch observation at its frozen
  guard interface, not ownership of isolation mechanics.
- RP-04 receives candidate-side PO-FD-006 and UE-003 references; it still owns
  credential custody, authenticated privileged IPC, and broker-side proof.
- RP-05/RP-06 receive only the exact non-executing candidate commit and export
  envelope, never the candidate session or workspace.
- RP-11 receives a proved primary-provider binding as input to its generic
  adapter work; it does not retroactively widen RP-02 support.

Handoffs cite retained evidence by digest. They do not transfer authority,
credentials, candidate host state, or source ownership.
