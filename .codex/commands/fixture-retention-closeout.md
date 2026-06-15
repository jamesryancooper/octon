# /fixture-retention-closeout

Run the evidence-only fixture retention closeout workflow for a temporary implemented proposal fixture.

```text
/fixture-retention-closeout fixture_path=<proposal-fixture-path> owner_scope=<repair-or-change-scope> evidence_refs=<csv> [purpose=<purpose>]
```

The route emits a workflow-owned `fixture-retention-closeout-receipt-v1` receipt. It does not archive packets, mutate proposal status, edit generated publications, mutate Git, delete residue, or authorize repo-hygiene cleanup.
