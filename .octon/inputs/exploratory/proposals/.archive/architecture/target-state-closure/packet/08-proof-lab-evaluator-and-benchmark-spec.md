# 08. Proof, Lab, Evaluator, and Benchmark Spec

## 1. Goal

Preserve Octon’s strong structural/governance proof while making proof-plane completeness, evaluator independence, hidden checks, and lab coverage sufficient for closure-grade claims.

## 2. Preserve current strengths

Preserve and keep blocking:
- `architecture-conformance.yml`
- `deny-by-default-gates.yml`
- existing mission/runtime structural validation
- existing proof-plane artifacts already referenced by RunCards and retained-run-evidence

These are already load-bearing.

## 3. Canonical proof planes

Octon’s closure-grade proof model requires explicit coverage for:

1. structural
2. functional
3. behavioral
4. governance
5. recovery
6. maintainability
7. evaluator

Each live admitted support tuple must declare which planes are required.
No live tuple may omit structural, governance, or recovery.
The current bounded admitted claim also requires functional and behavioral proof for its active exemplar runs.

## 4. Lab realization

Preserve current top-level `framework/lab/**`.
Deepen it with explicit subdomains:

- `.octon/framework/lab/scenarios/workloads/**`
- `.octon/framework/lab/scenarios/hidden-checks/**`
- `.octon/framework/lab/scenarios/adversarial/**`
- `.octon/framework/lab/replay/**`
- `.octon/framework/lab/shadow/**`
- `.octon/framework/lab/faults/**`
- `.octon/framework/lab/probes/evaluator-independence/**`

Retained evidence:
- `.octon/state/evidence/lab/**`

## 5. Hidden-check posture

Create:
- `.octon/instance/governance/policies/hidden-check-governance.yml`
- `.octon/framework/constitution/contracts/assurance/hidden-check-policy-v1.schema.json`

Rules:
- active live claim must disclose hidden-check usage at the aggregate level
- hidden checks must never be the only proof plane
- hidden-check scenario names or exact assertions may remain sealed
- run bundles must record hidden-check coverage counts and identities at the policy level, not necessarily the assertion level

## 6. Evaluator independence

Create:
- `.octon/instance/governance/policies/evaluator-independence.yml`
- `.octon/framework/constitution/contracts/assurance/evaluator-independence-v1.schema.json`

Minimum policy:
- consequential acceptance cannot depend solely on the same model instance that generated the artifact
- at least one independent evaluator path per admitted support tuple is required
- human intervention, if any, must be disclosed as intervention, not hidden inside the evaluator path

## 7. Adversarial / red-team coverage

For every live support tuple, require at least:
- one adversarial scenario pack
- one replay/shadow comparison
- one recovery/fault-injection exercise

These can be narrow and cheap for small tuples; they cannot be absent.

## 8. Benchmark anti-overfitting protections

Required controls:
- hidden-check coverage
- held-out scenario packs
- evaluator diversity or independence
- no benchmark-only prompt branches undisclosed in HarnessCard
- benchmark packets generated from the same retained-run-evidence roots as production-grade disclosure

## 9. Honest intervention disclosure

Intervention records are required for:
- manual approvals
- waivers
- overrides
- label sync that materially changes route or status
- break-glass operations
- manual artifact repair
- benchmark steering

No “clean” benchmark or closure claim may exclude these records if they occurred.

## 10. Validators and generators

Create:
- `validate-proof-plane-completeness.sh`
- `validate-evaluator-independence.sh`
- `validate-lab-hidden-check-coverage.sh`
- `validate-adversarial-scenario-coverage.sh`
- `validate-intervention-disclosure-completeness.sh`
- `generate-proof-plane-coverage-report.sh`

## 11. Migration

1. preserve current structural/governance suites
2. move current live-validation and scenario assets into explicit scenario pack structure
3. add hidden/adversarial/evaluator-independence contracts
4. make behavioral/recovery/lab coverage advisory first, then required for the active claim
5. require proof-plane coverage report in closure bundle

## 12. Acceptance criteria

- top-level lab exists in substance and has scenario, shadow, fault, replay, and adversarial surfaces
- every live admitted support tuple has declared proof-plane requirements and evidence
- evaluator independence policy is live and validated
- hidden-check governance exists and is enforced
- intervention disclosure is complete for active proof-bundle exemplar runs
