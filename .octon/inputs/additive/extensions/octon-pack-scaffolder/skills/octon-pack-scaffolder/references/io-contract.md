# IO Contract

## Inputs

- `target` - required scaffold target selector
- `pack_id` - required additive extension pack id
- target-specific fields such as `bundle_id`, `skill_id`, `command_id`,
  `doc_id`, or `fixture_id`

## Outputs

- one scaffolded asset family under
  `/.octon/inputs/additive/extensions/<pack-id>/`
- a receipt covering created, reused, and blocked paths

## Source Of Truth

- `context/output-shapes.md`
- `context/examples/*.md`
