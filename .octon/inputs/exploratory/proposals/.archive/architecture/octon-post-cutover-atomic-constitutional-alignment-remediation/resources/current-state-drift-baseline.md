# Current-State Drift Baseline

## What remains wrong at current HEAD

### 1. Active family semantics are not fully synchronized

The charter manifest names the March 30, 2026 atomic cutover receipt as the live selector, but several active family manifests still point at earlier phase receipts. This is a semantic drift issue, not a runtime re-architecture issue.

### 2. Bootstrap orientation still leaks authored authority

`START.md` still tells readers that raw additive extension inputs sit inside instance-native repo authority. That violates the kernel's authored-authority boundary even though the underlying extension publication model is otherwise correct.

### 3. Live support claims are wider than retained proof

The support-target declaration publishes more adapters and envelopes than the current retained release disclosure proves. In a governed system, publication without proof must resolve either to stage-only/experimental status or to additional proof in the same atomic change.

### 4. Portability language is broader than the proved live envelope

Some `.octon/**` docs still blur the line between architectural portability intent and currently proved live support.

### 5. Placeholder owners remain on binding subordinate governance text

That is a durability and reviewability problem even though the principles surface is subordinate to the kernel.

## What is no longer wrong

### Disclosure live roots

The disclosure family, governance disclosure README, and historical-mirror README are already aligned to the March 30 atomic disclosure model.

That issue should now be handled as a **regression-prevention requirement**, not as an unfixed migration.
