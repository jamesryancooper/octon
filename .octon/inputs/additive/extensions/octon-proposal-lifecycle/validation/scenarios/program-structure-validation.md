# Program Structure Validation

Given a parent proposal program, the program structure validator checks
parent-only coordination structure before implementation, promotion,
verification prompt generation, closeout prompt generation, closeout, or
archive workflow entry.

It requires parent `proposal.yml`, `resources/child-packet-index.yml`,
`resources/child-packet-index.md`, `architecture/packet-sequence.md`,
`architecture/child-packet-contract.md`, and
`architecture/program-closeout-plan.md`. Child ids in `related_proposals`, the
YAML registry, the human index, and packet sequence must agree.

It fails on unsafe child paths, child packets nested under the parent program,
missing parent coordination files, mismatched child ids, dangling dependencies,
or parent-owned child authority surfaces such as child validation verdicts or
child archive metadata.

When children declare write scopes, the same validator computes a canonical
child/dependency/write-scope projection digest and the complete cross-child
collision set. Literal equality collides. A directory prefix collides only
when the prefix declaration ends in `/`; lexical siblings such as `host/` and
`hosted.yml` remain independent.

Positive scenarios cover:

- no collision with the ledger omitted or represented by a fresh empty ledger;
- one exact collision;
- a directory-prefix collision in either argument order;
- dependency serialization justified by transitive reachability; and
- two DAG peers serialized by an explicit exclusive integration lock, even
  when registry enumeration is the reverse of the declared order.

Negative scenarios fail before any runnable batch or dispatch when the ledger
is missing, stale, malformed, incomplete, duplicated, reversed, or contains an
extra non-collision. They also reject unknown children or scopes, self-pairs,
noncanonical participants, the wrong collision kind, missing or nonparticipant
integration ownership, empty or overlong contributions, missing or duplicate
ordered participants, dependency order without matching reachability, a lock
between dependency-related children, and a cycle in the combined dependency
and serialization graph.

The Rust controller repeats the digest, collision, ownership, ordering, and
cycle checks with typed unknown-field rejection. Its tests additionally prove
deserialize/clone/serialize preservation, non-projection mutation
preservation, projection-changing mutation denial without a valid replacement
ledger, component-aware prefix behavior, deterministic ordering, and zero
dispatch for invalid ledger state. Child-focused planning is subject to the
same shell and typed-runtime gates as whole-program planning.
