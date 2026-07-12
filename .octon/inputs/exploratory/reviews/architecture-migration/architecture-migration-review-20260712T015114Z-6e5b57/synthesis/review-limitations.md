# Review Limitations

- The sibling review tree was excluded and never consulted. This preserves
  independence but intentionally prevents comparison or global status claims
  about that tree.
- Provider observations are point-in-time, read-only GitHub API/CLI evidence.
  No provider mutation, malicious PR, ruleset change, or credential use was
  attempted.
- Secret values were never read or retained. Secret names and credential-source
  metadata do not prove a candidate actually used or exfiltrated them.
- Static launch and writer searches are bounded; they provide high confidence,
  not mathematical proof that no differently named external component exists.
- Authority, lifecycle, runtime-bus, hosted no-PR, and selected negative tests
  were executed. Concurrent consume, crash/power-loss, target race, hostile Git,
  sandbox escape, duplicate provider context, evidence rechain, compaction,
  and trust activation were not.
- Deployment-local evidence size reflects this checkout and includes local
  generated/untracked state. Tracked evidence size is a repository floor, not
  a universal production forecast.
- Current provider behavior can change after review; proposal implementation
  must rebind rulesets, permissions, workflow versions, and secrets metadata.
- The intake integrity index validated bytes and the ordered package was read;
  integrity does not make intake claims current or authoritative.
- The review proposes contracts, packets, and gates but does not approve them,
  create an ADR, promote architecture, authorize credentials, or authorize
  implementation/publication/activation.
- Exact line citations are bound to commit
  c5b1f5760c78ff521cca6b054e4e8fef5300505b and may move in later revisions.
