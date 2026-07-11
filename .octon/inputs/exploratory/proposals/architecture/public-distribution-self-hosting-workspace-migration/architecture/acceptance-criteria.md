# Acceptance Criteria

## AC-01

Workspace root policy identifies the repository as private self-hosting source,
and the versioned `.githooks/pre-push` guard blocks pushes to the public
distribution repository identity. Before the original `owner/octon` name is
reused, the active clone and every known writer from the legacy transition
inventory target the private workspace identity. Simulated pushes to both the
new public identity and the stale original-name URL are rejected before object
transfer, while approved private destinations pass. The `core.hooksPath`
activation and private-remote cutover are recorded in the run journal as
manual migration steps.

## AC-02

Active workspace workflows contain no cross-repository PAT requirement, generated-effective release commit, or automatic public distribution publication.

## AC-03

CODEOWNERS names valid ownership or is removed; no placeholder account remains.

## AC-04

.codex, .claude, and .cursor content is classified per content class: the projected `commands/` and `skills/` trees under all three roots, plus the projected `rules/` trees under `.codex/` and `.cursor/`, become local-only regenerable and leave tracking; `.claude/settings.json` stays committed as hand-maintained workspace host policy; `.claude/settings.local.json` and `.codex/config.toml` remain machine-local and never tracked. Untracking preserves local files plus regeneration capability.

## AC-05

`.gitignore` expresses the approved local-first defaults and is in place before
the Octon-internal storage migration begins. Host defaults remain
`/.codex/`, `/.cursor/`, and `/.claude/*` with
`!/.claude/settings.json`, while `.githooks/` remains tracked. The same
validator derives exact ignore rules and bounded exceptions for
`.octon/state/**`, `.octon/generated/**`, and each classified
`.octon/inputs/**` subtype from `repository-git-posture-v1.yml`. That earlier
contract defines bounded hosted-exception classes without depending on the
later storage-migration allowlist. After migration, an approved local-only path
cannot be re-added without an explicit path in the later allowlist that also
falls inside a predeclared exception class.

## AC-06

The migration is forward-only, retains existing history, and has a tested index-only rollback.

## Aggregate Gate

All criteria above must pass on the exact reviewed implementation revision.
A general statement that tests pass is insufficient; evidence must identify
the behavior, boundary, negative case, and retained receipt.
