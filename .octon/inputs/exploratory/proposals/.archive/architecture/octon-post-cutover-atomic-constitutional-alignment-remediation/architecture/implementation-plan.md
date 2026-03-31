# Implementation Plan

## Execution posture

This remediation is a **single-branch atomic alignment pass**.

Rules:

- do not create a new staged coexistence layer
- do not leave a subset of active family files on old receipt semantics after merge
- do not leave broad live support claims in place while promising future proof
- do not merge the validator hardening after the semantic changes; it must land in the same atomic change

## Workstream A — baseline freeze and reconciliation

1. Preserve the supplied independent evaluation in `resources/user-supplied-independent-evaluation.md`.
2. Record current HEAD reconciliation in `resources/current-head-reconciliation.md`.
3. Freeze the March 30 live-model selector as the reference truth for the rest of the packet.

**Output:** one agreed baseline and one explicit statement of what is already fixed vs still open.

## Workstream B — constitutional family live-model normalization

1. Update active family manifests under:
   - `objective/`
   - `authority/`
   - `runtime/`
   - `assurance/`
   - `retention/`
2. Repoint live receipt semantics to the March 30 atomic cutover receipt.
3. Preserve earlier phase receipts only as explicit lineage.

**Output:** every active family agrees with the charter manifest about the live constitutional model.

## Workstream C — bootstrap authority-surface correction

1. Edit `/.octon/instance/bootstrap/START.md`.
2. Remove raw additive inputs from any authored-authority list.
3. Add explicit extension-publication-chain wording.
4. Verify parity against `/.octon/README.md` and the umbrella architecture spec.

**Output:** no remaining authored-authority leak in bootstrap orientation.

## Workstream D — support-target and disclosure claim correction

1. Inspect every currently published compatibility tuple and adapter envelope.
2. For each envelope:
   - keep as live only if retained proof exists, or
   - demote to experimental/stage-only or unsupported
3. Rewrite authored HarnessCard summary and retained release HarnessCard summary to the proved envelope.
4. Preserve the already-correct disclosure roots and historical-mirror semantics.

**Output:** live claims become no broader than retained proof.

## Workstream E — documentation and owner normalization

1. Rewrite `.octon/**` portability/self-containment wording to evidence-bounded language.
2. Normalize subordinate owner identifiers to `octon-maintainers`.
3. Record repo-local non-`.octon/**` aftercare items separately rather than mixing scopes.

**Output:** live claim docs become truthful and subordinate governance identifiers become durable.

## Workstream F — validator and workflow hardening

1. Add the new validator scripts under the existing assurance runtime script surface.
2. Wire them into `alignment-check.sh`.
3. Make publication fail closed from `assurance-gate.sh` when any of the new checks fail.
4. Emit validation receipts under a retained publication/validation root.

**Output:** these drift classes cannot silently recur.

## Workstream G — closeout and claim refresh

1. Re-run the full alignment profile.
2. Refresh any affected release disclosure packet.
3. Record proof of the narrowed live envelope.
4. Confirm that no active family still points only at a phase receipt.
5. Confirm that no `.octon/**` live support doc uses placeholder owners or broad unsupported claims.

**Output:** one truthful post-cutover alignment release.

## Merge discipline

This packet intentionally treats the following as one merge unit:

- family semantics
- bootstrap authority fix
- support/disclosure claim narrowing
- owner normalization
- validator hardening

If these land separately, the repo may temporarily publish contradictory live semantics. That is exactly what this atomic pass is meant to eliminate.
