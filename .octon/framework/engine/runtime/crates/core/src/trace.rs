use crate::errors::{ErrorCode, KernelError, Result};
use parking_lot::Mutex;
use serde_json::json;
use std::fs;
use std::fs::OpenOptions;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::sync::Arc;

#[derive(Clone)]
pub struct TraceWriter {
    inner: Arc<Mutex<std::fs::File>>,
    trace_id: String,
    path: PathBuf,
}

impl TraceWriter {
    pub fn new(run_root: &Path, trace_id: Option<String>) -> Result<Self> {
        let trace_id = trace_id.unwrap_or_else(|| uuid::Uuid::new_v4().to_string());
        fs::create_dir_all(run_root).map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to create run root {}: {e}", run_root.display()),
            )
        })?;
        for dir in [
            run_root.join("receipts"),
            run_root.join("checkpoints"),
            run_root.join("replay"),
        ] {
            fs::create_dir_all(&dir).map_err(|e| {
                KernelError::new(
                    ErrorCode::Internal,
                    format!(
                        "failed to create run evidence family {}: {e}",
                        dir.display()
                    ),
                )
            })?;
        }

        let path = run_root.join("trace.ndjson");
        let file = OpenOptions::new()
            .create(true)
            .append(true)
            .open(&path)
            .map_err(|e| {
                KernelError::new(
                    ErrorCode::Internal,
                    format!("failed to open trace file: {e}"),
                )
            })?;
        write_trace_pointers(run_root, &path, &trace_id)?;

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
        let line = serde_json::to_string(value).map_err(|e| {
            KernelError::new(ErrorCode::Internal, format!("trace serialize failed: {e}"))
        })?;
        let mut file = self.inner.lock();
        file.write_all(line.as_bytes()).map_err(|e| {
            KernelError::new(ErrorCode::Internal, format!("trace write failed: {e}"))
        })?;
        file.write_all(b"\n").map_err(|e| {
            KernelError::new(ErrorCode::Internal, format!("trace write failed: {e}"))
        })?;
        let _ = file.flush();
        Ok(())
    }
}

fn write_trace_pointers(run_root: &Path, trace_path: &Path, trace_id: &str) -> Result<()> {
    let run_id = run_root
        .file_name()
        .and_then(|value| value.to_str())
        .unwrap_or("unknown-run");
    let updated_at = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|value| value.as_secs().to_string())
        .unwrap_or_else(|_| "0".to_string());
    let yaml = format!(
        concat!(
            "schema_version: \"run-trace-pointers-v1\"\n",
            "run_id: \"{}\"\n",
            "trace_id: \"{}\"\n",
            "trace_refs:\n",
            "  - \"{}\"\n",
            "updated_at: \"{}\"\n"
        ),
        run_id,
        trace_id,
        trace_path.display(),
        updated_at
    );
    let pointer_path = run_root.join("trace-pointers.yml");
    fs::write(&pointer_path, yaml).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to write trace pointer file {}: {e}",
                pointer_path.display()
            ),
        )
    })?;
    Ok(())
}
