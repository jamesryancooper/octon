# Current-to-Target Crosswalk

The target is not a rewrite. It retains mature domain contracts while moving
material authority and effects behind structural, transactional boundaries.

| Migration area | Current verified state | Target | Disposition | Completion proof |
|---|---|---|---|---|
| 1. Architecture and support claims | Complete/live claims exceed launch, verifier, and proof execution | Claims match physical mediation and fresh proof | Correct immediately | Claim-to-proof validator rejects every overstated fixture |
| 2. Candidate provider writes | pull_request_target runs candidate code with write token | No candidate code under provider credentials | Disable, later replace | Malicious PR suite cannot execute with token |
| 3. Canonical authority | authority_engine plus lifecycle-local proof | authority_engine sole issuer | Preserve engine; demote lifecycle authority | Missing/forged/stale/revoked/mismatched request denies every route |
| 4. Invocation guards | ExecutorLaunch exists but does not dominate spawn | Exact one-shot guard at spawn | Extend and structurally enforce | Launch-site inventory plus concurrent consume |
| 5. Credentialless native isolation | Shared HOME/env/checkout; partial Codex sandbox | Disposable native macOS candidate | Replace launcher envelope | Credential/filesystem/process/network denial matrix |
| 6. Isolated Git state | Worktrees share common Git state | Independent candidate object/ref/config state | Replace worktree security role | Candidate ref/object/config changes invisible to canonical repo |
| 7. SQLite/WAL source of truth | JSON/YAML/NDJSON independent writers | One local transactional store | Add and cut over atomically | Kill, race, corruption, backup, restore suite |
| 8. Local broker | No durable-effect custody process | One separate deterministic local broker | Add | Candidate raw effect denied; broker exact effect succeeds |
| 9. Credential migration | Keyring/PAT/Git helper available to ambient tools | Broker-only credential custody | Migrate with enrollment | Candidate cannot read/use credential; broker least privilege proved |
| 10. Sanitized Git adapter | Ordinary Git with ambient config/extensions | Broker-owned allowlisted Git | Replace performer; reuse ref checks | Hostile hooks/includes/filters/helpers/drivers cannot run |
| 11. Exact-SHA verifier | Candidate workflow/scripts produce required contexts | Candidate-immutable signed verifier | Replace identity and verdict | Self-modification and duplicate-context attempts deny |
| 12. Adaptive no-PR publication | Useful no-PR receipt/preflight logic, self-minted auth | Brokered exact CAS landing | Preserve logic behind broker | Source/target race, expiry, revocation, replay suite |
| 13. PR escalation | PR route exists | Automatic policy escalation/fallback | Modify route selector | Class C and uncertainty fixtures always select PR |
| 14. Direct-main retirement | Active normal solo route | No autonomous direct-main | Retire | Search, contract, CLI, and effect denial prove absence |
| 15. Runtime recovery | Replay concepts, no effect reconciliation | Operation attempt/unknown/reconcile/terminal machine | Extend into store/broker | Every fault converges without duplicate effect |
| 16. Signed bounded evidence | Hash chains and many retained files | Direct-observer signatures and bounded checkpoints | Preserve chain logic; add authenticity and bounds | Rechain/snapshot/compaction/low-space tests |
| 17. Safe degraded operation | Fail-closed concepts, no broker/store model | Block affected transition; preserve work/Class A | Add explicit states | Dependency outage matrix preserves candidate, no ambient fallback |
| 18. Self-development | Promotion readiness gate, candidate-mutable proof | Ordinary Class B; trust root inert | Modify | Self-gate changes cannot self-certify |
| 19. Trust-root activation | No installed-version state machine | Previous-version verified staged activation/rollback | Add after proof stack | Every activation kill point reaches safe terminal state |
| 20. Workspace Projects | Singleton Project Profile/locality | Minimal durable non-authority project ID/bounds | Add, reuse profile | Two-project and relocation tests; no authority widening |
| 21. Harness Factory | Schemas/context/resolver fragments | Deterministic digest-bound compiler only | Add compiler, reuse primitives | Identical input digest; stale/self-widened manifest denies |
| 22. Extensions/private catalog | Strong publication/quarantine, unsigned import | Signed pinned/revocable private catalog | Extend | Tamper, revoke, incompatibility, rollback tests |
| 23. Mission-scoped agents | Lifecycle children exist, ambient and unguarded | Temporary bounded credentialless children | Modify launcher/delegation | Scope/depth/budget/retirement tests |
| 24. Maintenance/external effects | Broad capability concepts; no brokered exemplar | Selected reversible brokered effects | Defer until core proof | One dogfood effect passes failure/recovery burden gate |
| 25. Setup/diagnostics/repair | Multi-step engagement/profile/plan/arm | Guided setup, doctor, repair, inbox | Consolidate product surface | Timed clean-machine and restart/recovery usability tests |
| 26. Support-claim transition | Current live/complete disclosures | Structural until dynamically re-admitted | Demote then promote by proof | Proof expiry automatically withdraws claim |
| 27. Authoritative promotion | Receipt and non-authority contracts exist | Formal packet/ADR promotion after proof | Preserve governance; integrate gates | Promotion references exact accepted packets and proof digests |

## Smallest safe bridge

The only permitted publication bridge before broker/verifier proof is a
manual or protected PR route that does not execute candidate code with
credentials. Candidate branches and evidence are preserved when publication
is blocked. Direct-main, ambient provider credentials, and the current
privileged auto-merge lane are not compatibility bridges.

