# Current-State Gap Map

| Current state | Gap | Required change |
|---|---|---|
| `protected-ci auto-merge` uses ambient `gh` and covers merge only | Cannot satisfy RP-00 secret isolation, full cutover, no-resend, or retirement | Add an exact owner-lane executor; leave auto-merge compatibility unchanged |
| GitHub host adapter is a non-authoritative projection | No trusted provider executor exists | Keep the adapter non-authoritative; consume runtime authority directly |
| Connector live effects are denied | A connector admission would create the wrong abstraction and a bootstrap loop | Do not use or widen the connector system |
| Credential policy defers self-provisioning and privileged writes | No typed one-shot lifecycle exists | Add strict lifecycle contracts and require separate exact provider authority |
| `ProtectedCiCheck` is the only GitHub-adjacent effect kind | Ruleset/workflow/ref/PR mutations are semantically broader | Add `ProviderRepositoryMutation` with its own verifier and inventory row |
| Program child is classified `missing-evidence` | Human provider authority cannot be recorded canonically | Add a narrow provider-authority approval blocker classification |
| RP-00 protocol exists only in proposal prose and validators | No executable consumer can enforce it | Implement Rust validation/execution plus hermetic fault tests |
| Live GitHub tuple is documented as protected-CI merge only | Owner-lane effects would exceed admitted proof | Expand the same tuple only after retained exact-operation runtime proof and keep general API surfaces excluded |
