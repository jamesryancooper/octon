# Support Claim Truth Table

This table captures the support surfaces that Phase 1 must reconcile. It should
be regenerated from live artifacts during implementation.

## Observed high-value tuple mismatch

| Support tuple | Authored support target | Runtime route bundle | Capability-pack route bundle | Generated support matrix | Proposed reconciler result |
| --- | --- | --- | --- | --- | --- |
| repo-shell / observe-read / repo-local-governed / reference-owned / english-primary | live/admitted | allow/admitted-live | allow for repo/shell/telemetry | supported | reconciled live if proof fresh |
| repo-shell / repo-consequential / repo-local-governed / reference-owned / english-primary | live/admitted | allow/admitted-live | allow for repo/git/shell/telemetry | supported | reconciled live if proof fresh |
| ci-control-plane / observe-read / repo-local-governed / reference-owned / english-primary | live/admitted | allow/admitted-live | allow where applicable | supported | reconciled live if proof fresh |
| github-control-plane / repo-consequential / repo-local-governed / reference-owned / english-primary | live/admitted | stage-only/non-live | allow/admitted-live for packs | not supported/listed | **fail: inconsistent support posture** |
| repo-shell / boundary-sensitive | stage-only | stage-only | mixed or deny | not supported | staged, not live |
| frontier/studio/boundary-sensitive | stage-only or unadmitted | stage-only | deny/unadmitted | not supported | staged or unsupported |
| external irreversible/API/browser surfaces | unsupported/excluded unless separately admitted | deny/stage-only | deny/unadmitted | not supported | unsupported/excluded |

## Required reconciler output for mismatch

For the GitHub repo-consequential mismatch above, the reconciler should emit at
least:

- `route_stage_only_but_support_declares_live`
- `pack_route_widens_runtime_route`
- `generated_matrix_omits_declared_live_claim`
- `effective: blocked`
- `operator_action: reconcile support declaration, route bundle, pack routes, and proof before live claim`

## Publication rule

A support card or disclosure must not present the mismatched tuple as live until
the reconciler output is `reconciled` and retained evidence exists.
