# Risk Register

## R1: Delivery Becomes A Second Control Plane

- severity: high
- risk: The delivery workflow could be implemented as an authority source for
  proposal transitions, Git mutation, cleanup, publication, or archive.
- mitigation: Profile, receipt, workflow, and validators must enforce
  target-owned authority and non-authorizing context.

## R2: Parent Program Evidence Substitutes For Child Receipts

- severity: high
- risk: A parent proposal-program summary could be treated as enough evidence
  for child implementation, conformance, drift, closeout, or archive.
- mitigation: Delivery receipt validator must require every child-owned receipt
  and fail parent-summary substitution.

## R3: Branch-No-PR Route Overclaims

- severity: high
- risk: Delivery could claim landed or cleaned without closeout route evidence,
  landing authorization, branch cleanup authorization, final sync, and terminal
  proof.
- mitigation: Delegate route truth to closeout-change and require Change,
  authorization, final sync, and terminal proof refs before cleaned claims.

## R4: Generated Publication Drift

- severity: medium
- risk: Delivery could close after proposal archive or registry mutation while
  generated projections are stale.
- mitigation: Require generated publication freshness checks after the final
  relevant mutation.

## R5: Operator Entry Point Becomes Too Broad

- severity: medium
- risk: `/proposal-program-delivery` could become a broad cleanup or shipping
  command.
- mitigation: Keep the command thin and require a delivery profile with target,
  route, outcome, PR policy, stash policy, and receipt expectations.

## R6: Residue Cleanup Is Treated As Detection-Only

- severity: medium
- risk: Delivery could delete local residue from classification alone.
- mitigation: Require repo-hygiene cleanup authorization and closeout-owned
  cleanup receipts before deletion.
