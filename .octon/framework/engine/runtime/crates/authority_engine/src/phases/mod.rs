use super::*;
use std::path::{Path, PathBuf};

pub(crate) mod preflight;
pub(crate) mod receipt;
pub(crate) mod results;
pub(crate) mod routing;

pub(crate) use results::AuthorizationPhaseResult;

pub(crate) fn phase_results_root(receipts_root: &Path) -> PathBuf {
    receipts_root.join("authorization-phases")
}
