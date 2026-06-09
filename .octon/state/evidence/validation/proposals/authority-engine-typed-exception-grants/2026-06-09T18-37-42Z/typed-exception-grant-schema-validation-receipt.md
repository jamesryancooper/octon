# Typed Exception Grant Schema Validation Receipt

verdict: pass
recorded_at: 2026-06-09T18:37:42Z
proposal_id: authority-engine-typed-exception-grants

## Schema Coverage

- `approval-request-v1.schema.json` defines `typed_exception_boundary`, `authority_provenance_refs`, and a non-authority guard for generated-output and read-model authority sources.
- `approval-grant-v1.schema.json` defines `typed_exception_boundary`, `authority_provenance_refs`, `grant_consumption_mode`, `revocation_behavior`, and `exception_reason`.
- `grant-bundle-v2.schema.json` defines `grant_consumption` with `mints_fresh_authority: false`.

## Typed Boundary Vocabulary

- `scope-expansion`
- `policy-override`
- `unresolved-risk-acceptance`
- `governance-mutation`
- `contradictory-evidence-resolution`
- `stale-evidence-acceptance`
- `authority-ambiguity`
- `unsafe-resume`
- `external-irreversible-effect`

## Checks

- `jq empty` over the three authority schema files: pass.
- `test-authority-engine-typed-exception-grants.sh`: pass.

## Artifact Hashes

- `approval-request-v1.schema.json`: `sha256:27fce7ab8012e0bba1b13d7a91e14dd83fbc3db3072aa416101b108f16d5cb3c`
- `approval-grant-v1.schema.json`: `sha256:0192d1ffb600015f3136c439a8b6303cadb085d53b0a723fbecfbbcc273274d8`
- `grant-bundle-v2.schema.json`: `sha256:c53871cc7d70625dac2e7fe7d430a8fec9fdbf085592efd0202636c577f21085`

## Boundary Result

The schema layer now exposes typed human exception grants and delegated grant consumption without allowing generated outputs, read models, route shape, workflow shape, extension shape, adapter shape, or generic importance to derive approval authority.
