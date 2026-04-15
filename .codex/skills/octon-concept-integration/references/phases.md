# Phases

## Phase 1 - Route Bundle

- resolve the requested `bundle`, defaulting to
  `source-to-architecture-packet`
- normalize the bundle-specific primary input such as `source_artifact`,
  `source_artifacts`, `proposal_packet`, `repo_paths`, `subsystem_scope`, or
  `conflicting_kernel_rules`

## Phase 2 - Prompt Alignment Preflight

- use the selected bundle manifest plus `prompts/shared/**` as the family
  prompt contract
- otherwise proceed with the last aligned pack-local prompt revision

## Phase 3 - Execute Bundle

- execute the selected bundle's stages and companions
- materialize checkpoint and packet support artifacts according to the selected
  bundle manifest

## Phase 4 - Validate Outputs

- run the validator stack appropriate to the selected bundle
- retain run evidence and any residual blockers
