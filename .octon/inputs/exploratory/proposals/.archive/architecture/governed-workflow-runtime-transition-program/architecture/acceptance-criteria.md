# Acceptance Criteria

_Status: Draft parent-program acceptance criteria_

The parent program packet is acceptable when:

- `proposal.yml` declares a draft architecture proposal program with
  `lifecycle.temporary: true`.
- `resources/child-packet-index.yml` contains the seed/reference child, all
  required child candidates, and all deferred/lab-only candidates.
- Child packet directories are not nested under this parent.
- `architecture/packet-sequence.md` defines gated sequencing and blocks final
  migration/cutover until required child evidence exists.
- `architecture/child-packet-contract.md` preserves child-owned lifecycle truth.
- `architecture/program-closeout-plan.md` requires child-owned terminal receipts
  and aggregate evidence.
- `RISK-REGISTER.md` covers proposal sprawl, overclaiming, terminology drift,
  second-control-plane risk, validation gaps, and implementation-order hazards.
- `validation-plan.md` defines parent and aggregate validation gates.
- `deferred-and-rejected-scope.md` explicitly rejects Durable Objects, MCP, and
  external workflow engines as authority and keeps them deferred/lab-only as
  adapters.
- Targeted proposal and architecture validators pass.
