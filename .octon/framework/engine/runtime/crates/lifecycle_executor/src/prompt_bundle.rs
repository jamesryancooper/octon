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
        "# Lifecycle Route Execution\n\n- lifecycle_id: `{}`\n- route_id: `{}`\n- target: `{}`\n- prompt_set_id: `{}`\n\n",
        request.lifecycle_id,
        request.route.route_id,
        request.target.display(),
        bundle.prompt_set_id
    );
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
