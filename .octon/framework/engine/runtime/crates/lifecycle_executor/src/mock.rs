use crate::authorization::now_rfc3339;
use crate::errors::{LifecycleErrorClass, LifecycleExecutionError};
use crate::observer;
use crate::request::LifecycleRouteExecutionRequest;
use crate::result::LifecycleRouteExecutionResult;
use anyhow::Result;
use sha2::{Digest, Sha256};
use std::fs;
use std::path::{Path, PathBuf};
use walkdir::WalkDir;

pub fn execute_mock(
    request: &LifecycleRouteExecutionRequest,
) -> Result<LifecycleRouteExecutionResult, LifecycleExecutionError> {
    let started_at = now_rfc3339();
    let before = observer::manifest_status(
        &request.target,
        &request.manifest_path,
        &request.status_field,
    )
    .map_err(LifecycleExecutionError::from)?;
    let before_target_digest = if request.expected_target_change {
        Some(observer::target_digest(&request.target).map_err(LifecycleExecutionError::from)?)
    } else {
        None
    };
    fs::create_dir_all(&request.evidence_root)?;
    let mock_log = request
        .evidence_root
        .join(format!("{}-mock.log", request.route.route_id));
    let mutation = if request.lifecycle_id == "proposal-packet" {
        execute_mock_proposal_route(request)
    } else if request.lifecycle_id == "proposal-program" {
        execute_mock_program_route(request)
    } else {
        Ok(())
    };
    let mut status = "completed".to_string();
    let mut error_class = None;
    let mut error_message = None;
    if let Err(error) = mutation {
        status = "failed".to_string();
        error_class = Some(LifecycleErrorClass::ExecutorFailed);
        error_message = Some(error.to_string());
    }
    fs::write(
        &mock_log,
        format!(
            "mock lifecycle route execution\nroute_id: {}\nstatus: {}\n",
            request.route.route_id, status
        ),
    )?;
    let observation = observer::observe_completion(request, before.clone(), before_target_digest)
        .map_err(LifecycleExecutionError::from)?;
    if status == "completed" && !observation.completion_observed {
        status = "failed".to_string();
        error_class = Some(LifecycleErrorClass::CompletionNotObserved);
        error_message = Some(observation.completion_message.clone());
    }
    let observation_path = request.evidence_root.join(format!(
        "{}-completion-observation.yml",
        request.route.route_id
    ));
    fs::write(
        &observation_path,
        serde_yaml::to_string(&observation).map_err(LifecycleExecutionError::from)?,
    )?;
    Ok(LifecycleRouteExecutionResult {
        schema_version: "octon-lifecycle-route-execution-result-v1".to_string(),
        run_id: request.run_id.clone(),
        route_id: request.route.route_id.clone(),
        executor_used: "mock".to_string(),
        status: status.clone(),
        started_at,
        ended_at: now_rfc3339(),
        manifest_status_before: before,
        manifest_status_after: observation.manifest_status_after,
        receipts_observed: observation.receipts_observed,
        evidence_paths: vec![mock_log],
        stdout_path: None,
        stderr_path: None,
        prompt_packet_path: None,
        retryable: false,
        next_action: if status == "completed" {
            "replan".to_string()
        } else {
            "manual-intervention".to_string()
        },
        error_class,
        error_message,
    })
}

fn execute_mock_proposal_route(request: &LifecycleRouteExecutionRequest) -> Result<()> {
    match request.route.route_id.as_str() {
        "create-packet" => mock_create(request),
        "review-packet" => mock_review(request),
        "revise-packet" => mock_revise(request),
        "generate-packet-implementation-prompt" => write_file(
            request
                .target
                .join("support/executable-implementation-prompt.md"),
            "# Executable Implementation Prompt\n\nMock implementation prompt.\n",
        ),
        "run-packet-implementation" | "run-implementation" => write_receipt(
            request.target.join("support/implementation-run.md"),
            &run_implementation_fields(),
        ),
        "promote-proposal" => set_manifest_status(request, "implemented"),
        "run-packet-verification-and-correction-loop" => {
            write_receipt(
                request
                    .target
                    .join("support/implementation-conformance-review.md"),
                &[("verdict", "pass"), ("unresolved_items_count", "0")],
            )?;
            write_receipt(
                request
                    .target
                    .join("support/post-implementation-drift-churn-review.md"),
                &[("verdict", "pass"), ("unresolved_items_count", "0")],
            )
        }
        "closeout-packet" => write_receipt(
            request.target.join("support/proposal-closeout.md"),
            &closeout_fields(),
        ),
        "archive-proposal" => set_manifest_status(request, "archived"),
        _ => Ok(()),
    }
}

fn execute_mock_program_route(request: &LifecycleRouteExecutionRequest) -> Result<()> {
    match request.route.route_id.as_str() {
        "promote-proposal" => set_manifest_status(request, "implemented"),
        "cleanup-lifecycle-residue" => {
            let cleaned_at = now_rfc3339();
            write_receipt(
                request.target.join("support/lifecycle-residue-cleanup.md"),
                &[
                    ("verdict", "blocked"),
                    ("cleaned_at", cleaned_at.as_str()),
                    ("cleanup_candidates", "0"),
                    ("manual_review_count", "1"),
                    ("worktree_hygiene_verdict", "blocked"),
                    ("remaining_blocker_class", "artifact-ownership-unclear"),
                    ("residue_fingerprint", "mock"),
                ],
            )
        }
        _ => Ok(()),
    }
}

fn mock_create(request: &LifecycleRouteExecutionRequest) -> Result<()> {
    if request.target.join(&request.manifest_path).is_file() {
        return Ok(());
    }
    let source = request
        .bound_inputs
        .get("source")
        .map(String::as_str)
        .unwrap_or_default();
    let source_kind = request
        .bound_inputs
        .get("source_kind")
        .map(String::as_str)
        .unwrap_or("text");
    let proposal_id = request
        .bound_inputs
        .get("proposal_id")
        .map(|value| sanitize_proposal_id(value))
        .filter(|value| !value.is_empty())
        .unwrap_or_else(|| {
            request
                .target
                .file_name()
                .and_then(|name| name.to_str())
                .map(sanitize_proposal_id)
                .filter(|value| !value.is_empty())
                .unwrap_or_else(|| "mock-created-proposal".to_string())
        });
    let title = title_from_proposal_id(&proposal_id);
    fs::create_dir_all(&request.target)?;
    write_file(
        request.target.join("proposal.yml"),
        &format!(
            r#"schema_version: "proposal-v1"
proposal_id: "{proposal_id}"
title: "{title}"
summary: "Mock-created architecture proposal packet."
proposal_kind: "architecture"
promotion_scope: "octon-internal"
promotion_targets:
  - ".octon/framework/example.md"
status: "draft"
lifecycle:
  temporary: true
  exit_expectation: "Review, implement, promote, verify, close out, and archive."
related_proposals: []
"#
        ),
    )?;
    write_file(
        request.target.join("README.md"),
        &format!(
            "# {title}\n\nMock-created architecture proposal packet for lifecycle automation acceptance.\n"
        ),
    )?;
    write_file(
        request.target.join("architecture-proposal.yml"),
        "schema_version: \"architecture-proposal-v1\"\nproposal_type: \"architecture\"\nstatus: \"draft\"\n",
    )?;
    write_file(
        request.target.join("architecture/target-architecture.md"),
        "# Target Architecture\n\nMock target architecture derived from bound lifecycle source context.\n",
    )?;
    write_file(
        request.target.join("architecture/implementation-plan.md"),
        "# Implementation Plan\n\n1. Apply the bounded mock implementation change.\n2. Verify conformance and drift receipts.\n3. Close out and archive the packet.\n",
    )?;
    write_file(
        request.target.join("architecture/acceptance-criteria.md"),
        "# Acceptance Criteria\n\n- Proposal review accepts the packet.\n- Implementation run records pass.\n- Conformance and drift receipts pass.\n- Closeout authorizes archive.\n",
    )?;
    write_file(
        request.target.join("resources/source-context.md"),
        &format!(
            "# Source Context\n\nsource_kind: {source_kind}\nsource_context_bound: yes\n\n{}\n",
            markdown_fenced_text(source)
        ),
    )?;
    write_file(
        request
            .target
            .join("support/implementation-grade-completeness-review.md"),
        "# Implementation-Grade Completeness Review\n\nverdict: pass\nunresolved_questions_count: 0\nclarification_required: no\n",
    )?;
    write_file(
        request.target.join("navigation/source-of-truth-map.md"),
        "# Source Of Truth Map\n\n- Source context: `resources/source-context.md`\n- Target architecture: `architecture/target-architecture.md`\n- Implementation plan: `architecture/implementation-plan.md`\n- Acceptance criteria: `architecture/acceptance-criteria.md`\n",
    )?;
    write_file(
        request.target.join("navigation/artifact-catalog.md"),
        "# Artifact Catalog\n\n- `proposal.yml`\n- `README.md`\n- `architecture-proposal.yml`\n- `architecture/target-architecture.md`\n- `architecture/implementation-plan.md`\n- `architecture/acceptance-criteria.md`\n- `navigation/artifact-catalog.md`\n- `navigation/source-of-truth-map.md`\n- `resources/source-context.md`\n- `support/implementation-grade-completeness-review.md`\n- `support/proposal-creation.md`\n",
    )?;
    write_file(
        request.target.join("support/proposal-creation.md"),
        &format!(
            "creation_id: mock-creation-{}\ncreated_at: {}\ncreator: mock-lifecycle-executor\nsource_context_bound: yes\npacket_path: {}\nverdict: pass\n",
            request.run_id,
            now_rfc3339(),
            request.target.display()
        ),
    )
}

fn sanitize_proposal_id(value: &str) -> String {
    let mut sanitized = String::new();
    let mut previous_hyphen = false;
    for ch in value.chars() {
        let next = if ch.is_ascii_alphanumeric() {
            ch.to_ascii_lowercase()
        } else {
            '-'
        };
        if next == '-' {
            if !previous_hyphen {
                sanitized.push(next);
            }
            previous_hyphen = true;
        } else {
            sanitized.push(next);
            previous_hyphen = false;
        }
    }
    sanitized.trim_matches('-').to_string()
}

fn title_from_proposal_id(proposal_id: &str) -> String {
    proposal_id
        .split('-')
        .filter(|part| !part.is_empty())
        .map(|part| {
            let mut chars = part.chars();
            match chars.next() {
                Some(first) => format!("{}{}", first.to_ascii_uppercase(), chars.as_str()),
                None => String::new(),
            }
        })
        .collect::<Vec<_>>()
        .join(" ")
}

fn markdown_fenced_text(value: &str) -> String {
    let mut fence = "```".to_string();
    while value.contains(&fence) {
        fence.push('`');
    }
    format!("{fence}text\n{value}\n{fence}")
}

fn mock_review(request: &LifecycleRouteExecutionRequest) -> Result<()> {
    fs::create_dir_all(request.target.join("support"))?;
    let revised = request.target.join("support/revisions").is_dir();
    if revised {
        set_manifest_status(request, "accepted")?;
    } else {
        set_manifest_status(request, "in-review")?;
    }
    let verdict = if revised {
        "accepted"
    } else {
        "revision-required"
    };
    let authorized = if revised { "yes" } else { "no" };
    let blockers = if revised { "0" } else { "1" };
    let digest = reviewed_packet_digest(&request.target)?;
    let approved_targets = approved_promotion_targets(request)?;
    let content = format!(
        "review_id: mock-review-{}\nreviewed_at: {}\nreviewer: mock-lifecycle-executor\nverdict: {}\nimplementation_prompt_authorized: {}\nreviewed_packet_digest: {}\nopen_blocking_findings_count: {}\n\n## Approved Promotion Targets\n\n{}\n\n## Exclusions\n\n- none\n\n## Blocking Findings\n\n- mock\n\n## Nonblocking Findings\n\n- none\n\n## Final Route Recommendation\n\n{}\n",
        request.run_id,
        now_rfc3339(),
        verdict,
        authorized,
        digest,
        blockers,
        approved_targets,
        if revised { "generate-packet-implementation-prompt" } else { "revise-packet" }
    );
    write_file(request.target.join("support/proposal-review.md"), &content)
}

fn approved_promotion_targets(request: &LifecycleRouteExecutionRequest) -> Result<String> {
    let path = request.target.join(&request.manifest_path);
    let value: serde_yaml::Value = serde_yaml::from_slice(&fs::read(path)?)?;
    let targets = value
        .get("promotion_targets")
        .and_then(|value| value.as_sequence())
        .map(|items| {
            items
                .iter()
                .filter_map(|item| item.as_str())
                .map(|target| format!("- {target}"))
                .collect::<Vec<_>>()
        })
        .unwrap_or_default();
    if targets.is_empty() {
        Ok("- mock".to_string())
    } else {
        Ok(targets.join("\n"))
    }
}

fn mock_revise(request: &LifecycleRouteExecutionRequest) -> Result<()> {
    let revisions = request.target.join("support/revisions");
    fs::create_dir_all(&revisions)?;
    write_file(
        revisions.join("mock-revision-1.md"),
        &format!(
            "revision_id: mock-revision-1\nsource_review_id: mock-review-{}\nchanged_packet_files: README.md\naddressed_finding_ids: mock\nremaining_blocking_count: 0\npost_revision_digest: pending-review\nvalidators_rerun: mock\ncatalog_checksum_registry_refresh_confirmed: yes\n",
            request.run_id
        ),
    )?;
    let readme = request.target.join("README.md");
    let existing = fs::read_to_string(&readme).unwrap_or_default();
    write_file(
        readme,
        &format!("{existing}\n\nMock revision applied by lifecycle executor.\n"),
    )
}

fn set_manifest_status(request: &LifecycleRouteExecutionRequest, status: &str) -> Result<()> {
    let path = request.target.join(&request.manifest_path);
    let existing = fs::read_to_string(&path).unwrap_or_default();
    let mut saw_status = false;
    let mut next = String::new();
    for line in existing.lines() {
        if line.trim_start().starts_with("status:") {
            next.push_str(&format!("status: {status}\n"));
            saw_status = true;
        } else {
            next.push_str(line);
            next.push('\n');
        }
    }
    if !saw_status {
        next.push_str(&format!("status: {status}\n"));
    }
    write_file(path, &next)
}

fn write_receipt<K, V>(path: PathBuf, fields: &[(K, V)]) -> Result<()>
where
    K: AsRef<str>,
    V: AsRef<str>,
{
    let mut content = String::new();
    for (key, value) in fields {
        content.push_str(&format!("{}: {}\n", key.as_ref(), value.as_ref()));
    }
    write_file(path, &content)
}

fn write_file(path: PathBuf, content: &str) -> Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(path, content)?;
    Ok(())
}

fn reviewed_packet_digest(target: &Path) -> Result<String> {
    let mut rels = Vec::new();
    for entry in WalkDir::new(target)
        .into_iter()
        .filter_map(std::result::Result::ok)
    {
        if !entry.file_type().is_file() {
            continue;
        }
        let path = entry.path();
        let rel = path
            .strip_prefix(target)?
            .to_string_lossy()
            .replace('\\', "/");
        if digest_excluded(&rel) {
            continue;
        }
        rels.push(rel);
    }
    rels.sort();
    if rels.is_empty() {
        return Ok(
            "sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855".to_string(),
        );
    }
    let mut hashes = String::new();
    for rel in rels {
        let bytes = fs::read(target.join(&rel))?;
        let hash = hex::encode(Sha256::digest(&bytes));
        hashes.push_str(&format!("{hash}  {rel}\n"));
    }
    Ok(format!(
        "sha256:{}",
        hex::encode(Sha256::digest(hashes.as_bytes()))
    ))
}

fn run_implementation_fields() -> Vec<(&'static str, String)> {
    vec![
        ("verdict", "pass".to_string()),
        ("implemented_at", now_rfc3339()),
        ("promotion_evidence_count", "1".to_string()),
    ]
}

fn closeout_fields() -> Vec<(&'static str, String)> {
    vec![
        ("verdict", "pass".to_string()),
        ("closed_at", now_rfc3339()),
        ("archive_authorized", "yes".to_string()),
    ]
}

fn digest_excluded(rel: &str) -> bool {
    rel.starts_with('.')
        || rel.contains("/.")
        || matches!(rel, "SHA256SUMS.txt" | "support/SHA256SUMS.txt")
        || matches!(
            rel,
            "support/proposal-review.md" | "support/executable-implementation-prompt.md"
        )
        || matches!(rel, "support/proposal-creation.md")
        || rel.starts_with("support/revisions/")
        || matches!(
            rel,
            "support/implementation-run.md"
                | "support/implementation-conformance-review.md"
                | "support/post-implementation-drift-churn-review.md"
                | "support/proposal-closeout.md"
                | "support/validation.md"
        )
        || rel.starts_with("support/validation/")
        || rel.starts_with("support/.tmp/")
}
