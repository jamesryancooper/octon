mod api;
mod authority;
mod autonomy;
mod common;
mod execution;
mod policy;
mod records;
mod runtime_state;
mod support;

// Compatibility note for validator readers:
// `authorize_execution` now lives in `implementation/execution.rs`, where it
// binds canonical run lifecycle roots via `bind_run_lifecycle(...)` and carries
// route linkage through the mission `effective_scenario_resolution_ref`.

pub use api::*;
pub use authority::with_authority_env_metadata;
pub use execution::{
    artifact_root_from_relative, authorize_execution, default_autonomy_context, finalize_execution,
    write_execution_start,
};
pub use policy::{build_executor_command, now_rfc3339, resolve_executor_profile};

pub(crate) use common::*;
pub(crate) use records::*;
pub(crate) use runtime_state::*;
pub(crate) use support::*;

pub(crate) use authority::{
    budget_posture_from_preview, load_active_revocation_refs, load_existing_approval_grants,
    reversibility_payload, review_metadata_from_env, write_approval_request,
    write_authority_grant_bundle, write_decision_artifact,
};
pub(crate) use autonomy::resolve_autonomy_state;
pub(crate) use policy::{
    authorize_network_egress, budget_metadata_from_decision, capability_classification_for_mode,
    compose_policy_receipt, current_branch, dangerous_flags_for, dedupe_strings, env_bool,
    evidence_links, file_size, finalize_execution_budget, is_critical_action, material_side_effect,
    path_tail, policy_profile_for_request, preview_execution_budget, sha256_bytes, sha256_file,
    unique_temp_file, write_instruction_manifest, write_json, write_yaml, zero_sha256,
    PolicyArtifacts,
};

#[cfg(test)]
include!("implementation/tests.rs");
