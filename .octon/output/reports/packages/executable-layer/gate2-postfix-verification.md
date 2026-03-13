# Gate 2 Postfix Verification

## Scope
Validated the two remaining scenarios requested after Gate 2 migration:
- `CAPABILITY_DENIED`
- `TIMEOUT`

## Results

| Scenario | Status | Notes |
|---|---|---|
| Service requests ungrantable capability | PASS | `kv put` fails with `CAPABILITY_DENIED` when `storage.local` is removed from policy for `interfaces/kv`. |
| Service exceeds timeout | PASS | `slow/ping` fails with `TIMEOUT` after creating `agent-platform/slow` with `limits.timeout_ms = 1` and a non-returning op. |

## Evidence

### 1) CAPABILITY_DENIED

Test method:
1. Back up `.octon/runtime/config/policy.yml`
2. Remove `storage.local` grant for `interfaces/kv`
3. Run:

```bash
.octon/runtime/run tool kv put --json '{"key":"deny-test","value":"1"}'
```

Observed output:

```text
Error: CAPABILITY_DENIED: capabilities not granted for interfaces/kv
```

Policy file restored immediately after test.

### 2) TIMEOUT

Test setup:
1. Scaffolded `agent-platform/slow` via:

```bash
.octon/runtime/run service new agent-platform slow
```

2. Set timeout in:
`/.octon/capabilities/services/agent-platform/slow/service.json`

```json
"timeout_ms": 1
```

3. Implemented `ping` as non-returning loop in:
`/.octon/capabilities/services/agent-platform/slow/rust/src/lib.rs`

4. Built service:

```bash
.octon/runtime/run service build agent-platform slow
```

5. Invoked:

```bash
.octon/runtime/run tool slow ping --json '{"message":"timeout"}'
```

Observed output:

```text
Error: TIMEOUT: service execution timed out
```

## Runtime fix applied during verification

To classify Wasmtime 29 interrupt traps correctly as timeout/cancel outcomes, the error mapper was hardened in:
- `/.octon/runtime/crates/wasm_host/src/invoke.rs`

This was required because Wasmtime 29 often reports epoch interrupts through trap chains that are not reliably visible in `err.to_string()` alone.

## Sanity checks after tests

- `cargo check --workspace` in `/.octon/runtime/crates` passes.
- `cargo component check` in `/.octon/capabilities/services/interfaces/kv/rust` passes.
- KV tool invocation still works after policy restoration.
