# 13. Pre-Cutover Staging, Shadow, and Dry-Run Plan

## 1. Goal

Define everything that may happen before cutover without contaminating live claim surfaces.

## 2. Non-negotiable staging rules

Pre-cutover work is allowed only when it is:
- non-authoritative
- non-claim-bearing
- reversible
- quarantined from live closure claims

No staging artifact may be described as target-state closure.

## 3. Staging locations

### Candidate control root
Create:
- `.octon/state/control/closure/candidates/<candidate-id>/`

Purpose:
- staging metadata
- migration manifests
- shadow gate outputs
- comparison results

### Shadow release evidence root
Create:
- `.octon/state/evidence/disclosure/releases/<candidate-id>-shadow/**`

Purpose:
- full candidate release bundle generation
- no effect on live release lineage
- no stable mirrors generated into active paths

## 4. Allowed pre-cutover work

### A. Schema introduction
Allowed:
- add new schemas
- add validators and generators
- add new roots
- add support dossier structure
- add retirement registry structure

### B. Artifact backfills
Allowed:
- backfill exemplar evidence classifications
- backfill measurement summaries
- backfill run bundle consistency reports
- backfill support tuple corrections

Rule:
- all backfills occur under candidate/shadow process first
- no active claim update yet

### C. Compatibility shims
Allowed:
- keep old contract files as shims
- keep instance closure/disclosure mirrors
- keep legacy architect / SOUL surfaces marked historical
- generate new and old forms in parallel

### D. Shadow certification rehearsals
Allowed:
- generate shadow release bundles
- run all closure validators
- compute candidate closure certificates
- compare with active claim

## 5. Forbidden pre-cutover work

Not allowed:
- hand-edit active HarnessCard to “match reality”
- hand-edit active gate-status or closure-summary files
- flip active release pointer before certification passes
- cite shadow bundle as live claim
- silently treat backfilled candidate artifacts as active proof

## 6. Staging workstreams

### Workstream 1 — Contract normalization
- introduce run-contract-v3
- mission-charter schema
- quorum-policy schema
- evidence-classification v2

### Workstream 2 — Evidence and disclosure backfill
- fill exemplar evidence classifications
- regenerate measurement summaries
- regenerate RunCards/HarnessCard in shadow mode
- create closure bundle shadows

### Workstream 3 — Authority normalization
- migrate leases/revocations
- introduce projection receipts
- align route semantics

### Workstream 4 — Lab / evaluator hardening
- hidden checks
- adversarial scenarios
- evaluator independence contracts

### Workstream 5 — Legacy path retirement rehearsal
- no-legacy-active-path dry-runs
- ingress rewrite dry-runs
- historical shim inventory

## 7. Shadow acceptance criteria

Before cutover may be attempted:
- all shadow validators pass at least once
- all active proof-bundle exemplar runs have non-empty classifications in candidate state
- no stale wording remains in candidate release bundle
- run bundle consistency passes for all active exemplar runs
- run-contract-v3 is wired everywhere in candidate state
- generated mirrors can be produced from the candidate release bundle with zero parity drift

## 8. Exit artifact

Pre-cutover staging exits with:
- one approved candidate id
- one shadow release bundle
- one shadow closure certificate
- one migration manifest
- one cutover go/no-go decision packet
