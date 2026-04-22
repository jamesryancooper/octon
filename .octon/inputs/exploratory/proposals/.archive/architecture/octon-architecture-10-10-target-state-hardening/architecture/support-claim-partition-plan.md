# Support Claim Partition Plan

## Objective

Prevent live support claims from being widened by flat directories, stage-only
surfaces, generated projections, pack admissions, adapter defaults, or mission
routes.

## Current posture

`support-targets.yml` declares a bounded support universe and distinguishes live
model/workload/context/locale/host/model/capability-pack elements from resolved
non-live surfaces. The architecture is directionally correct but the filesystem
shape should make claim state obvious without requiring readers to parse every
route field.

## Target layout

```text
.octon/instance/governance/support-target-admissions/
  live/
  stage-only/
  unadmitted/
  retired/

.octon/instance/governance/support-dossiers/
  live/
  stage-only/
  unadmitted/
  retired/
```

## Claim-state rules

| State | Meaning | Runtime effect |
| --- | --- | --- |
| `live` | Fully admitted, proof-backed, disclosure-backed, runtime-real tuple. | Eligible for live support claim when all validators pass. |
| `stage-only` | Explicitly non-live, may be staged or previewed under policy. | Cannot be claimed live; must not appear in final live disclosure. |
| `unadmitted` | Known but not admitted. | Deny or escalate; no runtime support claim. |
| `retired` | Formerly present, now removed from active claim. | No current route except historical lineage. |

## Required validators

Add `validate-support-pack-admission-alignment.sh` to check:

- every live tuple has live admission, live dossier, proof bundle, support card,
  representative run disclosure, and negative controls;
- every stage-only tuple is physically in `stage-only/` and has no live claim;
- no live tuple references an unadmitted pack or adapter;
- no active mission defaults to stage-only/non-live tier without explicit
  stage-only posture;
- generated support matrices cannot widen claim state;
- support-card disclosure cannot exceed `support-targets.yml` plus admissions.

## Cutover path

1. Create partition directories.
2. Move current live-supported admissions/dossiers into `live/`.
3. Move stage-only/boundary-sensitive/frontier/GitHub/Studio/browser/API-like
   surfaces into `stage-only/` or `unadmitted/` as appropriate.
4. Update `support-targets.yml` refs.
5. Update generated support matrix generator.
6. Add validation tests.
7. Retain migration evidence.

## Acceptance

A reader must be able to tell claim state from path placement before parsing the
file. Parsing must then confirm, not discover, claim state.
