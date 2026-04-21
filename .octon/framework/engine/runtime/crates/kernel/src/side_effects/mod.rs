use octon_authority_engine::SideEffectFlags;
use std::collections::BTreeMap;

pub const MATERIAL_SIDE_EFFECT_INVENTORY_SCHEMA_REF: &str =
    ".octon/framework/engine/runtime/spec/material-side-effect-inventory-v1.schema.json";
pub const AUTHORIZATION_BOUNDARY_COVERAGE_SCHEMA_REF: &str =
    ".octon/framework/engine/runtime/spec/authorization-boundary-coverage-v1.schema.json";
pub const AUTHORIZATION_BOUNDARY_REF: &str =
    ".octon/framework/engine/runtime/spec/execution-authorization-v1.md";

#[derive(Debug, Clone, Copy, Eq, PartialEq)]
pub enum MaterialSideEffectClass {
    RepoMutation,
    EvidenceMutation,
    ControlMutation,
    GeneratedEffectivePublication,
    ExecutorLaunch,
    ServiceInvocation,
    ReadOnlyProjection,
}

impl MaterialSideEffectClass {
    pub fn as_str(self) -> &'static str {
        match self {
            Self::RepoMutation => "repo-mutation",
            Self::EvidenceMutation => "evidence-mutation",
            Self::ControlMutation => "control-mutation",
            Self::GeneratedEffectivePublication => "generated-effective-publication",
            Self::ExecutorLaunch => "executor-launch",
            Self::ServiceInvocation => "service-invocation",
            Self::ReadOnlyProjection => "read-only-projection",
        }
    }
}

#[derive(Debug, Clone)]
pub struct MaterialSideEffectInventoryEntry {
    pub id: &'static str,
    pub class: MaterialSideEffectClass,
    pub affected_roots: &'static [&'static str],
    pub required_boundary: &'static str,
    pub material: bool,
}

const INVENTORY: &[MaterialSideEffectInventoryEntry] = &[
    MaterialSideEffectInventoryEntry {
        id: "kernel.service.invoke",
        class: MaterialSideEffectClass::ServiceInvocation,
        affected_roots: &[".octon/framework/capabilities/runtime/services/**"],
        required_boundary: AUTHORIZATION_BOUNDARY_REF,
        material: true,
    },
    MaterialSideEffectInventoryEntry {
        id: "kernel.service.scaffold",
        class: MaterialSideEffectClass::RepoMutation,
        affected_roots: &[".octon/framework/capabilities/runtime/services/**"],
        required_boundary: AUTHORIZATION_BOUNDARY_REF,
        material: true,
    },
    MaterialSideEffectInventoryEntry {
        id: "kernel.service.build",
        class: MaterialSideEffectClass::RepoMutation,
        affected_roots: &[".octon/framework/capabilities/runtime/services/**"],
        required_boundary: AUTHORIZATION_BOUNDARY_REF,
        material: true,
    },
    MaterialSideEffectInventoryEntry {
        id: "kernel.studio.launch",
        class: MaterialSideEffectClass::ExecutorLaunch,
        affected_roots: &[".octon/generated/.tmp/engine/build/runtime-crates-target"],
        required_boundary: AUTHORIZATION_BOUNDARY_REF,
        material: true,
    },
    MaterialSideEffectInventoryEntry {
        id: "kernel.orchestration.report",
        class: MaterialSideEffectClass::EvidenceMutation,
        affected_roots: &[".octon/state/evidence/**"],
        required_boundary: AUTHORIZATION_BOUNDARY_REF,
        material: true,
    },
    MaterialSideEffectInventoryEntry {
        id: "kernel.orchestration.lookup",
        class: MaterialSideEffectClass::EvidenceMutation,
        affected_roots: &[".octon/state/evidence/**"],
        required_boundary: AUTHORIZATION_BOUNDARY_REF,
        material: true,
    },
    MaterialSideEffectInventoryEntry {
        id: "kernel.run.lifecycle",
        class: MaterialSideEffectClass::ControlMutation,
        affected_roots: &[".octon/state/control/**"],
        required_boundary: AUTHORIZATION_BOUNDARY_REF,
        material: true,
    },
    MaterialSideEffectInventoryEntry {
        id: "kernel.read.only",
        class: MaterialSideEffectClass::ReadOnlyProjection,
        affected_roots: &[".octon/state/**"],
        required_boundary: AUTHORIZATION_BOUNDARY_REF,
        material: false,
    },
];

pub fn inventory() -> &'static [MaterialSideEffectInventoryEntry] {
    INVENTORY
}

pub fn classify_support_posture(
    workload_tier: &str,
    host_adapter: &str,
) -> MaterialSideEffectClass {
    if workload_tier == "observe-and-read" {
        return MaterialSideEffectClass::ReadOnlyProjection;
    }

    if host_adapter == "repo-shell" {
        MaterialSideEffectClass::RepoMutation
    } else {
        MaterialSideEffectClass::ServiceInvocation
    }
}

pub fn classify_execution_request(
    action_type: &str,
    side_effect_flags: &SideEffectFlags,
    target_id: &str,
) -> MaterialSideEffectClass {
    if action_type == "launch_executor" || target_id == "octon-studio" {
        return MaterialSideEffectClass::ExecutorLaunch;
    }

    if side_effect_flags.write_repo
        || side_effect_flags.state_mutation
        || side_effect_flags.branch_mutation
    {
        return MaterialSideEffectClass::RepoMutation;
    }

    if side_effect_flags.write_evidence && !side_effect_flags.write_repo {
        return MaterialSideEffectClass::EvidenceMutation;
    }

    if side_effect_flags.network || side_effect_flags.model_invoke {
        return MaterialSideEffectClass::ServiceInvocation;
    }

    MaterialSideEffectClass::ReadOnlyProjection
}

pub fn inventory_metadata(
    workload_tier: &str,
    host_adapter: &str,
    action_type: &str,
    target_id: &str,
    side_effect_flags: &SideEffectFlags,
) -> BTreeMap<String, String> {
    let mut metadata = BTreeMap::new();
    let support_class = classify_support_posture(workload_tier, host_adapter);
    let request_class = classify_execution_request(action_type, side_effect_flags, target_id);
    let inventory_entry = inventory()
        .iter()
        .find(|entry| entry.class == request_class)
        .or_else(|| {
            inventory()
                .iter()
                .find(|entry| entry.class == support_class)
        })
        .unwrap_or(&inventory()[0]);

    metadata.insert(
        "material_side_effect_inventory_schema".to_string(),
        MATERIAL_SIDE_EFFECT_INVENTORY_SCHEMA_REF.to_string(),
    );
    metadata.insert(
        "authorization_boundary_coverage_schema".to_string(),
        AUTHORIZATION_BOUNDARY_COVERAGE_SCHEMA_REF.to_string(),
    );
    metadata.insert(
        "material_side_effect_class".to_string(),
        request_class.as_str().to_string(),
    );
    metadata.insert(
        "material_side_effect_inventory_id".to_string(),
        inventory_entry.id.to_string(),
    );
    metadata.insert(
        "authorization_boundary_ref".to_string(),
        inventory_entry.required_boundary.to_string(),
    );
    metadata.insert(
        "material_side_effect_root".to_string(),
        inventory_entry
            .affected_roots
            .first()
            .copied()
            .unwrap_or(".octon/")
            .to_string(),
    );
    metadata.insert(
        "material_side_effect_material".to_string(),
        inventory_entry.material.to_string(),
    );
    metadata.insert(
        "support_side_effect_class".to_string(),
        support_class.as_str().to_string(),
    );
    metadata
}
