# Implementation Plan

1. Extend closeout-worktree documentation and I/O contract for autonomous non-mutating partition reports.
2. Extend classifier output or wrapper report fields to record ownership basis, include paths, exclude paths, classifier digest, foreign fingerprint, and non-mutating disposition.
3. Extend lifecycle interaction return handling to cite partition reports without transferring authority.
4. Extend wrapper validation to reject any partition report that claims deletion, staging, commit, push, archive, publication, branch cleanup, child closeout, or terminal delivery authority.
5. Add fixture coverage for provably owned partition, foreign/manual residue, ambiguous residue, protected evidence, and invalid mutating report claims.

This child must not implement lifecycle loop breaking, route leases, or polluted-run supersession.
