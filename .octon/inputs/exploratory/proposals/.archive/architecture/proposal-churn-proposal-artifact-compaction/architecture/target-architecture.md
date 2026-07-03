# Target Architecture

Proposal generated output should be a stable projection over proposal lineage.

The target generator behavior:

- detects changed proposal inputs;
- preserves stable registry ordering;
- emits artifact indexes and spines only for changed packets;
- treats archived proposal records as retained input lineage;
- skips unchanged output writes;
- validates generated proposal views against current proposal manifests.
