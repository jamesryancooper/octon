use super::*;
use std::collections::BTreeMap;
use std::path::{Path, PathBuf};

pub(crate) mod preflight;
pub(crate) mod receipt;
pub(crate) mod results;
pub(crate) mod routing;

pub(crate) use results::AuthorizationPhaseResult;

pub(crate) fn phase_results_root(receipts_root: &Path) -> PathBuf {
    receipts_root.join("authorization-phases")
}

pub(crate) fn phase_result_ref(repo_root: &Path, receipts_root: &Path, phase_id: &str) -> String {
    path_tail(
        repo_root,
        &phase_results_root(receipts_root).join(format!("{phase_id}.json")),
    )
}

pub(crate) fn phase_result_artifact_refs(
    entries: Vec<(String, String)>,
) -> BTreeMap<String, String> {
    entries.into_iter().collect()
}
