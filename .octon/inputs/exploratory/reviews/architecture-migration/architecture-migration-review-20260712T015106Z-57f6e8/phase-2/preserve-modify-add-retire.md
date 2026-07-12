# Preserve / Modify / Add / Retire (evidence-grounded)

> Non-authoritative. Every entry cites the Phase 1 finding that justifies it.

## PRESERVE (working primitives that satisfy the target — do not rebuild)

| Item | Why | Evidence |
|---|---|---|
| `authority_engine::verify_authorized_effect` single-use token verifier | Correct deny-by-default primitive; extend, don't replace | A-07, J-05 |
| Kernel `authorize_execution` + verify pattern before every subprocess | Proof the mediation pattern is implementable and already applied | A-07 |
| `protected_ci_auto_merge` gated command | Good model: approval projection + bound caps + verified effects before merge | strengths (comprehensive-review §4) |
| `promotion_blockers()` fail-closed reader | Thorough non-self-approval logic; wire onto enforced path | F-018-2 |
| Deterministic Harness Factory + `runtime_resolver` digest enforcement | FD-020 SATISFIED; compile-fixed, runtime-verified | G-03, G-04 |
| Provider adapter contracts (non-authoritative, replaceable) | FD-023 SATISFIED | G-07, G-08 |
| Extension catalog (provenance, pin, quarantine, no marketplace) | FD-021 core realized | G-05 |
| Project Profile "never authority" discipline | FD-019 never-authority half solid | G-02 |
| Transition-scoped degraded operation | FD-016 blocking half is a real strength | B-08 |
| Evidence completeness / fail-closed hash-match rules | FD-014 completeness half is honest | E-06 |
| Inline network-egress exception-lease model | FD-013 no-standalone-service half satisfied | E-05 |
| `side_effects` INVENTORY enumerating ExecutorLaunch | Reuse as the enforced-invariant seed | J-05 |

## MODIFY / EXTEND

| Item | Change | Evidence |
|---|---|---|
| `lifecycle_executor` | Depend on authority_engine; consume canonical grant + one-shot ExecutorLaunch before spawn | A-01, A-02, J-01 |
| `DelegationProof` | Demote to evidence-only; keep its governance checks subordinate to canonical grant | A-01 |
| Both executor spawn paths | Add `env_clear` + allowlist + OS sandbox wrapper | B-01, B-03, J-02 |
| `route_selection_order` | Remove/guard direct-main for autonomous work; branch-no-PR default | C-005 |
| Single-use consume | Non-transactional read-check-write → transactional CAS | D-02, J-04 |
| Evidence vocabulary + quorum | Sign or reword; quorum verifies identity not string presence | E-01, E-03, E-06 |
| Trust-root certification gates | Run verifiers from base ref, not PR head | F-017-2 |
| `trust_domain_add` | Validate the approval artifact, not its mere presence | J-06 |
| "Class A/B/C" naming | Rename retention taxonomy; map FD-002 consequence classes onto ACP model | H-01, H-08 |
| Stale-route-bundle env bypass | Require signed exception artifact, not bare env var | J-08 |

## ADD (net-new, each closes a specific testable gap)

| Item | Gap it closes | Evidence |
|---|---|---|
| Local credential-holding broker (separate process) | No credential boundary exists | B-02, H-02 |
| SQLite/WAL transactional store | No atomic transaction boundary | D-01, D-03 |
| macOS OS-sandbox launcher + isolated Git state | No isolation at all | B-04, B-05 |
| Sanitized git adapter (in broker) | Git runs unsanitized; hooks execute | C-001, C-002 |
| Candidate-immutable out-of-tree exact-SHA verifier | Verifier authors its own verdict | C-003, C-006 |
| Unknown-outcome reconciliation + attempt lifecycle | No "did it land?" recovery | D-05, D-06 |
| Capacity reservation in operation transaction | No reservation; near-full-disk unsafe | D-04, E-04 |
| Inert trust-root landing + staged activation controller | No inert landing; no staged rollback activation | F-017-3, F-018-1 |
| Enforced self-dev/trust-root classifier + merge gate | Evolution discipline is unwired prose | F-017-1, F-017-4 |
| Minimal `workspace-project-v1` identity (never authority) | No durable project identity | G-01 |
| Operator-mode `octon doctor` + cross-project `octon inbox` | Diagnose/inbox legs missing | H-05, H-09 |
| Signing (ed25519/HMAC) — if option A chosen | No signing exists | E-01, E-02 |

## RETIRE / DEMOTE

| Item | Action | Evidence |
|---|---|---|
| Self-attesting DelegationProof-as-authority | Demote to evidence | A-01 |
| Ambient durable credentials at spawn | Retire (env_clear + broker) | B-01, J-02 |
| Managed git hooks (`git-autonomy-hooks-install.sh`) | Retire; move cleanup to gated command | C-002 |
| Autonomous direct-main work | Retire from autonomous route order | C-005 |
| File state as transaction boundary | Replace with SQLite/WAL | D-01 |
| Standalone route-write-lease as authority | Demote to derived projection | D-04 |
| Overbroad "signed / complete-mediation / non-repudiation" claims | Retire the wording (or back with real signing) | E-01, E-03, J-05 |
| Federation / Trust-Compact multi-party breadth (solo vertical) | Demote behind off-by-default feature | H-04 |

## EXPLICITLY EXCLUDE (permanently out of scope — do not introduce)

VMs, enterprise identity/RBAC/SSO/SCIM, distributed consensus/multi-writer ledgers,
public marketplace, persistent agent organizations, second broker/control plane,
native Windows, Octon-owned container platform. (Cross-checked against
`decisions/rejected-and-out-of-scope.yml`.) The migration introduces none of these;
Phase 3 verifies the plan does not smuggle a second control plane.
