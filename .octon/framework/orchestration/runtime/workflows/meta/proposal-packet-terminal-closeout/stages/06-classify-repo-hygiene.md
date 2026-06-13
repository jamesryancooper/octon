---
title: Classify Repo Hygiene
description: Classify repo-hygiene residue and delegate cleanup only through authorized routes.
---

# Step 6: Classify Repo Hygiene

## Consumed Evidence

- Publication freshness evidence.
- Repo hygiene policy and helper contracts.

## Produced Evidence

- Repo-hygiene classification evidence.
- State ledger entry `classify-repo-hygiene`.

## Actions

1. Classify repo-hygiene residue.
2. Treat classification as evidence only, not deletion authority.
3. Delegate cleanup only to authorized repo-hygiene cleanup routes.
4. Require `repo-hygiene-cleanup-authorization-v1` evidence for cleanup.
5. Block if deletion occurred without validating authorization.

## Side Effect Class

Read-only classification plus retained evidence write.

## Re-Entry Condition

Re-enter when worktree status, generated scratch output, state evidence, or
repo-hygiene policy changes.

## Stop Condition

Stop with `blocked` and next route `repo-hygiene-cleanup` when cleanup is
required or authorization is missing.

## Receipt Fields

- `repo_hygiene.classification_ref`
- `repo_hygiene.cleanup_performed`
- `repo_hygiene.cleanup_authorization_refs`
- `repo_hygiene.unauthorized_deletion_performed: false`
- `state_ledger[].state_id: classify-repo-hygiene`
