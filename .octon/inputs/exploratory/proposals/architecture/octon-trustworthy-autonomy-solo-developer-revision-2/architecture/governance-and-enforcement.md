# Governance, Effect Boundary, and Enforcement Topology

## Decision Summary

Octon should authorize a focused candidate-development envelope once, let the
agent iterate freely inside that disposable envelope, and mediate only the
transitions that create canonical, external, credentialed, irreversible, or
trust-root consequences.

The governing split is:

~~~text
Class A: disposable candidate effects
  -> sandbox-enforced and autonomous after launch

Class B: durable but ordinarily reversible effects
  -> typed capability plus broker, normally automatic

Class C: irreversible, externally consequential, or trust-root effects
  -> typed capability plus independent verification and explicit activation
~~~

This replaces both extremes that Revision 1 risked implying:

- repository-wide ambient autonomy is too broad; and
- a privileged broker call for every file write is too slow and operationally
  unnecessary.

The safe path must be the default path. The agent process receives neither the
credentials nor the host access needed to bypass it, while the operator uses one
ordinary command and receives generated receipts and concise notifications.

## Proportional Effect Classes

### Class A — Reversible Candidate Work

Class A is autonomous by default after the authority engine has authorized,
the capability ledger has registered/reserved/spent the run's typed
`ExecutorLaunch`, the evidence-store/ledger attempt gate has succeeded, and
the launch broker has consumed the resulting invocation guard.
There is no per-file, per-command, or per-commit approval.

Representative actions:

- repository reads and analysis;
- file creation, modification, rename, and deletion inside the candidate
  workspace;
- local builds, tests, linters, typecheckers, formatters, and code generation;
- local commits and local refs inside the candidate workspace's separate Git
  database;
- patch, diff, report, and candidate-evidence generation;
- child processes that inherit the exact same or a strictly narrower sandbox;
- replay, fault injection, and rollback rehearsal inside disposable state.

Required controls:

- a disposable candidate checkout with a separate Git database;
- no writable path to the canonical checkout, canonical Git refs, installed
  Octon runtime, broker, signer, verifier, or host policy;
- no remote configured for the model-visible Git client;
- no consequential credentials, credential sockets, cloud metadata access, or
  provider tokens;
- network denied by default;
- bounded project roots and temporary/cache roots;
- process-tree containment and inherited restrictions;
- low-overhead trusted start, checkpoint, and stop records plus batched tree and
  commit digests.

A local commit is Class A only when it changes the disposable candidate Git
database. Creating or updating a canonical or remote ref is Class B.

### Class B — Durable but Ordinarily Reversible Effects

Class B crosses the broker boundary. It should be automatically authorized when
the canonical policy permits it and should normally produce an asynchronous
operator notification, not a blocking prompt.

Representative actions:

- fetching and pinning a governed source snapshot;
- promoting an exact candidate commit or tree to a governed local branch;
- pushing a governed branch;
- opening or updating a pull request;
- writing canonical Workspace Project, Project Profile, control, or retained
  evidence state;
- publishing ordinary retained evidence;
- merging a low-risk, fully validated exact-SHA change;
- deleting a source branch already proven contained in the target;
- performing a reversible authenticated API update.

Required controls:

- a typed effect capability bound to repository identity, exact source object,
  target, GrantBundle identity and digest, Effective Harness digest, policy and
  runtime versions, expiry, revocation epoch, and rollback handle;
- credentials held by the broker rather than the proposing process;
- broker-side precondition and postcondition checks;
- idempotency key or explicit non-retry posture;
- reconciliation against actual external state;
- automatic rollback or a concrete reversion handle;
- concise operator notification with effect, target, source SHA, result, and
  rollback.

### Class C — Irreversible, Externally Consequential, or Trust-Root Effects

Class C candidate implementation and testing remain Class A. Inactive staging
may be Class B. Activation is Class C.

Representative actions:

- production deployment;
- destructive infrastructure mutation;
- sensitive secret use;
- irreversible or public package/publication release;
- authority-engine, broker, signer, verifier, CI-gate, policy-root,
  support-claim, installer, release, or update-root activation.

Required controls:

- explicit operator activation or a deliberately configured high-assurance
  policy;
- independent verification by a different software identity and pinned
  verifier version;
- two-phase implementation/staging and activation;
- no same-change control of the only verifier or activation gate;
- exact artifact and environment binding;
- strong compensation, rollback, or incident-response plan;
- automatic retention of the previously trusted version.

For the default solo profile, software identities, keys, a previously trusted
verifier, and staged activation provide two-authority separation. A second human
is profile-dependent, not the ordinary default.

## Candidate Versus Durable Boundary

The boundary is not "write versus no write." It is "disposable state versus
canonical, external, credentialed, or trust-affecting state."

| Surface or action | Inside autonomous candidate envelope | Broker or approval boundary |
|---|---|---|
| Canonical source filesystem | Read-only snapshot or absent | Any write to canonical checkout is Class B |
| Disposable source filesystem | Read/write/delete freely within project scope | Promotion of its exact tree or commit is Class B |
| Canonical Git object/ref database | Not writable by model process | Broker creates or updates canonical refs |
| Candidate Git database | Status, diff, add, commit, reset of candidate refs, and local tags are Class A | Importing an exact object into canonical Git is Class B |
| Ordinary Git worktree | Permitted only if shared common-dir metadata is not writable | Otherwise replace with a disposable clone or separate-gitdir checkout |
| Git fetch | No direct remote in sandbox | Broker fetches, records repository identity and exact fetched refs, and constructs the source snapshot |
| Branch push | Never direct | Class B broker effect |
| Pull-request creation/update | Never direct | Class B broker effect |
| Merge or target-branch update | Never direct | Class B when low risk and fully validated; Class C when policy/trust impact requires it |
| Local builds/tests/linters | Class A when sandboxed, credentialless, and offline or fixture-bound | Host service, privileged device, secret, or network use requires a typed broker route |
| Generated artifacts | Candidate generation is Class A | Canonical publication is Class B; runtime/trust activation is Class C |
| Canonical Octon control roots | Agent may prepare proposed records only | Typed broker/store APIs perform authorized canonical writes; the authority issuer signs capability requests and the ledger registers/exposes references, but neither has control-root effect authority |
| Canonical Octon evidence roots | Candidate logs are untrusted source material | Broker/observer submits origin-authenticated fact envelopes; the evidence store owns canonical sequencing/receipts and preserves producer envelopes; the signer independently re-verifies producer signatures/nonces/digests end to end before signing normalized committed records |
| Public external reads | Use a pinned cache or brokered read-only proxy | Direct egress is denied; authenticated or externally observable reads are automatically brokered |
| External API mutation | Never direct | Class B if reversible; Class C if irreversible or high consequence |
| Dependency download | Pinned cache may be mounted read-only | Network retrieval is brokered and digest-checked |
| Host/system package installation | Not allowed | Brokered host administration; normally outside an ordinary run |
| Deployment | Build, test, simulate, and rehearse locally | Activation is Class C |
| Package publication | Build and verify package locally | Public release is Class C by default; a proven reversible internal prerelease may be Class B |
| Secrets | No secret values, agents, or sockets in sandbox | Broker uses an opaque handle and performs the effect itself |
| Policy/trust-root files | Candidate edit and adversarial validation are Class A | Canonical merge is at least Class B; activation is Class C |
| Workspace Project/Profile repair | Candidate regenerated revision is Class A | Factual or narrowing promotion is Class B; boundary or trust widening is Class C |
| Evidence compaction | Candidate summary is non-authoritative | Trusted compaction and anchor update are Class B |

### Candidate Workspace Requirement

A normal Git worktree shares the repository's common Git directory and therefore
does not, by itself, isolate refs or object-database mutation. The default
candidate substrate should be a cheap local disposable clone, copy-on-write
checkout, or equivalent separate Git directory with:

- an exact broker-pinned base SHA;
- no writable remote configuration;
- optional read-only object alternates for performance;
- new objects and refs stored only in the run-owned Git directory;
- canonical repository and Octon installation outside the sandbox write set.

A worktree adapter may be admitted only after it proves that the model cannot
write shared Git metadata while still supporting local candidate commits.

### Trusted Versus Candidate Evidence

Candidate stdout, logs, reports, and summaries are evidence inputs, not trusted
attestations. The launcher and broker attest to:

- the sandbox and harness they installed;
- the process they launched;
- capabilities they verified and consumed;
- effects they performed;
- observed external postconditions;
- the final candidate tree/commit they preserved.

This avoids asking the model to author the receipt that vouches for its own
effect.

## Enforcement Topology Comparison

Ratings are architectural suitability, not current implementation claims:
High means the option can provide the property when correctly implemented;
Partial means it needs another boundary; None means it does not address the
property.

### Security and Mediation Properties

| Option | Complete mediation | Resistance to agent/repo modification or bypass | Filesystem isolation | Process/shell isolation | Network control | Credential isolation | Git/GitHub mediation |
|---|---|---|---|---|---|---|---|
| 1. In-process wrappers | Low | Low: same process/repository can bypass wrapper paths | None | None | Partial at API layer only | Low if ambient environment remains | Partial only for wrapped calls |
| 2. Local broker process | High for routed effects; incomplete alone | Medium: strong only when sandbox removes alternate paths | None alone | None alone | Partial alone | High when credentials exist only in broker | High for broker-routed Git/provider effects |
| 3. Privileged sidecar | High for routed host effects; incomplete alone | High when installed outside repo and OS-protected | None alone | None alone | Partial at its admitted interface | High | High for routed Git/provider effects |
| 4. Container or VM boundary | High inside guest; host effects still need broker | High against repository/model, subject to host configuration | High | High | High | High when no host secrets are mounted | High only with external broker |
| 5. OS sandbox plus broker | High practical coverage | High when all agent processes begin inside sandbox | High through host adapter | High through host adapter | High through host adapter | High | High |
| 6. Remote effect broker | High for remote effects; none for local host effects | High for remote service, low for local bypass without sandbox | None | None | Only broker endpoint policy | High | High for supported remote providers |
| 7. GitHub App | High for admitted GitHub operations only | High provider-side isolation | None | None | GitHub only | High, installation-scoped provider identity | High for GitHub; none for local Git |
| 8. Hybrid local and remote enforcement | High end-to-end | High when raw credentials and alternate egress are absent | High | High | High | High | High |

### Operational Properties

| Option | Offline operation | Portability across macOS/Linux/Windows | Installation burden | Runtime latency | Debugging and recovery burden | Solo-developer suitability |
|---|---|---|---|---|---|---|
| 1. In-process wrappers | Excellent | High | Low | Near zero | Low, but bypass failures are difficult to trust | Migration, telemetry, and ergonomics only |
| 2. Local broker process | Candidate and local effects continue | Broker core high; IPC/credential adapters vary | Medium | Approximately 1–20 ms local overhead target | Medium | Necessary component, not sufficient alone |
| 3. Privileged sidecar | Good | Low to medium; host-specific | High | Approximately 1–20 ms call overhead plus startup | High; privileged recovery path required | Higher-assurance profile |
| 4. Container or VM boundary | Good for cached candidate work | Medium; runtime availability differs by host | Medium after one-time runtime installation; dedicated VM is high | Approximately 0.2–5 s startup depending profile | Medium for rootless OCI; high for dedicated VM | Recommended rootless sandbox substrate when paired with broker; dedicated VM is higher assurance |
| 5. OS sandbox plus broker | Excellent for Class A | Medium; independent adapter per host | Medium | Tens to hundreds of ms launch plus low broker overhead | Medium | Optional host-native fast profile after conformance |
| 6. Remote effect broker | Class A continues; consequential transitions pause | High client portability | Medium plus service operation | Network latency, approximately 50–500 ms or more | Medium to high | Complement, not sole boundary |
| 7. GitHub App | No GitHub effects offline; candidate continues | High | Medium one-time installation | Provider latency, commonly hundreds of ms or more | Medium | Recommended GitHub boundary |
| 8. Hybrid local and remote enforcement | Class A remains offline-capable | Medium until all host profiles are proven | Medium-high | Minimal candidate overhead; network only at durable transitions | Medium with explicit reconciliation tooling | Recommended overall |

## Recommended Profiles

### Practical Solo-Developer Default

Use this concrete hybrid:

1. Broker fetches and pins the repository/source SHA.
2. Workspace manager creates a credentialless disposable candidate clone.
3. A rootless OCI sandbox launches the model and all descendants. Linux uses
   native namespaces; macOS and Windows use a VM-backed container runtime.
4. A local broker, installed outside and non-writable by the repository,
   mediates canonical filesystem, Git, evidence, and credentialed effects.
5. Network is denied in the agent process; the broker exposes only admitted
   typed operations.
6. An independent verifier GitHub App publishes provenance checks, and a
   separate effect App performs provider mutations where available.
7. Trusted broker/observer evidence is externally anchorable.

The default broker may be unprivileged if the admitted OCI/host boundary
prevents access to its credentials, executable, socket impersonation path, and
canonical roots. Privilege is added only where a host adapter requires it. A
native sandbox is an optional faster profile only after it passes the same
conformance contract.

### Higher-Assurance Profile

Use:

- a disposable container, lightweight VM, or equivalent hardened guest;
- read-only source input and a run-owned writable volume;
- a privileged host sidecar or remote broker;
- separate verifier and effect GitHub App identities;
- independently installed signer and verifier;
- no host SSH agent, cloud socket, container-admin socket, keychain, or
  unrestricted network exposed to the guest;
- staged activation and automatic rollback to the previously trusted version.

### Host-Specific Variants

- **macOS default:** VM-backed rootless OCI plus the macOS local broker. A
  native sandbox adapter may be admitted later; a CLI flag alone is not
  conformance.
- **Linux default:** rootless OCI with user/mount/network namespaces plus the
  host local broker. A lighter native adapter is optional after the full
  filesystem, process, signal, credential, and egress suite passes.
- **Windows default:** WSL2/Hyper-V-backed rootless OCI plus the Windows local
  broker. A restricted-token/ACL/job-object adapter is optional after IPC,
  credential, filesystem, process, and network isolation proof.

Support admission must bind the operating system, enforcement adapter version,
and conformance evidence. Compiling the runtime on a host is not sufficient.

## Hooks and In-Process Controls

Hooks and wrappers remain useful for:

- early operator diagnostics;
- migration warnings;
- route and scope telemetry;
- accidental misuse prevention;
- defense in depth.

They must not be the sole trust boundary because the repository or agent can
modify, omit, or bypass them when a general shell and ambient credentials remain
available.

## Narrow Failure and Degraded Operation

Failure must block only the unavailable consequential transition:

- local broker down: preserve candidate and block canonical promotion;
- signer/anchor down: Class A continues and every new ordinary B/C business
  start blocks. Pre-registered strictly narrowing obligations—bound check
  failure, exact rollback to a capability-bound prior production/deployment or
  trust slot, strictly exposure-reducing bounded compensation, and
  stop/revoke—may execute through healthy ledger/evidence attempt-link gates
  and queue origin-authenticated pending facts. An effect already past consume
  retains pending facts but cannot claim completion;
- GitHub/network down: continue Class A and queue a digest-bound Class B
  request; revalidate before sending;
- verifier down: preserve staged result; do not merge or activate;
- revocation: deny new broker calls immediately, terminate affected executor,
  and preserve candidate state;
- unknown external outcome: query provider state using idempotency key, exact
  target, and expected postcondition before retrying.

Every denial should return:

- reason code and governing policy;
- exact missing or stale evidence;
- effect that was blocked;
- unaffected work that may continue;
- shortest safe recovery route.

## Safe-Path Convenience Requirements

The safe path is acceptable only when it is at least as convenient as bypass:

- one ordinary command selects the project, compiles the harness, creates the
  candidate workspace, and launches the run;
- no user-authored grant, receipt, or evidence document for ordinary work;
- local edits, builds, tests, and commits require no broker round trip;
- promotion accepts the exact candidate commit directly rather than manual patch
  copying;
- policy-eligible Class B effects happen automatically;
- notifications are batched and concise;
- raw Git/provider/deployment commands fail because credentials and routes are
  absent, not because the operator must remember a convention;
- outages preserve completed candidate work and provide a one-command retry
  after revalidation.

## Acceptance Conditions

This design decision is acceptable when tests prove:

- the agent cannot mutate canonical files, Git refs, control roots, broker,
  signer, verifier, or host policy;
- the agent cannot access consequential credentials or unrestricted network;
- local builds, tests, and commits remain autonomous;
- a broker can promote an exact candidate SHA without reconstructing work;
- direct push and provider API attempts fail while the equivalent broker request
  succeeds;
- revocation prevents later effects and terminates the affected executor;
- broker/provider outage blocks only the associated transition;
- hooks can be removed without weakening the trusted boundary.
