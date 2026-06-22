# Acceptance Criteria

- `closeout-worktree` can return a non-mutating partition report when ownership is provable.
- The report records classifier output refs and digests, include paths, exclude paths, ownership basis, and disposition.
- Foreign/manual residue can be preserved and excluded from the named lifecycle blocker without deletion or mutation.
- Ambiguous ownership returns a nonterminal report with blocker evidence.
- Validators reject partition reports that claim cleanup, archive, publication, branch mutation, child closeout, Change receipt replacement, or terminal delivery authority.
- Lifecycle interaction return evidence cites the wrapper report without transferring authority.
