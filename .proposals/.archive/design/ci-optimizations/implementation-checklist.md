# Octon CI Cost Optimization Checklist (Execution)

## Baseline + target

- [x] Create 30-day baseline report (run count, median duration, failure/cancel rate, billed-minutes proxy, event breakdown).
  - Command: `bash .proposals/ci-optimizations/scripts/collect-actions-baseline.sh --days 30`
  - Evidence: `.proposals/ci-optimizations/baseline/20260304T215613Z/workflow-summary.csv`, `.proposals/ci-optimizations/baseline/20260304T215613Z/event-summary.csv`, `.proposals/ci-optimizations/baseline/20260304T215613Z/summary.md`
  - Evidence: `.proposals/ci-optimizations/evidence/20260304T220013Z/baseline-capture-notes.md`
- [x] Set numeric target and latency guardrail.
  - Target: `>= 80%` reduction in Actions minutes over 30 days.
  - Guardrail: median required-check completion regression `<= 10%`.
  - Evidence: `.proposals/ci-optimizations/execution-plan.md` (`Goal / Outcome`, `Verification Plan`)

## Workflow edits

- [x] AI Gate event slimming in `.github/workflows/ai-review-gate.yml`.
  - Evidence: `.github/workflows/ai-review-gate.yml` (`jobs.changes`, `jobs.provider-findings.if`)
- [x] AI Gate path gating in `.github/workflows/ai-review-gate.yml`.
  - Evidence: `.github/workflows/ai-review-gate.yml` (`dorny/paths-filter` risk filter)
- [x] AI Gate artifact retention reduction in `.github/workflows/ai-review-gate.yml`.
  - Evidence: `.github/workflows/ai-review-gate.yml` (`retention-days: 3`, `retention-days: 7`)
- [x] Perf trigger scope narrowing in `.github/workflows/filesystem-interfaces-perf-regression.yml`.
  - Evidence: `.github/workflows/filesystem-interfaces-perf-regression.yml` (`.octon/engine/runtime/**` paths)
- [x] Rust/cargo caching and `cargo-component` install guard in `.github/workflows/filesystem-interfaces-perf-regression.yml`.
  - Evidence: `.github/workflows/filesystem-interfaces-perf-regression.yml` (`swatinem/rust-cache@v2`, guarded install block)
- [x] Perf artifact retention reduction in `.github/workflows/filesystem-interfaces-perf-regression.yml`.
  - Evidence: `.github/workflows/filesystem-interfaces-perf-regression.yml` (`retention-days: 7`, `retention-days: 3`)
- [x] Smoke de-duplication in `.github/workflows/smoke.yml` (schedule/manual only).
  - Evidence: `.github/workflows/smoke.yml` (`workflow_dispatch`, PR trigger/comment removal)
- [x] Concurrency standardization in required-check workflows:
  - `.github/workflows/pr-autonomy-policy.yml`
  - `.github/workflows/pr-quality.yml`
  - `.github/workflows/commit-and-branch-standards.yml`
  - Evidence: top-level `concurrency` blocks in all three files
- [x] Schedule cadence reduction:
  - `.github/workflows/pr-auto-merge.yml` (`*/15` -> hourly)
  - `.github/workflows/pr-clean-state-enforcer.yml` (`*/30` -> hourly)
  - Evidence: hourly cron (`0 * * * *`) in both files
- [x] Codex PR review risk/label gate in `.github/workflows/codex-pr-review.yml`.
  - Evidence: `.github/workflows/codex-pr-review.yml` (`jobs.changes`, label/risky gate in `codex-review.if`)
- [x] Timeout discipline updates on long-running workflows.
  - Evidence: timeout additions in `.github/workflows/ai-review-gate.yml`, `.github/workflows/filesystem-interfaces-perf-regression.yml`, `.github/workflows/pr-quality.yml`, `.github/workflows/commit-and-branch-standards.yml`, `.github/workflows/smoke.yml`, `.github/workflows/codex-pr-review.yml`
- [x] Billing-incident stale-context note in `.octon/agency/practices/github-autonomy-runbook.md`.
  - Evidence: troubleshooting note appended under `## Troubleshooting`

## Codification (future-proofing)

- [x] Add `.github/workflows/ci-efficiency-guard.yml` from `codification/ci-efficiency-guard.yml`.
  - Evidence: `.github/workflows/ci-efficiency-guard.yml`
- [x] Add `.github/scripts/ci-efficiency-guard.sh` from `codification/ci-efficiency-guard.sh`.
  - Evidence: `.github/scripts/ci-efficiency-guard.sh` (executable bit set)
- [ ] Add guard workflow as required check for PRs touching `.github/workflows/**`.
  - Pending: repository ruleset/branch-protection update outside source tree.
  - Precondition complete: guard workflow now runs on all PRs and no-ops when no workflow files changed (deadlock-safe required-check behavior).
  - Evidence: `.proposals/ci-optimizations/evidence/20260304T220013Z/ci-efficiency-pr-mode-check.txt`

## Verification

- [x] Bash syntax validation passes for shell scripts.
  - Evidence: `.proposals/ci-optimizations/evidence/20260304T220013Z/bash-n.txt`
- [x] YAML/lint validation passes for all edited workflow files.
  - Suggested: `actionlint` + `yamllint`
  - Evidence: `.proposals/ci-optimizations/evidence/20260304T220013Z/workflow-validation.txt`
- [ ] Required check contexts still report and unblock merges correctly.
- [ ] 1-week before/after comparison completed.
  - Command: `bash .proposals/ci-optimizations/scripts/compare-actions-baseline.sh <before_dir> <after_1w_dir>`
- [ ] 30-day before/after comparison completed.
  - Command: `bash .proposals/ci-optimizations/scripts/compare-actions-baseline.sh <before_dir> <after_30d_dir>`

## Done criteria

- [ ] Minute reduction target achieved.
- [ ] No increase in merge-blocking flakes.
- [ ] Required governance checks are still effective and enforced.
