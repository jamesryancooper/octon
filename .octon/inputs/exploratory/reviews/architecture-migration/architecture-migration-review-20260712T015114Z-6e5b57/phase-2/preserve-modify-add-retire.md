# Preserve, Modify, Add, Retire

## Preserve as working primitives

- AuthorizedEffect and VerifiedEffect type separation and restricted minting.
- authority_engine decision, grant, expiry, revocation, route, support,
  approval, rollback, budget, egress, and lifecycle checks.
- Run-journal transition validation and hash-link calculation.
- Replay requirement for fresh authority.
- Exact source, target-pre, ancestry, required-check, post-land, cleanup, and
  rollback vocabulary from current no-PR tooling.
- Active main ruleset deletion, non-fast-forward, linear-history, strict
  checks, and no-current-user-bypass posture.
- Context-pack hashing, omissions, redactions, freshness, and receipts.
- Extension additive/control/generated separation, publication receipts,
  generations, and quarantine.
- Promotion non-authority language and current inert promote-apply behavior.

## Modify

- Lifecycle authorization becomes admission/validation only.
- Every process-launch abstraction takes and consumes a typed exact guard.
- authority scope matching becomes canonical and one-directional.
- Runtime bus becomes a projection/validator behind the transactional writer.
- Route selector chooses isolated Class B no-PR, then PR on predicates; never
  autonomous direct-main.
- Required-check consumption accepts one authenticated verifier verdict, not
  an arbitrary successful context name.
- Evidence aggregation references direct-observer signed results and cannot
  manufacture pass, approval, review, or executed-test claims.
- Project Profile remains descriptive and is referenced by Workspace Project.
- Existing task-harness/context/extension inputs feed one deterministic
  compiler, not another runtime.

## Add

- One local SQLite/WAL authoritative schema and single writer.
- One separate deterministic broker with OS-keychain custody and a narrow IPC.
- A structural one-shot launch gate and isolated candidate launcher.
- Disposable independent Git store for candidates.
- Sanitized broker-owned Git adapter and exact target compare-and-swap.
- Candidate-immutable exact-SHA verifier and direct-observer signing keys.
- Evidence-capacity reservation, signed checkpoints, quotas, compaction,
  pins, and low-space admission.
- Operation reservation, attempt, unknown, reconcile, terminal, rollback, and
  revocation-generation state machine.
- Trust-root inventory, inert version store, previous-version verifier,
  staged health gate, active pointer, and automatic rollback.
- Minimal Workspace Project, digest-bound harness manifest, signed private
  extension catalog, setup, doctor, repair, and mission inbox.

## Retire

- Lifecycle-local DelegationProof as execution authority.
- Autonomous direct-main and candidate-side Git/GitHub provider writes.
- Current candidate-controlled privileged pr-auto-merge execution.
- File token/journal/control writers as canonical sources after atomic cutover.
- Self-minted branch-landing authorization.
- Ambient privileged Git and user/global/repository executable extensions.
- Proof validators that equate references with execution.
- Synthesized evaluator approval and proof-plane pass records.
- Unsigned live extension import and unbounded raw evidence retention.
- Singleton Project Profile as project identity.

## Demote or hide

- Federation, trust-domain administration, delegated leases, certification,
  stewardship, and broad connector surfaces become advanced/operator-only or
  deferred; they are not part of the solo golden path.
- Legacy lifecycle authority fields remain read-only observability during the
  bridge and are then removed.
- Legacy files remain read-only projections/export compatibility after store
  cutover and are never dual authoritative writers.

## Explicit exclusions

No VM, distributed consensus, multi-writer database, standalone evidence
capacity service, second broker, public marketplace, enterprise IAM, native
Windows target, universal PR ceremony, persistent agent organization, or
autonomous direct-main path is introduced.

