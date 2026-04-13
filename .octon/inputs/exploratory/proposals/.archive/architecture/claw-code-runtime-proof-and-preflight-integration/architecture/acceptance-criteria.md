# Acceptance Criteria

## Concept 1 — Repo-shell supported scenario proof
Accepted when:
- `repo-shell-supported-scenario.yml` exists under `framework/lab/scenarios/packs/repo-shell/`
- `framework/lab/scenarios/registry.yml` registers it
- `/run-repo-shell-supported-scenario` exists and is discoverable
- a retained scenario-proof bundle and publication receipt exist after execution
- the scenario remains within the admitted live support universe and does not widen claims

## Concept 2 — Repo-shell execution classifiers
Accepted when:
- `instance/governance/policies/repo-shell-execution-classes.yml` exists
- `repo-shell.yml` references the classifier semantics and receipt expectations
- `policy-interface-v1.md` describes the payload/receipt contract
- assurance proves deterministic classification behavior
- classifier outcomes flow through canonical receipt/evidence surfaces

## Concept 3 — Bootstrap doctor/preflight
Accepted when:
- `/bootstrap-doctor` exists as a canonical task workflow
- `START.md` points operators to it as the first runtime check
- `agent-led-happy-path` requires or consumes its readiness result
- execution emits a retained readiness receipt and a short operator summary

## Concept 4 — Failure taxonomy and degraded-status summaries
Accepted when:
- `failure-taxonomy.yml` covers the classes needed by doctor/preflight/scenario workflows
- `reporting.yml` requires short machine-grounded summaries citing failure classes
- generated operator summaries appear only as derived views backed by retained evidence
- non-happy-path summaries cite failure classes and evidence roots

## Concept 5 — Branch freshness before blame
Accepted when:
- `branch-freshness.yml` exists under instance governance policies
- `/repo-consequential-preflight` exists and is discoverable
- broad verification in listed repo-consequential workflows is gated on the preflight
- stale/diverged/fresh outcomes route according to policy
- freshness outcomes are retained as evidence and summarized for operators

## Packet-level acceptance
Accepted when:
- all five concepts meet their concept-level acceptance criteria
- no unresolved blockers remain
- two consecutive validation passes succeed with no new blocking issues
- retained evidence demonstrates that the integrated capability set is complete, usable, and aligned with Octon invariants
