# User Source Input 03 — Repository Hygiene Capability Spec Request

Faithful packet-local reproduction of the user's earlier detailed request.

## Source text

You are a senior repository-grounded Octon capability-architecture, governance-design, retirement/ablation, runtime-control, and implementation-spec generation agent.

Your task is to inspect the live Octon repository at:

* `https://github.com/jamesryancooper/octon`
* default branch: `main`

and produce a **fully implementable, production-grade, Octon-aligned capability spec packet** for **repository hygiene, dead-code detection, transitional-surface retirement, and repository-bloat removal** in a **Rust + Shell** repository.

This is **not** a generic cleanup memo.
This is **not** a Python `ruff + vulture` translation.
This is **not** a brainstorming exercise.
This is a **repository-specific, closure-oriented, implementation-ready capability architecture and governance packet**.

Your job is to determine the **correct Octon-native implementation shape** for this problem and then specify it completely.

---

## Core objective

Design the exact Octon-native capability family required to safely, repeatably, and governably:

1. detect dead Rust code,
2. detect unused Rust dependencies,
3. detect orphaned or unused Shell scripts,
4. detect stale generated artifacts and unreferenced repository outputs,
5. detect migration leftovers, compatibility shims, dual-path residue, helper-authored projections, deprecated pathways, and other **sunsettable transitional surfaces**,
6. classify each finding as:
   * safe-to-delete,
   * needs ablation before delete,
   * retain with rationale,
   * demote to historical/projection-only,
   * register for future retirement,
   * or never delete,
7. execute all deletion/retention/demotion logic under Octon’s existing:
   * deny-by-default model,
   * Autonomous Control Points,
   * Mission-Scoped Reversible Autonomy,
   * build-to-delete retirement governance,
   * retained evidence model,
   * support-target boundedness,
   * and fail-closed execution boundary.

The output must define the **full spec packet** required to implement this capability in Octon with **no additional design pass required**.

Additional requirements in the source request included:
- reuse the existing retirement/build-to-delete governance spine before inventing anything new;
- do not treat unused as synonymous with safe-to-delete;
- respect historical and retained surfaces;
- stay within admitted support and capability bounds by default;
- fail closed on ambiguity;
- separate static deadness, dependency deadness, shell orphaning, artifact bloat, transitional residue, historical-retained surfaces, and never-delete surfaces;
- determine the correct implementation shape, naming model, governance owner, runtime/action model, evidence model, and toolchain;
- prefer consolidation over duplication and explicit retained-with-rationale registration over silent accumulation;
- and provide usable operator and CI workflows with explicit closure conditions.
