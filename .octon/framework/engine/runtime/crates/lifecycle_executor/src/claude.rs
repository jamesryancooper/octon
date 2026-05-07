use crate::codex::execute_agent;
use crate::request::LifecycleRouteExecutionRequest;
use crate::result::LifecycleRouteExecutionResult;
use crate::LifecycleExecutionError;
use std::path::{Path, PathBuf};

pub fn execute_claude(
    repo_root: &Path,
    request: &LifecycleRouteExecutionRequest,
    executor_bin: PathBuf,
) -> Result<LifecycleRouteExecutionResult, LifecycleExecutionError> {
    execute_agent(repo_root, request, "claude", executor_bin)
}
