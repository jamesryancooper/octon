# Current-State Gap Map

## Summary

| Concept | Current Octon evidence | Coverage status | Gap type(s) | Operational risk if left as-is | Final disposition |
|---|---|---|---|---|---|
| Instruction-layer provenance, precedence, and progressive-disclosure hardening | `instruction-layer-manifest-v2.schema.json`, precedence files, `tool-output-budgets.yml`, ingress read order | partially_covered | extension_needed; overlap_existing_surface | medium — provenance exists, but capability/class/envelope disclosure is not yet closure-grade | adapt |
| Capability invocation and output-envelope normalization | execution request / grant / receipt schemas, repo-shell class policy, shell/repo pack manifests, admitted shell pack | partially_covered | extension_needed; consolidation_needed; overlap_existing_surface | medium-high — authority routing exists, but envelope semantics are split across multiple surfaces | adapt |

## Detailed gaps

### 1. Instruction-layer provenance
**What exists now**
- The runtime contract family already includes `instruction-layer-manifest-v2.schema.json`.
- The manifest already requires `workspace_charter_refs`, `run_contract_ref`, `support_target_tuple_id`, `authority_refs`, `precedence_stack`, `adapter_projection_refs`, and `source_digests`.
- Repo-local runtime overlays already include `tool-output-budgets.yml` with raw-payload-ref requirements and summary limits.

**Why that is not yet enough**
- The current manifest does not yet provide an explicit, validator-enforced link to active capability packs, execution classes, or budget policies.
- Output budgets exist, but they are not yet normalized into the manifest / receipt path in a way that makes a consequential run self-describing.

**Usability gap**
Operators can inspect multiple surfaces and infer what happened, but the repo does not yet guarantee one authoritative, per-run provenance record for capability/tool surface + envelope posture.

### 2. Capability invocation and output-envelope normalization
**What exists now**
- Requests, grants, and receipts are already modeled under the engine runtime spec.
- The repo-shell execution-classes policy already defines class routes, command prefixes, and receipt reasons.
- Framework capability packs and repo-local admissions already exist, with shell admitted and support-target-bounded.

**Why that is not yet enough**
- The end-to-end path from request to receipt does not yet guarantee normalized pack/class/envelope semantics in one coherent chain.
- Receipt and budget semantics are still partially implicit and partly spread across engine spec, pack manifests, and repo-specific class policy.

**Usability gap**
The repo can govern execution, but it cannot yet prove, with minimum ambiguity, which admitted pack, which execution class, and which output-envelope policy governed a particular step.

## No-change areas explicitly left untouched

The packet does not reopen already-covered runtime areas:
- atomic run-contract execution
- engine-owned authorization boundary
- mission continuity
- retry / failure classification
- verification evidence families
- delegation governance
