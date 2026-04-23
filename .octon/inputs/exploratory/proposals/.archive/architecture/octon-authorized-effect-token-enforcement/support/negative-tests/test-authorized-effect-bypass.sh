#!/usr/bin/env bash
set -euo pipefail

# Proposal-local illustrative negative test. Promotion target should create the real validator/test.
# The real test should attempt each material family without a valid token and require fail-closed behavior.

case "${1:-}" in
  repo-mutation)
    echo "would attempt repo mutation without AuthorizedEffect<RepoMutation>; expected: DENY/FCR-023"
    ;;
  evidence-mutation)
    echo "would attempt evidence write without AuthorizedEffect<EvidenceMutation>; expected: DENY/FCR-023"
    ;;
  forged-token)
    echo "would attempt forged token not present in canonical token ledger; expected: DENY/FORGED"
    ;;
  *)
    echo "usage: $0 {repo-mutation|evidence-mutation|forged-token}" >&2
    exit 2
    ;;
esac
