# Validation Plan

## Evidence Posture

All dynamic proof described here is planned and must run only after the exact
implementation is separately authorized. Future receipts must bind exact commit,
macOS build, hardware architecture, sandbox profile digest, provider/client
path/digest/version, workspace and Git identities, rendered SBPL and
`sandbox-exec` digests, relay listener and redacted session class, commands, times, exit
codes, retained logs or digests, and evidence classifications. Secret values
must never be retained.

## Structural Proposal Validation

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-candidate-isolation`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-candidate-isolation`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-candidate-isolation`
- architecture review and strict review-gate validators after real review
- structural checks that the primary spawn uses
  `CandidateIsolationRunner::apply_native_policy_and_spawn`, the exact client
  is absolute/digest-bound, the profile is default-deny, and the relay schema
  exposes inference operations only

## Positive Proof

- representative primary-provider task with a bounded, objectively checkable
  result through the exact one-run relay, never direct provider egress;
- independent repository/common-directory/object identity assertion;
- exact candidate commit and non-executing export verification;
- cancellation and normal cleanup with no surviving process/session/workspace
  reuse.

## Credential and Host Canary Matrix

| Probe | Required result |
| --- | --- |
| sentinel environment variables and durable provider tokens | absent or unreadable; the one-run relay bearer is explicitly non-durable and expires at terminal state |
| macOS Keychain items and security APIs | access denied |
| SSH agent and Git credential helper sockets | unavailable |
| parent file descriptors and privileged Unix sockets | closed or denied |
| canonical `.git`, refs, objects, config, index, worktrees, hooks, attributes | read and mutation denied |
| sibling projects, operator HOME, shell history, tool configuration | denied unless an exact non-secret input is declared |
| process listing, signals, ptrace/debug, sibling process handles | denied outside owned process group |
| direct provider endpoint, arbitrary network, non-relay loopback services, metadata endpoints | denied; only the exact one-run relay listener is reachable |
| relay effect/provider-administration operations | nonexistent or denied; inference protocol only |

## Filesystem and Git Adversarial Matrix

- `..`, symlink, hardlink, case-folding, Unicode, mount, temporary-directory,
  and file-replacement escapes;
- linked-worktree and alternates/object-store injection;
- malicious Git config, include, hook, attribute, filter, helper, driver,
  fsmonitor, submodule, and transport entries;
- canonical ref/object/config mutation attempts;
- export of missing, wrong, or replaced commit identity.

No trusted process executes or checks out candidate-controlled Git behavior
during this RP-02 export proof.

## Fault and Lifecycle Matrix

- kill before repository creation, after materialization, before/after session
  attachment, during task, during commit, during export, and during cleanup;
- provider expiry, denial, timeout, rate limit, and lost response;
- wrong/expired/reused relay bearer, second concurrent client, wrong run/model/
  budget, relay crash, direct provider attempt, and alternate loopback port;
- disk full and permission loss in disposable roots;
- cancellation with child and grandchild processes;
- cleanup failure and attempted identity/workspace reuse.

## Required Evidence

Future evidence under
`.octon/state/evidence/validation/proposals/octon-architecture-migration-candidate-isolation/`
includes ED-001 and profile/session manifests without secrets, client,
`sandbox-exec`, and rendered-profile digests, repository
identity, positive task result, every negative matrix result, process/FD
coverage, export and cleanup receipts, rollback drill, UE-003 disposition,
conformance, and drift/churn review. UE-003 is not required for proposal
acceptance or authorization to create the implementation, but is mandatory
before conformance, implementation completion, cutover, or promotion.
