# Child Packet Contract

Each child packet remains a sibling proposal package and owns its lifecycle
truth. The parent may reference child coordinates, sequence, dependencies, and
aggregate closeout status, but it must not write child validation verdicts,
child archive metadata, child receipts, child promotion targets, child terminal
outcomes, or child implementation truth.

Each required child must provide:

- `change_profile: atomic`;
- a bounded write scope;
- explicit evidence gates and retained receipts;
- rollback or compensation posture;
- generated/read-model non-authority language;
- implementation-grade completeness review;
- accepted proposal review with implementation prompt authorization.

No child may treat the parent, generated projections, dashboards, external
systems, tool availability, or agent output as authority.
