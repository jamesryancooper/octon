# Conformance Card

| Dimension | Selected posture |
| --- | --- |
| proposal id | `repository-hygiene-and-retirement` |
| proposal kind | `architecture` |
| architecture scope | `repo-architecture` |
| decision type | `new-surface` |
| release state | `pre-1.0` |
| change profile | `atomic` |
| official promotion scope | `octon-internal` |
| official promotion target family | `.octon/**` only |
| dependent implementation family | `.github/workflows/**` integrations |
| core governance strategy | extend existing retirement/build-to-delete spine |
| command strategy | repo-native command under `instance/capabilities/runtime/commands/**` |
| detector strategy | Rust + Shell native; no Ruff/Vulture translation |
| destructive-action posture | separated from detection; routed through existing ablation/review workflow |
| support posture | no widening of support targets or capability packs |
| closure burden | baseline audit + same-change registration + packet attachment + dual clean passes |

## Quick verdict

This packet is review-ready only if reviewers accept the active-scope split:
`.octon/**` promotion targets remain canonical and `.github/**` edits remain
explicit dependent integrations. That split is not a gap in the architecture;
it is the direct consequence of the live proposal standard.
