# Generate Program Implementation Orchestration Prompt

Re-read the parent and every child packet, then run the parent review gate and
child-readiness gate:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <program-packet-path> --require-implementation-authorization
```

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package <program-packet-path>
```

Stop unless both validators pass. Parent review authorization must be a fresh
accepted parent-local `support/proposal-review.md` receipt. Child readiness
then checks required non-deferred child metadata including `change_profile`,
child-owned implementation-grade completeness reviews, accepted fresh
child-owned proposal-review digests, declared packet-specific completeness
requirements, predecessor/successor coherence, and cutover readiness
constraints.

Respect each child promotion target, follow the declared sequence or parallel
grouping, record child-level and program-level evidence, and stop when a child
packet is stale or blocked.

The generated prompt must identify the parent-owned coordination work, each
child-owned implementation target, allowed parallel groups, handoff gates,
shared generated/runtime surfaces, validation commands, evidence outputs, and
terminal criteria. It may coordinate child packets but must not collapse child
authority into the parent or broaden a child packet beyond its manifests unless
the parent sequence explicitly requires one coordinated changeset.

The generated program implementation orchestration prompt must require a parent-local
`support/program-implementation-orchestration-run.md` after program execution with at least
`verdict`, `implemented_at`, `promotion_evidence_count`, and
`child_authority_preserved`. Use `verdict: pass` and
`child_authority_preserved: yes` only when parent coordination evidence is
complete and child manifests, child receipts, child promotion targets, child
validation verdicts, and child archive metadata remain child-owned. Parent
implementation-run evidence may summarize child outcomes but never satisfies
child receipts.

Proposal readiness is permission to generate program implementation orchestration prompts, not
evidence that implementation has completed. Do not require implementation
receipts, promoted durable contracts, schemas, validators, fixtures, or
canonical runtime support to already exist unless a child packet explicitly
claims they already exist.
