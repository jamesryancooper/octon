# Generate Correction Prompt

Use one stable finding id as the correction unit unless a finding group is
explicitly justified. Include affected paths, evidence, expected behavior,
correction scope, commands to run, acceptance criteria, and whether packet
revision or explicit deferral is required.

The correction prompt must preserve the original finding identity, explain the
minimum safe change, name any generated/runtime surfaces that must be refreshed,
and send the work back through verification after correction. It must not fold
unrelated findings into the fix, weaken acceptance criteria, create new durable
authority inside the proposal packet, or mark a finding deferred without owner,
rationale, and follow-up route.
