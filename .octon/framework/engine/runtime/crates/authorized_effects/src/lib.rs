use serde::{Deserialize, Serialize};
use std::marker::PhantomData;

pub trait EffectKind {
    const KIND: &'static str;
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuthorizedEffect<T> {
    pub request_id: String,
    pub run_root: String,
    #[serde(default)]
    pub support_tuple_ref: Option<String>,
    #[serde(default)]
    pub allowed_capability_packs: Vec<String>,
    pub scope_ref: String,
    #[serde(skip)]
    _marker: PhantomData<T>,
}

impl<T> AuthorizedEffect<T> {
    pub fn new(
        request_id: impl Into<String>,
        run_root: impl Into<String>,
        support_tuple_ref: Option<String>,
        allowed_capability_packs: Vec<String>,
        scope_ref: impl Into<String>,
    ) -> Self {
        Self {
            request_id: request_id.into(),
            run_root: run_root.into(),
            support_tuple_ref,
            allowed_capability_packs,
            scope_ref: scope_ref.into(),
            _marker: PhantomData,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RepoMutation;
impl EffectKind for RepoMutation {
    const KIND: &'static str = "repo-mutation";
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GeneratedEffectivePublication;
impl EffectKind for GeneratedEffectivePublication {
    const KIND: &'static str = "generated-effective-publication";
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StateControlMutation;
impl EffectKind for StateControlMutation {
    const KIND: &'static str = "state-control-mutation";
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EvidenceMutation;
impl EffectKind for EvidenceMutation {
    const KIND: &'static str = "evidence-mutation";
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExecutorLaunch;
impl EffectKind for ExecutorLaunch {
    const KIND: &'static str = "executor-launch";
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ServiceInvocation;
impl EffectKind for ServiceInvocation {
    const KIND: &'static str = "service-invocation";
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProtectedCiCheck;
impl EffectKind for ProtectedCiCheck {
    const KIND: &'static str = "protected-ci-check";
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExtensionActivation;
impl EffectKind for ExtensionActivation {
    const KIND: &'static str = "extension-activation";
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CapabilityPackActivation;
impl EffectKind for CapabilityPackActivation {
    const KIND: &'static str = "capability-pack-activation";
}
