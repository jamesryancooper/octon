# Validation Plan

## Existing Validators To Run

- lifecycle runner tests;
- lifecycle interaction receipt tests;
- context pack builder tests;
- publication freshness gate tests;
- run-health read-model tests;
- closeout worktree wrapper tests;
- closeout-change lifecycle alignment validation;
- proposal review gate validation;
- proposal registry validation;
- generated freshness validation;
- replay validation;
- rollback validation.

## New Validators Required

- prompt-pack capsule generation;
- stale capsule fail-closed behavior;
- evidence index generation;
- raw-log summary hash matching;
- failing-slice reconstruction;
- planner-state reconstruction;
- program-context capsule digest verification;
- blocker-ledger fingerprinting;
- validator-result manifest generation;
- generated freshness handle validation;
- model-routing receipt emission;
- token-budget ledger accounting;
- context-pack omission manifests;
- child-handoff capsule correctness;
- proposal program mock run;
- CI token regression thresholds.

## Negative Controls

- stale prompt capsule;
- stale generated freshness handle;
- raw proposal input accidentally treated as authority;
- generated registry replacing proposal manifest;
- missing child receipt;
- missing rollback evidence;
- missing context-pack hash;
- missing authorization receipt;
- model route bypass attempt;
- raw-log summary mismatch;
- blocker fingerprint drift.

## Acceptance

Validation passes only if token reductions are achieved without weakening evidence completeness, replay completeness, rollback posture, authorization, closeout correctness, archive correctness, proposal non-authority, or generated/read-model non-authority.
