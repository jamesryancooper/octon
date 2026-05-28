# Pack Scaffolder - Create Validation Fixture

Scaffold a pack-local validation scenario fixture under
`/.octon/inputs/additive/extensions/<pack-id>/validation/scenarios/`.

Default outputs:

- `validation/scenarios/<fixture-id>.md`

Behavior:

- use scenario markdown rather than runtime state
- capture preconditions, invocation, and expected additive outputs
- keep publication, compatibility receipts, and quarantine behavior out of the
  fixture itself
- fail closed on conflicting existing content

See `context/output-shapes.md#create-validation-fixture` and
`context/examples/create-validation-fixture-minimal.md`.
