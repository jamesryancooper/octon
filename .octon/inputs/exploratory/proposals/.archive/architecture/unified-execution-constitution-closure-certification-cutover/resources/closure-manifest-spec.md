# Closure Manifest Spec

This packet requires one machine-readable closure manifest whose sole job is to
freeze the exact supported claim and the exact proof bundle needed to publish
that claim.

## Proposed path

- `.octon/instance/governance/closure/unified-execution-constitution.yml`

## Proposed contract

```yaml
schema_version: unified-execution-constitution-closure-v1
claim_id: uec-closure-certification
claim_kind: release
claim_status: candidate
supported_claim:
  model_tier: MT-B
  workload_tier: WT-2
  language_resource_tier: LT-REF
  locale_tier: LOC-EN
  host_adapter: repo-shell
  model_adapter: repo-local-governed
  support_status: supported
excluded_or_reduced_surfaces:
  - surface: github-control-plane
    status: reduced
    route: allow-as-projection-only
  - surface: ci-control-plane
    status: reduced
    route: stage_only
  - surface: WT-3
    status: reduced
    route: stage_only
  - surface: LT-EXT
    status: reduced
    route: stage_only
  - surface: LOC-MX
    status: reduced
    route: stage_only
  - surface: MT-C
    status: experimental
    route: stage_only
  - surface: WT-4
    status: unsupported
    route: deny
required_proof_artifacts:
  - authority-decision-artifact
  - authority-grant-bundle
  - run-contract
  - run-manifest
  - runtime-state
  - rollback-posture
  - stage-attempt-root
  - checkpoint-root
  - evidence-classification
  - replay-pointers
  - external-replay-index
  - intervention-log
  - measurement-summary
  - run-card
  - harness-card-proof-bundle
allowed_historical_shims:
  - .octon/AGENTS.md
  - AGENTS.md
  - CLAUDE.md
permitted_release_wording: >-
  Octon is a fully realized unified execution constitution within its declared
  supported envelope for MT-B / WT-2 / LT-REF / LOC-EN on repo-shell and
  repo-local-governed.
```

## Rules

- This manifest is the **claim boundary**. Release wording may not outrun it.
- Any surface not explicitly included is outside the fully realized claim.
- Any required proof artifact missing from the certified run blocks release.
- Allowed historical shims remain legal only if the shim-independence audit is
  clean and each shim has an explicit retirement condition.
