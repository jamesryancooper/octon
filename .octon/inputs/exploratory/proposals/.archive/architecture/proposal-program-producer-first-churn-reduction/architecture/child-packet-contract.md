# Child Packet Contract

This parent program coordinates ten sibling child packets, nine core packets
and one optional adjacent packet.

## Authority Boundary

The parent may coordinate ordering, dependency gates, aggregate risk, metrics,
external dependency references, and closeout readiness. The parent must not
edit or satisfy child manifests, child receipts, child promotion targets,
child validation verdicts, child archive metadata, child cleanup
dispositions, or child terminal outcomes.

## Producer-First Rule

Every child must name the generator, publisher, validator, lifecycle writer,
or cleanup route that creates the churn. The primary fix must be made at that
producer entrypoint. Path cleanup is allowed only when the same producer or an
owning cleanup route classifies exact files as rebuildable, stale, or
unreferenced.

## Child Duties

Each child owns:

- target surfaces;
- generator or producer owner;
- producer entrypoint inventory;
- current problem;
- intended efficiency improvement;
- guardrails;
- validation gates;
- measurable success criteria;
- dependencies on existing packets when applicable.
- applicable common metrics from `resources/metrics.md`.

## Required Implementation Handoff

Before any child can move from draft planning into implementation readiness,
it must include:

- exact producer entrypoints, validators, writers, cleanup routes, and
  consumers in scope;
- external dependencies and how they are consumed without duplication;
- support-claim, authority, freshness, closeout, cleanup, and retained-evidence
  negative controls applicable to the child;
- common metrics the child will report before and after implementation;
- compatibility or migration plan for consumers when output shape changes;
- refusal criteria for cleanup or compaction that would erase evidence, reuse
  stale freshness, or widen authority.

## Parent Duties

The parent owns only program coordination artifacts:

- `resources/child-packet-index.yml`
- `resources/child-packet-index.md`
- `resources/churn-class-table.md`
- `resources/metrics.md`
- `architecture/packet-sequence.md`
- `architecture/child-packet-contract.md`
- `architecture/program-closeout-plan.md`
- parent-local validation and closeout coordination evidence

## Negative Controls

- Generated outputs cannot become authored authority.
- Host projections cannot become authority or cleanup truth.
- Retained evidence cannot be deleted by generic cleanup.
- Source/framework/input/archive changes cannot be reclassified as generated residue.
- Parent summaries cannot satisfy child-owned receipts.
