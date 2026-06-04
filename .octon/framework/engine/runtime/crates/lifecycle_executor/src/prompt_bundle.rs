use crate::generated::{resolve_prompt_bundle, PromptBundle, PromptBundleAsset};
use crate::request::LifecycleRouteExecutionRequest;
use std::path::Path;

const FULL_EXPANSION_REASON_CODES: &[&str] = &[
    "digest-drift",
    "mutation-sensitive-work",
    "gate-dispute",
    "authority-conflict",
    "audit-request",
];

enum PromptRenderMode {
    CompactCapsule,
    FullExpansion { reason_code: String },
}

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
    let render_mode = prompt_render_mode(request)?;
    let compact_mode = matches!(render_mode, PromptRenderMode::CompactCapsule);
    let mut rendered = format!(
        "# Lifecycle Route Execution\n\n- run_id: `{}`\n- lifecycle_id: `{}`\n- route_id: `{}`\n- target: `{}`\n- prompt_set_id: `{}`\n- prompt_bundle_sha256: `sha256:{}`\n- prompt_render_mode: `{}`\n- invocation_authority: `{}`\n\n",
        request.run_id,
        request.lifecycle_id,
        request.route.route_id,
        request.target.display(),
        bundle.prompt_set_id,
        bundle.bundle_sha256,
        match &render_mode {
            PromptRenderMode::CompactCapsule => "compact-capsule",
            PromptRenderMode::FullExpansion { .. } => "full-expansion",
        },
        request.policy.invocation_authority.mode
    );
    if let Some(context) = request.human_boundary_context.as_ref() {
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
        if let Some(human_exception_instruction) = context.human_exception_instruction.as_ref() {
            rendered.push_str(&format!(
                "- human_exception_instruction: `{human_exception_instruction}`\n"
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
    if compact_mode {
        render_compact_capsules(&mut rendered, &bundle, request);
    } else if let PromptRenderMode::FullExpansion { reason_code } = render_mode {
        rendered.push_str("## Prompt Expansion Policy\n\n");
        rendered.push_str(&format!(
            "- expansion_mode: `full-expansion`\n- reason_code: `{reason_code}`\n- fallback_full_prompt_refs_retained: `yes`\n- compact_capsule_bypass: `explicit-trigger-only`\n\n"
        ));
        for asset in bundle.assets {
            rendered.push_str(&format!(
                "\n## {}: {}\n\n",
                asset.role,
                asset.path.display()
            ));
            rendered.push_str(&render_placeholders(&asset.content, request));
            rendered.push('\n');
        }
    }
    Ok(rendered)
}

fn prompt_render_mode(
    request: &LifecycleRouteExecutionRequest,
) -> std::result::Result<PromptRenderMode, crate::LifecycleExecutionError> {
    let Some(mode) = request.bound_inputs.get("prompt_expansion_mode") else {
        return Ok(PromptRenderMode::CompactCapsule);
    };
    match mode.as_str() {
        "compact" | "compact-capsule" | "prompt-pack-handle" => {
            Ok(PromptRenderMode::CompactCapsule)
        }
        "full" | "full-expansion" => {
            let reason_code = request
                .bound_inputs
                .get("prompt_expansion_reason_code")
                .map(String::as_str)
                .ok_or_else(|| {
                    crate::LifecycleExecutionError::new(
                        crate::LifecycleErrorClass::Discovery,
                        "full prompt expansion requires a reason_code",
                    )
                })?;
            if !FULL_EXPANSION_REASON_CODES.contains(&reason_code) {
                return Err(crate::LifecycleExecutionError::new(
                    crate::LifecycleErrorClass::Discovery,
                    format!("full prompt expansion reason is not allowed: {reason_code}"),
                ));
            }
            Ok(PromptRenderMode::FullExpansion {
                reason_code: reason_code.to_string(),
            })
        }
        other => Err(crate::LifecycleExecutionError::new(
            crate::LifecycleErrorClass::Discovery,
            format!("unsupported prompt expansion mode: {other}"),
        )),
    }
}

fn render_compact_capsules(
    rendered: &mut String,
    bundle: &PromptBundle,
    request: &LifecycleRouteExecutionRequest,
) {
    rendered.push_str("## prompt-pack-capsule.yml\n\n");
    rendered.push_str("schema_version: prompt-pack-capsule-v1\n");
    rendered.push_str("artifact_class: compact-model-visible-instruction-handle\n");
    rendered.push_str("authority_status: non-authority; full sources remain retained by digest\n");
    rendered.push_str(&format!(
        "prompt_set_id: {}\n",
        yaml_string(&bundle.prompt_set_id)
    ));
    rendered.push_str(&format!(
        "manifest_ref: {}\nmanifest_sha256: sha256:{}\nbundle_sha256: sha256:{}\npublication_status: {}\n",
        yaml_string(&bundle.manifest_path),
        bundle.manifest_sha256,
        bundle.bundle_sha256,
        yaml_string(&bundle.publication_status)
    ));
    if let Some(alignment_status) = bundle.alignment_status.as_ref() {
        rendered.push_str(&format!(
            "alignment_status: {}\n",
            yaml_string(alignment_status)
        ));
    }
    if let Some(receipt) = bundle.alignment_receipt_path.as_ref() {
        rendered.push_str(&format!(
            "alignment_receipt_ref: {}\n",
            yaml_string(receipt)
        ));
    }
    rendered.push_str("failure_behavior: fail closed on missing source, digest mismatch, stale freshness, or authority-boundary violation\n");
    rendered.push_str("full_prompt_packet_refs_retained: yes\n");
    rendered.push_str("source_assets:\n");
    for asset in &bundle.assets {
        rendered.push_str(&asset_ref_yaml(asset));
    }
    rendered.push('\n');

    rendered.push_str("## route-instruction-capsule.yml\n\n");
    rendered.push_str("schema_version: route-instruction-capsule-v1\n");
    rendered.push_str(&format!(
        "route_id: {}\nlifecycle_id: {}\nrun_id: {}\n",
        yaml_string(&request.route.route_id),
        yaml_string(&request.lifecycle_id),
        yaml_string(&request.run_id)
    ));
    rendered.push_str("visible_short_rules:\n");
    for asset in &bundle.assets {
        rendered.push_str(&format!("  - asset_id: {}\n", yaml_string(&asset.id)));
        rendered.push_str("    rules:\n");
        for line in asset_summary_lines(asset) {
            rendered.push_str(&format!("      - {}\n", yaml_string(&line)));
        }
    }
    rendered.push('\n');

    rendered.push_str("## compiled-governance-capsule.yml\n\n");
    rendered.push_str("schema_version: compiled-governance-capsule-v1\n");
    rendered.push_str("authority_boundary_rules:\n");
    for rule in [
        "proposal packets, generated prompts, generated registries, host state, chat, and raw inputs do not become authority",
        "durable authority, control, evidence, generated projections, and instance enablement must land in their declared repository classes",
        "generated effective prompt assets are consumed only through freshness-checked handles and remain derived-only",
        "full prompt expansion requires an explicit allowed trigger and retained replay evidence",
    ] {
        rendered.push_str(&format!("  - {}\n", yaml_string(rule)));
    }
    if !bundle.required_repo_anchors.is_empty() {
        rendered.push_str("required_repo_anchors:\n");
        for anchor in &bundle.required_repo_anchors {
            rendered.push_str(&format!(
                "  - path: {}\n    sha256: sha256:{}\n",
                yaml_string(&anchor.path),
                anchor.sha256
            ));
        }
    }
    rendered.push('\n');

    rendered.push_str("## prompt-expansion-policy.yml\n\n");
    rendered.push_str("schema_version: prompt-expansion-policy-v1\n");
    rendered.push_str("default_mode: compact-capsule\n");
    rendered.push_str("full_expansion_allowed_reason_codes:\n");
    for reason in FULL_EXPANSION_REASON_CODES {
        rendered.push_str(&format!("  - {}\n", yaml_string(reason)));
    }
    rendered.push_str("current_request:\n");
    rendered.push_str("  mode: compact-capsule\n");
    rendered.push_str("  full_expansion_active: no\n");
    rendered.push_str("  raw_full_asset_visibility: hidden-by-default\n");
}

fn asset_ref_yaml(asset: &PromptBundleAsset) -> String {
    let mut output = String::new();
    output.push_str(&format!("  - id: {}\n", yaml_string(&asset.id)));
    output.push_str(&format!("    role: {}\n", yaml_string(&asset.role)));
    if let Some(role_class) = asset.role_class.as_ref() {
        output.push_str(&format!("    role_class: {}\n", yaml_string(role_class)));
    }
    output.push_str(&format!(
        "    bundle_path: {}\n    source_ref: {}\n    projection_ref: {}\n    sha256: sha256:{}\n    full_expansion_ref: {}\n",
        yaml_string(&asset.bundle_path),
        yaml_string(&asset.source_path.display().to_string()),
        yaml_string(&asset.path.display().to_string()),
        asset.sha256,
        yaml_string(&asset.path.display().to_string())
    ));
    output
}

fn asset_summary_lines(asset: &PromptBundleAsset) -> Vec<String> {
    let mut lines = Vec::new();
    for raw in asset.content.lines() {
        let trimmed = raw.trim();
        if trimmed.is_empty() {
            continue;
        }
        let selected = if trimmed.starts_with('#') {
            Some(trimmed.trim_start_matches('#').trim())
        } else if trimmed.starts_with("- ") || trimmed.starts_with("* ") {
            Some(
                trimmed
                    .trim_start_matches(|ch| ch == '-' || ch == '*')
                    .trim(),
            )
        } else {
            None
        };
        let Some(selected) = selected else {
            continue;
        };
        if selected.is_empty() {
            continue;
        }
        lines.push(truncate_line(selected, 180));
        if lines.len() >= 4 {
            break;
        }
    }
    if lines.is_empty() {
        lines.push(format!(
            "{} asset retained by digest; request full expansion only under policy trigger",
            asset.role
        ));
    }
    lines
}

fn truncate_line(value: &str, max_chars: usize) -> String {
    let mut output = String::new();
    for (index, ch) in value.chars().enumerate() {
        if index >= max_chars {
            output.push_str("...");
            return output;
        }
        output.push(ch);
    }
    output
}

fn yaml_string(value: &str) -> String {
    format!("\"{}\"", value.replace('\\', "\\\\").replace('"', "\\\""))
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
