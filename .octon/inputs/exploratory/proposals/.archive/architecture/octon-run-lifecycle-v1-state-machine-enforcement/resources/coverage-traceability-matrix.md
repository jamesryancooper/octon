# Coverage Traceability Matrix

| Requirement | Current source | Gap | Proposed artifact | Validation |
|---|---|---|---|---|
| Canonical lifecycle states | `run-lifecycle-v1.md` | Not yet guaranteed executable | transition gate | state-table test |
| Canonical transition record | `run-journal-v1.md` | Needs reconstruction proof | reconstruction schema + validator | journal replay test |
| Derived runtime state | `run-lifecycle-v1.md`, `run-journal-v1.md` | Drift detection needed | reconstruction report | mismatch fixture |
| Authorization before running | `execution-authorization-v1.md` | State-specific binding required | transition precondition | missing-grant fixture |
| Context before authorization | `context-pack-builder-v1.md` | Resume/rebuild state handling needed | context-aware transitions | stale-context fixture |
| Token before material effects | `authorized-effect-token-v1.md` | Lifecycle-state check needed | state-aware token verification | token-outside-running fixture |
| Closeout evidence | `evidence-store-v1.md` | Blocking closeout gate needed | closeout validator | missing-evidence fixture |
| Support-target proof | `support-targets.yml` | Deterministic state reconstruction proof needed | retained assurance report | support proof fixture |
| Generated non-authority | umbrella spec | Need negative test | generated non-authority fixture | generated-state spoof fixture |
