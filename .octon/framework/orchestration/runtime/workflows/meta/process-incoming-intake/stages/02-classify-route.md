# Classify Route

Apply Governed Incoming Intake Routing from
`.octon/framework/engine/governance/inputs/additive/incoming-intake-processing.md`
and
`.octon/framework/engine/governance/inputs/additive/governed-incoming-intake-routing.md`.

Select exactly one route:

1. **`single-work-unit-handoff`**
   - choose for one coherent intent, one primary target surface, no child
     sequencing, no migration or cutover, no cross-surface dependency,
     reviewable provenance, and bounded validation
   - target owner: proposal packet lifecycle
2. **`coordinated-program-handoff`**
   - choose for multiple surfaces or candidate changes, dependency ordering,
     staged adoption, migration or cutover, governance plus runtime change, or
     child packet coordination
   - target owner: proposal program lifecycle
3. **`target-owned-direct-handoff`**
   - recognize only for future non-proposal targets with explicit target-owned
     intake admission contracts
   - deny in the current implementation when no such contract exists
4. **`blocked-rejected-deferred`**
   - choose when the intake is malformed, unsafe, ambiguous, unsupported,
     unverifiable, low-value, deferred, stale, scope-drifted, requested-route
     mismatched, or authority-confused

Decision receipt requirements:

- selected route and rationale
- criteria that matched the selected route
- each rejected route and why it was rejected
- intake-envelope validator findings
- provenance, trust, compatibility, schema, ownership, risk, and support findings
- envelope digest, payload inventory digest, replay input digest, and target
  handoff scope digest when applicable
- denial evidence for blocked or rejected routes
- whether route execution requires target-owned proposal packet/program
  admission, human acknowledgement, or blocked disposition

Treat these as classification findings, not normalized authority: missing,
partial, declared-only, or unverified provenance; route ambiguity; opaque
binaries; executables; secrets/private data; proprietary or redistribution-risk
material; oversized payloads; candidate extension packs; candidate core skills;
installer bypass instructions; unsupported schemas; and payloads that require a
new receiving contract.

The decision receipt must conform to
`governed-incoming-intake-route-decision-v1`.

`requested_route` is advisory only. If it disagrees with deterministic
classification, select `blocked-rejected-deferred` and record
`requested-route-mismatch` denial evidence.

If `stop_after_classification` is true, stop after this receipt, do not run the
handoff stage, and explicitly record that `.incoming/<intake-id>/` remains raw
intake because no final disposition was applied.
