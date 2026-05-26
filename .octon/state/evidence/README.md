# State Evidence

`state/evidence/**` stores retained operational evidence.

## Canonical Evidence Classes

| Path | Purpose |
| --- | --- |
| `state/evidence/runs/**` | Run receipts, checkpoints, replay manifests, replay pointers, evidence classification, trace pointers, and retained execution evidence |
| `state/evidence/disclosure/**` | Canonical retained RunCard and HarnessCard disclosure evidence |
| `state/evidence/lab/**` | Retained scenario proof, benchmark measurements, evaluator reviews, and historical lab mirrors that support disclosure claims |
| `state/evidence/control/execution/**` | Retained authority decisions, grant bundles, and control-plane mutation evidence |
| `state/evidence/external-index/**` | Content-addressed indexes for replay-heavy or externally retained immutable evidence |
| `state/evidence/decisions/**` | Historical lineage and capability-policy decision logs that no longer mint live per-run authority |
| `state/evidence/validation/**` | Validation receipts and audit evidence |
| `state/evidence/migration/**` | Migration provenance and rollback traceability |
| `state/evidence/cleanup/**` | Local cleanup classifications and non-authorizing archive evidence for stash, run, control, generated, or evidence residue |

`state/evidence/validation/publication/**` is the canonical machine-readable
receipt family for locality, extension, and capability publication runs.

Evidence is append-oriented and retention-governed. It must not be treated as
active task state or rebuildable generated output.

Local stash archives under `state/evidence/cleanup/stash-archives/**` are
operator-local retained cleanup evidence and are ignored by Git by default.
They preserve review context for dropped stashes without making stale
generated, control, evidence, proposal-local, host-state, or lifecycle-event
residue current authority.

Packet evidence classes:

- `Class A`: Git-inline authored disclosures, approvals, decisions, and
  benchmark summaries
- `Class B`: Git-pointer manifests and pointer/index artifacts
- `Class C`: External immutable raw replay and trace payloads
