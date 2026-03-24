# Validation Plan

The cutover is blocked on a full validation stack that proves MSRAOM is
complete, integrated, and internally coherent.

## Validation Layers

### 1. Schema Validation
Validate:
- all newly added mission-control and scenario-resolution schemas
- all updated execution and policy schemas
- mission scaffolds and active mission examples against the final schemas

### 2. Contract-Registry Alignment
Block merge if:
- a schema exists but is not in the contract registry
- a runtime-consumed file has no durable contract
- a documented canonical surface has no contract and no scaffold

### 3. Runtime Guards
Block merge if:
- autonomous execution can start without a valid mission ID
- autonomous execution can start without a valid slice ID
- autonomous execution can start without a valid intent ID
- a mission can run autonomously without a valid lease
- a stale or missing scenario-resolution artifact is silently ignored
- recovery semantics fall back to undocumented hardcoded behavior

### 4. Projection Freshness
Validate:
- generated effective route freshness
- generated mission summary freshness
- operator digest freshness
- consistent source refs in scenario resolution and summaries

### 5. Control Evidence Emission
Validate that the following create retained control receipts:
- directive application
- authorize-update application
- lease mutation
- schedule mutation
- breaker trip
- breaker reset
- safing change
- break-glass activation
- break-glass clearing

### 6. Reader Alignment
Regression tests must prove:
- `owner_ref` is consumed by runtime and generated views
- legacy `owner` is not the canonical read path after the cutover

## Scenario Conformance Suite

The cutover must include a blocking scenario suite that drives one mission fixture
or equivalent test harness through the following cases.

| Scenario | Expected route and outcome |
| --- | --- |
| Routine repo housekeeping | `silent`, digest-only, revert-based recovery |
| Long-running refactor | `notify` at mission open, interruptible scheduled posture, slice-level rollback |
| Dependency/security patching | `feedback_window` or `proceed_on_silence`, canary boundary, rollback handle |
| Release maintenance | staging allowed, publish/finalize `approval_required` |
| Infrastructure drift correction | mission-class default plus attestation overlay; `STAGE_ONLY` when required authority missing |
| Cost optimization / cleanup | soft-destructive proceed-on-silence allowed with recovery window; hard delete separated |
| Data migration / backfill | chunk boundaries, recovery profile, explicit finalize step |
| External API sync | at least `notify`; compensable route, not silent by default |
| Monitoring / observe-only | `silent`, continuous, observe-to-operate fork where policy allows |
| Production incident response | bounded emergency route, explicit containment rationale, breaker/safing awareness |
| High-volume repetitive work | campaign-level visibility, batch-level receipts, no per-item alert spam |
| Destructive high-impact work | `approval_required`, no autonomous point-of-no-return |
| Human absent | proceed only where declared; `STAGE_ONLY` or pause when required authority missing |
| Human late | rollback / compensation or finalize-block within recovery window |
| Conflicting human input | authoritative precedence or safe-boundary pause / stage-only |
| Breaker trip | mode tightens automatically; scheduler responds |
| Safing | authority contracts to safe subset |
| Break-glass | explicit override, TTL, receipts, and postmortem obligations |

## Negative Suite

The cutover must fail closed in these cases:

1. missing `lease.yml`
2. missing `intent-register.yml`
3. missing or stale `scenario-resolution.yml`
4. missing rollback/compensation data on a route that requires it
5. proceed-on-silence attempted on irreversible or disallowed work
6. unauthorized break-glass activation
7. missing ownership precedence resolution for conflicting directives
8. runtime tries to start a new run while `suspended_future_runs` is true
9. runtime crosses a point of no return while `block_finalize` is active
10. generated views drift from canonical source refs

## Required Test Assets

- at least one canonical sample mission fixture for each mission class
- one scenario-resolution fixture per scenario family
- control-receipt fixtures
- generated summary fixtures for at least one active mission and one operator

## Merge Gates

The cutover cannot merge until all of the following are true:

1. schema validation is green
2. contract registry validation is green
3. runtime guards are green
4. scenario suite is green
5. negative suite is green
6. generated summary freshness checks are green
7. control-evidence emission checks are green
8. doc-claim alignment checks are green
9. sample fixtures are committed
10. migration plan and evidence roots are created

## Post-Merge Verification

Immediately after merge:

- regenerate scenario-resolution and mission/operator summaries for sample missions
- verify no placeholder-only canonical directories remain
- verify control receipts emit for at least one directive and one breaker event
- verify branch release metadata points to `0.6.0`
