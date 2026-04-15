# Source Artifact

## Validation Fixture

The current Octon extension publication model exposes `routing_exports` for
extension commands and skills, but it does not surface full extension skill
registry metadata as a first-class generated effective view.

Proposed concept:

- publish extension skill registry metadata into the effective extension family
  so extension composite skills are introspectable without rereading raw pack
  payloads.
