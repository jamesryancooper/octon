# Acceptance Criteria

- AC-01: All strict lifecycle schemas validate the accepted RP-00 fixture and
  reject unknown fields, wrong versions, stale or mismatched bindings, and
  self-referential digest inputs. Two independent RFC 8785 construction paths
  produce byte-identical artifacts and digests.
- AC-02: Every provider mutation requires and consumes exactly one
  `AuthorizedEffect<ProviderRepositoryMutation>` bound to the exact run and
  manifest; bypass and replay tests fail before effect.
- AC-03: The runtime reads one fine-grained PAT only from an inherited FD and
  proves the token is absent from argv, environment, persistent files, logs,
  evidence, and ambient helpers.
- AC-04: The executor accepts only fixed GitHub.com HTTPS origins and the closed
  operation enum; arbitrary URL, method, path, Git remote, and request bodies
  are impossible through manifest data. External tool path/digest drift and
  `PATH` poisoning fail before credential capture.
- AC-05: Admission proves the exact login `jamesryancooper`, actor id `800837`,
  repository `jamesryancooper/octon`, API version, and required capability
  posture before the first mutation.
- AC-06: Each request has an append-only pre-send journal record. A terminal
  response is bound by digest; absent terminal response becomes outcome-unknown
  and permanently blocks resend without separate reconciliation authority.
- AC-07: HTTPS Git uses the fixed askpass helper and a one-use FIFO. The secret
  never enters the URL, refspec, argv, environment, config, or disk.
- AC-08: Conditional base/head/ruleset/marker/check/merge assertions fail closed
  on drift. Merge binds `sha` to the exact observed head.
- AC-09: The same token is submitted once, unauthenticated, to
  `/credentials/revoke`; subsequent `/user` probes require a genuine provider
  `401`, after which local buffers/FIFO are destroyed and a clean secret census
  plus retirement receipt is required.
- AC-10: The runtime adds no connector, daemon, database, credential proxy,
  general HTTP client surface, or generated authority. The existing GitHub
  tuple expands only to the exact `rp00-owner-lane-cutover` operation after a
  retained full hermetic runtime run and denial proof; all broader API and
  recurring automation remain excluded.
- AC-11: Only an explicit provider-authority blocker becomes
  `approval-required`; unrelated missing evidence remains missing evidence, and
  approval grants bind the exact child route/run/candidate/operation tuple.
- AC-12: Proposal, architecture, contract, runtime, adversarial, conformance,
  drift, rollback, and diff-hygiene gates all pass with current evidence.
