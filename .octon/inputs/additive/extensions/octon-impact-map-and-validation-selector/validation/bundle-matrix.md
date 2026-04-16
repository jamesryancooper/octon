# Validation Bundle Matrix

| Route | Minimum credible validation floor | Default next step |
| --- | --- | --- |
| `touched-paths` | path-classified subset of extension publication, authoritative-doc trigger, proposal validator, repo-hygiene, or harness audit surfaces | route determined by the selected floor |
| `proposal-packet` | `validate-proposal-standard.sh` plus the packet-kind validator | `/octon-concept-integration-packet-refresh-and-supersession` |
| `refactor-target` | `/refactor` plus any extra validators implied by affected surfaces | `/refactor` |
| `mixed-inputs` | touched-path floor first, then coherent packet or refactor extras only when they still match observed paths | packet refresh, `/refactor`, or clarification |
