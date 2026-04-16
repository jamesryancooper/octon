# Octon Pack Scaffolder

Dispatch explicitly to one `octon-pack-scaffolder` leaf target.

Dispatcher behavior:

- requires `--target`
- normalizes `--pack-id`
- performs no route inference
- forwards only the arguments relevant to the selected leaf scaffold

Use `--target pack|prompt-bundle|skill|command|context-doc|validation-fixture`
to select the leaf scaffold explicitly.

Supported targets:

- `pack`
- `prompt-bundle`
- `skill`
- `command`
- `context-doc`
- `validation-fixture`

Leaf commands:

- `/octon-pack-scaffolder-create-pack`
- `/octon-pack-scaffolder-create-prompt-bundle`
- `/octon-pack-scaffolder-create-skill`
- `/octon-pack-scaffolder-create-command`
- `/octon-pack-scaffolder-create-context-doc`
- `/octon-pack-scaffolder-create-validation-fixture`

Boundary:

- additive only
- create or update raw pack content under
  `/.octon/inputs/additive/extensions/<pack-id>/`
- do not activate, publish, quarantine, or govern the target pack

The source of truth for scaffolded output shapes is `context/output-shapes.md`.
