# Target Architecture

## Decision

Add `repo-hygiene-cleanup-authorization-v1` as a retained, machine-checkable
authorization receipt for post-closeout local residue cleanup. The receipt does
not authorize broad repo cleanup. It authorizes only an exact cleanup path set
after policy-backed classification proves every path is untracked,
unreferenced, non-authoritative, inside an allowed cleanup pattern, and outside
protected or manual-review classes.

## Receipt Shape

The durable schema should require:

- `schema_version`
- `authorization_id`
- `authorization_result`
- `created_at`
- `expires_at` or `valid_until_status_changes`
- `policy_ref`
- `helper_ref`
- `repo_root_ref`
- `head_ref`
- `main_ref`
- `origin_main_ref`
- `git_status_digest`
- `classification_ref`
- `classification_digest`
- `cleanup_path_set_digest`
- `authorized_paths`
- `protected_paths_digest`
- `manual_review_paths_digest`
- `discard_or_rollback_posture`
- `runtime_safety_boundary`

Each `authorized_paths` entry must include `path`, `class`, `pattern_id`, and
proof booleans for untracked, unreferenced by tracked files,
non-authoritative, allowed cleanup pattern, not input surface, not durable
evidence, not active control state, not generated authority, and not
ignored/user-owned residue.

## Cleanup Authority Boundary

Repo hygiene owns cleanup authorization. The local-run helper owns immediate
revalidation and path deletion. `Closeout Worktree` owns classification and
routing reports only. `Closeout Change` owns cleanup only inside the selected
Change route boundary and cannot claim global worktree hygiene.

Receipt-backed cleanup replaces repeated Octon-level `--confirm` only when the
receipt validates. It does not bypass filesystem permissions, Codex sandbox
approval, provider controls, host security prompts, or other runtime/platform
safety boundaries.

## Eligible Classes

Eligible autonomous cleanup classes are limited to untracked and unreferenced:

- local `publish-*`, `service-build-*`, and runtime-agent-quorum residue
- superseded publication receipts under already classified local-run patterns
- rebuildable scratch under `.octon/generated/.tmp/**`

Generated run-health stale paths are eligible only through the run-health
generator path that records `pruned_paths`, not through generic local-run
cleanup.

## Forbidden Or Manual Classes

The cleanup receipt must deny tracked files, referenced untracked files,
`.octon/inputs/**`, durable closeout receipts referenced by Change or wrapper
evidence, active control or continuity state, build-to-delete or claim-adjacent
evidence, host projections, ignored or user-owned local files, generated
effective authority outputs, generated run-health projections handled by the
generator, and any path outside explicit cleanup patterns.

## Helper Behavior

`cleanup-local-run-artifacts.sh` should keep dry-run as the default and retain
manual `--confirm` as a fallback. Add:

- `--authorize <out.json>` to classify current residue and write an approved or
  denied cleanup authorization receipt.
- `--authorization <receipt.json>` to recompute classification, re-scan tracked
  references, verify git/status/path-set digests, validate every authorized
  path, and delete only the exact authorized path set.

The helper must fail closed when the receipt is missing, malformed, denied,
stale, mismatched, path-drifted, or when any candidate is now tracked,
referenced, outside pattern, protected, or manual-review.

## Closeout Integration

`Closeout Worktree` should add repo-hygiene classification and next-route
fields to its report, including cleanup candidate counts, protected referenced
counts, manual-review counts, classification refs, optional authorization refs,
and `repo_hygiene_cleanup_actions_performed: false`.

`Closeout Change` should state that `cleaned` means selected route cleanup,
branch/source cleanup when applicable, local-main synchronization when claimed,
and route-bound residue disposition. Global residue remains repo-hygiene or
wrapper territory.
