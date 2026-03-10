---
title: Validate Scaffolded Package
description: Run the design-package standard validator against the scaffolded package.
---

# Step 4: Validate Scaffolded Package

## Purpose

Ensure the scaffolded package is standard-compliant before reporting success.

## Actions

1. Run:
   `bash .harmony/assurance/runtime/_ops/scripts/validate-design-package-standard.sh --package ".design-packages/<package_id>"`
2. Fail closed if validation fails.
3. Record the validator outcome and any follow-up work needed before the package
   is filled in.

## Proceed When

- [ ] Standard validator passes
- [ ] Manifest-bearing module requirements are satisfied
- [ ] README wording and exit path requirements are satisfied
