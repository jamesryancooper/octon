# Validation Plan

## Validation model

Validation for this proposal has two layers:

1. **proposal-packet validation** — proves the packet itself is manifest-
   governed, reviewable, and archive-ready;
2. **target-architecture validation** — proves the implemented capability
   family is structurally wired, evidence-producing, and safe to use.

Both layers matter. A correct architecture packet is not enough if the future
implementation lacks evidence hooks, and a future implementation would not be
trustworthy if the packet buried gaps or mixed authorities.

## Validation families

### Family A — proposal packet conformance

Validate:

- `proposal.yml`
- `architecture-proposal.yml`
- required navigation files
- required architecture working docs
- artifact inventory completeness
- checksum generation

Expected evidence:

- valid manifests
- packet file inventory
- review-ready reading order

### Family B — structural governance validation

Validate that the landed `.octon/**` surfaces remain consistent with the live
repo's authority and build-to-delete model.

Required checks after implementation:

- `validate-repo-hygiene-governance.sh`
- updated `validate-phase7-build-to-delete-institutionalization.sh`
- updated `validate-global-retirement-closure.sh`
- existing architecture-conformance workflow invocation

### Family C — detector stack validation

The detector stack must be demonstrably Rust + Shell native and bounded:

- `cargo check --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml --workspace --all-targets --all-features`
- `cargo clippy --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml --workspace --all-targets --all-features --message-format short -- -W dead_code -W unused_imports -W unused_variables`
- `(cd .octon/framework/engine/runtime/crates && cargo machete)`
- `(cd .octon/framework/engine/runtime/crates && cargo +nightly udeps --workspace --all-targets --all-features)` on slower audit paths
- `git ls-files`
- `find`
- `rg`
- `shellcheck -x`
- `bash -n` / `sh -n`

These checks do not by themselves authorize deletion. They feed classification.

### Family D — retirement and ablation validation

Any delete/demote/retain/register outcome that touches transitional,
historical, or claim-adjacent surfaces must reconcile against:

- retirement policy
- retirement registry and register
- drift review
- retirement review
- support-target review when posture could widen
- adapter review when adapter-backed or disclosure surfaces are touched
- ablation-driven deletion workflow

### Family E — closure and recertification validation

Closure-grade claims for this capability require:

- repo-hygiene findings attached to the active build-to-delete packet;
- claim-gate-compatible status for any relevant non-retired targets;
- two consecutive clean validation passes on unchanged authoritative surfaces.

## Validator / check inventory

| Validator / check | Purpose | When required |
| --- | --- | --- |
| proposal-standard validation | packet manifest and lifecycle correctness | before packet handoff |
| architecture-proposal validation | required architecture files exist and parse | before packet handoff |
| `validate-repo-hygiene-governance.sh` | structural linkage of policy, command, validators, workflows | every implementation change |
| `validate-phase7-build-to-delete-institutionalization.sh` | ensure hygiene surfaces are part of the build-to-delete spine | every implementation change |
| `validate-global-retirement-closure.sh` | closure packet contains hygiene attachment and no unresolved blockers | closure-grade changes |
| architecture-conformance workflow | repo-wide structural correctness | every PR touching relevant surfaces |
| repo-hygiene fast enforce workflow | changed-scope hygiene blocking path | PRs touching relevant surfaces |
| repo-hygiene scheduled audit workflow | full audit and evidence emission | scheduled / manual runs |
| closure-certification workflow | dual-pass closure validation | release/closure claims |

## Required reports and evidence

The implementation must emit, at minimum:

- `audit-summary.yml`
- `findings.yml`
- `blocking-findings.yml`
- `summary.md`
- `repo-hygiene-findings.yml` when packetized into a build-to-delete review
  packet
- same-change retirement-registry and retirement-register updates when
  registration occurs

## Human review expectations

Human review is mandatory for:

- any contract or policy change;
- any classification rule that could affect delete safety;
- any proposal to treat a historical or claim-adjacent surface as deleteable;
- any attempt to widen packs, workload classes, or support claims.

## Dual-pass closure rule

When this proposal's target state is said to be closed or certified, the
implementation must show **two consecutive clean passes** across:

1. architecture conformance with the new hygiene validator active;
2. the repo-hygiene enforce/audit path;
3. closure certification with the global retirement closure validator active.

One clean pass demonstrates current correctness. Two consecutive clean passes
demonstrate that the capability is stable enough to certify.
