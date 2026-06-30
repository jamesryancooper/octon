# Packet Sequence

The program runs sequentially so later operator-facing surfaces can mirror earlier canonical contract decisions.

| Order | Child | Gate |
| --- | --- | --- |
| 1 | `proposal-delivery-input-contract-alignment` | Align canonical required inputs before projection or alias work. |
| 2 | `proposal-program-delivery-operator-alias` | Add the optional alias after canonical input semantics are stable. |
| 3 | `proposal-program-delivery-host-projections` | Publish or correct host projections after the input contract and alias source are stable. |
| 4 | `proposal-program-review-loop-documentation` | Document intentional program review/revision asymmetry before regression hardening. |
| 5 | `proposal-lifecycle-surface-validation-hardening` | Encode coherence checks after the target surface set is defined. |

No sequence step authorizes a child lifecycle transition by itself. Each child must pass its own review, implementation, validation, closeout, archive, cleanup, and terminal proof gates.
