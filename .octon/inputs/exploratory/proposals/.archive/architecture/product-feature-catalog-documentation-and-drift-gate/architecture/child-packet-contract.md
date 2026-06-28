# Child Packet Contract

Each child packet remains an independently valid proposal packet at its own
active path. The parent program may sequence, summarize, and coordinate child
work, but it must not satisfy child validation, child implementation evidence,
child promotion targets, child archive metadata, child terminal outcomes, or
child receipts.

Every child must preserve these boundaries:

- proposal paths are non-authoritative;
- generated outputs are derived-only;
- retained evidence proves checks occurred but does not authorize execution;
- product feature catalog entries remain navigation-only;
- the closeout gate may recommend or block but may not rewrite docs without an
  explicit implementation route.
