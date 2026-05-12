# Generate Program Implementation Prompt

Re-read the parent and every child packet, then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package <program-packet-path>
```

Stop unless the validator passes. The gate must pass before a program-level
implementation prompt is generated; it checks required non-deferred child
metadata including `change_profile`, child-owned implementation-grade
completeness reviews, accepted fresh proposal-review digests, declared
packet-specific completeness requirements, predecessor/successor coherence, and
cutover readiness constraints.

Respect each child promotion target, follow the declared sequence or parallel
grouping, record child-level and program-level evidence, and stop when a child
packet is stale or blocked.

The generated prompt must identify the parent-owned coordination work, each
child-owned implementation target, allowed parallel groups, handoff gates,
shared generated/runtime surfaces, validation commands, evidence outputs, and
terminal criteria. It may coordinate child packets but must not collapse child
authority into the parent or broaden a child packet beyond its manifests unless
the parent sequence explicitly requires one coordinated changeset.

Proposal readiness is permission to generate implementation prompts, not
evidence that implementation has completed. Do not require implementation
receipts, promoted durable contracts, schemas, validators, fixtures, or
canonical runtime support to already exist unless a child packet explicitly
claims they already exist.
