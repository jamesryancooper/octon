# Repo Internal Concept Mining Bundle Contract

- input type: repo-native artifacts such as ADRs, exploratory notes, repo
  paths, or internal design docs
- output type: architecture proposal packet
- mining rule: treat repo-native artifacts as source material, not as already
  promoted authority
- validators:
  - `validate-proposal-standard.sh --package <packet-path>`
  - `validate-architecture-proposal.sh --package <packet-path>`
