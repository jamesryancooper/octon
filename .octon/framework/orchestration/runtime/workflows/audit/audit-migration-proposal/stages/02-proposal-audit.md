---
name: proposal-audit
title: Audit Migration Proposal
description: Run deterministic completeness and consistency checks for the target migration proposal.
---

# Step 2: Audit Migration Proposal

## Actions

1. Load the target proposal from `proposal_path`.
2. Run the migration proposal validator stack.
3. Record any blocking completeness or consistency gaps in the stage report.
