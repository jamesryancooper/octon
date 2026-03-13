use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use std::collections::BTreeSet;

#[allow(warnings)]
mod bindings;
use bindings::Guest;

const DEFAULT_HTTP_TIMEOUT_MS: u64 = 30_000;
const FLOW_RUNS_DIR: &str = ".octon/engine/_ops/state/runs/flow";
const FLOW_ADAPTER_NATIVE: &str = "native-octon";
const FLOW_ADAPTER_LANGGRAPH_HTTP: &str = "langgraph-http";

#[derive(Default)]
pub struct Service;

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct FlowRequest {
    config: FlowConfig,
    #[serde(default)]
    params: Value,
    #[serde(default)]
    dry_run: bool,
    #[serde(default)]
    adapter: Option<String>,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct FlowConfig {
    flow_name: String,
    canonical_prompt_path: String,
    workspace_root: Option<String>,
    workflow_manifest_path: String,
    workflow_entrypoint: Option<String>,
    observability: Option<ObservabilityConfig>,
    runtime: Option<FlowRuntimeConfig>,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct ObservabilityConfig {
    span_prefix: Option<String>,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct FlowRuntimeConfig {
    #[serde(rename = "type")]
    runtime_type: Option<String>,
    adapter: Option<String>,
    url: Option<String>,
    timeout_seconds: Option<u64>,
    timeout_ms: Option<u64>,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct FlowResponse {
    result: Value,
    run_id: String,
    #[serde(skip_serializing_if = "Vec::is_empty")]
    artifacts: Vec<String>,
    metadata: FlowMetadata,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct FlowMetadata {
    flow_name: String,
    workflow_manifest_path: String,
    canonical_prompt_path: String,
    workspace_root: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    runner_endpoint: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    workflow_entrypoint: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    runtime_run_id: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    span_prefix: Option<String>,
    adapter: String,
    step_count: usize,
    run_record_path: String,
}

#[derive(Debug)]
struct NativeManifestInfo {
    steps: Vec<String>,
}

#[derive(Debug)]
struct RunExecution {
    result: Value,
    artifacts: Vec<String>,
    runtime_run_id: Option<String>,
    runner_endpoint: Option<String>,
}

impl Guest for Service {
    fn invoke(op: String, input_json: String) -> String {
        match op.as_str() {
            "run" => run_flow(&input_json),
            _ => panic!("INVALID_INPUT: unknown operation '{op}'"),
        }
    }
}

fn run_flow(input_json: &str) -> String {
    let request: FlowRequest = serde_json::from_str(input_json)
        .unwrap_or_else(|e| panic!("INVALID_INPUT: invalid flow payload: {e}"));

    let params = normalize_params(request.params);
    let config = request.config;

    let flow_name = non_empty("config.flowName", &config.flow_name);
    let canonical_prompt_path = non_empty("config.canonicalPromptPath", &config.canonical_prompt_path);
    let workflow_manifest_path = non_empty("config.workflowManifestPath", &config.workflow_manifest_path);
    let workspace_root = config
        .workspace_root
        .clone()
        .unwrap_or_else(|| ".".to_string());

    validate_repo_relative("config.canonicalPromptPath", &canonical_prompt_path);
    validate_repo_relative("config.workflowManifestPath", &workflow_manifest_path);
    validate_repo_relative("config.workspaceRoot", &workspace_root);

    if !bindings::fs::exists(&canonical_prompt_path) {
        panic!("INVALID_INPUT: canonical prompt path does not exist: {canonical_prompt_path}");
    }
    if !bindings::fs::exists(&workflow_manifest_path) {
        panic!("INVALID_INPUT: workflow manifest path does not exist: {workflow_manifest_path}");
    }

    let manifest_text = bindings::fs::read_text(&workflow_manifest_path);
    let manifest = parse_native_manifest(&manifest_text);

    let workflow_entrypoint = match config.workflow_entrypoint.clone() {
        Some(entry) => {
            let entry = non_empty("config.workflowEntrypoint", &entry);
            if !manifest.steps.iter().any(|step| step == &entry) {
                panic!("INVALID_INPUT: workflowEntrypoint '{entry}' is not declared in workflow manifest");
            }
            Some(entry)
        }
        None => manifest.steps.first().cloned(),
    };

    let adapter = resolve_adapter(request.adapter.as_deref(), config.runtime.as_ref());
    let run_id = derive_run_id(
        &flow_name,
        &canonical_prompt_path,
        &workflow_manifest_path,
        workflow_entrypoint.as_deref(),
        &params,
        &adapter,
    );

    let execution = if request.dry_run {
        RunExecution {
            result: json!({
                "dryRun": true,
                "accepted": true,
                "adapter": adapter,
                "flowName": flow_name,
                "stepCount": manifest.steps.len(),
            }),
            artifacts: Vec::new(),
            runtime_run_id: None,
            runner_endpoint: runtime_endpoint(config.runtime.as_ref(), false),
        }
    } else if adapter == FLOW_ADAPTER_LANGGRAPH_HTTP {
        run_langgraph_http(
            &config,
            &flow_name,
            &canonical_prompt_path,
            &workflow_manifest_path,
            workflow_entrypoint.as_deref(),
            &workspace_root,
            &params,
            &run_id,
        )
    } else {
        run_native_octon(&flow_name, workflow_entrypoint.as_deref(), &manifest.steps, &params)
    };

    let run_record_path = persist_run_record(
        &run_id,
        &adapter,
        &flow_name,
        &canonical_prompt_path,
        &workflow_manifest_path,
        workflow_entrypoint.as_deref(),
        &workspace_root,
        request.dry_run,
        &params,
        &execution.result,
    );

    let mut artifacts = execution.artifacts.clone();
    artifacts.push(run_record_path.clone());

    let response = FlowResponse {
        result: execution.result,
        run_id,
        artifacts,
        metadata: FlowMetadata {
            flow_name,
            workflow_manifest_path,
            canonical_prompt_path,
            workspace_root,
            runner_endpoint: execution.runner_endpoint,
            workflow_entrypoint,
            runtime_run_id: execution.runtime_run_id,
            span_prefix: config
                .observability
                .and_then(|obs| obs.span_prefix)
                .map(|s| s.trim().to_string())
                .filter(|s| !s.is_empty()),
            adapter,
            step_count: manifest.steps.len(),
            run_record_path,
        },
    };

    serde_json::to_string(&response)
        .unwrap_or_else(|e| panic!("INTERNAL: failed to encode flow response: {e}"))
}

fn normalize_params(value: Value) -> Value {
    match value {
        Value::Null => json!({}),
        Value::Object(_) => value,
        _ => panic!("INVALID_INPUT: params must be an object"),
    }
}

fn non_empty(field: &str, value: &str) -> String {
    let trimmed = value.trim();
    if trimmed.is_empty() {
        panic!("INVALID_INPUT: {field} is required");
    }
    trimmed.to_string()
}

fn validate_repo_relative(field: &str, path: &str) {
    if path.contains('\0') {
        panic!("INVALID_INPUT: {field} contains invalid characters");
    }
    if path.starts_with('/') || path.starts_with('\\') {
        panic!("INVALID_INPUT: {field} must be repo-relative");
    }
    if path.contains("..") {
        panic!("INVALID_INPUT: {field} cannot include parent traversal");
    }
    if path.contains(':') {
        panic!("INVALID_INPUT: {field} must not include URI or drive prefixes");
    }
}

fn parse_native_manifest(manifest_text: &str) -> NativeManifestInfo {
    let mut steps = Vec::new();
    let mut seen = BTreeSet::new();

    for line in manifest_text.lines() {
        let trimmed = line.trim_start();
        if let Some(rest) = trimmed.strip_prefix("- id:") {
            let step = rest.trim().trim_matches('"').trim_matches('\'').to_string();
            if step.is_empty() {
                panic!("INVALID_INPUT: workflow manifest contains empty step id");
            }
            if !seen.insert(step.clone()) {
                panic!("INVALID_INPUT: workflow manifest contains duplicate step id '{step}'");
            }
            steps.push(step);
        }
    }

    if steps.is_empty() {
        panic!("INVALID_INPUT: workflow manifest contains no steps");
    }

    NativeManifestInfo { steps }
}

fn resolve_adapter(override_adapter: Option<&str>, runtime: Option<&FlowRuntimeConfig>) -> String {
    if let Some(adapter) = override_adapter {
        let normalized = adapter.trim().to_ascii_lowercase();
        if !normalized.is_empty() {
            return normalized;
        }
    }

    if let Some(runtime) = runtime {
        if let Some(adapter) = runtime.adapter.as_ref() {
            let normalized = adapter.trim().to_ascii_lowercase();
            if !normalized.is_empty() {
                return normalized;
            }
        }

        if let Some(runtime_type) = runtime.runtime_type.as_ref() {
            let runtime_type = runtime_type.trim().to_ascii_lowercase();
            if runtime_type == "http-service" || runtime_type == FLOW_ADAPTER_LANGGRAPH_HTTP {
                return FLOW_ADAPTER_LANGGRAPH_HTTP.to_string();
            }
        }
    }

    FLOW_ADAPTER_NATIVE.to_string()
}

fn runtime_endpoint(runtime: Option<&FlowRuntimeConfig>, append_flow_path: bool) -> Option<String> {
    let runtime = runtime?;
    let base = runtime.url.as_ref()?.trim();
    if base.is_empty() {
        return None;
    }

    if !append_flow_path {
        return Some(base.to_string());
    }

    if base.ends_with("/flows/run") {
        Some(base.to_string())
    } else {
        Some(format!("{}/flows/run", base.trim_end_matches('/')))
    }
}

fn run_native_octon(
    flow_name: &str,
    workflow_entrypoint: Option<&str>,
    steps: &[String],
    params: &Value,
) -> RunExecution {
    let step_outputs: Vec<Value> = steps
        .iter()
        .enumerate()
        .map(|(idx, id)| {
            json!({
                "id": id,
                "status": "simulated",
                "sequence": idx + 1
            })
        })
        .collect();

    RunExecution {
        result: json!({
            "dryRun": false,
            "accepted": true,
            "adapter": FLOW_ADAPTER_NATIVE,
            "flowName": flow_name,
            "workflowEntrypoint": workflow_entrypoint,
            "steps": step_outputs,
            "params": params,
        }),
        artifacts: Vec::new(),
        runtime_run_id: None,
        runner_endpoint: None,
    }
}

fn run_langgraph_http(
    config: &FlowConfig,
    flow_name: &str,
    canonical_prompt_path: &str,
    workflow_manifest_path: &str,
    workflow_entrypoint: Option<&str>,
    workspace_root: &str,
    params: &Value,
    run_id: &str,
) -> RunExecution {
    let endpoint = runtime_endpoint(config.runtime.as_ref(), true)
        .unwrap_or_else(|| "http://127.0.0.1:8410/flows/run".to_string());
    let timeout_ms = config
        .runtime
        .as_ref()
        .and_then(|runtime| runtime.timeout_ms)
        .or_else(|| {
            config
                .runtime
                .as_ref()
                .and_then(|runtime| runtime.timeout_seconds.map(|seconds| seconds.saturating_mul(1000)))
        })
        .unwrap_or(DEFAULT_HTTP_TIMEOUT_MS)
        .max(1);

    let payload = json!({
        "runId": run_id,
        "flowName": flow_name,
        "canonicalPromptPath": canonical_prompt_path,
        "workflowManifestPath": workflow_manifest_path,
        "workflowEntrypoint": workflow_entrypoint,
        "workspaceRoot": workspace_root,
        "params": params,
    });

    let body = serde_json::to_vec(&payload)
        .unwrap_or_else(|e| panic!("INTERNAL: failed to encode langgraph payload: {e}"));

    let response = bindings::http::send(&bindings::http::Request {
        method: "POST".to_string(),
        url: endpoint.clone(),
        headers: vec![bindings::http::Header {
            name: "content-type".to_string(),
            value: "application/json".to_string(),
        }],
        body,
        timeout_ms: Some(timeout_ms),
    });

    if !(200..300).contains(&response.status) {
        let body_text = String::from_utf8_lossy(&response.body);
        let body_text = body_text.replace('\n', " ").replace('\r', " ");
        panic!(
            "HTTP_ERROR: langgraph runtime returned HTTP {}: {}",
            response.status, body_text
        );
    }

    let decoded: Value = match serde_json::from_slice(&response.body) {
        Ok(value) => value,
        Err(_) => Value::String(String::from_utf8_lossy(&response.body).to_string()),
    };

    let runtime_run_id = decoded
        .get("runtimeRunId")
        .and_then(Value::as_str)
        .or_else(|| decoded.get("runId").and_then(Value::as_str))
        .map(ToString::to_string);

    let result = decoded
        .get("result")
        .cloned()
        .unwrap_or_else(|| decoded.clone());

    let artifacts = decoded
        .get("artifacts")
        .and_then(Value::as_array)
        .map(|values| {
            values
                .iter()
                .filter_map(|v| {
                    v.as_str()
                        .map(ToString::to_string)
                        .or_else(|| v.get("path").and_then(Value::as_str).map(ToString::to_string))
                })
                .collect::<Vec<_>>()
        })
        .unwrap_or_default();

    RunExecution {
        result,
        artifacts,
        runtime_run_id,
        runner_endpoint: Some(endpoint),
    }
}

#[allow(clippy::too_many_arguments)]
fn persist_run_record(
    run_id: &str,
    adapter: &str,
    flow_name: &str,
    canonical_prompt_path: &str,
    workflow_manifest_path: &str,
    workflow_entrypoint: Option<&str>,
    workspace_root: &str,
    dry_run: bool,
    params: &Value,
    result: &Value,
) -> String {
    bindings::fs::mkdirp(FLOW_RUNS_DIR);

    let record_path = format!("{FLOW_RUNS_DIR}/{run_id}.json");
    let record = json!({
        "runId": run_id,
        "adapter": adapter,
        "dryRun": dry_run,
        "flow": {
            "name": flow_name,
            "canonicalPromptPath": canonical_prompt_path,
            "workflowManifestPath": workflow_manifest_path,
            "workflowEntrypoint": workflow_entrypoint,
            "workspaceRoot": workspace_root,
        },
        "params": params,
        "result": result,
    });

    let record_text = serde_json::to_string_pretty(&record)
        .unwrap_or_else(|e| panic!("INTERNAL: failed to encode flow run record: {e}"));
    bindings::fs::write_text(&record_path, &record_text);
    record_path
}

fn derive_run_id(
    flow_name: &str,
    canonical_prompt_path: &str,
    workflow_manifest_path: &str,
    workflow_entrypoint: Option<&str>,
    params: &Value,
    adapter: &str,
) -> String {
    let fingerprint = json!({
        "flowName": flow_name,
        "canonicalPromptPath": canonical_prompt_path,
        "workflowManifestPath": workflow_manifest_path,
        "workflowEntrypoint": workflow_entrypoint,
        "params": params,
        "adapter": adapter,
    });
    let bytes = serde_json::to_vec(&fingerprint)
        .unwrap_or_else(|e| panic!("INTERNAL: failed to encode run fingerprint: {e}"));

    let hi = fnv1a64(&bytes, 0xcbf29ce484222325);
    let lo = fnv1a64(&bytes, 0x84222325cbf29ce4);
    let hex = format!("{hi:016x}{lo:016x}");

    format!(
        "{}-{}-{}-{}-{}",
        &hex[0..8],
        &hex[8..12],
        &hex[12..16],
        &hex[16..20],
        &hex[20..32]
    )
}

fn fnv1a64(bytes: &[u8], seed: u64) -> u64 {
    let mut hash = seed;
    for b in bytes {
        hash ^= u64::from(*b);
        hash = hash.wrapping_mul(0x0000_0100_0000_01b3);
    }
    hash
}

bindings::export!(Service with_types_in bindings);
