# Execution Constitution Conformance Card

| Check | Status target | Evidence / surface |
|---|---|---|
| Super-root preserved | pass | no new top-level roots proposed |
| Authored authority remains only in `framework/**` and `instance/**` | pass | target file map |
| Existing run-centered execution model preserved | pass | no new control root proposed |
| Engine-owned authorization boundary preserved | pass | no bypass; request/grant/receipt refinement only |
| Generated truth not introduced | pass | no new generated family required |
| Proposal packet remains non-authoritative | pass | packet rooted in `inputs/exploratory/proposals/**` only |
| Support-target universe not widened | pass | no edits to support-target declarations required |
| Enabled overlay points respected | pass | instance-side edits confined to enabled governance / agency runtime overlays |
| Validator coverage present | required | new validator scripts + CI edits |
| Closure requires two clean passes | required | closure-certification-plan.md |

## Residual concerns to check during implementation

- emitter locations not yet named in this packet
- receipt/evidence sample generation must be proven in branch, not assumed
- fallback path is not acceptable unless the preferred path is shown unsafe
