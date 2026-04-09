# Validation

Validation path:

1. generate the successor release bundle
2. regenerate disclosure and closure projections from the successor release
3. run packet-specific hardening validators
4. rerun core disclosure, parity, and recertification validators

Current local status:

- successor release bundle regenerated for
  `2026-04-09-uec-hardening-recertification`
- packet-specific hardening validator sweep completed green
- disclosure, parity, and recertification checks completed green
- lineage promotion to the successor release is in progress

