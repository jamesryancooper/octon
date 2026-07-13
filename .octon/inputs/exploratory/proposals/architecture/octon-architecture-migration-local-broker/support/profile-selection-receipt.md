# Profile Selection Receipt

- release_state: `pre-1.0`
- change_profile: `atomic`
- atomic_mode: `clean-break`
- selected_at: `2026-07-12`
- selected_by: `proposal packet authoring task`
- rationale: RP-04 introduces one credential and effect boundary and makes it
  the sole normal runtime-store writer. A transitional profile allowing
  ambient and Keychain credentials, direct and broker effects, two services,
  two writers, or old/new IPC identities as normal routes would defeat FD-006
  and make rollback/replay claims unsafe.
- transitional_exception_note: `not applicable`
- authority_effect: none from packet creation
- runtime_effect: none from packet creation
- support_claim_effect: none from packet creation

Atomic permits default-disabled installation, sentinel enrollment, diagnostic
identity proof, and disposable scratch testing. Admission changes only after
the whole credential/IPC/writer boundary passes. This receipt does not
authorize dependencies, service installation, credential enrollment, store
access, effect execution, or promotion.
