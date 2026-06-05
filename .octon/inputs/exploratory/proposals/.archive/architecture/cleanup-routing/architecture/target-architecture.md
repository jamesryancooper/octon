# Target Architecture

Lifecycle and closeout wrappers classify local run-state residue separately.
When cleanup is eligible, they delegate to `repo-hygiene-cleanup` with fresh
cleanup authority and retained receipts.

Wrappers may not:

- delete residue directly;
- treat cleanup classification as cleanup authorization;
- publish local-private residue;
- delete referenced evidence, active control state, or manual-review residue.
