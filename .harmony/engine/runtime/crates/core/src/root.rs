use crate::errors::{ErrorCode, KernelError, Result};
use std::path::{Path, PathBuf};

/// Resolves the active `.harmony/` directory using the "nearest ancestor wins" rule.
pub struct RootResolver;

impl RootResolver {
    /// Resolve from an explicit starting directory.
    pub fn resolve_from(start: &Path) -> Result<PathBuf> {
        if let Some(override_path) = override_harmony_dir()? {
            return Ok(override_path);
        }

        let mut cur = start
            .canonicalize()
            .map_err(|e| KernelError::new(ErrorCode::Internal, format!("failed to canonicalize cwd: {e}")))?;

        loop {
            let candidate = cur.join(".harmony");
            if candidate.is_dir() {
                return Ok(candidate);
            }

            if !cur.pop() {
                break;
            }
        }

        Err(KernelError::new(
            ErrorCode::Internal,
            "no .harmony directory found in any parent of cwd",
        ))
    }

    /// Resolve from the current working directory.
    pub fn resolve() -> Result<PathBuf> {
        if let Some(override_path) = override_harmony_dir()? {
            return Ok(override_path);
        }

        let cwd = std::env::current_dir()
            .map_err(|e| KernelError::new(ErrorCode::Internal, format!("failed to read cwd: {e}")))?;
        Self::resolve_from(&cwd)
    }
}

fn override_harmony_dir() -> Result<Option<PathBuf>> {
    if let Some(harmony_dir) = std::env::var_os("HARMONY_DIR_OVERRIDE") {
        let path = PathBuf::from(harmony_dir);
        let canonical = path.canonicalize().map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to canonicalize HARMONY_DIR_OVERRIDE {}: {e}", path.display()),
            )
        })?;
        if !canonical.is_dir() {
            return Err(KernelError::new(
                ErrorCode::Internal,
                format!("HARMONY_DIR_OVERRIDE is not a directory: {}", canonical.display()),
            ));
        }
        return Ok(Some(canonical));
    }

    if let Some(root_dir) = std::env::var_os("HARMONY_ROOT_DIR") {
        let root = PathBuf::from(root_dir);
        let harmony_dir = root.join(".harmony");
        let canonical = harmony_dir.canonicalize().map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to canonicalize HARMONY_ROOT_DIR/.harmony {}: {e}", harmony_dir.display()),
            )
        })?;
        if !canonical.is_dir() {
            return Err(KernelError::new(
                ErrorCode::Internal,
                format!("HARMONY_ROOT_DIR does not contain .harmony/: {}", canonical.display()),
            ));
        }
        return Ok(Some(canonical));
    }

    Ok(None)
}
