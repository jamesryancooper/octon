# Phase 3 — Independent Assurance Review

## Assurance conclusion

The Phase 2 target is the smallest credible architecture, but implementation
must not begin with privileged automation. The current provider lane must
first be disabled, support claims narrowed, physical writer/launch inventories
completed, exact authority scopes fixed, and the bridge made PR-only/manual.

The target itself survives simplification challenge because each new
load-bearing component removes an observed class of failure:

- one transactional store removes file consume/append races;
- one broker removes credentials from candidates and centralizes effects;
- one structural launch guard removes lifecycle-local authority;
- one sanitized Git adapter removes repository-controlled execution under
  privilege;
- one independent verifier removes same-change self-certification;
- signed checkpoints and capacity reservation make evidence authentic,
  bounded, and recoverable;
- Workspace Project and Harness Factory reduce repeated project setup without
  creating authority or another runtime.

No second broker, evidence service, VM, distributed ledger, universal PR
route, or enterprise control plane is justified.

## Challenges and outcomes

### Hidden authority and alternate effects

Challenge succeeded. Lifecycle request metadata authorizes launch without
canonical ExecutorLaunch. Direct Git scripts and provider workflows perform
material effects outside a broker. authority scope comparison can match in
both prefix directions.

### Ambient credentials and candidate isolation

Challenge succeeded statically and deployment-locally. Launchers do not clear
the environment, use the canonical checkout, and rely on user HOME. Worktrees
share the common Git directory. No escape or credential-read experiment was
run, so actual access remains unverified.

### Candidate-controlled privileged execution

Challenge succeeded. pull_request_target obtains write permission, later
checks out PR head, and executes candidate scripts/kernel while the token is
available. The active provider variable enables the lane. This is
BLOCKER_BEFORE_PRIVILEGED_IMPLEMENTATION.

### Exact-SHA verification

Challenge succeeded. Required check contexts are produced from
candidate-controlled workflows/scripts, and context-name success does not
authenticate one immutable verifier identity. Current exact-ref logic should
be reused only behind a new verifier boundary.

### Replay, concurrency, crash ordering, and unknown outcomes

Challenge succeeded by code inspection. Token consumption and journal append
span multiple unlocked writes; sequence and consumed state can race; event,
receipt, record, and manifest can diverge after crash. Existing tests passed
sequential behavior but did not cover these faults.

### Evidence forgery and stale claims

Challenge succeeded. Hash chains lack signer/monotonic checkpoint protection,
some closeout code synthesizes pass/approval records, and the proof
executability validator reports a referenced test as executed without invoking
it. The latter was dynamically reproduced. Current claims must be downgraded,
not discarded: chain validation, receipts, and disclosed limitations remain
useful structural evidence.

### Trust activation and rollback

Challenge succeeded. Promotion is currently inert, a safety strength, but
there is no installed exact-version controller or executable automatic
rollback. Current rollback artifacts are posture records, not a state machine.

### Second control plane

Challenge succeeded. GitHub workflow-local eligibility and effect execution
currently operate as a second effect plane. The target prevents recurrence by
making any remote worker a dumb exact-operation performer reconciled through
the local authoritative store.

## Actual dynamic and adversarial coverage

Executed at the reviewed commit:

- authority_engine: 75/75 tests passed;
- lifecycle_executor: 15/15 tests passed;
- runtime_bus: 17/17 tests passed;
- hosted no-PR test: 29/29 cases passed;
- authorized-effect bypass negative controls passed;
- material side-effect token bypass denials passed;
- authorization coverage validator passed;
- proof executability validator passed while emitting the misleading
  runtime_tests_executed field without executing that referenced test.

ADVERSARIALLY_TESTED is claimed only for the repository negative-control
scripts actually run. Sandbox escape, malicious PR, hostile Git extensions,
concurrent token consume, crash injection, provider target race, duplicate
check contexts, evidence rechain, and trust activation were not executed.

## Self-challenge against overstatement

- The authority engine is not rejected: its typed and validation logic is a
  major retained asset.
- Codex workspace-write is useful containment, but not proof of the accepted
  credentialless/native-isolation boundary.
- The active ruleset is a real provider safeguard; its required verifier
  implementation is still candidate-controlled.
- The no-PR suite genuinely validates many receipt and route invariants; it
  does not prove trusted effect execution.
- Hash chaining genuinely detects tested corruption; signatures address a
  different authenticity/rollback threat.
- The GitHub dossier discloses missing naturalistic evidence; the defect is
  promotion strength and validator semantics, not concealment.
- The current inert promotion command is safer than a broken activator. Trust
  automation is deferred until its dependencies are proven.
- Deployment-local evidence volume demonstrates burden on this checkout, not
  a universal installation size.

## Done gate

The review evidence bundle is complete when all required artifacts validate,
all 24 decisions are present, all 14 workgroups have entry/exit/rollback/proof,
all subagents are recorded, write scope is clean, and integrity checks pass.
The implementation done gate remains intentionally unmet.

