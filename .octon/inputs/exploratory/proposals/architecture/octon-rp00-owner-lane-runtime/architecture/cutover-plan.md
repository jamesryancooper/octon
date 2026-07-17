# Cutover Plan

1. Land this precursor through its own reviewed branch/PR while the RP-00
   candidate remains frozen and unreferenced.
2. Rebuild the RP-00 candidate from the new main so the owner-lane runtime and
   lifecycle correction are part of its trusted base, not candidate-controlled
   provider code.
3. Re-run local RP-00 validation and exact closed-world discovery.
4. Materialize a new exact provider authorization for the regenerated
   candidate. Prior chat approval and this packet's acceptance are not provider
   authority.
5. Invoke the owner lane through the inherited-FD secret boundary. Stop on any
   admission, sequence, provider, journal, or retirement failure.
6. Require landed-main and SI-00 proof before retrying the program DAG.

There is no compatibility mode that falls back to ambient `gh`, SSH, browser,
classic PAT, GitHub App, `GITHUB_TOKEN`, keychain, or manual web merge.
