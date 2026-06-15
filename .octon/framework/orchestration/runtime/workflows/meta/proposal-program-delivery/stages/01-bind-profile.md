# Stage 01: Bind Profile

Validate the delivery profile with `validate-proposal-program-delivery-profile.sh` before any delivery claim.

Required checks:

- `release_state` and operator grant context are recorded in the run evidence when provided by the operator.
- `target_program_path` resolves to an accepted proposal program.
- `target_outcome` is one of the supported terminal outcomes.
- `pr_policy.mode: forbid-pr` rejects PR creation and PR fallback.
- `stash_policy.mode: forbidden` preserves unrelated work without hiding it in a stash.
- Non-authority boundaries classify proposal-local files, generated prompts, generated outputs, dashboards, chat, model memory, and host state as non-authoritative.
