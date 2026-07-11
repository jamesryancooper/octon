# Acceptance Criteria

## AC-01

A committed `.octon/core.lock.yml` validates against
`.octon/framework/engine/runtime/spec/core-lock-v1.schema.json`, rejects
unknown fields, and identifies one exact release artifact, source commit,
artifact SHA-256, manifest digest, compatibility contract, and accepted
provenance identity. Canonical serialization yields the same lock digest on
all Tier 1 platforms. "Accepted provenance identity" is defined by the
`portable-component-clearance-v1` clearance contract (owned by
`public-distribution-portable-base-clearance`); this packet consumes that
definition and does not redefine it.

## AC-02

Install and verify work from both a verified release and an explicit local artifact file without modifying project-owned paths.

## AC-03

First initialization creates only absent neutral instance, ingress, state-root, generated-root, evidence-root, and host-projection inputs, with user choices stored outside framework-owned paths.

## AC-04

Update provides a complete dry-run diff, checks compatibility and ownership, stages and verifies before replacement, journals transitions, and writes the new lock last. Dry-run diff completeness means every add, modify, and delete relative to the lock manifest is listed, and nothing outside that set is listed.

## AC-05

Injected interruption at each transaction boundary recovers idempotently to a fully verified old or new core; rollback restores the old lock and core.

## AC-06

Linux x86-64, macOS ARM64, and Windows x86-64 pass install, update, interruption, and rollback tests or are explicitly demoted before release.

## Aggregate Gate

All criteria above must pass on the exact reviewed implementation revision.
A general statement that tests pass is insufficient; evidence must identify
the behavior, boundary, negative case, and retained receipt.
