# Creation Prompt

Create a policy proposal packet for Octon's hybrid solo-first landing model.

The proposal should optimize for a solo maintainer who wants to ship quickly
without weakening safety, while remaining compatible with a very small trusted
team. It should keep PRs for high-risk, collaborative, externally reviewed, or
explicitly PR-requested Changes, and allow validated branch-isolated work to
fast-forward land on hosted `main` without a PR when provider rules permit it.

The packet must distinguish Octon-internal policy/tooling changes from
repo-local `.github/**` projection and live GitHub ruleset changes.
