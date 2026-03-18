# Step 3: Materialize Export

## Actions

1. Run:

   ```bash
   bash .octon/framework/orchestration/runtime/_ops/scripts/export-harness.sh --profile <repo_snapshot|pack_bundle> --output-dir <path> [--pack-ids <csv>]
   ```

2. Write the export root to `<output_dir>/.octon/`.
3. Write `export.receipt.yml` to `<output_dir>/`.
4. Do not include `inputs/exploratory/**`, `state/**`, or `generated/**` in `repo_snapshot`.
5. Do not include framework or instance authority in `pack_bundle`.

## Output

- materialized export root
- export receipt
