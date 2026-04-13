# Target Architecture

## Objective

Integrate the selected Claw Code-derived concepts as a coherent Octon-native
refinement set that strengthens:

- repo-shell execution narrowing
- lab-backed proof of supported repo-shell operation
- bootstrap/preflight readiness
- operator-visible degraded-state reporting
- branch-freshness protection before broad repo-consequential verification

All changes must stay inside the current admitted live support universe and must
remain subordinate to the current constitutional kernel.

## Target state by concept

### 1. Repo-shell supported scenario execution
Target state:
- Octon owns a repo-shell-specific supported scenario pack under `framework/lab/scenarios/packs/`
- the scenario registry names it
- a canonical task workflow exists to execute it and emit retained lab proof plus publication receipts
- the scenario is usable without consulting proposal-local artifacts

### 2. Repo-shell execution classification
Target state:
- Octon owns a repo-specific execution-class policy for the `repo-shell` host adapter
- the adapter explicitly references the classifier expectations
- assurance validates classifier behavior
- allow/deny outcomes surface through canonical authorization/evidence paths rather than ad hoc shell heuristics

### 3. Bootstrap doctor/preflight
Target state:
- a canonical `/bootstrap-doctor` task workflow exists
- `START.md` points to it
- `agent-led-happy-path` treats it as an onboarding prerequisite
- readiness outcomes emit retained receipts and short operator-facing summaries

### 4. Failure taxonomy and degraded-status/operator summaries
Target state:
- failure taxonomy includes the classes needed by the new doctor, scenario, and freshness-preflight workflows
- reporting policy requires concise machine-grounded operator summaries citing failure classes
- generated operator digests remain derived-only and are backed by retained evidence elsewhere

### 5. Branch freshness gating
Target state:
- a repo-owned `branch-freshness.yml` policy exists
- `/repo-consequential-preflight` checks freshness before broad verification
- repo-consequential task workflows require that preflight before broad tests
- freshness outcomes are retained as evidence and can warn, block, or route according to policy

## Why this is the correct landing shape

A narrower docs-only or registry-only treatment would create pseudo-coverage:
the concepts would appear to exist without an operator/runtime surface, without
retained receipts, and without enforceable workflow use.

A broader redesign is unnecessary because Octon already has the core surfaces:
host adapters, lab scenario roots, bootstrap docs, observability governance,
task workflow discovery, and run/evidence roots. The correct move is to adapt
those existing surfaces into complete operational capabilities.
