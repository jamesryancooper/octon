# Pack Scaffolder - Create Command

Scaffold a pack-local command markdown entry and wire it into the pack-local
commands manifest fragment.

Default outputs:

- `commands/<command-id>.md`
- a new entry in `commands/manifest.fragment.yml`

Behavior:

- use `access: agent`
- preserve lexical id order in the manifest fragment
- keep the command thin and delegate execution policy to the matching skill
  when one exists
- fail closed on conflicting existing content

See `context/output-shapes.md#create-command` and
`context/examples/create-command-minimal.md`.
