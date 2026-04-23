# Coverage Traceability Matrix

| Requirement | Proposed artifact/change | Runtime/evidence implication | Validation |
|---|---|---|---|
| Every consequential Run has canonical journal | `run-event-ledger-v2`, runtime bus append path | `events.ndjson` under run control root | Journal integrity validator |
| Events are typed and causal | `run-event-v2` | Sequence, causal refs, actor refs, governing refs | Schema + lifecycle validator |
| Runtime state derives from journal | `runtime-state-v2`, reconstruction v2 | `runtime-state.yml` last-applied event and drift status | Reconstruction validator |
| Authorization cannot bypass journal | authorization-boundary update, authority engine emitters | authority events and GrantBundle refs in journal | Authorization coverage validator |
| Capability use is evidenced | capability event pairs | invocation events plus receipt/effect refs | Fixture and negative tests |
| Evidence matches control truth | evidence-store update | closeout snapshot/hash match | Evidence closeout validator |
| Operator views remain derived | operator-read-model update | generated views cite journal/evidence refs | Generated non-authority validator |
| Replay is safe | replay-store update | dry-run/sandbox default | Replay-safety validator |
| Support-target claims are honest | support-target admission update | no admitted tuple without journal proof | Support-target admission validator |
| Drift is detected | reconstruction v2 + drift events | ledger wins; drift incident evidence | Drift negative test |
