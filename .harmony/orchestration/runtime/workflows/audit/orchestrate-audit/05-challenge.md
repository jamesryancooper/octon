---
name: challenge
title: "Challenge"
description: "Global self-challenge that checks for issues spanning partition boundaries."
---

# Step 5: Challenge

## Input

- Merged findings collection (from step 4)
- Merged coverage stats (from step 4)
- Partition plan (from step 2)
- Failed partitions (from step 3)

## Purpose

Perform global self-challenge that individual partition-scoped audits cannot do. This catches issues at partition boundaries and validates the overall audit integrity. Each partition's self-challenge only covers its own slice — this step covers the whole.

## Actions

1. **Cross-partition reference check:**

   Look for findings where a file in partition A references a path that resolves to a file in partition B:

   - Read cross-partition reference notes from each partition report
   - For each cross-partition reference, verify: does the target path exist? Is it stale?
   - Add new findings if cross-partition references reveal staleness

2. **Partition boundary integrity:**

   - Verify the union of all partition scopes equals the full scope (no gaps)
   - Check that no file was missed by all partitions
   - Check for files audited by multiple partitions with conflicting findings (overlap check)
   - Record: "Boundary integrity: PASS" or list gaps/overlaps

3. **Global mapping coverage:**

   For each mapping in the manifest, verify it was searched across the union of all partitions:

   - A mapping may appear as "confirmed clean" in every partition but still need a global check
   - Check: does every mapping have either findings or "confirmed clean" across all partitions combined?
   - Flag any mapping that has neither (missed globally)

4. **Cross-partition semantic consistency:**

   Check for findings in one partition that are contradicted by clean results in another:

   - Example: partition A flags "stale reference to X" but partition B shows X was correctly updated
   - Resolve contradictions: verify the finding, adjust severity or remove if disproved

5. **Failed partition impact assessment:**

   For any failed partitions:

   - List which mappings and key files were not covered
   - Assess whether findings from successful partitions are reliable despite the gaps
   - Record: "Failed partition impact: {assessment}"

6. **Record global challenge outcomes:**

   ```markdown
   ## Global Self-Challenge Results

   - Cross-partition references verified: N
   - Partition boundary integrity: PASS/FAIL
   - Global mapping coverage: N/N mappings covered
   - Cross-partition consistency issues: N
   - Failed partition impact: {assessment}
   - New findings from global challenge: N
   - Findings removed by global challenge: N
   ```

## Idempotency

**Check:** Global challenge outcomes already exist in checkpoint.

- [ ] Checkpoint file exists at `checkpoints/orchestrate-audit/05-challenge.complete`

**If Already Complete:**

- Skip to step 6
- Re-run if merged findings have changed

**Marker:** `checkpoints/orchestrate-audit/05-challenge.complete`

## Error Messages

- Boundary failure: "CHALLENGE_BOUNDARY: {N} files missing from partition union"
- Mapping gap: "CHALLENGE_MAPPING_GAP: Mapping '{old}' not covered in any partition"

## Output

- Updated findings collection (with global challenge additions/removals)
- Global challenge report
- Final coverage assessment

## Proceed When

- [ ] All 5 global challenge checks completed
- [ ] Challenge outcomes documented
- [ ] Findings collection updated with any additions or removals
