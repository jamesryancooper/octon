use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ReplayBundleRef {
    pub run_id: String,
    pub manifest_ref: String,
    pub external_index_ref: String,
}

pub fn canonical_bundle_ref(run_id: &str) -> ReplayBundleRef {
    ReplayBundleRef {
        run_id: run_id.to_string(),
        manifest_ref: format!(".octon/state/evidence/runs/{run_id}/replay/manifest.yml"),
        external_index_ref: format!(".octon/state/evidence/external-index/runs/{run_id}.yml"),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn canonical_bundle_ref_uses_runtime_roots() {
        let bundle = canonical_bundle_ref("run-123");
        assert_eq!(bundle.manifest_ref, ".octon/state/evidence/runs/run-123/replay/manifest.yml");
        assert_eq!(
            bundle.external_index_ref,
            ".octon/state/evidence/external-index/runs/run-123.yml"
        );
    }
}
