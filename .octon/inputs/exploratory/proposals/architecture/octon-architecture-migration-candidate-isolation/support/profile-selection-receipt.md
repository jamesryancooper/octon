# Profile Selection Receipt

- release_state: `pre-1.0`
- change_profile: `atomic`
- atomic_mode: `clean-break`
- selected_at: `2026-07-12`
- selected_by: `proposal packet authoring task`
- rationale: RP-02 establishes one clean candidate-execution boundary. A
  transitional profile would admit ambient and isolated execution, shared and
  independent Git, or readable and credentialless sessions as simultaneous
  supported routes, defeating FD-008 and making rollback unsafe.
- transitional_exception_note: `not applicable`
- authority_effect: none from packet creation
- runtime_effect: none from packet creation
- support_claim_effect: none from packet creation; future support is limited to
  the exact tuple that passes all positive and negative proof

Atomic does not mean one unreviewed deployment step. Preparation and
default-disabled proof may be staged, but admission switches only after the
complete useful-positive and escape-negative envelope passes. This receipt
does not authorize implementation, provider/session access, candidate launch,
Git export, or promotion.
