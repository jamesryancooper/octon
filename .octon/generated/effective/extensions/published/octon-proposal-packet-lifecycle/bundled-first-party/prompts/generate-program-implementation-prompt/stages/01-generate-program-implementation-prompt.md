# Generate Program Implementation Prompt

Re-read the parent and every child packet, validate child packets before use,
respect each child promotion target, follow the declared sequence or parallel
grouping, record child-level and program-level evidence, and stop when a child
packet is stale or blocked.

The generated prompt must identify the parent-owned coordination work, each
child-owned implementation target, allowed parallel groups, handoff gates,
shared generated/runtime surfaces, validation commands, evidence outputs, and
terminal criteria. It may coordinate child packets but must not collapse child
authority into the parent or broaden a child packet beyond its manifests unless
the parent sequence explicitly requires one coordinated changeset.
