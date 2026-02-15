use crate::errors::{ErrorCode, KernelError, Result};
use serde_json::json;
use std::fs::OpenOptions;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::sync::Arc;
use parking_lot::Mutex;

#[derive(Clone)]
pub struct TraceWriter {
    inner: Arc<Mutex<std::fs::File>>,
    trace_id: String,
    path: PathBuf,
}

impl TraceWriter {
    pub fn new(state_dir: &Path, trace_id: Option<String>) -> Result<Self> {
        let trace_id = trace_id.unwrap_or_else(|| uuid::Uuid::new_v4().to_string());
        let traces_dir = state_dir.join("traces");
        std::fs::create_dir_all(&traces_dir).map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to create traces dir {}: {e}", traces_dir.display()),
            )
        })?;

        let path = traces_dir.join(format!("{trace_id}.ndjson"));
        let file = OpenOptions::new()
            .create(true)
            .append(true)
            .open(&path)
            .map_err(|e| KernelError::new(ErrorCode::Internal, format!("failed to open trace file: {e}")))?;

        Ok(Self {
            inner: Arc::new(Mutex::new(file)),
            trace_id,
            path,
        })
    }

    pub fn trace_id(&self) -> &str {
        &self.trace_id
    }

    pub fn path(&self) -> &Path {
        &self.path
    }

    pub fn event(&self, event: &str, fields: serde_json::Value) -> Result<()> {
        let ts_ms = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap_or_default()
            .as_millis() as u64;

        let obj = json!({
            "ts_ms": ts_ms,
            "trace_id": self.trace_id,
            "event": event,
            "fields": fields,
        });
        self.write_raw(&obj)
    }

    pub fn write_raw(&self, value: &serde_json::Value) -> Result<()> {
        let line = serde_json::to_string(value)
            .map_err(|e| KernelError::new(ErrorCode::Internal, format!("trace serialize failed: {e}")))?;
        let mut file = self.inner.lock();
        file.write_all(line.as_bytes())
            .map_err(|e| KernelError::new(ErrorCode::Internal, format!("trace write failed: {e}")))?;
        file.write_all(b"\n")
            .map_err(|e| KernelError::new(ErrorCode::Internal, format!("trace write failed: {e}")))?;
        let _ = file.flush();
        Ok(())
    }
}
