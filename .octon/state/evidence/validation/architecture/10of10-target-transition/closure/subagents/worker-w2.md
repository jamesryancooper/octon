# Worker W2

- Upgraded packet-aligned validator surfaces only under `framework/assurance/runtime/_ops/scripts/**`.
- Added machine-readable validator result emission plus achieved-depth aggregation in `validate-architecture-health.sh`.
- Added the packet-named tests `test-runtime-effective-handle-negative-controls.sh`, `test-material-side-effect-token-bypass-denials.sh`, `test-architecture-health-depth.sh`, and `test-proof-bundle-execution.sh`, while keeping the older handle-test filename as a shim.
- Forward-compatible contract recognition now accepts newer target-state naming where present for runtime-effective handles, freshness, executable proof, operator read models, and compatibility retirement.
- Assumption: authorized-effect token enforcement remains dormant unless token metadata or the token contract is present; current repo passing behavior stays intact until the runtime/spec surfaces land.
