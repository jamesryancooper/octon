# Capability Pack Route Handle v1

This contract defines the handle requirements for generated effective pack
routes.

## Requirements

- output and lock digests
- publication receipt linkage
- root-manifest digest
- support-target digest linkage
- governance/runtime registry digest linkage
- freshness mode and invalidation conditions
- allowed and forbidden consumers
- non-authority classification

## Runtime rule

Runtime may consume pack routes only through the verified handle path. The
compatibility projection under `instance/capabilities/runtime/packs/**` is
compatibility-only and never a runtime authority surface.
