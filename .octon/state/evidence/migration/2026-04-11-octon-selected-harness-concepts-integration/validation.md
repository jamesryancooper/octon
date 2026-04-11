# Validation

Pass 1 completed cleanly:

- targeted review-disposition, distillation, tool-output-envelope, and
  mission-proposal-classification validators: pass
- `alignment-check.sh --profile harness`: pass
- `alignment-check.sh --profile mission-autonomy`: pass

Pass 2 completed cleanly:

- `alignment-check.sh --profile harness,mission-autonomy`: pass

No new blocking issues were introduced between pass 1 and pass 2.
