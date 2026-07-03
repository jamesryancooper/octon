# Target Architecture

Filesystem snapshot production should derive stable snapshot identity from
semantic inputs and record retention metadata that lets the producer prune only
safe generated snapshot outputs.

Reference-integrity checks must run before any snapshot pruning that could
affect retained evidence or active generated/effective consumers.
