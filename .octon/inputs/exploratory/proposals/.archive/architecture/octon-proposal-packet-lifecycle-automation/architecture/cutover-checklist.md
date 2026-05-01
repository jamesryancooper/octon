# Cutover Checklist

- proposal: `octon-proposal-packet-lifecycle-automation`

## Before Implementation

- [ ] Confirm no unrelated untracked proposal packets should be included in proposal registry regeneration.
- [ ] Confirm the whole-universe scope remains desired.
- [ ] Confirm the pack should be enabled rather than seeded disabled.
- [ ] Confirm host projections to update for Claude, Codex, and Cursor.

## During Implementation

- [ ] Create extension pack raw source.
- [ ] Add shared contracts.
- [ ] Add route prompt bundles.
- [ ] Add skills and command wrappers.
- [ ] Add validation fixtures and tests.
- [ ] Update instance extension selection.
- [ ] Publish extension state.
- [ ] Publish capability routing.
- [ ] Publish host projections.
- [ ] Run all validation commands.

## Before Staging

- [ ] Review generated outputs and evidence outputs.
- [ ] Exclude incidental build, cache, or scratch artifacts.
- [ ] Decide intentionally whether local prompt scaffolding or skill logs belong in the final changeset.
- [ ] Verify no raw pack path is used as runtime or policy authority.
- [ ] Verify proposal registry is regenerated only when all visible proposal packets are intended.

## Before Merge

- [ ] Required checks pass.
- [ ] Review conversations are resolved.
- [ ] Working tree is clean except intended closeout state.
- [ ] Proposal is promoted or archived according to lifecycle state.
- [ ] Local and remote branch cleanup plan is explicit.
