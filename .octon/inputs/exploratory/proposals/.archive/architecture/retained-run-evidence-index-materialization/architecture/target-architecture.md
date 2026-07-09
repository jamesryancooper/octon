# Target Architecture

Add one canonical assurance script:

- `.octon/framework/assurance/runtime/_ops/scripts/generate-retained-run-evidence-index.sh`

The script materializes a retained evidence bundle for one implemented proposal
packet:

- `.octon/state/evidence/runs/<run-id>/retained-run-evidence-index.yml`
- `.octon/state/evidence/runs/<run-id>/validation/result.yml`
- `.octon/state/evidence/runs/<run-id>/rollback/rollback.md`
- `.octon/state/evidence/runs/<run-id>/source-manifest.yml`
- `.octon/state/evidence/runs/workflows/<run-id>/retained-run-evidence-index-materialization.yml`

The index uses `direct_control_refs_present: false` unless direct lifecycle
control refs exist. When direct control refs are absent, it binds the
materialization receipt as retained workflow evidence and records the child
packet receipts as proposal-local source refs. The retained validation result
and rollback note are digest-bound retained evidence refs.

The authority boundary stays explicit:

- the index replaces no source evidence;
- the index authorizes no execution;
- the index satisfies no lifecycle transition authority;
- the index satisfies no child receipts;
- proposal-local refs remain non-authoritative;
- generated outputs remain derived-only.

The materializer must fail closed when the child packet is not implemented,
required child support receipts are missing, receipt verdicts are not `pass`,
source refs are missing, or an existing index would become digest-stale.
