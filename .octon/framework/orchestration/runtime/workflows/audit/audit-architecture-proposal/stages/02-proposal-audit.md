---
name: proposal-audit
title: Audit Architecture Proposal
description: Run deterministic completeness and consistency checks for the target architecture proposal.
---

# Step 2: Audit Architecture Proposal

## Actions

1. Load the target proposal from `proposal_path`.
2. Run the architecture proposal validator stack.
3. Identify every external tool, its supported interface, and the Octon-owned
   adaptation or enforcement surface.
4. Record as blocking any fork, patch, modification, reengineering effort,
   private derivative, undocumented internal dependency, or required upstream
   change.
5. Record any other blocking completeness or consistency gaps in the stage
   report.
