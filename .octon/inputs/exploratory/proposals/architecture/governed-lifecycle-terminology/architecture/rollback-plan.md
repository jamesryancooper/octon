# Rollback Plan

If the terminology update causes validator drift or navigation breakage, revert
the durable terminology commit rather than partially restoring old product
names. The rollback must restore the previous product feature file, roadmap
file, catalog feature id, validator expectations, and any regenerated
projections in one atomic change.

Do not delete retained lifecycle evidence. If archive has already occurred,
retain the archived packet and record a follow-up correction proposal instead
of editing archived receipts.
