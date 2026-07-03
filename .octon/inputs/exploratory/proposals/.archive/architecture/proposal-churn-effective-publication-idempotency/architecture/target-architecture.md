# Target Architecture

Effective publishers should compute source and output digests before writing,
then skip unchanged outputs while preserving publication receipts and freshness
metadata required by runtime consumers.

The target architecture preserves:

- source refs and digests;
- output and lock digests;
- publication receipt linkage;
- freshness mode;
- allowed and forbidden consumers;
- non-authority classification;
- resolver-verified handle access.
