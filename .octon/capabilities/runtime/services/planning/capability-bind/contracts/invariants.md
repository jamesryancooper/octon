# Capability Bind Invariants

1. A valid `command` is required (`bind` or `validate`).
2. `plan` input requires either inline JSON or `planPath` and is always treated deterministically.
3. Capability resolution is stable for identical payloads.
4. `result` must include `stepBindings`, `capabilityCatalog`, and `bindingSummary`.
5. Missing capability capabilities appear as unsupported and are reported explicitly.
6. Validate mode fail-closes on unsupported required capabilities.
