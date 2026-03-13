use wasmtime::{Engine, Result, Store};
use wasmtime::component::{Component, Linker, HasSelf};
use wasmtime_wasi::p2::add_to_linker_sync;

use crate::bindings::OctonService;
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

    // Provide WASI Preview2 imports
    add_to_linker_sync(&mut linker)?;

    // Provide Octon host imports from the generated bindings
    OctonService::add_to_linker::<_, HasSelf<_>>(&mut linker, |s| s)?;

    // Create store
    let mut store = Store::new(engine, state);

    // Best-effort cancellation support.
    if let Some((tx, flag)) = cancel {
        if let Ok(h) = store.interrupt_handle() {
            let _ = tx.send(CancelHandle::new(h, flag));
        }
    }

    // Timeout via epoch interruption (best-effort). If disabled, pass 0.
    if timeout_ms > 0 && tick_ms > 0 {
        let ticks = (timeout_ms + tick_ms - 1) / tick_ms;
        store.set_epoch_deadline(ticks);
    }

    // Instantiate
    let bindings = OctonService::instantiate(&mut store, &component, &linker)?;

    // Call exported top-level function `invoke`
    let out = bindings.call_invoke(&mut store, op, input_json)?;
    Ok(out)
}
