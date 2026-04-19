# Coverage Traceability Matrix

| Decision | Current surface | Repository change | Validator | Acceptance criteria |
|---|---|---|---|---|
| Canonical noun is execution role | agency spec | add execution-role spec; delete agency spec | hard-cutover validator | 1-5 |
| Run-contract atomic unit | charter, README, runtime | remove mission-only path | terminology validator | 8-9 |
| Context packs mandatory | execution authorization references context packs | require in v3 schema and receipts | context-pack validator | 11 |
| Generated cognition non-authority | cognition spec | add context-pack derived-input rules | generated-boundary validator | 12 |
| Capability packs governance-grade | capability pack README | bind packs in support tuple and run envelope | capability-pack validator | 13 |
| Browser/API support proof-backed | browser/API packs, service manifest | service manifest plus proof or non-live claim | browser/API proof validator | 14 |
| Runtime events canonical | octon.yml runtime bus roots | add runtime-event schema | event conformance tests | 15 |
| Connector leases required | network egress policy | replace with connector lease model | egress validator | 16 |
| Budgets frontier-scoped | execution budget policy | replace with run/mission/tool/browser/API budgets | budget validator | 17 |
| Evidence-only disclosures | lab/observability/constitution | RunCard/HarnessCard from evidence only | disclosure validator | 18 |
