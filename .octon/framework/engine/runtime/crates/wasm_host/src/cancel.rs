use std::sync::{
    atomic::{AtomicBool, Ordering},
    Arc,
};

#[derive(Clone)]
pub struct CancelHandle {
    cancelled: Arc<AtomicBool>,
    engine: wasmtime::Engine,
}

impl CancelHandle {
    pub fn new(engine: wasmtime::Engine, cancelled: Arc<AtomicBool>) -> Self {
        Self { cancelled, engine }
    }

    pub fn cancel(&self) {
        self.cancelled.store(true, Ordering::SeqCst);
        // Nudge epoch checks so cancellation is observed promptly.
        self.engine.increment_epoch();
    }

    pub fn was_cancelled(&self) -> bool {
        self.cancelled.load(Ordering::SeqCst)
    }

    pub fn flag(&self) -> Arc<AtomicBool> {
        self.cancelled.clone()
    }
}
