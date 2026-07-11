---
disclosure_status: externally-shareable-after-maintainer-review
authority_mode: non-authoritative
external_transmission_approved: false
---

# Downstream Installation And Update Model

## Default Delivery

**Sponsor decision:** Downstream projects commit an exact core lock instead of
committing a framework snapshot by default.

The lock identifies:

- version and source release;
- source commit;
- artifact SHA-256;
- export manifest digest;
- accepted provenance or attestation identity;
- compatibility metadata.

## Installation

1. Resolve the exact release or explicit local artifact.
2. Verify checksum, manifest, provenance policy, archive safety, and
   compatibility.
3. Cache by digest in machine-local storage.
4. Materialize core-owned paths.
5. Initialize only absent project-owned roots from neutral templates and
   explicit user input.
6. Generate local state, effective output, evidence roots, and host projections.
7. Record a compact verification receipt; do not commit automatically.

## Update Transaction

1. Resolve and verify the candidate.
2. Produce a dry-run file and ownership diff.
3. Check instance compatibility.
4. Hash all project-owned paths.
5. Stage the complete candidate.
6. Journal each transition.
7. Replace only core-owned paths.
8. Verify the active core.
9. Recheck project-owned hashes.
10. Write the new lock last.

## Recovery And Rollback

The previous verified core and lock remain available until completion.
Interruption at any journal point recovers idempotently to one complete old or
new state. If that cannot be proven, automation stops with a bounded manual
recovery plan.

## Alternatives

Vendored committed core is a documented exception for air-gapped or
policy-constrained adopters. Git submodules, subtrees, and mutable remote
dependencies are not the default.

External architect question: Is local materialization with a committed lock
operationally simpler than vendoring across the promised platforms and offline
constraints?

Sources: `SRC-010`, `SRC-011`, `SRC-014`, `SRC-015`, and
`SRC-018`.

