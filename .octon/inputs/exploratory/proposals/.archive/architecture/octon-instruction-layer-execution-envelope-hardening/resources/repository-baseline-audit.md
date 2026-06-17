# Repository Baseline Audit

## 1. Super-root and authority model

Observed current state:
- `/.octon/` is the single authoritative super-root.
- Top-level class roots are `framework/`, `instance/`, `inputs/`, `state/`, and `generated/`.
- Only `framework/**` and `instance/**` are authored authority.
- `state/**` is split into `state/continuity/**`, `state/evidence/**`, and `state/control/**`.
- `generated/**` is rebuildable only.

## 2. Constitutional kernel and umbrella architecture

Observed current state:
- repo-local supreme control regime lives under `/.octon/framework/constitution/**`
- the umbrella architecture contract remains `/.octon/framework/cognition/_meta/architecture/specification.md`
- the contract registry already activates objective, authority, runtime, assurance, disclosure, adapter, and retention families

## 3. Execution model

Observed current state:
- the workspace charter explicitly states that every consequential run must bind the workspace charter pair and a per-run contract
- the charter and README explicitly say runs, not missions, are the atomic consequential execution unit
- the engine-owned authorization boundary is already live

## 4. Support-target and adapter model

Observed current state:
- the support universe is declared in `instance/governance/support-targets.yml`
- governance exclusions are explicit
- capability pack governance and runtime admissions are already live
- the admitted shell pack already requires instruction-layer-manifest evidence

## 5. Runtime / capability surfaces adjacent to this packet

Observed current state:
- `instruction-layer-manifest-v2.schema.json` already exists
- repo-local `tool-output-budgets.yml` already exists under the enabled `instance-agency-runtime` overlay point
- execution request / grant / receipt schemas already exist
- repo-shell execution classes already exist
- framework capability packs and repo-local admissions already exist
- assurance scripts and a blocking architecture-conformance workflow already exist

## 6. Proposal packet convention observed

Observed current state:
- the active architecture proposal root currently contains `octon_bounded_uec_proposal_packet`
- that packet uses a README plus numbered markdown artifacts and a `resources/` subtree
- the live repo does not expose proposal-manifest sidecars in that active packet
- this packet therefore follows the higher-precedence prompt requirement for manifest-governed packet files while still remaining compatible with the repo’s current “packet as markdown set” style
