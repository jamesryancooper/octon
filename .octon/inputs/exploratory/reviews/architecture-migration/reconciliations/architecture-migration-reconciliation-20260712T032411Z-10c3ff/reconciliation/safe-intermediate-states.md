# Safe Intermediate States

Each state is a supported migration resting point. Advancing requires the listed exit proof; rollback cannot restore a prohibited bridge.

## SI-00 — Contained baseline

- Entry: normalized clean commit and provider evidence bound.
- Permitted: observation, proposal drafting, candidate work, manual/protected PR.
- Required: candidate-head provider writers and autonomous direct-main disabled; claims narrowed; writers/launches/credentials/trust roots inventoried.
- Prohibited: privileged autonomous implementation.
- Rollback: restore only documentation/inventory changes; keep unsafe routes disabled.

## SI-01 — Trusted authority, no autonomous effects

- Entry: SI-00.
- Required: candidate-immutable evaluator/policy floor, production override denial, typed scope repair, exhaustive exact launch guards.
- Permitted: guarded candidate launch against non-privileged fixtures.
- Prohibited: brokered provider/Git effects.
- Rollback: prior certified authority binary/config; disable affected launcher.

## SI-02 — Useful credentialless isolated candidate

- Entry: SI-00; may proceed in parallel with SI-01.
- Required: independent disposable repository/object database, native macOS policy, useful primary supported-provider session, negative credential/host/Git tests.
- Permitted: candidate work export for manual/protected PR.
- Prohibited: candidate access to canonical Git, broker credentials, or privileged IPC.
- Rollback: preserve exported candidate commit; disable automated candidate launch.

## SI-03 — One transactional source of truth

- Entry: SI-01 authority/guard semantics are frozen; SI-02 may proceed independently.
- Required: migrated grants/guards/operations/attempts/revocation/outbox/recovery state in one SQLite/WAL writer; backup/restore and fault proof.
- Permitted: legacy files as read-only projections.
- Prohibited: dual writers or YAML/file authority after first transactional effect.
- Rollback: before first effect, restore immutable snapshot. Afterward keep effects disabled; restore only crash-consistent certified DB/WAL plus monotonic epoch/high-water state, reconcile external outcomes and revoke/advance uncertain authority, or repair forward. Never make an older authority DB live directly.

## SI-04 — Supervised broker with one non-production effect

- Entry: SI-01, SI-02, SI-03.
- Required: authenticated IPC stronger than same-UID alone, credential custody, operation-handle validation, auto-start/restart, doctor/repair, one exact scratch effect.
- Permitted: broker effects against disposable targets.
- Prohibited: production Class B publication.
- Rollback: disable broker route, preserve candidate output, use protected PR.

## SI-05 — Sanitized Git and immutable verifier

- Entry: SI-04.
- Required: broker-owned minimal Git state, non-executing object transfer, hostile extension denial, expected-old fast-forward primitive, separate exact-SHA verdict identity.
- Permitted: staging/source-ref fixture publication.
- Prohibited: autonomous production landing until evidence/recovery closes.
- Rollback: previous certified adapter/verifier behind same identities or route disablement.

## SI-06 — Signed recoverable Class B vertical

- Entry: SI-05 plus signed evidence/capacity/retention.
- Required: unknown-outcome reconciliation, target race/duplicate/lost-response/provider-outage/broker-crash tests, deterministic PR escalation, zero routine prompts.
- Permitted: admitted Class B within the proved support tuple.
- Prohibited: trust-root automation and broader support claims.
- Rollback: disable Class B route; preserve work and use protected PR. Do not disable signing while claiming autonomous success.

## SI-07 — Safe self-development and trust activation

- Entry: SI-06.
- Required: ordinary self-change through Class B, trust-root changes land inert, previous-version exact activation, staged health, automatic rollback, self-widening denial.
- Permitted: preauthorized trust-root activation within the exact proved state machine.
- Prohibited: same-change self-certification or candidate-modifiable activation rules.
- Rollback: authenticated automatic old-version restoration; otherwise remain inert.

## SI-08 — Complete solo target, not yet authoritative

- Entry: Projects, cross-project mission inbox, Harness Factory, SI-07, and every capability whose claim is being promoted are complete.
- Required: fresh setup, two-project/inbox and rolling 30-day dogfood, scheduled maintenance and one reversible effect, completion/speed/recovery/burden budgets, provider conformance for each claimed tuple, proof map, independent reproduction.
- Permitted: formal operator disposition and promotion preparation.
- Prohibited: treating this research reconciliation as Octon authority.
- Rollback: demote failed support claims and disable affected feature/route while preserving lower safe states.
