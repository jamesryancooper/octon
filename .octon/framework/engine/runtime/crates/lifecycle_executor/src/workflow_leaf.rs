use crate::generated::resolve_workflow_manifest;
use crate::request::LifecycleRouteExecutionRequest;
use serde_yaml::Value;
use std::fs;
use std::path::Path;

pub fn render_workflow_leaf_prompt(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
) -> std::result::Result<String, crate::LifecycleExecutionError> {
    let manifest_path = resolve_workflow_manifest(
        repo_root,
        &request.runtime_route_bundle,
        &request.route.route_id,
    )?;
    let manifest: Value = serde_yaml::from_slice(&fs::read(&manifest_path).map_err(|error| {
        crate::LifecycleExecutionError::new(
            crate::LifecycleErrorClass::Discovery,
            error.to_string(),
        )
    })?)
    .map_err(|error| {
        crate::LifecycleExecutionError::new(
            crate::LifecycleErrorClass::Discovery,
            error.to_string(),
        )
    })?;
    let mut rendered = format!(
        "# Lifecycle Workflow Leaf Execution\n\nRun workflow `{}` for lifecycle `{}`.\n\n- run_id: `{}`\n- approval_policy: `{}`\n\nWorkflow contract: `{}`\n\nInputs:\n",
        request.route.route_id,
        request.lifecycle_id,
        request.run_id,
        request.policy.approval_policy,
        manifest_path.display()
    );
    if let Some(context) = request.approval_context.as_ref() {
        rendered.push_str("- context_kind: `");
        rendered.push_str(&context.context_kind);
        rendered.push_str("`\n");
        if let Some(program_run_id) = context.program_run_id.as_ref() {
            rendered.push_str("- program_run_id: `");
            rendered.push_str(program_run_id);
            rendered.push_str("`\n");
        }
        if let Some(child_id) = context.child_id.as_ref() {
            rendered.push_str("- child_id: `");
            rendered.push_str(child_id);
            rendered.push_str("`\n");
        }
    }
    for (key, value) in &request.bound_inputs {
        rendered.push_str(&format!("- `{key}`: `{value}`\n"));
    }
    if let Some(inputs) = manifest.get("inputs").and_then(Value::as_sequence) {
        rendered.push_str("\nRequired workflow inputs declared by the workflow:\n");
        for input in inputs {
            let name = scalar(input.get("name")).unwrap_or("unknown");
            let required = input
                .get("required")
                .and_then(Value::as_bool)
                .unwrap_or(false);
            rendered.push_str(&format!("- `{name}` required={required}\n"));
        }
    }
    rendered.push_str("\nExecute the workflow leaf route and produce its declared evidence. Do not treat proposal-local receipts as durable runtime authority.\n");
    Ok(rendered)
}

fn scalar(value: Option<&Value>) -> Option<&str> {
    value.and_then(|value| match value {
        Value::String(raw) => Some(raw.as_str()),
        _ => None,
    })
}
