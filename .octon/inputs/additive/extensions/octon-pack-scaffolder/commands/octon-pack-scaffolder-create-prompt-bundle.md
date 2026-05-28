# Pack Scaffolder - Create Prompt Bundle

Scaffold a minimal prompt bundle inside
`/.octon/inputs/additive/extensions/<pack-id>/prompts/<bundle-id>/`.

Default outputs:

- `pack.yml` updated to set `content_entrypoints.prompts: "prompts/"` when it
  is still `null`
- `prompts/<bundle-id>/README.md`
- `prompts/<bundle-id>/manifest.yml`
- `prompts/<bundle-id>/companions/01-align-bundle.md`
- `prompts/<bundle-id>/stages/01-<stage-id>.md`
- `prompts/<bundle-id>/references/bundle-contract.md`

Behavior:

- create the bundle only inside an additive extension pack
- keep the bundle manifest-governed and leaf-sized
- do not add prompt freshness routing or shared-reference machinery in MVP
- fail closed on conflicting existing content

See `context/output-shapes.md#create-prompt-bundle` and
`context/examples/create-prompt-bundle-minimal.md`.
