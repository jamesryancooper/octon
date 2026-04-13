# Task: Run Repo-Shell Supported Scenario

## Context

Use this to exercise the admitted repo-shell supported scenario without
widening support claims. The scenario remains bounded to the existing
repo-shell support envelope and must retain proof as evidence rather than as
proposal-only text.

## Failure Conditions

- The authored repo-shell supported scenario is missing from the scenario
  registry.
- Repo-shell execution classes block the intended scenario commands or paths.
- Required proof or publication outputs cannot be retained under canonical
  evidence roots.

## Flow

1. Confirm authored scenario
   - Read `/.octon/framework/lab/scenarios/registry.yml`.
   - Load
     `/.octon/framework/lab/scenarios/packs/repo-shell/repo-shell-supported-scenario.yml`.
2. Confirm bounded envelope
   - Use the admitted repo-shell observe-and-read tuple only.
   - Confirm no new host adapter, model adapter, or capability pack is
     required.
3. Exercise the supported scenario
   - Run the repo-shell commands and path interactions needed to prove the
     supported scenario under canonical repo boundaries.
   - Preserve classifier and support-envelope facts through canonical retained
     receipts rather than ad hoc shell output.
4. Retain proof
   - Emit scenario proof and replay linkage under `state/evidence/lab/**`.
   - Emit a short operator summary citing `supported-scenario-proof` when the
     scenario degrades or fails.

## Required Outcome

- One retained repo-shell supported-scenario proof bundle that is usable
  without proposal-local artifacts.
