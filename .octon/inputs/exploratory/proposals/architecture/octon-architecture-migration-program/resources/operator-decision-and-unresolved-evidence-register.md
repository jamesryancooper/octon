# Operator Decisions and Unresolved Evidence

## Disposition model

The intake records final operator intent but remains non-authoritative pending
formal promotion. The reviews and reconciliation may sharpen implementation,
packet boundaries, engineering defaults, and proof, but they do not reopen an
accepted intake decision without new evidence of impossibility, contradiction,
material safety failure, or a materially simpler invariant-preserving design.

The operator accepted the five previously bounded recommendations on
2026-07-13. The proposal-local acceptance receipt is
`support/operator-decision-acceptance-receipt.md`. It records intent for this
program and changes no runtime, support, trust, provider, or promotion authority.

| Class | Meaning in this program |
| --- | --- |
| Operator-accepted architecture or policy | Target direction or human risk/trust/cost posture is settled; packets consume, encode, configure, and prove it rather than request another vote. |
| Configuration parameter | A concrete instance value implementing an accepted posture; use conservative reversible defaults and measurement-adjustment where exact values are not justified. |
| Engineering disposition | Mechanism, provider conformance, or provisional value selected through design, feasibility, measurement, and proof. |
| Promotion acceptance | Later evidence-based acceptance of an implemented claim; never a present architecture decision. |

## ROD disposition summary

| Lineage | Accepted disposition | Implementation owner | Fail-closed behavior |
| --- | --- | --- | --- |
| ROD-001 | `OPERATOR_ACCEPTED_ADAPTIVE_POLICY` — conservative bounded recovery/evidence posture with reversible measurement-adjusted values; one store, signed bounded evidence, transactional terminal capacity, and narrow degraded operation remain settled. | RP-03 binds backup/recovery engineering defaults; RP-07 binds retention, quota, pinning, and key-recovery mechanisms. | Deny affected effects if terminal evidence cannot be guaranteed; preserve work; no unsigned fallback. |
| ROD-002 | `SETTLED_RETIRED_OPEN_DECISION` — accepted A/B/C, eligible no-PR Class B, deterministic review-selected PR, protected Class C/trust, no-agent-direct-main, and irreducible-ambiguity-only notification policy. | RP-06 and RP-08 encode and prove the accepted rules. | Invalid/stale/revoked/mismatched authority and actual races deny/preserve; valid review-required or stable pre-route high-contention work uses protected PR. |
| ROD-003 | `OPERATOR_ACCEPTED_TRUST_BOOTSTRAP` — small content-addressed semantic epoch-zero inventory, one-time human trust anchor/bootstrap, and exact bounded activation preauthorization. Safe automatic activation remains proof- and promotion-gated. | RP-01 binds epoch-zero semantics; RP-09 binds exact preauthorization and activation mechanisms. | Trust changes land inert; activation stays disabled or operator-confirmed; safe-automatic remains unclaimed until proof and later promotion acceptance. |
| ROD-004 | `OPERATOR_ACCEPTED_DENY_BY_DEFAULT_CONFIG` — one operator-controlled signer family, immutable references/digests, explicit capability grants, and an initially empty source allowlist. | RP-12 binds nonsecret source/signer configuration and signed-catalog proof. | Unknown, unsigned, revoked, incompatible, or unadmitted sources deny; no private import or availability. |
| ROD-005 | `OPERATOR_ACCEPTED_ADAPTIVE_RESOURCE_POLICY` — lowest useful concurrency with conservative adjustable time, attempt, token, cost, and evidence ceilings; widen only from dogfood measurement. | RP-13 binds enforceable provisional values and conformance proof. | Child launch remains disabled until values are bound and every enforcement/conformance gate passes. |
| ROD-006 | `OPERATOR_ACCEPTED_NO_OCTON_DIRECT_MAIN` — Octon exposes no human or agent direct-main route; ordinary human Git remains outside Octon. | RP-00 proves route unreachability and disclosure; RP-14 consumes the receipt only as an upstream fact. | Eligible Class B uses brokered no-PR after the safety spine; PR is review-selected, never a failure fallback. |

## Genuine remaining operator decisions

None.

Exact values that can safely remain reversible are configuration and engineering
work, not unclosed operator decisions. If later measurement reveals a material,
non-reversible risk, cost, trust, recovery, or support tradeoff that cannot stay
inside the accepted posture, the owning packet must fail closed and open a new
governed decision rather than silently widen this receipt.

## Accepted choice details

### ROD-001 — Recovery and evidence posture

| Field | Accepted content |
| --- | --- |
| Accepted choice | Conservative reversible defaults, measured in dogfood and adjusted inside the accepted bounded-recovery posture. No unsupported fixed numbers. |
| Policy invariants | Bounded local raw evidence outside Git; longer-lived signed receipts/checkpoints/rollback references; terminal evidence reserve; no unsigned fallback; deny the affected consequential transition and preserve work when recovery evidence cannot be guaranteed. |
| Engineering/configuration work | Store path, backup mechanism, signer algorithm/provider, candidate-inaccessible monotonic anchor, reserve mechanism, and provisional cadence/size/generation values. |
| Evidence | Intake `decisions/operator-decisions.md:33-38,82-101,110-115`; `target-state/evidence-retention-and-degraded-operation.md:3-19`; roadmap `workgroups.yml:73-90,165-180`; reconciliation `remaining-operator-decisions.yml:5-16`. |
| Proof consequence | Backup/restore, stale-snapshot denial, key rotation/loss, compaction, pinning, byte/inode/quota pressure, terminal reserve, corruption, and recovery-objective tests. |

### ROD-003 — Initial trust grounding

| Field | Accepted content |
| --- | --- |
| Accepted choice | A small content-addressed semantic epoch-zero inventory with one-time human trust grounding; later preauthorization must bind exact scope, artifact/version, time, budget, verifier, health, and rollback rules. |
| Policy invariants | Inert landing; no same-change self-authorization; safe automatic activation remains disabled and unclaimed until prior-version verification, staged health, rollback proof, and later promotion acceptance pass. |
| Engineering/configuration work | Inventory encoding/detection, concrete anchor provisioning, health-window duration, canary mechanics, rollback retention, and other reversible values. |
| Evidence | Intake `decisions/operator-decisions.md:117-129`; `target-state/self-development-and-trust-activation.md:3-21`; `decisions/proof-obligations-and-unresolved.yml:25-32`; reconciliation `remaining-operator-decisions.yml:29-41`. |
| Proof consequence | Epoch-zero verification, same-change denial, dependency indirection, exact artifact/provider/approval binding, staged health, rollback, reboot/disk-full kill points, and self-widening denial. |

### ROD-004 — Private extension trust configuration

| Field | Accepted content |
| --- | --- |
| Accepted choice | One operator-controlled signer family, immutable references/digests, explicit capability grants, and an empty deny-by-default source allowlist until the first intentional admission. |
| Policy invariants | Unknown source, signer, capability, compatibility, pin, or revocation state denies import, availability, restore, and promotion. |
| Engineering/configuration work | Concrete signer identity/key reference, rotation/recovery mechanism, future intentional source admissions, immutable pins, compatibility encoding, and signed-envelope verification. |
| Evidence | Intake `decisions/operator-decisions.md:145-150`; `target-state/extensions-multi-agent-and-provider-boundaries.md:3-5`; roadmap `workgroups.yml:280-302`; reconciliation `remaining-operator-decisions.yml:42-52`. |
| Proof consequence | Unsigned/wrong/revoked/tampered source, immutable-reference drift, incompatibility, capability mismatch, signer rotation/loss, generation rollback, and restore tests. |

### ROD-005 — Child-agent resource posture

| Field | Accepted content |
| --- | --- |
| Accepted choice | The lowest useful concurrency and conservative adjustable wall-clock, attempt, token/cost, and evidence ceilings; widen only when dogfood demonstrates worthwhile completion benefit within the accepted bounded posture. No unsupported fixed numbers. |
| Policy invariants | Depth-one bounded authority, explicit scope, no ambient credentials, enforced cancellation/retirement, and child launch disabled until values and proof are current. |
| Engineering/configuration work | Initial provisional ceilings, enforcement mapping, provider conformance, and measurement/tuning rules. |
| Evidence | Intake `decisions/operator-decisions.md:152-164`; `target-state/extensions-multi-agent-and-provider-boundaries.md:7-15`; roadmap `workgroups.yml:303-325`; reconciliation `remaining-operator-decisions.yml:53-63`. |
| Proof consequence | Concurrency, attempts/retries, timeout, token/cost/evidence ceilings, depth, scope, credentials, cancellation, conflict, unknown outcome, provider conformance, and terminal retirement tests. |

### ROD-006 — Direct-main posture

| Field | Accepted content |
| --- | --- |
| Accepted choice | Octon exposes no human-only or autonomous direct-main route. Ordinary human Git remains possible outside Octon and outside autonomous support. |
| Policy invariants | No agent or Octon-owned direct-main path; hosted publication is candidate-first and brokered; PR is selected only by a valid pre-effect review predicate. |
| Engineering/configuration work | Route removal/unreachability, identity separation, rollback, and support disclosure. |
| Evidence | Intake `decisions/operator-decisions.md:68-73,166-171`; `product/product-experience.md:38-45`; Architect A `phase-1/current-finding-register.yml:699-710`; reconciliation `remaining-operator-decisions.yml:64-75`. |
| Proof consequence | Autonomous and Octon-owned direct-main unreachability, authorization separation, rollback, and support-disclosure tests. |

## Settled decision awaiting encoding and proof

ROD-002 is not a current operator question. RP-06 and RP-08 must encode the
accepted deterministic policy into versioned, digest-bound durable authority
and prove it. Concrete protected-path inventories and predicate implementation
are engineering work. The accepted behavior is:

- Class A autonomous candidate work;
- admitted Class B brokered, independently verified no-PR completion;
- deterministic protected PR for valid review-required or stable pre-route
  high-contention predicates; actual collision, invalid authority,
  `ATTEMPTING`, and `UNKNOWN` never change route;
- protected PR and guarded activation for Class C/trust-root work;
- no autonomous direct-main; and
- human notification only for irreducibly ambiguous state.

Evidence: intake `decisions/operator-decisions.md:12-17,68-73,110-115`,
`product/friction-and-operational-standards.md:19-21,34-40`, and cross-review
`cross-review/architect-a/response.md:21-27,42-50`.

## Later evidence-gated promotion acceptance

These are not unresolved architecture decisions:

- final core Solo Local support wording;
- signed-extension support admission;
- child-agent support admission;
- secondary-provider support admission; and
- safe-automatic trust activation claim/enablement.

RP-14 consumes child-owned proof and produces an evidence-only claim map. Each
passing claim then follows its separately governed promotion route. Failed,
stale, or incomplete proof leaves the capability disabled/unclaimed. ROD-006
does not govern promotion and is already accepted at the proposal-program level.

## Unresolved evidence ownership

| Evidence | Primary owner | Cross-packet role |
| --- | --- | --- |
| UE-001 | RP-01 | RP-09 consumes/refreshes trust use |
| UE-002 | RP-01 | exact guard proof |
| UE-003 | RP-02 | candidate-isolation proof; RP-04 cross-checks broker IPC/credential boundary |
| UE-004 | RP-03 | store crash substrate; RP-08 cross-checks outcome behavior |
| UE-005 | RP-05 | hostile Git/CAS proof |
| UE-006 | RP-06 | verifier/publisher binding |
| UE-007 | RP-08 | attribution/retry behavior; RP-05 fixture |
| UE-008 | RP-07 | forgery/rollback/capacity/compaction |
| UE-009 | RP-09 | trust activation fault proof |
| UE-010 | RP-11 | consumes RP-01/RP-02/RP-10 |
| UE-011 | RP-11 component, RP-14 promotion | provider conformance reproduction |
| UE-012 | RP-12 | signed extension import/recovery |
| UE-013 | RP-13 | bounded child proof |
| UE-014 | RP-14 | integrated solo dogfood/burden |
| UE-015 | RP-14 promotion | RP-06/RP-09 implementation-time refresh contributors |
