use std::sync::{
    atomic::{AtomicBool, Ordering},
    Arc,
};

#[derive(Clone)]
pub struct CancelHandle {
    inner: wasmtime::InterruptHandle,
    cancelled: Arc<AtomicBool>,
}

impl CancelHandle {
    pub fn new(inner: wasmtime::InterruptHandle, cancelled: Arc<AtomicBool>) -> Self {
        Self { inner, cancelled }
    }

    pub fn cancel(&self) {
        self.cancelled.store(true, Ordering::SeqCst);
        self.inner.interrupt();
    }

    pub fn was_cancelled(&self) -> bool {
        self.cancelled.load(Ordering::SeqCst)
    }

    pub fn flag(&self) -> Arc<AtomicBool> {
        self.cancelled.clone()
    }
}
