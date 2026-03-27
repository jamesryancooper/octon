# Run Evidence

`state/evidence/runs/` stores retained operational run evidence and receipts.

Its mutable control-plane counterpart is
`state/control/execution/runs/`, which holds bound run contracts and
stage-attempt placement during the Wave 1 transition.

The directory is intentionally tracked so validators and fresh checkouts can
resolve the canonical state root even when no new run bundle is present yet.
