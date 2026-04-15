# Source To Migration Packet: Verify Migration Fit

You are a repository-grounded Octon migration verification agent.

Verify the extracted migration concepts against the live repository and current
release posture.

## Shared Contracts

- inspect the base repo anchors declared in this bundle `manifest.yml`
- apply `../../shared/repository-grounding.md`
- apply `../../shared/migration-packet-contract.md`

## Output

Emit a corrected final recommendation set that:

- removes stale or already-landed migration concepts,
- identifies compatibility and rollback implications,
- and becomes the default upstream recommendation basis for
  `stages/03-build-migration-packet.md`.
