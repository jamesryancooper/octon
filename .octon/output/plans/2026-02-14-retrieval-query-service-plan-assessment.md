# Assessment: Retrieval Query Service Plan

**Plan under review:** `.octon/output/plans/2026-02-14-retrieval-query-service-plan.md`
**Assessment date:** 2026-02-14
**Architectural constraint:** Agent-native, permanently zero external dependencies. Adapter-contract pattern for external backends.

---

## Verdict

The plan is sound. All previously identified gaps are resolved. The
architectural boundary (agent-native core, adapter-external backends) is
clearly stated and structurally enforced. The plan is ready to execute
Phase 0.

---

## What the plan gets right

### 1. Architectural boundary

The new "Architectural Boundary: Agent-Native, Adapter-External" section
establishes that external retrieval backends are never implemented inside
the service — permanently, not as a staging decision. Integration with
external backends follows the adapter-contract pattern from
`interfaces/agent-platform`: declarative contracts under `adapters/<id>/`,
actual implementation lives externally, core service functions without any
adapter loaded.

This is the strongest structural decision in the plan. It eliminates
dependency creep by design rather than by discipline.

### 2. Phase sequencing

Contract-first (Phase 0) before runtime (Phase 1) before registration
(Phase 2) before observability (Phase 3) mirrors how every existing wired
service was built. The PR-per-phase cut strategy keeps review slices small
and independently revertible.

### 3. Artifact inventory

The Phase 0 deliverable list hits every required component in
`conventions/rich-contracts.md`:

| Rich-contract requirement | Plan artifact | Present |
|---|---|---|
| schema | `schema/input.schema.json`, `output.schema.json` | Yes |
| rules | `rules/rules.yml` | Yes |
| fixtures | `fixtures/{positive,negative,edge}.json` | Yes |
| invariants | `contracts/invariants.md` | Yes |
| error_semantics | `contracts/errors.yml` | Yes |
| compatibility_profile | `compatibility.yml` | Yes |

### 4. Non-negotiables

Seven invariants, up from five in the original. The additions — native-first
(item 6) and provider-term confinement (item 7) — directly encode the
architectural boundary into enforceable contract terms.

### 5. Signal architecture

The `keyword | semantic | graph` vocabulary is architecturally honest. Each
signal's determinism boundary is explicitly documented. The processing
pipeline diagram makes the flow legible at a glance. The rename from
`dense` to `semantic` correctly names what the agent does (contextual
relevance scoring) rather than implying infrastructure that does not exist.

### 6. Phase 1 runtime

Pure `bash` + `jq` + agent interpretation. No Python, no pip, no embedding
models. Signal scripts are factored into `impl/signals/` with a clear
entrypoint (`query.sh`). Index artifact dependencies are explicit:
`keyword.json`, `links.jsonl`, `chunks.jsonl`. The `dense.*` artifact is
correctly removed.

### 7. Phase 2 wiring

All three canonical actions (`ask`, `retrieve`, `explain`) have
corresponding command docs. `interface_type: shell` and
`category: retrieval` are pinned. `integratesWith: [index]` declares the
dependency on index artifacts. `retrieval` as category covers future
sibling services without further `capabilities.yml` changes.

### 8. Phase 4 boundary

Advanced routes are agent-native only. Adapter contracts for external
backends follow the `agent-platform` pattern with a concrete directory
layout. The plan is explicit that adapter contracts define the interface;
implementation lives externally. This prevents the most likely drift vector:
someone adding a "just this one library" shortcut into the core service.

### 9. Guide.md scope boundary

The plan correctly treats `guide.md` as design context, not contract
source. SERVICE.md is authoritative. External-backend content in `guide.md`
is preserved as source material for future adapter contracts, not as MVP
scope. This avoids both unnecessary churn (rewriting guide.md now) and
scope creep (treating it as implementation spec).

### 10. Risks

Six risks with targeted mitigations. The additions — semantic signal latency
(risk 5) and guide.md scope creep (risk 6) — address the two most likely
failure modes of the agent-native approach.

---

## Resolved gaps from initial assessment

| Gap | Initial status | Current status |
|---|---|---|
| `service_categories` missing a category | Open | Resolved: add `retrieval` in Phase 2 |
| `interface_type` unspecified | Open | Resolved: `shell` |
| Independence validator would trip | Open | Resolved: clean pass, no exceptions |
| `dense` signal vocabulary misleading | Open | Resolved: renamed to `semantic` |
| Python recommended in Phase 1 | Open | Resolved: removed, pure bash + jq |
| `dense.*` index artifact without embeddings | Open | Resolved: removed, `chunks.jsonl` added |
| guide.md treated as contract source | Open | Resolved: scope boundary documented |
| Semantic signal latency undocumented | Open | Resolved: Phase 3 baseline requirement |
| `explain` command missing from Phase 2 | Open | Resolved: `query-explain.md` added |
| Phase 0 exit gate too soft | Open | Resolved: fixture-schema validation added |
| `generated.manifest.json` status unclear | Open | Resolved: stub with `"status": "pending"` |
| Composite service dependency undeclared | Open | Resolved: `integratesWith: [index]` |

---

## Remaining observations

These are not blockers. They are refinements to consider during execution.

### 1. Semantic signal determinism boundary needs fixture treatment

The plan correctly states that semantic signal stability "depends on agent
model determinism and is documented as a known boundary." During Phase 1
fixture authoring, consider whether `positive.json` fixtures should assert
on semantic-scored output or only on the deterministic pipeline stages
(keyword, graph, fusion, citation assembly). If fixtures include semantic
output, they become model-dependent and may break across agent versions.

Recommendation: Phase 1 fixtures assert deterministic pipeline stages only.
Semantic scoring quality is validated in Phase 3 via the evaluation dataset
and baseline report, not via brittle fixture assertions.

### 2. `chunks.jsonl` provenance

The plan declares `indexes/<snapshot>/chunks.jsonl` as an input dependency
but the index service is not yet wired either (it exists as a guide only,
like query did). Phase 1 implementation will need either:
- a hand-built test snapshot with `keyword.json`, `links.jsonl`, and
  `chunks.jsonl` for fixture validation, or
- a minimal index artifact generator script committed alongside Phase 1.

This is a practical sequencing detail, not a plan gap.

### 3. Adapter contract validation

Phase 4 states adapter contracts "pass structural validation" but no
validator currently exists for the adapter-contract pattern. The
`agent-platform` service has adapter artifacts but no automated validator
that checks adapter registry/metadata/fixture completeness. If Query adds
adapters in Phase 4+, it may want to propose a shared adapter-contract
validator. This is future work and does not block MVP.

---

## Summary

| Dimension | Status |
|---|---|
| Architectural boundary | Sound — permanently agent-native, adapter-external |
| Phase sequencing | Sound |
| Artifact completeness | Sound |
| Non-negotiables | Sound — expanded to seven, encodes boundary |
| Signal architecture | Sound — `keyword \| semantic \| graph` |
| Runtime dependencies | Sound — bash + jq only, no external deps |
| Index artifacts | Sound — `keyword.json`, `links.jsonl`, `chunks.jsonl` |
| Phase 2 wiring | Sound — all three commands, category, interface type pinned |
| Phase 4 expansion | Sound — agent-native routes + adapter-contract pattern |
| Guide.md scope | Sound — design context, not contract source |
| Compatibility profile | Sound — `external_dependencies: none` |
| Risks and mitigations | Sound — six risks, all mitigated |
| PR cut strategy | Sound |

The plan is ready to execute Phase 0.
