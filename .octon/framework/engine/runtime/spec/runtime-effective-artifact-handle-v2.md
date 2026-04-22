# Runtime Effective Artifact Handle v2

This contract defines the recursive resolver-verified handle model for
runtime-facing generated/effective artifacts.

## Purpose

Generated/effective outputs remain derived non-authority. Runtime may consume
them only through a handle that proves provenance, freshness, consumer posture,
and dependency-handle closure.

## Supported artifact kinds

- `runtime_route_bundle`
- `pack_routes`
- `support_matrix`
- `extension_catalog`
- `extension_generation_lock`
- `capability_routing`

## Recursive verification model

- Every runtime-facing generated/effective family must resolve through this
  handle contract.
- A handle may declare `dependency_handle_refs` when its trust depends on other
  runtime-effective handles.
- Route-bundle verification must fail closed when any required dependency
  handle drifts, becomes stale, is missing, or is forbidden to the requesting
  consumer.
- Support-matrix handles may narrow route-bundle publication, but they never
  widen support claims and may be declared publication-only by the
  runtime-resolution selector.

## Required handle fields

- `schema_version`
- `artifact_kind`
- `generation_id`
- `output_ref`
- `output_sha256`
- `lock_ref` when the family has a lock
- `lock_sha256` when the family has a lock
- `publication_receipt_ref`
- `publication_receipt_sha256`
- `source_refs`
- `source_digests`
- `freshness.mode`
- `freshness.invalidation_conditions`
- `allowed_consumers`
- `forbidden_consumers`
- `non_authority_classification`
- `dependency_handle_refs` when the artifact depends on other runtime-effective
  handles

Each `dependency_handle_refs` entry must declare:

- `artifact_kind`
- `output_ref`
- `lock_ref` when the dependency family has a lock
- `requirement`
- `purpose`

## Freshness modes

- `digest_bound`
  Trust is valid only while the declared source digests remain equal to the
  live source digests.
- `ttl_bound`
  Trust is valid only while the declared TTL window remains open.
- `receipt_bound`
  Trust is valid only while the linked publication receipt remains current for
  the referenced generation.

Legacy timestamp fields do not satisfy v2 freshness. Compatibility timestamps
may be retained only as explicitly ignored metadata under
`publication-freshness-gates-v4.md`.

## Consumer rules

- Runtime may consume `generated/effective/**` only through this handle model.
- Validators may use the handle model to prove freshness, provenance, and
  dependency closure.
- Operators may inspect handle metadata, but that inspection remains
  non-authoritative.
- Generated cognition read models, proposal packets, raw inputs, and
  compatibility projections are never valid runtime-authority substitutes.

## Failure rules

Reject the handle when any of the following is true:

- the handle is missing
- source digests drift
- output or lock digest drifts
- publication receipt is missing, digest-drifted, or reports a different
  generation
- `non_authority_classification` is not `derived-runtime-handle`
- the caller is not in `allowed_consumers`
- the caller is in `forbidden_consumers`
- freshness-mode validation fails
- a required dependency handle is missing
- a required dependency handle fails its own verification

Canonical denial codes should map cleanly into runtime and retained evidence,
including:

- `RUNTIME_HANDLE_MISSING`
- `RUNTIME_HANDLE_OUTPUT_DIGEST_DRIFT`
- `RUNTIME_HANDLE_LOCK_DIGEST_DRIFT`
- `RUNTIME_HANDLE_SOURCE_DIGEST_DRIFT`
- `RUNTIME_HANDLE_RECEIPT_MISSING`
- `RUNTIME_HANDLE_RECEIPT_DIGEST_DRIFT`
- `RUNTIME_HANDLE_GENERATION_MISMATCH`
- `RUNTIME_HANDLE_FRESHNESS_INVALID`
- `RUNTIME_HANDLE_CONSUMER_FORBIDDEN`
- `RUNTIME_HANDLE_NON_AUTHORITY_CLASS_INVALID`

## Related contracts

- `/.octon/framework/engine/runtime/spec/runtime-resolution-v1.md`
- `/.octon/framework/engine/runtime/spec/runtime-effective-route-bundle-lock-v3.schema.json`
- `/.octon/framework/engine/runtime/spec/publication-freshness-gates-v4.md`
- `/.octon/framework/engine/runtime/spec/compatibility-retirement-cutover-v2.md`
