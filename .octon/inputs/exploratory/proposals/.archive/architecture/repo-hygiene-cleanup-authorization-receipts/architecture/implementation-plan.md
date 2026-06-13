# Implementation Plan

## Workstream 1: Receipt Contract

Add `.octon/framework/product/contracts/repo-hygiene-cleanup-authorization-v1.schema.json`
with strict required fields, no additional properties by default, approved or
denied results, path-proof booleans, digest fields, and runtime safety boundary
text. Model the revalidation posture after branch cleanup authorization while
keeping the scope path-based rather than ref-based.

Update `.octon/instance/governance/policies/repo-hygiene.yml` so local artifact
hygiene allows receipt-backed cleanup as an alternative to manual `--confirm`
only when the receipt validates and the helper revalidates the exact path set.
Keep detection-only hygiene and ablation/retirement cleanup unchanged.

## Workstream 2: Helper Hardening

Extend `.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`
with `--authorize <out.json>` and `--authorization <receipt.json>`.

The helper should emit deterministic classification data, compute digests over
cleanup candidates, protected referenced paths, manual-review paths, current git
refs, and status, and revalidate those values before deletion. The deletion path
must remove only authorized cleanup candidates and retain all protected or
manual-review paths.

Reject generated run-health projection paths in the generic helper and route
them to `generate-run-health-read-model.sh --all-runs`, where pruning remains
generator-owned and recorded through `pruned_paths`.

## Workstream 3: Repo Hygiene Cleanup Skill

Add a narrow `repo-hygiene-cleanup` remediation skill under
`.octon/framework/capabilities/runtime/skills/remediation/repo-hygiene-cleanup/SKILL.md`.
Register it in the skill manifest, registry, and remediation group. The skill
should inventory residue, run helper classification, optionally emit an
authorization receipt, invoke helper cleanup only with a validating receipt or
manual fallback, and record run evidence under `.octon/state/evidence/runs/skills/`.

The skill must not become a new command, must not perform broad repo-hygiene
audit/enforce work, and must not treat proposal paths, generated projections,
ignored files, host metadata, or chat state as authority.

## Workstream 4: Closeout Boundary Updates

Update `Closeout Worktree` docs and report validator so wrapper reports can
record repo-hygiene classification refs, authorization refs, cleanup candidate
counts, retained/manual-review residue, and a next route condition while
requiring `repo_hygiene_cleanup_actions_performed: false`.

Update `Closeout Change` docs so cleaned outcomes cannot overclaim global
worktree hygiene. Route-bound cleanup remains part of Change closeout; unrelated
or global residue routes to the wrapper or `repo-hygiene-cleanup`.

## Workstream 5: Validators And Tests

Extend repo-hygiene governance validation to require the schema, policy text,
helper flags, docs, tests, and skill registration. Extend helper tests with
receipt-backed success and fail-closed negative cases. Extend closeout-worktree
validation so terminal reports cannot claim full worktree cleanliness while
repo-hygiene candidates or manual-review residue remain unresolved.

Run the proposal validators first, then implementation validators after durable
changes land.
