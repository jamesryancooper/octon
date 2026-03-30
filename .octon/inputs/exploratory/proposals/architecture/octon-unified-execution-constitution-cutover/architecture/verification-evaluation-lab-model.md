# Verification, Evaluation, and Lab Model

## Proof planes
1. Structural
2. Functional
3. Behavioral
4. Maintainability
5. Governance
6. Recovery

## Rules
- structural and governance proof remain blocking from day one
- functional / behavioral / recovery proof become tier-gated but must grow to blocking status for supported claims
- self-checking is allowed only for local deterministic checks
- consequential acceptance requires deterministic proof or independent evaluation
- hidden-check support is required for benchmark integrity
- every human intervention must be disclosed honestly

## Lab design
`framework/lab/**` owns:
- scenario packs
- workload replay
- shadow runs
- fault injection
- red-team experiments
- telemetry probes
- operational discovery

## Key interfaces
- `lab-scenario-v1`
- `replay-bundle-v1`
- `shadow-run-manifest-v1`
- `fault-injection-plan-v1`
- `probe-contract-v1`

## Preserve current strengths
The current architecture-conformance and deny-by-default gates remain the structural /
governance backbone. The new proof planes are additive and must not weaken those suites.
