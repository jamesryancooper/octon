use anyhow::{anyhow, Context, Result};
use glob::Pattern;
use jsonschema::JSONSchema;
use serde::de::DeserializeOwned;
use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::collections::{BTreeMap, BTreeSet, HashMap, HashSet};
use std::fs;
use std::path::{Path, PathBuf};
use time::format_description;

pub const ALLOWED_ATOM_TOOLS: &[&str] = &[
    "Read",
    "Glob",
    "Grep",
    "Edit",
    "WebFetch",
    "WebSearch",
    "Task",
    "Shell",
    "Bash",
    "Write",
];

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PolicyV2 {
    pub schema_version: String,
    pub mode: String,
    pub defaults: PolicyDefaults,
    pub exceptions: ExceptionsConfig,
    #[serde(default)]
    pub governance_overrides: GovernanceOverridesConfig,
    pub grants: GrantsConfig,
    pub agent_only: AgentOnlyConfig,
    pub kill_switch: KillSwitchConfig,
    pub profiles: HashMap<String, ProfileConfig>,
    pub observability: ObservabilityConfig,
    #[serde(default)]
    pub flags_metadata: FlagsMetadataConfig,
    #[serde(default)]
    pub acp: AcpConfig,
    #[serde(default)]
    pub reversibility: ReversibilityConfig,
    #[serde(default)]
    pub budgets: HashMap<String, HashMap<String, f64>>,
    #[serde(default)]
    pub quorum: HashMap<String, QuorumConfig>,
    #[serde(default)]
    pub attestations: AttestationsConfig,
    #[serde(default)]
    pub circuit_breakers: HashMap<String, CircuitBreakerConfig>,
    #[serde(default)]
    pub receipts: ReceiptsConfig,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PolicyDefaults {
    pub fail_closed: bool,
    pub deny_unknown_tokens: bool,
    pub deny_unscoped_bash: bool,
    pub deny_unscoped_write: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExceptionsConfig {
    pub state_file: String,
    pub require_owner: bool,
    pub require_reason: bool,
    pub require_created: bool,
    pub require_expires: bool,
    pub max_lease_days: i64,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct GovernanceOverridesConfig {
    #[serde(default)]
    pub waivers: Option<GovernanceOverrideType>,
    #[serde(default)]
    pub exceptions: Option<GovernanceOverrideType>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct GovernanceOverrideType {
    #[serde(default)]
    pub state_file: String,
    #[serde(default)]
    pub required_fields: Vec<String>,
    #[serde(default)]
    pub max_duration_days: i64,
    #[serde(default)]
    pub require_receipt: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GrantsConfig {
    pub state_dir: String,
    pub default_ttl_seconds: u64,
    pub max_ttl_seconds_by_tier: TierTtls,
    pub allow_auto_grant_low: bool,
    pub allow_auto_grant_medium: bool,
    pub allow_auto_grant_high: bool,
    pub require_provenance: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TierTtls {
    pub low: u64,
    pub medium: u64,
    pub high: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentOnlyConfig {
    pub enabled: bool,
    pub risk_tiers: RiskTiers,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RiskTiers {
    pub low: RiskTierConfig,
    pub medium: RiskTierConfig,
    pub high: RiskTierConfig,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RiskTierConfig {
    pub min_distinct_agents: usize,
    pub require_review: bool,
    pub require_quorum_token: bool,
    pub require_rollback_plan: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KillSwitchConfig {
    pub state_dir: String,
    pub fail_closed: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProfileConfig {
    pub description: String,
    pub auto_grant_tier: String,
    pub tool_bundle: Vec<String>,
    pub write_scope_bundle: Vec<String>,
    pub service_allowlist: Vec<String>,
    pub deny_rules: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ObservabilityConfig {
    pub decision_log_path: String,
    pub friction_slo: FrictionSlo,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct FlagsMetadataConfig {
    #[serde(default)]
    pub contract_file: String,
    #[serde(default)]
    pub schema_file: String,
    #[serde(default)]
    pub required_fields: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FrictionSlo {
    pub false_deny_rate_max: f64,
    pub median_deny_to_unblock_seconds_max: u64,
    pub auto_remediation_success_rate_min: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpConfig {
    #[serde(default)]
    pub levels: Vec<AcpLevelDefinition>,
    #[serde(default)]
    pub risk_tier_mapping: HashMap<String, String>,
    #[serde(default)]
    pub operating_modes: HashMap<String, AcpOperatingMode>,
    #[serde(default)]
    pub evidence_contracts: HashMap<String, AcpEvidenceContract>,
    #[serde(default)]
    pub profile_mode_map: HashMap<String, String>,
    #[serde(default)]
    pub docs_gate: Option<AcpDocsGateConfig>,
    #[serde(default)]
    pub materiality: Option<AcpMaterialityConfig>,
    #[serde(default)]
    pub telemetry_gate: Option<AcpTelemetryGateConfig>,
    #[serde(default)]
    pub flag_metadata_gate: Option<AcpFlagMetadataGateConfig>,
    #[serde(default)]
    pub profile_defaults: HashMap<String, AcpProfileDefault>,
    #[serde(default)]
    pub stage_only_behavior: Option<AcpStageOnlyBehavior>,
    #[serde(default)]
    pub rules: Vec<AcpRule>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpLevelDefinition {
    pub id: String,
    pub name: String,
    pub description: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpOperatingMode {
    #[serde(default = "default_acp_level_zero")]
    pub acp_ceiling: String,
    #[serde(default)]
    pub required_evidence_contract: String,
    #[serde(default)]
    pub escalation_path: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpEvidenceContract {
    #[serde(default)]
    pub required_evidence: Vec<String>,
    #[serde(default)]
    pub remediation: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpProfileDefault {
    #[serde(default = "default_acp_level_zero")]
    pub ceiling: String,
    #[serde(default)]
    pub allow_stage_only_fallback: bool,
    #[serde(default)]
    pub break_glass_required: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpStageOnlyBehavior {
    #[serde(default)]
    pub emit_receipt: bool,
    #[serde(default)]
    pub preserve_artifacts: bool,
    #[serde(default)]
    pub notify: Option<AcpStageOnlyNotify>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpStageOnlyNotify {
    #[serde(default)]
    pub enabled: bool,
    #[serde(default)]
    pub threshold_acp: Option<String>,
    #[serde(default)]
    pub channels: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpDocsGateConfig {
    #[serde(default)]
    pub enforce_on_phase: Vec<String>,
    #[serde(default)]
    pub evidence_types: Vec<String>,
    #[serde(default)]
    pub reason_code: Option<String>,
    #[serde(default)]
    pub missing_action_by_acp: HashMap<String, String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpMaterialityConfig {
    #[serde(default)]
    pub predicate_name: String,
    #[serde(default)]
    pub aliases: Vec<String>,
    #[serde(default)]
    pub target_fields: AcpMaterialityTargetFields,
    #[serde(default)]
    pub enforce_on_phase: Vec<String>,
    #[serde(default)]
    pub default_for_phase: AcpMaterialityDefaults,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpMaterialityTargetFields {
    #[serde(default)]
    pub canonical: String,
    #[serde(default)]
    pub aliases: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpMaterialityDefaults {
    #[serde(default)]
    pub promote: bool,
    #[serde(default)]
    pub finalize: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpTelemetryGateConfig {
    #[serde(default)]
    pub enforce_on_phase: Vec<String>,
    #[serde(default = "default_acp_level_one")]
    pub required_for_acp_at_or_above: String,
    #[serde(default)]
    pub target_field: String,
    #[serde(default)]
    pub allowed_by_acp: HashMap<String, Vec<String>>,
    #[serde(default)]
    pub reason_codes: AcpTelemetryReasonCodes,
    #[serde(default)]
    pub missing_action_by_acp: HashMap<String, String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpTelemetryReasonCodes {
    #[serde(default)]
    pub missing: String,
    #[serde(default)]
    pub invalid: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpFlagMetadataGateConfig {
    #[serde(default)]
    pub enforce_on_phase: Vec<String>,
    #[serde(default)]
    pub required_when_target_flags: Vec<String>,
    #[serde(default)]
    pub metadata_valid_field: String,
    #[serde(default)]
    pub evidence_type: String,
    #[serde(default)]
    pub reason_codes: AcpFlagMetadataReasonCodes,
    #[serde(default)]
    pub missing_action_by_acp: HashMap<String, String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpFlagMetadataReasonCodes {
    #[serde(default)]
    pub missing_evidence: String,
    #[serde(default)]
    pub invalid: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpRule {
    pub id: String,
    pub r#match: AcpRuleMatch,
    pub require: AcpRuleRequire,
    pub on_missing_requirements: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpRuleMatch {
    #[serde(default)]
    pub class: OneOrManyString,
    #[serde(default)]
    pub phase: Vec<String>,
    #[serde(default)]
    pub target: Option<HashMap<String, Value>>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpRuleRequire {
    #[serde(default = "default_acp_level_zero")]
    pub acp: String,
    #[serde(default = "default_phase_promote")]
    pub phase: String,
    #[serde(default)]
    pub break_glass_required: bool,
    #[serde(default)]
    pub reversibility: Option<AcpRuleReversibility>,
    #[serde(default)]
    pub evidence_required: Vec<String>,
    #[serde(default)]
    pub quorum_required: Option<String>,
    #[serde(default)]
    pub budget_set: Option<String>,
    #[serde(default)]
    pub circuit_breaker_set: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpRuleReversibility {
    #[serde(default)]
    pub required: bool,
    #[serde(default)]
    pub primitive: Option<String>,
    #[serde(default)]
    pub rollback_proof_required: bool,
    #[serde(default)]
    pub recovery_window_default: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ReversibilityConfig {
    #[serde(default = "default_acp_level_one")]
    pub required_for_acp_at_or_above: String,
    #[serde(default)]
    pub primitives: HashMap<String, ReversiblePrimitive>,
    #[serde(default)]
    pub blocked_when_not_break_glass: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ReversiblePrimitive {
    #[serde(default)]
    pub description: String,
    #[serde(default)]
    pub rollback_handle_type: String,
    #[serde(default)]
    pub default_recovery_window: Option<String>,
    #[serde(default)]
    pub trash_root: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct QuorumConfig {
    #[serde(default)]
    pub required_roles: Vec<String>,
    #[serde(default)]
    pub optional_roles: Vec<String>,
    #[serde(default)]
    pub min_signatures: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AttestationsConfig {
    #[serde(default)]
    pub required_fields: Vec<String>,
    #[serde(default)]
    pub roles: HashMap<String, AttestationRoleDefinition>,
    #[serde(default)]
    pub binding: Option<AttestationBinding>,
    #[serde(default)]
    pub owner_attestation: Option<OwnerAttestationConfig>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AttestationRoleDefinition {
    #[serde(default)]
    pub description: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AttestationBinding {
    #[serde(default)]
    pub require_plan_hash: bool,
    #[serde(default)]
    pub require_evidence_hash: bool,
    #[serde(default)]
    pub allowed_hash_algorithms: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct OwnerAttestationConfig {
    #[serde(default)]
    pub enabled: bool,
    #[serde(default = "default_owner_attestation_role")]
    pub role: String,
    #[serde(default)]
    pub sources: Vec<String>,
    #[serde(default)]
    pub required_for_acp: Vec<String>,
    #[serde(default)]
    pub required_when_target_flags: Vec<String>,
    #[serde(default)]
    pub timeout_seconds: u64,
    #[serde(default)]
    pub retry: OwnerAttestationRetryConfig,
    #[serde(default)]
    pub escalate_on_exhausted: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct OwnerAttestationRetryConfig {
    #[serde(default)]
    pub max_attempts: u64,
    #[serde(default)]
    pub backoff_seconds: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct CircuitBreakerConfig {
    #[serde(default)]
    pub triggers: Vec<CircuitBreakerTrigger>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct CircuitBreakerTrigger {
    #[serde(default)]
    pub id: String,
    #[serde(default)]
    pub r#type: String,
    #[serde(default)]
    pub signal: String,
    #[serde(default)]
    pub threshold: u64,
    #[serde(default)]
    pub action: String,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ReceiptsConfig {
    #[serde(default = "default_acp_level_one")]
    pub required_for_acp_at_or_above: String,
    #[serde(default)]
    pub emit_on: Vec<String>,
    #[serde(default)]
    pub paths: ReceiptPathsConfig,
    #[serde(default)]
    pub required_fields: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct ReceiptPathsConfig {
    #[serde(default)]
    pub runs_dir: String,
    #[serde(default)]
    pub decision_log: String,
    #[serde(default)]
    pub acp_decision_log: String,
    #[serde(default)]
    pub receipt_filename: Option<String>,
    #[serde(default)]
    pub digest_filename: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(untagged)]
pub enum OneOrManyString {
    One(String),
    Many(Vec<String>),
}

impl Default for OneOrManyString {
    fn default() -> Self {
        Self::Many(Vec::new())
    }
}

impl OneOrManyString {
    pub fn contains_value(&self, value: &str) -> bool {
        match self {
            OneOrManyString::One(single) => single == value,
            OneOrManyString::Many(values) => values.iter().any(|item| item == value),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum AcpDecisionKind {
    Allow,
    StageOnly,
    Deny,
    Escalate,
}

impl Default for AcpDecisionKind {
    fn default() -> Self {
        Self::Deny
    }
}

impl AcpDecisionKind {
    pub fn as_str(&self) -> &'static str {
        match self {
            AcpDecisionKind::Allow => "ALLOW",
            AcpDecisionKind::StageOnly => "STAGE_ONLY",
            AcpDecisionKind::Deny => "DENY",
            AcpDecisionKind::Escalate => "ESCALATE",
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpRequest {
    pub run_id: String,
    #[serde(default)]
    pub actor: AcpActor,
    #[serde(default)]
    pub profile: String,
    #[serde(default)]
    pub phase: String,
    #[serde(default)]
    pub operation: AcpOperation,
    #[serde(default)]
    pub acp_claim: Option<String>,
    #[serde(default)]
    pub break_glass: bool,
    #[serde(default)]
    pub reversibility: Option<AcpReversibilityProof>,
    #[serde(default)]
    pub evidence: Vec<AcpEvidence>,
    #[serde(default)]
    pub attestations: Vec<AcpAttestation>,
    #[serde(default)]
    pub budgets: HashMap<String, f64>,
    #[serde(default)]
    pub counters: HashMap<String, f64>,
    #[serde(default)]
    pub circuit_signals: Vec<String>,
    #[serde(default)]
    pub plan_hash: Option<String>,
    #[serde(default)]
    pub evidence_hash: Option<String>,
    #[serde(default)]
    pub intent: Option<String>,
    #[serde(default)]
    pub boundaries: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpActor {
    #[serde(default)]
    pub id: String,
    #[serde(default)]
    pub r#type: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpOperation {
    #[serde(default)]
    pub class: String,
    #[serde(default)]
    pub targets: Vec<String>,
    #[serde(default)]
    pub resources: Vec<String>,
    #[serde(default)]
    pub target: HashMap<String, Value>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpReversibilityProof {
    #[serde(default)]
    pub reversible: bool,
    #[serde(default)]
    pub primitive: Option<String>,
    #[serde(default)]
    pub rollback_handle: Option<String>,
    #[serde(default)]
    pub recovery_window: Option<String>,
    #[serde(default)]
    pub rollback_proof: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpEvidence {
    #[serde(default)]
    pub r#type: String,
    #[serde(default)]
    pub r#ref: String,
    #[serde(default)]
    pub sha256: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpAttestation {
    #[serde(default)]
    pub role: String,
    #[serde(default)]
    pub actor_id: String,
    #[serde(default)]
    pub timestamp: Option<String>,
    #[serde(default)]
    pub plan_hash: Option<String>,
    #[serde(default)]
    pub evidence_hash: Option<String>,
    #[serde(default)]
    pub signature: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpMissingRequirements {
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub missing_evidence: Vec<String>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub missing_attestations: Vec<String>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub missing_reversibility: Vec<String>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub breaker_actions: Vec<String>,
    #[serde(default, skip_serializing_if = "BTreeMap::is_empty")]
    pub budget_remaining: BTreeMap<String, f64>,
    #[serde(default, skip_serializing_if = "BTreeMap::is_empty")]
    pub budget_exceeded: BTreeMap<String, f64>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub owner_attestation: Option<OwnerAttestationRequirement>,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct OwnerAttestationRequirement {
    pub required: bool,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub sources: Vec<String>,
    pub timeout_seconds: u64,
    pub retry_max_attempts: u64,
    pub retry_attempt: u64,
    pub exhausted: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct AcpDecision {
    pub allow: bool,
    pub decision: AcpDecisionKind,
    pub effective_acp: String,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub reason_codes: Vec<String>,
    #[serde(default, skip_serializing_if = "String::is_empty")]
    pub remediation: String,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub remediation_steps: Vec<String>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub notes: Vec<String>,
    #[serde(default)]
    pub requirements: AcpMissingRequirements,
}

fn default_acp_level_zero() -> String {
    "ACP-0".to_string()
}

fn default_acp_level_one() -> String {
    "ACP-1".to_string()
}

fn default_owner_attestation_role() -> String {
    "owner".to_string()
}

fn default_phase_promote() -> String {
    "promote".to_string()
}

fn default_materiality_config() -> AcpMaterialityConfig {
    AcpMaterialityConfig {
        predicate_name: "material_side_effect".to_string(),
        aliases: vec![
            "material side-effect".to_string(),
            "meaningful behavior change".to_string(),
            "durable effect".to_string(),
            "promotion".to_string(),
        ],
        target_fields: AcpMaterialityTargetFields {
            canonical: "material_side_effect".to_string(),
            aliases: vec![
                "meaningful_behavior_change".to_string(),
                "durable_effect".to_string(),
                "promotion".to_string(),
            ],
        },
        enforce_on_phase: vec!["promote".to_string(), "finalize".to_string()],
        default_for_phase: AcpMaterialityDefaults {
            promote: true,
            finalize: true,
        },
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExceptionLeaseFile {
    pub exceptions: Vec<ExceptionLease>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExceptionLease {
    pub id: Option<String>,
    pub scope: String,
    pub target: String,
    pub rule: String,
    pub owner: Option<String>,
    pub reason: Option<String>,
    pub created: Option<String>,
    pub expires: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KillSwitchRecord {
    pub id: Option<String>,
    pub scope: String,
    pub state: Option<String>,
    pub owner: Option<String>,
    pub reason: Option<String>,
    pub created: Option<String>,
    pub expires: Option<String>,
    pub incident_id: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ServicesManifest {
    pub services: Vec<ServiceManifestEntry>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ServiceManifestEntry {
    pub id: String,
    pub path: String,
    pub status: String,
    pub interface_type: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SkillsManifest {
    pub skills: Vec<SkillManifestEntry>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SkillManifestEntry {
    pub id: String,
    pub path: String,
    pub status: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DenyPayload {
    pub code: String,
    pub message: String,
    pub scope: String,
    pub target: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub missing_scope: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub expected_token: Option<String>,
    pub remediation_hint: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub risk_tier: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Decision {
    pub allow: bool,
    pub mode: String,
    #[serde(default, skip_serializing_if = "is_false")]
    pub shadow_deny: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub deny: Option<DenyPayload>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub notes: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum ScopeKind {
    Service,
    Skill,
}

impl ScopeKind {
    pub fn as_str(&self) -> &'static str {
        match self {
            ScopeKind::Service => "service",
            ScopeKind::Skill => "skill",
        }
    }
}

#[derive(Debug, Clone)]
pub struct PreflightRequest {
    pub kind: ScopeKind,
    pub target_id: String,
    pub manifest_path: PathBuf,
    pub artifact_path: PathBuf,
    pub policy_path: PathBuf,
    pub exceptions_path: Option<PathBuf>,
    pub caller_skill_id: Option<String>,
    pub caller_skill_manifest_path: Option<PathBuf>,
    pub caller_skill_artifact_path: Option<PathBuf>,
}

#[derive(Debug, Clone)]
pub struct EnforceRequest {
    pub preflight: PreflightRequest,
    pub requested_command: Option<String>,
    pub risk_tier: String,
    pub agent_id: Option<String>,
    pub agent_ids_csv: Option<String>,
    pub review_agent_id: Option<String>,
    pub quorum_token: Option<String>,
    pub rollback_plan_id: Option<String>,
    pub category: Option<String>,
}

#[derive(Debug, Clone)]
pub struct GrantEvalRequest {
    pub policy_path: PathBuf,
    pub tier: String,
    pub requested_tools: Vec<String>,
    pub requested_write_scopes: Vec<String>,
    pub requested_ttl_seconds: Option<u64>,
    pub has_review_evidence: bool,
    pub has_quorum_evidence: bool,
    pub request_id: Option<String>,
    pub agent_id: Option<String>,
    pub plan_step_id: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GrantEvalResult {
    pub allow: bool,
    pub tier: String,
    pub mode: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub deny: Option<DenyPayload>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub effective_ttl_seconds: Option<u64>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub notes: Vec<String>,
}

#[derive(Debug, Clone)]
pub struct DoctorRequest {
    pub policy_path: PathBuf,
    pub schema_path: PathBuf,
    pub reason_codes_path: Option<PathBuf>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DoctorReport {
    pub valid: bool,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub schema_errors: Vec<String>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub semantic_errors: Vec<String>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub warnings: Vec<String>,
}

#[derive(Debug, Clone)]
pub struct ReceiptValidateRequest {
    pub policy_path: PathBuf,
    pub receipt_path: PathBuf,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReceiptValidateReport {
    pub valid: bool,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub reason_codes: Vec<String>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub errors: Vec<String>,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub warnings: Vec<String>,
}

#[derive(Debug, Clone)]
struct ArtifactContext {
    status: String,
    interface_type: Option<String>,
    allowed_tools: Vec<String>,
    allowed_services: Vec<String>,
    fail_closed: Option<String>,
    bash_scopes: Vec<String>,
    has_broad_write: bool,
}

fn is_false(value: &bool) -> bool {
    !*value
}

pub fn today_ymd_utc() -> Result<String> {
    let format = format_description::parse("[year]-[month]-[day]")?;
    Ok(time::OffsetDateTime::now_utc().format(&format)?)
}

pub fn load_policy(path: &Path) -> Result<PolicyV2> {
    let mut policy: PolicyV2 = load_yaml(path)?;

    if let Ok(mode_override) = std::env::var("OCTON_POLICY_MODE_OVERRIDE") {
        let normalized = mode_override.trim().to_lowercase();
        if matches!(
            normalized.as_str(),
            "shadow" | "soft-enforce" | "hard-enforce"
        ) {
            policy.mode = normalized;
        }
    }

    Ok(policy)
}

pub fn load_profile<'a>(policy: &'a PolicyV2, profile_id: &str) -> Option<&'a ProfileConfig> {
    policy.profiles.get(profile_id)
}

pub fn split_allowed_tools(raw: &str) -> Vec<String> {
    let mut tokens = Vec::new();
    let mut token = String::new();
    let mut depth: i64 = 0;

    for ch in raw.chars() {
        match ch {
            '(' => {
                depth += 1;
                token.push(ch);
            }
            ')' => {
                if depth > 0 {
                    depth -= 1;
                }
                token.push(ch);
            }
            ' ' | '\t' if depth == 0 => {
                if !token.trim().is_empty() {
                    tokens.push(token.trim().to_string());
                    token.clear();
                }
            }
            _ => token.push(ch),
        }
    }

    if !token.trim().is_empty() {
        tokens.push(token.trim().to_string());
    }

    tokens
}

pub fn split_allowed_services(raw: &str) -> Vec<String> {
    raw.split_whitespace()
        .map(str::trim)
        .filter(|value| !value.is_empty())
        .map(ToString::to_string)
        .collect()
}

pub fn is_known_tool_token(token: &str) -> bool {
    if ALLOWED_ATOM_TOOLS.contains(&token) {
        return true;
    }
    if token.starts_with("pack:") {
        return true;
    }
    if token.starts_with("Bash(") && token.ends_with(')') {
        return true;
    }
    if token.starts_with("Write(") && token.ends_with(')') {
        return true;
    }
    false
}

pub fn bash_scope_from_token(token: &str) -> Option<String> {
    if token.starts_with("Bash(") && token.ends_with(')') {
        let scope = token.trim_start_matches("Bash(").trim_end_matches(')');
        return Some(scope.to_string());
    }
    None
}

pub fn write_scope_from_token(token: &str) -> Option<String> {
    if token.starts_with("Write(") && token.ends_with(')') {
        let scope = token.trim_start_matches("Write(").trim_end_matches(')');
        return Some(scope.to_string());
    }
    None
}

fn infer_services_manifest_from_skills_manifest(path: &Path) -> Option<PathBuf> {
    let sibling_fixture = path.parent()?.join("services-manifest.yml");
    if sibling_fixture.exists() {
        return Some(sibling_fixture);
    }

    let runtime_dir = path.parent()?.parent()?;
    Some(runtime_dir.join("services").join("manifest.yml"))
}

fn partial_caller_skill_context(request: &PreflightRequest) -> bool {
    request.caller_skill_id.is_some()
        || request.caller_skill_manifest_path.is_some()
        || request.caller_skill_artifact_path.is_some()
}

fn validate_declared_skill_services(
    request: &PreflightRequest,
    artifact: &ArtifactContext,
) -> Option<Decision> {
    if artifact.allowed_services.is_empty() {
        return None;
    }

    let Some(services_manifest_path) = infer_services_manifest_from_skills_manifest(&request.manifest_path) else {
        return Some(deny(
            "hard-enforce",
            "DDB026_ALLOWED_SERVICE_MANIFEST_UNRESOLVABLE",
            "Could not resolve services manifest for skill allowed-services validation",
            "skill",
            &request.target_id,
            None,
            None,
            "Run validation from a standard .octon runtime layout or supply a resolvable skills manifest path",
            None,
        ));
    };

    let Ok(manifest) = load_yaml::<ServicesManifest>(&services_manifest_path) else {
        return Some(deny(
            "hard-enforce",
            "DDB026_ALLOWED_SERVICE_MANIFEST_UNRESOLVABLE",
            "Could not load services manifest for skill allowed-services validation",
            "skill",
            &request.target_id,
            None,
            None,
            "Ensure .octon/capabilities/runtime/services/manifest.yml exists and is valid",
            None,
        ));
    };

    let service_ids = manifest
        .services
        .into_iter()
        .map(|service| service.id)
        .collect::<HashSet<_>>();

    for service_id in &artifact.allowed_services {
        if !service_ids.contains(service_id) {
            return Some(deny(
                "hard-enforce",
                "DDB027_UNKNOWN_ALLOWED_SERVICE",
                "Skill declares unknown allowed-services id",
                "skill",
                &request.target_id,
                None,
                Some(service_id.clone()),
                "Declare only services that exist in runtime/services/manifest.yml",
                None,
            ));
        }
    }

    None
}

fn validate_caller_skill_service_access(request: &PreflightRequest) -> Result<Option<Decision>> {
    if !matches!(request.kind, ScopeKind::Service) {
        return Ok(None);
    }

    if !partial_caller_skill_context(request) {
        return Ok(None);
    }

    let (Some(caller_skill_id), Some(caller_manifest_path), Some(caller_artifact_path)) = (
        request.caller_skill_id.clone(),
        request.caller_skill_manifest_path.clone(),
        request.caller_skill_artifact_path.clone(),
    ) else {
        return Ok(Some(deny(
            "hard-enforce",
            "DDB028_CALLER_SKILL_CONTEXT_INCOMPLETE",
            "Service authorization request included incomplete caller skill context",
            "service",
            &request.target_id,
            None,
            None,
            "Supply caller_skill_id, caller_skill_manifest_path, and caller_skill_artifact_path together",
            None,
        )));
    };

    let caller_request = PreflightRequest {
        kind: ScopeKind::Skill,
        target_id: caller_skill_id.clone(),
        manifest_path: caller_manifest_path,
        artifact_path: caller_artifact_path,
        policy_path: request.policy_path.clone(),
        exceptions_path: request.exceptions_path.clone(),
        caller_skill_id: None,
        caller_skill_manifest_path: None,
        caller_skill_artifact_path: None,
    };

    let caller_artifact = load_artifact_context(&caller_request)?;
    if caller_artifact.status != "active" {
        return Ok(Some(deny(
            "hard-enforce",
            "DDB029_CALLER_SKILL_INACTIVE",
            "Inactive caller skill cannot authorize service access",
            "service",
            &request.target_id,
            None,
            Some(caller_skill_id),
            "Use an active caller skill or update manifest status",
            None,
        )));
    }

    if let Some(decision) = validate_declared_skill_services(&caller_request, &caller_artifact) {
        return Ok(Some(decision));
    }

    if !caller_artifact
        .allowed_services
        .iter()
        .any(|service_id| service_id == &request.target_id)
    {
        return Ok(Some(deny(
            "hard-enforce",
            "DDB030_SKILL_SERVICE_NOT_DECLARED",
            "Caller skill did not declare permission to invoke this service",
            "service",
            &request.target_id,
            None,
            Some(request.target_id.clone()),
            "Add the service id to caller SKILL.md allowed-services or remove the service invocation",
            None,
        )));
    }

    Ok(None)
}

pub fn evaluate_preflight(request: &PreflightRequest) -> Result<Decision> {
    let policy = load_policy(&request.policy_path)
        .with_context(|| format!("failed to load policy {}", request.policy_path.display()))?;

    let exceptions_path = request
        .exceptions_path
        .clone()
        .unwrap_or_else(|| PathBuf::from(&policy.exceptions.state_file));

    let exceptions = load_exceptions(&exceptions_path)?;
    let artifact = load_artifact_context(request)?;
    let today = today_ymd_utc()?;

    let mut decision = match request.kind {
        ScopeKind::Service => {
            evaluate_service_preflight(&policy, request, &artifact, &exceptions, &today)
        }
        ScopeKind::Skill => {
            evaluate_skill_preflight(&policy, request, &artifact, &exceptions, &today)
        }
    };

    if decision.allow {
        if let Some(caller_decision) = validate_caller_skill_service_access(request)? {
            decision = caller_decision;
        }
    }

    apply_mode(&policy.mode, &mut decision);
    Ok(decision)
}

pub fn evaluate_enforce(request: &EnforceRequest) -> Result<Decision> {
    let policy = load_policy(&request.preflight.policy_path).with_context(|| {
        format!(
            "failed to load policy {}",
            request.preflight.policy_path.display()
        )
    })?;

    let exceptions_path = request
        .preflight
        .exceptions_path
        .clone()
        .unwrap_or_else(|| PathBuf::from(&policy.exceptions.state_file));
    let exceptions = load_exceptions(&exceptions_path)?;
    let artifact = load_artifact_context(&request.preflight)?;
    let today = today_ymd_utc()?;

    let mut decision = match request.preflight.kind {
        ScopeKind::Service => {
            evaluate_service_preflight(&policy, &request.preflight, &artifact, &exceptions, &today)
        }
        ScopeKind::Skill => {
            evaluate_skill_preflight(&policy, &request.preflight, &artifact, &exceptions, &today)
        }
    };

    if !decision.allow {
        apply_mode(&policy.mode, &mut decision);
        return Ok(decision);
    }

    if matches!(request.preflight.kind, ScopeKind::Service)
        && artifact
            .interface_type
            .as_deref()
            .map(|value| value == "shell")
            .unwrap_or(false)
    {
        if let Some(command) = &request.requested_command {
            let command_allowed = artifact
                .bash_scopes
                .iter()
                .any(|scope| matches_bash_scope(scope, command));
            if !command_allowed {
                decision = deny(
                    "hard-enforce",
                    "DDB007_BASH_SCOPE_DENIED",
                    "Command invocation not permitted by declared Bash scopes",
                    "service",
                    &request.preflight.target_id,
                    Some(format!("Bash({command})")),
                    Some(format!("Bash({command})")),
                    "Add a minimal Bash scope for this command or run with a matching profile",
                    Some(request.risk_tier.clone()),
                );
            }
        }
    }

    if decision.allow && matches!(request.preflight.kind, ScopeKind::Service) {
        let agent_decision = evaluate_agent_only(&policy, request, &today)?;
        if !agent_decision.allow {
            decision = agent_decision;
        }
    }

    apply_mode(&policy.mode, &mut decision);
    Ok(decision)
}

pub fn evaluate_acp_preflight(policy_path: &Path, request: &AcpRequest) -> Result<AcpDecision> {
    let policy = load_policy(policy_path)
        .with_context(|| format!("failed to load policy {}", policy_path.display()))?;
    evaluate_acp_internal(&policy, request, false)
}

pub fn evaluate_acp_enforce(policy_path: &Path, request: &AcpRequest) -> Result<AcpDecision> {
    let policy = load_policy(policy_path)
        .with_context(|| format!("failed to load policy {}", policy_path.display()))?;
    evaluate_acp_internal(&policy, request, true)
}

fn evaluate_acp_internal(
    policy: &PolicyV2,
    request: &AcpRequest,
    enforce: bool,
) -> Result<AcpDecision> {
    let phase = normalize_phase(&request.phase, enforce);
    let operation_class = request.operation.class.trim();
    let mut reason_codes = Vec::new();
    let mut reason_seen = HashSet::new();
    let mut notes = Vec::new();
    let mut requirements = AcpMissingRequirements::default();

    if operation_class.is_empty() {
        push_reason(&mut reason_codes, &mut reason_seen, "ACP_RULE_NO_MATCH");
        let (remediation, remediation_steps) =
            build_acp_remediation(&AcpDecisionKind::Deny, &reason_codes);
        return Ok(AcpDecision {
            allow: false,
            decision: AcpDecisionKind::Deny,
            effective_acp: request
                .acp_claim
                .clone()
                .unwrap_or_else(default_acp_level_zero),
            reason_codes,
            remediation,
            remediation_steps,
            notes: vec!["operation.class missing from ACP request".to_string()],
            requirements,
        });
    }

    let today = today_ymd_utc()?;
    let mut scope_keys = vec!["global".to_string(), format!("operation:{operation_class}")];
    if let Some(category) = request
        .operation
        .target
        .get("category")
        .and_then(value_to_string)
    {
        scope_keys.push(format!("category:{category}"));
    }
    if is_kill_switch_active(policy, &scope_keys, &today)? {
        push_reason(&mut reason_codes, &mut reason_seen, "ACP_KILLSWITCH_ACTIVE");
        let (remediation, remediation_steps) =
            build_acp_remediation(&AcpDecisionKind::Deny, &reason_codes);
        return Ok(AcpDecision {
            allow: false,
            decision: AcpDecisionKind::Deny,
            effective_acp: request
                .acp_claim
                .clone()
                .unwrap_or_else(default_acp_level_zero),
            reason_codes,
            remediation,
            remediation_steps,
            notes: vec!["Kill-switch active for ACP scope".to_string()],
            requirements,
        });
    }

    let Some(rule) =
        find_matching_acp_rule(policy, operation_class, &phase, &request.operation.target)
    else {
        push_reason(&mut reason_codes, &mut reason_seen, "ACP_RULE_NO_MATCH");
        let (remediation, remediation_steps) =
            build_acp_remediation(&AcpDecisionKind::Deny, &reason_codes);
        return Ok(AcpDecision {
            allow: false,
            decision: AcpDecisionKind::Deny,
            effective_acp: request
                .acp_claim
                .clone()
                .unwrap_or_else(default_acp_level_zero),
            reason_codes,
            remediation,
            remediation_steps,
            notes: vec![format!(
                "No ACP rule matched class='{operation_class}' phase='{phase}'"
            )],
            requirements,
        });
    };

    if rule_targets_protected_scope(rule.r#match.target.as_ref()) {
        push_reason(&mut reason_codes, &mut reason_seen, "ACP_PROTECTED_TARGET");
    }

    let effective_acp = rule.require.acp.clone();
    let profile_cfg = policy
        .acp
        .profile_defaults
        .get(&request.profile)
        .cloned()
        .unwrap_or(AcpProfileDefault {
            ceiling: default_acp_level_zero(),
            allow_stage_only_fallback: true,
            break_glass_required: false,
        });

    let profile_ceiling_rank = acp_level_rank(&profile_cfg.ceiling);
    let required_rank = acp_level_rank(&effective_acp);
    let mut hard_deny = false;
    if profile_ceiling_rank < required_rank {
        push_reason(
            &mut reason_codes,
            &mut reason_seen,
            "ACP_PROFILE_CEILING_EXCEEDED",
        );
        notes.push(format!(
            "Profile '{}' ceiling '{}' below required '{}'",
            request.profile, profile_cfg.ceiling, effective_acp
        ));
        if !profile_cfg.allow_stage_only_fallback {
            hard_deny = true;
        }
    }

    let break_glass_required =
        rule.require.break_glass_required || profile_cfg.break_glass_required;
    if break_glass_required && !request.break_glass {
        push_reason(
            &mut reason_codes,
            &mut reason_seen,
            "RA_BREAK_GLASS_REQUIRED",
        );
        hard_deny = true;
    }

    if let Some(primitive) = request
        .reversibility
        .as_ref()
        .and_then(|value| value.primitive.as_deref())
    {
        if policy
            .reversibility
            .blocked_when_not_break_glass
            .iter()
            .any(|blocked| blocked == primitive)
            && !request.break_glass
        {
            push_reason(
                &mut reason_codes,
                &mut reason_seen,
                "ACP_IRREVERSIBLE_BLOCKED",
            );
            hard_deny = true;
        }
    }

    let reversibility_required = rule
        .require
        .reversibility
        .as_ref()
        .map(|value| value.required)
        .unwrap_or(false)
        || required_rank >= acp_level_rank(&policy.reversibility.required_for_acp_at_or_above);

    if reversibility_required {
        validate_reversibility(
            policy,
            request,
            rule,
            &mut requirements,
            &mut reason_codes,
            &mut reason_seen,
        );
    }

    validate_evidence(
        request,
        rule,
        &mut requirements,
        &mut reason_codes,
        &mut reason_seen,
    );
    let material_side_effect = resolve_material_side_effect(
        policy,
        &request.operation.target,
        &phase,
        &mut reason_codes,
        &mut reason_seen,
        &mut notes,
    );
    let docs_gate_action = validate_docs_gate(
        policy,
        request,
        &phase,
        &effective_acp,
        material_side_effect,
        &mut requirements,
        &mut reason_codes,
        &mut reason_seen,
        &mut notes,
    );
    let telemetry_gate_action = validate_telemetry_gate(
        policy,
        request,
        &phase,
        &effective_acp,
        material_side_effect,
        &mut requirements,
        &mut reason_codes,
        &mut reason_seen,
        &mut notes,
    );
    let flag_gate_action = validate_flag_metadata_gate(
        policy,
        request,
        &phase,
        &effective_acp,
        material_side_effect,
        &mut requirements,
        &mut reason_codes,
        &mut reason_seen,
        &mut notes,
    );
    validate_quorum(
        policy,
        request,
        rule,
        &mut requirements,
        &mut reason_codes,
        &mut reason_seen,
    );
    let owner_attestation_action = validate_owner_attestation(
        policy,
        request,
        &effective_acp,
        &mut requirements,
        &mut reason_codes,
        &mut reason_seen,
        &mut notes,
    );
    validate_budgets(
        policy,
        request,
        rule,
        &mut requirements,
        &mut reason_codes,
        &mut reason_seen,
    );

    let breaker_actions = evaluate_circuit_breaker_actions(policy, request, rule, &requirements);
    let mut force_stage_only = false;
    let mut force_escalate = false;

    if let Some(action) = docs_gate_action {
        match action {
            AcpDecisionKind::Deny => hard_deny = true,
            AcpDecisionKind::Escalate => force_escalate = true,
            AcpDecisionKind::StageOnly => force_stage_only = true,
            AcpDecisionKind::Allow => {}
        }
    }

    if let Some(action) = telemetry_gate_action {
        match action {
            AcpDecisionKind::Deny => hard_deny = true,
            AcpDecisionKind::Escalate => force_escalate = true,
            AcpDecisionKind::StageOnly => force_stage_only = true,
            AcpDecisionKind::Allow => {}
        }
    }

    if let Some(action) = flag_gate_action {
        match action {
            AcpDecisionKind::Deny => hard_deny = true,
            AcpDecisionKind::Escalate => force_escalate = true,
            AcpDecisionKind::StageOnly => force_stage_only = true,
            AcpDecisionKind::Allow => {}
        }
    }

    if let Some(action) = owner_attestation_action {
        match action {
            AcpDecisionKind::Deny => hard_deny = true,
            AcpDecisionKind::Escalate => force_escalate = true,
            AcpDecisionKind::StageOnly => force_stage_only = true,
            AcpDecisionKind::Allow => {}
        }
    }

    if !breaker_actions.is_empty() {
        requirements.breaker_actions = breaker_actions.clone();
        push_reason(
            &mut reason_codes,
            &mut reason_seen,
            "ACP_CIRCUIT_BREAKER_TRIPPED",
        );
        notes.push(format!(
            "Circuit breaker trigger fired with actions: {}",
            breaker_actions.join(",")
        ));
        let mut invalid_breaker_actions = Vec::new();
        for action in &breaker_actions {
            match action.as_str() {
                "auto_rollback_and_trip_killswitch" | "rollback_and_trip_killswitch" => {
                    hard_deny = true;
                }
                "halt_and_notify" => {
                    force_escalate = true;
                }
                "stop_and_stage_only" => {
                    force_stage_only = true;
                }
                unknown if unknown.starts_with("invalid_action:") => {
                    invalid_breaker_actions
                        .push(unknown.trim_start_matches("invalid_action:").to_string());
                }
                unknown => {
                    invalid_breaker_actions.push(unknown.to_string());
                }
            }
        }

        if !invalid_breaker_actions.is_empty() {
            hard_deny = true;
            push_reason(
                &mut reason_codes,
                &mut reason_seen,
                "ACP_CIRCUIT_BREAKER_INVALID_ACTION",
            );
            notes.push(format!(
                "Unsupported circuit breaker action(s): {}",
                invalid_breaker_actions.join(",")
            ));
        }
    }

    let has_missing_requirements = !requirements.missing_evidence.is_empty()
        || !requirements.missing_attestations.is_empty()
        || !requirements.missing_reversibility.is_empty()
        || !requirements.budget_exceeded.is_empty();

    let decision = if hard_deny {
        AcpDecisionKind::Deny
    } else if force_escalate {
        AcpDecisionKind::Escalate
    } else if force_stage_only {
        AcpDecisionKind::StageOnly
    } else if has_missing_requirements {
        match parse_acp_decision(&rule.on_missing_requirements) {
            AcpDecisionKind::Deny => AcpDecisionKind::Deny,
            AcpDecisionKind::Escalate => AcpDecisionKind::Escalate,
            _ => AcpDecisionKind::StageOnly,
        }
    } else {
        AcpDecisionKind::Allow
    };

    let mut final_decision = decision;
    if matches!(final_decision, AcpDecisionKind::StageOnly)
        && !profile_cfg.allow_stage_only_fallback
    {
        final_decision = AcpDecisionKind::Escalate;
        push_reason(&mut reason_codes, &mut reason_seen, "ACP_ESCALATE_POLICY");
    }

    if matches!(final_decision, AcpDecisionKind::StageOnly) {
        push_reason(
            &mut reason_codes,
            &mut reason_seen,
            "ACP_STAGE_ONLY_REQUIRED",
        );
    }

    if matches!(final_decision, AcpDecisionKind::Allow) && reason_codes.is_empty() {
        push_reason(&mut reason_codes, &mut reason_seen, "ACP_ALLOW_POLICY_PASS");
    }

    let (remediation, remediation_steps) =
        build_acp_remediation(&final_decision, &reason_codes);

    Ok(AcpDecision {
        allow: matches!(final_decision, AcpDecisionKind::Allow),
        decision: final_decision,
        effective_acp,
        reason_codes,
        remediation,
        remediation_steps,
        notes,
        requirements,
    })
}

fn normalize_phase(phase: &str, enforce: bool) -> String {
    let normalized = phase.trim().to_lowercase();
    if !normalized.is_empty() {
        return normalized;
    }
    if enforce {
        "promote".to_string()
    } else {
        "stage".to_string()
    }
}

fn parse_acp_decision(value: &str) -> AcpDecisionKind {
    match value.trim().to_uppercase().as_str() {
        "ALLOW" => AcpDecisionKind::Allow,
        "STAGE_ONLY" => AcpDecisionKind::StageOnly,
        "ESCALATE" => AcpDecisionKind::Escalate,
        _ => AcpDecisionKind::Deny,
    }
}

fn default_remediation_for_decision(decision: &AcpDecisionKind) -> &'static str {
    match decision {
        AcpDecisionKind::Allow => {
            "All required ACP controls passed. Preserve evidence artifacts for promotion traceability."
        }
        AcpDecisionKind::StageOnly => {
            "Promotion is blocked in stage-only mode until missing controls are remediated."
        }
        AcpDecisionKind::Deny => {
            "Policy denied this operation. Resolve failing controls or reduce scope before retry."
        }
        AcpDecisionKind::Escalate => {
            "Escalation is required. Route the run through the declared escalation path with full evidence."
        }
    }
}

fn remediation_for_reason_code(code: &str) -> String {
    match code {
        "ACP_ALLOW_POLICY_PASS" => {
            "No additional remediation required beyond retaining the receipt and evidence bundle."
                .to_string()
        }
        "ACP_RULE_NO_MATCH" => {
            "Add or normalize an ACP rule for this operation class, phase, and target.".to_string()
        }
        "ACP_PROFILE_CEILING_EXCEEDED" => {
            "Use a higher operating mode/profile or split the action into lower-risk reversible steps."
                .to_string()
        }
        "ACP_PROTECTED_TARGET" => {
            "Attach elevated evidence and quorum artifacts required for protected targets."
                .to_string()
        }
        "ACP_DOCS_EVIDENCE_MISSING" => {
            "Attach docs.spec, docs.adr, and docs.runbook evidence before promote.".to_string()
        }
        "ACP_EVIDENCE_MISSING" | "ACP_EVIDENCE_INVALID" => {
            "Regenerate and attach complete, hash-bound evidence artifacts for this gate."
                .to_string()
        }
        "ACP_REVERSIBILITY_REQUIRED" | "ACP_ROLLBACK_HANDLE_MISSING" | "ACP_ROLLBACK_PROOF_MISSING"
        | "ACP_RECOVERY_WINDOW_MISSING" => {
            "Provide full reversibility metadata: primitive, rollback handle, proof, and recovery window."
                .to_string()
        }
        "ACP_QUORUM_MISSING" | "ACP_QUORUM_INVALID" | "ACP_ATTESTATION_FIELD_MISSING"
        | "ACP_ATTESTATION_INVALID" | "ACP_ATTESTATION_ROLE_MISMATCH"
        | "ACP_OWNER_ATTESTATION_MISSING" | "ACP_OWNER_ATTESTATION_TIMEOUT" => {
            "Collect required attestations and quorum evidence bound to the same plan/evidence hashes."
                .to_string()
        }
        "ACP_TELEMETRY_PROFILE_MISSING" | "ACP_TELEMETRY_PROFILE_INVALID" => {
            "Set an ACP-allowed telemetry_profile and rerun receipt validation.".to_string()
        }
        "ACP_FLAG_METADATA_EVIDENCE_MISSING" | "ACP_FLAG_METADATA_INVALID" => {
            "Attach validated flag metadata evidence and set flag_metadata_valid=true only on pass."
                .to_string()
        }
        "ACP_BUDGET_SET_MISSING" | "ACP_BUDGET_EXCEEDED" => {
            "Reduce promotion scope or update budget policy with explicit approval.".to_string()
        }
        "ACP_CIRCUIT_BREAKER_TRIPPED" | "ACP_CIRCUIT_BREAKER_INVALID_ACTION" => {
            "Investigate breaker trigger/action, remediate, and rerun ACP enforcement.".to_string()
        }
        "ACP_KILLSWITCH_ACTIVE" => {
            "Resolve active kill-switch conditions before attempting promotion or finalize."
                .to_string()
        }
        "ACP_STAGE_ONLY_REQUIRED" => {
            "Keep execution staged and satisfy all missing requirements before promote.".to_string()
        }
        "ACP_ESCALATE_POLICY" => {
            "Escalate this run with receipt and digest evidence to the designated owner path."
                .to_string()
        }
        "RA_BREAK_GLASS_REQUIRED" => {
            "Use a reversible path or provide explicit break-glass evidence for ACP-4 actions."
                .to_string()
        }
        _ => format!("Resolve {code} using the policy reason-code catalog and rerun ACP evaluation."),
    }
}

fn build_acp_remediation(
    decision: &AcpDecisionKind,
    reason_codes: &[String],
) -> (String, Vec<String>) {
    let fallback = default_remediation_for_decision(decision).to_string();
    if reason_codes.is_empty() {
        return (fallback.clone(), vec![fallback]);
    }

    let remediation_steps: Vec<String> = reason_codes
        .iter()
        .map(|code| remediation_for_reason_code(code))
        .collect();

    let summary = remediation_steps
        .first()
        .cloned()
        .unwrap_or_else(|| fallback.clone());

    (summary, remediation_steps)
}

fn acp_level_rank(level: &str) -> usize {
    match level.trim().to_uppercase().as_str() {
        "ACP-0" => 0,
        "ACP-1" => 1,
        "ACP-2" => 2,
        "ACP-3" => 3,
        "ACP-4" => 4,
        _ => 0,
    }
}

fn normalize_ref(value: &str, prefix: &str) -> String {
    value
        .trim()
        .strip_prefix(prefix)
        .unwrap_or(value.trim())
        .to_string()
}

fn find_matching_acp_rule<'a>(
    policy: &'a PolicyV2,
    operation_class: &str,
    phase: &str,
    target: &HashMap<String, Value>,
) -> Option<&'a AcpRule> {
    policy.acp.rules.iter().find(|rule| {
        if !rule.r#match.class.contains_value(operation_class) {
            return false;
        }
        if !rule.r#match.phase.is_empty()
            && !rule
                .r#match
                .phase
                .iter()
                .any(|candidate| candidate.eq_ignore_ascii_case(phase))
        {
            return false;
        }

        let Some(match_target) = rule.r#match.target.as_ref() else {
            return true;
        };

        match_target.iter().all(|(key, expected)| {
            let actual = target.get(key);
            target_value_matches(expected, actual)
        })
    })
}

fn target_value_matches(expected: &Value, actual: Option<&Value>) -> bool {
    let Some(actual_value) = actual else {
        return false;
    };

    match expected {
        Value::String(text) => target_contains(actual_value, text),
        Value::Array(values) => values
            .iter()
            .filter_map(value_to_string)
            .any(|candidate| target_contains(actual_value, &candidate)),
        _ => false,
    }
}

fn target_contains(actual: &Value, expected: &str) -> bool {
    match actual {
        Value::String(text) => text == expected,
        Value::Array(values) => values
            .iter()
            .filter_map(value_to_string)
            .any(|candidate| candidate == expected),
        _ => false,
    }
}

fn value_to_string(value: &Value) -> Option<String> {
    value.as_str().map(|text| text.to_string())
}

fn value_to_bool(value: &Value) -> Option<bool> {
    match value {
        Value::Bool(flag) => Some(*flag),
        Value::Number(number) => number.as_i64().map(|raw| raw != 0),
        Value::String(text) => {
            let normalized = text.trim().to_ascii_lowercase();
            match normalized.as_str() {
                "1" | "true" | "yes" | "on" => Some(true),
                "0" | "false" | "no" | "off" => Some(false),
                _ => None,
            }
        }
        _ => None,
    }
}

fn target_flag_is_truthy(value: Option<&Value>) -> bool {
    value.and_then(value_to_bool).unwrap_or(false)
}

fn target_u64(value: Option<&Value>) -> Option<u64> {
    match value {
        Some(Value::Number(number)) => number.as_u64(),
        Some(Value::String(text)) => text.trim().parse::<u64>().ok(),
        _ => None,
    }
}

fn push_reason(reason_codes: &mut Vec<String>, reason_seen: &mut HashSet<String>, code: &str) {
    if reason_seen.insert(code.to_string()) {
        reason_codes.push(code.to_string());
    }
}

fn validate_reversibility(
    policy: &PolicyV2,
    request: &AcpRequest,
    rule: &AcpRule,
    requirements: &mut AcpMissingRequirements,
    reason_codes: &mut Vec<String>,
    reason_seen: &mut HashSet<String>,
) {
    let Some(reversibility) = request.reversibility.as_ref() else {
        requirements
            .missing_reversibility
            .push("reversibility".to_string());
        push_reason(reason_codes, reason_seen, "ACP_REVERSIBILITY_REQUIRED");
        return;
    };

    if !reversibility.reversible {
        requirements
            .missing_reversibility
            .push("reversible=true".to_string());
        push_reason(reason_codes, reason_seen, "ACP_REVERSIBILITY_REQUIRED");
    }

    if reversibility
        .rollback_handle
        .as_deref()
        .unwrap_or_default()
        .trim()
        .is_empty()
    {
        requirements
            .missing_reversibility
            .push("rollback_handle".to_string());
        push_reason(reason_codes, reason_seen, "ACP_ROLLBACK_HANDLE_MISSING");
    }

    if let Some(required) = rule
        .require
        .reversibility
        .as_ref()
        .and_then(|value| value.primitive.as_ref())
    {
        if reversibility.primitive.as_deref() != Some(required.as_str()) {
            requirements
                .missing_reversibility
                .push(format!("primitive:{required}"));
            push_reason(reason_codes, reason_seen, "ACP_REVERSIBILITY_REQUIRED");
        }
    }

    if reversibility
        .recovery_window
        .as_deref()
        .unwrap_or_default()
        .trim()
        .is_empty()
    {
        let primitive_default = reversibility
            .primitive
            .as_ref()
            .and_then(|name| policy.reversibility.primitives.get(name))
            .and_then(|value| value.default_recovery_window.as_ref());
        let rule_default = rule
            .require
            .reversibility
            .as_ref()
            .and_then(|value| value.recovery_window_default.as_ref());
        if primitive_default.is_none() && rule_default.is_none() {
            requirements
                .missing_reversibility
                .push("recovery_window".to_string());
            push_reason(reason_codes, reason_seen, "ACP_RECOVERY_WINDOW_MISSING");
        }
    }

    let rollback_proof_required = rule
        .require
        .reversibility
        .as_ref()
        .map(|value| value.rollback_proof_required)
        .unwrap_or(false);
    if rollback_proof_required {
        let has_rollback_proof = reversibility
            .rollback_proof
            .as_deref()
            .is_some_and(|value| !value.trim().is_empty())
            || request
                .evidence
                .iter()
                .any(|item| matches!(item.r#type.as_str(), "rollback_test" | "rollback_proof"));
        if !has_rollback_proof {
            requirements
                .missing_reversibility
                .push("rollback_proof".to_string());
            push_reason(reason_codes, reason_seen, "ACP_ROLLBACK_PROOF_MISSING");
        }
    }
}

fn validate_evidence(
    request: &AcpRequest,
    rule: &AcpRule,
    requirements: &mut AcpMissingRequirements,
    reason_codes: &mut Vec<String>,
    reason_seen: &mut HashSet<String>,
) {
    let present: HashSet<String> = request
        .evidence
        .iter()
        .map(|entry| entry.r#type.clone())
        .collect();

    for required in &rule.require.evidence_required {
        if !present.contains(required) {
            requirements.missing_evidence.push(required.clone());
        }
    }

    if !requirements.missing_evidence.is_empty() {
        push_reason(reason_codes, reason_seen, "ACP_EVIDENCE_MISSING");
    }

    let invalid = request.evidence.iter().any(|entry| {
        entry.r#ref.trim().is_empty()
            || !entry
                .sha256
                .as_deref()
                .is_some_and(|value| !value.trim().is_empty())
    });
    if invalid {
        push_reason(reason_codes, reason_seen, "ACP_EVIDENCE_INVALID");
    }
}

fn resolve_material_side_effect(
    policy: &PolicyV2,
    target: &HashMap<String, Value>,
    phase: &str,
    reason_codes: &mut Vec<String>,
    reason_seen: &mut HashSet<String>,
    notes: &mut Vec<String>,
) -> bool {
    let config = policy
        .acp
        .materiality
        .clone()
        .unwrap_or_else(default_materiality_config);
    let canonical = if config.target_fields.canonical.trim().is_empty() {
        "material_side_effect"
    } else {
        config.target_fields.canonical.trim()
    };

    let enforce_on: Vec<String> = if config.enforce_on_phase.is_empty() {
        vec!["promote".to_string(), "finalize".to_string()]
    } else {
        config
            .enforce_on_phase
            .iter()
            .map(|entry| entry.trim().to_ascii_lowercase())
            .collect()
    };
    if !enforce_on.iter().any(|candidate| candidate == phase) {
        return true;
    }

    let mut fields = vec![canonical.to_string()];
    fields.extend(config.target_fields.aliases.iter().cloned());

    let mut detected: Vec<(String, bool)> = Vec::new();
    for field in fields {
        if let Some(value) = target.get(&field) {
            if let Some(parsed) = value_to_bool(value) {
                detected.push((field.clone(), parsed));
                continue;
            }
            push_reason(
                reason_codes,
                reason_seen,
                "ACP_MATERIAL_SIDE_EFFECT_INVALID",
            );
            notes.push(format!(
                "materiality field '{field}' must be boolean-compatible for predicate '{canonical}'"
            ));
            return true;
        }
    }

    if detected.is_empty() {
        return match phase {
            "promote" => config.default_for_phase.promote,
            "finalize" => config.default_for_phase.finalize,
            _ => true,
        };
    }

    let first = detected[0].1;
    let conflict = detected.iter().any(|(_, value)| *value != first);
    if conflict {
        push_reason(
            reason_codes,
            reason_seen,
            "ACP_MATERIAL_SIDE_EFFECT_INVALID",
        );
        notes.push(format!(
            "conflicting materiality aliases detected for predicate '{canonical}'"
        ));
        return true;
    }

    if detected[0].0 != canonical {
        notes.push(format!(
            "materiality alias '{}' normalized to canonical predicate '{}'",
            detected[0].0, canonical
        ));
    }

    first
}

fn gate_action_for_acp(
    missing_action_by_acp: &HashMap<String, String>,
    effective_acp: &str,
    fallback: AcpDecisionKind,
) -> AcpDecisionKind {
    let action = missing_action_by_acp
        .get(&effective_acp.to_ascii_uppercase())
        .or_else(|| missing_action_by_acp.get("default"))
        .map(|value| parse_acp_decision(value))
        .unwrap_or(fallback);

    match action {
        AcpDecisionKind::Allow => AcpDecisionKind::StageOnly,
        other => other,
    }
}

fn validate_docs_gate(
    policy: &PolicyV2,
    request: &AcpRequest,
    phase: &str,
    effective_acp: &str,
    material_side_effect: bool,
    requirements: &mut AcpMissingRequirements,
    reason_codes: &mut Vec<String>,
    reason_seen: &mut HashSet<String>,
    notes: &mut Vec<String>,
) -> Option<AcpDecisionKind> {
    let Some(config) = policy.acp.docs_gate.as_ref() else {
        return None;
    };
    if !material_side_effect {
        return None;
    }

    let enforce_on: Vec<String> = if config.enforce_on_phase.is_empty() {
        vec!["promote".to_string()]
    } else {
        config
            .enforce_on_phase
            .iter()
            .map(|item| item.trim().to_ascii_lowercase())
            .collect()
    };
    if !enforce_on.iter().any(|candidate| candidate == phase) {
        return None;
    }

    let required_types: Vec<String> = if config.evidence_types.is_empty() {
        vec![
            "docs.spec".to_string(),
            "docs.adr".to_string(),
            "docs.runbook".to_string(),
        ]
    } else {
        config.evidence_types.clone()
    };

    let present: HashSet<String> = request
        .evidence
        .iter()
        .map(|entry| entry.r#type.clone())
        .collect();
    let missing: Vec<String> = required_types
        .iter()
        .filter(|required| !present.contains(required.as_str()))
        .cloned()
        .collect();
    if missing.is_empty() {
        return None;
    }

    for entry in &missing {
        if !requirements
            .missing_evidence
            .iter()
            .any(|item| item == entry)
        {
            requirements.missing_evidence.push(entry.clone());
        }
    }

    push_reason(reason_codes, reason_seen, "ACP_EVIDENCE_MISSING");
    push_reason(
        reason_codes,
        reason_seen,
        config
            .reason_code
            .as_deref()
            .filter(|value| !value.trim().is_empty())
            .unwrap_or("ACP_DOCS_EVIDENCE_MISSING"),
    );
    notes.push(format!(
        "docs-gate evidence missing for phase='{phase}': {}",
        missing.join(",")
    ));

    Some(gate_action_for_acp(
        &config.missing_action_by_acp,
        effective_acp,
        AcpDecisionKind::StageOnly,
    ))
}

fn validate_telemetry_gate(
    policy: &PolicyV2,
    request: &AcpRequest,
    phase: &str,
    effective_acp: &str,
    material_side_effect: bool,
    requirements: &mut AcpMissingRequirements,
    reason_codes: &mut Vec<String>,
    reason_seen: &mut HashSet<String>,
    notes: &mut Vec<String>,
) -> Option<AcpDecisionKind> {
    let Some(config) = policy.acp.telemetry_gate.as_ref() else {
        return None;
    };
    if !material_side_effect {
        return None;
    }

    let enforce_on: Vec<String> = if config.enforce_on_phase.is_empty() {
        vec!["promote".to_string()]
    } else {
        config
            .enforce_on_phase
            .iter()
            .map(|entry| entry.trim().to_ascii_lowercase())
            .collect()
    };
    if !enforce_on.iter().any(|candidate| candidate == phase) {
        return None;
    }

    if acp_level_rank(effective_acp) < acp_level_rank(&config.required_for_acp_at_or_above) {
        return None;
    }

    let target_field = if config.target_field.trim().is_empty() {
        "telemetry_profile"
    } else {
        config.target_field.trim()
    };
    let telemetry_profile = request
        .operation
        .target
        .get(target_field)
        .and_then(value_to_string)
        .map(|value| value.trim().to_ascii_lowercase())
        .filter(|value| !value.is_empty());
    let missing_reason = if config.reason_codes.missing.trim().is_empty() {
        "ACP_TELEMETRY_PROFILE_MISSING"
    } else {
        config.reason_codes.missing.as_str()
    };
    let invalid_reason = if config.reason_codes.invalid.trim().is_empty() {
        "ACP_TELEMETRY_PROFILE_INVALID"
    } else {
        config.reason_codes.invalid.as_str()
    };

    let Some(profile_value) = telemetry_profile else {
        if !requirements
            .missing_evidence
            .iter()
            .any(|item| item == target_field)
        {
            requirements.missing_evidence.push(target_field.to_string());
        }
        push_reason(reason_codes, reason_seen, missing_reason);
        notes.push(format!(
            "telemetry profile field '{target_field}' missing for ACP '{effective_acp}'"
        ));
        return Some(gate_action_for_acp(
            &config.missing_action_by_acp,
            effective_acp,
            AcpDecisionKind::StageOnly,
        ));
    };

    let allowed_profiles = config
        .allowed_by_acp
        .get(&effective_acp.to_ascii_uppercase())
        .or_else(|| config.allowed_by_acp.get("default"))
        .cloned()
        .unwrap_or_default();
    let is_allowed = allowed_profiles
        .iter()
        .map(|value| value.trim().to_ascii_lowercase())
        .any(|value| value == profile_value);
    if is_allowed {
        return None;
    }

    push_reason(reason_codes, reason_seen, invalid_reason);
    notes.push(format!(
        "telemetry profile '{profile_value}' is not allowed for ACP '{effective_acp}'"
    ));
    Some(gate_action_for_acp(
        &config.missing_action_by_acp,
        effective_acp,
        AcpDecisionKind::Deny,
    ))
}

fn validate_flag_metadata_gate(
    policy: &PolicyV2,
    request: &AcpRequest,
    phase: &str,
    effective_acp: &str,
    material_side_effect: bool,
    requirements: &mut AcpMissingRequirements,
    reason_codes: &mut Vec<String>,
    reason_seen: &mut HashSet<String>,
    notes: &mut Vec<String>,
) -> Option<AcpDecisionKind> {
    let Some(config) = policy.acp.flag_metadata_gate.as_ref() else {
        return None;
    };
    if !material_side_effect {
        return None;
    }

    let enforce_on: Vec<String> = if config.enforce_on_phase.is_empty() {
        vec!["promote".to_string()]
    } else {
        config
            .enforce_on_phase
            .iter()
            .map(|entry| entry.trim().to_ascii_lowercase())
            .collect()
    };
    if !enforce_on.iter().any(|candidate| candidate == phase) {
        return None;
    }

    let required_when_target_flags: Vec<String> = if config.required_when_target_flags.is_empty() {
        vec![
            "has_flags".to_string(),
            "modifies_flags".to_string(),
            "flag_change".to_string(),
        ]
    } else {
        config.required_when_target_flags.clone()
    };
    let triggered = required_when_target_flags
        .iter()
        .any(|flag| target_flag_is_truthy(request.operation.target.get(flag)));
    if !triggered {
        return None;
    }

    let evidence_type = if config.evidence_type.trim().is_empty() {
        "flags.metadata"
    } else {
        config.evidence_type.trim()
    };
    let has_metadata_evidence = request
        .evidence
        .iter()
        .any(|entry| entry.r#type == evidence_type);
    let missing_reason = if config.reason_codes.missing_evidence.trim().is_empty() {
        "ACP_FLAG_METADATA_EVIDENCE_MISSING"
    } else {
        config.reason_codes.missing_evidence.as_str()
    };
    let invalid_reason = if config.reason_codes.invalid.trim().is_empty() {
        "ACP_FLAG_METADATA_INVALID"
    } else {
        config.reason_codes.invalid.as_str()
    };

    if !has_metadata_evidence {
        if !requirements
            .missing_evidence
            .iter()
            .any(|item| item == evidence_type)
        {
            requirements
                .missing_evidence
                .push(evidence_type.to_string());
        }
        push_reason(reason_codes, reason_seen, missing_reason);
        notes.push(format!(
            "flag metadata evidence '{evidence_type}' missing for ACP '{effective_acp}'"
        ));
        return Some(gate_action_for_acp(
            &config.missing_action_by_acp,
            effective_acp,
            AcpDecisionKind::StageOnly,
        ));
    }

    let metadata_field = if config.metadata_valid_field.trim().is_empty() {
        "flag_metadata_valid"
    } else {
        config.metadata_valid_field.trim()
    };
    let metadata_valid = target_flag_is_truthy(request.operation.target.get(metadata_field));
    if metadata_valid {
        return None;
    }

    if !requirements
        .missing_evidence
        .iter()
        .any(|item| item == metadata_field)
    {
        requirements
            .missing_evidence
            .push(metadata_field.to_string());
    }
    push_reason(reason_codes, reason_seen, invalid_reason);
    notes.push(format!(
        "flag metadata validity field '{metadata_field}' missing/false for ACP '{effective_acp}'"
    ));
    Some(gate_action_for_acp(
        &config.missing_action_by_acp,
        effective_acp,
        AcpDecisionKind::Deny,
    ))
}

fn validate_quorum(
    policy: &PolicyV2,
    request: &AcpRequest,
    rule: &AcpRule,
    requirements: &mut AcpMissingRequirements,
    reason_codes: &mut Vec<String>,
    reason_seen: &mut HashSet<String>,
) {
    let Some(quorum_ref) = rule.require.quorum_required.as_ref() else {
        return;
    };
    let quorum_key = normalize_ref(quorum_ref, "quorum.");
    let Some(quorum) = policy.quorum.get(&quorum_key) else {
        requirements
            .missing_attestations
            .push(format!("quorum:{quorum_key}"));
        push_reason(reason_codes, reason_seen, "ACP_QUORUM_MISSING");
        return;
    };

    let required_fields: Vec<&str> = if policy.attestations.required_fields.is_empty() {
        vec!["role", "actor_id", "signature"]
    } else {
        policy
            .attestations
            .required_fields
            .iter()
            .map(String::as_str)
            .collect()
    };
    let mut missing_required_field = false;
    let mut invalid_attestation = false;
    let mut role_mismatch = false;

    for field in &required_fields {
        if !is_known_attestation_required_field(field) {
            invalid_attestation = true;
            requirements
                .missing_attestations
                .push(format!("required_field:{field}"));
        }
    }

    for (index, entry) in request.attestations.iter().enumerate() {
        if !policy.attestations.roles.is_empty()
            && !policy.attestations.roles.contains_key(&entry.role)
        {
            invalid_attestation = true;
            role_mismatch = true;
            requirements
                .missing_attestations
                .push(format!("attestation[{index}].role_unknown"));
        }

        for field in &required_fields {
            if !is_known_attestation_required_field(field) {
                continue;
            }
            let value = attestation_field_value(entry, field);
            let is_missing = value.map_or(true, |candidate| candidate.trim().is_empty());
            if is_missing {
                missing_required_field = true;
                requirements
                    .missing_attestations
                    .push(format!("attestation[{index}].{field}"));
                continue;
            }
            if *field == "timestamp" && !attestation_timestamp_valid(value.unwrap_or_default()) {
                invalid_attestation = true;
                requirements
                    .missing_attestations
                    .push(format!("attestation[{index}].timestamp_format"));
            }
        }
    }

    if missing_required_field {
        push_reason(reason_codes, reason_seen, "ACP_ATTESTATION_FIELD_MISSING");
        push_reason(reason_codes, reason_seen, "ACP_QUORUM_MISSING");
    }
    if invalid_attestation {
        push_reason(reason_codes, reason_seen, "ACP_ATTESTATION_INVALID");
        push_reason(reason_codes, reason_seen, "ACP_QUORUM_INVALID");
    }

    let signatures = request
        .attestations
        .iter()
        .filter(|entry| {
            entry
                .signature
                .as_deref()
                .is_some_and(|value| !value.trim().is_empty())
        })
        .count();
    if signatures < quorum.min_signatures {
        requirements
            .missing_attestations
            .push(format!("signatures:{}", quorum.min_signatures));
    }

    for role in &quorum.required_roles {
        let has_role = request.attestations.iter().any(|entry| {
            entry.role == *role
                && entry
                    .signature
                    .as_deref()
                    .is_some_and(|sig| !sig.trim().is_empty())
        });
        if !has_role {
            role_mismatch = true;
            requirements.missing_attestations.push(role.clone());
        }
    }

    if role_mismatch {
        push_reason(reason_codes, reason_seen, "ACP_ATTESTATION_ROLE_MISMATCH");
    }

    if !requirements.missing_attestations.is_empty() {
        push_reason(reason_codes, reason_seen, "ACP_QUORUM_MISSING");
    }

    let binding = policy
        .attestations
        .binding
        .as_ref()
        .cloned()
        .unwrap_or_default();
    if binding.require_plan_hash {
        let Some(plan_hash) = request.plan_hash.as_ref() else {
            push_reason(reason_codes, reason_seen, "ACP_QUORUM_INVALID");
            requirements
                .missing_attestations
                .push("plan_hash_binding".to_string());
            return;
        };
        if request
            .attestations
            .iter()
            .any(|entry| entry.plan_hash.as_deref() != Some(plan_hash.as_str()))
        {
            push_reason(reason_codes, reason_seen, "ACP_QUORUM_INVALID");
            requirements
                .missing_attestations
                .push("plan_hash_binding".to_string());
        }
    }
    if binding.require_evidence_hash {
        let Some(evidence_hash) = request.evidence_hash.as_ref() else {
            push_reason(reason_codes, reason_seen, "ACP_QUORUM_INVALID");
            requirements
                .missing_attestations
                .push("evidence_hash_binding".to_string());
            return;
        };
        if request
            .attestations
            .iter()
            .any(|entry| entry.evidence_hash.as_deref() != Some(evidence_hash.as_str()))
        {
            push_reason(reason_codes, reason_seen, "ACP_QUORUM_INVALID");
            requirements
                .missing_attestations
                .push("evidence_hash_binding".to_string());
        }
    }
}

fn validate_owner_attestation(
    policy: &PolicyV2,
    request: &AcpRequest,
    effective_acp: &str,
    requirements: &mut AcpMissingRequirements,
    reason_codes: &mut Vec<String>,
    reason_seen: &mut HashSet<String>,
    notes: &mut Vec<String>,
) -> Option<AcpDecisionKind> {
    let Some(config) = policy.attestations.owner_attestation.as_ref() else {
        return None;
    };
    if !config.enabled {
        return None;
    }

    let required_for_level = config
        .required_for_acp
        .iter()
        .any(|level| level.eq_ignore_ascii_case(effective_acp));
    if !required_for_level {
        return None;
    }

    let required_flags: Vec<String> = if config.required_when_target_flags.is_empty() {
        vec![
            "boundary_exception".to_string(),
            "owner_scope".to_string(),
            "owner_attestation_required".to_string(),
        ]
    } else {
        config.required_when_target_flags.clone()
    };
    let triggered = required_flags
        .iter()
        .any(|flag| target_flag_is_truthy(request.operation.target.get(flag)));
    if !triggered {
        return None;
    }

    let owner_role = if config.role.trim().is_empty() {
        "owner".to_string()
    } else {
        config.role.trim().to_string()
    };
    let owner_present = request.attestations.iter().any(|entry| {
        entry.role.eq_ignore_ascii_case(&owner_role)
            && entry
                .signature
                .as_deref()
                .is_some_and(|value| !value.trim().is_empty())
    });
    if owner_present {
        return None;
    }

    if !requirements
        .missing_attestations
        .iter()
        .any(|entry| entry == &owner_role)
    {
        requirements.missing_attestations.push(owner_role.clone());
    }
    push_reason(reason_codes, reason_seen, "ACP_OWNER_ATTESTATION_MISSING");
    push_reason(reason_codes, reason_seen, "ACP_QUORUM_MISSING");

    let timeout_seconds = config.timeout_seconds.max(1);
    let retry_max_attempts = config.retry.max_attempts.max(1);
    let retry_attempt =
        target_u64(request.operation.target.get("owner_attestation_retry")).unwrap_or(0);
    let elapsed_seconds = target_u64(
        request
            .operation
            .target
            .get("owner_attestation_elapsed_seconds"),
    )
    .unwrap_or(0);
    let exhausted = retry_attempt >= retry_max_attempts || elapsed_seconds >= timeout_seconds;

    requirements.owner_attestation = Some(OwnerAttestationRequirement {
        required: true,
        sources: config.sources.clone(),
        timeout_seconds,
        retry_max_attempts,
        retry_attempt,
        exhausted,
    });

    notes.push(format!(
        "owner attestation missing; sources={} retry={}/{} elapsed={}s timeout={}s",
        config.sources.join(","),
        retry_attempt,
        retry_max_attempts,
        elapsed_seconds,
        timeout_seconds
    ));

    if exhausted {
        push_reason(reason_codes, reason_seen, "ACP_OWNER_ATTESTATION_TIMEOUT");
        if config.escalate_on_exhausted {
            push_reason(reason_codes, reason_seen, "ACP_ESCALATE_POLICY");
            return Some(AcpDecisionKind::Escalate);
        }
    }

    Some(AcpDecisionKind::StageOnly)
}

fn validate_budgets(
    policy: &PolicyV2,
    request: &AcpRequest,
    rule: &AcpRule,
    requirements: &mut AcpMissingRequirements,
    reason_codes: &mut Vec<String>,
    reason_seen: &mut HashSet<String>,
) {
    let Some(budget_ref) = rule.require.budget_set.as_ref() else {
        return;
    };
    let budget_key = normalize_ref(budget_ref, "budgets.");
    let Some(budget_set) = policy.budgets.get(&budget_key) else {
        push_reason(reason_codes, reason_seen, "ACP_BUDGET_SET_MISSING");
        return;
    };

    for (metric, limit) in budget_set {
        let counter = request.counters.get(metric).copied().unwrap_or(0.0);
        if counter > *limit {
            requirements
                .budget_exceeded
                .insert(metric.clone(), counter - *limit);
        } else {
            requirements
                .budget_remaining
                .insert(metric.clone(), (*limit - counter).max(0.0));
        }
    }

    if !requirements.budget_exceeded.is_empty() {
        push_reason(reason_codes, reason_seen, "ACP_BUDGET_EXCEEDED");
    }
}

fn evaluate_circuit_breaker_actions(
    policy: &PolicyV2,
    request: &AcpRequest,
    rule: &AcpRule,
    requirements: &AcpMissingRequirements,
) -> Vec<String> {
    let Some(breaker_ref) = rule.require.circuit_breaker_set.as_ref() else {
        return Vec::new();
    };
    let breaker_key = normalize_ref(breaker_ref, "circuit_breakers.");
    let Some(breaker_set) = policy.circuit_breakers.get(&breaker_key) else {
        return Vec::new();
    };

    let mut seen = HashSet::new();
    let mut actions = Vec::new();

    for trigger in &breaker_set.triggers {
        let threshold = trigger.threshold.max(1);
        let mut signal_count = request
            .circuit_signals
            .iter()
            .filter(|signal| *signal == &trigger.signal)
            .count() as u64;
        if trigger.signal == "budget.exceeded" && !requirements.budget_exceeded.is_empty() {
            signal_count = threshold;
        }
        if signal_count < threshold {
            continue;
        }

        let raw_action = if trigger.action.trim().is_empty() {
            "stop_and_stage_only"
        } else {
            trigger.action.trim()
        };
        let action = normalize_breaker_action(raw_action)
            .unwrap_or_else(|| format!("invalid_action:{raw_action}"));

        if seen.insert(action.clone()) {
            actions.push(action);
        }
    }

    actions
}

fn normalize_breaker_action(action: &str) -> Option<String> {
    let normalized = action.trim().to_ascii_lowercase();
    match normalized.as_str() {
        "" | "stop_and_stage_only" => Some("stop_and_stage_only".to_string()),
        "auto_rollback_and_trip_killswitch" => {
            Some("auto_rollback_and_trip_killswitch".to_string())
        }
        "rollback_and_trip_killswitch" => Some("rollback_and_trip_killswitch".to_string()),
        "halt_and_notify" | "deny_and_escalate" => Some("halt_and_notify".to_string()),
        _ => None,
    }
}

fn is_known_attestation_required_field(field: &str) -> bool {
    matches!(
        field.trim(),
        "role" | "actor_id" | "timestamp" | "plan_hash" | "evidence_hash" | "signature"
    )
}

fn attestation_field_value<'a>(entry: &'a AcpAttestation, field: &str) -> Option<&'a str> {
    match field.trim() {
        "role" => Some(entry.role.as_str()),
        "actor_id" => Some(entry.actor_id.as_str()),
        "timestamp" => entry.timestamp.as_deref(),
        "plan_hash" => entry.plan_hash.as_deref(),
        "evidence_hash" => entry.evidence_hash.as_deref(),
        "signature" => entry.signature.as_deref(),
        _ => None,
    }
}

fn attestation_timestamp_valid(value: &str) -> bool {
    let timestamp = value.trim();
    if timestamp.is_empty() {
        return false;
    }
    timestamp.contains('T') && (timestamp.ends_with('Z') || timestamp.contains('+'))
}

fn rule_targets_protected_scope(target: Option<&HashMap<String, Value>>) -> bool {
    let Some(target) = target else {
        return false;
    };

    target.iter().any(|(key, expected)| {
        let key_normalized = key.trim().to_ascii_lowercase();
        if !matches!(
            key_normalized.as_str(),
            "branch" | "branches" | "environment" | "path" | "service" | "resource" | "target"
        ) {
            return false;
        }
        value_contains_protected_scope_markers(expected)
    })
}

fn value_contains_protected_scope_markers(value: &Value) -> bool {
    match value {
        Value::String(raw) => {
            let normalized = raw.trim().to_ascii_lowercase();
            matches!(
                normalized.as_str(),
                "main" | "master" | "prod" | "production" | "release" | "stable" | "protected"
            ) || normalized.contains("protected")
        }
        Value::Array(items) => items.iter().any(value_contains_protected_scope_markers),
        Value::Object(map) => map.values().any(value_contains_protected_scope_markers),
        _ => false,
    }
}

pub fn evaluate_grant(request: &GrantEvalRequest) -> Result<GrantEvalResult> {
    let policy = load_policy(&request.policy_path)
        .with_context(|| format!("failed to load policy {}", request.policy_path.display()))?;

    let tier = request.tier.to_lowercase();
    if !matches!(tier.as_str(), "low" | "medium" | "high") {
        return Ok(GrantEvalResult {
            allow: false,
            tier,
            mode: policy.mode,
            deny: Some(make_deny(
                "DDB022_GRANT_TIER_REVIEW_REQUIRED",
                "Invalid grant tier",
                "grant",
                "request",
                None,
                None,
                "Use low, medium, or high tier",
                None,
            )),
            effective_ttl_seconds: None,
            notes: Vec::new(),
        });
    }

    for token in &request.requested_tools {
        if !is_known_tool_token(token) {
            return Ok(GrantEvalResult {
                allow: false,
                tier,
                mode: policy.mode,
                deny: Some(make_deny(
                    "DDB003_UNKNOWN_TOOL_TOKEN",
                    "Grant request contains unknown tool token",
                    "grant",
                    "request",
                    None,
                    Some(token.clone()),
                    "Use approved tool tokens only",
                    None,
                )),
                effective_ttl_seconds: None,
                notes: Vec::new(),
            });
        }
    }

    if request
        .requested_write_scopes
        .iter()
        .any(|scope| scope.contains("**"))
    {
        return Ok(GrantEvalResult {
            allow: false,
            tier,
            mode: policy.mode,
            deny: Some(make_deny(
                "DDB021_GRANT_SCOPE_TOO_BROAD",
                "Grant request includes broad write scope",
                "grant",
                "request",
                None,
                None,
                "Request minimal write scopes without recursive wildcard",
                None,
            )),
            effective_ttl_seconds: None,
            notes: Vec::new(),
        });
    }

    if policy.grants.require_provenance
        && (request.request_id.is_none()
            || request.agent_id.is_none()
            || request.plan_step_id.is_none())
    {
        return Ok(GrantEvalResult {
            allow: false,
            tier,
            mode: policy.mode,
            deny: Some(make_deny(
                "DDB013_AGENT_ID_MISSING",
                "Grant request missing provenance metadata",
                "grant",
                "request",
                None,
                None,
                "Provide request_id, agent_id, and plan_step_id",
                None,
            )),
            effective_ttl_seconds: None,
            notes: Vec::new(),
        });
    }

    let requested_ttl = request
        .requested_ttl_seconds
        .unwrap_or(policy.grants.default_ttl_seconds);
    let max_ttl = match tier.as_str() {
        "low" => policy.grants.max_ttl_seconds_by_tier.low,
        "medium" => policy.grants.max_ttl_seconds_by_tier.medium,
        "high" => policy.grants.max_ttl_seconds_by_tier.high,
        _ => policy.grants.default_ttl_seconds,
    };

    if requested_ttl > max_ttl {
        return Ok(GrantEvalResult {
            allow: false,
            tier,
            mode: policy.mode,
            deny: Some(make_deny(
                "DDB021_GRANT_SCOPE_TOO_BROAD",
                "Requested grant TTL exceeds policy maximum",
                "grant",
                "request",
                None,
                None,
                "Request a shorter TTL or lower-risk scope",
                None,
            )),
            effective_ttl_seconds: None,
            notes: Vec::new(),
        });
    }

    if (tier == "medium" || tier == "high") && !request.has_review_evidence {
        return Ok(GrantEvalResult {
            allow: false,
            tier,
            mode: policy.mode,
            deny: Some(make_deny(
                "DDB022_GRANT_TIER_REVIEW_REQUIRED",
                "Medium/high grants require review evidence",
                "grant",
                "request",
                None,
                None,
                "Attach review evidence or use low-risk profile",
                None,
            )),
            effective_ttl_seconds: None,
            notes: Vec::new(),
        });
    }

    if tier == "high" && !request.has_quorum_evidence {
        return Ok(GrantEvalResult {
            allow: false,
            tier,
            mode: policy.mode,
            deny: Some(make_deny(
                "DDB022_GRANT_TIER_REVIEW_REQUIRED",
                "High-risk grants require quorum evidence",
                "grant",
                "request",
                None,
                None,
                "Attach quorum evidence for high-risk grant",
                None,
            )),
            effective_ttl_seconds: None,
            notes: Vec::new(),
        });
    }

    let auto_grant_enabled = match tier.as_str() {
        "low" => policy.grants.allow_auto_grant_low,
        "medium" => policy.grants.allow_auto_grant_medium,
        "high" => policy.grants.allow_auto_grant_high,
        _ => false,
    };

    if !auto_grant_enabled {
        return Ok(GrantEvalResult {
            allow: false,
            tier,
            mode: policy.mode,
            deny: Some(make_deny(
                "DDB022_GRANT_TIER_REVIEW_REQUIRED",
                "Auto-grant disabled for requested tier",
                "grant",
                "request",
                None,
                None,
                "Use explicit review/quorum grant path",
                None,
            )),
            effective_ttl_seconds: None,
            notes: Vec::new(),
        });
    }

    Ok(GrantEvalResult {
        allow: true,
        tier,
        mode: policy.mode,
        deny: None,
        effective_ttl_seconds: Some(requested_ttl),
        notes: vec!["grant-policy-pass".to_string()],
    })
}

pub fn doctor(request: &DoctorRequest) -> Result<DoctorReport> {
    let schema_json = load_json_value(&request.schema_path)?;
    let policy_yaml = load_yaml_value(&request.policy_path)?;

    let compiled = JSONSchema::compile(&schema_json)
        .map_err(|err| anyhow!("failed to compile schema: {err}"))?;

    let mut schema_errors = Vec::new();
    if let Err(errors) = compiled.validate(&policy_yaml) {
        for err in errors {
            schema_errors.push(err.to_string());
        }
    }

    let mut semantic_errors = Vec::new();
    let mut warnings = Vec::new();

    let policy_typed: Option<PolicyV2> = if schema_errors.is_empty() {
        match load_policy(&request.policy_path) {
            Ok(policy) => Some(policy),
            Err(err) => {
                semantic_errors.push(format!("failed to parse typed policy: {err}"));
                None
            }
        }
    } else {
        None
    };

    if let Some(policy) = &policy_typed {
        if !policy
            .exceptions
            .state_file
            .starts_with(".octon/capabilities/_ops/state/")
        {
            semantic_errors.push(
                "exceptions.state_file must remain under .octon/capabilities/_ops/state/"
                    .to_string(),
            );
        }

        if !policy
            .grants
            .state_dir
            .starts_with(".octon/capabilities/_ops/state/")
        {
            semantic_errors.push(
                "grants.state_dir must remain under .octon/capabilities/_ops/state/".to_string(),
            );
        }

        if !policy
            .kill_switch
            .state_dir
            .starts_with(".octon/capabilities/_ops/state/")
        {
            semantic_errors.push(
                "kill_switch.state_dir must remain under .octon/capabilities/_ops/state/"
                    .to_string(),
            );
        }

        for (name, override_type) in [
            ("waivers", policy.governance_overrides.waivers.as_ref()),
            (
                "exceptions",
                policy.governance_overrides.exceptions.as_ref(),
            ),
        ] {
            let Some(override_cfg) = override_type else {
                semantic_errors.push(format!(
                    "governance_overrides.{name} must be configured in policy"
                ));
                continue;
            };
            if !override_cfg
                .state_file
                .starts_with(".octon/capabilities/_ops/state/")
            {
                semantic_errors.push(format!(
                    "governance_overrides.{name}.state_file must remain under .octon/capabilities/_ops/state/"
                ));
            }
            if override_cfg.required_fields.is_empty() {
                semantic_errors.push(format!(
                    "governance_overrides.{name}.required_fields must be non-empty"
                ));
            }
            if !override_cfg.require_receipt {
                semantic_errors.push(format!(
                    "governance_overrides.{name}.require_receipt must be true"
                ));
            }
        }

        if policy.flags_metadata.contract_file.trim().is_empty() {
            semantic_errors.push("flags_metadata.contract_file must be configured".to_string());
        }
        if policy.flags_metadata.schema_file.trim().is_empty() {
            semantic_errors.push("flags_metadata.schema_file must be configured".to_string());
        }
        if policy.flags_metadata.required_fields.is_empty() {
            semantic_errors.push(
                "flags_metadata.required_fields must declare required metadata fields".to_string(),
            );
        }

        if policy.grants.max_ttl_seconds_by_tier.low < policy.grants.max_ttl_seconds_by_tier.medium
            || policy.grants.max_ttl_seconds_by_tier.medium
                < policy.grants.max_ttl_seconds_by_tier.high
        {
            semantic_errors
                .push("max_ttl_seconds_by_tier must satisfy low >= medium >= high".to_string());
        }

        for (profile_id, profile) in &policy.profiles {
            if profile
                .write_scope_bundle
                .iter()
                .any(|scope| scope.contains("**"))
            {
                warnings.push(format!(
                    "profile '{profile_id}' includes broad write scope; prefer explicit subpaths"
                ));
            }
        }

        let mut declared_levels: HashSet<String> = policy
            .acp
            .levels
            .iter()
            .map(|level| level.id.to_ascii_uppercase())
            .collect();
        declared_levels.insert("ACP-0".to_string());
        declared_levels.insert("ACP-1".to_string());
        declared_levels.insert("ACP-2".to_string());
        declared_levels.insert("ACP-3".to_string());
        declared_levels.insert("ACP-4".to_string());

        let low_level = policy
            .acp
            .risk_tier_mapping
            .get("low")
            .cloned()
            .unwrap_or_else(default_acp_level_one);
        let medium_level = policy
            .acp
            .risk_tier_mapping
            .get("medium")
            .cloned()
            .unwrap_or_else(default_acp_level_one);
        let high_level = policy
            .acp
            .risk_tier_mapping
            .get("high")
            .cloned()
            .unwrap_or_else(default_acp_level_one);

        if acp_level_rank(&low_level) > acp_level_rank(&medium_level)
            || acp_level_rank(&medium_level) > acp_level_rank(&high_level)
        {
            semantic_errors.push(
                "acp.risk_tier_mapping must satisfy low <= medium <= high ACP levels".to_string(),
            );
        }
        if acp_level_rank(&high_level) > acp_level_rank("ACP-3") {
            semantic_errors.push(
                "acp.risk_tier_mapping.high must not exceed ACP-3 for routine autonomy".to_string(),
            );
        }
        for (tier, level) in &policy.acp.risk_tier_mapping {
            if !declared_levels.contains(&level.to_ascii_uppercase()) {
                semantic_errors.push(format!(
                    "acp.risk_tier_mapping.{tier} references undeclared ACP level '{level}'"
                ));
            }
        }

        let expected_modes = ["observe", "iterate", "operate", "emergency"];
        for mode_name in expected_modes {
            if !policy.acp.operating_modes.contains_key(mode_name) {
                semantic_errors.push(format!(
                    "acp.operating_modes.{mode_name} must be configured"
                ));
            }
        }

        let mut referenced_evidence_contracts: BTreeSet<String> = BTreeSet::new();
        for (mode_name, mode) in &policy.acp.operating_modes {
            if !declared_levels.contains(&mode.acp_ceiling.to_ascii_uppercase()) {
                semantic_errors.push(format!(
                    "acp.operating_modes.{mode_name}.acp_ceiling references undeclared ACP level '{}'",
                    mode.acp_ceiling
                ));
            }
            if mode.required_evidence_contract.trim().is_empty() {
                semantic_errors.push(format!(
                    "acp.operating_modes.{mode_name}.required_evidence_contract must be non-empty"
                ));
            }
            if mode.escalation_path.trim().is_empty() {
                semantic_errors.push(format!(
                    "acp.operating_modes.{mode_name}.escalation_path must be non-empty"
                ));
            }

            let contract_id = mode.required_evidence_contract.trim();
            if !contract_id.is_empty() {
                referenced_evidence_contracts.insert(contract_id.to_string());
                if !policy.acp.evidence_contracts.contains_key(contract_id) {
                    semantic_errors.push(format!(
                        "acp.operating_modes.{mode_name}.required_evidence_contract references unknown contract '{contract_id}'"
                    ));
                }
            }
        }

        for (contract_id, contract) in &policy.acp.evidence_contracts {
            if contract.required_evidence.is_empty() {
                semantic_errors.push(format!(
                    "acp.evidence_contracts.{contract_id}.required_evidence must declare at least one evidence type"
                ));
            }
            if contract.remediation.trim().is_empty() {
                semantic_errors.push(format!(
                    "acp.evidence_contracts.{contract_id}.remediation must be non-empty"
                ));
            }
            if !referenced_evidence_contracts.contains(contract_id) {
                warnings.push(format!(
                    "acp.evidence_contracts.{contract_id} is not referenced by any operating mode"
                ));
            }
        }

        let mut required_profile_ids: BTreeSet<String> = BTreeSet::new();
        for profile_id in policy.profiles.keys() {
            required_profile_ids.insert(profile_id.to_string());
        }
        for profile_id in policy.acp.profile_defaults.keys() {
            required_profile_ids.insert(profile_id.to_string());
        }
        for profile_id in &required_profile_ids {
            let Some(mode_name) = policy.acp.profile_mode_map.get(profile_id) else {
                semantic_errors.push(format!(
                    "acp.profile_mode_map.{profile_id} must be configured"
                ));
                continue;
            };

            let Some(mode_cfg) = policy.acp.operating_modes.get(mode_name) else {
                semantic_errors.push(format!(
                    "acp.profile_mode_map.{profile_id} references unknown mode '{mode_name}'"
                ));
                continue;
            };

            let Some(profile_default) = policy.acp.profile_defaults.get(profile_id) else {
                semantic_errors.push(format!(
                    "acp.profile_defaults.{profile_id} must be configured"
                ));
                continue;
            };

            if profile_default.ceiling != mode_cfg.acp_ceiling {
                semantic_errors.push(format!(
                    "profile '{profile_id}' ceiling mismatch: profile_defaults='{}' mode '{}' ceiling='{}'",
                    profile_default.ceiling, mode_name, mode_cfg.acp_ceiling
                ));
            }
        }

        for profile_id in policy.acp.profile_mode_map.keys() {
            if !required_profile_ids.contains(profile_id) {
                warnings.push(format!(
                    "acp.profile_mode_map.{profile_id} does not correspond to a declared profile or profile_default"
                ));
            }
        }

        if let Some(docs_gate) = &policy.acp.docs_gate {
            if docs_gate.evidence_types.is_empty() {
                semantic_errors.push(
                    "acp.docs_gate.evidence_types must declare at least one evidence type"
                        .to_string(),
                );
            }
            if docs_gate.enforce_on_phase.is_empty() {
                semantic_errors.push(
                    "acp.docs_gate.enforce_on_phase must declare at least one ACP phase"
                        .to_string(),
                );
            }
            if let Some(code) = docs_gate.reason_code.as_deref() {
                if !code.starts_with("ACP_") {
                    semantic_errors
                        .push("acp.docs_gate.reason_code must start with ACP_".to_string());
                }
            }
        }

        if let Some(materiality) = &policy.acp.materiality {
            if materiality.predicate_name != "material_side_effect" {
                semantic_errors.push(
                    "acp.materiality.predicate_name must be material_side_effect".to_string(),
                );
            }
            if materiality.target_fields.canonical != "material_side_effect" {
                semantic_errors.push(
                    "acp.materiality.target_fields.canonical must be material_side_effect"
                        .to_string(),
                );
            }
            if materiality.enforce_on_phase.is_empty() {
                semantic_errors.push(
                    "acp.materiality.enforce_on_phase must declare at least one phase".to_string(),
                );
            }
        }

        if let Some(telemetry_gate) = &policy.acp.telemetry_gate {
            if telemetry_gate.target_field.trim().is_empty() {
                semantic_errors
                    .push("acp.telemetry_gate.target_field must be non-empty".to_string());
            }
            if telemetry_gate.allowed_by_acp.is_empty() {
                semantic_errors
                    .push("acp.telemetry_gate.allowed_by_acp must be non-empty".to_string());
            }
            if !telemetry_gate.reason_codes.missing.starts_with("ACP_") {
                semantic_errors.push(
                    "acp.telemetry_gate.reason_codes.missing must start with ACP_".to_string(),
                );
            }
            if !telemetry_gate.reason_codes.invalid.starts_with("ACP_") {
                semantic_errors.push(
                    "acp.telemetry_gate.reason_codes.invalid must start with ACP_".to_string(),
                );
            }
        }

        if let Some(flag_gate) = &policy.acp.flag_metadata_gate {
            if flag_gate.evidence_type.trim().is_empty() {
                semantic_errors
                    .push("acp.flag_metadata_gate.evidence_type must be non-empty".to_string());
            }
            if flag_gate.metadata_valid_field.trim().is_empty() {
                semantic_errors.push(
                    "acp.flag_metadata_gate.metadata_valid_field must be non-empty".to_string(),
                );
            }
            if !flag_gate.reason_codes.missing_evidence.starts_with("ACP_") {
                semantic_errors.push(
                    "acp.flag_metadata_gate.reason_codes.missing_evidence must start with ACP_"
                        .to_string(),
                );
            }
            if !flag_gate.reason_codes.invalid.starts_with("ACP_") {
                semantic_errors.push(
                    "acp.flag_metadata_gate.reason_codes.invalid must start with ACP_".to_string(),
                );
            }
        }

        if let Some(owner) = &policy.attestations.owner_attestation {
            if owner.enabled && owner.sources.is_empty() {
                semantic_errors.push(
                    "attestations.owner_attestation.sources must be non-empty when enabled"
                        .to_string(),
                );
            }
            if owner.enabled && owner.retry.max_attempts == 0 {
                semantic_errors.push(
                    "attestations.owner_attestation.retry.max_attempts must be >= 1".to_string(),
                );
            }
            if owner.enabled && owner.timeout_seconds == 0 {
                semantic_errors.push(
                    "attestations.owner_attestation.timeout_seconds must be >= 1".to_string(),
                );
            }
        }

        if let Some(reason_codes_path) = &request.reason_codes_path {
            let known_codes = load_reason_codes(reason_codes_path)?;
            for (profile_id, profile) in &policy.profiles {
                for code in &profile.deny_rules {
                    if !known_codes.contains(code) {
                        semantic_errors.push(format!(
                            "profile '{profile_id}' references unknown reason code '{code}'"
                        ));
                    }
                }
            }

            if let Some(docs_gate) = &policy.acp.docs_gate {
                if let Some(code) = docs_gate.reason_code.as_deref() {
                    if !code.trim().is_empty() && !known_codes.contains(code) {
                        semantic_errors.push(format!(
                            "acp.docs_gate.reason_code references unknown reason code '{code}'"
                        ));
                    }
                }
            }
            if let Some(telemetry_gate) = &policy.acp.telemetry_gate {
                for code in [
                    telemetry_gate.reason_codes.missing.as_str(),
                    telemetry_gate.reason_codes.invalid.as_str(),
                ] {
                    if !code.trim().is_empty() && !known_codes.contains(code) {
                        semantic_errors.push(format!(
                            "acp.telemetry_gate references unknown reason code '{code}'"
                        ));
                    }
                }
            }
            if let Some(flag_gate) = &policy.acp.flag_metadata_gate {
                for code in [
                    flag_gate.reason_codes.missing_evidence.as_str(),
                    flag_gate.reason_codes.invalid.as_str(),
                ] {
                    if !code.trim().is_empty() && !known_codes.contains(code) {
                        semantic_errors.push(format!(
                            "acp.flag_metadata_gate references unknown reason code '{code}'"
                        ));
                    }
                }
            }
        }
    }

    let valid = schema_errors.is_empty() && semantic_errors.is_empty();
    Ok(DoctorReport {
        valid,
        schema_errors,
        semantic_errors,
        warnings,
    })
}

pub fn validate_receipt(request: &ReceiptValidateRequest) -> Result<ReceiptValidateReport> {
    let policy = load_policy(&request.policy_path)
        .with_context(|| format!("failed to load policy {}", request.policy_path.display()))?;

    let mut errors = Vec::new();
    let mut warnings = Vec::new();
    let mut reason_codes = Vec::new();
    let mut reason_seen = HashSet::new();

    if !request.receipt_path.exists() {
        errors.push(format!(
            "receipt file missing: {}",
            request.receipt_path.display()
        ));
        push_reason(&mut reason_codes, &mut reason_seen, "ACP_RECEIPT_REQUIRED");
        return Ok(ReceiptValidateReport {
            valid: false,
            reason_codes,
            errors,
            warnings,
        });
    }

    let receipt = match load_json_value(&request.receipt_path) {
        Ok(value) => value,
        Err(err) => {
            errors.push(format!(
                "failed to parse receipt {}: {err}",
                request.receipt_path.display()
            ));
            push_reason(&mut reason_codes, &mut reason_seen, "ACP_RECEIPT_INVALID");
            return Ok(ReceiptValidateReport {
                valid: false,
                reason_codes,
                errors,
                warnings,
            });
        }
    };

    if !receipt.is_object() {
        errors.push("receipt must be a JSON object".to_string());
    }

    for field in &policy.receipts.required_fields {
        if receipt_field_missing(&receipt, field) {
            errors.push(format!("missing required receipt field '{field}'"));
        }
    }

    let receipt_reason_codes: Vec<String> = receipt
        .get("reason_codes")
        .and_then(Value::as_array)
        .map(|values| {
            values
                .iter()
                .filter_map(Value::as_str)
                .map(ToString::to_string)
                .collect()
        })
        .unwrap_or_default();
    let reason_details = receipt
        .get("reason_details")
        .and_then(Value::as_array)
        .cloned()
        .unwrap_or_default();
    for code in &receipt_reason_codes {
        let mut found = false;
        for detail in &reason_details {
            let detail_code = detail.get("code").and_then(Value::as_str).unwrap_or_default();
            let detail_remediation = detail
                .get("remediation")
                .and_then(Value::as_str)
                .unwrap_or_default();
            if detail_code == code {
                found = true;
                if detail_remediation.trim().is_empty() {
                    errors.push(format!(
                        "reason_details entry for code '{code}' must include non-empty remediation"
                    ));
                }
            }
        }
        if !found {
            errors.push(format!(
                "reason_details missing remediation entry for reason code '{code}'"
            ));
        }
    }

    if receipt
        .get("remediation")
        .and_then(Value::as_str)
        .unwrap_or_default()
        .trim()
        .is_empty()
    {
        errors.push("receipt remediation must be non-empty".to_string());
    }

    let decision = receipt
        .get("decision")
        .and_then(Value::as_str)
        .unwrap_or_default()
        .to_string();
    if matches!(decision.as_str(), "ALLOW" | "STAGE_ONLY" | "DENY")
        && receipt_reason_codes.is_empty()
    {
        errors.push(format!(
            "receipt decision '{decision}' must include at least one reason code"
        ));
    }
    if !decision.is_empty()
        && !policy.receipts.emit_on.is_empty()
        && !policy
            .receipts
            .emit_on
            .iter()
            .any(|expected| expected == &decision)
    {
        errors.push(format!(
            "receipt decision '{decision}' is not in policy receipts.emit_on"
        ));
    }

    let effective_acp = receipt
        .get("effective_acp")
        .and_then(Value::as_str)
        .unwrap_or_default()
        .to_string();
    if !effective_acp.is_empty() {
        let required_rank = acp_level_rank(&policy.receipts.required_for_acp_at_or_above);
        if acp_level_rank(&effective_acp) >= required_rank
            && receipt_field_missing(&receipt, "rollback_handle")
        {
            errors.push(
                "rollback_handle is required for receipts at or above configured ACP threshold"
                    .to_string(),
            );
        }
    } else {
        warnings.push("receipt missing effective_acp; ACP threshold check skipped".to_string());
    }

    let phase = receipt
        .get("phase")
        .and_then(Value::as_str)
        .unwrap_or_default()
        .trim()
        .to_ascii_lowercase();
    let receipt_target: HashMap<String, Value> = receipt
        .pointer("/operation/target")
        .and_then(Value::as_object)
        .cloned()
        .unwrap_or_default()
        .into_iter()
        .collect();
    let material_side_effect = resolve_material_side_effect(
        &policy,
        &receipt_target,
        &phase,
        &mut reason_codes,
        &mut reason_seen,
        &mut warnings,
    );

    if let Some(config) = policy.acp.telemetry_gate.as_ref() {
        let enforce_on: Vec<String> = if config.enforce_on_phase.is_empty() {
            vec!["promote".to_string()]
        } else {
            config
                .enforce_on_phase
                .iter()
                .map(|entry| entry.trim().to_ascii_lowercase())
                .collect()
        };
        if material_side_effect
            && enforce_on.iter().any(|candidate| candidate == &phase)
            && !effective_acp.is_empty()
            && acp_level_rank(&effective_acp)
                >= acp_level_rank(&config.required_for_acp_at_or_above)
        {
            let target_field = if config.target_field.trim().is_empty() {
                "telemetry_profile"
            } else {
                config.target_field.trim()
            };
            let telemetry_profile = receipt
                .get(target_field)
                .or_else(|| receipt.pointer(&format!("/operation/target/{target_field}")))
                .and_then(Value::as_str)
                .map(|value| value.trim().to_ascii_lowercase())
                .filter(|value| !value.is_empty());
            let missing_reason = if config.reason_codes.missing.trim().is_empty() {
                "ACP_TELEMETRY_PROFILE_MISSING"
            } else {
                config.reason_codes.missing.as_str()
            };
            let invalid_reason = if config.reason_codes.invalid.trim().is_empty() {
                "ACP_TELEMETRY_PROFILE_INVALID"
            } else {
                config.reason_codes.invalid.as_str()
            };

            if let Some(profile_value) = telemetry_profile {
                let allowed_profiles = config
                    .allowed_by_acp
                    .get(&effective_acp.to_ascii_uppercase())
                    .or_else(|| config.allowed_by_acp.get("default"))
                    .cloned()
                    .unwrap_or_default();
                let is_allowed = allowed_profiles
                    .iter()
                    .map(|value| value.trim().to_ascii_lowercase())
                    .any(|value| value == profile_value);
                if !is_allowed {
                    errors.push(format!(
                        "receipt telemetry profile '{profile_value}' is not allowed for ACP '{effective_acp}'"
                    ));
                    push_reason(&mut reason_codes, &mut reason_seen, invalid_reason);
                }
            } else {
                errors.push(format!(
                    "receipt missing telemetry profile field '{target_field}' for ACP '{effective_acp}'"
                ));
                push_reason(&mut reason_codes, &mut reason_seen, missing_reason);
            }
        }
    }

    if let Some(config) = policy.acp.flag_metadata_gate.as_ref() {
        let enforce_on: Vec<String> = if config.enforce_on_phase.is_empty() {
            vec!["promote".to_string()]
        } else {
            config
                .enforce_on_phase
                .iter()
                .map(|entry| entry.trim().to_ascii_lowercase())
                .collect()
        };
        let trigger_fields: Vec<String> = if config.required_when_target_flags.is_empty() {
            vec![
                "has_flags".to_string(),
                "modifies_flags".to_string(),
                "flag_change".to_string(),
            ]
        } else {
            config.required_when_target_flags.clone()
        };
        let triggered = trigger_fields
            .iter()
            .any(|field| target_flag_is_truthy(receipt_target.get(field)));
        if material_side_effect
            && enforce_on.iter().any(|candidate| candidate == &phase)
            && triggered
        {
            let evidence_type = if config.evidence_type.trim().is_empty() {
                "flags.metadata"
            } else {
                config.evidence_type.trim()
            };
            let has_flag_metadata_evidence = receipt
                .get("evidence")
                .and_then(Value::as_array)
                .is_some_and(|entries| {
                    entries.iter().any(|entry| {
                        entry
                            .get("type")
                            .and_then(Value::as_str)
                            .is_some_and(|value| value == evidence_type)
                    })
                });
            let missing_reason = if config.reason_codes.missing_evidence.trim().is_empty() {
                "ACP_FLAG_METADATA_EVIDENCE_MISSING"
            } else {
                config.reason_codes.missing_evidence.as_str()
            };
            let invalid_reason = if config.reason_codes.invalid.trim().is_empty() {
                "ACP_FLAG_METADATA_INVALID"
            } else {
                config.reason_codes.invalid.as_str()
            };

            if !has_flag_metadata_evidence {
                errors.push(format!(
                    "receipt missing required flag metadata evidence type '{evidence_type}'"
                ));
                push_reason(&mut reason_codes, &mut reason_seen, missing_reason);
            }

            let metadata_field = if config.metadata_valid_field.trim().is_empty() {
                "flag_metadata_valid"
            } else {
                config.metadata_valid_field.trim()
            };
            let metadata_valid = receipt
                .get(metadata_field)
                .and_then(value_to_bool)
                .or_else(|| receipt_target.get(metadata_field).and_then(value_to_bool))
                .unwrap_or(false);
            if !metadata_valid {
                errors.push(format!(
                    "receipt metadata validity field '{metadata_field}' must be true when flags change"
                ));
                push_reason(&mut reason_codes, &mut reason_seen, invalid_reason);
            }
        }
    }

    if !errors.is_empty() {
        push_reason(&mut reason_codes, &mut reason_seen, "ACP_RECEIPT_INVALID");
    }

    Ok(ReceiptValidateReport {
        valid: errors.is_empty(),
        reason_codes,
        errors,
        warnings,
    })
}

fn evaluate_service_preflight(
    policy: &PolicyV2,
    request: &PreflightRequest,
    artifact: &ArtifactContext,
    exceptions: &[ExceptionLease],
    today: &str,
) -> Decision {
    if artifact.status != "active" {
        return allow(
            "hard-enforce",
            vec![format!(
                "non-active service status='{}'; policy checks skipped",
                artifact.status
            )],
        );
    }

    if artifact.allowed_tools.is_empty() {
        return deny(
            "hard-enforce",
            "DDB003_UNKNOWN_TOOL_TOKEN",
            "Service has empty or missing allowed-tools",
            "service",
            &request.target_id,
            None,
            None,
            "Declare allowed-tools with scoped permissions",
            None,
        );
    }

    for token in &artifact.allowed_tools {
        if token == "Bash" || token == "Shell" {
            return deny(
                "hard-enforce",
                "DDB004_UNSCOPED_BASH",
                "Unscoped command permission is not allowed for active service",
                "service",
                &request.target_id,
                None,
                Some(token.clone()),
                "Replace with Bash(<scoped-command>)",
                None,
            );
        }

        if token == "Write" {
            return deny(
                "hard-enforce",
                "DDB005_UNSCOPED_WRITE",
                "Unscoped write permission is not allowed for active service",
                "service",
                &request.target_id,
                None,
                Some(token.clone()),
                "Replace with Write(<scoped-path>)",
                None,
            );
        }

        if policy.defaults.deny_unknown_tokens && !is_known_tool_token(token) {
            return deny(
                "hard-enforce",
                "DDB003_UNKNOWN_TOOL_TOKEN",
                "Unknown allowed-tools token",
                "service",
                &request.target_id,
                None,
                Some(token.clone()),
                "Use only approved tool tokens",
                None,
            );
        }
    }

    if artifact.has_broad_write {
        match check_active_exception(
            exceptions,
            "service",
            &request.target_id,
            "broad_write_scope",
            today,
        ) {
            ExceptionState::Active => {}
            ExceptionState::Missing => {
                return deny(
                    "hard-enforce",
                    "DDB009_EXCEPTION_MISSING",
                    "Broad write scope requires active exception lease",
                    "service",
                    &request.target_id,
                    None,
                    None,
                    "Add temporary exception lease or narrow Write scope",
                    None,
                )
            }
            ExceptionState::Expired => {
                return deny(
                    "hard-enforce",
                    "DDB010_EXCEPTION_EXPIRED",
                    "Broad write scope exception has expired",
                    "service",
                    &request.target_id,
                    None,
                    None,
                    "Renew exception lease or narrow Write scope",
                    None,
                )
            }
        }
    }

    if artifact
        .interface_type
        .as_deref()
        .map(|value| value == "shell")
        .unwrap_or(false)
        && artifact.bash_scopes.is_empty()
    {
        return deny(
            "hard-enforce",
            "DDB006_BASH_SCOPE_MISSING",
            "Active shell service requires at least one Bash(<scope>) token",
            "service",
            &request.target_id,
            None,
            None,
            "Add a scoped Bash token to allowed-tools",
            None,
        );
    }

    let fail_closed = artifact.fail_closed.as_deref().map(str::to_lowercase);
    match fail_closed.as_deref() {
        Some("true") => {}
        Some("false") => {
            match check_active_exception(
                exceptions,
                "service",
                &request.target_id,
                "fail_closed_false",
                today,
            ) {
                ExceptionState::Active => {}
                ExceptionState::Missing => {
                    return deny(
                        "hard-enforce",
                        "DDB011_FAIL_CLOSED_FALSE_REQUIRES_EXCEPTION",
                        "policy.fail_closed=false requires active exception lease",
                        "service",
                        &request.target_id,
                        None,
                        None,
                        "Restore fail_closed=true or add temporary lease",
                        None,
                    )
                }
                ExceptionState::Expired => {
                    return deny(
                        "hard-enforce",
                        "DDB010_EXCEPTION_EXPIRED",
                        "policy.fail_closed=false exception lease is expired",
                        "service",
                        &request.target_id,
                        None,
                        None,
                        "Renew lease or set fail_closed=true",
                        None,
                    )
                }
            }
        }
        _ => {
            return deny(
                "hard-enforce",
                "DDB002_POLICY_INVALID",
                "Service missing or invalid policy.fail_closed setting",
                "service",
                &request.target_id,
                None,
                None,
                "Set policy.fail_closed to true or false in SERVICE.md",
                None,
            )
        }
    }

    allow("hard-enforce", vec!["service-preflight-pass".to_string()])
}

fn evaluate_skill_preflight(
    _policy: &PolicyV2,
    request: &PreflightRequest,
    artifact: &ArtifactContext,
    exceptions: &[ExceptionLease],
    today: &str,
) -> Decision {
    if artifact.status != "active" {
        return allow(
            "hard-enforce",
            vec![format!(
                "non-active skill status='{}'; policy checks skipped",
                artifact.status
            )],
        );
    }

    if artifact.allowed_tools.is_empty() {
        return deny(
            "hard-enforce",
            "DDB003_UNKNOWN_TOOL_TOKEN",
            "Skill has empty or missing allowed-tools",
            "skill",
            &request.target_id,
            None,
            None,
            "Declare allowed-tools with scoped permissions",
            None,
        );
    }

    for token in &artifact.allowed_tools {
        if token == "Bash" || token == "Shell" {
            return deny(
                "hard-enforce",
                "DDB004_UNSCOPED_BASH",
                "Unscoped command permission is not allowed for active skill",
                "skill",
                &request.target_id,
                None,
                Some(token.clone()),
                "Replace with Bash(<scoped-command>)",
                None,
            );
        }

        if token == "Write" {
            return deny(
                "hard-enforce",
                "DDB005_UNSCOPED_WRITE",
                "Unscoped write permission is not allowed for active skill",
                "skill",
                &request.target_id,
                None,
                Some(token.clone()),
                "Replace with Write(<scoped-path>)",
                None,
            );
        }

        if !is_known_tool_token(token) {
            return deny(
                "hard-enforce",
                "DDB003_UNKNOWN_TOOL_TOKEN",
                "Unknown allowed-tools token",
                "skill",
                &request.target_id,
                None,
                Some(token.clone()),
                "Use only approved tool tokens",
                None,
            );
        }
    }

    if artifact.has_broad_write {
        match check_active_exception(
            exceptions,
            "skill",
            &request.target_id,
            "broad_write_scope",
            today,
        ) {
            ExceptionState::Active => {}
            ExceptionState::Missing => {
                return deny(
                    "hard-enforce",
                    "DDB009_EXCEPTION_MISSING",
                    "Broad write scope requires active exception lease",
                    "skill",
                    &request.target_id,
                    None,
                    None,
                    "Add temporary exception lease or narrow Write scope",
                    None,
                )
            }
            ExceptionState::Expired => {
                return deny(
                    "hard-enforce",
                    "DDB010_EXCEPTION_EXPIRED",
                    "Broad write scope exception has expired",
                    "skill",
                    &request.target_id,
                    None,
                    None,
                    "Renew exception lease or narrow Write scope",
                    None,
                )
            }
        }
    }

    if let Some(decision) = validate_declared_skill_services(request, artifact) {
        return decision;
    }

    allow("hard-enforce", vec!["skill-preflight-pass".to_string()])
}

fn evaluate_agent_only(
    policy: &PolicyV2,
    request: &EnforceRequest,
    today: &str,
) -> Result<Decision> {
    if !policy.agent_only.enabled {
        return Ok(deny(
            "hard-enforce",
            "DDB012_AGENT_ONLY_POLICY_DISABLED",
            "Agent-only policy is disabled",
            "service",
            &request.preflight.target_id,
            None,
            None,
            "Set agent_only.enabled=true in deny-by-default.v2 policy",
            Some(request.risk_tier.clone()),
        ));
    }

    let risk_tier = request.risk_tier.to_lowercase();
    let tier = match risk_tier.as_str() {
        "low" => &policy.agent_only.risk_tiers.low,
        "medium" => &policy.agent_only.risk_tiers.medium,
        "high" => &policy.agent_only.risk_tiers.high,
        _ => {
            return Ok(deny(
                "hard-enforce",
                "DDB012_AGENT_ONLY_POLICY_DISABLED",
                "Invalid risk tier",
                "service",
                &request.preflight.target_id,
                None,
                None,
                "Use low, medium, or high risk tier",
                Some(request.risk_tier.clone()),
            ))
        }
    };

    let scope_keys = {
        let mut keys = vec![
            "global".to_string(),
            format!("service:{}", request.preflight.target_id),
        ];
        if let Some(category) = &request.category {
            keys.push(format!("category:{category}"));
        }
        keys
    };

    if is_kill_switch_active(policy, &scope_keys, today)? {
        return Ok(deny(
            "hard-enforce",
            "DDB019_KILL_SWITCH_ACTIVE",
            "Matching kill-switch is active for requested scope",
            "service",
            &request.preflight.target_id,
            None,
            None,
            "Clear or expire kill-switch record for this scope",
            Some(request.risk_tier.clone()),
        ));
    }

    let agent_id = match request.agent_id.as_deref() {
        Some(value) if !value.trim().is_empty() => value.trim().to_string(),
        _ => {
            return Ok(deny(
                "hard-enforce",
                "DDB013_AGENT_ID_MISSING",
                "Agent-only mode requires OCTON_AGENT_ID",
                "service",
                &request.preflight.target_id,
                None,
                None,
                "Set OCTON_AGENT_ID",
                Some(request.risk_tier.clone()),
            ))
        }
    };

    let ids_csv = request
        .agent_ids_csv
        .as_deref()
        .unwrap_or(agent_id.as_str())
        .to_string();
    let distinct = count_distinct_ids(&ids_csv);
    if distinct < tier.min_distinct_agents {
        return Ok(deny(
            "hard-enforce",
            "DDB014_DISTINCT_AGENT_QUORUM_NOT_MET",
            "Distinct agent quorum not met",
            "service",
            &request.preflight.target_id,
            None,
            None,
            "Provide additional distinct agent ids in OCTON_AGENT_IDS",
            Some(request.risk_tier.clone()),
        ));
    }

    if tier.require_review {
        let reviewer = match request.review_agent_id.as_deref() {
            Some(value) if !value.trim().is_empty() => value.trim().to_string(),
            _ => {
                return Ok(deny(
                    "hard-enforce",
                    "DDB015_REVIEW_AGENT_REQUIRED",
                    "Risk tier requires review agent",
                    "service",
                    &request.preflight.target_id,
                    None,
                    None,
                    "Set OCTON_REVIEW_AGENT_ID",
                    Some(request.risk_tier.clone()),
                ))
            }
        };

        if reviewer == agent_id {
            return Ok(deny(
                "hard-enforce",
                "DDB016_REVIEWER_NOT_DISTINCT",
                "Reviewer must differ from acting agent",
                "service",
                &request.preflight.target_id,
                None,
                None,
                "Use distinct reviewer identity",
                Some(request.risk_tier.clone()),
            ));
        }
    }

    if tier.require_quorum_token
        && request
            .quorum_token
            .as_deref()
            .unwrap_or_default()
            .trim()
            .is_empty()
    {
        return Ok(deny(
            "hard-enforce",
            "DDB017_QUORUM_TOKEN_REQUIRED",
            "Risk tier requires quorum token",
            "service",
            &request.preflight.target_id,
            None,
            None,
            "Set OCTON_QUORUM_TOKEN",
            Some(request.risk_tier.clone()),
        ));
    }

    if tier.require_rollback_plan
        && request
            .rollback_plan_id
            .as_deref()
            .unwrap_or_default()
            .trim()
            .is_empty()
    {
        return Ok(deny(
            "hard-enforce",
            "DDB018_ROLLBACK_PLAN_REQUIRED",
            "Risk tier requires rollback plan id",
            "service",
            &request.preflight.target_id,
            None,
            None,
            "Set OCTON_ROLLBACK_PLAN_ID",
            Some(request.risk_tier.clone()),
        ));
    }

    Ok(allow(
        "hard-enforce",
        vec![format!(
            "agent-only-pass:tier={risk_tier}:distinct={distinct}"
        )],
    ))
}

fn is_kill_switch_active(policy: &PolicyV2, scope_keys: &[String], today: &str) -> Result<bool> {
    let state_dir = PathBuf::from(&policy.kill_switch.state_dir);
    if !state_dir.exists() {
        return Ok(false);
    }

    for entry in fs::read_dir(&state_dir).with_context(|| {
        format!(
            "failed to read kill-switch directory {}",
            state_dir.display()
        )
    })? {
        let entry = entry?;
        let path = entry.path();
        if !path.is_file() {
            continue;
        }

        let ext = path
            .extension()
            .and_then(|value| value.to_str())
            .unwrap_or_default();
        if ext != "yml" && ext != "yaml" && ext != "json" {
            continue;
        }

        let record: KillSwitchRecord = load_yaml(&path)
            .with_context(|| format!("failed to parse kill-switch record {}", path.display()))?;

        let state = record.state.as_deref().unwrap_or("active").to_lowercase();
        if state != "active" {
            continue;
        }

        if !scope_keys.iter().any(|key| key == &record.scope) {
            continue;
        }

        let expires = record.expires.as_deref().unwrap_or("");
        if expires.is_empty() {
            return Ok(true);
        }
        if !is_valid_date(expires) {
            return Ok(true);
        }
        if expires >= today {
            return Ok(true);
        }
    }

    Ok(false)
}

fn apply_mode(mode: &str, decision: &mut Decision) {
    let normalized = mode.to_lowercase();
    decision.mode = normalized.clone();

    if decision.allow {
        return;
    }

    let Some(deny) = decision.deny.as_ref() else {
        return;
    };

    match normalized.as_str() {
        "shadow" => {
            decision.allow = true;
            decision.shadow_deny = true;
            decision
                .notes
                .push(format!("shadow-mode: would deny with {}", deny.code));
        }
        "soft-enforce" => {
            if !is_critical_code(&deny.code) {
                decision.allow = true;
                decision.shadow_deny = true;
                decision.notes.push(format!(
                    "soft-enforce: non-critical deny converted to warning ({})",
                    deny.code
                ));
            }
        }
        _ => {}
    }
}

fn is_critical_code(code: &str) -> bool {
    matches!(
        code,
        "DDB001_POLICY_FILE_MISSING"
            | "DDB002_POLICY_INVALID"
            | "DDB019_KILL_SWITCH_ACTIVE"
            | "DDB025_RUNTIME_DECISION_ENGINE_ERROR"
    )
}

fn allow(mode: &str, notes: Vec<String>) -> Decision {
    Decision {
        allow: true,
        mode: mode.to_string(),
        shadow_deny: false,
        deny: None,
        notes,
    }
}

fn deny(
    mode: &str,
    code: &str,
    message: &str,
    scope: &str,
    target: &str,
    missing_scope: Option<String>,
    expected_token: Option<String>,
    remediation_hint: &str,
    risk_tier: Option<String>,
) -> Decision {
    Decision {
        allow: false,
        mode: mode.to_string(),
        shadow_deny: false,
        deny: Some(make_deny(
            code,
            message,
            scope,
            target,
            missing_scope,
            expected_token,
            remediation_hint,
            risk_tier,
        )),
        notes: Vec::new(),
    }
}

fn make_deny(
    code: &str,
    message: &str,
    scope: &str,
    target: &str,
    missing_scope: Option<String>,
    expected_token: Option<String>,
    remediation_hint: &str,
    risk_tier: Option<String>,
) -> DenyPayload {
    DenyPayload {
        code: code.to_string(),
        message: message.to_string(),
        scope: scope.to_string(),
        target: target.to_string(),
        missing_scope,
        expected_token,
        remediation_hint: remediation_hint.to_string(),
        risk_tier,
    }
}

fn load_artifact_context(request: &PreflightRequest) -> Result<ArtifactContext> {
    let contents = fs::read_to_string(&request.artifact_path).with_context(|| {
        format!(
            "failed to read artifact {}",
            request.artifact_path.display()
        )
    })?;

    let raw_allowed = extract_key_line_value(&contents, "allowed-tools").unwrap_or_default();
    let allowed_tools = split_allowed_tools(&raw_allowed);
    let raw_allowed_services =
        extract_key_line_value(&contents, "allowed-services").unwrap_or_default();
    let allowed_services = split_allowed_services(&raw_allowed_services);
    let bash_scopes = allowed_tools
        .iter()
        .filter_map(|token| bash_scope_from_token(token))
        .collect::<Vec<_>>();
    let has_broad_write = allowed_tools
        .iter()
        .filter_map(|token| write_scope_from_token(token))
        .any(|scope| scope.contains("**"));

    let fail_closed = parse_frontmatter_value(&contents, "fail_closed");

    match request.kind {
        ScopeKind::Service => {
            let manifest: ServicesManifest = load_yaml(&request.manifest_path)?;
            let entry = manifest
                .services
                .into_iter()
                .find(|service| service.id == request.target_id)
                .ok_or_else(|| {
                    anyhow!(
                        "service '{}' not found in manifest {}",
                        request.target_id,
                        request.manifest_path.display()
                    )
                })?;

            Ok(ArtifactContext {
                status: entry.status,
                interface_type: entry.interface_type,
                allowed_tools,
                allowed_services,
                fail_closed,
                bash_scopes,
                has_broad_write,
            })
        }
        ScopeKind::Skill => {
            let manifest: SkillsManifest = load_yaml(&request.manifest_path)?;
            let entry = manifest
                .skills
                .into_iter()
                .find(|skill| skill.id == request.target_id)
                .ok_or_else(|| {
                    anyhow!(
                        "skill '{}' not found in manifest {}",
                        request.target_id,
                        request.manifest_path.display()
                    )
                })?;

            Ok(ArtifactContext {
                status: entry.status,
                interface_type: None,
                allowed_tools,
                allowed_services,
                fail_closed,
                bash_scopes,
                has_broad_write,
            })
        }
    }
}

fn extract_key_line_value(contents: &str, key: &str) -> Option<String> {
    let prefix = format!("{key}:");
    for line in contents.lines() {
        let trimmed = line.trim();
        if let Some(rest) = trimmed.strip_prefix(&prefix) {
            return Some(rest.trim().trim_matches('"').trim_matches('\'').to_string());
        }
    }
    None
}

fn parse_frontmatter_value(contents: &str, key: &str) -> Option<String> {
    let mut in_frontmatter = false;
    let mut delimiter_count = 0;

    for line in contents.lines() {
        let trimmed = line.trim();
        if trimmed == "---" {
            delimiter_count += 1;
            if delimiter_count == 1 {
                in_frontmatter = true;
                continue;
            }
            if delimiter_count == 2 {
                break;
            }
        }

        if in_frontmatter {
            let prefix = format!("{key}:");
            if let Some(rest) = trimmed.strip_prefix(&prefix) {
                return Some(rest.trim().trim_matches('"').trim_matches('\'').to_string());
            }
        }
    }

    None
}

fn matches_bash_scope(scope: &str, command: &str) -> bool {
    if scope == "bash" {
        return command.starts_with("bash ") || command == "bash";
    }

    if let Ok(pattern) = Pattern::new(scope) {
        return pattern.matches(command);
    }

    scope == command
}

#[derive(Debug, Clone, PartialEq, Eq)]
enum ExceptionState {
    Active,
    Missing,
    Expired,
}

fn check_active_exception(
    exceptions: &[ExceptionLease],
    scope: &str,
    target: &str,
    rule: &str,
    today: &str,
) -> ExceptionState {
    let matching = exceptions
        .iter()
        .find(|lease| lease.scope == scope && lease.target == target && lease.rule == rule);

    let Some(lease) = matching else {
        return ExceptionState::Missing;
    };

    let expires = lease.expires.as_deref().unwrap_or("");
    if !is_valid_date(expires) {
        return ExceptionState::Expired;
    }
    if expires < today {
        return ExceptionState::Expired;
    }
    ExceptionState::Active
}

fn is_valid_date(value: &str) -> bool {
    if value.len() != 10 {
        return false;
    }
    let bytes = value.as_bytes();
    for (idx, byte) in bytes.iter().enumerate() {
        match idx {
            4 | 7 => {
                if *byte != b'-' {
                    return false;
                }
            }
            _ => {
                if !byte.is_ascii_digit() {
                    return false;
                }
            }
        }
    }
    true
}

pub fn load_exceptions(path: &Path) -> Result<Vec<ExceptionLease>> {
    if !path.exists() {
        return Ok(Vec::new());
    }

    let file: ExceptionLeaseFile = load_yaml(path)?;
    Ok(file.exceptions)
}

pub fn count_distinct_ids(csv: &str) -> usize {
    let mut set = BTreeSet::new();
    for part in csv.split(',') {
        let value = part.trim();
        if !value.is_empty() {
            set.insert(value.to_string());
        }
    }
    set.len()
}

pub fn load_reason_codes(path: &Path) -> Result<HashSet<String>> {
    let text = fs::read_to_string(path)
        .with_context(|| format!("failed to read reason codes {}", path.display()))?;

    let mut set = HashSet::new();
    for raw in text.split(|ch: char| !ch.is_ascii_alphanumeric() && ch != '_') {
        if (raw.starts_with("DDB") || raw.starts_with("ACP") || raw.starts_with("RA"))
            && raw.contains('_')
        {
            set.insert(raw.to_string());
        }
    }

    Ok(set)
}

fn receipt_field_missing(receipt: &Value, field: &str) -> bool {
    let Some(value) = receipt.get(field) else {
        return true;
    };

    if value.is_null() {
        return true;
    }

    if let Some(text) = value.as_str() {
        return text.trim().is_empty();
    }

    false
}

fn load_json_value(path: &Path) -> Result<Value> {
    let text = fs::read_to_string(path)
        .with_context(|| format!("failed to read JSON file {}", path.display()))?;
    Ok(serde_json::from_str(&text)
        .with_context(|| format!("failed to parse JSON file {}", path.display()))?)
}

fn load_yaml_value(path: &Path) -> Result<Value> {
    let text = fs::read_to_string(path)
        .with_context(|| format!("failed to read YAML file {}", path.display()))?;
    Ok(serde_yaml::from_str(&text)
        .with_context(|| format!("failed to parse YAML file {}", path.display()))?)
}

fn load_yaml<T>(path: &Path) -> Result<T>
where
    T: DeserializeOwned,
{
    let text = fs::read_to_string(path)
        .with_context(|| format!("failed to read YAML file {}", path.display()))?;
    Ok(serde_yaml::from_str(&text)
        .with_context(|| format!("failed to parse YAML file {}", path.display()))?)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn split_allowed_tools_respects_parentheses_depth() {
        let raw =
            "Read Bash(git diff --name-only) Write(.octon/output/**) Bash(rg deny-by-default)";
        let tokens = split_allowed_tools(raw);
        assert_eq!(
            tokens,
            vec![
                "Read",
                "Bash(git diff --name-only)",
                "Write(.octon/output/**)",
                "Bash(rg deny-by-default)",
            ]
        );
    }

    #[test]
    fn distinct_agent_count_deduplicates_values() {
        assert_eq!(count_distinct_ids("a,b,a, c"), 3);
    }

    #[test]
    fn bash_scope_match_supports_glob_patterns() {
        assert!(matches_bash_scope(
            "bash execution/agent/impl/agent.sh *",
            "bash execution/agent/impl/agent.sh --help"
        ));
        assert!(!matches_bash_scope(
            "bash execution/agent/impl/agent.sh *",
            "bash execution/guard/impl/guard.sh"
        ));
    }
}
