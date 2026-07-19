# Closeout Change Validation

Validation proves:

- the active route set excludes direct-main;
- generic closeout targets `preserved`;
- branch-no-PR remains classifiable but cannot authorize or perform landing;
- all landing and authorization helpers deny before mutation with
  `RP00_CONTAINMENT_PUBLICATION_DISABLED`;
- all cleanup helpers deny before mutation with
  `RP00_CONTAINMENT_CLEANUP_DISABLED`;
- dry-run cleanup inventories without changing refs or worktrees;
- exact candidate and rollback handles survive denial; and
- receipts cannot claim `cleaned`, `synced`, or publication success.

Run the targeted validators and their disposable direct-invocation tests. A
failed assertion yields a blocked preserved outcome.
