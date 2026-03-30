# Supported Envelope Positive

- fixture: `supported-envelope-positive`
- tuple: `MT-B / WT-2 / LT-REF / LOC-EN`
- adapters: `repo-shell` + `repo-local-governed`
- retained run contract:
  `/.octon/state/control/execution/runs/run-wave3-runtime-bridge-20260327/run-contract.yml`
- retained run manifest:
  `/.octon/state/control/execution/runs/run-wave3-runtime-bridge-20260327/run-manifest.yml`
- retained RunCard:
  `/.octon/state/evidence/disclosure/runs/run-wave3-runtime-bridge-20260327/run-card.yml`
- retained decision artifact:
  `/.octon/state/evidence/control/execution/authority-decision-run-wave3-runtime-bridge-20260327.yml`

This retained supported-envelope fixture is the positive proof path for the
closure claim. The canonical closure validator binds its bundle requirements to
the run contract and RunCard schema rather than to a prose allowlist.

Result: PASS
