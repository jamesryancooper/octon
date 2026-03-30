# Lab Runtime

Lab runtime surfaces define the contracts used to record replay manifests,
scenario proof, and other retained behavioral evidence.

Canonical retained outputs live under `/.octon/state/evidence/lab/**` and
run-local replay roots under `/.octon/state/evidence/runs/<run-id>/replay/**`.

Reusable disclosure tooling lives under `runtime/_ops/scripts/`.

Active authored runtime contracts cover:

- replay manifests
- scenario proof
- shadow-run reports
- fault-rehearsal reports
- adversarial experiment reports

Replay manifests remain Class B Git-pointer artifacts. When a supported run
class requires external immutable replay payloads, the manifest must cite the
content-addressed index entry retained under `state/evidence/external-index/**`.
