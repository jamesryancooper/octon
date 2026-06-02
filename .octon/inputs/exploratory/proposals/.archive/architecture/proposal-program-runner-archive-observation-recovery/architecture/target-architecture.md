# Target Architecture

Archive workflow execution remains workflow-owned. The lifecycle executor
observes terminal archive state after active proposal path moves, records
blocked archive evidence when convergence fails, and replans from live state.
