# Stage 01: Bind Profile

Validate the delivery profile with `validate-proposal-packet-delivery-profile.sh`
before any delivery claim.

Required checks:

- The requested command shape is `/proposal-packet-delivery outcome=cleaned
  route=branch-no-pr`.
- `target_packet_path` resolves to an accepted proposal packet.
- `target_outcome` is one of the supported terminal outcomes.
- `pr_policy.mode: forbid-pr` rejects PR creation and PR fallback.
- `packet_state_routing` declares pre-archive and already-archived packet
  state routes.
- `stash_policy.mode: forbidden` preserves unrelated work without hiding it in a stash.
- Non-authority boundaries classify proposal-local files, generated prompts,
  generated outputs, dashboards, chat, model memory, and host state as
  non-authoritative.
- Delivery remains aggregate-only and cannot replace target-owned packet
  receipts.
