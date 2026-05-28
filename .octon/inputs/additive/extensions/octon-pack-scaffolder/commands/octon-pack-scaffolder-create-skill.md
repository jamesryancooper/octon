# Pack Scaffolder - Create Skill

Scaffold a pack-local skill and wire it into the pack-local discovery
fragments.

Default outputs:

- `skills/<skill-id>/SKILL.md`
- `skills/<skill-id>/references/phases.md`
- `skills/<skill-id>/references/io-contract.md`
- `skills/<skill-id>/references/validation.md`
- new entries in `skills/manifest.fragment.yml`
- new entries in `skills/registry.fragment.yml`

Behavior:

- use `group: extensions`
- use `skill_class: invocable`
- register `/skill-id` in the pack-local registry fragment
- insert new entries in lexical id order
- fail closed on conflicting existing content

See `context/output-shapes.md#create-skill` and
`context/examples/create-skill-minimal.md`.
