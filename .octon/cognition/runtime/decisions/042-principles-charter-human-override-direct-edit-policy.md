# ADR 042: Principles Charter Human-Override Direct-Edit Policy

- Date: 2026-02-24
- Status: Accepted
- Deciders: Octon maintainers
- Supersedes (policy portions):
  - `020-principles-charter-successor-v2026-02-20`
  - `040-principles-charter-successor-v2026-02-24`
  - `041-principles-major-framing-human-override-contract`
- Related:
  - `/.octon/cognition/governance/principles/principles.md`
  - `/.octon/cognition/governance/principles/README.md`
  - `/.octon/cognition/governance/principles/index.yml`
  - `/.octon/cognition/_ops/principles/scripts/lint-principles-governance.sh`
  - `/.octon/agency/governance/CONSTITUTION.md`
  - `/AGENTS.md`

## Context

Prior governance contracts and lint enforcement treated
`/.octon/cognition/governance/principles/principles.md` as immutable with a
hard no-edit posture and checksum lock. The active charter now declares
`change_policy: human-override-only` and requires explicit human override
metadata for major framing-shift exceptions.

To remove contradictory guidance, policy, contracts, and lint enforcement must
align to the same direct-edit rule: direct edits are allowed only when explicit
human override instructions are provided and required override evidence is
recorded.

## Decision

Adopt human-override-controlled direct editing for the authoritative principles
charter.

Rules:

1. Default evolution path remains versioned successor + ADR.
2. Direct edits to `principles.md` are permitted only with explicit human
   override instructions.
3. Major framing-shift overrides require explicit evidence in the charter:
   rationale, responsible owner, review date, override scope, review/agreement
   evidence, and intentional non-automated exception log reference.
4. Automation may propose framing changes but must not approve or apply major
   framing-shift overrides.
5. Governance lint must enforce change-control invariants and override-evidence
   requirements, not fixed immutable checksum pinning.
6. Active governance discovery surfaces must point to `principles.md`; retire
   successor-file references from active policy indexes.

## Consequences

### Benefits

- Aligns governance contracts and enforcement with the active charter policy.
- Preserves default safety through successor-based evolution while enabling
  explicit human-authorized direct corrections.
- Removes false-positive lint failures caused by checksum immutability locks.
- Simplifies policy discovery around a single authoritative charter file.

### Costs

- Requires stricter operator discipline to ensure explicit override evidence is
  complete whenever direct edits are made.
- Introduces governance overhead for documenting override provenance.

## Notes

- Historical ADR records remain append-only; this ADR controls forward policy
  interpretation when prior records conflict with `human-override-only`.
