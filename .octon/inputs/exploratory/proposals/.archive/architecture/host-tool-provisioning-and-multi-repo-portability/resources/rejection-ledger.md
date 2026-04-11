# Rejection Ledger

| Rejected option | Why rejected | Replacement adopted |
| --- | --- | --- |
| Vendor third-party binaries directly under `/.octon/**` | Mixes host-specific artifacts into durable repo authority and harms portability. | Keep binaries in host-scoped Octon home. |
| Per-repo tool caches under repo `state/**` or `generated/**` | Duplicates binaries across repos and blurs repo versus host responsibility. | Use one host-scoped shared cache with repo-local desired requirements. |
| Make `/init` install host tools implicitly | Violates bootstrap boundary clarity and creates hidden host mutation. | Add explicit provisioning command. |
| Treat `/tmp` as the canonical cache | Ephemeral and machine-specific; unsuitable as steady-state architecture. | Use `$OCTON_HOME` with OS-default fallback. |
| One global mutable version per tool | Breaks multi-repo coexistence and deterministic per-repo resolution. | Side-by-side versioned installs keyed by tool id, version, and platform. |
