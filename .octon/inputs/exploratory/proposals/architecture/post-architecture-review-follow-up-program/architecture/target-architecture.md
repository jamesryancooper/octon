# Target Architecture (Program Level)

The program's target state is coordination-complete, not implementation:
every registry child either closed through its own governed lifecycle,
superseded, rejected with rationale, or (F-10 only) recorded no-action.

Child-level target states are owned by the children and chartered in
`child-packet-contract.md`:

- `retained-evidence-operability-contract` → the `immutable://` store and
  retention lifecycle carry an accepted operational contract (F-03, F-06).
- `retirement-register-compatibility-refresh` → zero overdue compatibility
  reviews (F-04).
- `runtime-spec-directory-index` → spec directory carries a local index
  aligned with declared active versions (F-05).
- `continuity-coherence-validator` → pre-resumption coherence check defined
  and green (F-07).
- `historical-runcard-support-audit` → historical disclosure references
  audited or declared frozen-as-of-issuance (F-08).
- `evidence-classification-v2-migration` → one classification schema in use
  (F-09).
- `governance-quorum-revisit-trigger` → quorum revisit decided or no-action
  recorded (F-10).

Program-level invariants: no second control plane; children stay in declared
write scopes; parent evidence never substitutes for child evidence; the
sibling environment-override packet is untouched by this program.
