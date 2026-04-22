# Runtime Effective Handle Resolution v1

This contract defines how Octon resolves runtime-facing generated/effective
artifacts through a generic verifier rather than bespoke family-specific path
reads.

## Canonical API

The runtime resolver must expose a generic entrypoint equivalent to:

```text
verify_runtime_effective_handle(kind, output_ref, expected_consumer)
```

The verifier may derive `output_ref` from the runtime-resolution selector when
the caller requests a canonical kind.

## Resolution steps

1. Resolve the authored runtime-resolution selector.
2. Resolve the output and lock refs for the requested kind.
3. Verify output presence and lock presence when required.
4. Verify publication receipt presence, digest, generation id, and status.
5. Verify source digests against current authored or retained sources.
6. Verify freshness mode and invalidation conditions.
7. Verify allowed-consumer and forbidden-consumer posture.
8. Verify non-authority classification.
9. Verify dependency handles when the family declares them.

## Supported kinds

- `runtime_route_bundle`
- `pack_routes`
- `support_matrix`
- `extension_catalog`
- `extension_generation_lock`
- `capability_routing`

## Support-matrix posture

`support_matrix` may be one of two legal states:

- direct runtime handle with an explicit lock and consumer posture; or
- route-bundle-publication-only, where runtime may not consume it directly and
  only the route-bundle publication flow may depend on it.

The selector must make that posture explicit.

## Failure behavior

Resolution fails closed when:

- the requested kind is missing from the selector;
- the output or lock is missing;
- the receipt is missing or drifted;
- source digests drift;
- the consumer is forbidden;
- freshness is invalid; or
- a required dependency handle fails.
