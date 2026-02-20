use anyhow::{anyhow, Result};
use std::collections::BTreeMap;
use std::fs;
use std::io::ErrorKind;
use std::path::{Path, PathBuf};

#[derive(Debug, Clone)]
pub enum StagedFileEdit {
    Update {
        path: PathBuf,
        before: String,
        after: String,
        reason: String,
    },
    Create {
        path: PathBuf,
        after: String,
        reason: String,
    },
}

#[derive(Debug, Clone, Default)]
pub struct StagedEditBuffer {
    edits: BTreeMap<PathBuf, StagedFileEdit>,
}

#[derive(Debug, Clone)]
pub struct ApplyReport {
    pub attempted_files: usize,
    pub applied_files: usize,
    pub rolled_back_files: usize,
    pub audit_path: PathBuf,
}

#[derive(Debug, Clone)]
pub struct ApplyAuditSummary {
    pub path: PathBuf,
    pub timestamp_unix_ms: Option<u128>,
    pub status: String,
    pub summary: String,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum ApplyStatus {
    NoEdits,
    Applied,
    PreflightFailed,
    RolledBack,
    RollbackFailed,
}

#[derive(Debug, Clone)]
struct ApplyExecution {
    status: ApplyStatus,
    attempted_files: usize,
    applied_files: usize,
    rolled_back_files: usize,
    error: Option<String>,
    rollback_error: Option<String>,
}

impl ApplyExecution {
    fn success(attempted_files: usize) -> Self {
        Self {
            status: ApplyStatus::Applied,
            attempted_files,
            applied_files: attempted_files,
            rolled_back_files: 0,
            error: None,
            rollback_error: None,
        }
    }

    fn no_edits() -> Self {
        Self {
            status: ApplyStatus::NoEdits,
            attempted_files: 0,
            applied_files: 0,
            rolled_back_files: 0,
            error: None,
            rollback_error: None,
        }
    }

    fn preflight_failed(attempted_files: usize, error: String) -> Self {
        Self {
            status: ApplyStatus::PreflightFailed,
            attempted_files,
            applied_files: 0,
            rolled_back_files: 0,
            error: Some(error),
            rollback_error: None,
        }
    }

    fn rolled_back(attempted_files: usize, applied_files: usize, error: String) -> Self {
        Self {
            status: ApplyStatus::RolledBack,
            attempted_files,
            applied_files,
            rolled_back_files: applied_files,
            error: Some(error),
            rollback_error: None,
        }
    }

    fn rollback_failed(
        attempted_files: usize,
        applied_files: usize,
        error: String,
        rollback_error: String,
    ) -> Self {
        Self {
            status: ApplyStatus::RollbackFailed,
            attempted_files,
            applied_files,
            rolled_back_files: 0,
            error: Some(error),
            rollback_error: Some(rollback_error),
        }
    }

    fn is_success(&self) -> bool {
        matches!(self.status, ApplyStatus::NoEdits | ApplyStatus::Applied)
    }

    fn status_label(&self) -> &'static str {
        match self.status {
            ApplyStatus::NoEdits => "no-edits",
            ApplyStatus::Applied => "applied",
            ApplyStatus::PreflightFailed => "preflight-failed",
            ApplyStatus::RolledBack => "failed-rolled-back",
            ApplyStatus::RollbackFailed => "failed-rollback-error",
        }
    }

    fn summary_line(&self) -> String {
        match self.status {
            ApplyStatus::NoEdits => "No staged edits to apply.".to_string(),
            ApplyStatus::Applied => format!("Applied {} staged edits.", self.applied_files),
            ApplyStatus::PreflightFailed => format!(
                "Preflight failed before apply: {}",
                self.error.as_deref().unwrap_or("unknown preflight failure")
            ),
            ApplyStatus::RolledBack => format!(
                "Apply failed and rolled back {} file(s): {}",
                self.rolled_back_files,
                self.error.as_deref().unwrap_or("unknown write failure")
            ),
            ApplyStatus::RollbackFailed => format!(
                "Apply failed and rollback also failed: {}; rollback error: {}",
                self.error.as_deref().unwrap_or("unknown write failure"),
                self.rollback_error
                    .as_deref()
                    .unwrap_or("unknown rollback failure")
            ),
        }
    }
}

impl StagedEditBuffer {
    pub fn stage_update(&mut self, path: PathBuf, before: String, after: String, reason: String) {
        if before == after {
            return;
        }
        self.edits.insert(
            path.clone(),
            StagedFileEdit::Update {
                path,
                before,
                after,
                reason,
            },
        );
    }

    pub fn stage_create(&mut self, path: PathBuf, after: String, reason: String) {
        self.edits.insert(
            path.clone(),
            StagedFileEdit::Create {
                path,
                after,
                reason,
            },
        );
    }

    pub fn clear(&mut self) {
        self.edits.clear();
    }

    pub fn len(&self) -> usize {
        self.edits.len()
    }

    pub fn is_empty(&self) -> bool {
        self.edits.is_empty()
    }

    pub fn render_unified_patch(&self, repo_root: &Path) -> String {
        if self.edits.is_empty() {
            return "# No staged edits.\n".to_string();
        }

        let mut out = String::new();
        for edit in self.edits.values() {
            match edit {
                StagedFileEdit::Update {
                    path,
                    before,
                    after,
                    reason,
                } => {
                    let rel = to_rel_display(repo_root, path);
                    out.push_str(&format!("# reason: {reason}\n"));
                    out.push_str(&format!("diff --git a/{rel} b/{rel}\n"));
                    out.push_str(&format!("--- a/{rel}\n"));
                    out.push_str(&format!("+++ b/{rel}\n"));
                    out.push_str(&render_replacement_hunk(before, after));
                }
                StagedFileEdit::Create {
                    path,
                    after,
                    reason,
                } => {
                    let rel = to_rel_display(repo_root, path);
                    out.push_str(&format!("# reason: {reason}\n"));
                    out.push_str(&format!("diff --git a/{rel} b/{rel}\n"));
                    out.push_str("--- /dev/null\n");
                    out.push_str(&format!("+++ b/{rel}\n"));
                    out.push_str(&render_creation_hunk(after));
                }
            }
            out.push('\n');
        }
        out
    }

    pub fn export_patch_preview(&self, repo_root: &Path) -> Result<PathBuf> {
        let preview = self.render_unified_patch(repo_root);
        let reports_dir = repo_root.join(".harmony/output/reports");
        fs::create_dir_all(&reports_dir)?;

        let timestamp = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map_err(|e| anyhow!("system clock error: {e}"))?
            .as_millis();
        let path = reports_dir.join(format!("{timestamp}-studio-patch-preview.diff"));
        fs::write(&path, preview)?;
        Ok(path)
    }

    pub fn apply_to_disk(&self, repo_root: &Path) -> Result<ApplyReport> {
        let execution = self.execute_apply();
        let audit_path = write_apply_audit(repo_root, &execution, &self.edits)?;

        if execution.is_success() {
            return Ok(ApplyReport {
                attempted_files: execution.attempted_files,
                applied_files: execution.applied_files,
                rolled_back_files: execution.rolled_back_files,
                audit_path,
            });
        }

        Err(anyhow!(
            "{} (audit artifact: {})",
            execution.summary_line(),
            audit_path.display()
        ))
    }

    fn execute_apply(&self) -> ApplyExecution {
        if self.edits.is_empty() {
            return ApplyExecution::no_edits();
        }

        let attempted_files = self.edits.len();
        if let Err(error) = preflight_validate(&self.edits) {
            return ApplyExecution::preflight_failed(attempted_files, error.to_string());
        }

        let mut applied = Vec::new();
        for edit in self.edits.values() {
            match write_single_edit(edit) {
                Ok(applied_edit) => applied.push(applied_edit),
                Err(error) => {
                    let applied_files = applied.len();
                    return match rollback_applied_edits(&applied) {
                        Ok(()) => ApplyExecution::rolled_back(
                            attempted_files,
                            applied_files,
                            error.to_string(),
                        ),
                        Err(rollback_error) => ApplyExecution::rollback_failed(
                            attempted_files,
                            applied_files,
                            error.to_string(),
                            rollback_error.to_string(),
                        ),
                    };
                }
            }
        }

        ApplyExecution::success(attempted_files)
    }
}

pub fn list_recent_apply_audits(repo_root: &Path, limit: usize) -> Result<Vec<ApplyAuditSummary>> {
    if limit == 0 {
        return Ok(Vec::new());
    }

    let reports_dir = repo_root.join(".harmony/output/reports");
    if !reports_dir.exists() {
        return Ok(Vec::new());
    }

    let mut entries = Vec::new();
    for entry in fs::read_dir(&reports_dir)? {
        let entry = entry?;
        let path = entry.path();
        if !path.is_file() {
            continue;
        }
        let Some(file_name) = path.file_name().and_then(|name| name.to_str()) else {
            continue;
        };
        if !file_name.ends_with("-studio-apply-audit.md") {
            continue;
        }

        let timestamp_unix_ms = extract_timestamp_from_audit_file_name(file_name);
        entries.push((timestamp_unix_ms, path));
    }

    entries.sort_by(|left, right| right.0.cmp(&left.0).then_with(|| right.1.cmp(&left.1)));

    let mut audits = Vec::new();
    for (_, path) in entries.into_iter().take(limit) {
        let markdown = fs::read_to_string(&path)?;
        let parsed = parse_apply_audit_markdown(&markdown);
        audits.push(ApplyAuditSummary {
            path,
            timestamp_unix_ms: parsed.timestamp_unix_ms,
            status: parsed.status,
            summary: parsed.summary,
        });
    }

    Ok(audits)
}

#[derive(Debug)]
enum AppliedEdit {
    Updated {
        path: PathBuf,
        previous_contents: String,
    },
    Created {
        path: PathBuf,
    },
}

fn rollback_applied_edits(applied: &[AppliedEdit]) -> Result<()> {
    for edit in applied.iter().rev() {
        match edit {
            AppliedEdit::Updated {
                path,
                previous_contents,
            } => {
                fs::write(path, previous_contents).map_err(|error| {
                    anyhow!(
                        "failed to rollback updated file {}: {error}",
                        path.display()
                    )
                })?;
            }
            AppliedEdit::Created { path } => match fs::remove_file(path) {
                Ok(()) => {}
                Err(error) if error.kind() == ErrorKind::NotFound => {}
                Err(error) => {
                    return Err(anyhow!(
                        "failed to rollback created file {}: {error}",
                        path.display()
                    ));
                }
            },
        }
    }
    Ok(())
}

fn write_single_edit(edit: &StagedFileEdit) -> Result<AppliedEdit> {
    match edit {
        StagedFileEdit::Update {
            path,
            before,
            after,
            ..
        } => {
            if let Some(parent) = path.parent() {
                fs::create_dir_all(parent).map_err(|error| {
                    anyhow!(
                        "failed preparing parent directory {}: {error}",
                        parent.display()
                    )
                })?;
            }
            fs::write(path, after).map_err(|error| {
                anyhow!(
                    "failed writing staged update target {}: {error}",
                    path.display()
                )
            })?;
            Ok(AppliedEdit::Updated {
                path: path.clone(),
                previous_contents: before.clone(),
            })
        }
        StagedFileEdit::Create { path, after, .. } => {
            if let Some(parent) = path.parent() {
                fs::create_dir_all(parent).map_err(|error| {
                    anyhow!(
                        "failed preparing parent directory {}: {error}",
                        parent.display()
                    )
                })?;
            }
            fs::write(path, after).map_err(|error| {
                anyhow!(
                    "failed writing staged create target {}: {error}",
                    path.display()
                )
            })?;
            Ok(AppliedEdit::Created { path: path.clone() })
        }
    }
}

fn preflight_validate(edits: &BTreeMap<PathBuf, StagedFileEdit>) -> Result<()> {
    for edit in edits.values() {
        match edit {
            StagedFileEdit::Update { path, before, .. } => {
                if !path.exists() {
                    return Err(anyhow!(
                        "staged update target does not exist: {}",
                        path.display()
                    ));
                }

                let current = fs::read_to_string(path).map_err(|error| {
                    anyhow!(
                        "failed to read staged update target {}: {error}",
                        path.display()
                    )
                })?;
                if current != *before {
                    return Err(anyhow!(
                        "staged update conflict at {}: file changed since staging",
                        path.display()
                    ));
                }
            }
            StagedFileEdit::Create { path, .. } => {
                if path.exists() {
                    return Err(anyhow!(
                        "staged create target already exists: {}",
                        path.display()
                    ));
                }
            }
        }
    }
    Ok(())
}

fn write_apply_audit(
    repo_root: &Path,
    execution: &ApplyExecution,
    edits: &BTreeMap<PathBuf, StagedFileEdit>,
) -> Result<PathBuf> {
    let reports_dir = repo_root.join(".harmony/output/reports");
    match write_apply_audit_in_dir(&reports_dir, repo_root, execution, edits) {
        Ok(path) => Ok(path),
        Err(primary_error) => {
            let fallback_dir = std::env::temp_dir().join("harmony-studio-reports");
            write_apply_audit_in_dir(&fallback_dir, repo_root, execution, edits).map_err(
                |fallback_error| {
                    anyhow!(
                        "failed to write apply audit artifact in {}: {primary_error}; fallback {} also failed: {fallback_error}",
                        reports_dir.display(),
                        fallback_dir.display()
                    )
                },
            )
        }
    }
}

fn write_apply_audit_in_dir(
    reports_dir: &Path,
    repo_root: &Path,
    execution: &ApplyExecution,
    edits: &BTreeMap<PathBuf, StagedFileEdit>,
) -> Result<PathBuf> {
    fs::create_dir_all(reports_dir)?;

    let timestamp_unix_ms = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map_err(|e| anyhow!("system clock error: {e}"))?
        .as_millis();
    let pid = std::process::id();
    let path = reports_dir.join(format!("{timestamp_unix_ms}-{pid}-studio-apply-audit.md"));
    let markdown = render_apply_audit_markdown(timestamp_unix_ms, repo_root, execution, edits);
    fs::write(&path, markdown)?;
    Ok(path)
}

fn render_apply_audit_markdown(
    timestamp_unix_ms: u128,
    repo_root: &Path,
    execution: &ApplyExecution,
    edits: &BTreeMap<PathBuf, StagedFileEdit>,
) -> String {
    let mut out = String::new();
    out.push_str("# Harmony Studio Apply Audit\n\n");
    out.push_str(&format!("- timestamp_unix_ms: {timestamp_unix_ms}\n"));
    out.push_str(&format!("- status: {}\n", execution.status_label()));
    out.push_str(&format!(
        "- attempted_files: {}\n",
        execution.attempted_files
    ));
    out.push_str(&format!("- applied_files: {}\n", execution.applied_files));
    out.push_str(&format!(
        "- rolled_back_files: {}\n",
        execution.rolled_back_files
    ));
    out.push_str(&format!("- summary: {}\n", execution.summary_line()));
    if let Some(error) = &execution.error {
        out.push_str(&format!("- error: {error}\n"));
    }
    if let Some(error) = &execution.rollback_error {
        out.push_str(&format!("- rollback_error: {error}\n"));
    }

    out.push_str("\n## Staged Edits\n");
    if edits.is_empty() {
        out.push_str("- none\n");
        return out;
    }

    for edit in edits.values() {
        match edit {
            StagedFileEdit::Update { path, reason, .. } => {
                out.push_str(&format!(
                    "- update | {} | {reason}\n",
                    to_rel_display(repo_root, path)
                ));
            }
            StagedFileEdit::Create { path, reason, .. } => {
                out.push_str(&format!(
                    "- create | {} | {reason}\n",
                    to_rel_display(repo_root, path)
                ));
            }
        }
    }

    out
}

#[derive(Debug, Clone)]
struct ParsedApplyAudit {
    timestamp_unix_ms: Option<u128>,
    status: String,
    summary: String,
}

fn parse_apply_audit_markdown(markdown: &str) -> ParsedApplyAudit {
    let mut timestamp_unix_ms = None;
    let mut status = String::from("unknown");
    let mut summary = String::from("No summary captured.");

    for line in markdown.lines() {
        if let Some(value) = line.strip_prefix("- timestamp_unix_ms: ") {
            timestamp_unix_ms = value.trim().parse::<u128>().ok();
        } else if let Some(value) = line.strip_prefix("- status: ") {
            status = value.trim().to_string();
        } else if let Some(value) = line.strip_prefix("- summary: ") {
            summary = value.trim().to_string();
        }
    }

    ParsedApplyAudit {
        timestamp_unix_ms,
        status,
        summary,
    }
}

fn extract_timestamp_from_audit_file_name(file_name: &str) -> Option<u128> {
    let mut segments = file_name.splitn(2, '-');
    let timestamp = segments.next()?;
    timestamp.parse::<u128>().ok()
}

fn to_rel_display(root: &Path, path: &Path) -> String {
    path.strip_prefix(root)
        .unwrap_or(path)
        .to_string_lossy()
        .replace('\\', "/")
}

fn render_replacement_hunk(before: &str, after: &str) -> String {
    let old_lines: Vec<&str> = before.lines().collect();
    let new_lines: Vec<&str> = after.lines().collect();

    let mut out = String::new();
    out.push_str(&format!(
        "@@ -1,{} +1,{} @@\n",
        old_lines.len(),
        new_lines.len()
    ));
    for line in old_lines {
        out.push('-');
        out.push_str(line);
        out.push('\n');
    }
    for line in new_lines {
        out.push('+');
        out.push_str(line);
        out.push('\n');
    }
    out
}

fn render_creation_hunk(after: &str) -> String {
    let lines: Vec<&str> = after.lines().collect();
    let mut out = String::new();
    out.push_str(&format!("@@ -0,0 +1,{} @@\n", lines.len()));
    for line in lines {
        out.push('+');
        out.push_str(line);
        out.push('\n');
    }
    out
}

#[cfg(test)]
mod tests {
    use super::StagedEditBuffer;
    use std::fs;
    use std::path::PathBuf;
    use std::time::{SystemTime, UNIX_EPOCH};

    fn temp_dir(label: &str) -> PathBuf {
        let stamp = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("clock should be valid")
            .as_nanos();
        let pid = std::process::id();
        let path = std::env::temp_dir().join(format!("harmony-studio-{label}-{pid}-{stamp}"));
        fs::create_dir_all(&path).expect("temp dir should be created");
        path
    }

    fn extract_audit_path(message: &str) -> Option<PathBuf> {
        let marker = "audit artifact: ";
        let index = message.find(marker)?;
        let path = &message[(index + marker.len())..];
        Some(PathBuf::from(path.trim_end_matches(')')))
    }

    #[test]
    fn apply_to_disk_writes_update_and_create() {
        let root = temp_dir("apply-ok");
        let existing_path = root.join("01-existing.txt");
        fs::write(&existing_path, "before\n").expect("existing file should be written");

        let create_path = root.join("02-created.txt");

        let mut buffer = StagedEditBuffer::default();
        buffer.stage_update(
            existing_path.clone(),
            "before\n".to_string(),
            "after\n".to_string(),
            "update existing".to_string(),
        );
        buffer.stage_create(
            create_path.clone(),
            "new file\n".to_string(),
            "create file".to_string(),
        );

        let report = buffer.apply_to_disk(&root).expect("apply should succeed");
        assert_eq!(report.attempted_files, 2);
        assert_eq!(report.applied_files, 2);
        assert_eq!(report.rolled_back_files, 0);
        assert_eq!(
            fs::read_to_string(existing_path).expect("updated file should exist"),
            "after\n"
        );
        assert_eq!(
            fs::read_to_string(create_path).expect("created file should exist"),
            "new file\n"
        );
        assert!(report.audit_path.exists(), "audit artifact should exist");
        let audit_markdown =
            fs::read_to_string(&report.audit_path).expect("audit artifact should be readable");
        assert!(
            audit_markdown.contains("- status: applied"),
            "audit should contain applied status"
        );

        fs::remove_dir_all(root).expect("temp dir should be removed");
    }

    #[test]
    fn apply_to_disk_rolls_back_after_late_write_failure() {
        let root = temp_dir("apply-rollback");
        let update_path = root.join("01-update-target.txt");
        fs::write(&update_path, "original\n").expect("update target should be written");

        let blocked_parent = root.join("02-blocked-parent");
        fs::write(&blocked_parent, "not a directory\n").expect("blocked parent should be file");
        let create_path = blocked_parent.join("child.txt");

        let mut buffer = StagedEditBuffer::default();
        buffer.stage_update(
            update_path.clone(),
            "original\n".to_string(),
            "changed\n".to_string(),
            "update first".to_string(),
        );
        buffer.stage_create(
            create_path.clone(),
            "created\n".to_string(),
            "create second".to_string(),
        );

        let error = buffer.apply_to_disk(&root).expect_err("apply should fail");
        let message = format!("{error}");
        assert!(
            message.contains("rolled back"),
            "error should report rollback, got: {message}"
        );
        let audit_path = extract_audit_path(&message).expect("audit path should be present");
        assert!(
            audit_path.exists(),
            "audit artifact should exist on failure"
        );
        let audit_markdown =
            fs::read_to_string(&audit_path).expect("failure audit should be readable");
        assert!(
            audit_markdown.contains("- status: failed-rolled-back"),
            "audit should capture rollback status"
        );
        assert_eq!(
            fs::read_to_string(&update_path).expect("updated file should still exist"),
            "original\n",
            "updated file should be restored after rollback"
        );
        assert!(
            !create_path.exists(),
            "failed create target should not exist after rollback"
        );

        fs::remove_dir_all(root).expect("temp dir should be removed");
    }
}
