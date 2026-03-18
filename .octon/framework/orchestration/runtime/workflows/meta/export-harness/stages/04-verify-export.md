# Step 4: Verify Export

## Actions

1. Confirm `<output_dir>/.octon/` exists.
2. Confirm `<output_dir>/export.receipt.yml` exists and parses as YAML.
3. For `repo_snapshot`, verify:
   - `.octon/octon.yml`
   - `.octon/framework/`
   - `.octon/instance/`
4. For `pack_bundle`, verify only selected packs and dependency closure are present under `.octon/inputs/additive/extensions/`.
5. Confirm no forbidden classes leaked into the export payload.

## Output

- verification status with explicit pass/fail result
