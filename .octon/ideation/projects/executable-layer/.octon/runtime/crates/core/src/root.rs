use crate::errors::{ErrorCode, KernelError, Result};
use std::path::{Path, PathBuf};

/// Resolves the active `.octon/` directory using the "nearest ancestor wins" rule.
pub struct RootResolver;

impl RootResolver {
    /// Resolve from an explicit starting directory.
    pub fn resolve_from(start: &Path) -> Result<PathBuf> {
        let mut cur = start
            .canonicalize()
            .map_err(|e| KernelError::new(ErrorCode::Internal, format!("failed to canonicalize cwd: {e}")))?;

        loop {
            let candidate = cur.join(".octon");
            if candidate.is_dir() {
                return Ok(candidate);
            }

            if !cur.pop() {
                break;
            }
        }

        Err(KernelError::new(
            ErrorCode::Internal,
            "no .octon directory found in any parent of cwd",
        ))
    }

    /// Resolve from the current working directory.
    pub fn resolve() -> Result<PathBuf> {
        let cwd = std::env::current_dir()
            .map_err(|e| KernelError::new(ErrorCode::Internal, format!("failed to read cwd: {e}")))?;
        Self::resolve_from(&cwd)
    }
}
