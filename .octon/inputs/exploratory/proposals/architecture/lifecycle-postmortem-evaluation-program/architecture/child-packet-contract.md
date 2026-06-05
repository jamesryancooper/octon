# Child Packet Contract

Each child packet is a sibling architecture proposal packet. The parent may
coordinate sequencing, dependencies, and aggregate closeout posture only.

Child packets must own:

- their `proposal.yml` lifecycle state;
- their `architecture-proposal.yml` subtype contract;
- their promotion targets;
- their implementation-grade receipt;
- their implementation evidence;
- their conformance and drift/churn receipts after implementation;
- their validation evidence;
- their closeout and archive evidence.

Parent evidence may summarize child outcomes but cannot satisfy child-owned
receipts, validation verdicts, promotion evidence, or archive metadata.

All children must preserve these boundaries:

- generated outputs remain derived-only;
- raw inputs remain non-authoritative;
- postmortem reports remain evidence only;
- invariant evaluation remains evidence only but must classify constitutional
  violations as blocking or corrective findings when the rating requires it;
- Unknown invariant ratings are evidence gaps and cannot be counted as Pass;
- invariant validity and evolution review remains evidence only and may only
  recommend governance, proposal, or amendment candidates;
- invariant change recommendations must not mutate invariant authority,
  weaken fail-closed behavior, approve redesign, or alter support claims
  without a separate governed route;
- review findings require separate dispositions before they become blocking
  run-control semantics;
- redesign recommendations require a separate proposal, evolution, or
  governance route before implementation.
