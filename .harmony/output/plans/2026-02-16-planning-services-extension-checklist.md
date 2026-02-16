# Planning Services Extension Checklist (Ordered, Gate-Driven)

Date: 2026-02-16
Owner: architect
Scope: `.harmony/capabilities/services/planning` + required shared service registry updates

## Rules

1. Execute phases strictly in numeric order.
2. Do not begin phase `N+1` until phase `N` gate passes.
3. If a gate fails, resolve all failures in the same phase.
4. All new planning services must remain tech-stack-agnostic and OS-agnostic.
5. No Python runtime dependency is allowed for core planning paths.
6. External runtimes/interfaces remain optional adapters only.

## Phase Tracker

### Phase 0: Confirm Service Scope and Contracts

Status: `completed`

Deliverables:
- Confirmed initial planning service additions: `critic`, `replan`, `scheduler`, `capability-bind`, `contingency`.
- Confirmed service boundaries: all services remain in `.harmony/capabilities/services/planning`.
- Confirmed implementation style: shell scripts + JSON schemas + deterministic fixtures.

Gate:
- Service list approved and scoped.
- No external dependency required by core paths.

### Phase 1: Scaffold New Planning Services

Status: `completed`

Deliverables:
- `planning/critic/{SERVICE.md,compatibility.yml,contracts/,fixture/,guide.md,impl/,references/,rules/,schema/,README?}`
- `planning/replan/{SERVICE.md,compatibility.yml,contracts/,fixture/,guide.md,impl/,references/,rules/,schema/,README?}`
- `planning/scheduler/{SERVICE.md,compatibility.yml,contracts/,fixture/,guide.md,impl/,references/,rules/,schema/,README?}`
- `planning/capability-bind/{SERVICE.md,compatibility.yml,contracts/,fixture/,guide.md,impl/,references/,rules/,schema/,README?}`
- `planning/contingency/{SERVICE.md,compatibility.yml,contracts/,fixture/,guide.md,impl/,references/,rules/,schema/,README?}`

Gate command:

```bash
bash .harmony/capabilities/services/_ops/scripts/validate-services.sh
```

### Phase 2: Implement Service Logic (MVP Native)

Status: `completed`

Deliverables:
- `critic/impl/critic.sh` with deterministic `validate` and `score` modes
- `replan/impl/replan.sh` with deterministic step repair/re-sequencing behavior
- `scheduler/impl/scheduler.sh` with deterministic schedule generation
- `capability-bind/impl/capability-bind.sh` with deterministic capability negotiation semantics
- `contingency/impl/contingency.sh` with deterministic alternative-path generation

Gate command:

```bash
bash .harmony/capabilities/services/planning/_ops/scripts/validate-planning-fixtures.sh
```

### Phase 3: Register Services in Shared Service Indices

Status: `completed`

Deliverables:
- `.harmony/capabilities/services/manifest.yml` entries for five services
- `.harmony/capabilities/services/registry.yml` entries for five services
- `.harmony/capabilities/services/capabilities.yml` category updates
- `.harmony/capabilities/services/planning/README.md` service list updated

Gate:

```bash
bash .harmony/capabilities/services/_ops/scripts/validate-services.sh
```

### Phase 4: Expand Planning Fixture Harness

Status: `completed`

Deliverables:
- `.harmony/capabilities/services/planning/_ops/scripts/validate-planning-fixtures.sh` extended
  to validate planner/critic/replan/scheduler/capability-bind/contingency fixtures.

Gate:

```bash
bash .harmony/capabilities/services/_ops/scripts/validate-services.sh
bash .harmony/capabilities/services/planning/_ops/scripts/validate-planning-fixtures.sh
```

### Phase 5: Final Hardening and Documentation

Status: `completed`

Deliverables:
- Updated `validator` and `registry` references are deterministic and executable.
- Commit message sequence records the full migration.
- Short summary of residual risks.

Gate:

```bash
bash .harmony/capabilities/services/_ops/scripts/validate-services.sh
bash .harmony/capabilities/services/planning/_ops/scripts/validate-planning-fixtures.sh
bash .harmony/capabilities/services/_ops/scripts/validate-service-independence.sh --mode services-core
```

## Progress Log

- 2026-02-16: Plan created and scope finalized.
- 2026-02-16: Additional planning service additions approved for immediate implementation.
- 2026-02-16: Scaffolding pass started.
- 2026-02-16: Validation gates completed for planning fixtures and new service registrations.
- 2026-02-16: Full planning service migration finalized and checker script bugfixes resolved.
