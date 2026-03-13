# Build output

Captured from this repository on the current machine after runtime migration updates.

## `cargo check --workspace` (from `.octon/engine/runtime/crates/`)

```bash
$ cd .octon/engine/runtime/crates
$ cargo check --workspace
Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.35s
```

## `cargo component check` (from `.octon/capabilities/runtime/services/interfaces/kv/rust/`)

```bash
$ cd .octon/capabilities/runtime/services/interfaces/kv/rust
$ cargo component check
Generating bindings for octon-kv-service (src/bindings.rs)
Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.02s
```

## Prebuilt kernel binaries (`.octon/engine/_ops/bin/`)

```bash
$ cargo build -p octon_kernel --release --target aarch64-apple-darwin
Finished `release` profile [optimized] target(s) in 6.71s

$ cargo build -p octon_kernel --release --target x86_64-apple-darwin
Finished `release` profile [optimized] target(s) in 35.65s

$ cargo build -p octon_kernel --release --target x86_64-unknown-linux-gnu
error: failed to run custom build command for `zstd-sys ...`
error occurred in cc-rs: failed to find tool \"x86_64-linux-gnu-gcc\"
```

Current checked-in binaries:

- `.octon/engine/_ops/bin/octon-macos-arm64`
- `.octon/engine/_ops/bin/octon-macos-x64`
