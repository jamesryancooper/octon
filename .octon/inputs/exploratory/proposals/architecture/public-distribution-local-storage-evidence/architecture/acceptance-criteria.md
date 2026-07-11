# Acceptance Criteria

## AC-01

Every enumerated storage-class root has one explicit default Git posture plus bounded exceptions. The enumeration must cover at minimum `.octon/state/` (including `.octon/state/evidence/` and operational runtime state), `.octon/generated/`, `.octon/inputs/` (with per-subtype posture for raw intake, archives, extension source, ideation, proposals, plans, syntheses, and reports), and repository host projections (`.claude/`, `.codex/`, `.cursor/`), plus logs, caches, archives, reports, and release artifacts.

## AC-02

All active shell and Rust evidence producers, storage/replay schemas,
consumers, validators, and tests use `local-private` for local custody,
calculate SHA-256 from actual retained bytes, and reject
`external-immutable` unless the referenced external object exists, the durable
locator resolves under the configured backend, and the object's actual digest
matches. A run identifier, local manifest digest, pointer digest, or
`immutable://`-shaped string is not sufficient proof.

## AC-03

A machine-readable downstream Git-posture contract requires state, evidence, generated output, logs, caches, and host projections to remain outside hosted Git by default while preserving required project authority and exact core lock.

## AC-04

Retention defaults implement disposable caches, 30-day successful routine evidence, 90-day resolved failure evidence, live-claim plus 90-day release and security evidence, and indefinite compact governance receipts.

## AC-05

High-value local evidence is covered by encrypted system backup and a disconnected encrypted backup with a successful restore receipt.

## AC-06

Compaction remains non-destructive candidate preparation; AI summaries cannot authorize deletion or claim equivalence to raw evidence.

## AC-07

The declared storage-class closure includes the active retention family and
README, replay and evidence classification schemas, evidence-store and
disclosure contracts, architecture registry, engine and lab specifications,
shell writer, Rust authority-engine producer and consumer, disclosure
validator, and their tests. A deterministic fixture matrix proves every
allowed class round-trips through each producer and consumer, rejects an
unsupported class, and detects any synthetic external object claim. The
implementation cannot close with an undeclared active producer or consumer.

## Aggregate Gate

All criteria above must pass on the exact reviewed implementation revision.
A general statement that tests pass is insufficient; evidence must identify
the behavior, boundary, negative case, and retained receipt.
