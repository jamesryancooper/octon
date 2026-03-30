# Evidence

## What Changed

- converged the constitutional manifest to one atomic live model and moved old
  staged rollout metadata into historical lineage
- renamed the live WT-2 support tier from `repo-local-transitional` to
  `repo-local-consequential`
- published a named runtime `authority_engine` crate and bound quorum policy
  references into approval and grant-bundle artifacts
- promoted canonical disclosure roots to:
  `instance/governance/disclosure/**` and
  `state/evidence/disclosure/{runs,releases}/**`
- re-pointed live run contracts, run manifests, run projections, evaluators,
  benchmarks, and closeout validators at the new disclosure roots
- registered old run-local and lab-local disclosure paths as historical mirrors
  in the retirement system and refreshed the build-to-delete review packet

## Evidence Produced

- canonical authored HarnessCard source:
  `/.octon/instance/governance/disclosure/harness-card.yml`
- canonical retained release HarnessCard:
  `/.octon/state/evidence/disclosure/releases/2026-03-30-unified-execution-constitution-atomic-cutover/harness-card.yml`
- canonical retained RunCards:
  `/.octon/state/evidence/disclosure/runs/run-wave3-runtime-bridge-20260327/run-card.yml`
  `/.octon/state/evidence/disclosure/runs/run-wave4-benchmark-evaluator-20260327/run-card.yml`
- refreshed build-to-delete review packet:
  `/.octon/state/evidence/validation/publication/build-to-delete/2026-03-30/`

## Gate Mapping

- Gate A: run-first execution is real
  `workflow run` now accepts `run-id`, run contracts/manifests point at the new
  canonical disclosure roots, and mission remains continuity context only.
- Gate B: authority is first-class and runtime-consumed
  `quorum-policy-v1` exists, approval artifacts now cite quorum policy, and the
  supported authority engine is exposed as a named runtime crate.
- Gate C: stage / attempt semantics are explicit
  run lifecycle binding and stage-attempt recording remain enforced under the
  canonical run roots.
- Gate D: proof planes are mandatory
  live assurance family and suites are aligned to the new supported tier and
  still gate the consequential run examples.
- Gate E: disclosure is canonical
  authored + retained disclosure roots now exist and the live validators point
  at them.
- Gate F: support-targets are runtime-active
  runtime admission stays fail-closed and the supported WT-2 label is now
  non-transitional.
- Gate H / J / K:
  disclosure mirrors are retired from the live path, explicitly registered as
  historical retained scaffolding, and the build-to-delete packet was refreshed.

## Residual Non-Blocking Risk

- the kernel Rust suite still shows an ACP-wrapper fixture race under the
  default parallel `cargo test` invocation; the authoritative serial run passes
  `30/30` after prebuilding `octon-policy`
