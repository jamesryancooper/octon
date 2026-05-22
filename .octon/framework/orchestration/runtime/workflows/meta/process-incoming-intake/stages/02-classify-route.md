# Classify Route

Apply the decision matrix in
`.octon/framework/engine/governance/inputs/additive/incoming-intake-processing.md`.

Select exactly one route:

1. **Additive extension pack**
   - choose when the intake unit is optional, selectable, portable,
     trust-gated, externally sourced, reusable outside core Octon, or already
     shaped as an `octon-extension-pack-v5`
   - required destination:
     `.octon/inputs/additive/extensions/<extension-pack-id>/`
2. **Core Octon skill**
   - choose only when the intake unit contains an always-on framework-owned
     foundation capability required by Octon itself
   - required destination:
     `.octon/framework/capabilities/runtime/skills/<family>/<skill-id>/`
3. **Blocked / proposal-required**
   - choose when ownership is ambiguous, provenance is missing, structure is
     invalid, trust posture is unsafe, schemas mismatch, installer instructions
     bypass Octon flows, or no existing contract fits
   - allowed retention:
     `.octon/inputs/additive/.archive/<intake-id>/`

Decision receipt requirements:

- selected route and rationale
- criteria that matched the selected route
- each rejected route and why it was rejected
- intake-envelope validator findings
- provenance, trust, compatibility, schema, ownership, risk, and support findings
- whether route execution requires human acknowledgement, proposal work, or
  blocked disposition

Treat these as classification findings, not normalized authority: missing,
partial, declared-only, or unverified provenance; route ambiguity; opaque
binaries; executables; secrets/private data; proprietary or redistribution-risk
material; oversized payloads; candidate extension packs; candidate core skills;
installer bypass instructions; unsupported schemas; and payloads that require a
new receiving contract.

If `stop_after_classification` is true, stop after this receipt, do not run the
mutation stage, and explicitly record that `.incoming/<intake-id>/` remains raw
intake because no final disposition was applied.
