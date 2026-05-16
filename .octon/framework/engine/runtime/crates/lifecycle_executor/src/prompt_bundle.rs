use crate::generated::resolve_prompt_bundle;
use crate::request::LifecycleRouteExecutionRequest;
use std::path::Path;

pub fn render_extension_prompt(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
) -> std::result::Result<String, crate::LifecycleExecutionError> {
    let prompt_set_id = request.route.prompt_set_id.as_deref().ok_or_else(|| {
        crate::LifecycleExecutionError::new(
            crate::LifecycleErrorClass::Discovery,
            format!("route {} has no prompt_set_id", request.route.route_id),
        )
    })?;
    let bundle = resolve_prompt_bundle(
        repo_root,
        &request.effective_extension_catalog,
        &request.owner_extension,
        prompt_set_id,
    )?;
    let mut rendered = format!(
        "# Lifecycle Route Execution\n\n- run_id: `{}`\n- lifecycle_id: `{}`\n- route_id: `{}`\n- target: `{}`\n- prompt_set_id: `{}`\n- approval_policy: `{}`\n\n",
        request.run_id,
        request.lifecycle_id,
        request.route.route_id,
        request.target.display(),
        bundle.prompt_set_id,
        request.policy.approval_policy
    );
    if let Some(context) = request.approval_context.as_ref() {
        rendered.push_str("## Program Context\n\n");
        rendered.push_str(&format!("- context_kind: `{}`\n", context.context_kind));
        if let Some(program_run_id) = context.program_run_id.as_ref() {
            rendered.push_str(&format!("- program_run_id: `{program_run_id}`\n"));
        }
        if let Some(child_id) = context.child_id.as_ref() {
            rendered.push_str(&format!("- child_id: `{child_id}`\n"));
        }
        if let Some(retry_instruction) = context.retry_instruction.as_ref() {
            rendered.push_str(&format!("- retry_instruction: `{retry_instruction}`\n"));
        }
        if let Some(unattended_instruction) = context.unattended_override_instruction.as_ref() {
            rendered.push_str(&format!(
                "- unattended_override_instruction: `{unattended_instruction}`\n"
            ));
        }
        rendered.push('\n');
    }
    if !request.bound_inputs.is_empty() {
        rendered.push_str("## Bound Inputs\n\n");
        for (key, value) in &request.bound_inputs {
            if value.contains('\n') {
                rendered.push_str(&format!("- `{key}`:\n\n{}\n\n", fenced_text(value)));
            } else {
                rendered.push_str(&format!("- `{key}`: `{value}`\n"));
            }
        }
        rendered.push('\n');
    }
    for asset in bundle.assets {
        rendered.push_str(&format!(
            "\n## {}: {}\n\n",
            asset.role,
            asset.path.display()
        ));
        rendered.push_str(&render_placeholders(&asset.content, request));
        rendered.push('\n');
    }
    Ok(rendered)
}

fn fenced_text(value: &str) -> String {
    let mut fence = "```".to_string();
    while value.contains(&fence) {
        fence.push('`');
    }
    format!("{fence}text\n{value}\n{fence}")
}

pub fn render_placeholders(content: &str, request: &LifecycleRouteExecutionRequest) -> String {
    let mut rendered = content.to_string();
    for (key, value) in &request.bound_inputs {
        rendered = rendered.replace(&format!("{{{{{key}}}}}"), value);
        rendered = rendered.replace(&format!("<{}>", key.to_ascii_uppercase()), value);
    }
    rendered
}
