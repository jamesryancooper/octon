# Stage 01: Bind Profile

Validate the delivery profile with `validate-proposal-program-delivery-profile.sh` before any delivery claim.

Required checks:

- `release_state` and operator grant context are recorded in the run evidence when provided by the operator.
- `target_program_path` resolves to an accepted proposal program.
- `target_outcome` is `implemented` or `archive-ready` and `route=stage-only`;
  effectful and omitted/default requests fail with
  `RP00_CONTAINMENT_PUBLICATION_DISABLED`.
- The profile requires exact-work preservation and disables publication,
  Change-closeout delegation, final sync, and cleanup effects.
- Profile or workflow evidence records order policy, PR policy, stash policy, runner handoff refs when supplied, include-path classification state, and retained preflight refs.
- `execution_order_policy.canonical_order_ref: child-before-parent-delivery` is enforced before lifecycle continuation.
- Non-canonical requested order emits a retained warning/stop record and blocks continuation unless a schema-valid, target-bound, run-bound order override receipt is present.
- `pr_policy.mode: forbid-pr` rejects PR creation and PR fallback.
- `stash_policy.mode: forbidden` preserves unrelated work without hiding it in a stash.
- Runner handoff evidence is delivery input only; it does not satisfy child packet, archive, generated-publication, cleanup, Change, branch, final sync, or terminal proof gates.
- Non-authority boundaries classify proposal-local files, generated prompts, generated outputs, dashboards, chat, model memory, and host state as non-authoritative.
