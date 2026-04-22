# Target Architecture

## Executive decision

Adopt a target-state architecture in which Octon's constitutional model is not
only structurally correct but mechanically unavoidable at runtime.

The target state preserves the current live architecture's strongest decisions:

- single `/.octon/` super-root;
- five class roots;
- authored authority only in `framework/**` and `instance/**`;
- `state/**` as operational truth, retained evidence, and continuity;
- `generated/**` as derived-only;
- `inputs/**` as non-authoritative;
- run contracts as atomic consequential execution units;
- missions as continuity containers;
- engine-owned `authorize_execution(...)` as the material side-effect boundary;
- support claims as bounded, admitted, finite, proof-backed tuples;
- host/model adapters as replaceable and non-authoritative.

The target state changes what must be proven before Octon can credibly score
10/10:

1. Every material side-effect path is inventoried, mapped, tested, and blocked if
   it cannot prove `authorize_execution` coverage.
2. Every live support tuple is physically separated from stage-only, unadmitted,
   and retired claim artifacts.
3. Every support tuple, pack admission, runtime route, dossier, proof bundle, and
   disclosure claim is invariant-checked as one graph.
4. Every runtime-facing generated/effective output is rejected when freshness or
   publication receipts are missing or stale.
5. Every mission/run lifecycle transition is bound to canonical run roots,
   rollback posture, operator-visible state, retained evidence, and disclosure.
6. Pack and extension lifecycle surfaces are normalized into a small number of
   authored/control/generated states with generated projections instead of manual
   duplication.
7. Operator boot is split from closeout and compatibility workflow concerns.
8. Transitional shims carry owner, successor, review cadence, and retirement
   trigger; shims without those facts fail architecture health.
9. Proof-plane artifacts are sufficient to audit behavioral, structural,
   governance, maintainability, support, and recovery claims.
10. The runtime is packaged, validated, installable, and demonstrably able to
    execute the canonical first-run lifecycle.

## Target-state architectural principle

Every surface must do at least one of four things:

1. enforce a boundary,
2. generate or retain proof,
3. simplify operator or agent understanding,
4. or be retired.

## Target-state class-root discipline

| Class root | Target-state role | Required invariant |
| --- | --- | --- |
| `framework/**` | Portable authored Octon authority, runtime contracts, validators, proof-plane framework, runtime implementation | Must not contain repo-local mutable control truth, retained evidence, or generated outputs. |
| `instance/**` | Repo-specific durable authority: ingress, bootstrap, manifest, governance, locality, decisions, missions, admitted runtime overlays | Must not contain raw untrusted inputs or generated read models presented as authority. |
| `state/**` | Mutable operational truth, retained evidence, continuity, quarantine, active selections | Must not contain portable framework contracts or repo-owned durable governance policy except as retained copies/receipts. |
| `generated/**` | Derived runtime-effective outputs, cognition projections, proposal discovery | Must never mint authority; runtime-facing outputs require receipts and freshness. |
| `inputs/**` | Raw additive/exploratory material | Must never be a direct runtime or policy dependency. |

## Target-state execution model

### Atomic unit

The run contract remains the atomic consequential execution unit. Mission files
may authorize continuity, cadence, scope, and long-horizon intent, but they may
not authorize material execution without a bound run contract.

### Authorization boundary

All material paths must pass through the engine-owned authorization boundary:

```rust
authorize_execution(request: ExecutionRequest) -> GrantBundle
```

Target-state acceptance requires full coverage for:

- repo mutation;
- evidence mutation;
- control mutation;
- generated/effective publication;
- executor launch;
- service invocation;
- protected CI checks;
- workflow compatibility wrappers;
- adapter-mediated actions;
- pack activation/publication;
- elevated operator closeout.

### Runtime state

The target runtime exposes one canonical operator flow:

```text
octon doctor --architecture
octon run start --contract <path>
octon run inspect --run-id <id>
octon run checkpoint --run-id <id>
octon run disclose --run-id <id>
octon run close --run-id <id>
octon run replay --run-id <id>
```

Workflow execution may remain only as a compatibility wrapper until run-first
usage is complete.

## Target-state support and claim architecture

Support artifacts must be physically and mechanically partitioned:

```text
instance/governance/support-target-admissions/
  live/
  stage-only/
  unadmitted/
  retired/

instance/governance/support-dossiers/
  live/
  stage-only/
  unadmitted/
  retired/
```

`support-targets.yml` remains the bounded support matrix but must not become a
flat mix of live and non-live references that requires readers to infer claim
state. Validators must prove that:

- live support tuples have current admissions, dossiers, proof bundles,
  representative run disclosures, negative controls, and SupportCards;
- stage-only tuples cannot be claimed as live;
- unadmitted packs or adapters cannot appear in live routes;
- generated disclosures cannot widen live support;
- active missions cannot default to stage-only or non-live support tiers without
  explicit stage-only posture.

## Target-state pack and extension architecture

Packs and extensions remain valid abstractions only if their lifecycle is small,
typed, validated, and publication-bound.

### Pack lifecycle

1. Framework pack contract: `framework/capabilities/packs/**`.
2. Instance governance selection: `instance/governance/capability-packs/**`.
3. Runtime admission decision: `instance/capabilities/runtime/packs/admissions/**`
   or a generated admission projection from the canonical governance intent.
4. Runtime-effective projection: `generated/effective/capabilities/**`, only when
   current publication receipts and freshness artifacts exist.
5. Run usage: request/grant/receipt must cite pack id, admission id, support tuple,
   route, and output/evidence envelope.

### Extension lifecycle

1. Raw additive inputs live under `inputs/additive/extensions/**`.
2. Desired selection lives in `instance/extensions.yml`.
3. Actual active/quarantine truth lives under `state/control/extensions/**`.
4. Runtime-effective output lives under `generated/effective/extensions/**`.
5. Publication receipts live under `state/evidence/validation/publication/**`.
6. Stale generated/effective outputs fail closed.

The target state does not allow raw additive extension inputs or generated
extension projections to become policy or runtime authority.

## Target-state proof-plane architecture

Proof planes remain distinct and composable:

| Proof plane | Target role |
| --- | --- |
| Structural conformance | placement, registry, overlay, class-root, generated/authored boundaries |
| Behavioral/lab | scenarios, replay, shadow-runs, negative controls, adversarial claims |
| Governance/support | support tuple admission, dossier sufficiency, proof bundle, support card, claim effect |
| Maintainability | active-doc hygiene, registry readability, change containment, discoverability |
| Recovery/reversibility | rollback posture, replay bundles, checkpoint integrity, closure readiness |
| Runtime enforcement | authorization coverage, material side-effect tests, run lifecycle transitions |

A live claim is target-state valid only when the required proof-plane artifacts are
retained and inspectable.

## Target-state operator boot

`instance/ingress/manifest.yml` should own mandatory reads, optional orientation,
and adapter parity. Branch closeout, merge lane, and deprecated prompt fallback
logic should move to dedicated closeout contracts/workflows.

The target boot path is:

1. `/.octon/README.md`
2. `/.octon/AGENTS.md` as projected ingress adapter
3. `/.octon/instance/ingress/AGENTS.md`
4. `/.octon/instance/bootstrap/START.md`
5. `octon doctor --architecture`
6. first run contract or read-only orientation run

## Target-state deployment practicality

The target architecture must be installable, inspectable, and recoverable:

- versioned runtime binary or reproducible build path;
- schema/validator version compatibility;
- local initialization path;
- architecture health command;
- support matrix command;
- proof bundle generation command;
- migration and rollback procedure;
- fixtures for all negative controls.

## What the target state explicitly avoids

- New top-level control plane.
- Generated artifacts as authority.
- Raw inputs as direct policy/runtime dependencies.
- Support claim widening by adapter or pack admission.
- A separate mission-only execution path.
- Permanent workflow-first compatibility semantics.
- A new enterprise governance layer outside Octon's class-root model.
- Pack/extension marketplace mechanics before trust and publication invariants are sealed.
