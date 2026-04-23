# Implementation Gap Analysis

## Gap table

| Blocking factor | What currently prevents full realization | Required change | How this packet closes it |
|---|---|---|---|
| Token doctrine lacks executable schema | `authorized-effect-token-v1.md` is doctrinal and concise. | Add v2 token schema and consumption schema. | Promotion targets include both schemas and acceptance criteria. |
| Token values can be forged or hand-built | Current token value is serializable and constructor-like APIs exist. | Use ledger-backed verification, private fields where possible, digest checks, and `VerifiedEffect<T>` guard. | Runtime plan requires verifier and guard before mutation. |
| Token lacks full provenance | Minimal fields do not prove grant, decision, lifecycle, revocation, or journal refs. | Add token id, grant id, decision artifact ref, grant bundle ref, issued/expires/revocation/journal/digest metadata. | Target schema and file map define fields. |
| Incomplete material path family coverage | Inventory schema exists but no complete inventory/proof file is promoted in this packet’s source set. | Add `material-side-effect-inventory.yml` with path ids, owners, token classes, and test refs. | Phase 0/1 freeze and validate inventory. |
| Side-effect APIs may still accept raw paths/ambient grants | Documentation alone does not enforce call signatures. | Update material API signatures to require token/guard. | Phase 4 API hardening and tests. |
| Token lifecycle not replayable | Current event schema lacks token events; Run Journal dependency needed. | Add token lifecycle items/events in canonical Run Journal. | Target architecture declares required event set and sequencing. |
| Evidence store does not explicitly require token proof | Minimum consequential bundle does not name token issue/consume receipts. | Update evidence-store and receipt schemas. | File-change map and validation plan include evidence completeness. |
| Support-target proof omits token coverage | Support targets require authority artifacts and ledgers but not token enforcement proof. | Add token coverage to proof requirements. | File-change map includes support-targets update. |
| Negative bypass proof missing | Coverage contract requires negative controls, but token-specific tests are absent. | Add bypass tests for every material family. | Validation plan and tests define required cases. |
| Generated/read-model confusion risk | Operator views may display execution state. | Preserve generated non-authority and prohibit generated token authority. | Source-of-truth map and conformance card enforce boundaries. |

## Required implementation removals or quarantines

The following patterns must be removed or quarantined for material effects:

- direct filesystem writes to repo/state/evidence/generated-effective roots without a verified token;
- executor launch functions that accept only command/profile/path values;
- service invocation paths that treat a `GrantBundle` as sufficient at the callee;
- receipt writers that can persist material-effect claims without a token consumption ref;
- generated-effective publication code that writes by raw path;
- extension or capability-pack activation code without token class match;
- compatibility wrappers that continue to expose material mutation without enforcement.

## Required additive mechanisms

- token record store under run control root;
- token receipt store under run evidence root;
- token verifier;
- token consumption guard;
- material inventory validator;
- negative bypass suite;
- support-target proof extension;
- closure certification process.

## Non-blocking but important cleanup

- Normalize naming between `run_root`, `run_id`, `run_control_root`, and `run_evidence_root` in token records.
- Consider explicit effect kinds for network egress and model invocation if service invocation is too broad.
- Ensure replay never re-executes token-consumed effects by default.
