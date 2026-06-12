# Target Architecture

## Decision

Add a terminal lifecycle proof layer for proposal-program closeout. The layer
does not replace proposal review, child receipts, implementation conformance,
post-implementation drift/churn, generated publication validators, Change
closeout, or branch-no-pr hosted checks. It makes the final `cleaned` claim
depend on fresh evidence produced after the last mutation that can stale a
proposal or generated artifact.

## Target Components

### Terminal Freshness Barrier

Introduce `validate-proposal-lifecycle-terminal-freshness.sh` as the terminal
validator for large proposal programs and proposal closeouts that touch
proposal packets, archives, generated proposal artifacts, generated effective
publication state, extension publication state, capability publication state,
or host projections.

The validator must:

- accept a parent program path or a single packet path;
- resolve active and archived packet paths from authoritative manifests and
  child indexes;
- run registry freshness checks after the last proposal status, archive, or
  support receipt mutation;
- run proposal artifact index generation in check mode for the parent and each
  declared child;
- run artifact spine validation for the parent and each declared child;
- run publication freshness checks when the touched-path set includes generated
  effective outputs, extension publication, capability publication, or host
  projections;
- reject stale digests, missing compact artifacts, stale publication receipts,
  unsupported aliases, proposal-path authority leakage, and parent summaries
  standing in for child receipts;
- emit a retained freshness receipt under a state/evidence run root.

### Aggregate Correction-Branch Receipt

Add `lifecycle-correction-branch-aggregate-receipt-v1.schema.json` for
post-primary correction branches in branch-no-pr lifecycle runs.

The aggregate receipt is evidence-only. It records:

- primary change id and primary landing ref;
- every follow-up correction branch, source ref, commit ref, landing
  authorization ref, branch cleanup authorization ref, validation refs, and
  cleanup outcome;
- generated artifacts or publication states refreshed by each correction;
- final landed ref, rollback handle, local-main sync proof, and unresolved
  count;
- explicit non-authority classification.

The receipt must not authorize branch landing, branch cleanup, closeout,
promotion, archive, publication, or mutation. It only makes the final lifecycle
history self-contained after multiple correction branches.

### Terminal Current-State Proof Bundle

Add `lifecycle-terminal-current-state-proof-v1.schema.json` for `cleaned`
claims. The proof bundle records the current repository state observed after
landing, cleanup, generated publication, and residue classification.

Required fields include:

- command/runtime refs for `git status --short --branch`, `git rev-parse HEAD
  main origin/main`, branch absence checks, temp-path absence checks, and the
  local run artifact cleanup classifier;
- final `HEAD`, `main`, `origin/main`, and landed ref equality or containment
  facts;
- worktree cleanliness or retained-residue classification;
- cleanup classifier counts;
- terminal validator refs and exit statuses;
- evidence refs for branch landing, branch cleanup, generated freshness, and
  correction aggregation when applicable;
- explicit statement that the bundle is evidence-only.

### Scoped Terminal Child Validation

Add a scoped terminal child validation mode for proposal programs. It should
read the parent child registry and validate only the declared child set, active
or archived, rather than scanning unrelated archived proposals during terminal
closeout.

The scoped mode is valid only when:

- a parent child registry exists and passes structure validation;
- every child has its own manifest, readiness, conformance, drift/churn,
  closeout, and archive evidence appropriate to its lifecycle state;
- every child artifact spine validates;
- a separate registry freshness check has passed once at the program level;
- the validator records why the scoped check covers the remaining terminal
  risk.

### Compact Validator-Log Handling

Codify a compact validation-log artifact for long validators. A compact log is
valid evidence only when it records command, cwd, canonical runtime path, start
and end time, exit code, full-log digest when a full log exists, bounded
excerpts, and the retained evidence ref. It does not replace structured
receipts or validator results.

### Canonical Validator Runtime Resolution

Add a lightweight standard for resolving canonical validator commands before
waiving or skipping a gate. The target behavior is:

- use repo-local validator scripts under
  `.octon/framework/assurance/runtime/_ops/scripts/`;
- use the repository-compatible shell/runtime required by the validator;
- record corrected invocations when an initial path or shell fails;
- treat runtime resolution as validation hygiene, not as authority to weaken
  the gate.

## Authority Boundaries

- Generated artifacts are derived-only.
- Proposal-local packets and parent summaries are temporary and
  non-authoritative.
- Terminal proof bundles are retained evidence only.
- Aggregate correction receipts are retained evidence only.
- Validator logs are validation evidence only and never replace schemas,
  receipts, or canonical state.
- Host state, chat, model memory, dashboards, tool availability, and raw inputs
  are never authority.
