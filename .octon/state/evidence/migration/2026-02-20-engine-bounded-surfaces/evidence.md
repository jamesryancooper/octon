# Engine Bounded Surfaces Migration Evidence (2026-02-20)

## Scope

Clean-break migration from top-level `/.octon/runtime/` to bounded `/.octon/framework/engine/` surfaces:

- `engine/runtime/`
- `engine/governance/`
- `engine/practices/`

## Static Verification

### Legacy path removal

Command:

```bash
if [ -e .octon/runtime ]; then echo 'FAIL'; else echo 'PASS'; fi
```

Result:

- `PASS` (legacy top-level `/.octon/runtime/` path removed)

### Legacy reference sweep (active files)

Command:

```bash
rg -n --hidden \
  -g '!.git' \
  -g '!.octon/generated/**' \
  -g '!.octon/inputs/exploratory/ideation/**' \
  -g '!.octon/framework/engine/_ops/state/**' \
  -g '!.octon/framework/engine/runtime/crates/target/**' \
  -g '!.octon/framework/cognition/decisions/**' \
  -g '!.octon/framework/cognition/methodology/migrations/**' \
  '\.octon/runtime/' .
```

Result:

- Remaining matches are intentional explanatory references only:
  - `/.octon/framework/engine/README.md`
  - `/.octon/framework/engine/practices/local-dev-validation.md`
  - `/.octon/framework/cognition/_meta/architecture/bounded-surfaces-contract.md`

## Runtime Verification

### Engine runtime workspace builds

Command:

```bash
cargo check --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml
```

Result:

- Passed (`octon_core`, `octon_wasm_host`, `octon_kernel` checked successfully)

### Filesystem interfaces runtime wiring

Command:

```bash
bash .octon/framework/capabilities/runtime/services/_ops/scripts/validate-filesystem-interfaces.sh
```

Result:

- Passed (`filesystem interface validation passed`)

### Rebuild interface services against migrated runtime paths

Command:

```bash
OCTON_RUNTIME_PREFER_SOURCE=1 .octon/framework/engine/runtime/run service build interfaces/filesystem-snapshot
OCTON_RUNTIME_PREFER_SOURCE=1 .octon/framework/engine/runtime/run service build interfaces/filesystem-discovery
OCTON_RUNTIME_PREFER_SOURCE=1 .octon/framework/engine/runtime/run service build interfaces/filesystem-watch
```

Result:

- Passed (all three services rebuilt; integrity hashes updated in `service.json`)

## CI/Guardrail Verification

### Harness structure validator

Command:

```bash
bash .octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh
```

Result:

- Passed (`errors=0 warnings=0`)
- Includes deprecated-path assertion for legacy runtime domain:
  - `deprecated engine path removed: .octon/runtime`

## Notes

- Engine surface contract and risks/mitigations are documented at:
  - `/.octon/framework/engine/_meta/architecture/README.md`
  - `/.octon/framework/cognition/_meta/architecture/bounded-surfaces-contract.md`
