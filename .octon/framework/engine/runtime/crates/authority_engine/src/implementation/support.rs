use super::*;
use anyhow::Context;
use octon_core::config::{ExecutorProfileConfig, RuntimeConfig};
use octon_core::errors::{ErrorCode, KernelError, Result as CoreResult};
use octon_core::execution_integrity::{
    evaluate_execution_budget, evaluate_network_egress, infer_provider_from_model,
    load_execution_budget_policy, load_execution_exception_leases, load_network_egress_policy,
    record_budget_consumption, write_execution_cost_evidence, BudgetCheckContext, BudgetDecision,
    NetworkEgressContext, NetworkEgressDecision,
};
use octon_core::policy::PolicyEngine;
use octon_core::registry::ServiceDescriptor;
use serde::{Deserialize, Serialize};
use serde_json::json;
use sha2::{Digest, Sha256};
use std::collections::{BTreeMap, BTreeSet};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::sync::{Mutex, OnceLock};

pub(crate) fn load_ownership_registry(cfg: &RuntimeConfig) -> CoreResult<OwnershipRegistryRecord> {
    let path = cfg
        .octon_dir
        .join("instance")
        .join("governance")
        .join("ownership")
        .join("registry.yml");
    read_yaml_or_default(&path)
}

pub(crate) fn ownership_glob_matches(pattern: &str, candidate: &str) -> bool {
    if pattern == "**" || pattern == "*" {
        return true;
    }
    if let Some(prefix) = pattern.strip_suffix("/**") {
        return candidate.starts_with(prefix);
    }
    candidate == pattern
}

pub(crate) fn resolve_ownership_posture(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    run_contract: &RunContractRecord,
) -> CoreResult<OwnershipPosture> {
    let registry = load_ownership_registry(cfg)?;
    let mut owner_refs = Vec::new();
    let mut matched_asset_ref = None;

    for asset in &registry.assets {
        if asset.path_globs.iter().any(|glob| {
            request
                .scope_constraints
                .write
                .iter()
                .any(|path| ownership_glob_matches(glob, path))
        }) {
            matched_asset_ref = asset.asset_id.clone();
            owner_refs.extend(
                asset
                    .owners
                    .iter()
                    .filter(|value| !value.trim().is_empty())
                    .map(|value| format!("operator://{value}")),
            );
            break;
        }
    }

    if owner_refs.is_empty() && request.caller_path == "service" {
        for service in &registry.services {
            if service.service_id.as_deref() == Some(request.target_id.as_str()) {
                owner_refs.extend(
                    service
                        .owners
                        .iter()
                        .filter(|value| !value.trim().is_empty())
                        .map(|value| format!("operator://{value}")),
                );
            }
        }
    }

    if owner_refs.is_empty() {
        if let Some(default_owner) = registry.defaults.operator_id {
            owner_refs.push(format!("operator://{default_owner}"));
        } else if let Some(operator) = registry.operators.first() {
            owner_refs.push(format!("operator://{}", operator.operator_id));
        }
    }

    let status = if owner_refs.is_empty() {
        "unresolved"
    } else {
        "resolved"
    };
    let source = if let Some(asset_ref) = &matched_asset_ref {
        let asset_support_tier = registry
            .assets
            .iter()
            .find(|asset| asset.asset_id.as_ref() == Some(asset_ref))
            .and_then(|asset| asset.support_tier.as_deref());
        if asset_support_tier.is_some() {
            "ownership_registry.asset_with_support_tier"
        } else {
            "ownership_registry.asset"
        }
    } else if !request.scope_constraints.write.is_empty() {
        "ownership_registry.default"
    } else if !run_contract.support_tier.trim().is_empty() {
        "ownership_registry.support_tier_default"
    } else {
        "ownership_registry.fallback"
    };

    Ok(OwnershipPosture {
        status: status.to_string(),
        source: source.to_string(),
        owner_refs,
        matched_asset_ref,
    })
}

pub(crate) fn load_support_targets(cfg: &RuntimeConfig) -> CoreResult<SupportTargetsRecord> {
    let path = cfg
        .octon_dir
        .join("instance")
        .join("governance")
        .join("support-targets.yml");
    read_yaml_file(&path)
}

pub(crate) fn load_support_target_admissions(
    cfg: &RuntimeConfig,
) -> CoreResult<Vec<SupportTargetAdmissionRecord>> {
    let root = cfg
        .octon_dir
        .join("instance")
        .join("governance")
        .join("support-target-admissions");
    let mut admissions = Vec::new();
    if !root.is_dir() {
        return Ok(admissions);
    }
    for entry in fs::read_dir(&root).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!(
                "failed to read support-target admissions {}: {e}",
                root.display()
            ),
        )
    })? {
        let entry = entry.map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to read support-target admission entry: {e}"),
            )
        })?;
        let path = entry.path();
        if path.extension().and_then(|value| value.to_str()) != Some("yml") {
            continue;
        }
        admissions.push(read_yaml_file(&path)?);
    }
    Ok(admissions)
}

pub(crate) fn load_runtime_capability_pack_registry(
    cfg: &RuntimeConfig,
) -> CoreResult<RuntimeCapabilityPackRegistryRecord> {
    let path = cfg
        .octon_dir
        .join("instance")
        .join("capabilities")
        .join("runtime")
        .join("packs")
        .join("registry.yml");
    read_yaml_file(&path)
}

pub(crate) fn resolve_contract_path(repo_root: &Path, raw: &str) -> PathBuf {
    repo_root.join(raw)
}

pub(crate) fn string_set_contains_all(container: &[String], expected: &[String]) -> bool {
    let values: BTreeSet<&str> = container.iter().map(|value| value.as_str()).collect();
    expected
        .iter()
        .all(|candidate| values.contains(candidate.as_str()))
}

pub(crate) fn validate_support_tier_declarations(
    declarations: &AdapterSupportTierDeclarationsRecord,
    adapter: &AdapterSupportDeclaration,
) -> bool {
    string_set_contains_all(&declarations.model_tiers, &adapter.allowed_model_tiers)
        && string_set_contains_all(
            &declarations.workload_tiers,
            &adapter.allowed_workload_tiers,
        )
        && string_set_contains_all(
            &declarations.language_resource_tiers,
            &adapter.allowed_language_resource_tiers,
        )
        && string_set_contains_all(&declarations.locale_tiers, &adapter.allowed_locale_tiers)
}

pub(crate) fn validate_host_adapter_manifest(
    cfg: &RuntimeConfig,
    adapter: &AdapterSupportDeclaration,
) -> Option<HostAdapterManifestRecord> {
    if adapter.contract_ref.trim().is_empty() {
        return None;
    }
    let path = resolve_contract_path(&cfg.repo_root, &adapter.contract_ref);
    let manifest = read_yaml_file::<HostAdapterManifestRecord>(&path).ok()?;
    if manifest.schema_version != "octon-host-adapter-v1"
        || manifest.adapter_id != adapter.adapter_id
        || manifest.display_name.trim().is_empty()
        || !matches!(
            manifest.host_family.as_str(),
            "github" | "ci" | "local-cli" | "studio"
        )
        || !manifest.replaceable
        || !matches!(
            manifest.authority_mode.as_str(),
            "projection_only" | "non_authoritative"
        )
        || manifest.runtime_surface.interface_ref.trim().is_empty()
        || manifest.runtime_surface.integration_class.trim().is_empty()
        || manifest.support_target_ref != ".octon/instance/governance/support-targets.yml"
        || (manifest.host_family != "local-cli" && manifest.projection_sources.is_empty())
        || !validate_support_tier_declarations(&manifest.support_tier_declarations, adapter)
        || !string_set_contains_all(&manifest.conformance_criteria_refs, &adapter.criteria_refs)
        || manifest.known_limitations.is_empty()
        || manifest.non_authoritative_boundaries.is_empty()
    {
        return None;
    }
    Some(manifest)
}

pub(crate) fn validate_model_adapter_manifest(
    cfg: &RuntimeConfig,
    adapter: &AdapterSupportDeclaration,
) -> Option<ModelAdapterManifestRecord> {
    if adapter.contract_ref.trim().is_empty() {
        return None;
    }
    let path = resolve_contract_path(&cfg.repo_root, &adapter.contract_ref);
    let manifest = read_yaml_file::<ModelAdapterManifestRecord>(&path).ok()?;
    if manifest.schema_version != "octon-model-adapter-v1"
        || manifest.adapter_id != adapter.adapter_id
        || manifest.display_name.trim().is_empty()
        || !manifest.replaceable
        || manifest.authority_mode != "non_authoritative"
        || manifest.runtime_surface.interface_ref.trim().is_empty()
        || manifest.runtime_surface.integration_class.trim().is_empty()
        || manifest.support_target_ref != ".octon/instance/governance/support-targets.yml"
        || !validate_support_tier_declarations(&manifest.support_tier_declarations, adapter)
        || !string_set_contains_all(&manifest.conformance_criteria_refs, &adapter.criteria_refs)
        || manifest.conformance_suite_refs.is_empty()
        || manifest
            .contamination_reset_policy
            .contamination_signal_ref
            .trim()
            .is_empty()
        || manifest
            .contamination_reset_policy
            .evidence_log_ref
            .trim()
            .is_empty()
        || !manifest
            .contamination_reset_policy
            .clean_checkpoint_required
        || !manifest.contamination_reset_policy.hard_reset_on_signature
        || manifest.known_limitations.is_empty()
        || manifest.non_authoritative_boundaries.is_empty()
    {
        return None;
    }
    Some(manifest)
}

pub(crate) fn infer_requested_capability_packs(request: &ExecutionRequest) -> Vec<String> {
    let mut packs = Vec::new();

    if !request.scope_constraints.read.is_empty()
        || !request.scope_constraints.write.is_empty()
        || request.caller_path == "workflow-stage"
        || request.caller_path == "service"
    {
        packs.push("repo".to_string());
    }
    if request.side_effect_flags.shell {
        packs.push("shell".to_string());
    }
    if request.side_effect_flags.write_repo
        || request.side_effect_flags.branch_mutation
        || request.side_effect_flags.publication
        || request.action_type.contains("git")
    {
        packs.push("git".to_string());
    }
    if request.side_effect_flags.write_evidence || request.side_effect_flags.state_mutation {
        packs.push("telemetry".to_string());
    }
    if request.side_effect_flags.network
        || request
            .requested_capabilities
            .iter()
            .any(|value| value == "net.http")
        || request.metadata.contains_key("network_egress_url")
    {
        packs.push("api".to_string());
    }
    if request
        .requested_capabilities
        .iter()
        .any(|value| value.starts_with("browser."))
        || request
            .metadata
            .keys()
            .any(|value| value.starts_with("browser_"))
    {
        packs.push("browser".to_string());
    }
    if let Some(raw) = request.metadata.get("support_capability_packs") {
        for item in raw.split(',') {
            let trimmed = item.trim();
            if !trimmed.is_empty() {
                packs.push(trimmed.to_string());
            }
        }
    }

    dedupe_strings(&packs)
}

pub(crate) fn resolve_capability_pack_support(
    cfg: &RuntimeConfig,
    requested_packs: &[String],
    allowed_packs: &[String],
) -> ResolvedCapabilityPackSupport {
    if requested_packs.is_empty() {
        return ResolvedCapabilityPackSupport {
            support_status: "supported".to_string(),
            route: "allow".to_string(),
            required_evidence: Vec::new(),
        };
    }

    let registry = match load_runtime_capability_pack_registry(cfg) {
        Ok(registry) => registry,
        Err(_) => {
            return ResolvedCapabilityPackSupport {
                support_status: "unsupported".to_string(),
                route: "deny".to_string(),
                required_evidence: Vec::new(),
            }
        }
    };

    let allowed: BTreeSet<&str> = allowed_packs.iter().map(|value| value.as_str()).collect();
    let mut required_evidence = Vec::new();
    let mut route = "allow".to_string();

    for requested in requested_packs {
        let Some(pack) = registry
            .packs
            .iter()
            .find(|candidate| candidate.pack_id == *requested)
        else {
            return ResolvedCapabilityPackSupport {
                support_status: "unsupported".to_string(),
                route: "deny".to_string(),
                required_evidence,
            };
        };

        let manifest_path = resolve_contract_path(&cfg.repo_root, &pack.contract_ref);
        let manifest = match read_yaml_file::<CapabilityPackManifestRecord>(&manifest_path) {
            Ok(manifest) => manifest,
            Err(_) => {
                return ResolvedCapabilityPackSupport {
                    support_status: "unsupported".to_string(),
                    route: "deny".to_string(),
                    required_evidence,
                }
            }
        };
        if manifest.schema_version != "octon-capability-pack-v1"
            || manifest.pack_id != pack.pack_id
            || manifest.surface != pack.pack_id
            || manifest.display_name.trim().is_empty()
            || manifest.description.trim().is_empty()
            || manifest.runtime_surface_refs.is_empty()
            || manifest.support_target_ref != ".octon/instance/governance/support-targets.yml"
            || manifest.known_limitations.is_empty()
            || pack.contract_ref.trim().is_empty()
            || !matches!(pack.admission_status.as_str(), "admitted" | "unadmitted")
            || pack.default_route.trim().is_empty()
        {
            return ResolvedCapabilityPackSupport {
                support_status: "unsupported".to_string(),
                route: "deny".to_string(),
                required_evidence,
            };
        }

        if pack.admission_status != "admitted" || !allowed.contains(requested.as_str()) {
            return ResolvedCapabilityPackSupport {
                support_status: "unsupported".to_string(),
                route: "deny".to_string(),
                required_evidence: merge_required_evidence(
                    manifest
                        .required_evidence
                        .iter()
                        .chain(pack.required_evidence.iter()),
                ),
            };
        }

        required_evidence.extend(manifest.required_evidence.clone());
        required_evidence.extend(pack.required_evidence.clone());
        route = combine_route(&[route.as_str(), pack.default_route.as_str()]);
    }

    ResolvedCapabilityPackSupport {
        support_status: "supported".to_string(),
        route,
        required_evidence: dedupe_strings(&required_evidence),
    }
}

pub(crate) fn route_rank(route: &str) -> u8 {
    match route {
        "deny" => 3,
        "escalate" => 2,
        "stage_only" => 1,
        "allow" => 0,
        _ => 3,
    }
}

pub(crate) fn combine_route(routes: &[&str]) -> String {
    routes
        .iter()
        .copied()
        .max_by_key(|route| route_rank(route))
        .unwrap_or("deny")
        .to_string()
}

pub(crate) fn support_status_rank(status: &str) -> u8 {
    match status {
        "unsupported" => 3,
        "experimental" => 2,
        "reduced" => 1,
        "supported" => 0,
        _ => 3,
    }
}

pub(crate) fn combine_support_status(statuses: &[&str]) -> String {
    statuses
        .iter()
        .copied()
        .max_by_key(|status| support_status_rank(status))
        .unwrap_or("unsupported")
        .to_string()
}

pub(crate) fn merge_required_evidence<'a, I>(inputs: I) -> Vec<String>
where
    I: IntoIterator<Item = &'a String>,
{
    let mut unique = BTreeSet::new();
    let mut merged = Vec::new();
    for value in inputs {
        if unique.insert(value.clone()) {
            merged.push(value.clone());
        }
    }
    merged
}

pub(crate) fn resolve_adapter_support(
    cfg: &RuntimeConfig,
    declaration: &SupportTargetsRecord,
    adapter_kind: &str,
    adapter_id: &str,
    model_tier: &str,
    workload_tier: &str,
    language_resource_tier: &str,
    locale_tier: &str,
) -> ResolvedAdapterSupport {
    let declarations = if adapter_kind == "host" {
        &declaration.host_adapters
    } else {
        &declaration.model_adapters
    };

    let Some(adapter) = declarations
        .iter()
        .find(|candidate| candidate.adapter_id == adapter_id)
    else {
        return ResolvedAdapterSupport {
            adapter_id: adapter_id.to_string(),
            support_status: "unsupported".to_string(),
            route: "deny".to_string(),
            ..ResolvedAdapterSupport::default()
        };
    };

    if adapter.contract_ref.trim().is_empty()
        || adapter.authority_mode.trim().is_empty()
        || !adapter.replaceable
        || adapter.criteria_refs.is_empty()
        || adapter.allowed_model_tiers.is_empty()
        || adapter.allowed_workload_tiers.is_empty()
        || adapter.allowed_language_resource_tiers.is_empty()
        || adapter.allowed_locale_tiers.is_empty()
    {
        return ResolvedAdapterSupport {
            adapter_id: adapter.adapter_id.clone(),
            support_status: "unsupported".to_string(),
            route: "deny".to_string(),
            ..ResolvedAdapterSupport::default()
        };
    }

    let authority_mode_valid = if adapter_kind == "host" {
        matches!(
            adapter.authority_mode.as_str(),
            "projection_only" | "non_authoritative"
        )
    } else {
        adapter.authority_mode == "non_authoritative"
    };
    if !authority_mode_valid {
        return ResolvedAdapterSupport {
            adapter_id: adapter.adapter_id.clone(),
            support_status: "unsupported".to_string(),
            route: "deny".to_string(),
            ..ResolvedAdapterSupport::default()
        };
    }

    let manifest_valid = if adapter_kind == "host" {
        validate_host_adapter_manifest(cfg, adapter).is_some()
    } else {
        validate_model_adapter_manifest(cfg, adapter).is_some()
    };
    if !manifest_valid {
        return ResolvedAdapterSupport {
            adapter_id: adapter.adapter_id.clone(),
            support_status: "unsupported".to_string(),
            route: "deny".to_string(),
            ..ResolvedAdapterSupport::default()
        };
    }

    let criteria: Vec<_> = adapter
        .criteria_refs
        .iter()
        .filter_map(|criterion_id| {
            declaration
                .adapter_conformance_criteria
                .iter()
                .find(|criterion| {
                    criterion.criterion_id == *criterion_id
                        && criterion.adapter_kind == adapter_kind
                })
        })
        .collect();

    if criteria.len() != adapter.criteria_refs.len() {
        return ResolvedAdapterSupport {
            adapter_id: adapter.adapter_id.clone(),
            support_status: "unsupported".to_string(),
            route: "deny".to_string(),
            ..ResolvedAdapterSupport::default()
        };
    }

    let tier_match = adapter
        .allowed_model_tiers
        .iter()
        .any(|value| value == model_tier)
        && adapter
            .allowed_workload_tiers
            .iter()
            .any(|value| value == workload_tier)
        && adapter
            .allowed_language_resource_tiers
            .iter()
            .any(|value| value == language_resource_tier)
        && adapter
            .allowed_locale_tiers
            .iter()
            .any(|value| value == locale_tier);

    let required_evidence = merge_required_evidence(
        adapter.required_evidence.iter().chain(
            criteria
                .iter()
                .flat_map(|criterion| criterion.required_evidence.iter()),
        ),
    );

    if !tier_match {
        return ResolvedAdapterSupport {
            adapter_id: adapter.adapter_id.clone(),
            support_status: "unsupported".to_string(),
            route: "deny".to_string(),
            criteria_refs: adapter.criteria_refs.clone(),
            required_evidence,
        };
    }

    ResolvedAdapterSupport {
        adapter_id: adapter.adapter_id.clone(),
        support_status: if adapter.support_status.trim().is_empty() {
            "unsupported".to_string()
        } else {
            adapter.support_status.clone()
        },
        route: if adapter.default_route.trim().is_empty() {
            declaration.default_route.clone()
        } else {
            adapter.default_route.clone()
        },
        criteria_refs: adapter.criteria_refs.clone(),
        required_evidence,
    }
}

pub(crate) fn resolve_support_tier_posture(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    run_contract: &RunContractRecord,
    autonomy_state: Option<&ResolvedAutonomyState>,
) -> CoreResult<SupportTierPosture> {
    let declaration = load_support_targets(cfg)?;
    let admissions = load_support_target_admissions(cfg)?;
    let requested_tuple = if run_contract.support_target.workload_tier.trim().is_empty() {
        requested_support_target_tuple(request)?
    } else {
        run_contract.support_target.clone()
    };
    let requested_tier = requested_tuple.workload_tier.trim();
    let model_tier = requested_tuple.model_tier.clone();
    let host_adapter_id = requested_tuple.host_adapter.clone();
    let model_adapter_id = requested_tuple.model_adapter.clone();
    let language_resource_tier = requested_tuple.language_resource_tier.clone();
    let locale_tier = requested_tuple.locale_tier.clone();
    let requested_capability_packs = if run_contract.requested_capability_packs.is_empty() {
        infer_requested_capability_packs(request)
    } else {
        dedupe_strings(&run_contract.requested_capability_packs)
    };
    let Some(workload) = declaration
        .tiers
        .workload
        .iter()
        .find(|tier| tier.id == requested_tier || tier.label == requested_tier)
        .cloned()
    else {
        return Ok(SupportTierPosture {
            support_tier: requested_tier.to_string(),
            model_tier_id: Some(model_tier),
            route: declaration.default_route,
            support_status: "unsupported".to_string(),
            host_adapter_id: Some(host_adapter_id),
            model_adapter_id: Some(model_adapter_id),
            requested_capability_packs,
            declaration_ref: Some(".octon/instance/governance/support-targets.yml".to_string()),
            ..SupportTierPosture::default()
        });
    };

    let model_known = declaration
        .tiers
        .model
        .iter()
        .any(|tier| tier.id == model_tier || tier.label == model_tier);
    let language_known = declaration
        .tiers
        .language_resource
        .iter()
        .any(|tier| tier.id == language_resource_tier || tier.label == language_resource_tier);
    let locale_known = declaration
        .tiers
        .locale
        .iter()
        .any(|tier| tier.id == locale_tier || tier.label == locale_tier);

    if !model_known || !language_known || !locale_known {
        return Ok(SupportTierPosture {
            support_tier: run_contract.support_tier.clone(),
            model_tier_id: Some(model_tier),
            workload_tier_id: Some(workload.id.clone()),
            language_resource_tier_id: Some(language_resource_tier),
            locale_tier_id: Some(locale_tier),
            workload_tier_label: Some(workload.label),
            support_status: "unsupported".to_string(),
            route: declaration.default_route,
            host_adapter_id: Some(host_adapter_id),
            model_adapter_id: Some(model_adapter_id),
            requested_capability_packs,
            declaration_ref: Some(".octon/instance/governance/support-targets.yml".to_string()),
            ..SupportTierPosture::default()
        });
    }

    let explicit_admission_ref = !run_contract.support_target_admission_ref.trim().is_empty();
    let admission = if explicit_admission_ref {
        let path =
            resolve_contract_path(&cfg.repo_root, &run_contract.support_target_admission_ref);
        if path.is_file() {
            Some(read_yaml_file(&path)?)
        } else {
            None
        }
    } else {
        admissions
            .iter()
            .find(|entry| {
                entry.tuple.model_tier == model_tier
                    && entry.tuple.workload_tier == workload.id
                    && entry.tuple.language_resource_tier == language_resource_tier
                    && entry.tuple.locale_tier == locale_tier
                    && entry.tuple.host_adapter == host_adapter_id
                    && entry.tuple.model_adapter == model_adapter_id
            })
            .cloned()
    };
    if explicit_admission_ref
        && admission
            .as_ref()
            .map(|entry| {
                entry.tuple.model_tier != model_tier
                    || entry.tuple.workload_tier != workload.id
                    || entry.tuple.language_resource_tier != language_resource_tier
                    || entry.tuple.locale_tier != locale_tier
                    || entry.tuple.host_adapter != host_adapter_id
                    || entry.tuple.model_adapter != model_adapter_id
            })
            .unwrap_or(true)
    {
        return Ok(SupportTierPosture {
            support_tier: requested_tier.to_string(),
            model_tier_id: Some(model_tier),
            workload_tier_id: Some(workload.id.clone()),
            language_resource_tier_id: Some(language_resource_tier),
            locale_tier_id: Some(locale_tier),
            workload_tier_label: Some(workload.label),
            support_status: "unsupported".to_string(),
            route: declaration.default_route,
            host_adapter_id: Some(host_adapter_id),
            model_adapter_id: Some(model_adapter_id),
            requested_capability_packs,
            declaration_ref: Some(run_contract.support_target_admission_ref.clone()),
            ..SupportTierPosture::default()
        });
    }
    let matrix_entry = declaration.compatibility_matrix.iter().find(|entry| {
        entry.model_tier == model_tier
            && entry.workload_tier == workload.id
            && entry.language_resource_tier == language_resource_tier
            && entry.locale_tier == locale_tier
    });
    let base_support_status = admission
        .as_ref()
        .map(|entry| entry.status.clone())
        .or_else(|| matrix_entry.map(|entry| entry.support_status.clone()))
        .unwrap_or_else(|| "unsupported".to_string());
    let base_route = admission
        .as_ref()
        .map(|entry| entry.route.clone())
        .or_else(|| matrix_entry.map(|entry| entry.default_route.clone()))
        .unwrap_or_else(|| {
            if workload.default_route.trim().is_empty() {
                declaration.default_route.clone()
            } else {
                workload.default_route.clone()
            }
        });
    let requires_mission = admission
        .as_ref()
        .map(|entry| entry.requires_mission)
        .or_else(|| matrix_entry.and_then(|entry| entry.requires_mission))
        .unwrap_or(false);
    let base_required_evidence = admission
        .as_ref()
        .map(|entry| entry.required_authority_artifacts.clone())
        .or_else(|| matrix_entry.map(|entry| entry.required_evidence.clone()))
        .unwrap_or_default();
    let allowed_capability_packs = admission
        .as_ref()
        .map(|entry| entry.allowed_capability_packs.clone())
        .or_else(|| matrix_entry.map(|entry| entry.allowed_capability_packs.clone()))
        .unwrap_or_default();
    let host_adapter = resolve_adapter_support(
        cfg,
        &declaration,
        "host",
        &host_adapter_id,
        &model_tier,
        &workload.id,
        &language_resource_tier,
        &locale_tier,
    );
    let model_adapter = resolve_adapter_support(
        cfg,
        &declaration,
        "model",
        &model_adapter_id,
        &model_tier,
        &workload.id,
        &language_resource_tier,
        &locale_tier,
    );
    let capability_pack_support = resolve_capability_pack_support(
        cfg,
        &requested_capability_packs,
        &allowed_capability_packs,
    );
    let support_status = combine_support_status(&[
        base_support_status.as_str(),
        host_adapter.support_status.as_str(),
        model_adapter.support_status.as_str(),
        capability_pack_support.support_status.as_str(),
    ]);
    let route = combine_route(&[
        base_route.as_str(),
        host_adapter.route.as_str(),
        model_adapter.route.as_str(),
        capability_pack_support.route.as_str(),
    ]);
    let adapter_conformance_criteria = merge_required_evidence(
        host_adapter
            .criteria_refs
            .iter()
            .chain(model_adapter.criteria_refs.iter()),
    );
    let required_evidence = merge_required_evidence(
        base_required_evidence
            .iter()
            .chain(host_adapter.required_evidence.iter())
            .chain(model_adapter.required_evidence.iter()),
    );
    let required_evidence = merge_required_evidence(
        required_evidence
            .iter()
            .chain(capability_pack_support.required_evidence.iter()),
    );

    if requires_mission && autonomy_state.is_none() {
        return Ok(SupportTierPosture {
            support_tier: run_contract.support_tier.clone(),
            model_tier_id: Some(model_tier.clone()),
            workload_tier_id: Some(workload.id),
            language_resource_tier_id: Some(language_resource_tier.clone()),
            locale_tier_id: Some(locale_tier.clone()),
            workload_tier_label: Some(workload.label),
            host_adapter_id: Some(host_adapter.adapter_id),
            host_adapter_status: Some(host_adapter.support_status),
            model_adapter_id: Some(model_adapter.adapter_id),
            model_adapter_status: Some(model_adapter.support_status),
            adapter_conformance_criteria,
            support_status,
            route: "deny".to_string(),
            requires_mission,
            required_evidence,
            allowed_capability_packs,
            requested_capability_packs,
            declaration_ref: Some(".octon/instance/governance/support-targets.yml".to_string()),
        });
    }

    Ok(SupportTierPosture {
        support_tier: run_contract.support_tier.clone(),
        model_tier_id: Some(model_tier),
        workload_tier_id: Some(workload.id),
        language_resource_tier_id: Some(language_resource_tier),
        locale_tier_id: Some(locale_tier),
        workload_tier_label: Some(workload.label),
        host_adapter_id: Some(host_adapter.adapter_id),
        host_adapter_status: Some(host_adapter.support_status),
        model_adapter_id: Some(model_adapter.adapter_id),
        model_adapter_status: Some(model_adapter.support_status),
        adapter_conformance_criteria,
        support_status,
        route,
        requires_mission,
        required_evidence,
        allowed_capability_packs,
        requested_capability_packs,
        declaration_ref: Some(".octon/instance/governance/support-targets.yml".to_string()),
    })
}
