# Evidence Plan

## Purpose

Define the evidence burden that the future implementation must satisfy so the
capability can be claimed as landed without relying on prose assertion.

## Evidence families

| Evidence family | Root | Purpose |
| --- | --- | --- |
| routine hygiene audits | `/.octon/state/evidence/runs/ci/repo-hygiene/<audit-id>/` | baseline and scheduled scan evidence |
| build-to-delete packet attachment | `/.octon/state/evidence/validation/publication/build-to-delete/<packet>/repo-hygiene-findings.yml` | closure-grade hygiene proof |
| governance review evidence | `/.octon/state/evidence/governance/build-to-delete/**` | claim/readiness review outcomes |
| release disclosure evidence | `/.octon/state/evidence/disclosure/releases/**` | active release and closure certificate context |

## Minimum routine audit outputs

- `audit-summary.yml`
- `findings.yml`
- `blocking-findings.yml`
- `summary.md`

## Minimum closure-grade outputs

- `repo-hygiene-findings.yml` attached to the active build-to-delete packet
- same-change updates to `retirement-registry.yml` and `retirement-register.yml`
  when new transitional or historical surfaces are registered
- any required ablation/deletion receipt updates when delete/demote actions are
  evaluated

## Evidence rules

1. Packet-local copied sources are review aids only; they are not durable repo
   evidence.
2. A baseline audit is mandatory before implementation closure can be claimed.
3. Closure-grade certification requires two consecutive clean validation passes.
4. Current claim-bearing release artifacts remain protected; hygiene evidence
   may refer to them but not replace them.

## Evidence sufficiency tests

Evidence is sufficient only when it proves all of the following:

- the capability exists structurally;
- the capability runs on the live repository;
- blocking findings are controlled by policy, not hand-waved away; and
- closure claims are backed by retained artifacts in the correct roots.
