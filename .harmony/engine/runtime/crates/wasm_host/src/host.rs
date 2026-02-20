use crate::run_component::invoke_component;
use crate::state::HostState;
use crate::cancel::CancelHandle;
use harmony_core::config::RuntimeConfig;
use std::path::Path;
use std::sync::{Arc, atomic::AtomicBool};

pub struct WasmHost {
    engine: wasmtime::Engine,
    tick_ms: u64,
}

impl WasmHost {
    pub fn new(cfg: &RuntimeConfig) -> anyhow::Result<Self> {
        let mut c = wasmtime::Config::new();

        // Component model is required for the v1 ABI.
        c.wasm_component_model(true);

        // Timeout support.
        c.epoch_interruption(true);

        // Compilation caching.
        if let Some(cache_cfg) = &cfg.wasmtime_cache_config {
            // Note: cache config file path, not a directory.
            let _ = c.cache_config_load(cache_cfg);
        }

        let engine = wasmtime::Engine::new(&c)?;

        let tick_ms = 10;
        let ticker_engine = engine.clone();
        std::thread::spawn(move || loop {
            std::thread::sleep(std::time::Duration::from_millis(tick_ms));
            ticker_engine.increment_epoch();
        });

        Ok(Self { engine, tick_ms })
    }

    pub fn invoke(
        &self,
        wasm_path: &Path,
        state: HostState,
        op: &str,
        input_json: &str,
        timeout_ms: u64,
        cancel: Option<(std::sync::mpsc::Sender<CancelHandle>, Arc<AtomicBool>)>,
    ) -> wasmtime::Result<String> {
        invoke_component(
            &self.engine,
            wasm_path,
            state,
            op,
            input_json,
            timeout_ms,
            self.tick_ms,
            cancel,
        )
    }
}
