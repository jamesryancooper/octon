use crate::host::WasmHost;
use crate::kv_store::KvStore;
use crate::policy::GrantSet;
use crate::scoped_fs::ScopedFs;
use crate::state::HostState;

use octon_core::config::RuntimeConfig;
use octon_core::errors::{ErrorCode, KernelError, Result};
use octon_core::limits::ConcurrencyManager;
use octon_core::registry::ServiceDescriptor;
use octon_core::schema::SchemaStore;
use octon_core::trace::TraceWriter;

use serde_json::json;
use std::sync::{
    atomic::{AtomicBool, Ordering},
    Arc,
};

pub struct Invoker {
    cfg: RuntimeConfig,
    schemas: SchemaStore,
    wasm: WasmHost,
    concurrency: ConcurrencyManager,
}

impl Invoker {
    pub fn new(cfg: RuntimeConfig, schemas: SchemaStore) -> anyhow::Result<Self> {
        let wasm = WasmHost::new(&cfg)?;
        Ok(Self {
            cfg,
            schemas,
            wasm,
            concurrency: ConcurrencyManager::new(),
        })
    }

    pub fn invoke(
        &self,
        service: &ServiceDescriptor,
        grants: GrantSet,
        op: &str,
        input: serde_json::Value,
        trace: Option<&TraceWriter>,
        deadline_ms: Option<u64>,
        cancel_tx: Option<std::sync::mpsc::Sender<crate::cancel::CancelHandle>>,
    ) -> Result<serde_json::Value> {
        let service_id = service.key.id();

        let op_decl = service
            .manifest
            .ops
            .get(op)
            .ok_or_else(|| {
                KernelError::new(
                    ErrorCode::UnknownOperation,
                    format!("unknown operation '{op}' for {service_id}"),
                )
                .with_details(json!({"service": service_id, "op": op}))
            })?
            .clone();

        if let Some(t) = trace {
            let _ = t.event(
                "request.received",
                json!({"service": service_id, "op": op}),
            );
        }

        // Input schema validation.
        self.schemas.validate_against_schema(
            &input,
            &op_decl.input_schema,
            ErrorCode::InvalidInput,
            "input failed schema validation",
        )?;

        // Serialize input JSON (canonical form) and enforce max_request_bytes.
        let input_json = serde_json::to_string(&input).map_err(|e| {
            KernelError::new(ErrorCode::MalformedJson, format!("failed to serialize input: {e}"))
        })?;

        if input_json.as_bytes().len() as u64 > service.manifest.limits.max_request_bytes {
            return Err(KernelError::new(
                ErrorCode::RequestTooLarge,
                "request exceeds max_request_bytes",
            )
            .with_details(json!({
                "max_request_bytes": service.manifest.limits.max_request_bytes,
                "request_bytes": input_json.as_bytes().len(),
            })));
        }

        // Concurrency enforcement.
        let _permit = self
            .concurrency
            .try_acquire(&service_id, service.manifest.limits.max_concurrency)?;

        // Timeouts: service limit is an upper bound.
        let mut timeout_ms = service.manifest.limits.timeout_ms;
        if let Some(d) = deadline_ms {
            timeout_ms = timeout_ms.min(d);
        }

        if let Some(t) = trace {
            let _ = t.event(
                "policy.decision",
                json!({"service": service_id, "granted": grants.list()}),
            );
            let _ = t.event(
                "invoke.start",
                json!({"service": service_id, "op": op, "timeout_ms": timeout_ms}),
            );
        }

        // Build HostState.
        // Do not inherit host stdio. In stdio server mode, stdout is reserved for the protocol.
        let wasi_ctx = wasmtime_wasi::WasiCtxBuilder::new().build();
        let table = wasmtime_wasi::ResourceTable::new();

        let kv = KvStore::open(self.cfg.state_dir.join("kv")).map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to open kv store: {e}"),
            )
        })?;

        let fs = ScopedFs::new(self.cfg.repo_root.clone()).map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to init scoped fs: {e}"),
            )
        })?;

        let mut cancelled_flag: Option<Arc<AtomicBool>> = None;
        let cancel = cancel_tx.map(|tx| {
            let flag = Arc::new(AtomicBool::new(false));
            cancelled_flag = Some(flag.clone());
            (tx, flag)
        });

        let state = HostState {
            wasi_ctx,
            table,
            grants,
            kv,
            fs,
        };

        // Call Wasm.
        let out_json = match self
            .wasm
            .invoke(&service.wasm_path, state, op, &input_json, timeout_ms, cancel)
        {
            Ok(s) => s,
            Err(e) => {
                let ke = map_wasmtime_error(e, cancelled_flag.as_ref());
                if let Some(t) = trace {
                    let _ = t.event(
                        "invoke.error",
                        json!({"service": service_id, "error": ke.as_error_object()}),
                    );
                }
                return Err(ke);
            }
        };

        if out_json.as_bytes().len() as u64 > service.manifest.limits.max_response_bytes {
            return Err(KernelError::new(
                ErrorCode::Internal,
                "response exceeds max_response_bytes",
            )
            .with_details(json!({
                "max_response_bytes": service.manifest.limits.max_response_bytes,
                "response_bytes": out_json.as_bytes().len(),
            })));
        }

        // Parse output.
        let out_value: serde_json::Value = serde_json::from_str(&out_json).map_err(|e| {
            KernelError::new(
                ErrorCode::ServiceTrap,
                format!("service returned invalid JSON: {e}"),
            )
        })?;

        // Output schema validation (fail-closed).
        self.schemas.validate_against_schema(
            &out_value,
            &op_decl.output_schema,
            ErrorCode::ServiceTrap,
            "output failed schema validation",
        )?;

        if let Some(t) = trace {
            let _ = t.event(
                "invoke.end",
                json!({"service": service_id, "op": op, "ok": true}),
            );
        }

        Ok(out_value)
    }
}

fn map_wasmtime_error(err: wasmtime::Error, cancelled_flag: Option<&Arc<AtomicBool>>) -> KernelError {
    let msg = err.to_string();
    let mut full = msg.clone();
    for cause in err.chain().skip(1) {
        full.push_str(" | ");
        full.push_str(&cause.to_string());
    }
    let full_lc = full.to_ascii_lowercase();

    if full.contains("CANCELLED:") {
        return KernelError::new(ErrorCode::Cancelled, "request cancelled");
    }
    if full.contains("TIMEOUT:") {
        return KernelError::new(ErrorCode::Timeout, "service execution timed out");
    }

    // Wasmtime 29 commonly reports epoch interruption as a Trap::Interrupt
    // with backtrace-focused display text.
    if let Some(trap) = err.downcast_ref::<wasmtime::Trap>() {
        if *trap == wasmtime::Trap::Interrupt {
            let was_cancelled = cancelled_flag
                .map(|f| f.load(Ordering::SeqCst))
                .unwrap_or(false);
            return KernelError::new(
                if was_cancelled {
                    ErrorCode::Cancelled
                } else {
                    ErrorCode::Timeout
                },
                if was_cancelled {
                    "request cancelled"
                } else {
                    "service execution timed out"
                },
            );
        }
    }
    if let Some(trap) = err.root_cause().downcast_ref::<wasmtime::Trap>() {
        if *trap == wasmtime::Trap::Interrupt {
            let was_cancelled = cancelled_flag
                .map(|f| f.load(Ordering::SeqCst))
                .unwrap_or(false);
            return KernelError::new(
                if was_cancelled {
                    ErrorCode::Cancelled
                } else {
                    ErrorCode::Timeout
                },
                if was_cancelled {
                    "request cancelled"
                } else {
                    "service execution timed out"
                },
            );
        }
    }

    // Cancellation or timeout will typically surface as an interrupt trap.
    let was_cancelled = cancelled_flag
        .map(|f| f.load(Ordering::SeqCst))
        .unwrap_or(false);

    if full_lc.contains("interrupt") || full_lc.contains("epoch") {
        return KernelError::new(
            if was_cancelled {
                ErrorCode::Cancelled
            } else {
                ErrorCode::Timeout
            },
            if was_cancelled {
                "request cancelled"
            } else {
                "service execution timed out"
            },
        );
    }

    if msg.contains("CAPABILITY_DENIED") {
        return KernelError::new(ErrorCode::CapabilityDenied, msg);
    }

    if msg.contains("INVALID_INPUT") {
        return KernelError::new(ErrorCode::InvalidInput, msg);
    }

    KernelError::new(ErrorCode::ServiceTrap, full)
}
