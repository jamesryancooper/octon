use serde::{Deserialize, Serialize};
use std::marker::PhantomData;

pub trait EffectKind {
    const KIND: &'static str;
}

#[derive(Debug, Clone, Default, Serialize, Deserialize, PartialEq, Eq)]
pub struct AuthorizedEffectScope {
    #[serde(default)]
    pub read: Vec<String>,
    #[serde(default)]
    pub write: Vec<String>,
    #[serde(default)]
    pub executor_profile: Option<String>,
    #[serde(default)]
    pub locality_scope: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct AuthorizedEffectPayload {
    pub schema_version: String,
    pub token_id: String,
    pub token_type: String,
    pub effect_kind: String,
    pub run_id: String,
    pub request_id: String,
    pub grant_id: String,
    #[serde(default)]
    pub decision_artifact_ref: Option<String>,
    #[serde(default)]
    pub authority_grant_bundle_ref: Option<String>,
    pub run_control_root: String,
    pub run_evidence_root: String,
    #[serde(default)]
    pub lifecycle_state_ref: String,
    #[serde(default)]
    pub route_id: Option<String>,
    #[serde(default)]
    pub runtime_effective_route_bundle_ref: Option<String>,
    #[serde(default)]
    pub runtime_effective_route_bundle_sha256: Option<String>,
    #[serde(default)]
    pub runtime_effective_route_generation_id: Option<String>,
    #[serde(default)]
    pub runtime_effective_freshness_mode: Option<String>,
    #[serde(default)]
    pub runtime_effective_publication_receipt_ref: Option<String>,
    #[serde(default)]
    pub runtime_effective_non_authority_classification: Option<String>,
    #[serde(default)]
    pub support_target_tuple_ref: Option<String>,
    #[serde(default)]
    pub support_claim_effect: Option<String>,
    #[serde(default)]
    pub support_route: Option<String>,
    #[serde(default)]
    pub allowed_capability_packs: Vec<String>,
    pub scope_ref: String,
    #[serde(default)]
    pub scope_envelope: AuthorizedEffectScope,
    #[serde(default)]
    pub rollback_plan_ref: Option<String>,
    #[serde(default)]
    pub rollback_posture_ref: Option<String>,
    #[serde(default)]
    pub approval_request_ref: Option<String>,
    #[serde(default)]
    pub approval_grant_refs: Vec<String>,
    #[serde(default)]
    pub exception_lease_refs: Vec<String>,
    #[serde(default)]
    pub budget_ref: Option<String>,
    #[serde(default)]
    pub budget_rule_id: Option<String>,
    #[serde(default)]
    pub egress_ref: Option<String>,
    #[serde(default)]
    pub egress_route: Option<String>,
    pub issued_at: String,
    #[serde(default)]
    pub expires_at: Option<String>,
    pub single_use: bool,
    pub issuer_ref: String,
    #[serde(default)]
    pub revocation_refs: Vec<String>,
    pub token_record_ref: String,
    #[serde(default)]
    pub journal_ref: Option<String>,
    pub token_digest: String,
}

#[derive(Debug, Clone, Serialize, PartialEq, Eq)]
pub struct AuthorizedEffect<T> {
    #[serde(flatten)]
    payload: AuthorizedEffectPayload,
    #[serde(skip)]
    _marker: PhantomData<T>,
}

impl<T: EffectKind> AuthorizedEffect<T> {
    pub fn payload(&self) -> &AuthorizedEffectPayload {
        &self.payload
    }

    pub fn schema_version(&self) -> &str {
        &self.payload.schema_version
    }

    pub fn token_id(&self) -> &str {
        &self.payload.token_id
    }

    pub fn token_type(&self) -> &str {
        &self.payload.token_type
    }

    pub fn effect_kind(&self) -> &str {
        &self.payload.effect_kind
    }

    pub fn run_id(&self) -> &str {
        &self.payload.run_id
    }

    pub fn request_id(&self) -> &str {
        &self.payload.request_id
    }

    pub fn grant_id(&self) -> &str {
        &self.payload.grant_id
    }

    pub fn decision_artifact_ref(&self) -> Option<&str> {
        self.payload.decision_artifact_ref.as_deref()
    }

    pub fn authority_grant_bundle_ref(&self) -> Option<&str> {
        self.payload.authority_grant_bundle_ref.as_deref()
    }

    pub fn run_control_root(&self) -> &str {
        &self.payload.run_control_root
    }

    pub fn run_evidence_root(&self) -> &str {
        &self.payload.run_evidence_root
    }

    pub fn lifecycle_state_ref(&self) -> &str {
        &self.payload.lifecycle_state_ref
    }

    pub fn route_id(&self) -> Option<&str> {
        self.payload.route_id.as_deref()
    }

    pub fn runtime_effective_route_bundle_ref(&self) -> Option<&str> {
        self.payload.runtime_effective_route_bundle_ref.as_deref()
    }

    pub fn runtime_effective_route_bundle_sha256(&self) -> Option<&str> {
        self.payload
            .runtime_effective_route_bundle_sha256
            .as_deref()
    }

    pub fn runtime_effective_route_generation_id(&self) -> Option<&str> {
        self.payload
            .runtime_effective_route_generation_id
            .as_deref()
    }

    pub fn runtime_effective_freshness_mode(&self) -> Option<&str> {
        self.payload.runtime_effective_freshness_mode.as_deref()
    }

    pub fn runtime_effective_publication_receipt_ref(&self) -> Option<&str> {
        self.payload
            .runtime_effective_publication_receipt_ref
            .as_deref()
    }

    pub fn runtime_effective_non_authority_classification(&self) -> Option<&str> {
        self.payload
            .runtime_effective_non_authority_classification
            .as_deref()
    }

    pub fn support_target_tuple_ref(&self) -> Option<&str> {
        self.payload.support_target_tuple_ref.as_deref()
    }

    pub fn support_claim_effect(&self) -> Option<&str> {
        self.payload.support_claim_effect.as_deref()
    }

    pub fn support_route(&self) -> Option<&str> {
        self.payload.support_route.as_deref()
    }

    pub fn allowed_capability_packs(&self) -> &[String] {
        &self.payload.allowed_capability_packs
    }

    pub fn scope_ref(&self) -> &str {
        &self.payload.scope_ref
    }

    pub fn scope_envelope(&self) -> &AuthorizedEffectScope {
        &self.payload.scope_envelope
    }

    pub fn rollback_plan_ref(&self) -> Option<&str> {
        self.payload.rollback_plan_ref.as_deref()
    }

    pub fn rollback_posture_ref(&self) -> Option<&str> {
        self.payload.rollback_posture_ref.as_deref()
    }

    pub fn approval_request_ref(&self) -> Option<&str> {
        self.payload.approval_request_ref.as_deref()
    }

    pub fn approval_grant_refs(&self) -> &[String] {
        &self.payload.approval_grant_refs
    }

    pub fn exception_lease_refs(&self) -> &[String] {
        &self.payload.exception_lease_refs
    }

    pub fn budget_ref(&self) -> Option<&str> {
        self.payload.budget_ref.as_deref()
    }

    pub fn budget_rule_id(&self) -> Option<&str> {
        self.payload.budget_rule_id.as_deref()
    }

    pub fn egress_ref(&self) -> Option<&str> {
        self.payload.egress_ref.as_deref()
    }

    pub fn egress_route(&self) -> Option<&str> {
        self.payload.egress_route.as_deref()
    }

    pub fn issued_at(&self) -> &str {
        &self.payload.issued_at
    }

    pub fn expires_at(&self) -> Option<&str> {
        self.payload.expires_at.as_deref()
    }

    pub fn single_use(&self) -> bool {
        self.payload.single_use
    }

    pub fn issuer_ref(&self) -> &str {
        &self.payload.issuer_ref
    }

    pub fn revocation_refs(&self) -> &[String] {
        &self.payload.revocation_refs
    }

    pub fn token_record_ref(&self) -> &str {
        &self.payload.token_record_ref
    }

    pub fn journal_ref(&self) -> Option<&str> {
        self.payload.journal_ref.as_deref()
    }

    pub fn token_digest(&self) -> &str {
        &self.payload.token_digest
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct VerifiedEffect<T> {
    payload: AuthorizedEffectPayload,
    consumer_api_ref: String,
    target_scope: String,
    consumption_receipt_ref: String,
    journal_event_refs: Vec<String>,
    _marker: PhantomData<T>,
}

impl<T: EffectKind> VerifiedEffect<T> {
    pub fn payload(&self) -> &AuthorizedEffectPayload {
        &self.payload
    }

    pub fn token_id(&self) -> &str {
        &self.payload.token_id
    }

    pub fn effect_kind(&self) -> &str {
        &self.payload.effect_kind
    }

    pub fn scope_ref(&self) -> &str {
        &self.payload.scope_ref
    }

    pub fn consumer_api_ref(&self) -> &str {
        &self.consumer_api_ref
    }

    pub fn target_scope(&self) -> &str {
        &self.target_scope
    }

    pub fn consumption_receipt_ref(&self) -> &str {
        &self.consumption_receipt_ref
    }

    pub fn journal_event_refs(&self) -> &[String] {
        &self.journal_event_refs
    }
}

#[cfg(any(test, feature = "authority-mint"))]
pub mod authority_mint {
    use super::{
        AuthorizedEffect, AuthorizedEffectPayload, EffectKind, PhantomData, VerifiedEffect,
    };

    pub fn mint_authorized_effect<T: EffectKind>(
        payload: AuthorizedEffectPayload,
    ) -> AuthorizedEffect<T> {
        AuthorizedEffect {
            payload,
            _marker: PhantomData,
        }
    }

    pub fn mint_verified_effect<T: EffectKind>(
        payload: AuthorizedEffectPayload,
        consumer_api_ref: impl Into<String>,
        target_scope: impl Into<String>,
        consumption_receipt_ref: impl Into<String>,
        journal_event_refs: Vec<String>,
    ) -> VerifiedEffect<T> {
        VerifiedEffect {
            payload,
            consumer_api_ref: consumer_api_ref.into(),
            target_scope: target_scope.into(),
            consumption_receipt_ref: consumption_receipt_ref.into(),
            journal_event_refs,
            _marker: PhantomData,
        }
    }
}

#[cfg(any(test, feature = "test-support"))]
pub mod test_support {
    pub use crate::authority_mint::{mint_authorized_effect, mint_verified_effect};
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
