#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
RUNTIME_CRATES_DIR="$ROOT_DIR/.octon/framework/engine/runtime/crates"
PUBLICATION_KERNEL_TARGET_DIR="$ROOT_DIR/.octon/generated/.tmp/engine/build/runtime-crates-target"
PUBLICATION_KERNEL_BIN="$PUBLICATION_KERNEL_TARGET_DIR/debug/octon"

resolve_octon_kernel_bin() {
  if [[ -n "${OCTON_KERNEL_BIN:-}" ]]; then
    printf '%s\n' "$OCTON_KERNEL_BIN"
    return
  fi

  mkdir -p "$PUBLICATION_KERNEL_TARGET_DIR"
  (
    cd "$RUNTIME_CRATES_DIR"
    export CARGO_TARGET_DIR="$PUBLICATION_KERNEL_TARGET_DIR"
    cargo build -q -p octon_kernel --bin octon
  )

  if [[ -x "$PUBLICATION_KERNEL_BIN" ]]; then
    printf '%s\n' "$PUBLICATION_KERNEL_BIN"
    return
  fi

  echo "unable to resolve octon kernel binary for publication wrapper" >&2
  exit 1
}

run_octon_kernel() {
  local kernel_bin
  kernel_bin="$(resolve_octon_kernel_bin)"
  OCTON_KERNEL_BIN="$kernel_bin" "$kernel_bin" "$@"
}

run_publication_wrapper() {
  local publisher_cmd="$1"
  run_octon_kernel publish "$publisher_cmd"
}

enter_publication_runtime_boundary() {
  local publisher_cmd="$1"
  if [[ "${OCTON_PUBLICATION_ENTRYPOINT:-}" != "runtime" ]]; then
    run_publication_wrapper "$publisher_cmd"
    exit $?
  fi

  if [[ -z "${OCTON_PUBLICATION_TOKEN_MANIFEST:-}" ]]; then
    echo "missing OCTON_PUBLICATION_TOKEN_MANIFEST for runtime publication entrypoint" >&2
    exit 1
  fi
  if [[ -z "${OCTON_PUBLICATION_TOKEN_RESULT_MANIFEST:-}" ]]; then
    echo "missing OCTON_PUBLICATION_TOKEN_RESULT_MANIFEST for runtime publication entrypoint" >&2
    exit 1
  fi

  run_octon_kernel publication-internal verify-manifest \
    --publisher "$publisher_cmd" \
    --manifest "$OCTON_PUBLICATION_TOKEN_MANIFEST" \
    --result-manifest "$OCTON_PUBLICATION_TOKEN_RESULT_MANIFEST"
}
