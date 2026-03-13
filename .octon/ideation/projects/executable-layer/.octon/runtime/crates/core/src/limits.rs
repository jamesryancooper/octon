use crate::errors::{ErrorCode, KernelError, Result};
use parking_lot::Mutex;
use std::collections::HashMap;
use std::sync::Arc;

/// Tracks per-service concurrent invocations.
///
/// v1 policy: reject new requests once `max_concurrency` is reached.
#[derive(Clone, Default)]
pub struct ConcurrencyManager {
    inner: Arc<Mutex<HashMap<String, usize>>>,
}

impl ConcurrencyManager {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn try_acquire(&self, service_id: &str, max_concurrency: u32) -> Result<Permit> {
        let mut map = self.inner.lock();
        let cur = map.get(service_id).copied().unwrap_or(0);
        if cur >= max_concurrency as usize {
            return Err(KernelError::new(
                ErrorCode::Internal,
                format!("max_concurrency exceeded for {service_id}"),
            )
            .with_details(serde_json::json!({
                "service": service_id,
                "max_concurrency": max_concurrency,
            })));
        }

        map.insert(service_id.to_string(), cur + 1);
        Ok(Permit {
            service_id: service_id.to_string(),
            mgr: self.clone(),
        })
    }

    fn release(&self, service_id: &str) {
        let mut map = self.inner.lock();
        if let Some(cur) = map.get_mut(service_id) {
            if *cur > 1 {
                *cur -= 1;
            } else {
                map.remove(service_id);
            }
        }
    }
}

pub struct Permit {
    service_id: String,
    mgr: ConcurrencyManager,
}

impl Drop for Permit {
    fn drop(&mut self) {
        self.mgr.release(&self.service_id);
    }
}
