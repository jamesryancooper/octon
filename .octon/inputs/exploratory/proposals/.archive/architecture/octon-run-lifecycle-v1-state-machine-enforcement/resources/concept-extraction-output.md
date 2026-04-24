# Concept Extraction Output

## Extracted core concept

**Run Lifecycle v1 enforcement**: The Governed Agent Runtime must implement a fail-closed lifecycle state machine for consequential Runs, using the canonical Run Journal as transition authority and `runtime-state.yml` as a derived materialized view.

## Extracted supporting concepts

| Concept | Implementation implication |
|---|---|
| Event-sourced runtime | Lifecycle state reconstructs from journal. |
| Resumable state machine | Pause/resume/revoke/fail/rollback/close are explicit transitions. |
| Authorized effect gating | Material side effects require valid lifecycle state and effect token. |
| Context-aware authorization | Bind/authorize/resume validate context-pack evidence. |
| Evidence-backed closeout | `closed` is blocked until evidence-store completeness is proven. |
| Operator visibility | Runtime-state and read models mirror journal-derived lifecycle state. |
| Fail-closed transition handling | Missing required facts deny transitions, not warn-only. |
| Support-target proofing | Lifecycle reconstruction evidence supports admitted tuple claims. |

## Excluded extracted concepts

- New support-target admissions.
- Full Mission scheduler redesign.
- Browser/API action model.
- Memory governor.
- Multi-agent orchestration.
- Broad workflow engine replacement.
