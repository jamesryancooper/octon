# Effective Capability Routing Outputs

`generated/effective/capabilities/**` is the only runtime-facing capability
routing publication family.

## Outputs

- `routing.effective.yml`
- `artifact-map.yml`
- `generation.lock.yml`
- `filesystem-snapshots/**` as non-authoritative support data only

## Rules

- Published routing is rebuildable and non-authoritative.
- Runtime and host integrations consume the routing triple, not raw capability
  inputs and not policy compiler intermediates.
- `routing.effective.yml` carries `routing_context`, deterministic
  `resolution_order`, selector metadata, fingerprint metadata, host adapter
  metadata, and scope relevance metadata for each candidate.
- Capability routing may publish with
  `publication_status: published_with_quarantine` when locality or extension
  inputs are coherent but degraded.
- `filesystem-snapshots/**` is support data only and not the canonical routing
  publication surface.
- Stale or invalid routing publication fails closed.
