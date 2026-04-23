# Assumptions and Blockers

## Assumptions

- The canonical append-only Run Journal is the prior sequencing step or active dependency.
- Existing `authorized_effects` and `authority_engine` crates are the intended runtime landing zones.
- Current live support universe remains bounded to repo-shell / CI-control-plane and repo-local governed execution.
- Proposal remains octon-internal and does not promote `.github/**` targets.
- The implementation branch can run local Rust and shell validators.

## Blockers

| Blocker | Resolution |
|---|---|
| Run Journal not promoted | Pause token lifecycle closure; continue inventory/schema work only. |
| Material API owners unknown | Phase 0 cannot exit until owners are identified. |
| No negative bypass test harness | Add harness before enforcing closure. |
| Cannot distinguish material vs read-only path | Use material inventory and fail closed for ambiguous paths. |
| CI cannot run validators automatically | Create linked repo-local CI wiring change. |
| Token constructor cannot be fully compile-time restricted across crates | Use ledger-backed verification and non-serializable verified guard. |
