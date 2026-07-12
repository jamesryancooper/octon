# Preflight and Integrity

## Result

Baseline normalization and immutable-input integrity passed. The process variance is that Architect B's cross-review was produced by an explicitly labelled third-party substitute because the original Architect B was unavailable.

## Baseline

- Repository: `git@github.com:jamesryancooper/octon.git`
- Branch: `main`
- Normalized commit: `c5b1f5760c78ff521cca6b054e4e8fef5300505b`
- Commit time: `2026-07-11T16:56:55-05:00`
- Current `HEAD...origin/main`: `0 0`
- Original review baselines: same clean commit and host; no repository delta required.
- Git-visible state: tracked/staged clean outside the allowed review tree; no untracked path outside `.octon/inputs/exploratory/reviews/`.
- Limitation: ignored caches/local state were not exhaustively fingerprinted.

## Immutable integrity

`shasum -a 256 -c provenance/integrity-index.sha256` passed for:

- Intake: 94/94 indexed artifacts; index SHA-256 `a99768d03184effc455671d1292f8c0c54459d7efcf8c0ec71bb4f7d44a14873`.
- Review A: 56/56 indexed artifacts; index SHA-256 `c55a45862b95a00a608c2c7cc3949a14b95c10e2acf3a424602f5db3fe675633`.
- Review B: 46/46 indexed artifacts; index SHA-256 `968d8f48d94471c11b95e20ace6c7b179d4edd8bbab7c4fa6f2d261b08f70eba`.

The indexes validate intentional artifacts, not filesystem totality. The intake contains three unindexed `.DS_Store` files, Review A one, and Review B two; each index also excludes itself. These metadata files were not used as evidence.

## Cross-review packages

- Architect A package: original-author cross-review; exactly eight required files; six YAML files parse.
- Architect B package: third-party substitute, clearly labelled; exactly eight required files; six YAML files parse.
- Both verdicts: `READY_FOR_PROPOSAL_PROGRAM`.
- Architect A assessed 25 grouped material claims; Architect B substitute assessed 20.
- Architect A self-corrections now have stable IDs `A-SC-001` through `A-SC-010`.
- Five initially invalid Architect A repository refs were corrected to current exact paths before reconciliation completion.

## Decision coverage

Both original decision crosswalks contain exactly one FD-001 through FD-024 record. The reconciled decision and proof registers cover all 24 exactly once.

Review B's status summaries are internally inconsistent:

- manifest: 2 satisfied, 9 partial, 8 contradicted, 5 absent;
- crosswalk summary: 2, 8, 8, 5 (total 23);
- actual per-decision records: 2, 9, 9, 4.

The reconciliation therefore uses the per-decision records plus explicit cross-review corrections, not Review B's summary counts. Review B also uses shorthand `A-01` through `A-07` for expanded finding IDs; reconciliation cites the expanded subject or stable reconciled ID instead.

## Source-boundary compliance

Only the repository, intake, the two named original reviews, and the current reconciliation were admitted. Current reconciliation artifacts mention only the permitted review IDs. Manifests, allowlists, reviewer declarations, inspected-path reports, and artifact scans support the claim that unrelated sibling reviews were not used. This is bounded process evidence, not a complete operating-system read audit.

No provider mutation, commit, push, merge, rebase, reset, stash, cleanup, or workflow dispatch occurred.

## Evidence traceability

- Original review references used by cross-review resolve.
- Current repository references were path/line checked; the five cross-review path defects discovered during preflight were corrected.
- Review A's out-of-range FD-017 source range was not propagated.
- Provider evidence is point-in-time and clearly separated from committed repository fact.
- Dynamic labels were narrowed where tests did not execute the claimed concurrency/crash behavior.

## Original-review immutability

Both original integrity indexes passed again after cross-review generation and reconciliation drafting. No original review artifact was rewritten.

## Completion checks

All terminal checks passed:

- all 33 reconciliation YAML files parse and the JSONL command log parses line by line;
- both cross-review packages contain exactly eight required files and six valid YAML files;
- all 24 decisions and all 24 proof obligations are present exactly once;
- all 32 comparison topics, 18 disagreements, and 33 findings are dispositioned and traceable;
- the 14-workgroup and 15-packet graphs have no missing dependency or cycle, every packet has one workgroup owner, and source-of-truth ownership is exclusive;
- RF-028 through RF-033 and every earlier finding map to their owning packet, with positive readiness finding RF-020 explicitly non-blocking;
- no prohibited architecture is restored and unresolved facts are not represented as consensus;
- no Mermaid artifact exists in this package, so Mermaid validation is not applicable;
- only the two permitted review IDs occur in the package;
- tracked/staged repository state remains clean outside the allowed review tree, no untracked path exists outside it, and both original review indexes still pass;
- the command log records cross-review, reconciliation, subagent, challenge, validation, containment, and closeout activity; and
- `provenance/integrity-index.sha256` validates all 50 other package artifacts and excludes itself.
