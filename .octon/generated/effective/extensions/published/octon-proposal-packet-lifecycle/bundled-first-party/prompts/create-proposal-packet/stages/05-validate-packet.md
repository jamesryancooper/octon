# Validate Packet

Run the base proposal validator and the applicable subtype validator. If
proposal registry regeneration is unsafe because unrelated visible packets are
present, use the validator's registry-skip mode and record the reason.

Also validate the packet against the selected scenario: source material is
preserved in `resources/**`; required artifact classes are present or explicitly
omitted with rationale; traceability connects findings, gaps, target-state
claims, implementation actions, validation, acceptance, and closure; durable
promotion targets stand outside the proposal path; and no generated, prompt,
GitHub, external-tool, or proposal-local surface is promoted as authority.

Return `packet-created`, `needs-packet-revision`, or `blocked` with retained
finding ids and correction recommendations.
