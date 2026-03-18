# Invariants

1. Graph/discovery operations require valid snapshot artifacts.
2. Graph entities returned to callers are resolvable to a concrete filesystem path.
3. Discovery operations return bounded, explicit frontier expansions.
4. Explain outputs include snapshot-scoped provenance fields.
5. Corrupt or unsupported snapshot artifacts fail closed with actionable remediation guidance.
6. Discovery operations enforce bounded byte/time limits and fail closed on limit exceedance.
7. Provider-specific terms are disallowed in core filesystem-discovery files.
