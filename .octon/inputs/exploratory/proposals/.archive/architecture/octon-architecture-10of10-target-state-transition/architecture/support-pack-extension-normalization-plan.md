# Support, Pack, and Extension Normalization Plan

## Support target normalization

The target state adopts the partitioned claim-state model already declared by support governance:

- `support-target-admissions/live/**`
- `support-target-admissions/stage-only/**`
- `support-target-admissions/unadmitted/**`
- `support-target-admissions/retired/**`
- matching `support-dossiers/<partition>/**`

All refs in support targets, proof bundles, support cards, and generated/effective matrices must point
to the same canonical partitioned paths. Flat files may remain only as shims listed in the retirement
register.

## Capability pack normalization

Keep three semantic layers:

1. framework pack contract: `framework/capabilities/packs/**`
2. repo-owned governance intent: `instance/governance/capability-packs/**`
3. compiled runtime route: `generated/effective/capabilities/pack-routes.effective.yml`

The current `instance/capabilities/runtime/packs/**` root should not remain an authored-looking runtime
projection indefinitely. It should become either a compatibility projection with retirement criteria or
be replaced by generated/effective pack-route output.

## Extension lifecycle normalization

Current desired/active/quarantine/published shape is correct, but active state is over-expanded. Target:

- `instance/extensions.yml`: desired selection and trust policy
- `state/control/extensions/active.yml`: compact active generation pointers only
- `state/control/extensions/quarantine.yml`: quarantine records
- `generated/effective/extensions/**`: compiled published output
- `state/evidence/validation/publication/extensions/**`: publication receipts
- `state/evidence/validation/compatibility/extensions/**`: compatibility receipts

Large dependency closure, prompt anchor, required input, and source digest data moves to generation lock
and artifact map.
