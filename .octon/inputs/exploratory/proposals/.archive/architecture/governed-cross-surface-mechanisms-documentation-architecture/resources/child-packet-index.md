# Child Packet Index

_Status: Draft parent-program canonical child registry companion_

The YAML registry at `resources/child-packet-index.yml` is the structured
proposal-program registry. This Markdown file is navigation only.

The current registry posture is `canonical-child-packets`: entries below name
sibling child packet directories with child-owned `proposal.yml` manifests and
accepted child-owned proposal review receipts. Required children must still
pass child-owned readiness and lifecycle gates before implementation or
program closeout. The detail/operator-map child was previously optional and is
intentionally selected for this implementation run, so it is required here
while remaining child-owned.

| Child ID | Packet Status | Required For Program | Deferred | Phase | Depends On | Purpose |
| --- | --- | --- | --- | --- | --- | --- |
| `mechanism-index-foundation` | accepted | yes | no | `phase-1` | none | Create the architecture mechanism index, glossary, authority-class guide, and boundary guide skeleton. |
| `authority-class-schema-alignment` | accepted | yes | no | `phase-2` | `mechanism-index-foundation` | Align product catalog and mechanism index authority classes with the topology registry. |
| `mechanism-index-validator-guards` | accepted | yes | no | `phase-3` | `mechanism-index-foundation`, `authority-class-schema-alignment` | Add validators for path/class consistency and non-authority boundaries. |
| `product-doc-boundary-crosslinks` | accepted | yes | no | `phase-3` | `mechanism-index-foundation` | Link product docs to the architecture index while preserving product feature navigation-only posture. |
| `retired-terminology-guardrails` | accepted | yes | no | `phase-4` | `mechanism-index-validator-guards`, `product-doc-boundary-crosslinks` | Contain retired `Lifecycle Autopilot` language to compatibility or historical notes. |
| `mechanism-detail-pages-and-operator-map` | accepted | yes | no | `phase-5` | `mechanism-index-foundation`, `product-doc-boundary-crosslinks`, `retired-terminology-guardrails` | Selected detail pages and operator maps after the mandatory index and terminology guardrails are stable. |
| `program-closeout-coverage-evidence` | accepted | yes | no | `phase-6` | `authority-class-schema-alignment`, `mechanism-index-validator-guards`, `product-doc-boundary-crosslinks`, `retired-terminology-guardrails`, `mechanism-detail-pages-and-operator-map` | Verify aggregate coverage, validator posture, selected optional-child coverage, and closeout evidence. |

No child packet directory may be nested under this parent. The parent
coordinates sequence only and does not own child lifecycle truth.
