# Extension Governance

This surface governs Packet 8 additive extension-pack boundaries.

## Canonical Rules

- Downloaded, unreviewed, or route-undecided additive intake units are governed
  by `../inputs/additive/incoming-intake-processing.md` and live only under
  `inputs/additive/.incoming/<intake-id>/` until classified.
- Normalized raw extension packs live only under
  `inputs/additive/extensions/<pack-id>/`.
- Rejected, superseded, historical, or quarantined additive intake copies live
  only under `inputs/additive/.archive/<intake-id>/` when retained before or
  after classification.
- Desired repo-owned activation lives only in `instance/extensions.yml`.
- Actual active state and quarantine truth live only under
  `state/control/extensions/**`.
- Runtime-facing extension consumption reads only
  `generated/effective/extensions/**`.
- Raw pack paths and incoming intake paths must never become direct runtime or
  policy dependencies.

## Ownership Model

Use this ownership split across all extension artifact types:

- **Extension-owned raw artifacts**
  Content authored inside a normalized pack under
  `inputs/additive/extensions/<pack-id>/` such as commands, skills, prompts,
  templates, context docs, validation docs, extension-local fixtures, and
  extension-local validation tests.
- **Framework-owned extension system artifacts**
  Generic publication, validation, routing, projection, discovery, and
  portability machinery that must continue to work even when a specific
  extension is absent.
- **Framework-owned generated extension outputs**
  Rebuildable runtime-facing publication artifacts under
  `generated/effective/extensions/**`.
- **Repo-owned control artifacts**
  Desired activation and live extension control truth under
  `instance/extensions.yml` and `state/control/extensions/**`.

Rules:

- If an artifact exists only to validate or support one specific extension, it
  should live in that extension unless it must be executed from a framework
  discovery point.
- If an artifact validates reusable extension-system behavior, it stays in
  framework surfaces even when it uses a specific extension as a fixture.
- Extension-local scripts and tests are allowed as additive pack content, but
  they remain non-authoritative and must not become implicit runtime
  dependencies.

## Subcontracts

- `boundary-contract.md`
- `../inputs/additive/incoming-intake-processing.md`
- `trust-and-compatibility.md`
