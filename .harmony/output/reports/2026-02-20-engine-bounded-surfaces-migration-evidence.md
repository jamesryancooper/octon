# Engine Bounded Surfaces Migration Evidence (2026-02-20)

## Scope

Clean-break migration from top-level `/.harmony/runtime/` to bounded `/.harmony/engine/` surfaces:

- `engine/runtime/`
- `engine/governance/`
- `engine/practices/`

## Static Verification

### Legacy path removal

Command:

```bash
if [ -e .harmony/runtime ]; then echo 'FAIL'; else echo 'PASS'; fi
```

Result:

- `PASS` (legacy top-level `/.harmony/runtime/` path removed)

### Legacy reference sweep (active files)

Command:

```bash
rg -n --hidden \
  -g '!.git' \
  -g '!.harmony/output/**' \
  -g '!.harmony/ideation/**' \
  -g '!.harmony/engine/_ops/state/**' \
  -g '!.harmony/engine/runtime/crates/target/**' \
  -g '!.harmony/cognition/decisions/**' \
  -g '!.harmony/cognition/methodology/migrations/**' \
  '\.harmony/runtime/' .
```

Result:

- Remaining matches are intentional explanatory references only:
  - `/.harmony/engine/README.md`
  - `/.harmony/engine/practices/local-dev-validation.md`
  - `/.harmony/cognition/_meta/architecture/bounded-surfaces-contract.md`

## Runtime Verification

### Engine runtime workspace builds

Command:

```bash
cargo check --manifest-path .harmony/engine/runtime/crates/Cargo.toml
```

Result:

- Passed (`harmony_core`, `harmony_wasm_host`, `harmony_kernel` checked successfully)

### Filesystem interfaces runtime wiring

Command:

```bash
bash .harmony/capabilities/runtime/services/_ops/scripts/validate-filesystem-interfaces.sh
```

Result:

- Passed (`filesystem interface validation passed`)

### Rebuild interface services against migrated runtime paths

Command:

```bash
HARMONY_RUNTIME_PREFER_SOURCE=1 .harmony/engine/runtime/run service build interfaces/filesystem-snapshot
HARMONY_RUNTIME_PREFER_SOURCE=1 .harmony/engine/runtime/run service build interfaces/filesystem-discovery
HARMONY_RUNTIME_PREFER_SOURCE=1 .harmony/engine/runtime/run service build interfaces/filesystem-watch
```

Result:

- Passed (all three services rebuilt; integrity hashes updated in `service.json`)

## CI/Guardrail Verification

### Harness structure validator

Command:

```bash
bash .harmony/assurance/runtime/_ops/scripts/validate-harness-structure.sh
```

Result:

- Passed (`errors=0 warnings=0`)
- Includes deprecated-path assertion for legacy runtime domain:
  - `deprecated engine path removed: .harmony/runtime`

## Notes

- Engine surface contract and risks/mitigations are documented at:
  - `/.harmony/engine/_meta/architecture/README.md`
  - `/.harmony/cognition/_meta/architecture/bounded-surfaces-contract.md`
