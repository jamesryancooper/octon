# Validation plan

## Validation planes

### 1. Structural validation
Validate file existence, schema conformance, and placement:
- all new contracts validate as JSON/YAML schemas
- all new instance policies conform to existing manifest/overlay rules
- all new control/evidence artifacts live in the correct class roots

### 2. Runtime/control validation
Validate live mutable truth:
- review dispositions block or allow progression exactly as policy defines
- proposal-required mission classes fail closed when proposal refs are missing
- no external comment or proposal-local file can override state/control truth

### 3. Assurance validation
Validate quality and governance:
- evaluator findings map cleanly to dispositions
- failure-distillation bundles contain provenance to source evidence
- distillation workflows never auto-promote authority changes

### 4. Evidence retention validation
Validate proof posture:
- every new actionable refinement has a paired evidence artifact
- raw payloads offloaded from compact output envelopes remain recoverable through retained evidence
- distillation bundles record source evidence indexes, not just summaries

### 5. Generated-output validation
Validate derived-only posture:
- generated summaries and review packs are marked non-authoritative
- all generated artifacts trace back to control/evidence or authority roots
- no runtime or policy path depends on generated files

### 6. Operator/runtime usability validation
Validate that the capability is actually usable:
- reviewers can emit findings and dispositions without side-channel conventions
- mission intake can set proposal-first classification deterministically
- adapter/tool surfaces can emit compact envelopes without losing recoverability
- governance operators can inspect failure/distillation bundles and promote follow-on changes through ordinary authority routes

## Required validation artifacts by concept

| Concept | Minimum validation set |
|---|---|
| Structured review findings + disposition | schema tests, run-control blocking tests, evidence provenance checks |
| Proposal-first mission classification | schema tests, fail-closed mission intake tests, proposal-ref presence checks |
| Failure-driven harness hardening | bundle validation, recurrence clustering checks, promoted-hardening regression proof |
| Thin adapters + token-efficient outputs | output-envelope schema tests, token-budget checks, raw-payload recovery proof |
| Distillation pipeline | distillation bundle schema tests, provenance checks, anti-shadow-memory checks |

## Two-pass closure requirement

No adapted concept can close until:
1. all validators pass,
2. a second consecutive validation pass introduces no new blocking issues,
3. required evidence artifacts exist and are inspectable.

## Negative tests required

- Sandboxed or isolated execution must **not** count as approval.
- Proposal packet content must **not** be readable as canonical control truth.
- Generated distillation summaries must **not** override retained evidence or promoted authority.
