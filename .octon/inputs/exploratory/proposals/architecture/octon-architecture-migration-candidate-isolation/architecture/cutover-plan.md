# Cutover Plan

## Preconditions

- `octon-architecture-migration-containment` exits and its containment evidence
  is fresh for the exact integration baseline.
- ED-001's design is selected as arm64 macOS 26/Darwin 25, root-owned exact-
  digest `/usr/bin/sandbox-exec`, digest-bound default-deny SBPL, an absolute
  exact-digest/version OpenAI Codex CLI, and
  `loopback-capability-relay-v1`.
- Before candidate execution, RP-00 verification passes and the exact host,
  working client, authenticated upstream transport, relay, and fixtures pass
  preflight. Useful-positive and credential-negative proof is deliberately
  post-implementation and does not circularly block design authorization.
- RP-01 freezes the authority/guard decision and immediate-launch interface;
  exact shared-file symbols are allocated to RP-02.
- Proposal acceptance, implementation-grade completeness, and pre-integration
  architecture review pass.
- Sentinel credentials, disposable provider targets, an independent repository
  fixture, a route-neutral exact-candidate preservation/export fixture, and
  cleanup/rollback handles are prepared.

## Atomic Isolation Sequence

1. Pin the source commit, absolute client path/digest/version, macOS build and
   kernel identity, `/usr/bin/sandbox-exec` owner/digest, rendered SBPL digest,
   relay listener, and independent repository materialization recipe.
2. Create the candidate-only root, fresh HOME, and independent repository and
   object database; verify no canonical common directory, object alternate,
   config, hook, index, ref, or worktree link exists.
3. Construct the explicit environment, FD, executable, filesystem, process,
   IPC, and network allowlists and apply the native sandbox before provider
   client execution.
4. Start the inference-only relay outside the sandbox/process group from a
   pre-existing authenticated upstream transport, mint one run/model/budget/
   listener/deadline-bound 256-bit bearer, and expose only that non-durable
   bearer to the candidate client.
5. Run the deterministic useful task and all credential, host, Git, network,
   process, FD, and filesystem canaries.
6. Create and identify the exact candidate commit, then export it through a
   non-executing object boundary without canonical mutation.
7. Atomically revoke the relay bearer and stop the relay at every terminal
   path, then retire the process group, HOME, workspace, repository, and
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
relay protocol/listener policy, or repository materialization mechanism invalidates the
tuple and returns the route to disabled pending fresh proof.

## Safe Resting State

At SI-02, useful primary-provider work may run only through the admitted
credentialless native candidate route. Candidate commits may be exported for
preservation and later RP-06 route evaluation; export itself selects no
publication route. Protected PR is available only when RP-06 later evaluates a
fresh valid review-required predicate, never as isolation-failure recovery.
Candidate direct provider egress and access to canonical Git, broker
credentials, privileged IPC, or provider effects remains prohibited. RP-02 can safely pause there without
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
