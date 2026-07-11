# Prompt Set Coverage Map

Source: `source/conversation-thread.md` (normalized source-model wording)

Review date: 2026-07-06

## Purpose

This map explains how the earlier prompt sets in the source thread are covered
by the final seven-prompt Octon architecture review library.

The final seven prompts are the operative prompt library. Earlier prompt sets
are source context. Their pertinent review concerns are either absorbed into a
broader final review route, preserved as an example target inside a final
prompt, or superseded by the review-result routing amendment.

## Interpretation Rules

- `Primary` means the final prompt is the normal route for that earlier concern.
- `Secondary` means the final prompt can inspect the concern when scope requires
  it, but it is not the default starting point.
- `Conditional` means the final prompt should be used only if another review
  identifies the triggering condition.
- `Not retained as standalone` means the concern is intentionally collapsed
  into a broader route and is not missing as a separate prompt artifact.

## Final Operative Prompt Routes

| Final route | Prompt artifact | Primary role |
| --- | --- | --- |
| Prompt 1 | `prompts/01-octon-authoritative-super-root-balanced-architecture-review.md` | Whole super-root architecture review |
| Prompt 2 | `prompts/02-bounded-clean-sheet-delta-review.md` | Follow-up clean-sheet delta review when Prompt 1 leaves foundational doubts |
| Prompt 3 | `prompts/03-current-state-mechanism-architecture-review.md` | Cross-surface mechanism review |
| Prompt 4 | `prompts/04-architecture-readiness-audit.md` | Readiness gate after an architecture has been accepted |
| Prompt 5 | `prompts/05-domain-architecture-audit.md` | Bounded domain architecture audit |
| Prompt 6 | `prompts/06-surface-architecture-audit.md` | Single durable surface or surface-family audit |
| Prompt 7 | `prompts/07-constitutional-challenge-review.md` | Conditional constitutional conflict review |

## Earlier Eight-Prompt Set Coverage

| Earlier concern | Primary final route | Secondary or conditional routes | Coverage note |
| --- | --- | --- | --- |
| Authority topology and second-control-plane review | Prompt 1 | Prompt 6 for a single surface; Prompt 7 if a constitutional conflict appears | Covered by whole-super-root authority topology, class-root, control-plane, and non-authority checks. |
| Material side-effect authorization coverage | Prompt 5 | Prompt 3 for a concrete mechanism; Prompt 7 for authority/fail-closed conflict | Covered as policy/ACP, material side-effect, deny-by-default, and authorization-bound execution review. |
| Run lifecycle and journal truth review | Prompt 5 | Prompt 3 for run closeout or journal lifecycle; Prompt 6 for specs/schemas | Covered through evidence closure, run journal, replay, rollback, receipts, and auditability domains. |
| Support envelope and proof sufficiency | Prompt 5 | Prompt 4 for readiness; Prompt 6 for support dossiers or contracts | Covered by support-target, proof executability, support-widening, and acceptance-gate checks. |
| Context, memory, and model-visible evidence review | Prompt 5 | Prompt 1 for whole-system implications; Prompt 7 for authority confusion | Covered by context packing, memory, model-visible integrity, context laundering, and non-authority checks. |
| Long-horizon autonomy and self-evolution review | Prompt 5 | Prompt 1 for whole-system posture; Prompt 7 for constitutional conflict | Covered by autonomy, stewardship, self-evolution, reversibility, and auditability checks. |
| Connector/browser/API admission critique | Prompt 5 | Prompt 7 for external trust or provider-state authority risk; Prompt 4 for readiness | Covered by connector admission, external operations, browser/API packs, trust, and support/capability posture. |
| Roadmap after architecture review | Review-result amendment | Prompt 4 for readiness; proposal packet/program routing only after retained evidence exists | Not retained as standalone. The final library separates review evidence from downstream proposal/program creation. |

## Earlier Twelve-Prompt Set Coverage

| Earlier prompt | Primary final route | Secondary or conditional routes | Coverage note |
| --- | --- | --- | --- |
| Single-control-plane, authority precedence, and human authority artifacts | Prompt 1 | Prompt 6 for a specific artifact; Prompt 7 for conflict | Covered by authority hierarchy, class-root placement, human authority artifacts, and second-control-plane checks. |
| Generated-effective resolver, freshness, and compatibility de-authorization | Prompt 5 | Prompt 3 for publication/resolver mechanism; Prompt 6 for handle or freshness surfaces | Covered by generated/effective trust, publication freshness, compatibility, retirement, and allowed-consumer checks. |
| Material side-effect authorization and policy/ACP enforcement | Prompt 5 | Prompt 3 for runtime authorization mechanism; Prompt 7 for fail-closed conflict | Covered by material execution, policy/ACP, effect authorization, and deny-by-default checks. |
| Run lifecycle, journal truth, evidence closure, replay, and rollback | Prompt 5 | Prompt 3 for run lifecycle mechanism; Prompt 6 for journal/evidence schemas | Covered by evidence closure, run journal, receipts, replay, rollback, disclosure, and auditability checks. |
| Support claim envelope and proof executability | Prompt 5 | Prompt 4 for readiness; Prompt 6 for support target surfaces | Covered by support-target admission, proof-backed support, support widening, and evidence expectations. |
| Context, memory, and model-visible integrity | Prompt 5 | Prompt 1 for whole-system context posture; Prompt 7 for authority risk | Covered by context-pack, memory, model-visible integrity, continuity, and non-authority checks. |
| Mission-scoped autonomy, stewardship, and self-evolution feedback loops | Prompt 5 | Prompt 1 for whole-super-root posture; Prompt 7 for constitutional conflict | Covered by mission-scoped autonomy, stewardship, promotion/recertification, reversibility, and auditability. |
| Connector, browser, API, plugin, and external operation admission | Prompt 5 | Prompt 7 for external/provider authority risk; Prompt 4 for readiness | Covered by connector/external operation domain examples, adapter/support posture, trust boundaries, and external admission risks. |
| External trust, portability, adoption, federation, and imported proof | Prompt 1 | Prompt 5 for trust/federation domain; Prompt 7 for constitutional conflict | Covered at the whole-architecture level and by domain/constitutional routes when external trust becomes concrete. |
| Change closeout, branch landing/cleanup, and hosted-control surfaces | Prompt 3 | Prompt 5 for closeout domain; Prompt 6 for hosted-control/read-model surfaces | Covered as a mechanism/domain/surface concern, but not retained as a named standalone prompt. |
| Architecture-health and validator-depth review | Prompt 4 | Prompt 5 for domain validator coverage; Prompt 6 for schema/validator surfaces | Covered by readiness gates, validator/test/fixture depth, negative controls, and acceptance criteria. |
| Product claim, disclosure, and operator read-model claim discipline | Prompt 1 | Prompt 5 for disclosure/read-model domain; Prompt 6 for read-model surfaces; Prompt 7 for conflict | Covered by operator/read-model boundaries, product disclosure, evidence/disclosure posture, and non-authority statements. |

## Coverage Conclusion

The earlier prompt sets do not require additional prompt artifacts for the
current intake library. Their pertinent review concerns are covered by the
final seven route prompts and by the shared review-result placement amendment.

The only material loss is one-to-one prompt identity: the final library no
longer preserves every earlier governance lens as a separately executable
prompt. That is intentional. The final library favors reusable review routes
that can be applied to a whole architecture, a mechanism, a domain, a surface,
an accepted architecture, or a constitutional conflict.

The three collapsed governance lenses that previously lacked a named final
route are now named Prompt 5 domain presets (added 2026-07-09):

- change closeout, branch landing/cleanup, and hosted-control surfaces;
- validator depth and architecture health;
- product claim, disclosure, and operator read-model claim discipline.

If Octon later wants durable specialized prompt products for any of these
lenses, they remain the strongest candidates. Those are optional future
specializations, not missing artifacts from this intake.

## Source-Thread Tension Seeds

The source thread's analysis passes flagged specific unresolved architectural
tensions that the final prompts cover only through their generic question
batteries. They are preserved here as optional seeds so a Prompt 1, 5, or 6
run does not have to rediscover them cold. They are hypotheses to test against
current repository evidence, not findings:

- far-future context receipt freshness
  (`CONTEXT_RECEIPT_VALID_UNTIL = "9999-12-31T23:59:59Z"`;
  `source/conversation-thread.md` lines 307, 837, 1586);
- `missing_cost_evidence_action: stage_only` behaving as a soft allow
  (lines 1193, 1578);
- capability-pack inference gaps in effect authorization (line 1580);
- normative-versus-epistemic precedence confusion risk;
- run-specific human authority artifact lifecycle (approvals, exceptions,
  revocations as first-class file-native artifacts).

## Boundary Statement

This map is intake-local, non-authoritative review material. It does not
authorize architecture review execution, proposal creation, implementation,
publication, generated/effective updates, support widening, or runtime/control
mutation.
