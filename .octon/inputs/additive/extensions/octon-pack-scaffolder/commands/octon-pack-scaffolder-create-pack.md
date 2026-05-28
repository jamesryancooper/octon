# Pack Scaffolder - Create Pack

Scaffold a new additive extension pack root under
`/.octon/inputs/additive/extensions/<pack-id>/`.

Default outputs:

- `pack.yml`
- `README.md`
- `commands/manifest.fragment.yml`
- `skills/manifest.fragment.yml`
- `skills/registry.fragment.yml`
- `context/overview.md`
- `validation/compatibility.yml`
- empty `templates/`, `prompts/`, `validation/scenarios/`, and
  `validation/tests/` directories

Behavior:

- create missing directories and files only
- keep existing compatible content intact
- fail closed on conflicting existing content
- do not edit `instance/extensions.yml` or publish the pack

See `context/output-shapes.md#create-pack` and
`context/examples/create-pack-minimal.md`.
