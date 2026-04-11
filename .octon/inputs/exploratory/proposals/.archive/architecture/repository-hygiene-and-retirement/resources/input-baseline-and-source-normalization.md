# Input Baseline and Source Normalization

## Source bundle used for this packet

No external audit file, ADR, or design note was uploaded in this turn. The
packet therefore normalizes the following sources into one in-scope source-item
register:

1. the user's initial Rust + Shell cleanup request;
2. the user's follow-up about migration leftovers, shims, and similar
   transitional residue;
3. the user's detailed capability-spec request for repository hygiene and
   transitional-surface retirement; and
4. the user's current request for a manifest-governed architecture proposal
   packet.

The live repository is then used to verify what is already true, what is
missing, and which design options are invalidated by existing authority.

## Extraction method

1. read the user-provided source materials and preserve them under
   `resources/source_inputs/**`;
2. extract candidate obligations, constraints, and non-goals;
3. inspect live repo authority, governance, proposal, runtime, and CI surfaces;
4. collapse overlapping requirements into one source-item register;
5. resolve conflicts using live repo authority and proposal contract
   precedence;
6. produce one definitive in-scope set for the packet.

## Conflict resolution

### Conflict A — generic or Python-centric cleanup model vs live repo reality

- user requirement: solve repository hygiene for a Rust + Shell repo;
- rejected option: translate the Python `ruff + vulture` pattern directly;
- repo resolution: use Rust + Shell native tooling because the live runtime is
  a Rust workspace and the repo is heavily shell-driven through validators and
  workflows.

### Conflict B — parallel transitional registry vs existing retirement spine

- earlier exploratory design space suggested a dedicated transitional registry;
- live repo already has retirement policy, registry, register, reviews,
  ablation workflow, claim gate, and release lineage;
- resolution: consolidate onto the existing retirement/build-to-delete plane.

### Conflict C — complete implementation program vs active proposal scope rule

- the implementation needs `.octon/**` authority edits and `.github/**`
  workflow integrations;
- the active proposal contract forbids mixing `.octon/**` and non-`.octon/**`
  promotion targets;
- resolution: keep official promotion targets under `.octon/**`, and model
  `.github/**` edits as explicit dependent implementation surfaces.

## Final normalized in-scope source-item set

| Source ID | Normalized item | Primary origin | Why in scope |
| --- | --- | --- | --- |
| SI-001 | reject direct Ruff/Vulture translation | initial user request | user explicitly asked for Rust + Shell guidance, not Python tooling |
| SI-002 | detect static dead Rust code | initial user request | core problem statement |
| SI-003 | detect unused Rust dependencies | initial user request | core problem statement |
| SI-004 | detect shell/script orphans | initial user request | repo is Shell-relevant and this was explicitly requested |
| SI-005 | detect stale generated outputs and repository bloat | initial user request | core problem statement |
| SI-006 | detect transitional residue such as migration leftovers and shims | follow-up user request | explicitly added by the user |
| SI-007 | define a strict decision grammar for findings | capability-spec request | required for governed action |
| SI-008 | reuse existing retirement governance; reject a parallel plane | capability-spec request + live repo evidence | explicit constraint plus repo-grounded fit |
| SI-009 | choose the correct Octon-native implementation shape | capability-spec request | central architecture decision |
| SI-010 | remain fail-closed, support-bounded, ACP-aligned | capability-spec request | explicit governance constraint |
| SI-011 | define evidence, ablation, receipts, and same-change updates | capability-spec request | required for trustworthy operation |
| SI-012 | satisfy the current proposal packet contract | packet-generation request | this packet itself must conform |
| SI-013 | emit a profile selection receipt and cutover model | packet-generation request + ingress/workspace rules | explicit contract requirement |
| SI-014 | preserve full implementation traceability despite active-scope target-family limits | packet-generation request + proposal standards | necessary to keep the packet both valid and complete |

## Assumptions and ambiguities

- No external audit ids are available, so source ids are packet-local rather
  than imported from a prior audit.
- The architecture packet is responsible for a complete implementation program,
  but not for executing that program now.
- Repo-local workflow integrations are treated as dependent implementation
  surfaces because the active proposal standard forbids mixed target families.

## Excluded items

No user-provided source item was silently excluded. Items that remain deferred
are recorded explicitly in `architecture/follow-up-gates.md` and
`resources/rejection-ledger.md`.
