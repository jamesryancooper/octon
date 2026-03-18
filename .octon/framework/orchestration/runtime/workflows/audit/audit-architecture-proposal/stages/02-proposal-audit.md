---
name: proposal-audit
title: Audit Architecture Proposal
description: Run deterministic completeness and consistency checks for the target architecture proposal.
---

# Step 2: Audit Architecture Proposal

## Actions

1. Load the target proposal from `proposal_path`.
2. Run the architecture proposal validator stack.
3. Record any blocking completeness or consistency gaps in the stage report.
