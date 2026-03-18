use anyhow::{Context, Result};
use octon_core::orchestration::{
    ClosureReadiness, LookupQuery, LookupResult, OrchestrationInspector, OpsSnapshot, SurfaceSummary,
    SummarySurface,
};
use clap::ValueEnum;
use serde::Serialize;
use std::fs;
use std::path::{Path, PathBuf};

#[derive(Clone, Copy, Debug, Eq, PartialEq, ValueEnum)]
pub enum OutputFormat {
    Json,
    Markdown,
}

pub fn write_lookup(
    octon_dir: &Path,
    query: LookupQuery,
    format: OutputFormat,
    output_report: Option<PathBuf>,
) -> Result<()> {
    let inspector = OrchestrationInspector::from_octon_dir(octon_dir)?;
    let lookup = inspector.lookup(query)?;
    let markdown = render_lookup_markdown(&lookup);
    emit_output(&lookup, &markdown, format, output_report)
}

pub fn write_summary(
    octon_dir: &Path,
    surface: SummarySurface,
    format: OutputFormat,
    output_report: Option<PathBuf>,
) -> Result<()> {
    let inspector = OrchestrationInspector::from_octon_dir(octon_dir)?;
    let summary = inspector.summary(surface)?;
    let snapshot = inspector.snapshot()?;
    let markdown = render_summary_markdown(&summary, &snapshot);
    emit_output(&summary, &markdown, format, output_report)
}

pub fn write_incident_closure_readiness(
    octon_dir: &Path,
    incident_id: &str,
    format: OutputFormat,
    output_report: Option<PathBuf>,
) -> Result<()> {
    let inspector = OrchestrationInspector::from_octon_dir(octon_dir)?;
    let readiness = inspector.incident_closure_readiness(incident_id)?;
    let markdown = render_closure_readiness_markdown(&readiness);
    emit_output(&readiness, &markdown, format, output_report)
}

fn emit_output<T: Serialize>(
    value: &T,
    markdown: &str,
    format: OutputFormat,
    output_report: Option<PathBuf>,
) -> Result<()> {
    let rendered = match format {
        OutputFormat::Json => serde_json::to_string_pretty(value)
            .context("failed to serialize orchestration output as JSON")?,
        OutputFormat::Markdown => markdown.to_string(),
    };

    if let Some(path) = output_report {
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent)
                .with_context(|| format!("failed to create report parent {}", parent.display()))?;
        }
        fs::write(&path, rendered.as_bytes())
            .with_context(|| format!("failed to write report {}", path.display()))?;
    }

    println!("{rendered}");
    Ok(())
}

fn render_lookup_markdown(result: &LookupResult) -> String {
    let mut body = String::new();
    body.push_str("# Orchestration Lookup\n\n");
    body.push_str(&format!(
        "- query_kind: `{}`\n- query_id: `{}`\n\n",
        result.query_kind, result.query_id
    ));
    body.push_str("## Artifacts\n\n");
    if result.artifacts.is_empty() {
        body.push_str("- none\n");
    } else {
        for artifact in &result.artifacts {
            body.push_str(&format!(
                "- `{}` `{}` -> `{}`{}\n",
                artifact.kind,
                artifact.id,
                artifact.path,
                artifact
                    .status
                    .as_ref()
                    .map(|value| format!(" (`{value}`)"))
                    .unwrap_or_default()
            ));
            if let Some(summary) = &artifact.summary {
                body.push_str(&format!("  summary: {}\n", summary));
            }
            for (key, value) in &artifact.details {
                body.push_str(&format!("  {}: {}\n", key, value));
            }
        }
    }
    body.push_str("\n## Relations\n\n");
    if result.relations.is_empty() {
        body.push_str("- none\n");
    } else {
        for relation in &result.relations {
            body.push_str(&format!(
                "- `{}` -> `{}` ({})\n",
                relation.from, relation.to, relation.relation
            ));
        }
    }
    body.push_str("\n## Notes\n\n");
    if result.notes.is_empty() {
        body.push_str("- none\n");
    } else {
        for note in &result.notes {
            body.push_str(&format!("- {}\n", note));
        }
    }
    body
}

fn render_summary_markdown(summary: &SurfaceSummary, snapshot: &OpsSnapshot) -> String {
    let mut body = String::new();
    body.push_str("# Orchestration Summary\n\n");
    body.push_str(&format!(
        "- generated_at: `{}`\n- surface: `{}`\n\n",
        summary.generated_at, summary.surface
    ));

    if summary.surface == "all" {
        body.push_str("## Overview\n\n");
        body.push_str(&format!(
            "- watchers: {} ({} unhealthy)\n- automations: {} ({} attention)\n- runs: {} ({} running)\n- incidents: {} ({} open, {} blocked for closure)\n- queue: pending={} claimed={} retry={} dead_letter={} expired_claims={}\n",
            snapshot.overview.watcher_count,
            snapshot.overview.watcher_unhealthy_count,
            snapshot.overview.automation_count,
            snapshot.overview.automation_attention_count,
            snapshot.overview.run_count,
            snapshot.overview.running_run_count,
            snapshot.overview.incident_count,
            snapshot.overview.open_incident_count,
            snapshot.overview.incident_closure_blocked_count,
            snapshot.overview.queue_pending_count,
            snapshot.overview.queue_claimed_count,
            snapshot.overview.queue_retry_count,
            snapshot.overview.queue_dead_letter_count,
            snapshot.overview.queue_expired_claim_count
        ));
        return body;
    }

    body.push_str("## Payload\n\n");
    body.push_str("```json\n");
    body.push_str(
        &serde_json::to_string_pretty(&summary.payload)
            .unwrap_or_else(|_| "{}".to_string()),
    );
    body.push_str("\n```\n");
    body
}

fn render_closure_readiness_markdown(readiness: &ClosureReadiness) -> String {
    let mut body = String::new();
    body.push_str("# Incident Closure Readiness\n\n");
    body.push_str(&format!(
        "- incident_id: `{}`\n- severity: `{}`\n- status: `{}`\n- owner: `{}`\n- ready: `{}`\n\n",
        readiness.incident_id,
        readiness.severity,
        readiness.status,
        readiness.owner,
        readiness.ready
    ));
    body.push_str("## Linked Runs\n\n");
    if readiness.linked_run_ids.is_empty() {
        body.push_str("- none\n");
    } else {
        for run_id in &readiness.linked_run_ids {
            body.push_str(&format!("- `{}`\n", run_id));
        }
    }
    body.push_str("\n## Blockers\n\n");
    if readiness.blockers.is_empty() {
        body.push_str("- none\n");
    } else {
        for blocker in &readiness.blockers {
            body.push_str(&format!("- {}\n", blocker));
        }
    }
    body
}
