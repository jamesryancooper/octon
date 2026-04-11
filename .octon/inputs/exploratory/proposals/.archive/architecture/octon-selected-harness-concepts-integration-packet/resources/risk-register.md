# Risk register

| Risk                                      | Level       | Failure mode                                                                          | Mitigation                                                                         |
| ----------------------------------------- | ----------- | ------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| Shadow memory via distillation            | Medium-High | Distillation outputs become runtime truth rather than proposal-gated evidence         | Keep distillation evidence-only until promoted; prohibit direct runtime dependency |
| Second review control plane               | Medium      | Findings/dispositions duplicated in comments or external systems                      | Make run-local control file canonical and treat comments as projections only       |
| Mission classification bureaucracy        | Medium      | Too many missions forced into proposal-first path                                     | Keep classification taxonomy small and tie it to material ambiguity/risk only      |
| Adapter over-thinning                     | Low-Medium  | Output envelope hides useful diagnostic detail                                        | Offload raw payloads to evidence and keep recoverability mandatory                 |
| Packet convention drift confusion         | Medium      | Requested manifest-governed packet mistaken for current repo-native packet convention | Carry explicit drift note in packet and do not claim convention already exists     |
| Schema proliferation                      | Medium      | New contracts multiply without consolidation                                          | Prefer extending assurance/objective/agency surfaces already present               |
| False closure on already-covered concepts | Low         | Existing coverage under-credited or accidentally duplicated                           | Mark already-covered concepts explicitly and exclude from implementation motion    |
| Constitutional regression                 | Critical    | Any change introduces shadow authority or bypasses authorization                      | Use conformance card and fail-closed validation                                    |
