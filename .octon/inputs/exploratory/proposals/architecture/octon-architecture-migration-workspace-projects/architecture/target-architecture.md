# Target Architecture

## Decision

Implement FD-019 as a minimal, non-authoritative Workspace Project layer.
Project records provide durable identity and narrowing facts. Existing
workspace, mission, Run Contract, support, policy, and authority surfaces retain
their current precedence.

## Durable Record Model

The authored root is `.octon/instance/locality/projects/`:

```text
projects/
  registry.yml
  <project-storage-key>/
    project.yml
    revisions/
      <revision>.yml
    profiles/
      <revision>.yml
```

`project-storage-key` is path-safe and maps one stable project ID to its
records. `registry.yml` and `project.yml` select one immutable project revision
and one immutable Profile revision by exact ref and digest. A project revision
contains only the strict fields needed for:

- project and repository identity;
- lifecycle state;
- normalized repository-relative roots, exclusions, and protected paths;
- explicit monorepo parent/child and cross-project read/build relationships;
- Profile ref and digest;
- validation, preview, deployment, rollback, context, evidence, and continuity
  defaults as descriptive/narrowing inputs;
- operator-correction lineage; and
- predecessor revision and digest.

The schema uses `additionalProperties: false`. Extension fields require a
versioned schema change; authority-shaped unknown fields are rejected.

## Identity and Relocation

Project identity is not the filesystem path. A same-repository relocation
preserves project identity and authored boundaries because boundaries are
normalized repository-relative paths. The rebuildable location index lives in
mutable continuity/read-model state and contains no permission. A clone, fork,
conflicting local identity, or ambiguous overlap fails project selection closed
until explicitly adopted or corrected.

## Project Profile Relationship

Workspace Project owns durable identity, logical boundaries, relationships,
and the active project/Profile selection. Project Profile owns evidence-backed
facts such as toolchains, commands, CI posture, validation strategy, protected
zones, and known risks.

Only an explicit, schema-validated Profile whitelist can enter downstream
compilation. Extra Profile facts may remain descriptive, but they cannot become
scope, support, capability, credential, or authorization inputs. A run records
the selected project revision ref/digest and Profile ref/digest and never
silently follows a later refresh.

## Inference, Refresh, and Corrections

Inference uses repository markers, current path, touched paths, existing
records, and operator selection to produce a candidate project match. It does
not create permission. Durable record activation follows the repository's
canonical change/authority route available at implementation time; RP-10 does
not add a writer or broker.

Operator corrections are durable and outrank future inference. Factual or
narrowing refreshes may prepare successor revisions. Boundary expansion,
protected-zone relaxation, new external paths, or other widening changes use
the appropriate higher-consequence route and cannot affect an active run.

## Monorepo and Overlap Rules

- one repository has one `.octon` control root;
- nested logical projects declare explicit parent/child relations;
- the deepest explicit project owns a matched path for selection purposes;
- parent membership never grants child write access;
- ambiguous or undeclared overlap blocks only the affected selection;
- cross-project writes require an explicitly scoped multi-project run under
  existing authority; and
- project relations never authorize access by themselves.

## Mission Continuity and Inbox

Mission authority remains in the canonical mission charter and control roots.
RP-10 adds project identity to continuity/read-model records and one read-only
command, `octon mission inbox`, that lists:

- project ID and concise display name;
- mission ID and current canonical status;
- last trusted continuity checkpoint;
- the next eligible operator-visible action; and
- the exact status or resume command.

The inbox derives its result from mission authority, current control state, and
continuity. It writes nothing, cannot resume work itself, and cannot override a
blocked, revoked, or closed mission.

## Source-of-Truth and Writer Rules

| Data | Canonical or planned owner | Writer rule |
| --- | --- | --- |
| Project schema | Framework runtime/constitutional contracts, RP-10 entry | Versioned authored change only |
| Project registry and active revision pointers | Instance locality, RP-10 | Existing governed repo change route; no RP-10-specific writer |
| Immutable project/Profile revisions | Instance locality, RP-10 | Publish once; never rewrite referenced revisions |
| Location index | Continuity/read-model state | Rebuildable; never authority |
| Mission authority/control | Existing mission owners | Unchanged by RP-10 |
| Inbox output | RP-10 CLI read model | Read-only, ephemeral or derived |
| Run authorization | RP-01/existing authority engine | Project data can only narrow |

This design introduces no second control plane and no second writable runtime
store.

## Exact Selected Mechanisms

`resources/workspace-project-design-and-dependency-receipt.yml` selects
`prj_<UUIDv7>` identity assigned once by governed adoption, strict RFC-8785
JSON/SHA-256 immutable revisions, a sorted registry and generation-bound active
pointers under `.octon/instance/locality/projects/`, and path-independent
repository discovery. Clone/fork or copied-ID disagreement blocks until an
explicit relocation or new-adoption receipt; identity is never inferred from a
path or remote alone.

Boundaries are repository-relative NFC POSIX paths verified no-follow from the
canonical root. Symlink, mount, Unicode/case alias, traversal, and unrecorded
overlap deny. Explicit reciprocal parent/child relations permit most-specific
selection. Operator-locked corrections outrank accepted prior facts, current
source facts, and deterministic defaults; refresh never rewrites history or
unlocks a correction.

Run admission freezes exact project/revision/Profile/boundary/RP-01 digests
once. The location index is rebuildable and non-authoritative. The read-only
inbox scans at most 10,000 missions, returns 50 by default/100 maximum in a
stable action/status/time/project/mission order, and invalidates its cursor on
source-digest drift; it performs no mission or project write.

## Availability and Degraded Operation

If the project registry is missing, corrupt, digest-mismatched, or ambiguous,
new project-bound runs fail closed for the affected project. Existing active
runs retain their pinned refs and digests. Candidate work remains preservable,
unrelated projects remain usable, and the operator receives the shortest
repair command. A missing location index is rebuilt automatically and never
blocks on authority grounds by itself.

## Unsupported Remainder

The target does not support portfolio workflows, team administration,
project-derived grants, arbitrary cross-repository writes, automatic conflict
resolution, nested Octon installations, or a project database separate from
the existing repository model.
