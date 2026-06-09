# Governed Cross-Surface Mechanisms Documentation Architecture

This parent proposal program coordinates documentation architecture work for
Octon's governed cross-surface mechanisms.

It adopts this terminology:

- product docs: product features
- architecture and governance docs: governed cross-surface mechanisms
- runtime and operator docs: lifecycles, workflows, routes, state machines,
  receipts, command names, and skill names

## Purpose

The program turns the cross-surface mechanism architecture evaluation and the
documentation plan into a staged proposal program. The goal is to make Octon's
multi-surface mechanisms discoverable without weakening authority boundaries.

## Parent Boundary

This parent owns coordination only: child sequencing, child registry, aggregate
scope, aggregate risk, and closeout expectations.

It does not own child packet lifecycle truth, child validation verdicts, child
promotion targets, child receipts, child archive metadata, runtime state,
state/control truth, retained evidence, generated-effective authority, operator
read-model authority, Change closeout authority, worktree cleanup authority, or
repo hygiene cleanup authority.

## Child Packets

The structured child registry is `resources/child-packet-index.yml`. The human
navigation companion is `resources/child-packet-index.md`.

This parent is currently in a canonical-child-packet posture. Registry entries
name sibling child packets whose directories and child-owned manifests now
exist.

Child packet directories must remain siblings under
`.octon/inputs/exploratory/proposals/architecture/`. No child packet may be
nested under this parent package.

Before implementation prompt generation or program closeout, every required
child must have child-owned lifecycle truth, accepted review receipts,
readiness receipts, promotion targets, validation verdicts, and terminal
outcomes as required by the active lifecycle stage. The optional
`mechanism-detail-pages-and-operator-map` child exists but remains deferred
unless a later accepted parent mutation marks it required.

## Non-Authority Posture

This proposal program is exploratory input. It may guide future promotion work,
but it is not runtime authority, policy authority, support authority, retained
evidence authority, closeout authority, cleanup authority, or generated
effective state.
