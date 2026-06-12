# Native Architectural Review Mechanism

This parent proposal program coordinates the child packets required to create a
native Architectural Review Mechanism in Octon. It does not implement the
mechanism directly.

The target mechanism makes architecture review a native governed capability:
workflows are canonical execution contracts, receipts and schemas carry gate
truth, validators fail closed, retained evidence is mode-specific, and skills
or commands remain thin invocation surfaces. The program also preserves the
extension split: `octon-concept-integration` continues to own source intake,
concept extraction, synthesis, source-to-packet generation, and the Architecture
Revision Packet packetization helper, while native Octon owns architectural
review doctrine, schemas, workflows, validators, evidence contracts, and
lifecycle integration.

## Fixed Decisions

- Pre-Integration Architecture Review is mandatory for every architecture
  proposal before acceptance or implementation authorization.
- Native review uses workflows and skills, with workflows as authority and
  skills as thin invocation surfaces.
- `architecture-readiness-audit` is the canonical slug; differently named
  permanent aliases are retired after a bounded migration window.
- Strict support receipt schemas are created and validated before lifecycle gate
  wiring.

## Child Packets

The sibling child packets are listed in `resources/child-packet-index.yml` and
described in `resources/child-packet-index.md`. Each child owns its own
manifest, promotion targets, receipts, evidence plan, rollback posture, and
validation plan.

The parent cannot satisfy child receipts, promote child targets, or authorize
closeout.
