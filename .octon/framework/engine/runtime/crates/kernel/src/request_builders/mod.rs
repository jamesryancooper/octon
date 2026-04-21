use anyhow::{anyhow, Result};
use octon_authority_engine::{
    active_intent_ref, default_execution_role_ref, with_authority_env_metadata, ExecutionRoleRef,
    IntentRef,
};
use octon_core::config::RuntimeConfig;
use std::collections::BTreeMap;

use crate::side_effects;

pub const DEFAULT_MODEL_TIER: &str = "repo-local-governed";
pub const DEFAULT_WORKLOAD_TIER: &str = "repo-consequential";
pub const OBSERVE_AND_READ_WORKLOAD_TIER: &str = "observe-and-read";
pub const DEFAULT_LANGUAGE_RESOURCE_TIER: &str = "reference-owned";
pub const DEFAULT_LOCALE_TIER: &str = "english-primary";
pub const DEFAULT_HOST_ADAPTER: &str = "repo-shell";
pub const DEFAULT_MODEL_ADAPTER: &str = "repo-local-governed";

fn insert_if_missing(metadata: &mut BTreeMap<String, String>, key: &str, value: &str) {
    metadata
        .entry(key.to_string())
        .or_insert_with(|| value.to_string());
}

pub fn workflow_mode(mission_id: Option<&str>) -> String {
    if mission_id.is_some() {
        "autonomous".to_string()
    } else {
        "role-mediated".to_string()
    }
}

pub fn role_mediated_mode() -> String {
    workflow_mode(None)
}

pub fn bind_request(
    cfg: &RuntimeConfig,
    metadata: BTreeMap<String, String>,
    workload_tier: &str,
    host_adapter: &str,
) -> Result<(IntentRef, ExecutionRoleRef, BTreeMap<String, String>)> {
    let intent_ref = active_intent_ref(cfg)
        .ok_or_else(|| anyhow!("consequential execution requires an active workspace intent"))?;
    let execution_role_ref = default_execution_role_ref();
    let mut metadata = with_authority_env_metadata(metadata);

    insert_if_missing(&mut metadata, "support_tier", workload_tier);
    insert_if_missing(&mut metadata, "support_model_tier", DEFAULT_MODEL_TIER);
    insert_if_missing(
        &mut metadata,
        "support_language_resource_tier",
        DEFAULT_LANGUAGE_RESOURCE_TIER,
    );
    insert_if_missing(&mut metadata, "support_locale_tier", DEFAULT_LOCALE_TIER);
    insert_if_missing(&mut metadata, "support_host_adapter", host_adapter);
    insert_if_missing(
        &mut metadata,
        "support_model_adapter",
        DEFAULT_MODEL_ADAPTER,
    );

    let support_class = side_effects::classify_support_posture(workload_tier, host_adapter);
    metadata.insert(
        "material_side_effect_inventory_schema".to_string(),
        side_effects::MATERIAL_SIDE_EFFECT_INVENTORY_SCHEMA_REF.to_string(),
    );
    metadata.insert(
        "authorization_boundary_coverage_schema".to_string(),
        side_effects::AUTHORIZATION_BOUNDARY_COVERAGE_SCHEMA_REF.to_string(),
    );
    metadata.insert(
        "authorization_boundary_ref".to_string(),
        side_effects::AUTHORIZATION_BOUNDARY_REF.to_string(),
    );
    metadata.insert(
        "support_side_effect_class".to_string(),
        support_class.as_str().to_string(),
    );

    Ok((intent_ref, execution_role_ref, metadata))
}

pub fn bind_repo_local_request(
    cfg: &RuntimeConfig,
    metadata: BTreeMap<String, String>,
) -> Result<(IntentRef, ExecutionRoleRef, BTreeMap<String, String>)> {
    bind_request(cfg, metadata, DEFAULT_WORKLOAD_TIER, DEFAULT_HOST_ADAPTER)
}

pub fn bind_repo_observe_request(
    cfg: &RuntimeConfig,
    metadata: BTreeMap<String, String>,
) -> Result<(IntentRef, ExecutionRoleRef, BTreeMap<String, String>)> {
    bind_request(
        cfg,
        metadata,
        OBSERVE_AND_READ_WORKLOAD_TIER,
        DEFAULT_HOST_ADAPTER,
    )
}
