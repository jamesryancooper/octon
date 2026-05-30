# Acceptance Criteria

_Status: In-review parent-program acceptance criteria_

The parent program packet is acceptable when:

- `proposal.yml` declares an architecture proposal program with
  `lifecycle.temporary: true`; revision routes keep it `in-review` until a
  later parent review accepts or rejects it.
- `resources/child-packet-index.yml` contains all required child packet
  references as canonical sibling paths.
- Child packet directories are not nested under this parent.
- `architecture/packet-sequence.md` defines gated sequencing and blocks residue
  migration until required child evidence exists.
- `architecture/child-packet-contract.md` preserves child-owned lifecycle
  truth.
- `architecture/program-closeout-plan.md` requires child-owned terminal
  receipts and aggregate evidence.
- `RISK-REGISTER.md` covers evidence leakage, vague receipts, local-only
  tracking, hosted closeout dependence on local artifacts, generated authority
  drift, `.octon/state/evidence/.gitignore` scoping, and migration hazards.
- `validation-plan.md` defines parent and aggregate validation gates.
- `support/program-creation.md` records parent-local creation evidence with
  `child_authority_preserved: yes`.
- Targeted proposal and program structure validators pass.

The parent is implementation-prompt-ready only when its implementation-grade
completeness receipt passes with no unresolved questions, required child state
passes live child-readiness validation, and a fresh accepted parent review
authorizes implementation prompt generation. Existing parent support prompts
are operational aids only and must not encode or override current review-gate
authorization.
