# External Architect Review Response Template

## Review Metadata

- architect:
- organization or independent capacity:
- reviewed packet commit/digest:
- review date:
- materials omitted or unavailable:
- conflicts or constraints:

## Overall Verdict

- verdict: `approve | approve-with-required-changes | revise | reject`
- implementation-decision-ready after required changes: `yes | no`
- executive rationale:

## Product-Fit Assessment

- safety posture:
- development-throughput posture:
- solo-operator administrative burden:
- strongest architectural property:
- largest residual risk:

## Architecture Decision Dispositions

| Decision | Disposition (`approve`, `amend`, `reject`, `needs-evidence`) | Required amendment or rationale | Blocking? | Acceptance evidence |
| --- | --- | --- | --- | --- |
| AD-01 |  |  |  |  |
| AD-02 |  |  |  |  |
| AD-03 |  |  |  |  |
| AD-04 |  |  |  |  |
| AD-05 |  |  |  |  |
| AD-06 |  |  |  |  |
| AD-07 |  |  |  |  |
| AD-08 |  |  |  |  |
| AD-09 |  |  |  |  |
| AD-10 |  |  |  |  |
| AD-11 |  |  |  |  |
| AD-12 |  |  |  |  |

## Open-Finding Dispositions

| Finding | Disposition (`accept`, `modify`, `reject`, `needs-evidence`) | Recommended resolution | Security effect | Velocity/operations effect | Acceptance test |
| --- | --- | --- | --- | --- | --- |
| EXT-01 |  |  |  |  |  |
| EXT-02 |  |  |  |  |  |
| EXT-03 |  |  |  |  |  |
| EXT-04 |  |  |  |  |  |
| EXT-05 |  |  |  |  |  |
| EXT-06 |  |  |  |  |  |
| EXT-07 |  |  |  |  |  |
| EXT-08 |  |  |  |  |  |
| EXT-09 |  |  |  |  |  |

## New Findings

Repeat this block for every new finding.

### ARCH-NEW-___ — Title

- severity: `blocker | high | medium | low`
- claim:
- evidence and file references:
- current fact, target-design issue, or inference:
- consequence:
- minimum credible repair:
- rejected repair alternatives:
- acceptance test:
- residual risk:

## Keep-As-Is Decisions

List material mechanisms that should remain unchanged and explain why.

## Authorization and Enforcement Trace

- sole grant-producing authority:
- capability issuance owner:
- capability state/consume owner:
- attempt-start owner:
- invocation owner:
- credential owner:
- evidence sequence owner:
- evidence authenticity owner:
- external anchor owner:
- hidden or competing plane found:

## Failure and Recovery Assessment

- most dangerous crash boundary:
- most dangerous concurrency boundary:
- revocation weakness:
- outcome-unknown weakness:
- degraded-operation assessment:
- recovery mechanism likely to strand work or authority:

## TCB and Identity Assessment

- missing privileged component or identity:
- unnecessary privileged component or identity:
- credential shortcut:
- same-change self-certification path:
- provider/platform dependency concern:

## Solo-Developer Usability Assessment

- expected ordinary interruptions:
- expected Class C interruptions:
- likely false-denial source:
- first secure install/enrollment estimate:
- recurring monthly administration estimate:
- control that costs more than its demonstrated risk reduction:

## Minimum Safe Implementation Order

Provide an ordered list with prerequisites and explicit temporary safe states.

1.
2.
3.

## Required Additional Evidence

| Evidence request | Why needed | Proof class (`static`, `dynamic`, `adversarial`) | Acceptance threshold |
| --- | --- | --- | --- |
|  |  |  |  |

## Residual Risks and Assumptions

- residual risks:
- assumptions:
- unsupported claims that must be removed:

## Final Recommendation

State the shortest safe route from the current `in-review` packet to either a
decision-ready revision or rejection. Confirm explicitly whether implementation
should remain blocked.
