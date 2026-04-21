# Risk Register

proposal_id: `octon-architecture-10of10-remediation`  
resource_role: architectural/runtime/migration risk register  
status: non-authoritative proposal resource under `inputs/**`

---

## Risk scale

| Level | Meaning |
|---|---|
| Critical | Can invalidate the target-state or core constitutional promise. |
| High | Can materially prevent 10/10 readiness. |
| Medium | Can slow adoption or create maintainability/reliability drag. |
| Low | Manageable cleanup or localized risk. |

---

## Register

| ID | Risk | Class | Severity | Likelihood | Impact | Mitigation | Closure evidence |
|---|---|---|---:|---:|---|---|---|
| R-001 | Authorization bypass remains possible through an unregistered material path | Runtime | Critical | Medium | Core governance promise fails | material path inventory, static call-path checks, negative bypass tests, protected CI gate | Authorization coverage receipt with 100% material path coverage |
| R-002 | Contract registry becomes another duplicate source instead of replacing duplication | Architecture | High | Medium | Drift persists | extend existing `contract-registry.yml`; generate docs; deprecate hand-maintained path matrices | drift report showing docs generated or registry-consistent |
| R-003 | Evidence store contract is underspecified | Evidence | High | Medium | RunCards/replay/disclosure cannot be trusted | define schema, conformance suite, retained evidence classes, retention policy | evidence-store conformance receipt |
| R-004 | CI artifacts are mistaken for canonical evidence | Evidence | High | Medium | evidence disappears or becomes unverifiable | label CI artifacts transport-only unless copied/hashed/registered | evidence plan adopted; validation rejects transport-only closeout |
| R-005 | Promotion hardening slows legitimate human edits too much | Governance/UX | Medium | Medium | operators bypass system | distinguish human-authored direct authority edits from generated/input promotion; keep receipts lightweight | promotion UX accepted and negative tests pass |
| R-006 | Authority engine decomposition changes behavior unintentionally | Runtime | High | Medium | regressions in grant/deny logic | golden fixtures before refactor; parity tests; staged cutover | parity report and fixture coverage |
| R-007 | Operator read models accidentally become authority | Boundary | High | Low-Medium | generated non-authority invariant weakens | generated disclaimers, validators, path restrictions, no runtime direct dependency | generated-boundary validation receipt |
| R-008 | Support-target proofing blocks all progress due to excessive proof burden | Support | Medium | Medium | support matrix stagnates | tiered support proof levels; keep stage-only honest | support proof policy with minimal live tuple proof |
| R-009 | Historical cutover relocation removes useful context | Documentation | Low-Medium | Medium | maintainers lose migration trace | archive under decisions/evidence; generate references | relocation index and backlinks |
| R-010 | Architecture self-validation becomes brittle/noisy | Validation | Medium | Medium | false positives reduce trust | fixture-based tests, severity levels, stable schemas | low-flake CI run history |
| R-011 | Runtime packaging strict mode breaks dev workflows | Packaging | Medium | Medium | adoption friction | strict mode for release, source fallback explicitly dev-only with warnings | packaging decision record and tests |
| R-012 | Proposal promoted partially, leaving inconsistent architecture | Migration | High | Medium | mixed old/new semantics | hybrid bounded cutover with gates and rollback | cutover checklist completed with transition receipts |
| R-013 | External integrations push Octon to own too much | Scope | Medium | Medium | complexity bloat | native-vs-integrated boundary: own authority/evidence/control; integrate execution surfaces | scope review and rejection ledger |
| R-014 | Pack/adapter lifecycle remains implicit | Extensibility | Medium | Medium | plugin sprawl or hidden authority | later pack/admission contracts tied to promotion/evidence | pack lifecycle validator in follow-up |
| R-015 | Operator UX remains too weak to make architecture inspectable | Ergonomics | High | Medium | architecture remains hard to trust | generated operator views, CLI/TUI status, RunCard generation | operator view acceptance tests |
