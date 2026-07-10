# Doc/Registry Consistency — Architecture Lens Bank

Run: `20260709-arms-program-clean-delivery-04-architecture-lens-bank-foundation`
Checked at: 2026-07-09T21:49:31Z

Verifies `architecture-lens-bank.md` and `lens-bank.yml` agree on lens ids,
tiers, method profiles, and the Balanced required set.

## Lens catalog

- `yq '.lenses | length'` → **18** lenses.
- Tier split (`.lenses[].tier | uniq -c`) → **12 core + 6 extended**.
- Every one of the 18 `lenses[].id` values appears as a backticked id in
  `architecture-lens-bank.md`: distinct-match count = **18/18** (see
  `lens-ids.txt` and the `grep -oFf` count).

## Method profiles

- `lens-bank.yml` declares `method_profiles` for all six suite methods
  (Balanced + five provisional companions); the lens-reference validator
  reports `bank declares 6 suite methods` and a complete profile for each
  (see `lens-references-positive-control.txt`).
- The doc's human-view R/O/— profile table carries all six method columns
  (Balanced, Greenfield, Tradeoff, Failure-Mode, Evolution/Fitness,
  Boundary/Authority) mirroring the YAML profiles.

## Balanced required set (AC-4)

`yq '.method_profiles."balanced-architecture-review-method".required[]' | sort`:

```
authority-boundary
clean-sheet-reference
complexity-separation
current-reality-map
failure-and-recovery
non-goals-deletion
steelman-chestertons-fence
system-job-framing
tradeoff-adr
validation-strategy
```

This is exactly the 10 `R` lens ids in the Balanced column of the source
profile table and the doc appendix — proving adoption is cross-reference-only.
`balanced-architecture-review-method.md` is unedited (see
`balanced-unchanged-gitdiff.txt`, empty).

Result: **consistent**. Doc and registry agree on 18 lens ids, two tiers, six
method profiles, and the 10-lens Balanced required set.
