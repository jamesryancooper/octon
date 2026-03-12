# FILES

Final Assurance Engine layout under `/Users/jamesryancooper/Projects/harmony/.harmony/assurance/`.

```text
.harmony/assurance/
├── governance/
│   ├── CHARTER.md                     # Canonical Assurance Charter (source of truth)
│   ├── README.md                      # Governance entrypoint and charter flow
│   ├── weights/
│   │   ├── weights.yml                # Policy weights + charter machine contract + changelog
│   │   ├── weights.md                 # Human guidance for policy model
│   │   └── inputs/context.yml         # Active context defaults for resolver runs
│   ├── scores/
│   │   └── scores.yml                 # Measurement scores + evidence pointers
│   ├── SUBSYSTEM_OVERRIDE_POLICY.md   # Repo-over-subsystem override governance
│   ├── subsystem-classes.yml          # Control-plane/productivity strictness model
│   └── overrides.yml                  # Explicit deviation declarations
├── runtime/
│   └── _ops/
│       ├── scripts/
│       │   ├── compute-assurance-score.sh   # Shell entrypoint to resolver
│       │   ├── assurance-gate.sh            # Shell entrypoint to gate
│       │   └── alignment-check.sh           # Alignment profile runner (includes charter args)
│       └── state/
│           ├── active-weight-context.lock.yml
│           └── effective-weights.lock.yml
└── practices/
    └── ...
```

Runtime implementation:

- `/Users/jamesryancooper/Projects/harmony/.harmony/engine/runtime/crates/assurance_tools/src/main.rs`

Generated artifacts:

- Effective matrix: `/Users/jamesryancooper/Projects/harmony/.harmony/output/assurance/effective/<context>.md`
- Weighted results: `/Users/jamesryancooper/Projects/harmony/.harmony/output/assurance/results/<context>.md`
- Deviations report: `/Users/jamesryancooper/Projects/harmony/.harmony/output/assurance/policy/deviations/<context>.md`
