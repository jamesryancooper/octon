# Current-State Gap Analysis

## Current state

The repository already contains several strong foundations for self-evolution:

- Proposal packets are explicitly manifest-governed, temporary, and non-canonical.
- Architecture proposals have a subtype standard and required target/implementation/acceptance documents.
- Evidence distillation is already proposal-gated with `auto_promote: false`.
- Evidence obligations require lab/replay/scenario/shadow-run evidence for behavioral claims and promotion receipts for authority/control/runtime-facing generated-effective changes.
- The five-root authority model already separates authored authority, mutable control truth, retained evidence, continuity, generated projections, and exploratory inputs.
- The execution authorization contract already protects material execution through engine-owned authorization and effect-token consumption.

## Gap

What is missing is a **canonical self-evolution control path** that connects those surfaces into a safe lifecycle:

- no first-class Evolution Candidate object;
- no standard control root for candidate disposition;
- no standard proposal compiler contract from candidate to packet;
- no standard governance impact simulation artifact;
- no standard Constitutional Amendment Request class;
- no standard promotion runtime contract;
- no standard recertification runtime contract;
- no Evolution Ledger that indexes self-evolution lineage without replacing proposal manifests or evidence;
- no CLI/runtime shape for `octon evolve ...`, `octon promote ...`, or `octon recertify ...`;
- no packet-to-promotion gate that keeps proposal outputs non-authoritative until accepted and promoted.

## Prior-layer dependency gap

Prior-layer dependency stance:

This v5 packet is intentionally scoped against the expected v1-v4 progression, but it does not reimplement v1-v4. If Engagement, Work Package, Mission Runner, Stewardship Program, or Connector Admission surfaces are absent in the live repo when this packet is implemented, the implementation must add only minimal compatibility shims needed to fail closed coherently. It must not silently backfill those layers inside this v5 change.


## Risk if left unresolved

Octon would accumulate proposal packets, retained evidence, and generated summaries, but promotion into durable authority would remain operator/manual-process dependent. That creates pressure for ad hoc promotion, hidden memory, generated summary authority, or proposal-path dependencies, all of which violate the current authority model.
