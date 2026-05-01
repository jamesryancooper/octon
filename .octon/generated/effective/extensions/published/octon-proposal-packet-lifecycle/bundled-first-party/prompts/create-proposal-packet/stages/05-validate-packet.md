# Validate Packet

Run the base proposal validator and the applicable subtype validator. If
proposal registry regeneration is unsafe because unrelated visible packets are
present, use the validator's registry-skip mode and record the reason.

Return `packet-created`, `needs-packet-revision`, or `blocked` with retained
finding ids and correction recommendations.
