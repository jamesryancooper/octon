# Existing Lifecycle Run Admission Fixtures

This fixture set defines the mandatory assurance matrix for the governed
`octon run bind-lifecycle` boundary. The cases are executed by the kernel test
module; this retained manifest prevents positive-only coverage or accidental
removal of fail-closed controls.

The fixture data is non-authoritative. Tests must construct checkpoint,
event-chain, delegation, target, rollback, and run-root artifacts through test
helpers and must exercise the owning runtime command.
