use std::sync::atomic::Ordering;
use wasmtime::component::{Component, Linker};
use wasmtime::{Engine, Result, Store, UpdateDeadline};

use crate::bindings::HarmonyService;
use crate::cancel::CancelHandle;
use crate::state::HostState;

pub fn invoke_component(
    engine: &Engine,
    wasm_path: &std::path::Path,
    state: HostState,
    op: &str,
    input_json: &str,
    timeout_ms: u64,
    tick_ms: u64,
    cancel: Option<(
        std::sync::mpsc::Sender<CancelHandle>,
        std::sync::Arc<std::sync::atomic::AtomicBool>,
    )>,
) -> Result<String> {
    let component = Component::from_file(engine, wasm_path)?;
    let mut linker: Linker<HostState> = Linker::new(engine);

    // Provide WASI imports required by the component.
    wasmtime_wasi::add_to_linker_sync(&mut linker)?;

    // Provide Harmony host imports from the generated bindings
    HarmonyService::add_to_linker(&mut linker, |s| s)?;

    // Create store
    let mut store = Store::new(engine, state);

    // Best-effort cancellation support.
    let cancelled_flag = cancel.as_ref().map(|(_, flag)| flag.clone());
    if let Some((tx, flag)) = cancel {
        let _ = tx.send(CancelHandle::new(engine.clone(), flag));
    }

    // Timeout and cancellation via epoch interruption.
    if tick_ms > 0 {
        let mut remaining_ticks = if timeout_ms > 0 {
            (timeout_ms + tick_ms - 1) / tick_ms
        } else {
            u64::MAX / 2
        };
        remaining_ticks = remaining_ticks.max(1);
        let cancelled_flag = cancelled_flag.clone();

        store.set_epoch_deadline(1);
        store.epoch_deadline_callback(move |_| {
            if cancelled_flag
                .as_ref()
                .map(|f| f.load(Ordering::SeqCst))
                .unwrap_or(false)
            {
                return Err(anyhow::anyhow!("CANCELLED: request cancelled"));
            }

            if remaining_ticks == 0 {
                return Err(anyhow::anyhow!("TIMEOUT: service execution timed out"));
            }

            remaining_ticks -= 1;
            Ok(UpdateDeadline::Continue(1))
        });
    } else {
        store.epoch_deadline_trap();
    }

    // Instantiate
    let bindings = HarmonyService::instantiate(&mut store, &component, &linker)?;

    // Call exported top-level function `invoke`
    let out = bindings.call_invoke(&mut store, op, input_json)?;
    Ok(out)
}
