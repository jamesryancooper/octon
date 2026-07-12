# Review Limitations (living document)

Recorded at review start; finalized in `synthesis/review-limitations.md`.

1. **Single-session review.** All evidence gathered in one reviewer session on
   2026-07-12 (UTC) against commit `c5b1f5760c78ff521cca6b054e4e8fef5300505b`.
2. **Sibling-review contamination controls.** No sibling directories existed
   under `.octon/inputs/exploratory/reviews/` at review start (verified
   empty). All repository searches by the primary architect and subagents were
   instructed to exclude `.octon/inputs/exploratory/reviews/**` except this
   directory. A persistent-memory hint from a prior session (concerning
   executor mediation) was present in the environment; it was treated as
   untrusted and re-derived independently — see provenance/source-register.yml.
3. **Provider observations are read-only and time-of-query.** GitHub state
   (rulesets, workflows, secrets metadata) can change after observation.
4. **Dynamic execution is bounded.** Test execution was limited to the
   repository's own test suites and short targeted commands; no long-running
   fault-injection campaigns were executed. Findings claiming
   DYNAMICALLY_EXECUTED or ADVERSARIALLY_TESTED cite the exact command run.
5. **Build cache mutation.** Compiling/running tests writes to the
   pre-existing gitignored `crates/target/` build cache. No tracked file
   outside this review directory was created, modified, or deleted.
6. **Intake sources partially normalized.** The intake unit itself records 13
   missing sources and normalized summaries for some long messages; this
   review treats intake claims as unverified until re-derived.
