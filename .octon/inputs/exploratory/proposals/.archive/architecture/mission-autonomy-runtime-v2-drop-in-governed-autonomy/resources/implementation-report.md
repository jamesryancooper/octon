# Implementation Report

## Summary

Mission Autonomy Runtime v2 has been promoted into durable Octon surfaces. The
runtime can open a mission from a v1 Engagement, create an Autonomy Window,
lease, budget, breakers, Mission Queue, Mission Run Ledger, mission evidence
profile, continuity state, Continuation Decisions, mission-aware Decision
Requests, stage-only connector admissions, and run-contract candidates.

## Durable authorities added

- `framework/engine/runtime/spec/*`: v2 runtime contracts.
- `framework/constitution/contracts/**`: constitutional mirrors.
- `instance/governance/policies/*`: mission continuation, autonomy window,
  connector admission, and mission closeout policy.
- `instance/orchestration/missions/**`: mission charter v2 authority.

## Operational truth and evidence added

- `state/control/execution/missions/**`: mission operational truth.
- `state/evidence/control/execution/missions/**`: mission retained proof.
- `state/continuity/repo/missions/**`: mission resumable context, not authority.

## Live validation artifacts

- Mission: `mission-autonomy-v2-validation`
- Engagement: `engagement-compiler-v1-validation`
- Mission control: `/.octon/state/control/execution/missions/mission-autonomy-v2-validation/**`
- Mission evidence: `/.octon/state/evidence/control/execution/missions/mission-autonomy-v2-validation/**`
- Mission continuity: `/.octon/state/continuity/repo/missions/mission-autonomy-v2-validation/**`
- Run candidate: `/.octon/state/control/execution/missions/mission-autonomy-v2-validation/run-candidates/mission-autonomy-v2-validation-run-1/run-contract.candidate.yml`

## Validation

- `cargo check -p octon_kernel --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml`: pass.
- `cargo test -p octon_kernel ... cli_parses_`: pass, 17 tests.
- `validate-mission-autonomy-runtime-v2.sh --mission-id mission-autonomy-v2-validation --cli-help /tmp/octon-help.txt`: pass.
- `test-mission-autonomy-runtime-v2.sh --mission-id mission-autonomy-v2-validation --cli-help /tmp/octon-help.txt`: pass.
- `validate-mission-source-of-truth.sh`: pass.
- `validate-mission-charter-bindings.sh`: pass.
- `validate-mission-runtime-contracts.sh`: pass.
- `validate-mission-control-state.sh`: pass.
- `validate-engagement-work-package-compiler.sh --work-package ... --cli-help /tmp/octon-arm-help.txt`: pass.

Full `cargo test -p octon_kernel` remains blocked by pre-existing generated
effective route bundle digest drift (`FCR-025`, root manifest / pack routes root
manifest digest drift). The same fail-closed drift blocks the optional
`octon mission continue --start-run` prepare-only path after candidate
materialization.

## Boundaries preserved

- Mission Queue does not replace run lifecycle.
- Continuation Decisions do not authorize execution.
- Mission Run Ledger does not replace per-run journals.
- Autonomy Window does not grant execution authority.
- Generated projections remain non-authoritative.
- `inputs/**` is not a runtime or policy authority source for v2.
- Live effectful connector admission remains blocked in v2 MVP.
