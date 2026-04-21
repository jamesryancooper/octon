# Evidence Plan

proposal_id: `octon-architecture-10of10-remediation`  
resource_role: retained evidence and proof-plane design  
status: non-authoritative proposal resource under `inputs/**`

---

## 1. Evidence thesis

A 10/10 Octon architecture must make evidence complete and durable by construction. Evidence cannot be an afterthought, a generated summary, or a temporary CI artifact. CI artifacts may transport evidence, but canonical retained evidence must live under declared evidence roots or a declared retained evidence backend whose receipts are referenced from those roots.

Target invariant:

> Every consequential run, support claim, adapter admission, promotion, denial, runtime closeout, and disclosure can be reconstructed from retained evidence without trusting chat history, generated summaries, host UI comments, or temporary CI artifacts.

---

## 2. Evidence to retain

| Evidence class | Required content | Canonical path / target |
|---|---|---|
| Run start receipt | request id, run id, mission id if any, support tuple, context pack, risk tier, rollback plan, grant state | `/.octon/state/evidence/runs/<run-id>/receipts/start.json` |
| GrantBundle receipt | authorization decision, grant id, reason codes, capabilities, scope, expiry, support tuple | `/.octon/state/evidence/control/execution/grants/<grant-id>.json` |
| Denial/stage receipt | denial/stage reason codes, missing authority/proof/support/evidence, requested path | `/.octon/state/evidence/runs/<run-id>/denials/**` |
| Checkpoint receipt | stage id, checkpoint id, file hashes, command outputs, tool invocations, rollback posture | `/.octon/state/evidence/runs/<run-id>/checkpoints/**` |
| Verification receipt | tests/checks run, result, environment, command, hash of output | `/.octon/state/evidence/runs/<run-id>/verification/**` |
| Replay manifest | replay inputs, file hashes, commands, runtime version, adapter versions, evidence refs | `/.octon/state/evidence/runs/<run-id>/replay/manifest.json` |
| RunCard source bundle | retained evidence sufficient to generate non-authoritative RunCard | `/.octon/state/evidence/runs/<run-id>/disclosure/runcard-source.json` |
| HarnessCard source bundle | runtime, support, policy, model, adapter, validation refs | `/.octon/state/evidence/validation/harnesscard/**` |
| Support proof bundle | conformance suite, live scenario, denied scenario, evidence completeness result, disclosure | `/.octon/state/evidence/validation/support-targets/<tuple-id>/**` |
| Promotion receipt | source path, target path, approver, validation result, evidence hash, authority class | `/.octon/state/evidence/control/promotions/<promotion-id>.json` |
| Publication receipt | generated/effective output, source authority hash, generation lock, freshness, target path | `/.octon/state/evidence/validation/publication/<publication-id>.json` |
| Architecture self-validation receipt | invariant suite run, pass/fail, negative fixture results | `/.octon/state/evidence/validation/architecture/<run-id>.json` |

---

## 3. What can remain transport/projection only

The following may be useful but must not be treated as canonical retained evidence unless copied/hashed/registered into a retained evidence root:

- GitHub Actions uploaded artifacts;
- PR comments;
- check-run annotations;
- issue comments;
- chat transcripts;
- IDE messages;
- generated summaries;
- local terminal scrollback;
- external dashboard cards;
- model memory;
- temporary worktree logs.

Transport artifacts may include pointers to retained evidence. They must not replace retained evidence.

---

## 4. Evidence store contract

Create:

- `/.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `/.octon/framework/constitution/contracts/evidence-store-v1.schema.json`
- `/.octon/framework/assurance/evidence/evidence-store-conformance.yml`

Minimum contract requirements:

1. append-oriented writes;
2. content hash per artifact;
3. run id / mission id binding where applicable;
4. support tuple binding where applicable;
5. retention class (`ephemeral`, `retained-local`, `retained-external`, `immutable-external`);
6. generation/publication relationship for generated views;
7. replay pointer validity;
8. tamper detection at closeout;
9. evidence completeness validator compatibility;
10. disclosure bundle assembly compatibility.

---

## 5. RunCard assembly

A RunCard is generated, non-authoritative, and rebuilt from retained evidence. It must include:

- run id and mission id;
- objective;
- initiating authority;
- support tuple;
- requested and admitted capabilities;
- grant/deny/stage decision;
- risk tier;
- rollback posture;
- commands/tool invocations;
- files changed;
- tests/verifications run;
- interventions;
- evidence completeness status;
- replay pointer;
- closeout disposition.

The RunCard must link to canonical evidence, not become canonical evidence itself.

---

## 6. HarnessCard assembly

A HarnessCard is generated, non-authoritative, and rebuilt from retained evidence plus authored authority. It must include:

- constitutional version / commit;
- runtime version;
- support targets;
- admitted adapters;
- capability packs;
- policy packs;
- validation suite status;
- support-target proof status;
- known exclusions;
- evidence-store conformance status;
- runtime/docs consistency status.

---

## 7. Denial bundle assembly

A denial bundle must include:

- request;
- missing/invalid authority;
- denial reason codes;
- support-target decision;
- rollback/evidence context;
- operator-readable explanation;
- remediation hint;
- negative test reference when applicable.

---

## 8. Disclosure bundle assembly

A disclosure bundle must include:

- RunCard;
- evidence completeness report;
- retained evidence index;
- support envelope;
- hidden human intervention disclosure;
- generated/read-model disclaimers;
- excluded surfaces and unsupported claims;
- replay manifest;
- unresolved risks.

---

## 9. Retention expectations

| Evidence | Minimum retention |
|---|---|
| consequential run receipts | repo lifetime or explicit retention policy |
| support-target proof bundles | until support tuple is retired plus audit window |
| promotion receipts | repo lifetime or until target authority is retired plus audit window |
| publication receipts | while generated/effective output exists plus audit window |
| CI transport artifacts | may be short-lived if retained evidence exists |
| operator read models | rebuildable, no retention obligation as authority |

---

## 10. Proof completeness rules

A run cannot close as `closed` unless:

1. start receipt exists;
2. grant/deny/stage/escalation receipt exists;
3. support tuple is resolved;
4. evidence root is bound;
5. rollback posture is recorded;
6. verification status is recorded;
7. interventions are logged or explicitly absent;
8. generated views are not required as evidence;
9. RunCard source bundle is complete;
10. replay manifest exists or run explicitly declares non-replayable with approved reason.
