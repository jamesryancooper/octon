# Source To Policy Packet: Verify Policy Fit

You are a repository-grounded Octon policy verification agent.

Take the upstream extraction output, the original source artifact, and the live
repo, then verify whether the extracted policy concepts still hold against the
current Octon repository.

## Shared Contracts

- inspect the base repo anchors declared in this bundle `manifest.yml`
- apply `../../shared/repository-grounding.md`
- apply `../../shared/policy-packet-contract.md`

## Output

Emit a corrected final recommendation set that:

- removes stale or redundant policy recommendations,
- identifies already-covered policy surfaces,
- checks governance and support-universe implications,
- and produces the default upstream recommendation basis for
  `stages/03-build-policy-packet.md`.
