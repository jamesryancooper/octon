# Evidence Plan

## Live control evidence

During active execution, the live control journal is:

```text
.octon/state/control/execution/runs/<run-id>/events.ndjson
.octon/state/control/execution/runs/<run-id>/events.manifest.yml
```

These are control truth, not generated projections.

## Retained closeout evidence

At Run closeout, the runtime must retain:

```text
.octon/state/evidence/runs/<run-id>/run-journal/events.snapshot.ndjson
.octon/state/evidence/runs/<run-id>/run-journal/events.manifest.snapshot.yml
.octon/state/evidence/runs/<run-id>/closeout.yml
```

The closeout record must include:

- control journal path,
- evidence snapshot path,
- first/last event IDs,
- event count,
- final event hash,
- schema versions,
- redaction refs,
- validator refs,
- disclosure refs.

## Event evidence classes

| Event class | Required refs |
|---|---|
| Context | context pack ref, source refs, hash. |
| Authority | execution request, GrantBundle/denial, policy receipt. |
| Approval | approval artifact, actor, expiry, scope. |
| Capability | capability pack, lease, invocation target, receipt. |
| Checkpoint | checkpoint artifact, rollback posture. |
| Rollback/recovery | rollback plan, recovery receipt, post-validation. |
| Operator | operator action, digest/disclosure ref, non-authority classification. |
| Assurance | validator name, version, result, evidence root. |

## Evidence retention rules

1. Do not store secrets in generated views.
2. If evidence is redacted, retain redaction lineage and original storage policy.
3. Evidence snapshots must not become live control truth after closeout.
4. Generated summaries must cite evidence roots and freshness.
5. Lab regression promotion must copy or reference evidence without mutating the
   original Run Journal.
