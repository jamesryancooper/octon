# Invariants

1. Native mode must function without any adapter loaded.
2. Session policy validation is required before execution.
3. Context budget warning threshold is fixed at 80%.
4. Context budget flush threshold is fixed at 90%.
5. Compaction is blocked if mandatory flush fails and no ACP waiver is present.
6. Provider-specific terms and keys are disallowed in core interop files.
