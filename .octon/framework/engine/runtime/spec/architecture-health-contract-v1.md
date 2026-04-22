# Architecture Health Contract v1

This contract defines Octon's aggregate architecture health gate.

The health gate is closure-grade only when it proves, in one run, that:

- structural class-root and registry invariants hold
- authorization-boundary coverage remains fail-closed
- run lifecycle and evidence-store requirements remain complete
- support-target, dossier, and pack-admission alignment remains coherent
- generated/effective publication freshness remains current
- compatibility-retirement posture remains reviewable and bounded
- operator boot remains separate from branch/PR closeout policy

Canonical validator:

- `/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-health.sh`

Canonical operator entrypoint:

- `octon doctor --architecture`

The aggregate health gate may orchestrate narrower validators, but it must not
invent a second authority surface. Canonical facts remain in the underlying
authored contracts, control roots, retained evidence, and publication receipts.
