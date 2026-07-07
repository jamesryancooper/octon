# Packet Sequence

The program runs sequentially so the operator command surface is based on stable route visibility and delivery admission semantics.

| Order | Child | Gate |
| --- | --- | --- |
| 1 | `proposal-program-route-graph-preview` | Define visible plan output before adding a one-command wrapper. |
| 2 | `proposal-architecture-review-route-visibility` | Add architecture-review visibility into the route graph. |
| 3 | `proposal-delivery-admission-input-simplification` | Clarify delivery admission inputs after route graph vocabulary is stable. |
| 4 | `proposal-clean-delivery-command-surface` | Add the command surface after visible planning and input binding are clear. |
| 5 | `proposal-lifecycle-host-projection-normalization` | Normalize host projection names and support declarations before final doc alignment. |
| 6 | `proposal-lifecycle-route-naming-and-doc-alignment` | Align docs and names against accepted command, projection, and route graph behavior. |
| 7 | `proposal-clean-delivery-regression-fixtures` | Add full clean-delivery fixtures after the accepted route shape is known. |

No sequence step authorizes a child lifecycle transition by itself. Each child must pass its own review, implementation, validation, closeout, archive, cleanup, and terminal proof gates.
