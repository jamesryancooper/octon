use anyhow::{anyhow, Result};
use octon_authority_engine::{
    active_intent_ref, default_actor_ref, with_authority_env_metadata, ActorRef, IntentRef,
};
use octon_core::config::RuntimeConfig;
use std::collections::BTreeMap;

pub const DEFAULT_MODEL_TIER: &str = "repo-local-governed";
pub const DEFAULT_WORKLOAD_TIER: &str = "repo-consequential";
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
        "agent-augmented".to_string()
    }
}

pub fn agent_augmented_mode() -> String {
    workflow_mode(None)
}

pub fn bind_request(
    cfg: &RuntimeConfig,
    metadata: BTreeMap<String, String>,
    workload_tier: &str,
    host_adapter: &str,
) -> Result<(IntentRef, ActorRef, BTreeMap<String, String>)> {
    let intent_ref = active_intent_ref(cfg)
        .ok_or_else(|| anyhow!("consequential execution requires an active workspace intent"))?;
    let actor_ref = default_actor_ref();
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

    Ok((intent_ref, actor_ref, metadata))
}

pub fn bind_repo_local_request(
    cfg: &RuntimeConfig,
    metadata: BTreeMap<String, String>,
) -> Result<(IntentRef, ActorRef, BTreeMap<String, String>)> {
    bind_request(cfg, metadata, DEFAULT_WORKLOAD_TIER, DEFAULT_HOST_ADAPTER)
}
