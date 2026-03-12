# PATCHPLAN

## Scope

Integrate the Assurance Charter as a first-class, enforced input in the Assurance Engine (historical alias: `QGE`) rooted at `/Users/jamesryancooper/Projects/harmony/.harmony/assurance/`.

## Incremental Plan

1. Baseline and preserve resolver semantics

- Keep precedence unchanged: `global -> run-mode -> subsystem -> maturity -> repo`.
- Keep two-file policy/measurement model (`weights.yml` + `scores.yml`).

1. Canonicalize Charter under Assurance governance root

- Add `/Users/jamesryancooper/Projects/harmony/.harmony/assurance/governance/CHARTER.md`.
- Update `/Users/jamesryancooper/Projects/harmony/.harmony/assurance/governance/README.md` with Charter-first Assurance Engine flow.

1. Make Charter machine-verifiable from policy

- Add `charter` contract block in `/Users/jamesryancooper/Projects/harmony/.harmony/assurance/governance/weights/weights.yml`:
  - `ref`, `version`, `priority_chain`, `tie_break_rule`, `tradeoff_rules`, `required_references`, `attribute_outcome_map`.
- Bump weights version and add changelog entry with ADR + `charter_ref`.

1. Wire Charter into resolver and outputs

- Extend Rust score command to load/validate Charter.
- Add Charter metadata and trade-off sections in generated outputs.
- Apply Charter priority chain as deterministic tie-breaker for top drivers.
- Emit tie-break conflict resolution records in outputs.

1. Wire Charter into enforcement

- Extend Rust gate command to:
  - hard fail on missing charter,
  - hard fail on charter/weights contract drift,
  - enforce version/changelog/ADR/charter_ref for charter/policy intent changes,
  - warn when top-driver tie-break ordering violates Charter chain,
  - warn on unjustified repo overrides that reduce top-priority Charter outcomes.

1. CI and local migration

- Update workflow path triggers and baseline extraction to include `CHARTER.md`.
- Pass `--charter` and `--baseline-charter` through gate invocation.

## Migration Steps (No Breakage)

1. Land Charter file and README references first.
2. Land weights `charter` contract + version/changelog/ADR.
3. Land resolver/gate code changes.
4. Land CI updates for charter baselines.
5. Run local score+gate with strict warnings using current files as baselines.
6. Monitor first PR run and then treat Charter checks as mandatory (already hard-fail configured).

## Completion Audit

- [x] Baseline semantics preserved (precedence unchanged; two-file model retained).
  - Evidence: `/Users/jamesryancooper/Projects/harmony/.harmony/engine/runtime/crates/assurance_tools/src/main.rs` (`build_effective_weights` applies `global -> run-mode -> subsystem -> maturity -> repo`).
- [x] Charter canonicalized at Assurance governance root and linked from the Assurance Engine entrypoint.
  - Evidence: `/Users/jamesryancooper/Projects/harmony/.harmony/assurance/governance/CHARTER.md`, `/Users/jamesryancooper/Projects/harmony/.harmony/assurance/governance/README.md`.
- [x] Charter contract made machine-verifiable in policy with governed changelog metadata.
  - Evidence: `/Users/jamesryancooper/Projects/harmony/.harmony/assurance/governance/weights/weights.yml` (`charter` block, `meta.version=1.3.0`, changelog entry with `adr` + `charter_ref`).
- [x] Resolver wired to load/validate Charter and emit charter-aware outputs.
  - Evidence: `/Users/jamesryancooper/Projects/harmony/.harmony/engine/runtime/crates/assurance_tools/src/main.rs` (`parse_charter_spec`, `parse_charter_doc`, `validate_charter_alignment`, charter sections in effective/results renderers).
- [x] Deterministic Charter tie-break behavior implemented for top drivers.
  - Evidence: `/Users/jamesryancooper/Projects/harmony/.harmony/engine/runtime/crates/assurance_tools/src/main.rs` (`charter_rank` sort tie-break, `detect_tie_break_resolutions`).
- [x] Gate enforcement extended with Charter hard-fail and warn checks.
  - Evidence: `/Users/jamesryancooper/Projects/harmony/.harmony/engine/runtime/crates/assurance_tools/src/main.rs` (missing charter, contract drift, changelog/ADR/charter_ref checks, tie-break warnings, charter-priority override warning).
- [x] CI/local migration wired for Charter baselines and args.
  - Evidence: `/Users/jamesryancooper/Projects/harmony/.github/workflows/assurance-weight-gates.yml`, `/Users/jamesryancooper/Projects/harmony/.harmony/assurance/runtime/_ops/scripts/alignment-check.sh`.
- [x] Local strict validation completed successfully.
  - Evidence: `compute-assurance-score.sh` + `assurance-gate.sh --strict-warnings` run with baselines: `status: PASS`, `hard-findings: 0`, `warn-findings: 0`.
- [ ] First PR workflow observation (operational follow-up).
  - Status: pending external PR event.
  - Scope: confirm `assurance-weight-gates` runs with repo baseline files in GitHub Actions and produces expected PASS/WARN/FAIL behavior.
