# Documentation Standards Starter Template

This bundle provides a stack-agnostic docs-as-code starter for new features,
components, and operational changes.

For canonical policy and usage guidance, see:

- `.octon/cognition/governance/principles/documentation-is-code.md`
- `.octon/scaffolding/runtime/templates/documentation-standards.md`

## Included Stubs

- `docs/specs/{{feature-name}}/spec.md` - specification one-pager
- `docs/specs/{{feature-name}}/adr-0001.md` - decision record
- `docs/specs/{{feature-name}}/bmad-story.md` - execution plan
- `docs/components/{{component-name}}/guide.md` - component/developer guide
- `docs/runbooks/{{feature-name}}.md` - operations runbook
- `packages/contracts/openapi.yaml` - API contract
- `packages/contracts/schemas/{{feature-name}}.schema.json` - payload schema

## How to Use

1. Rename `{{feature-name}}` and `{{component-name}}` placeholders.
2. Fill `spec.md` first, then author/update the ADR.
3. Define contracts in `packages/contracts/`.
4. Fill the feature story with an ordered implementation plan and tests.
5. Complete the component guide and runbook before rollout.
6. Keep docs updates in the same diff as behavior, contract, or operational
   changes.

## Notes

- Keep docs concise and implementation-linked.
- Include only sections that apply; remove empty placeholders.
- If a template section does not apply, write `Not applicable` with a short
  reason.
