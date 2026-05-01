# Evidence Plan

## Required Evidence

Implementation must retain evidence for:

- proposal validation,
- extension pack contract validation,
- extension publication,
- extension-local tests,
- capability publication,
- host projection publication,
- generated prompt placement tests,
- lifecycle route scenario tests,
- follow-up verification output,
- correction loop output,
- closeout prompt output,
- PR check and review resolution state,
- proposal promotion or archival.

## Evidence Locations

Use existing Octon evidence roots:

- `.octon/state/evidence/validation/**`
- `.octon/state/evidence/runs/skills/**`
- `.octon/state/evidence/runs/workflows/**`
- `.octon/state/control/skills/checkpoints/**` when resumable lifecycle loops require checkpoints

Do not store evidence in `generated/**`.
Do not treat proposal-local support prompts as evidence of implementation.
