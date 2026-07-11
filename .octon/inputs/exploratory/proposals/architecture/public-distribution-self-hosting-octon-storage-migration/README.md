# Public Distribution Self-Hosting Octon Storage Migration

_Status: In review; implementation-grade complete; not accepted or authorized for implementation._

## Problem

The workspace tracks tens of thousands of state files and substantial generated output. Moving to local-first storage requires index changes under .octon, which cannot share one proposal with root-level .gitignore and workflow changes.

## Confirmed Current Evidence

- **Confirmed evidence:** The current commit tracks more than forty thousand state files and more than one thousand generated files.
- **Confirmed evidence:** State and generated outputs are architecturally mutable or rebuildable rather than authored framework source.
- **Confirmed evidence:** The private workspace may retain broader evidence than downstream defaults but should reduce high-churn hosted tracking.
- **Confirmed evidence:** Canonical proposal target rules require this .octon migration to remain separate from root Git policy.

## Target Outcome

Perform a classified, backup-protected, forward-only untracking migration for
high-churn `.octon` state, raw evidence, generated output, and heterogeneous
input subtypes while preserving canonical framework source, changing only the
exact reviewed instance retention contract, retaining compact required
receipts, and preserving local working bytes.

## Scope

- Inventory and classify current `.octon/state`, `.octon/generated`, and each
  `.octon/inputs` subtype without inspecting human-led ideation content.
- Retain required compact governance and release receipts by explicit allowlist.
- Verify encrypted backups before untracking private raw evidence.
- Remove classified high-churn files from future Git tracking without deleting local bytes.
- Rebuild generated outputs and prove no framework or non-excepted instance
  hash changed.

## Non-Goals

- No history rewrite, evidence deletion, externalization, or public publication.
- No root .gitignore, workflow, CODEOWNERS, or host projection changes.
- No untracking of canonical framework source or repository-specific authored
  instance authority; only the exact disclosure-retention contract may change
  under explicit maintainer review.
- No downstream-style replacement of framework source.

## Adopted Decisions Implemented

- **Sponsor decision:** The self-hosting workspace tracks canonical framework source and repository-specific instance authority.
- **Sponsor decision:** High-churn operational state, raw evidence, and generated output leave Git by default after classification.
- **Sponsor decision:** Compact publishable receipts remain when collaboration, governance, release, or recovery requires them.
- **Sponsor decision:** Migration is forward-only and preserves working files and existing history.
- **Sponsor decision:** Raw evidence deletion remains a separate maintainer-only action.

## Superseded Approaches

- **Removed or superseded:** Treating all private workspace state and generated output as hosted-required.
- **Removed or superseded:** Deleting local evidence as part of Git untracking.
- **Removed or superseded:** Rewriting history as a prerequisite for local-first migration.
- **Removed or superseded:** Applying downstream core retrieval to the framework-development workspace.

## Authority Boundary

This packet remains non-authoritative input. Durable authority can arise only
from separately reviewed implementation in the declared promotion targets.
Maintainer-only decisions and external effects remain explicit gates.
