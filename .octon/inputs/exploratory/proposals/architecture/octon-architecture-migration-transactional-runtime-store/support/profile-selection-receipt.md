# Profile Selection Receipt

- release_state: `pre-1.0`
- change_profile: `atomic`
- atomic_mode: `clean-break`
- selected_at: `2026-07-12`
- selected_by: `proposal packet authoring task`
- rationale: RP-03 changes live runtime authority from split writable files and
  journal models to one SQLite/WAL epoch. A transitional profile permitting
  dual write, bidirectional projection, two normal writers, or file fallback
  would preserve the exact concurrency and resurrection hazards being removed.
- transitional_exception_note: `not applicable`
- authority_effect: none from packet creation
- runtime_effect: none from packet creation
- support_claim_effect: none from packet creation

Atomic permits offline import, read-only comparison, and default-disabled
proof. It requires one clean authority-epoch activation with no supported
dual-writer interval. This receipt does not authorize a dependency, database,
migration, cutover, effect, or promotion.
