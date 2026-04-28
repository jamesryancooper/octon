use super::*;
use octon_authorized_effects::authority_mint::{mint_authorized_effect, mint_verified_effect};
use octon_authorized_effects::{
    AuthorizedEffect, AuthorizedEffectPayload, AuthorizedEffectScope, CapabilityPackActivation,
    EffectKind, EvidenceMutation, ExecutorLaunch, ExtensionActivation,
    GeneratedEffectivePublication, ProtectedCiCheck, RepoMutation, ServiceInvocation,
    StateControlMutation, VerifiedEffect,
};
use octon_core::errors::{ErrorCode, KernelError, Result as CoreResult};
use octon_runtime_bus::{
    JournalActor, JournalClassification, JournalEffect, JournalGoverningRefs, JournalLifecycle,
    JournalPayload, JournalRedaction, RunJournalAppendRequest,
};
use octon_runtime_resolver::{
    verify_runtime_route_bundle, verify_support_envelope_tuple, SupportEnvelopeTuplePosture,
};
use serde::{Deserialize, Serialize};
use serde_json::json;
use std::collections::BTreeSet;
use std::fs;
use std::path::{Path, PathBuf};
use time::format_description::well_known::Rfc3339;
use time::OffsetDateTime;

const TOKEN_SCHEMA_VERSION: &str = "authorized-effect-token-v2";
const TOKEN_CONSUMPTION_SCHEMA_VERSION: &str = "authorized-effect-token-consumption-v1";
const TOKEN_ISSUER_REF: &str = ".octon/framework/engine/runtime/crates/authority_engine";
const TOKEN_EVENT_PAYLOAD_SCHEMA_REF: &str =
    ".octon/framework/engine/runtime/spec/runtime-event-v1.schema.json";
const TOKEN_VERIFICATION_BUNDLE_SCHEMA_VERSION: &str =
    "authorized-effect-token-verification-bundle-v1";
const TOKEN_VERIFIER_VERSION: &str = "authorized-effect-verifier-v1";

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuthorizedEffectVerificationBundle {
    pub schema_version: String,
    pub execution_grant_ref: String,
    pub consumer_api_ref: String,
    pub target_scope: String,
    pub token_payload: AuthorizedEffectPayload,
}
#[derive(Debug, Clone, Serialize, Deserialize)]
struct AuthorizedEffectTokenRecord {
    schema_version: String,
    payload: AuthorizedEffectPayload,
    status: String,
    single_use: bool,
    consumption_count: u64,
    #[serde(default)]
    issued_event_ref: Option<String>,
    #[serde(default)]
    last_event_ref: Option<String>,
    #[serde(default)]
    last_consumption_receipt_ref: Option<String>,
    #[serde(default)]
    last_consumed_at: Option<String>,
    #[serde(default)]
    last_consumer_api_ref: Option<String>,
    #[serde(default)]
    last_target_scope: Option<String>,
    #[serde(default)]
    rejection_reason_codes: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct AuthorizedEffectConsumptionReceipt {
    schema_version: String,
    token_id: String,
    token_digest: String,
    source_token_digest: String,
    token_type: String,
    effect_kind: String,
    material_effect_class: String,
    consumer_api_ref: String,
    target_scope: String,
    verifier_version: String,
    verification_result: String,
    #[serde(default)]
    denial_reason: Option<String>,
    #[serde(default)]
    rejection_reason_codes: Vec<String>,
    #[serde(default)]
    approval_trace_refs: Vec<String>,
    #[serde(default)]
    journal_event_refs: Vec<String>,
    #[serde(default)]
    evidence_refs: Vec<String>,
    recorded_at: String,
    run_id: String,
    request_id: String,
    grant_id: String,
    token_record_ref: String,
}

pub fn issue_execution_artifact_effects(
    runtime_path: &Path,
    grant: &GrantBundle,
    artifact_root: impl Into<String>,
) -> CoreResult<ExecutionArtifactEffects> {
    let artifact_root = artifact_root.into();
    Ok(ExecutionArtifactEffects {
        evidence: issue_authorized_effect::<EvidenceMutation>(
            runtime_path,
            grant,
            artifact_root.clone(),
            false,
        )?,
        control: issue_authorized_effect::<StateControlMutation>(
            runtime_path,
            grant,
            artifact_root,
            false,
        )?,
    })
}

pub fn issue_evidence_mutation_effect(
    runtime_path: &Path,
    grant: &GrantBundle,
    scope_ref: impl Into<String>,
    single_use: bool,
) -> CoreResult<AuthorizedEffect<EvidenceMutation>> {
    issue_authorized_effect::<EvidenceMutation>(runtime_path, grant, scope_ref.into(), single_use)
}

pub fn issue_generated_effective_publication_effect(
    runtime_path: &Path,
    grant: &GrantBundle,
    scope_ref: impl Into<String>,
    single_use: bool,
) -> CoreResult<AuthorizedEffect<GeneratedEffectivePublication>> {
    issue_authorized_effect::<GeneratedEffectivePublication>(
        runtime_path,
        grant,
        scope_ref.into(),
        single_use,
    )
}

pub fn issue_service_invocation_effect(
    runtime_path: &Path,
    grant: &GrantBundle,
    scope_ref: impl Into<String>,
) -> CoreResult<AuthorizedEffect<ServiceInvocation>> {
    issue_authorized_effect::<ServiceInvocation>(runtime_path, grant, scope_ref.into(), true)
}

pub fn issue_repo_mutation_effect(
    runtime_path: &Path,
    grant: &GrantBundle,
    scope_ref: impl Into<String>,
) -> CoreResult<AuthorizedEffect<RepoMutation>> {
    issue_authorized_effect::<RepoMutation>(runtime_path, grant, scope_ref.into(), true)
}

pub fn issue_repo_mutation_effect_with_mode(
    runtime_path: &Path,
    grant: &GrantBundle,
    scope_ref: impl Into<String>,
    single_use: bool,
) -> CoreResult<AuthorizedEffect<RepoMutation>> {
    issue_authorized_effect::<RepoMutation>(runtime_path, grant, scope_ref.into(), single_use)
}

pub fn issue_executor_launch_effect(
    runtime_path: &Path,
    grant: &GrantBundle,
    scope_ref: impl Into<String>,
) -> CoreResult<AuthorizedEffect<ExecutorLaunch>> {
    issue_authorized_effect::<ExecutorLaunch>(runtime_path, grant, scope_ref.into(), true)
}

pub fn issue_extension_activation_effect(
    runtime_path: &Path,
    grant: &GrantBundle,
    scope_ref: impl Into<String>,
    single_use: bool,
) -> CoreResult<AuthorizedEffect<ExtensionActivation>> {
    issue_authorized_effect::<ExtensionActivation>(
        runtime_path,
        grant,
        scope_ref.into(),
        single_use,
    )
}

pub fn issue_capability_pack_activation_effect(
    runtime_path: &Path,
    grant: &GrantBundle,
    scope_ref: impl Into<String>,
    single_use: bool,
) -> CoreResult<AuthorizedEffect<CapabilityPackActivation>> {
    issue_authorized_effect::<CapabilityPackActivation>(
        runtime_path,
        grant,
        scope_ref.into(),
        single_use,
    )
}

pub fn issue_protected_ci_check_effect(
    runtime_path: &Path,
    grant: &GrantBundle,
    scope_ref: impl Into<String>,
    single_use: bool,
) -> CoreResult<AuthorizedEffect<ProtectedCiCheck>> {
    issue_authorized_effect::<ProtectedCiCheck>(runtime_path, grant, scope_ref.into(), single_use)
}

pub fn verify_authorized_effect<T: EffectKind>(
    runtime_path: &Path,
    grant: &GrantBundle,
    effect: &AuthorizedEffect<T>,
    consumer_api_ref: &str,
    target_scope: impl Into<String>,
) -> CoreResult<VerifiedEffect<T>> {
    let target_scope = target_scope.into();
    let (repo_root, bound) = token_runtime_context(runtime_path, grant)?;
    let now = timestamp_now()?;
    let rejection_context = TokenRejectionContext {
        repo_root: &repo_root,
        bound: &bound,
        grant,
        consumer_api_ref,
        target_scope: &target_scope,
        recorded_at: &now,
    };

    if !matches!(grant.decision, ExecutionDecision::Allow) {
        return reject_without_record(
            effect,
            &rejection_context,
            "EFFECT_TOKEN_DECISION_NOT_ALLOW",
            "authorized effect requires an allow decision",
        );
    }

    if effect.effect_kind() != T::KIND {
        return reject_without_record(
            effect,
            &rejection_context,
            "EFFECT_TOKEN_KIND_MISMATCH",
            "authorized effect kind does not match verifier kind",
        );
    }

    if effect.request_id() != grant.request_id {
        return reject_without_record(
            effect,
            &rejection_context,
            "EFFECT_TOKEN_REQUEST_MISMATCH",
            "authorized effect request id does not match the active grant",
        );
    }

    if effect.grant_id() != grant.grant_id {
        return reject_without_record(
            effect,
            &rejection_context,
            "EFFECT_TOKEN_GRANT_MISMATCH",
            "authorized effect grant id does not match the active grant",
        );
    }

    if effect.run_id() != grant.request_id {
        return reject_without_record(
            effect,
            &rejection_context,
            "EFFECT_TOKEN_RUN_MISMATCH",
            "authorized effect run id does not match the active run",
        );
    }

    let record_path = resolve_relative_from_runtime_path(runtime_path, effect.token_record_ref())
        .ok_or_else(|| {
        KernelError::new(
            ErrorCode::CapabilityDenied,
            format!(
                "failed to resolve effect token record {}",
                effect.token_record_ref()
            ),
        )
    })?;

    if !record_path.is_file() {
        return reject_without_record(
            effect,
            &rejection_context,
            "EFFECT_TOKEN_RECORD_MISSING",
            "authorized effect canonical record is missing",
        );
    }

    let mut record = load_token_record(&record_path)?;
    let expected_digest = compute_token_digest(&record.payload)?;
    if record.payload.token_digest != expected_digest || effect.token_digest() != expected_digest {
        return reject_with_record(
            effect,
            &mut record,
            &record_path,
            &rejection_context,
            "EFFECT_TOKEN_DIGEST_MISMATCH",
            "authorized effect digest does not match the canonical record",
            "effect-token-rejected",
        );
    }

    if record.payload.request_id != effect.request_id()
        || record.payload.grant_id != effect.grant_id()
        || record.payload.run_id != effect.run_id()
    {
        return reject_with_record(
            effect,
            &mut record,
            &record_path,
            &rejection_context,
            "EFFECT_TOKEN_CANONICAL_MISMATCH",
            "authorized effect does not match the canonical record",
            "effect-token-rejected",
        );
    }

    if !required_authority_refs_exist(&repo_root, effect.payload()) {
        return reject_with_record(
            effect,
            &mut record,
            &record_path,
            &rejection_context,
            "EFFECT_TOKEN_AUTHORITY_REF_MISSING",
            "authorized effect decision or grant reference is missing",
            "effect-token-rejected",
        );
    }

    if !run_roots_match(&repo_root, &bound, grant, effect.payload()) {
        return reject_with_record(
            effect,
            &mut record,
            &record_path,
            &rejection_context,
            "EFFECT_TOKEN_RUN_ROOT_MISMATCH",
            "authorized effect run roots do not match the active grant",
            "effect-token-rejected",
        );
    }

    if !route_binding_matches(grant, effect.payload()) {
        return reject_with_record(
            effect,
            &mut record,
            &record_path,
            &rejection_context,
            "EFFECT_TOKEN_ROUTE_MISMATCH",
            "authorized effect route id does not match the active grant",
            "effect-token-rejected",
        );
    }

    if runtime_freshness_denied(&repo_root, grant, effect.payload())? {
        return reject_with_record(
            effect,
            &mut record,
            &record_path,
            &rejection_context,
            "EFFECT_TOKEN_FRESHNESS_STALE",
            "authorized effect runtime-effective freshness proof is stale or mismatched",
            "effect-token-rejected",
        );
    }

    if !grant.granted_effect_kinds.is_empty()
        && !grant
            .granted_effect_kinds
            .iter()
            .any(|value| value == effect.effect_kind())
    {
        return reject_with_record(
            effect,
            &mut record,
            &record_path,
            &rejection_context,
            "EFFECT_TOKEN_NOT_GRANTED",
            "authorized effect kind is outside the active grant envelope",
            "effect-token-rejected",
        );
    }

    if support_route_denied(grant, effect.payload()) {
        return reject_with_record(
            effect,
            &mut record,
            &record_path,
            &rejection_context,
            "EFFECT_TOKEN_SUPPORT_ROUTE_BLOCKED",
            "authorized effect support route is not allow/admitted-live",
            "effect-token-rejected",
        );
    }

    if let Some(tuple_ref) = effect.support_target_tuple_ref() {
        let active_support_tuple_ref = support_target_tuple_ref_for_grant(grant);
        if let Some(active_tuple_ref) = active_support_tuple_ref.as_deref() {
            if tuple_ref != active_tuple_ref {
                return reject_with_record(
                    effect,
                    &mut record,
                    &record_path,
                    &rejection_context,
                    "EFFECT_TOKEN_SUPPORT_TUPLE_MISMATCH",
                    "authorized effect support tuple does not match the active grant",
                    "effect-token-rejected",
                );
            }
        }
        if tuple_ref.starts_with("tuple://") && !support_tuple_is_live(&repo_root, tuple_ref)? {
            return reject_with_record(
                effect,
                &mut record,
                &record_path,
                &rejection_context,
                "EFFECT_TOKEN_SUPPORT_TUPLE_NOT_LIVE",
                "authorized effect support tuple is not admitted live",
                "effect-token-rejected",
            );
        }
        if let Some(reason_code) = support_envelope_denial_code(&repo_root, effect.payload())? {
            return reject_with_record(
                effect,
                &mut record,
                &record_path,
                &rejection_context,
                reason_code,
                "authorized effect support tuple is not live in the reconciled support envelope",
                "effect-token-rejected",
            );
        }
    }

    if !capability_packs_allowed(grant, effect.allowed_capability_packs()) {
        return reject_with_record(
            effect,
            &mut record,
            &record_path,
            &rejection_context,
            "EFFECT_TOKEN_CAPABILITY_PACK_MISMATCH",
            "authorized effect capability packs exceed the active grant envelope",
            "effect-token-rejected",
        );
    }

    if !scope_matches(
        effect.scope_ref(),
        effect.scope_envelope(),
        &grant.scope_constraints,
        &target_scope,
    ) {
        return reject_with_record(
            effect,
            &mut record,
            &record_path,
            &rejection_context,
            "EFFECT_TOKEN_SCOPE_MISMATCH",
            "authorized effect scope does not cover the requested target",
            "effect-token-rejected",
        );
    }

    if let Some(expires_at) = effect.expires_at() {
        if timestamp_is_expired(expires_at, &now)? {
            return reject_with_record(
                effect,
                &mut record,
                &record_path,
                &rejection_context,
                "EFFECT_TOKEN_EXPIRED",
                "authorized effect token is expired",
                "effect-token-expired",
            );
        }
    }

    let active_revocations = load_active_revocation_refs_from_repo_root(
        &repo_root,
        effect.request_id(),
        effect.grant_id(),
    )?;
    if !active_revocations.is_empty() || !effect.revocation_refs().is_empty() {
        let mut reasons = active_revocations;
        reasons.extend(effect.revocation_refs().iter().cloned());
        record.payload.revocation_refs = dedupe_strings(&reasons);
        return reject_with_record(
            effect,
            &mut record,
            &record_path,
            &rejection_context,
            "EFFECT_TOKEN_REVOKED",
            "authorized effect token is revoked",
            "effect-token-revoked",
        );
    }

    if approval_denied(&repo_root, grant, effect.payload()) {
        return reject_with_record(
            effect,
            &mut record,
            &record_path,
            &rejection_context,
            "EFFECT_TOKEN_APPROVAL_MISSING",
            "authorized effect approval binding is missing or inactive",
            "effect-token-rejected",
        );
    }

    if exception_denied(&repo_root, grant, effect.payload()) {
        return reject_with_record(
            effect,
            &mut record,
            &record_path,
            &rejection_context,
            "EFFECT_TOKEN_EXCEPTION_MISSING",
            "authorized effect exception lease binding is missing or inactive",
            "effect-token-rejected",
        );
    }

    if rollback_denied(&repo_root, grant, effect.payload()) {
        return reject_with_record(
            effect,
            &mut record,
            &record_path,
            &rejection_context,
            "EFFECT_TOKEN_ROLLBACK_NOT_READY",
            "authorized effect rollback posture is not ready",
            "effect-token-rejected",
        );
    }

    if budget_denied(&repo_root, grant, effect.payload()) {
        return reject_with_record(
            effect,
            &mut record,
            &record_path,
            &rejection_context,
            "EFFECT_TOKEN_BUDGET_EXCEEDED",
            "authorized effect budget binding is missing or exceeded",
            "effect-token-rejected",
        );
    }

    if egress_denied(&repo_root, grant, effect.payload()) {
        return reject_with_record(
            effect,
            &mut record,
            &record_path,
            &rejection_context,
            "EFFECT_TOKEN_EGRESS_DENIED",
            "authorized effect egress binding is denied or missing",
            "effect-token-rejected",
        );
    }

    ensure_run_lifecycle_allows_consumption::<T>(&bound, &target_scope)?;

    if record.single_use && record.status == "consumed" {
        return reject_with_record(
            effect,
            &mut record,
            &record_path,
            &rejection_context,
            "EFFECT_TOKEN_ALREADY_CONSUMED",
            "authorized effect token is single-use and already consumed",
            "effect-token-rejected",
        );
    }

    let requested_event_ref = append_effect_token_event(
        &repo_root,
        &bound,
        grant,
        effect.token_id(),
        "effect-token-consumption-requested",
        &now,
        Some(effect.token_record_ref().to_string()),
        "authorized-action",
        "requires-fresh-authorization",
        "authorization",
        Some(json!({
            "consumer_api_ref": consumer_api_ref,
            "target_scope": target_scope,
            "token_type": effect.token_type(),
            "effect_kind": effect.effect_kind(),
        })),
        Some("Authorized effect consumption request recorded before mutation.".to_string()),
    )?;

    let receipt_path = token_receipt_path(
        &bound,
        effect.token_id(),
        "consumption",
        consumer_api_ref,
        &now,
    );
    let receipt_ref = path_tail(&repo_root, &receipt_path);

    let consumed_event_ref = append_effect_token_event(
        &repo_root,
        &bound,
        grant,
        effect.token_id(),
        "effect-token-consumed",
        &now,
        Some(effect.token_record_ref().to_string()),
        "committed-effect",
        "requires-fresh-authorization",
        "authorization",
        Some(json!({
            "consumer_api_ref": consumer_api_ref,
            "target_scope": target_scope,
            "consumption_receipt_ref": receipt_ref,
        })),
        Some("Authorized effect consumption recorded before the material attempt.".to_string()),
    )?;

    let receipt = AuthorizedEffectConsumptionReceipt {
        schema_version: TOKEN_CONSUMPTION_SCHEMA_VERSION.to_string(),
        token_id: effect.token_id().to_string(),
        token_digest: effect.token_digest().to_string(),
        source_token_digest: effect.token_digest().to_string(),
        token_type: effect.token_type().to_string(),
        effect_kind: effect.effect_kind().to_string(),
        material_effect_class: effect.effect_kind().to_string(),
        consumer_api_ref: consumer_api_ref.to_string(),
        target_scope: target_scope.clone(),
        verifier_version: TOKEN_VERIFIER_VERSION.to_string(),
        verification_result: "verified".to_string(),
        denial_reason: None,
        rejection_reason_codes: Vec::new(),
        approval_trace_refs: approval_trace_refs(effect.payload(), grant),
        journal_event_refs: vec![requested_event_ref.clone(), consumed_event_ref.clone()],
        evidence_refs: vec![effect.token_record_ref().to_string()],
        recorded_at: now.clone(),
        run_id: effect.run_id().to_string(),
        request_id: effect.request_id().to_string(),
        grant_id: effect.grant_id().to_string(),
        token_record_ref: effect.token_record_ref().to_string(),
    };
    write_json(&receipt_path, &receipt).map_err(token_write_error)?;

    record.consumption_count += 1;
    if record.single_use {
        record.status = "consumed".to_string();
    }
    record.last_event_ref = Some(consumed_event_ref.clone());
    record.last_consumption_receipt_ref = Some(receipt_ref.clone());
    record.last_consumed_at = Some(now.clone());
    record.last_consumer_api_ref = Some(consumer_api_ref.to_string());
    record.last_target_scope = Some(target_scope.clone());
    persist_token_record(&record_path, &record)?;

    Ok(mint_verified_effect(
        effect.payload().clone(),
        consumer_api_ref,
        target_scope,
        receipt_ref,
        vec![requested_event_ref, consumed_event_ref],
    ))
}

pub fn authorized_effect_reference<T: EffectKind>(
    verified: &VerifiedEffect<T>,
) -> AuthorizedEffectReference {
    AuthorizedEffectReference {
        token_id: verified.token_id().to_string(),
        token_type: verified.payload().token_type.clone(),
        effect_kind: verified.effect_kind().to_string(),
        scope_ref: verified.scope_ref().to_string(),
        token_record_ref: verified.payload().token_record_ref.clone(),
        consumption_receipt_ref: verified.consumption_receipt_ref().to_string(),
        journal_event_refs: verified.journal_event_refs().to_vec(),
    }
}

pub fn write_authorized_effect_verification_bundle<T: EffectKind>(
    effect: &AuthorizedEffect<T>,
    execution_grant_ref: impl Into<String>,
    consumer_api_ref: impl Into<String>,
    target_scope: impl Into<String>,
    output_path: &Path,
) -> CoreResult<AuthorizedEffectVerificationBundle> {
    let bundle = AuthorizedEffectVerificationBundle {
        schema_version: TOKEN_VERIFICATION_BUNDLE_SCHEMA_VERSION.to_string(),
        execution_grant_ref: execution_grant_ref.into(),
        consumer_api_ref: consumer_api_ref.into(),
        target_scope: target_scope.into(),
        token_payload: effect.payload().clone(),
    };
    write_json(output_path, &bundle).map_err(token_write_error)?;
    Ok(bundle)
}

pub fn verify_authorized_effect_verification_bundle(
    bundle_path: &Path,
) -> CoreResult<AuthorizedEffectReference> {
    let raw = fs::read_to_string(bundle_path).map_err(|error| {
        KernelError::new(
            ErrorCode::CapabilityDenied,
            format!(
                "failed to read authorized effect verification bundle {}: {error}",
                bundle_path.display()
            ),
        )
    })?;
    let bundle: AuthorizedEffectVerificationBundle =
        serde_json::from_str(&raw).map_err(|error| {
            KernelError::new(
                ErrorCode::CapabilityDenied,
                format!(
                    "failed to parse authorized effect verification bundle {}: {error}",
                    bundle_path.display()
                ),
            )
        })?;
    if bundle.schema_version != TOKEN_VERIFICATION_BUNDLE_SCHEMA_VERSION {
        return Err(KernelError::new(
            ErrorCode::CapabilityDenied,
            format!(
                "authorized effect verification bundle {} uses unsupported schema {}",
                bundle_path.display(),
                bundle.schema_version
            ),
        ));
    }

    let grant_path = resolve_relative_from_runtime_path(bundle_path, &bundle.execution_grant_ref)
        .ok_or_else(|| {
        KernelError::new(
            ErrorCode::CapabilityDenied,
            format!(
                "failed to resolve execution grant bundle ref {} from {}",
                bundle.execution_grant_ref,
                bundle_path.display()
            ),
        )
    })?;
    let grant_raw = fs::read_to_string(&grant_path).map_err(|error| {
        KernelError::new(
            ErrorCode::CapabilityDenied,
            format!(
                "failed to read execution grant bundle {}: {error}",
                grant_path.display()
            ),
        )
    })?;
    let grant: GrantBundle = serde_json::from_str(&grant_raw)
        .or_else(|_| serde_yaml::from_str(&grant_raw))
        .map_err(|error| {
            KernelError::new(
                ErrorCode::CapabilityDenied,
                format!(
                    "failed to parse execution grant bundle {}: {error}",
                    grant_path.display()
                ),
            )
        })?;

    match bundle.token_payload.effect_kind.as_str() {
        RepoMutation::KIND => verify_bundle_for_kind::<RepoMutation>(bundle_path, &grant, &bundle),
        GeneratedEffectivePublication::KIND => {
            verify_bundle_for_kind::<GeneratedEffectivePublication>(bundle_path, &grant, &bundle)
        }
        StateControlMutation::KIND => {
            verify_bundle_for_kind::<StateControlMutation>(bundle_path, &grant, &bundle)
        }
        EvidenceMutation::KIND => {
            verify_bundle_for_kind::<EvidenceMutation>(bundle_path, &grant, &bundle)
        }
        ExecutorLaunch::KIND => {
            verify_bundle_for_kind::<ExecutorLaunch>(bundle_path, &grant, &bundle)
        }
        ServiceInvocation::KIND => {
            verify_bundle_for_kind::<ServiceInvocation>(bundle_path, &grant, &bundle)
        }
        ProtectedCiCheck::KIND => {
            verify_bundle_for_kind::<ProtectedCiCheck>(bundle_path, &grant, &bundle)
        }
        ExtensionActivation::KIND => {
            verify_bundle_for_kind::<ExtensionActivation>(bundle_path, &grant, &bundle)
        }
        CapabilityPackActivation::KIND => {
            verify_bundle_for_kind::<CapabilityPackActivation>(bundle_path, &grant, &bundle)
        }
        other => Err(KernelError::new(
            ErrorCode::CapabilityDenied,
            format!("unsupported authorized effect verification bundle kind: {other}"),
        )),
    }
}

fn issue_authorized_effect<T: EffectKind>(
    runtime_path: &Path,
    grant: &GrantBundle,
    scope_ref: String,
    single_use: bool,
) -> CoreResult<AuthorizedEffect<T>> {
    let (repo_root, bound) = token_runtime_context(runtime_path, grant)?;
    let now = timestamp_now()?;
    let token_id = token_id_for::<T>(grant, &scope_ref, &now);
    let record_path = bound
        .control_root
        .join("effect-tokens")
        .join(format!("{token_id}.json"));
    let record_ref = path_tail(&repo_root, &record_path);

    if !matches!(grant.decision, ExecutionDecision::Allow) {
        let _ = append_effect_token_event(
            &repo_root,
            &bound,
            grant,
            &token_id,
            "effect-token-denied",
            &now,
            Some(record_ref),
            "authorized-action",
            "requires-fresh-authorization",
            "authorization",
            Some(json!({
                "scope_ref": scope_ref,
                "token_type": authorized_effect_type::<T>(),
                "effect_kind": T::KIND,
            })),
            Some("Token minting was denied because the grant was not allow.".to_string()),
        );
        return Err(KernelError::new(
            ErrorCode::CapabilityDenied,
            format!(
                "cannot issue authorized effect '{}' from non-allow decision",
                T::KIND
            ),
        ));
    }

    let requested_event_ref = append_effect_token_event(
        &repo_root,
        &bound,
        grant,
        &token_id,
        "effect-token-requested",
        &now,
        Some(record_ref.clone()),
        "requested-action",
        "requires-fresh-authorization",
        "authorization",
        Some(json!({
            "scope_ref": scope_ref,
            "token_type": authorized_effect_type::<T>(),
            "effect_kind": T::KIND,
        })),
        Some("Authorized effect token request recorded.".to_string()),
    )?;

    let payload = AuthorizedEffectPayload {
        schema_version: TOKEN_SCHEMA_VERSION.to_string(),
        token_id: token_id.clone(),
        token_type: authorized_effect_type::<T>(),
        effect_kind: T::KIND.to_string(),
        run_id: grant.request_id.clone(),
        request_id: grant.request_id.clone(),
        grant_id: grant.grant_id.clone(),
        decision_artifact_ref: grant.decision_artifact_ref.clone(),
        authority_grant_bundle_ref: grant.authority_grant_bundle_ref.clone(),
        run_control_root: bound.control_root_rel.clone(),
        run_evidence_root: bound.evidence_root_rel.clone(),
        lifecycle_state_ref: path_tail(&repo_root, &bound.runtime_state_path),
        route_id: grant.route_id.clone().or_else(|| route_id_for_grant(grant)),
        runtime_effective_route_bundle_ref: grant.runtime_effective_route_bundle_ref.clone(),
        runtime_effective_route_bundle_sha256: grant.runtime_effective_route_bundle_sha256.clone(),
        runtime_effective_route_generation_id: grant.runtime_effective_route_generation_id.clone(),
        runtime_effective_freshness_mode: grant.runtime_effective_freshness_mode.clone(),
        runtime_effective_publication_receipt_ref: grant
            .runtime_effective_publication_receipt_ref
            .clone(),
        runtime_effective_non_authority_classification: grant
            .runtime_effective_non_authority_classification
            .clone(),
        support_target_tuple_ref: support_target_tuple_ref_for_grant(grant),
        support_claim_effect: grant.runtime_effective_claim_effect.clone(),
        support_route: grant
            .support_posture
            .as_ref()
            .map(|posture| posture.route.clone()),
        allowed_capability_packs: granted_capability_packs(grant),
        scope_ref,
        scope_envelope: scope_envelope_from_grant(grant),
        rollback_plan_ref: grant.rollback_handle.clone(),
        rollback_posture_ref: grant.rollback_posture_ref.clone().or_else(|| {
            Some(format!(
                ".octon/state/control/execution/runs/{}/rollback-posture.yml",
                grant.request_id
            ))
        }),
        approval_request_ref: grant.approval_request_ref.clone(),
        approval_grant_refs: grant.approval_grant_refs.clone(),
        exception_lease_refs: grant.exception_lease_refs.clone(),
        budget_ref: grant
            .budget
            .as_ref()
            .and_then(|budget| budget.evidence_path.clone()),
        budget_rule_id: grant
            .budget
            .as_ref()
            .map(|budget| budget.rule_id.clone())
            .filter(|value| !value.trim().is_empty()),
        egress_ref: grant
            .network_egress_posture
            .as_ref()
            .and_then(|egress| egress.artifact_ref.clone()),
        egress_route: grant
            .network_egress_posture
            .as_ref()
            .map(|egress| egress.route.clone()),
        issued_at: now.clone(),
        expires_at: grant.expires_after.clone(),
        single_use,
        issuer_ref: TOKEN_ISSUER_REF.to_string(),
        revocation_refs: grant.revocation_refs.clone(),
        token_record_ref: record_ref.clone(),
        journal_ref: None,
        token_digest: String::new(),
    };
    let minted_event_ref = append_effect_token_event(
        &repo_root,
        &bound,
        grant,
        &token_id,
        "effect-token-minted",
        &now,
        Some(record_ref.clone()),
        "authorized-action",
        "requires-fresh-authorization",
        "authorization",
        Some(json!({
            "requested_event_ref": requested_event_ref,
            "token_type": payload.token_type,
            "effect_kind": payload.effect_kind,
        })),
        Some("Authorized effect token minted under the active run grant.".to_string()),
    )?;

    let mut payload = payload;
    payload.journal_ref = Some(minted_event_ref.clone());
    payload.token_digest = compute_token_digest(&payload)?;
    let record = AuthorizedEffectTokenRecord {
        schema_version: TOKEN_SCHEMA_VERSION.to_string(),
        payload: payload.clone(),
        status: "minted".to_string(),
        single_use,
        consumption_count: 0,
        issued_event_ref: Some(minted_event_ref.clone()),
        last_event_ref: Some(minted_event_ref.clone()),
        last_consumption_receipt_ref: None,
        last_consumed_at: None,
        last_consumer_api_ref: None,
        last_target_scope: None,
        rejection_reason_codes: Vec::new(),
    };
    persist_token_record(&record_path, &record)?;

    let mint_receipt_path = token_receipt_path(&bound, &token_id, "mint", T::KIND, &now);
    let mint_receipt = AuthorizedEffectConsumptionReceipt {
        schema_version: TOKEN_CONSUMPTION_SCHEMA_VERSION.to_string(),
        token_id,
        token_digest: payload.token_digest.clone(),
        source_token_digest: payload.token_digest.clone(),
        token_type: payload.token_type.clone(),
        effect_kind: payload.effect_kind.clone(),
        material_effect_class: payload.effect_kind.clone(),
        consumer_api_ref: "authority-engine::mint".to_string(),
        target_scope: payload.scope_ref.clone(),
        verifier_version: TOKEN_VERIFIER_VERSION.to_string(),
        verification_result: "minted".to_string(),
        denial_reason: None,
        rejection_reason_codes: Vec::new(),
        approval_trace_refs: approval_trace_refs(&payload, grant),
        journal_event_refs: vec![requested_event_ref, minted_event_ref],
        evidence_refs: vec![record_ref],
        recorded_at: now,
        run_id: payload.run_id.clone(),
        request_id: payload.request_id.clone(),
        grant_id: payload.grant_id.clone(),
        token_record_ref: payload.token_record_ref.clone(),
    };
    write_json(&mint_receipt_path, &mint_receipt).map_err(token_write_error)?;
    Ok(mint_authorized_effect(payload))
}

fn verify_bundle_for_kind<T: EffectKind>(
    runtime_path: &Path,
    grant: &GrantBundle,
    bundle: &AuthorizedEffectVerificationBundle,
) -> CoreResult<AuthorizedEffectReference> {
    let effect = mint_authorized_effect::<T>(bundle.token_payload.clone());
    let verified = verify_authorized_effect(
        runtime_path,
        grant,
        &effect,
        &bundle.consumer_api_ref,
        bundle.target_scope.clone(),
    )?;
    Ok(authorized_effect_reference(&verified))
}

fn token_runtime_context(
    runtime_path: &Path,
    grant: &GrantBundle,
) -> CoreResult<(PathBuf, BoundRunLifecycle)> {
    let repo_root = discover_repo_root(runtime_path).ok_or_else(|| {
        KernelError::new(
            ErrorCode::CapabilityDenied,
            format!(
                "failed to discover repo root from {}",
                runtime_path.display()
            ),
        )
    })?;
    let bound = bound_run_from_grant(runtime_path, grant).ok_or_else(|| {
        KernelError::new(
            ErrorCode::CapabilityDenied,
            "failed to bind canonical run roots for effect token enforcement",
        )
    })?;
    Ok((repo_root, bound))
}

fn token_id_for<T: EffectKind>(grant: &GrantBundle, scope_ref: &str, recorded_at: &str) -> String {
    let digest = sha256_bytes(
        format!(
            "{}:{}:{}:{}:{}",
            grant.request_id,
            grant.grant_id,
            T::KIND,
            scope_ref,
            recorded_at
        )
        .as_bytes(),
    );
    format!("effect-token-{}-{}", T::KIND, &digest[..12])
}

fn authorized_effect_type<T: EffectKind>() -> String {
    match T::KIND {
        "repo-mutation" => "AuthorizedEffect<RepoMutation>".to_string(),
        "generated-effective-publication" => {
            "AuthorizedEffect<GeneratedEffectivePublication>".to_string()
        }
        "state-control-mutation" => "AuthorizedEffect<StateControlMutation>".to_string(),
        "evidence-mutation" => "AuthorizedEffect<EvidenceMutation>".to_string(),
        "executor-launch" => "AuthorizedEffect<ExecutorLaunch>".to_string(),
        "service-invocation" => "AuthorizedEffect<ServiceInvocation>".to_string(),
        "protected-ci-check" => "AuthorizedEffect<ProtectedCiCheck>".to_string(),
        "extension-activation" => "AuthorizedEffect<ExtensionActivation>".to_string(),
        "capability-pack-activation" => "AuthorizedEffect<CapabilityPackActivation>".to_string(),
        other => format!("AuthorizedEffect<{other}>"),
    }
}

fn scope_envelope_from_grant(grant: &GrantBundle) -> AuthorizedEffectScope {
    AuthorizedEffectScope {
        read: grant.scope_constraints.read.clone(),
        write: grant.scope_constraints.write.clone(),
        executor_profile: grant.scope_constraints.executor_profile.clone(),
        locality_scope: grant.scope_constraints.locality_scope.clone(),
    }
}

fn granted_capability_packs(grant: &GrantBundle) -> Vec<String> {
    grant
        .support_posture
        .as_ref()
        .map(|posture| {
            if posture.requested_capability_packs.is_empty() {
                posture.allowed_capability_packs.clone()
            } else {
                posture.requested_capability_packs.clone()
            }
        })
        .unwrap_or_default()
}

fn support_target_tuple_ref_for_grant(grant: &GrantBundle) -> Option<String> {
    grant
        .support_target_tuple_ref
        .as_deref()
        .filter(|value| !value.trim().is_empty())
        .map(ToString::to_string)
        .or_else(|| {
            grant
                .support_posture
                .as_ref()
                .and_then(support_target_tuple_ref_from_posture)
        })
}

fn support_target_tuple_ref_from_posture(posture: &SupportTierPosture) -> Option<String> {
    let model_tier = posture
        .model_tier_id
        .as_deref()
        .filter(|value| !value.trim().is_empty())?;
    let workload_tier = posture
        .workload_tier_id
        .as_deref()
        .filter(|value| !value.trim().is_empty())
        .or_else(|| {
            (!posture.support_tier.trim().is_empty()).then_some(posture.support_tier.as_str())
        })?;
    let language_resource_tier = posture
        .language_resource_tier_id
        .as_deref()
        .filter(|value| !value.trim().is_empty())?;
    let locale_tier = posture
        .locale_tier_id
        .as_deref()
        .filter(|value| !value.trim().is_empty())?;
    let host_adapter = posture
        .host_adapter_id
        .as_deref()
        .filter(|value| !value.trim().is_empty())?;
    let model_adapter = posture
        .model_adapter_id
        .as_deref()
        .filter(|value| !value.trim().is_empty())?;

    Some(support_target_tuple_id(&SupportTargetTuple {
        model_tier: model_tier.to_string(),
        workload_tier: workload_tier.to_string(),
        language_resource_tier: language_resource_tier.to_string(),
        locale_tier: locale_tier.to_string(),
        host_adapter: host_adapter.to_string(),
        model_adapter: model_adapter.to_string(),
    }))
}

fn compute_token_digest(payload: &AuthorizedEffectPayload) -> CoreResult<String> {
    let mut canonical = payload.clone();
    canonical.token_digest.clear();
    let bytes = serde_json::to_vec(&canonical).map_err(|error| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to serialize effect token payload for hashing: {error}"),
        )
    })?;
    Ok(format!("sha256:{}", sha256_bytes(&bytes)))
}

fn persist_token_record(path: &Path, record: &AuthorizedEffectTokenRecord) -> CoreResult<()> {
    write_json(path, record).map_err(token_write_error)
}

fn load_token_record(path: &Path) -> CoreResult<AuthorizedEffectTokenRecord> {
    let raw = fs::read_to_string(path).map_err(|error| {
        KernelError::new(
            ErrorCode::CapabilityDenied,
            format!(
                "failed to read effect token record {}: {error}",
                path.display()
            ),
        )
    })?;
    serde_json::from_str(&raw).map_err(|error| {
        KernelError::new(
            ErrorCode::CapabilityDenied,
            format!(
                "failed to parse effect token record {}: {error}",
                path.display()
            ),
        )
    })
}

fn append_effect_token_event(
    repo_root: &Path,
    bound: &BoundRunLifecycle,
    grant: &GrantBundle,
    token_id: &str,
    event_type: &str,
    recorded_at: &str,
    subject_ref: Option<String>,
    event_plane: &str,
    replay_disposition: &str,
    effect_class: &str,
    typed_body: Option<serde_json::Value>,
    summary: Option<String>,
) -> CoreResult<String> {
    let state = reconstructed_lifecycle_state(bound)?;
    let receipt = append_validated_run_journal_event(
        &bound.control_root,
        &bound.runtime_state_path,
        RunJournalAppendRequest {
            run_id: grant.request_id.clone(),
            control_root_ref: bound.control_root_rel.clone(),
            event_id: format!("evt-{event_type}-{token_id}"),
            event_type: event_type.to_string(),
            recorded_at: recorded_at.to_string(),
            subject_ref,
            actor: JournalActor {
                actor_class: "runtime".to_string(),
                actor_ref: ".octon/framework/engine/runtime/crates/runtime_bus".to_string(),
            },
            classification: JournalClassification {
                event_plane: event_plane.to_string(),
                replay_disposition: replay_disposition.to_string(),
            },
            lifecycle: JournalLifecycle {
                state_before: Some(state.clone()),
                state_after: Some(state),
            },
            governing_refs: token_journal_governing_refs(bound, grant),
            payload: JournalPayload {
                payload_kind: if typed_body.is_some() {
                    "inline-typed".to_string()
                } else {
                    "none".to_string()
                },
                schema_ref: Some(TOKEN_EVENT_PAYLOAD_SCHEMA_REF.to_string()),
                typed_body,
                artifact_ref: None,
                artifact_hash: None,
                content_type: Some("application/json".to_string()),
                summary,
            },
            effect: JournalEffect {
                effect_class: effect_class.to_string(),
                reversibility_class: "reversible".to_string(),
                evidence_class: "required".to_string(),
            },
            redaction: JournalRedaction {
                redacted: false,
                justification: None,
                lineage_ref: None,
                omitted_fields: Vec::new(),
            },
            causality: octon_runtime_bus::JournalCausality::default(),
            governing_manifest_roles: vec!["grant_bundle_ref".to_string()],
            materialization: None,
            snapshot_refs: None,
            drift_status: Some("in-sync".to_string()),
            drift_ref: None,
        },
    )?;
    Ok(format!(
        "{}#{}",
        path_tail(repo_root, &receipt.ledger_path),
        receipt.event.event_id
    ))
}

fn token_journal_governing_refs(
    bound: &BoundRunLifecycle,
    grant: &GrantBundle,
) -> JournalGoverningRefs {
    JournalGoverningRefs {
        run_contract_ref: format!(
            ".octon/state/control/execution/runs/{}/run-contract.yml",
            grant.request_id
        ),
        run_manifest_ref: bound.run_manifest_ref.clone(),
        execution_request_ref: Some(format!(
            ".octon/state/evidence/runs/{}/receipts/execution-request.json",
            grant.request_id
        )),
        authority_route_receipt_ref: grant.decision_artifact_ref.clone(),
        grant_bundle_ref: grant.authority_grant_bundle_ref.clone(),
        policy_receipt_ref: grant.policy_receipt_path.clone(),
        approval_ref: grant
            .approval_request_ref
            .clone()
            .or_else(|| grant.approval_grant_refs.first().cloned()),
        lease_ref: grant.exception_lease_refs.first().cloned(),
        revocation_ref: grant.revocation_refs.first().cloned(),
        support_target_tuple_ref: grant.support_target_tuple_ref.clone(),
        rollback_plan_ref: grant.rollback_handle.clone(),
        rollback_posture_ref: Some(format!(
            ".octon/state/control/execution/runs/{}/rollback-posture.yml",
            grant.request_id
        )),
        context_pack_ref: grant.context_pack_ref.clone(),
        stage_attempt_ref: grant.stage_attempt_ref.clone(),
        checkpoint_ref: None,
        validator_result_ref: None,
        evidence_snapshot_ref: None,
        disclosure_ref: None,
        drift_ref: None,
        continuity_ref: None,
        additional_refs: Vec::new(),
    }
}

fn token_receipt_path(
    bound: &BoundRunLifecycle,
    token_id: &str,
    phase: &str,
    suffix: &str,
    recorded_at: &str,
) -> PathBuf {
    let digest = sha256_bytes(format!("{token_id}:{phase}:{suffix}:{recorded_at}").as_bytes());
    bound
        .evidence_root
        .join("receipts")
        .join("effect-tokens")
        .join(token_id)
        .join(format!("{phase}-{}.json", &digest[..12]))
}

fn token_write_error(error: anyhow::Error) -> KernelError {
    KernelError::new(
        ErrorCode::Internal,
        format!("failed to persist authorized effect evidence: {error}"),
    )
}

fn support_tuple_is_live(repo_root: &Path, tuple_ref: &str) -> CoreResult<bool> {
    let path = resolve_repo_ref(repo_root, ".octon/instance/governance/support-targets.yml");
    let raw = fs::read_to_string(&path).map_err(|error| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to read support targets {}: {error}", path.display()),
        )
    })?;
    let document: serde_yaml::Value = serde_yaml::from_str(&raw).map_err(|error| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to parse support targets {}: {error}",
                path.display()
            ),
        )
    })?;
    Ok(document["tuple_admissions"]
        .as_sequence()
        .into_iter()
        .flatten()
        .any(|entry| {
            entry["tuple_id"].as_str() == Some(tuple_ref)
                && entry["claim_effect"].as_str() == Some("admitted-live-claim")
        }))
}

fn support_envelope_denial_code(
    repo_root: &Path,
    payload: &AuthorizedEffectPayload,
) -> CoreResult<Option<&'static str>> {
    if payload.runtime_effective_freshness_mode.as_deref() == Some("publication-bypass")
        && payload.effect_kind == GeneratedEffectivePublication::KIND
    {
        return Ok(None);
    }
    let Some(tuple_ref) = payload
        .support_target_tuple_ref
        .as_deref()
        .filter(|value| !value.trim().is_empty())
    else {
        return Ok(Some("EFFECT_TOKEN_SUPPORT_ENVELOPE_BLOCKED"));
    };
    let octon_dir = repo_root.join(".octon");
    let verified = match verify_support_envelope_tuple(&octon_dir, tuple_ref) {
        Ok(verified) => verified,
        Err(_) => return Ok(Some("EFFECT_TOKEN_SUPPORT_ENVELOPE_BLOCKED")),
    };
    let reason_code = match verified.posture {
        SupportEnvelopeTuplePosture::Live => None,
        SupportEnvelopeTuplePosture::Unsupported | SupportEnvelopeTuplePosture::StageOnly => {
            Some("EFFECT_TOKEN_SUPPORT_TUPLE_UNSUPPORTED")
        }
        SupportEnvelopeTuplePosture::Excluded => Some("EFFECT_TOKEN_SUPPORT_TUPLE_EXCLUDED"),
        SupportEnvelopeTuplePosture::Stale => Some("EFFECT_TOKEN_FRESHNESS_STALE"),
        SupportEnvelopeTuplePosture::Missing | SupportEnvelopeTuplePosture::Blocked => {
            Some("EFFECT_TOKEN_SUPPORT_ENVELOPE_BLOCKED")
        }
    };
    Ok(reason_code)
}

fn capability_packs_allowed(grant: &GrantBundle, token_packs: &[String]) -> bool {
    let allowed = grant
        .support_posture
        .as_ref()
        .map(|posture| {
            if posture.requested_capability_packs.is_empty() {
                posture.allowed_capability_packs.clone()
            } else {
                posture.requested_capability_packs.clone()
            }
        })
        .unwrap_or_default();
    if allowed.is_empty() {
        return true;
    }
    let allowed: BTreeSet<_> = allowed.into_iter().collect();
    token_packs.iter().all(|value| allowed.contains(value))
}

fn required_authority_refs_exist(repo_root: &Path, payload: &AuthorizedEffectPayload) -> bool {
    payload
        .decision_artifact_ref
        .as_deref()
        .filter(|value| !value.trim().is_empty())
        .map(|value| repo_ref_exists(repo_root, value))
        .unwrap_or(false)
        && payload
            .authority_grant_bundle_ref
            .as_deref()
            .filter(|value| !value.trim().is_empty())
            .map(|value| repo_ref_exists(repo_root, value))
            .unwrap_or(false)
}

fn run_roots_match(
    repo_root: &Path,
    bound: &BoundRunLifecycle,
    grant: &GrantBundle,
    payload: &AuthorizedEffectPayload,
) -> bool {
    let lifecycle_state_ref = path_tail(repo_root, &bound.runtime_state_path);
    payload.run_control_root == bound.control_root_rel
        && payload.run_control_root == grant.run_control_root.clone().unwrap_or_default()
        && payload.run_evidence_root == bound.evidence_root_rel
        && payload.run_evidence_root == grant.run_root
        && payload.lifecycle_state_ref == lifecycle_state_ref
        && repo_ref_exists(repo_root, &payload.lifecycle_state_ref)
}

fn route_id_for_grant(grant: &GrantBundle) -> Option<String> {
    let generation_id = grant
        .runtime_effective_route_generation_id
        .as_deref()
        .filter(|value| !value.trim().is_empty())?;
    let tuple_ref = support_target_tuple_ref_for_grant(grant)?;
    Some(format!("runtime-route:{generation_id}:{tuple_ref}"))
}

fn route_binding_matches(grant: &GrantBundle, payload: &AuthorizedEffectPayload) -> bool {
    let expected_route = grant.route_id.clone().or_else(|| route_id_for_grant(grant));
    expected_route.as_deref() == payload.route_id.as_deref()
        && optional_string_matches(
            grant.runtime_effective_route_bundle_ref.as_deref(),
            payload.runtime_effective_route_bundle_ref.as_deref(),
        )
        && optional_string_matches(
            grant.runtime_effective_route_bundle_sha256.as_deref(),
            payload.runtime_effective_route_bundle_sha256.as_deref(),
        )
        && optional_string_matches(
            grant.runtime_effective_route_generation_id.as_deref(),
            payload.runtime_effective_route_generation_id.as_deref(),
        )
        && optional_string_matches(
            grant.runtime_effective_freshness_mode.as_deref(),
            payload.runtime_effective_freshness_mode.as_deref(),
        )
        && optional_string_matches(
            grant.runtime_effective_publication_receipt_ref.as_deref(),
            payload.runtime_effective_publication_receipt_ref.as_deref(),
        )
        && optional_string_matches(
            grant
                .runtime_effective_non_authority_classification
                .as_deref(),
            payload
                .runtime_effective_non_authority_classification
                .as_deref(),
        )
}

fn runtime_freshness_denied(
    repo_root: &Path,
    grant: &GrantBundle,
    payload: &AuthorizedEffectPayload,
) -> CoreResult<bool> {
    let freshness_mode = payload
        .runtime_effective_freshness_mode
        .as_deref()
        .filter(|value| !value.trim().is_empty());
    if freshness_mode == Some("publication-bypass") {
        return Ok(false);
    }
    if freshness_mode.is_none() {
        return Ok(true);
    }
    let octon_dir = repo_root.join(".octon");
    let verified = match verify_runtime_route_bundle(&octon_dir) {
        Ok(verified) => verified,
        Err(_) => return Ok(true),
    };
    let bundle_ref = path_tail(repo_root, &verified.bundle_path);
    let non_authority_mismatch = !verified.lock.non_authority_classification.trim().is_empty()
        && payload
            .runtime_effective_non_authority_classification
            .as_deref()
            != Some(verified.lock.non_authority_classification.as_str());

    if payload.runtime_effective_route_bundle_ref.as_deref() != Some(bundle_ref.as_str())
        || payload.runtime_effective_route_bundle_sha256.as_deref()
            != Some(verified.bundle_sha256.as_str())
        || payload.runtime_effective_route_generation_id.as_deref()
            != Some(verified.generation_id())
        || payload.runtime_effective_freshness_mode.as_deref() != Some(verified.freshness_mode())
        || payload.runtime_effective_publication_receipt_ref.as_deref()
            != Some(verified.lock.publication_receipt_path.as_str())
        || non_authority_mismatch
    {
        return Ok(true);
    }
    if let Some(receipt_ref) = payload.runtime_effective_publication_receipt_ref.as_deref() {
        if !repo_ref_exists(repo_root, receipt_ref) {
            return Ok(true);
        }
    }
    if !optional_string_matches(
        grant.runtime_effective_route_generation_id.as_deref(),
        payload.runtime_effective_route_generation_id.as_deref(),
    ) {
        return Ok(true);
    }
    Ok(false)
}

fn support_route_denied(grant: &GrantBundle, payload: &AuthorizedEffectPayload) -> bool {
    if payload.support_claim_effect.as_deref() != grant.runtime_effective_claim_effect.as_deref() {
        return true;
    }
    if let Some(claim_effect) = payload.support_claim_effect.as_deref() {
        if claim_effect != "admitted-live-claim" && claim_effect != "publication-bypass" {
            return true;
        }
    } else {
        return true;
    }
    let grant_route = grant
        .support_posture
        .as_ref()
        .map(|posture| posture.route.as_str());
    !(payload.support_route.as_deref() == grant_route
        && payload.support_route.as_deref() == Some("allow"))
}

fn approval_denied(
    repo_root: &Path,
    grant: &GrantBundle,
    payload: &AuthorizedEffectPayload,
) -> bool {
    let approval_required = grant.approval_request_ref.is_some()
        || payload.approval_request_ref.is_some()
        || !grant.approval_grant_refs.is_empty()
        || !payload.approval_grant_refs.is_empty();
    if !approval_required {
        return false;
    }
    if grant.approval_request_ref.as_deref() != payload.approval_request_ref.as_deref() {
        return true;
    }
    if let Some(request_ref) = payload.approval_request_ref.as_deref() {
        if !repo_ref_exists(repo_root, request_ref) {
            return true;
        }
    }
    if grant.approval_grant_refs.is_empty()
        || payload.approval_grant_refs.is_empty()
        || !same_string_set(&grant.approval_grant_refs, &payload.approval_grant_refs)
    {
        return true;
    }
    payload
        .approval_grant_refs
        .iter()
        .any(|grant_ref| !active_yaml_ref(repo_root, grant_ref))
}

fn exception_denied(
    repo_root: &Path,
    grant: &GrantBundle,
    payload: &AuthorizedEffectPayload,
) -> bool {
    let egress_uses_exception = grant
        .network_egress_posture
        .as_ref()
        .and_then(|posture| posture.source_kind.as_deref())
        == Some("exception-lease");
    let exception_required = egress_uses_exception
        || !grant.exception_lease_refs.is_empty()
        || !payload.exception_lease_refs.is_empty();
    if !exception_required {
        return false;
    }
    if grant.exception_lease_refs.is_empty()
        || payload.exception_lease_refs.is_empty()
        || !same_string_set(&grant.exception_lease_refs, &payload.exception_lease_refs)
    {
        return true;
    }
    payload
        .exception_lease_refs
        .iter()
        .any(|lease_ref| !active_yaml_ref(repo_root, lease_ref))
}

fn rollback_denied(
    repo_root: &Path,
    grant: &GrantBundle,
    payload: &AuthorizedEffectPayload,
) -> bool {
    let expected_posture_ref = grant.rollback_posture_ref.clone().unwrap_or_else(|| {
        format!(
            ".octon/state/control/execution/runs/{}/rollback-posture.yml",
            grant.request_id
        )
    });
    if payload.rollback_posture_ref.as_deref() != Some(expected_posture_ref.as_str())
        || !repo_ref_exists(repo_root, &expected_posture_ref)
    {
        return true;
    }
    if let Some(rollback_handle) = grant.rollback_handle.as_deref() {
        payload.rollback_plan_ref.as_deref() != Some(rollback_handle)
    } else {
        false
    }
}

fn budget_denied(repo_root: &Path, grant: &GrantBundle, payload: &AuthorizedEffectPayload) -> bool {
    let Some(budget) = grant.budget.as_ref() else {
        return payload.budget_ref.is_some() || payload.budget_rule_id.is_some();
    };
    if budget
        .reason_codes
        .iter()
        .any(|reason| reason.contains("BUDGET_DENY") || reason.contains("BUDGET_EXCEEDED"))
    {
        return true;
    }
    if payload.budget_rule_id.as_deref() != Some(budget.rule_id.as_str()) {
        return true;
    }
    match budget.evidence_path.as_deref() {
        Some(evidence_path) => {
            payload.budget_ref.as_deref() != Some(evidence_path)
                || !repo_ref_exists(repo_root, evidence_path)
        }
        None => payload.budget_ref.is_some(),
    }
}

fn egress_denied(repo_root: &Path, grant: &GrantBundle, payload: &AuthorizedEffectPayload) -> bool {
    let Some(egress) = grant.network_egress_posture.as_ref() else {
        return payload.egress_ref.is_some() || payload.egress_route.is_some();
    };
    if egress.route != "allow" || payload.egress_route.as_deref() != Some(egress.route.as_str()) {
        return true;
    }
    match egress.artifact_ref.as_deref() {
        Some(artifact_ref) => {
            payload.egress_ref.as_deref() != Some(artifact_ref)
                || !repo_ref_exists(repo_root, artifact_ref)
        }
        None => payload.egress_ref.is_some(),
    }
}

fn same_string_set(left: &[String], right: &[String]) -> bool {
    let left: BTreeSet<&str> = left.iter().map(String::as_str).collect();
    let right: BTreeSet<&str> = right.iter().map(String::as_str).collect();
    left == right
}

fn optional_string_matches(expected: Option<&str>, actual: Option<&str>) -> bool {
    match expected {
        Some(expected) if !expected.trim().is_empty() => actual == Some(expected),
        _ => actual.map(|value| value.trim().is_empty()).unwrap_or(true),
    }
}

fn repo_ref_exists(repo_root: &Path, reference: &str) -> bool {
    let trimmed = reference.trim();
    if trimmed.is_empty() || trimmed.contains("<pending>") {
        return false;
    }
    let path_ref = trimmed.split('#').next().unwrap_or(trimmed);
    resolve_repo_ref(repo_root, path_ref).exists()
}

fn active_yaml_ref(repo_root: &Path, reference: &str) -> bool {
    let trimmed = reference.trim();
    if !repo_ref_exists(repo_root, trimmed) {
        return false;
    }
    let path_ref = trimmed.split('#').next().unwrap_or(trimmed);
    let path = resolve_repo_ref(repo_root, path_ref);
    let raw = match fs::read_to_string(path) {
        Ok(raw) => raw,
        Err(_) => return false,
    };
    let value: serde_yaml::Value = match serde_yaml::from_str(&raw) {
        Ok(value) => value,
        Err(_) => return false,
    };
    match value.get("state").and_then(|state| state.as_str()) {
        Some("active") => true,
        Some(_) => false,
        None => true,
    }
}

fn resolve_repo_ref(repo_root: &Path, reference: &str) -> PathBuf {
    let path = PathBuf::from(reference);
    if path.is_absolute() {
        path
    } else if repo_root.file_name().and_then(|value| value.to_str()) == Some(".octon") {
        if reference == ".octon" {
            repo_root.to_path_buf()
        } else if let Some(stripped) = reference.strip_prefix(".octon/") {
            repo_root.join(stripped)
        } else {
            repo_root.join(path)
        }
    } else {
        repo_root.join(path)
    }
}

#[cfg(test)]
mod tests {
    use super::resolve_repo_ref;
    use std::path::PathBuf;

    #[test]
    fn resolves_dot_octon_authority_refs_from_octon_root() {
        let octon_root = PathBuf::from("/tmp/octon-authority-ref/.octon");
        let resolved = resolve_repo_ref(&octon_root, ".octon/state/evidence/example.yml");
        assert_eq!(resolved, octon_root.join("state/evidence/example.yml"));
    }

    #[test]
    fn resolves_dot_octon_authority_refs_from_workspace_root() {
        let workspace_root = PathBuf::from("/tmp/octon-authority-ref");
        let resolved = resolve_repo_ref(&workspace_root, ".octon/state/evidence/example.yml");
        assert_eq!(
            resolved,
            workspace_root.join(".octon/state/evidence/example.yml")
        );
    }
}

fn approval_trace_refs(payload: &AuthorizedEffectPayload, grant: &GrantBundle) -> Vec<String> {
    let mut refs = Vec::new();
    if let Some(value) = payload.approval_request_ref.clone() {
        refs.push(value);
    }
    refs.extend(payload.approval_grant_refs.clone());
    refs.extend(grant.exception_lease_refs.clone());
    refs.extend(grant.revocation_refs.clone());
    dedupe_strings(&refs)
}

fn denial_reason_for_code(reason_code: &str) -> &'static str {
    match reason_code {
        "EFFECT_TOKEN_RECORD_MISSING" => "missing_token",
        "EFFECT_TOKEN_DIGEST_MISMATCH" | "EFFECT_TOKEN_CANONICAL_MISMATCH" => "forged_token",
        "EFFECT_TOKEN_KIND_MISMATCH" => "wrong_effect_class",
        "EFFECT_TOKEN_RUN_MISMATCH"
        | "EFFECT_TOKEN_REQUEST_MISMATCH"
        | "EFFECT_TOKEN_RUN_ROOT_MISMATCH" => "wrong_run",
        "EFFECT_TOKEN_GRANT_MISMATCH" | "EFFECT_TOKEN_AUTHORITY_REF_MISSING" => "forged_token",
        "EFFECT_TOKEN_ROUTE_MISMATCH" | "EFFECT_TOKEN_SUPPORT_ROUTE_BLOCKED" => "wrong_route",
        "EFFECT_TOKEN_SUPPORT_TUPLE_MISMATCH"
        | "EFFECT_TOKEN_SUPPORT_TUPLE_NOT_LIVE"
        | "EFFECT_TOKEN_SUPPORT_ENVELOPE_BLOCKED" => "wrong_support_tuple",
        "EFFECT_TOKEN_SUPPORT_TUPLE_UNSUPPORTED" => "unsupported_tuple",
        "EFFECT_TOKEN_SUPPORT_TUPLE_EXCLUDED" => "excluded_tuple",
        "EFFECT_TOKEN_CAPABILITY_PACK_MISMATCH" | "EFFECT_TOKEN_NOT_GRANTED" => {
            "wrong_capability_pack"
        }
        "EFFECT_TOKEN_SCOPE_MISMATCH" => "wrong_scope",
        "EFFECT_TOKEN_FRESHNESS_STALE" => "stale_token",
        "EFFECT_TOKEN_EXPIRED" => "expired_token",
        "EFFECT_TOKEN_REVOKED" => "revoked_token",
        "EFFECT_TOKEN_APPROVAL_MISSING" => "missing_approval",
        "EFFECT_TOKEN_EXCEPTION_MISSING" => "missing_exception",
        "EFFECT_TOKEN_ROLLBACK_NOT_READY" => "rollback_not_ready",
        "EFFECT_TOKEN_BUDGET_EXCEEDED" => "budget_exceeded",
        "EFFECT_TOKEN_EGRESS_DENIED" => "egress_denied",
        "EFFECT_TOKEN_ALREADY_CONSUMED" => "already_consumed",
        "EFFECT_TOKEN_DECISION_NOT_ALLOW" => "decision_not_allow",
        _ => "token_denied",
    }
}

fn scope_matches(
    token_scope_ref: &str,
    token_scope: &AuthorizedEffectScope,
    grant_scope: &ScopeConstraints,
    target_scope: &str,
) -> bool {
    if token_scope_ref == target_scope
        || target_scope.starts_with(token_scope_ref)
        || token_scope_ref.starts_with(target_scope)
    {
        return true;
    }
    if token_scope.write.iter().any(|entry| entry == target_scope)
        || token_scope.read.iter().any(|entry| entry == target_scope)
    {
        return true;
    }
    grant_scope.write.iter().any(|entry| entry == target_scope)
        || grant_scope.read.iter().any(|entry| entry == target_scope)
}

fn timestamp_is_expired(expires_at: &str, now: &str) -> CoreResult<bool> {
    let expires_at = OffsetDateTime::parse(expires_at, &Rfc3339).map_err(|error| {
        KernelError::new(
            ErrorCode::CapabilityDenied,
            format!("failed to parse effect token expiry {expires_at}: {error}"),
        )
    })?;
    let now = OffsetDateTime::parse(now, &Rfc3339).map_err(|error| {
        KernelError::new(
            ErrorCode::CapabilityDenied,
            format!("failed to parse effect token timestamp {now}: {error}"),
        )
    })?;
    Ok(expires_at < now)
}

fn ensure_run_lifecycle_allows_consumption<T: EffectKind>(
    bound: &BoundRunLifecycle,
    target_scope: &str,
) -> CoreResult<()> {
    ensure_material_effect_lifecycle_allowed(bound, T::KIND, target_scope)
}

fn load_active_revocation_refs_from_repo_root(
    repo_root: &Path,
    request_id: &str,
    grant_id: &str,
) -> CoreResult<Vec<String>> {
    let canonical_dir = resolve_repo_ref(repo_root, ".octon/state/control/execution/revocations");
    if !canonical_dir.is_dir() {
        return Ok(Vec::new());
    }
    let mut refs = Vec::new();
    for entry in fs::read_dir(&canonical_dir).map_err(|error| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to read canonical revocation dir {}: {error}",
                canonical_dir.display()
            ),
        )
    })? {
        let entry = entry.map_err(|error| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to read canonical revocation entry: {error}"),
            )
        })?;
        let path = entry.path();
        if path.extension().and_then(|value| value.to_str()) != Some("yml") {
            continue;
        }
        if path.file_name().and_then(|value| value.to_str()) == Some("grants.yml") {
            continue;
        }
        let revocation: RevocationArtifact = read_yaml_file(&path)?;
        if revocation.state == "active"
            && (revocation.request_id.as_deref() == Some(request_id)
                || revocation.grant_id.as_deref() == Some(grant_id))
        {
            refs.push(path_tail(repo_root, &path));
        }
    }
    Ok(refs)
}

fn timestamp_now() -> CoreResult<String> {
    now_rfc3339().map_err(|error| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to compute authorized effect timestamp: {error}"),
        )
    })
}

struct TokenRejectionContext<'a> {
    repo_root: &'a Path,
    bound: &'a BoundRunLifecycle,
    grant: &'a GrantBundle,
    consumer_api_ref: &'a str,
    target_scope: &'a str,
    recorded_at: &'a str,
}

fn reject_without_record<T: EffectKind>(
    effect: &AuthorizedEffect<T>,
    context: &TokenRejectionContext<'_>,
    reason_code: &str,
    message: &str,
) -> CoreResult<VerifiedEffect<T>> {
    let requested_event_ref = append_effect_token_event(
        context.repo_root,
        context.bound,
        context.grant,
        effect.token_id(),
        "effect-token-rejected",
        context.recorded_at,
        Some(effect.token_record_ref().to_string()),
        "authorized-action",
        "requires-fresh-authorization",
        "authorization",
        Some(json!({
            "consumer_api_ref": context.consumer_api_ref,
            "target_scope": context.target_scope,
            "reason_code": reason_code,
        })),
        Some(message.to_string()),
    )?;
    let receipt_path = token_receipt_path(
        context.bound,
        effect.token_id(),
        "rejection",
        context.consumer_api_ref,
        context.recorded_at,
    );
    let receipt_ref = path_tail(context.repo_root, &receipt_path);
    let receipt = AuthorizedEffectConsumptionReceipt {
        schema_version: TOKEN_CONSUMPTION_SCHEMA_VERSION.to_string(),
        token_id: effect.token_id().to_string(),
        token_digest: effect.token_digest().to_string(),
        source_token_digest: effect.token_digest().to_string(),
        token_type: effect.token_type().to_string(),
        effect_kind: effect.effect_kind().to_string(),
        material_effect_class: effect.effect_kind().to_string(),
        consumer_api_ref: context.consumer_api_ref.to_string(),
        target_scope: context.target_scope.to_string(),
        verifier_version: TOKEN_VERIFIER_VERSION.to_string(),
        verification_result: "rejected".to_string(),
        denial_reason: Some(denial_reason_for_code(reason_code).to_string()),
        rejection_reason_codes: vec![reason_code.to_string()],
        approval_trace_refs: approval_trace_refs(effect.payload(), context.grant),
        journal_event_refs: vec![requested_event_ref],
        evidence_refs: vec![effect.token_record_ref().to_string()],
        recorded_at: context.recorded_at.to_string(),
        run_id: effect.run_id().to_string(),
        request_id: effect.request_id().to_string(),
        grant_id: effect.grant_id().to_string(),
        token_record_ref: effect.token_record_ref().to_string(),
    };
    write_json(&receipt_path, &receipt).map_err(token_write_error)?;
    let denial_reason = denial_reason_for_code(reason_code);
    Err(KernelError::new(
        ErrorCode::CapabilityDenied,
        format!("{message} ({reason_code}/{denial_reason}); receipt={receipt_ref}"),
    ))
}

fn reject_with_record<T: EffectKind>(
    effect: &AuthorizedEffect<T>,
    record: &mut AuthorizedEffectTokenRecord,
    record_path: &Path,
    context: &TokenRejectionContext<'_>,
    reason_code: &str,
    message: &str,
    event_type: &str,
) -> CoreResult<VerifiedEffect<T>> {
    let event_ref = append_effect_token_event(
        context.repo_root,
        context.bound,
        context.grant,
        effect.token_id(),
        event_type,
        context.recorded_at,
        Some(effect.token_record_ref().to_string()),
        "authorized-action",
        "requires-fresh-authorization",
        "authorization",
        Some(json!({
            "consumer_api_ref": context.consumer_api_ref,
            "target_scope": context.target_scope,
            "reason_code": reason_code,
        })),
        Some(message.to_string()),
    )?;
    let receipt_path = token_receipt_path(
        context.bound,
        effect.token_id(),
        "rejection",
        context.consumer_api_ref,
        context.recorded_at,
    );
    let receipt_ref = path_tail(context.repo_root, &receipt_path);
    let receipt = AuthorizedEffectConsumptionReceipt {
        schema_version: TOKEN_CONSUMPTION_SCHEMA_VERSION.to_string(),
        token_id: effect.token_id().to_string(),
        token_digest: effect.token_digest().to_string(),
        source_token_digest: effect.token_digest().to_string(),
        token_type: effect.token_type().to_string(),
        effect_kind: effect.effect_kind().to_string(),
        material_effect_class: effect.effect_kind().to_string(),
        consumer_api_ref: context.consumer_api_ref.to_string(),
        target_scope: context.target_scope.to_string(),
        verifier_version: TOKEN_VERIFIER_VERSION.to_string(),
        verification_result: "rejected".to_string(),
        denial_reason: Some(denial_reason_for_code(reason_code).to_string()),
        rejection_reason_codes: vec![reason_code.to_string()],
        approval_trace_refs: approval_trace_refs(effect.payload(), context.grant),
        journal_event_refs: vec![event_ref.clone()],
        evidence_refs: vec![effect.token_record_ref().to_string()],
        recorded_at: context.recorded_at.to_string(),
        run_id: effect.run_id().to_string(),
        request_id: effect.request_id().to_string(),
        grant_id: effect.grant_id().to_string(),
        token_record_ref: effect.token_record_ref().to_string(),
    };
    write_json(&receipt_path, &receipt).map_err(token_write_error)?;
    record.status = match event_type {
        "effect-token-expired" => "expired".to_string(),
        "effect-token-revoked" => "revoked".to_string(),
        _ => "rejected".to_string(),
    };
    record.last_event_ref = Some(event_ref);
    record.last_consumption_receipt_ref = Some(receipt_ref.clone());
    record.last_consumed_at = Some(context.recorded_at.to_string());
    record.last_consumer_api_ref = Some(context.consumer_api_ref.to_string());
    record.last_target_scope = Some(context.target_scope.to_string());
    record.rejection_reason_codes = vec![reason_code.to_string()];
    persist_token_record(record_path, record)?;
    let denial_reason = denial_reason_for_code(reason_code);
    Err(KernelError::new(
        ErrorCode::CapabilityDenied,
        format!("{message} ({reason_code}/{denial_reason}); receipt={receipt_ref}"),
    ))
}
