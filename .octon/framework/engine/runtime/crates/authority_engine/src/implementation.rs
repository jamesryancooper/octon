mod api;
mod authority;
mod autonomy;
mod common;
mod effects;
mod execution;
#[path = "phases/mod.rs"]
mod phases;
mod policy;
mod records;
mod runtime_state;
mod support;

pub use octon_authorized_effects::{
    AuthorizedEffect, AuthorizedEffectPayload, AuthorizedEffectScope, CapabilityPackActivation,
    EffectKind, EvidenceMutation, ExecutorLaunch, ExtensionActivation,
    GeneratedEffectivePublication, ProtectedCiCheck, ProviderRepositoryMutation, RepoMutation,
    ServiceInvocation, StateControlMutation, VerifiedEffect,
};

// Compatibility note for validator readers:
// `authorize_execution` now lives in `implementation/execution.rs`, where it
// binds canonical run lifecycle roots via `bind_run_lifecycle(...)` and carries
// route linkage through the mission `effective_scenario_resolution_ref`.

pub use api::*;
pub use authority::with_authority_env_metadata;
pub use effects::{
    authorized_effect_reference, issue_capability_pack_activation_effect,
    issue_evidence_mutation_effect, issue_execution_artifact_effects, issue_executor_launch_effect,
    issue_extension_activation_effect, issue_generated_effective_publication_effect,
    issue_protected_ci_check_effect, issue_provider_repository_mutation_effect,
    issue_repo_mutation_effect, issue_repo_mutation_effect_with_mode,
    issue_service_invocation_effect, verify_authorized_effect,
    verify_authorized_effect_verification_bundle, write_authorized_effect_verification_bundle,
    AuthorizedEffectVerificationBundle,
};
pub use execution::{
    artifact_root_from_relative, authorize_execution, default_autonomy_context, finalize_execution,
    write_execution_start,
};
pub use policy::{build_executor_command, now_rfc3339, resolve_executor_profile};
pub use runtime_state::{
    validate_run_lifecycle_operation, RunLifecycleOperation, RunLifecycleReconstruction,
};

pub(crate) use common::*;
pub(crate) use records::*;
pub(crate) use runtime_state::*;
pub(crate) use support::*;

pub(crate) use authority::{
    approval_authority_source_from_request, approval_rationale_class_from_request,
    authority_provenance_refs_from_request, budget_posture_from_preview,
    is_valid_typed_exception_boundary, load_active_revocation_refs, load_existing_approval_grants,
    non_authority_source_reason_code, reversibility_payload, review_metadata_from_env,
    typed_boundary_reason_code, typed_exception_boundary_from_request, write_approval_request,
    write_authority_grant_bundle, write_decision_artifact,
    GRANT_CONSUMPTION_MODE_DELEGATED_EXECUTION,
};
pub(crate) use autonomy::resolve_autonomy_state;
pub(crate) use policy::{
    authorize_network_egress, budget_metadata_from_decision, compose_policy_receipt,
    current_branch, dedupe_strings, env_bool, evidence_links, finalize_execution_budget,
    is_critical_action, path_tail, preview_execution_budget, sha256_bytes, sha256_file, write_json,
    write_yaml,
};

#[cfg(test)]
include!("implementation/tests.rs");
