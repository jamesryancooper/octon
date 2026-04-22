# Tradeoff Analysis

## Why moderate restructuring is justified

The current architecture is strong but has reached a point where local additions will compound
complexity. The target state therefore uses moderate restructuring in runtime resolution, pack routes,
support path normalization, and extension active state.

## Tradeoffs accepted

| Tradeoff | Accepted because |
|---|---|
| More schemas and runtime resolver code | They reduce ambiguity and make runtime consumption enforceable |
| Generated/effective route bundle | It creates a single fresh runtime view rather than scattered projections |
| Support partition migration | It aligns paths with already-declared claim-state partitions |
| Pack route relocation to generated/effective | It clarifies authored governance vs compiled runtime view |
| Extension active-state compaction | It improves inspectability and change containment |
| More negative-control tests | They are required to prove governance is executable |

## Tradeoffs rejected

| Rejected option | Reason |
|---|---|
| Re-found the five-class root model | Current model is correct and load-bearing |
| Make generated/effective authored authority | Violates Octon constitution and generated discipline |
| Leave pack admissions as-is indefinitely | Keeps duplication and support-widening ambiguity |
| Keep flat support paths as canonical | Conflicts with declared claim-state partitions |
| Hide complexity only through docs | Runtime and validator enforcement must do the work |
| Expand live support while hardening architecture | Would blur target-state closure with support-universe growth |
