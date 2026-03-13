# Playbook Invariants

1. `playbookPath` is required.
2. Output always includes `status` and `playbook`.
3. Expansion is deterministic for identical inputs.
4. Invalid templates fail closed.
