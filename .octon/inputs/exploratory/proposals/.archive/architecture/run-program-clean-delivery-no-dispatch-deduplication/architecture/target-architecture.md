# Target Architecture

The workflow runner records a stable no-dispatch key from target, route, input
digest, blocker class, and blocker fingerprint. When the key repeats and no
route action was dispatched, the runner appends an attempt entry to a bounded
ledger instead of writing a duplicate evidence set.

The runner emits fresh evidence when inputs change, the blocker fingerprint
changes, a route is dispatched, or a validator produces new material output.
