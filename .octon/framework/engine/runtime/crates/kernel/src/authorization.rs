use anyhow::Context;
use octon_core::config::{ExecutorProfileConfig, RuntimeConfig};
use octon_core::errors::{ErrorCode, KernelError, Result as CoreResult};
use octon_core::policy::PolicyEngine;
use octon_core::registry::ServiceDescriptor;
use serde::{Deserialize, Serialize};
use serde_json::json;
use sha2::{Digest, Sha256};
use std::collections::{BTreeMap, BTreeSet};
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IntentRef {
    pub id: String,
    pub version: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ActorRef {
    pub kind: String,
    pub id: String,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct SideEffectFlags {
    #[serde(default)]
    pub write_repo: bool,
    #[serde(default)]
    pub write_evidence: bool,
    #[serde(default)]
    pub shell: bool,
    #[serde(default)]
    pub network: bool,
    #[serde(default)]
    pub model_invoke: bool,
    #[serde(default)]
    pub state_mutation: bool,
    #[serde(default)]
    pub publication: bool,
    #[serde(default)]
    pub branch_mutation: bool,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct ReviewRequirements {
    #[serde(default)]
    pub human_approval: bool,
    #[serde(default)]
    pub quorum: bool,
    #[serde(default)]
    pub rollback_metadata: bool,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct ScopeConstraints {
    #[serde(default)]
    pub read: Vec<String>,
    #[serde(default)]
    pub write: Vec<String>,
    #[serde(default)]
    pub executor_profile: Option<String>,
    #[serde(default)]
    pub locality_scope: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExecutionRequest {
    pub request_id: String,
    pub caller_path: String,
    pub action_type: String,
    pub target_id: String,
    #[serde(default)]
    pub requested_capabilities: Vec<String>,
    #[serde(default)]
    pub side_effect_flags: SideEffectFlags,
    pub risk_tier: String,
    #[serde(default)]
    pub locality_scope: Option<String>,
    #[serde(default)]
    pub intent_ref: Option<IntentRef>,
    #[serde(default)]
    pub actor_ref: Option<ActorRef>,
    #[serde(default)]
    pub parent_run_ref: Option<String>,
    #[serde(default)]
    pub review_requirements: ReviewRequirements,
    #[serde(default)]
    pub scope_constraints: ScopeConstraints,
    #[serde(default)]
    pub policy_mode_requested: Option<String>,
    #[serde(default)]
    pub environment_hint: Option<String>,
    #[serde(default)]
    pub metadata: BTreeMap<String, String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "SCREAMING_SNAKE_CASE")]
pub enum ExecutionDecision {
    Allow,
    StageOnly,
    Deny,
    Escalate,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "lowercase")]
pub enum ExecutionEnvironment {
    Development,
    Protected,
}

impl ExecutionEnvironment {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Development => "development",
            Self::Protected => "protected",
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GrantBundle {
    pub grant_id: String,
    pub request_id: String,
    pub decision: ExecutionDecision,
    #[serde(default)]
    pub granted_capabilities: Vec<String>,
    pub scope_constraints: ScopeConstraints,
    pub effective_policy_mode: String,
    #[serde(default)]
    pub reason_codes: Vec<String>,
    #[serde(default)]
    pub review_metadata: BTreeMap<String, String>,
    #[serde(default)]
    pub expires_after: Option<String>,
    #[serde(default)]
    pub receipt_requirements: Vec<String>,
    pub environment_class: ExecutionEnvironment,
    pub intent_ref: IntentRef,
    pub actor_ref: ActorRef,
    #[serde(default)]
    pub policy_receipt_path: Option<String>,
    #[serde(default)]
    pub policy_digest_path: Option<String>,
    #[serde(default)]
    pub instruction_manifest_path: Option<String>,
}

#[derive(Debug, Clone, Default, Serialize, Deserialize)]
pub struct SideEffectSummary {
    #[serde(default)]
    pub touched_scope: Vec<String>,
    #[serde(default)]
    pub shell_commands: Vec<String>,
    #[serde(default)]
    pub network_targets: Vec<String>,
    #[serde(default)]
    pub publications: Vec<String>,
    #[serde(default)]
    pub branch_mutations: Vec<String>,
    #[serde(default)]
    pub executor_profile: Option<String>,
    #[serde(default)]
    pub dangerous_flags_blocked: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExecutionOutcome {
    pub status: String,
    pub started_at: String,
    pub completed_at: String,
    #[serde(default)]
    pub error: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExecutionReceipt {
    pub schema_version: String,
    pub request_id: String,
    pub grant_id: String,
    pub target_id: String,
    pub action_type: String,
    pub path_type: String,
    pub environment_class: String,
    pub intent_ref: IntentRef,
    pub actor_ref: ActorRef,
    #[serde(default)]
    pub requested_capabilities: Vec<String>,
    #[serde(default)]
    pub granted_capabilities: Vec<String>,
    pub policy_mode_requested: String,
    pub policy_mode_effective: String,
    pub decision: ExecutionDecision,
    #[serde(default)]
    pub reason_codes: Vec<String>,
    #[serde(default)]
    pub touched_scope: Vec<String>,
    pub side_effects: SideEffectSummary,
    pub override_requested: bool,
    pub override_accepted: bool,
    pub ai_review_enforced: bool,
    pub autonomy_policy_enforced: bool,
    #[serde(default)]
    pub evidence_links: BTreeMap<String, String>,
    pub timestamps: ReceiptTimestamps,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReceiptTimestamps {
    pub started_at: String,
    pub completed_at: String,
}

#[derive(Debug, Clone)]
pub struct ExecutionArtifactPaths {
    pub root: PathBuf,
    pub request: PathBuf,
    pub decision: PathBuf,
    pub grant: PathBuf,
    pub side_effects: PathBuf,
    pub outcome: PathBuf,
    pub receipt: PathBuf,
}

impl ExecutionArtifactPaths {
    pub fn new(root: PathBuf) -> Self {
        Self {
            request: root.join("execution-request.json"),
            decision: root.join("policy-decision.json"),
            grant: root.join("grant-bundle.json"),
            side_effects: root.join("side-effects.json"),
            outcome: root.join("outcome.json"),
            receipt: root.join("execution-receipt.json"),
            root,
        }
    }
}

pub enum ManagedExecutorKind {
    Codex,
    Claude,
}

pub struct ExecutorCommandSpec<'a> {
    pub kind: ManagedExecutorKind,
    pub executor_bin: &'a Path,
    pub repo_root: &'a Path,
    pub output_path: Option<&'a Path>,
    pub model: Option<&'a str>,
    pub profile: &'a ExecutorProfileConfig,
}

pub fn default_actor_ref() -> ActorRef {
    ActorRef {
        kind: std::env::var("OCTON_EXECUTION_ACTOR_KIND").unwrap_or_else(|_| "system".to_string()),
        id: std::env::var("OCTON_EXECUTION_ACTOR_ID")
            .unwrap_or_else(|_| "octon-kernel".to_string()),
    }
}

pub fn default_policy_mode(cfg: &RuntimeConfig) -> String {
    std::env::var("OCTON_POLICY_MODE_OVERRIDE")
        .or_else(|_| std::env::var("OCTON_EFFECTIVE_POLICY_MODE"))
        .unwrap_or_else(|_| cfg.execution_governance.default_policy_mode.clone())
}

pub fn active_intent_ref(cfg: &RuntimeConfig) -> Option<IntentRef> {
    let path = cfg
        .repo_root
        .join(".octon/instance/cognition/context/shared/intent.contract.yml");
    let raw = fs::read_to_string(path).ok()?;
    let doc = serde_yaml::from_str::<serde_yaml::Value>(&raw).ok()?;
    Some(IntentRef {
        id: doc.get("intent_id")?.as_str()?.to_string(),
        version: doc.get("version")?.as_str()?.to_string(),
    })
}

pub fn resolve_execution_environment(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
) -> ExecutionEnvironment {
    if matches!(request.environment_hint.as_deref(), Some("protected")) {
        return ExecutionEnvironment::Protected;
    }

    if cfg
        .execution_governance
        .protected_workflows
        .contains(&request.target_id)
        || request
            .metadata
            .get("workflow_id")
            .map(|value| cfg.execution_governance.protected_workflows.contains(value))
            .unwrap_or(false)
    {
        return ExecutionEnvironment::Protected;
    }

    if request.side_effect_flags.publication
        || request.side_effect_flags.branch_mutation
        || request.action_type == "release_publication"
    {
        return ExecutionEnvironment::Protected;
    }

    if let Some(branch) = current_branch(&cfg.repo_root) {
        if cfg.execution_governance.protected_refs.contains(&branch)
            && (request.side_effect_flags.write_repo
                || request.side_effect_flags.publication
                || request.side_effect_flags.branch_mutation)
        {
            return ExecutionEnvironment::Protected;
        }
    }

    ExecutionEnvironment::Development
}

pub fn authorize_execution(
    cfg: &RuntimeConfig,
    policy: &PolicyEngine,
    request: &ExecutionRequest,
    service: Option<&ServiceDescriptor>,
) -> CoreResult<GrantBundle> {
    let environment = resolve_execution_environment(cfg, request);
    let intent_ref = request
        .intent_ref
        .clone()
        .or_else(|| active_intent_ref(cfg))
        .ok_or_else(|| {
            KernelError::new(
                ErrorCode::CapabilityDenied,
                "execution request missing active intent binding",
            )
            .with_details(json!({"reason_codes":["INTENT_MISSING"]}))
        })?;
    let actor_ref = request.actor_ref.clone().unwrap_or_else(default_actor_ref);

    let requested_mode = request
        .policy_mode_requested
        .clone()
        .unwrap_or_else(|| default_policy_mode(cfg));
    let effective_policy_mode = match environment {
        ExecutionEnvironment::Protected => {
            if requested_mode != cfg.execution_governance.protected_policy_mode {
                return Err(
                    KernelError::new(
                        ErrorCode::CapabilityDenied,
                        "protected execution rejected a weaker requested policy mode",
                    )
                    .with_details(json!({"reason_codes":["PROTECTED_EXECUTION_REQUIRES_HARD_ENFORCE"]})),
                );
            }
            cfg.execution_governance.protected_policy_mode.clone()
        }
        ExecutionEnvironment::Development => {
            if cfg
                .execution_governance
                .allowed_development_modes
                .contains(&requested_mode)
            {
                requested_mode.clone()
            } else {
                return Err(
                    KernelError::new(
                        ErrorCode::CapabilityDenied,
                        format!(
                            "requested policy mode '{}' is not allowed in development",
                            requested_mode
                        ),
                    )
                    .with_details(json!({"reason_codes":["POLICY_MODE_INVALID"]})),
                );
            }
        }
    };

    if matches!(environment, ExecutionEnvironment::Protected)
        && effective_policy_mode != cfg.execution_governance.protected_policy_mode
    {
        return Err(
            KernelError::new(
                ErrorCode::CapabilityDenied,
                "protected execution requires hard-enforce posture",
            )
            .with_details(json!({"reason_codes":["PROTECTED_EXECUTION_REQUIRES_HARD_ENFORCE"]})),
        );
    }

    let executor_profile = request
        .scope_constraints
        .executor_profile
        .as_ref()
        .and_then(|name| cfg.execution_governance.executor_profiles.get(name));
    if request.side_effect_flags.shell
        && request.caller_path != "service"
        && request.scope_constraints.executor_profile.is_none()
    {
        return Err(
            KernelError::new(
                ErrorCode::CapabilityDenied,
                "shell-backed execution requires an executor profile",
            )
            .with_details(json!({"reason_codes":["EXECUTOR_PROFILE_MISSING"]})),
        );
    }
    if request.scope_constraints.executor_profile.is_some() && executor_profile.is_none() {
        return Err(
            KernelError::new(
                ErrorCode::CapabilityDenied,
                "execution request referenced an unknown executor profile",
            )
            .with_details(json!({"reason_codes":["EXECUTOR_PROFILE_UNKNOWN"]})),
        );
    }

    if request.side_effect_flags.write_repo && request.scope_constraints.write.is_empty() {
        return Err(
            KernelError::new(
                ErrorCode::CapabilityDenied,
                "repo-mutating execution requires explicit write scope",
            )
            .with_details(json!({"reason_codes":["WRITE_SCOPE_MISSING"]})),
        );
    }

    if let Some(profile) = executor_profile {
        if profile.require_hard_enforce
            && effective_policy_mode != cfg.execution_governance.protected_policy_mode
        {
            return Err(
                KernelError::new(
                    ErrorCode::CapabilityDenied,
                    "elevated executor profile requires hard-enforce posture",
                )
                .with_details(json!({"reason_codes":["ELEVATED_EXECUTOR_REQUIRES_HARD_ENFORCE"]})),
            );
        }
        if profile.require_human_review || request.review_requirements.human_approval {
            let approved = std::env::var("OCTON_EXECUTION_HUMAN_APPROVED")
                .unwrap_or_default()
                .eq_ignore_ascii_case("true");
            if !approved {
                return Err(
                    KernelError::new(
                        ErrorCode::CapabilityDenied,
                        "human approval is required for this execution",
                    )
                    .with_details(json!({"reason_codes":["HUMAN_APPROVAL_REQUIRED"]})),
                );
            }
        }
        if request.review_requirements.quorum {
            let has_quorum = std::env::var("OCTON_EXECUTION_QUORUM_TOKEN")
                .map(|value| !value.trim().is_empty())
                .unwrap_or(false);
            if !has_quorum {
                return Err(
                    KernelError::new(
                        ErrorCode::CapabilityDenied,
                        "quorum evidence is required for this execution",
                    )
                    .with_details(json!({"reason_codes":["QUORUM_EVIDENCE_REQUIRED"]})),
                );
            }
        }
        if profile.require_rollback_metadata || request.review_requirements.rollback_metadata {
            let has_rollback = std::env::var("OCTON_EXECUTION_ROLLBACK_REF")
                .map(|value| !value.trim().is_empty())
                .unwrap_or(false);
            if !has_rollback {
                return Err(
                    KernelError::new(
                        ErrorCode::CapabilityDenied,
                        "rollback metadata is required for this execution",
                    )
                    .with_details(json!({"reason_codes":["ROLLBACK_METADATA_REQUIRED"]})),
                );
            }
        }
    }

    if is_critical_action(cfg, request, executor_profile)
        && effective_policy_mode != cfg.execution_governance.protected_policy_mode
    {
        return Err(
            KernelError::new(
                ErrorCode::CapabilityDenied,
                "critical action denied outside hard-enforce posture",
            )
            .with_details(json!({"reason_codes":["CRITICAL_ACTION_REQUIRES_HARD_ENFORCE"]})),
        );
    }

    let granted_capabilities = if let Some(service) = service {
        policy.decide_allow(service)?
    } else {
        dedupe_strings(&request.requested_capabilities)
    };
    if granted_capabilities.is_empty() {
        return Err(
            KernelError::new(
                ErrorCode::CapabilityDenied,
                "execution request did not resolve any granted capabilities",
            )
            .with_details(json!({"reason_codes":["GRANTED_CAPABILITIES_EMPTY"]})),
        );
    }

    let mut review_metadata = BTreeMap::new();
    if std::env::var("OCTON_EXECUTION_HUMAN_APPROVED")
        .unwrap_or_default()
        .eq_ignore_ascii_case("true")
    {
        review_metadata.insert("human_approval".to_string(), "true".to_string());
    }
    if let Ok(value) = std::env::var("OCTON_EXECUTION_QUORUM_TOKEN") {
        if !value.trim().is_empty() {
            review_metadata.insert("quorum_token".to_string(), value);
        }
    }
    if let Ok(value) = std::env::var("OCTON_EXECUTION_ROLLBACK_REF") {
        if !value.trim().is_empty() {
            review_metadata.insert("rollback_ref".to_string(), value);
        }
    }

    let policy_artifacts = compose_policy_receipt(
        cfg,
        request,
        &intent_ref,
        &actor_ref,
        &effective_policy_mode,
    )?;
    if !policy_artifacts.allow {
        return Err(
            KernelError::new(
                ErrorCode::CapabilityDenied,
                policy_artifacts
                    .remediation
                    .clone()
                    .unwrap_or_else(|| "ACP denied execution".to_string()),
            )
            .with_details(json!({
                "reason_codes": policy_artifacts.reason_codes,
                "decision": match policy_artifacts.decision {
                    ExecutionDecision::Allow => "ALLOW",
                    ExecutionDecision::StageOnly => "STAGE_ONLY",
                    ExecutionDecision::Deny => "DENY",
                    ExecutionDecision::Escalate => "ESCALATE",
                }
            })),
        );
    }

    Ok(GrantBundle {
        grant_id: format!("grant-{}", request.request_id),
        request_id: request.request_id.clone(),
        decision: ExecutionDecision::Allow,
        granted_capabilities,
        scope_constraints: request.scope_constraints.clone(),
        effective_policy_mode,
        reason_codes: if policy_artifacts.reason_codes.is_empty() {
            vec!["EXECUTION_AUTHORIZED".to_string()]
        } else {
            policy_artifacts.reason_codes.clone()
        },
        review_metadata,
        expires_after: None,
        receipt_requirements: vec![
            "execution-request.json".to_string(),
            "policy-decision.json".to_string(),
            "grant-bundle.json".to_string(),
            "side-effects.json".to_string(),
            "outcome.json".to_string(),
            "execution-receipt.json".to_string(),
        ],
        environment_class: environment,
        intent_ref,
        actor_ref,
        policy_receipt_path: policy_artifacts.receipt_path,
        policy_digest_path: policy_artifacts.digest_path,
        instruction_manifest_path: policy_artifacts.instruction_manifest_path,
    })
}

pub fn artifact_root_from_relative(repo_root: &Path, relative_root: &str, request_id: &str) -> PathBuf {
    repo_root.join(relative_root).join(request_id)
}

pub fn write_execution_start(
    root: &Path,
    request: &ExecutionRequest,
    grant: &GrantBundle,
) -> anyhow::Result<ExecutionArtifactPaths> {
    fs::create_dir_all(root)
        .with_context(|| format!("create execution artifact root {}", root.display()))?;
    let paths = ExecutionArtifactPaths::new(root.to_path_buf());
    write_json(
        &paths.request,
        &json!({
            "schema_version": "execution-request-v1",
            "request": request,
            "resolved_intent_ref": grant.intent_ref,
            "resolved_actor_ref": grant.actor_ref,
        }),
    )?;
    write_json(
        &paths.decision,
        &json!({
            "schema_version": "execution-authorization-v1",
            "decision": grant.decision,
            "reason_codes": grant.reason_codes,
            "effective_policy_mode": grant.effective_policy_mode,
            "environment_class": grant.environment_class,
        }),
    )?;
    write_json(
        &paths.grant,
        &json!({
            "schema_version": "execution-grant-v1",
            "grant": grant,
        }),
    )?;
    Ok(paths)
}

pub fn finalize_execution(
    paths: &ExecutionArtifactPaths,
    request: &ExecutionRequest,
    grant: &GrantBundle,
    started_at: &str,
    outcome: &ExecutionOutcome,
    side_effects: &SideEffectSummary,
) -> anyhow::Result<()> {
    write_json(&paths.side_effects, side_effects)?;
    write_json(&paths.outcome, outcome)?;
    let override_requested = request
        .policy_mode_requested
        .as_ref()
        .map(|value| value != &grant.effective_policy_mode)
        .unwrap_or(false);
    let receipt = ExecutionReceipt {
        schema_version: "execution-receipt-v1".to_string(),
        request_id: request.request_id.clone(),
        grant_id: grant.grant_id.clone(),
        target_id: request.target_id.clone(),
        action_type: request.action_type.clone(),
        path_type: request.caller_path.clone(),
        environment_class: grant.environment_class.as_str().to_string(),
        intent_ref: grant.intent_ref.clone(),
        actor_ref: grant.actor_ref.clone(),
        requested_capabilities: request.requested_capabilities.clone(),
        granted_capabilities: grant.granted_capabilities.clone(),
        policy_mode_requested: request
            .policy_mode_requested
            .clone()
            .unwrap_or_else(|| grant.effective_policy_mode.clone()),
        policy_mode_effective: grant.effective_policy_mode.clone(),
        decision: grant.decision.clone(),
        reason_codes: grant.reason_codes.clone(),
        touched_scope: side_effects.touched_scope.clone(),
        side_effects: side_effects.clone(),
        override_requested,
        override_accepted: !override_requested,
        ai_review_enforced: env_bool("AI_GATE_ENFORCE") || env_bool("OCTON_AI_GATE_ENFORCE"),
        autonomy_policy_enforced: env_bool("AUTONOMY_POLICY_ENFORCE")
            || env_bool("OCTON_AUTONOMY_POLICY_ENFORCE"),
        evidence_links: evidence_links(paths, grant),
        timestamps: ReceiptTimestamps {
            started_at: started_at.to_string(),
            completed_at: outcome.completed_at.clone(),
        },
    };
    write_json(&paths.receipt, &receipt)?;
    Ok(())
}

pub fn resolve_executor_profile<'a>(
    cfg: &'a RuntimeConfig,
    name: &str,
) -> CoreResult<&'a ExecutorProfileConfig> {
    cfg.execution_governance
        .executor_profiles
        .get(name)
        .ok_or_else(|| {
            KernelError::new(
                ErrorCode::CapabilityDenied,
                format!("unknown executor profile '{}'", name),
            )
            .with_details(json!({"reason_codes":["EXECUTOR_PROFILE_UNKNOWN"]}))
        })
}

pub fn build_executor_command(spec: ExecutorCommandSpec<'_>) -> CoreResult<(Command, Vec<String>)> {
    let mut command = Command::new(spec.executor_bin);
    let blocked_flags = dangerous_flags_for(&spec.kind)
        .into_iter()
        .filter(|_| !spec.profile.dangerous_flags_allowed)
        .collect::<Vec<_>>();
    match spec.kind {
        ManagedExecutorKind::Codex => {
            command
                .arg("exec")
                .arg("--ephemeral")
                .arg("--skip-git-repo-check")
                .arg("--cd")
                .arg(spec.repo_root);
            if spec.profile.dangerous_flags_allowed {
                command.arg("--full-auto");
            }
            if let Some(output_path) = spec.output_path {
                command.arg("--output-last-message").arg(output_path);
            }
        }
        ManagedExecutorKind::Claude => {
            command.arg("-p").arg("--output-format").arg("text");
            if spec.profile.dangerous_flags_allowed {
                command
                    .arg("--permission-mode")
                    .arg("bypassPermissions");
            }
        }
    }
    if let Some(model) = spec.model {
        command.arg("--model").arg(model);
    }
    command.current_dir(spec.repo_root);
    Ok((command, blocked_flags))
}

pub fn now_rfc3339() -> anyhow::Result<String> {
    Ok(time::OffsetDateTime::now_utc().format(&time::format_description::well_known::Rfc3339)?)
}

fn env_bool(name: &str) -> bool {
    std::env::var(name)
        .map(|value| value.eq_ignore_ascii_case("true"))
        .unwrap_or(false)
}

fn write_json(path: &Path, value: &impl Serialize) -> anyhow::Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)
            .with_context(|| format!("create parent directory {}", parent.display()))?;
    }
    fs::write(path, serde_json::to_vec_pretty(value)?)
        .with_context(|| format!("write {}", path.display()))
}

fn evidence_links(paths: &ExecutionArtifactPaths, grant: &GrantBundle) -> BTreeMap<String, String> {
    let mut links = BTreeMap::new();
    links.insert("request".to_string(), path_tail(&paths.root, &paths.request));
    links.insert("decision".to_string(), path_tail(&paths.root, &paths.decision));
    links.insert("grant".to_string(), path_tail(&paths.root, &paths.grant));
    links.insert("side_effects".to_string(), path_tail(&paths.root, &paths.side_effects));
    links.insert("outcome".to_string(), path_tail(&paths.root, &paths.outcome));
    links.insert("receipt".to_string(), path_tail(&paths.root, &paths.receipt));
    if let Some(path) = &grant.policy_receipt_path {
        links.insert("policy_receipt".to_string(), path.clone());
    }
    if let Some(path) = &grant.policy_digest_path {
        links.insert("policy_digest".to_string(), path.clone());
    }
    if let Some(path) = &grant.instruction_manifest_path {
        links.insert("instruction_manifest".to_string(), path.clone());
    }
    links
}

fn path_tail(root: &Path, path: &Path) -> String {
    path.strip_prefix(root)
        .unwrap_or(path)
        .display()
        .to_string()
}

fn current_branch(repo_root: &Path) -> Option<String> {
    let head_path = repo_root.join(".git/HEAD");
    let head = fs::read_to_string(head_path).ok()?;
    let head = head.trim();
    if let Some(rest) = head.strip_prefix("ref: ") {
        return rest.rsplit('/').next().map(ToOwned::to_owned);
    }
    None
}

fn dedupe_strings(values: &[String]) -> Vec<String> {
    let mut set = BTreeSet::new();
    values
        .iter()
        .filter(|value| set.insert((*value).clone()))
        .cloned()
        .collect()
}

fn is_critical_action(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    executor_profile: Option<&ExecutorProfileConfig>,
) -> bool {
    cfg.execution_governance
        .critical_action_types
        .contains(&request.action_type)
        || request.side_effect_flags.publication
        || request.side_effect_flags.branch_mutation
        || executor_profile
            .map(|profile| profile.require_hard_enforce)
            .unwrap_or(false)
}

fn dangerous_flags_for(kind: &ManagedExecutorKind) -> Vec<String> {
    match kind {
        ManagedExecutorKind::Codex => vec!["--full-auto".to_string()],
        ManagedExecutorKind::Claude => vec!["--permission-mode bypassPermissions".to_string()],
    }
}

struct PolicyArtifacts {
    allow: bool,
    decision: ExecutionDecision,
    reason_codes: Vec<String>,
    remediation: Option<String>,
    receipt_path: Option<String>,
    digest_path: Option<String>,
    instruction_manifest_path: Option<String>,
}

fn compose_policy_receipt(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    intent_ref: &IntentRef,
    actor_ref: &ActorRef,
    effective_policy_mode: &str,
) -> CoreResult<PolicyArtifacts> {
    let policy_runner = cfg.repo_root.join(".octon/framework/engine/runtime/policy");
    let policy_file = cfg
        .repo_root
        .join(".octon/framework/capabilities/governance/policy/deny-by-default.v2.yml");
    if !policy_runner.is_file() || !policy_file.is_file() {
        return Ok(PolicyArtifacts {
            allow: true,
            decision: ExecutionDecision::Allow,
            reason_codes: vec!["EXECUTION_AUTHORIZED".to_string()],
            remediation: None,
            receipt_path: None,
            digest_path: None,
            instruction_manifest_path: None,
        });
    }

    let request_path = unique_temp_file(&format!("policy-request-{}", request.request_id), "json");
    let run_root = cfg
        .repo_root
        .join(".octon/state/evidence/runs")
        .join(&request.request_id);
    let receipt_path = run_root.join("receipt.latest.json");
    let digest_path = run_root.join("digest.latest.md");
    let instruction_manifest_path = run_root.join("instruction-layer-manifest.json");

    let request_json = build_policy_request_json(
        cfg,
        request,
        intent_ref,
        actor_ref,
        effective_policy_mode,
    )?;

    fs::write(
        &request_path,
        serde_json::to_vec_pretty(&request_json)
            .map_err(|e| KernelError::new(ErrorCode::Internal, format!("failed to serialize policy request: {e}")))?,
    )
        .map_err(|e| KernelError::new(ErrorCode::Internal, format!("failed to write policy request temp file: {e}")))?;
    let receipt_output = Command::new(&policy_runner)
        .arg("acp-enforce")
        .arg("--policy")
        .arg(&policy_file)
        .arg("--request")
        .arg(&request_path)
        .arg("--emit-receipt")
        .arg("--run-id")
        .arg(&request.request_id)
        .output()
        .map_err(|e| KernelError::new(ErrorCode::Internal, format!("failed to spawn ACP execution flow: {e}")))?;
    fs::remove_file(&request_path).ok();
    let stdout = String::from_utf8_lossy(&receipt_output.stdout).to_string();
    let decision_json: serde_json::Value = serde_json::from_str(stdout.trim()).map_err(|e| {
        KernelError::new(
            ErrorCode::Internal,
            format!("failed to parse ACP decision output: {e}"),
        )
    })?;
    let decision = match decision_json
        .get("decision")
        .and_then(|value| value.as_str())
        .unwrap_or("DENY")
    {
        "ALLOW" => ExecutionDecision::Allow,
        "STAGE_ONLY" => ExecutionDecision::StageOnly,
        "ESCALATE" => ExecutionDecision::Escalate,
        _ => ExecutionDecision::Deny,
    };
    if !receipt_output.status.success() && !matches!(decision, ExecutionDecision::Deny | ExecutionDecision::StageOnly | ExecutionDecision::Escalate) {
        return Err(KernelError::new(
            ErrorCode::Internal,
            format!(
                "ACP execution flow failed: {}",
                String::from_utf8_lossy(&receipt_output.stderr)
            ),
        ));
    }

    if !receipt_path.is_file() {
        return Err(KernelError::new(
            ErrorCode::Internal,
            "policy receipt writer did not emit receipt.latest.json",
        ));
    }

    Ok(PolicyArtifacts {
        allow: decision_json
            .get("allow")
            .and_then(|value| value.as_bool())
            .unwrap_or(false),
        decision,
        reason_codes: decision_json
            .get("reason_codes")
            .and_then(|value| value.as_array())
            .map(|items| {
                items
                    .iter()
                    .filter_map(|item| item.as_str().map(ToOwned::to_owned))
                    .collect::<Vec<_>>()
            })
            .unwrap_or_default(),
        remediation: decision_json
            .get("remediation")
            .and_then(|value| value.as_str())
            .map(ToOwned::to_owned),
        receipt_path: Some(path_tail(&cfg.repo_root, &receipt_path)),
        digest_path: if digest_path.is_file() {
            Some(path_tail(&cfg.repo_root, &digest_path))
        } else {
            None
        },
        instruction_manifest_path: if instruction_manifest_path.is_file() {
            Some(path_tail(&cfg.repo_root, &instruction_manifest_path))
        } else {
            None
        },
    })
}

fn build_policy_request_json(
    cfg: &RuntimeConfig,
    request: &ExecutionRequest,
    intent_ref: &IntentRef,
    actor_ref: &ActorRef,
    effective_policy_mode: &str,
) -> CoreResult<serde_json::Value> {
    let request_json = serde_json::to_vec(request)
        .map_err(|e| KernelError::new(ErrorCode::Internal, format!("failed to serialize execution request: {e}")))?;
    let instruction_layers = json!([
        {
            "layer_id": "provider",
            "source": "upstream",
            "sha256": zero_sha256(),
            "bytes": 0,
            "visibility": "partial"
        },
        {
            "layer_id": "system",
            "source": "octon-system",
            "sha256": zero_sha256(),
            "bytes": 0,
            "visibility": "partial"
        },
        {
            "layer_id": "developer",
            "source": "AGENTS.md",
            "sha256": sha256_file(&cfg.repo_root.join(".octon/AGENTS.md")),
            "bytes": file_size(&cfg.repo_root.join(".octon/AGENTS.md")),
            "visibility": "full"
        },
        {
            "layer_id": "user",
            "source": "execution-request",
            "sha256": sha256_bytes(&request_json),
            "bytes": request_json.len(),
            "visibility": "full"
        }
    ]);

    Ok(json!({
        "run_id": request.request_id,
        "actor": {
            "id": actor_ref.id,
            "type": actor_ref.kind
        },
        "profile": policy_profile_for_request(request),
        "phase": "stage",
        "intent": format!("execution authorization for {}", request.target_id),
        "boundaries": request.caller_path,
        "operation": {
            "class": "execution.authorize",
            "target": {
                "material_side_effect": material_side_effect(request),
                "telemetry_profile": if effective_policy_mode == "hard-enforce" { "full" } else { "minimal" },
                "workflow_mode": "autonomous",
                "capability_classification": "agent-ready"
            },
            "targets": [request.target_id],
            "resources": request.scope_constraints.write
        },
        "intent_ref": {
            "id": intent_ref.id,
            "version": intent_ref.version
        },
        "boundary_id": request.caller_path,
        "boundary_set_version": "v1",
        "workflow_mode": "autonomous",
        "capability_classification": "agent-ready",
        "reversibility": {
            "reversible": true,
            "primitive": "git.revert_commit",
            "rollback_handle": format!("rollback-{}", request.request_id),
            "recovery_window": "P14D"
        },
        "evidence": [
            {
                "type": "diff",
                "ref": format!(".octon/state/evidence/runs/{}/execution-request.json", request.request_id)
            }
        ],
        "instruction_layers": instruction_layers,
        "context_acquisition": {
            "file_reads": 0,
            "search_queries": 0,
            "commands": 1,
            "subagent_spawns": 0,
            "duration_ms": 0
        },
        "context_overhead_ratio": 0
    }))
}

fn policy_profile_for_request(request: &ExecutionRequest) -> &'static str {
    if request.side_effect_flags.publication || request.action_type == "release_publication" {
        "release-readiness"
    } else if request.side_effect_flags.write_repo || request.side_effect_flags.shell {
        "refactor"
    } else {
        "docs"
    }
}

fn material_side_effect(request: &ExecutionRequest) -> bool {
    request.side_effect_flags.write_repo
        || request.side_effect_flags.shell
        || request.side_effect_flags.network
        || request.side_effect_flags.model_invoke
        || request.side_effect_flags.state_mutation
        || request.side_effect_flags.publication
        || request.side_effect_flags.branch_mutation
}

fn unique_temp_file(stem: &str, extension: &str) -> PathBuf {
    let millis = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map(|duration| duration.as_millis())
        .unwrap_or(0);
    std::env::temp_dir().join(format!("{stem}-{millis}-{}.{}", std::process::id(), extension))
}

fn zero_sha256() -> String {
    "0".repeat(64)
}

fn sha256_file(path: &Path) -> String {
    fs::read(path)
        .map(|bytes| sha256_bytes(&bytes))
        .unwrap_or_else(|_| zero_sha256())
}

fn sha256_bytes(bytes: &[u8]) -> String {
    format!("{:x}", Sha256::digest(bytes))
}

fn file_size(path: &Path) -> usize {
    fs::metadata(path).map(|meta| meta.len() as usize).unwrap_or(0)
}

#[cfg(test)]
mod tests {
    use super::*;
    use octon_core::config::{ExecutionGovernanceConfig, PolicyConfig, ReceiptRootsConfig, RuntimeConfig};
    use std::fs;
    use std::time::{SystemTime, UNIX_EPOCH};

    fn temp_runtime_config() -> RuntimeConfig {
        let stamp = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("time should move forward")
            .as_nanos();
        let base = std::env::temp_dir().join(format!(
            "octon-auth-test-{}-{stamp}",
            std::process::id()
        ));
        let _ = fs::remove_dir_all(&base);
        fs::create_dir_all(base.join(".octon/instance/cognition/context/shared"))
            .expect("create intent dir");
        fs::write(
            base.join(".octon/instance/cognition/context/shared/intent.contract.yml"),
            "intent_id: intent://test/example\nversion: 1.0.0\n",
        )
        .expect("write intent contract");
        RuntimeConfig {
            octon_dir: base.join(".octon"),
            repo_root: base,
            state_dir: std::env::temp_dir().join("octon-auth-state"),
            policy: PolicyConfig::default(),
            execution_governance: ExecutionGovernanceConfig {
                receipt_roots: ReceiptRootsConfig::default(),
                ..ExecutionGovernanceConfig::default()
            },
            ndjson_max_line_bytes: 1024,
            wasmtime_cache_config: None,
        }
    }

    fn minimal_request() -> ExecutionRequest {
        ExecutionRequest {
            request_id: "req-1".to_string(),
            caller_path: "workflow-stage".to_string(),
            action_type: "execute_stage".to_string(),
            target_id: "test-stage".to_string(),
            requested_capabilities: vec!["workflow.stage.execute".to_string()],
            side_effect_flags: SideEffectFlags {
                write_evidence: true,
                shell: true,
                model_invoke: true,
                ..SideEffectFlags::default()
            },
            risk_tier: "low".to_string(),
            locality_scope: None,
            intent_ref: None,
            actor_ref: Some(default_actor_ref()),
            parent_run_ref: None,
            review_requirements: ReviewRequirements::default(),
            scope_constraints: ScopeConstraints {
                read: vec!["repo-root".to_string()],
                write: vec!["workflow-evidence".to_string()],
                executor_profile: Some("read_only_analysis".to_string()),
                locality_scope: None,
            },
            policy_mode_requested: Some("soft-enforce".to_string()),
            environment_hint: Some("development".to_string()),
            metadata: BTreeMap::new(),
        }
    }

    #[test]
    fn development_mode_allows_soft_enforce() {
        let cfg = temp_runtime_config();
        let policy = PolicyEngine::new(cfg.clone());
        let grant = authorize_execution(&cfg, &policy, &minimal_request(), None)
            .expect("development request should authorize");
        assert_eq!(grant.effective_policy_mode, "soft-enforce");
    }

    #[test]
    fn protected_execution_rejects_soft_enforce() {
        let cfg = temp_runtime_config();
        let policy = PolicyEngine::new(cfg.clone());
        let mut request = minimal_request();
        request.environment_hint = Some("protected".to_string());
        let err = authorize_execution(&cfg, &policy, &request, None)
            .expect_err("protected request must deny soft-enforce");
        assert_eq!(err.code, ErrorCode::CapabilityDenied);
    }

    #[test]
    fn critical_action_requires_hard_enforce() {
        let cfg = temp_runtime_config();
        let policy = PolicyEngine::new(cfg.clone());
        let mut request = minimal_request();
        request.action_type = "mutate_repo".to_string();
        request.side_effect_flags.write_repo = true;
        request.scope_constraints.write = vec!["repo-scope".to_string()];
        let err = authorize_execution(&cfg, &policy, &request, None)
            .expect_err("critical action should deny outside hard-enforce");
        assert_eq!(err.code, ErrorCode::CapabilityDenied);
    }

    #[test]
    fn executor_wrapper_blocks_dangerous_flags_by_default() {
        let cfg = temp_runtime_config();
        let profile = resolve_executor_profile(&cfg, "read_only_analysis")
            .expect("profile should exist");
        let (_, blocked) = build_executor_command(ExecutorCommandSpec {
            kind: ManagedExecutorKind::Codex,
            executor_bin: Path::new("/usr/bin/env"),
            repo_root: &cfg.repo_root,
            output_path: Some(Path::new("/tmp/out.txt")),
            model: None,
            profile,
        })
        .expect("command should build");
        assert_eq!(blocked, vec!["--full-auto".to_string()]);
    }
}
