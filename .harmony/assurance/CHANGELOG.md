# Assurance Changelog

## 2.0.0 - 2026-02-19

### Breaking
- Replaced the legacy priority chain with the umbrella chain:
  `Assurance > Productivity > Integration`.
- Removed legacy chain semantics and old-chain output fields.
- Updated gate/report terminology to umbrella-first AE language.

### Migration
- Consumers parsing `charter_outcome` and `charter_rank` must use
  `umbrella` and `umbrella_rank`.
- Rebaseline generated assurance outputs and fixtures after upgrading.
