use anyhow::{anyhow, bail, Context, Result};
use octon_authority_engine::{ProviderRepositoryMutation, VerifiedEffect};
use serde::de::{self, DeserializeSeed, MapAccess, SeqAccess, Visitor};
use serde::{Deserialize, Serialize};
use serde_json::{Map, Value};
use sha2::{Digest, Sha256};
use std::collections::{BTreeMap, BTreeSet};
use std::fmt;
use std::fs::{self, File, OpenOptions};
use std::io::{Read, Write};
use std::os::fd::FromRawFd;
#[cfg(unix)]
use std::os::unix::fs::FileTypeExt;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use std::thread;
use walkdir::WalkDir;

const REPOSITORY: &str = "jamesryancooper/octon";
const PRINCIPAL_LOGIN: &str = "jamesryancooper";
const PRINCIPAL_ID: u64 = 800_837;
const API_VERSION: &str = "2026-03-10";
const MAX_EXACT_INTEGER: u64 = 9_007_199_254_740_991;
const MAX_CREDENTIAL_BYTES: usize = 2_048;
const HANDLE_DOMAIN: &[u8] = b"octon-owner-lane-handle-v1\0";
const HEADER_DOMAIN: &[u8] = b"octon-owner-lane-header-v1\0";
const REVOCATION_DOMAIN: &[u8] = b"octon-owner-lane-revocation-body-v1\0";

#[derive(Debug, Clone)]
pub(crate) struct ArtifactPaths {
    pub authorization: PathBuf,
    pub capture_metadata: PathBuf,
    pub operation_plan: PathBuf,
    pub evidence_root: PathBuf,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct AdmissionAuthorization {
    schema_version: String,
    authorization_id: String,
    accepted_review_digest: String,
    run_id: String,
    repository: String,
    base_sha: String,
    candidate_sha: String,
    candidate_tree: String,
    principal: Principal,
    credential_tuple: CredentialTuple,
    operation_plan_digest: String,
    evidence_root: String,
    request_budgets: RequestBudgets,
    allowed_admission_probes: Vec<String>,
    no_resend: bool,
    one_attempt_lock: String,
    replacement_lock: String,
    #[serde(rename = "authorized_at")]
    _authorized_at: String,
}

#[derive(Debug, Clone, Deserialize, Serialize, Eq, PartialEq)]
#[serde(deny_unknown_fields)]
struct Principal {
    login: String,
    id: u64,
}

#[derive(Debug, Clone, Deserialize, Serialize, Eq, PartialEq)]
#[serde(deny_unknown_fields)]
struct CredentialTuple {
    credential_class: String,
    token_prefix: String,
    issuer: String,
    resource_owner: Principal,
    selected_repositories: Vec<String>,
    public_read_boundary: String,
    permissions: Vec<CredentialPermission>,
    capture_channel: String,
    api_version: String,
    issuance_attempt_budget: u64,
    provider_expiry_days: u64,
    local_deadline_seconds: u64,
}

#[derive(Debug, Clone, Deserialize, Serialize, Eq, PartialEq)]
#[serde(deny_unknown_fields)]
struct CredentialPermission {
    name: String,
    level: String,
}

#[derive(Debug, Clone, Deserialize, Serialize, Eq, PartialEq)]
#[serde(deny_unknown_fields)]
struct RequestBudgets {
    identity_probe: u64,
    repository_probe: u64,
    revocation: u64,
    retirement_probe: u64,
    revocation_wait_seconds: u64,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct CredentialCaptureMetadata {
    schema_version: String,
    run_id: String,
    authorization_digest: String,
    operation_plan_digest: String,
    capture_source: String,
    issuance_attempts: u64,
    issued_at: String,
    provider_expires_at: String,
    local_deadline: String,
    resource_owner: Principal,
    selected_repositories: Vec<String>,
    permissions: Vec<CredentialPermission>,
    no_secret_retained: bool,
    #[serde(rename = "recorded_at")]
    _recorded_at: String,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct OperationPlan {
    schema_version: String,
    plan_id: String,
    run_id: String,
    repository: String,
    base_sha: String,
    head_sha: String,
    candidate_tree: String,
    branch: String,
    accepted_review_digest: String,
    one_attempt_lock: String,
    replacement_lock: String,
    tools: BTreeMap<String, ToolBinding>,
    attestation_template: AttestationTemplate,
    operations: Vec<PlannedOperation>,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct AttestationTemplate {
    repository: String,
    base_sha: String,
    candidate_sha: String,
    candidate_tree: String,
    principal: Principal,
    accepted_review_digest: String,
    attested: bool,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct PlannedOperation {
    id: String,
    sequence: u64,
    stage: OperationStage,
    kind: OperationKind,
    method: String,
    url: Value,
    authenticated: bool,
    no_resend: bool,
    expected_statuses: Vec<u16>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    body: Option<Value>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    refspec: Option<Value>,
    template_digest: String,
}

#[derive(Debug, Clone, Copy, Deserialize, Serialize, Eq, PartialEq)]
#[serde(rename_all = "snake_case")]
enum OperationStage {
    Admission,
    Prefix,
    Suffix,
    Terminal,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct IssuanceOutcome {
    schema_version: String,
    run_id: String,
    authorization_digest: String,
    capture_metadata_digest: String,
    operation_plan_digest: String,
    issued: bool,
    issuance_attempts: u64,
    issuer: String,
    principal: Principal,
    nonce_salted_handle_digest: String,
    header_digest: String,
    revocation_body_digest: String,
    no_secret_retained: bool,
    #[serde(rename = "recorded_at")]
    _recorded_at: String,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct LifecycleEnvelope {
    schema_version: String,
    run_id: String,
    authorization_digest: String,
    capture_metadata_digest: String,
    operation_plan_digest: String,
    issuance_outcome_digest: String,
    credential_handle_nonce: String,
    credential_handle_digest: String,
    credential_tuple: CredentialTuple,
    request_budgets: RequestBudgets,
    no_resend: bool,
    replacement_lock: String,
    actual_reached_phase: String,
    evidence_root: String,
    recorded_at: String,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct AdmissionReceipt {
    schema_version: String,
    run_id: String,
    lifecycle_digest: String,
    operation_plan_digest: String,
    identity_status: u16,
    repository_status: u16,
    login: String,
    id: u64,
    api_version: String,
    accepted_permissions: BTreeMap<String, String>,
    identity_request_digest: String,
    identity_response_digest: String,
    repository_request_digest: String,
    repository_response_digest: String,
    trusted_capture_facts_digest: String,
    pagination_complete: bool,
    admitted: bool,
    prior_authenticated_200: bool,
    #[serde(rename = "recorded_at")]
    _recorded_at: String,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct Attestation {
    schema_version: String,
    run_id: String,
    manifest_digest: String,
    authorization_digest: String,
    admission_digest: String,
    repository: String,
    base_sha: String,
    candidate_sha: String,
    candidate_tree: String,
    principal: Principal,
    accepted_review_digest: String,
    attested: bool,
    #[serde(rename = "recorded_at")]
    _recorded_at: String,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct ToolBinding {
    canonical_path: String,
    sha256: String,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct OperationManifest {
    schema_version: String,
    run_id: String,
    authorization_digest: String,
    capture_metadata_digest: String,
    issuance_outcome_digest: String,
    lifecycle_digest: String,
    admission_digest: String,
    operation_plan_digest: String,
    repository: String,
    base_sha: String,
    head_sha: String,
    candidate_tree: String,
    branch: String,
    attestation_template_digest: String,
    operation_template_digest: String,
    one_attempt_lock: String,
    replacement_lock: String,
    tools: BTreeMap<String, ToolBinding>,
    operations: Vec<PlannedOperation>,
    recorded_at: String,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct OwnerLaneOperation {
    id: String,
    sequence: u64,
    stage: OperationStage,
    kind: OperationKind,
    method: String,
    url: String,
    authenticated: bool,
    no_resend: bool,
    expected_statuses: Vec<u16>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    body: Option<Value>,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    refspec: Option<String>,
    template_digest: String,
    request_digest: String,
}

#[derive(Debug, Clone, Copy, Deserialize, Serialize, Eq, PartialEq)]
#[serde(rename_all = "snake_case")]
enum OperationKind {
    IdentityProbe,
    RepositoryProbe,
    WorkflowDisable,
    WorkflowRunCancel,
    GitPush,
    PullRequestCreate,
    PullRequestReconcile,
    MarkerCreate,
    RulesetUpdate,
    CheckTrigger,
    PullRequestMerge,
    MainPostRead,
    CredentialRevoke,
    TerminalIdentityProbe,
}

#[derive(Debug)]
struct ValidatedPlan {
    authorization: AdmissionAuthorization,
    capture_metadata: CredentialCaptureMetadata,
    operation_plan: OperationPlan,
    authorization_digest: String,
    capture_metadata_digest: String,
    operation_plan_digest: String,
    evidence_root: PathBuf,
    journal_path: PathBuf,
    issuance_path: PathBuf,
    lifecycle_path: PathBuf,
    admission_path: PathBuf,
    manifest_path: PathBuf,
    attestation_path: PathBuf,
    completed_prefix_path: PathBuf,
    retirement_path: PathBuf,
}

pub(crate) struct PreparedOwnerLane {
    plan: ValidatedPlan,
}

impl PreparedOwnerLane {
    pub(crate) fn run_id(&self) -> &str {
        &self.plan.authorization.run_id
    }

    pub(crate) fn authority_scope(&self) -> String {
        format!(
            "github://repo/{REPOSITORY}/rp00-owner-lane-cutover/run/{}/authorization/{}/review/{}/base/{}/candidate/{}/tree/{}/plan/{}/principal/{}:{}",
            self.plan.authorization.run_id,
            self.plan.authorization.authorization_id,
            self.plan.authorization.accepted_review_digest,
            self.plan.authorization.base_sha,
            self.plan.authorization.candidate_sha,
            self.plan.authorization.candidate_tree,
            self.plan.operation_plan_digest,
            self.plan.authorization.principal.login,
            self.plan.authorization.principal.id,
        )
    }
}

#[derive(Debug)]
struct Secret(Vec<u8>);

impl Secret {
    fn expose(&self) -> &[u8] {
        &self.0
    }

    fn zeroize(&mut self) {
        self.0.fill(0);
        self.0.clear();
    }
}

impl Drop for Secret {
    fn drop(&mut self) {
        self.0.fill(0);
    }
}

#[derive(Debug)]
struct SensitiveBuffer(Vec<u8>);

impl SensitiveBuffer {
    fn new() -> Self {
        Self(Vec::new())
    }

    fn expose(&self) -> &[u8] {
        &self.0
    }
}

impl Write for SensitiveBuffer {
    fn write(&mut self, bytes: &[u8]) -> std::io::Result<usize> {
        self.0.write(bytes)
    }

    fn flush(&mut self) -> std::io::Result<()> {
        self.0.flush()
    }
}

impl Drop for SensitiveBuffer {
    fn drop(&mut self) {
        self.0.fill(0);
    }
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct OperationResult {
    sent: bool,
    status: Option<u16>,
    headers: BTreeMap<String, String>,
    response: Vec<u8>,
}

trait OperationRunner {
    fn run(
        &mut self,
        operation: &OwnerLaneOperation,
        tools: &BTreeMap<String, ToolBinding>,
        secret: &[u8],
    ) -> Result<OperationResult>;

    fn fifo_removed(&self) -> bool {
        true
    }
}

struct SystemRunner<'a> {
    repo_root: &'a Path,
    fifo_active: bool,
}

#[derive(Debug, Serialize)]
struct JournalEvent<'a> {
    schema_version: &'static str,
    phase: &'a str,
    operation_id: &'a str,
    sequence: u64,
    request_digest: &'a str,
    #[serde(skip_serializing_if = "Option::is_none")]
    status: Option<u16>,
    #[serde(skip_serializing_if = "Option::is_none")]
    response_digest: Option<String>,
}

#[derive(Debug, Serialize)]
struct RetirementReceipt<'a> {
    schema_version: &'static str,
    run_id: &'a str,
    authorization_digest: &'a str,
    operation_plan_digest: &'a str,
    lifecycle_digest: &'a str,
    #[serde(skip_serializing_if = "Option::is_none")]
    manifest_digest: Option<&'a str>,
    #[serde(skip_serializing_if = "Option::is_none")]
    attestation_digest: Option<&'a str>,
    #[serde(skip_serializing_if = "Option::is_none")]
    completed_prefix_digest: Option<&'a str>,
    revocation_status: u16,
    terminal_identity_status: u16,
    prior_authenticated_200: bool,
    local_buffer_zeroized: bool,
    fifo_removed: bool,
    secret_census_empty: bool,
    retired: bool,
    completed_at: String,
}

#[derive(Debug, Serialize)]
struct OperationConstructionReceipt<'a> {
    schema_version: &'static str,
    run_id: &'a str,
    manifest_digest: &'a str,
    attestation_digest: &'a str,
    completed_prefix_digest: &'a str,
    operation_id: &'a str,
    sequence: u64,
    template_digest: &'a str,
    binding_digest: &'a str,
    resolved_request_digest: &'a str,
    normalized_template_digest: &'a str,
    canonical_pr_number: u64,
    normalized: bool,
    constructed_at: String,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct CompletedPrefixReceipt {
    schema_version: String,
    run_id: String,
    manifest_digest: String,
    attestation_digest: String,
    operation_plan_digest: String,
    completed_operation_ids: Vec<String>,
    last_sequence: u64,
    journal_digest: String,
    pull_request_create_request_digest: String,
    pull_request_create_response_digest: String,
    pull_request_reconcile_request_digest: String,
    pull_request_reconcile_response_digest: String,
    canonical_pr_number: u64,
    repository: String,
    base_sha: String,
    head_sha: String,
    candidate_tree: String,
    branch: String,
    terminal_state: String,
    recorded_at: String,
}

pub(crate) fn prepare(repo_root: &Path, paths: &ArtifactPaths) -> Result<PreparedOwnerLane> {
    Ok(PreparedOwnerLane {
        plan: validate_plan(repo_root, paths)?,
    })
}

pub(crate) fn execute_with_verified_effect(
    repo_root: &Path,
    prepared: &PreparedOwnerLane,
    credential_fd: i32,
    _effect: &VerifiedEffect<ProviderRepositoryMutation>,
) -> Result<()> {
    create_dir_all_sync(&prepared.plan.evidence_root)?;
    let mut secret = read_credential_fd(credential_fd)?;
    let mut runner = SystemRunner {
        repo_root,
        fifo_active: false,
    };
    execute_staged_plan(&prepared.plan, &mut secret, &mut runner)
}

fn validate_plan(repo_root: &Path, paths: &ArtifactPaths) -> Result<ValidatedPlan> {
    let authorization_value = read_strict_json(&paths.authorization)?;
    let capture_value = read_strict_json(&paths.capture_metadata)?;
    let plan_value = read_strict_json(&paths.operation_plan)?;

    let authorization: AdmissionAuthorization =
        serde_json::from_value(authorization_value.clone())?;
    let capture_metadata: CredentialCaptureMetadata =
        serde_json::from_value(capture_value.clone())?;
    let operation_plan: OperationPlan = serde_json::from_value(plan_value.clone())?;

    require_schema(
        &authorization.schema_version,
        "owner-lane-credential-admission-authorization-v1",
    )?;
    require_schema(
        &capture_metadata.schema_version,
        "owner-lane-credential-capture-metadata-v1",
    )?;
    require_schema(
        &operation_plan.schema_version,
        "owner-lane-operation-plan-v1",
    )?;

    let authorization_digest = digest_value(&authorization_value)?;
    let capture_metadata_digest = digest_value(&capture_value)?;
    let operation_plan_digest = digest_value(&plan_value)?;
    for digest in [
        authorization.accepted_review_digest.as_str(),
        authorization.operation_plan_digest.as_str(),
        capture_metadata.authorization_digest.as_str(),
        capture_metadata.operation_plan_digest.as_str(),
        operation_plan.accepted_review_digest.as_str(),
    ] {
        if !is_sha256_digest(digest) {
            bail!("owner-lane pre-capture input contains a malformed SHA-256 digest");
        }
    }
    for sha in [
        authorization.base_sha.as_str(),
        authorization.candidate_sha.as_str(),
        authorization.candidate_tree.as_str(),
        operation_plan.base_sha.as_str(),
        operation_plan.head_sha.as_str(),
        operation_plan.candidate_tree.as_str(),
    ] {
        if !is_lower_hex(sha, 40) {
            bail!("owner-lane pre-capture input contains a malformed Git object id");
        }
    }
    for timestamp in [
        authorization._authorized_at.as_str(),
        capture_metadata.issued_at.as_str(),
        capture_metadata.provider_expires_at.as_str(),
        capture_metadata.local_deadline.as_str(),
        capture_metadata._recorded_at.as_str(),
    ] {
        parse_timestamp(timestamp)?;
    }
    if !valid_run_id(&authorization.run_id)
        || authorization.run_id != capture_metadata.run_id
        || authorization.run_id != operation_plan.run_id
    {
        bail!("owner-lane pre-capture inputs do not bind one safe run id");
    }
    if authorization.repository != REPOSITORY || operation_plan.repository != REPOSITORY {
        bail!("owner-lane repository binding must be {REPOSITORY}");
    }
    if authorization.operation_plan_digest != operation_plan_digest
        || capture_metadata.operation_plan_digest != operation_plan_digest
        || capture_metadata.authorization_digest != authorization_digest
    {
        bail!("owner-lane pre-capture digest chain mismatch");
    }
    if authorization.accepted_review_digest != operation_plan.accepted_review_digest
        || authorization.base_sha != operation_plan.base_sha
        || authorization.candidate_sha != operation_plan.head_sha
        || authorization.candidate_tree != operation_plan.candidate_tree
    {
        bail!("owner-lane plan candidate or review binding mismatch");
    }
    if authorization.principal.login != PRINCIPAL_LOGIN
        || authorization.principal.id != PRINCIPAL_ID
        || authorization.principal != authorization.credential_tuple.resource_owner
        || authorization.principal != capture_metadata.resource_owner
    {
        bail!("owner-lane principal and resource owner must be {PRINCIPAL_LOGIN}:{PRINCIPAL_ID}");
    }
    validate_credential_tuple(&authorization.credential_tuple)?;
    validate_capture_metadata_tuple(&authorization, &capture_metadata)?;
    validate_capture_times(&authorization, &capture_metadata)?;
    let expected_probes = vec!["identity".to_string(), "repository".to_string()];
    if authorization.allowed_admission_probes != expected_probes
        || authorization.request_budgets.identity_probe != 1
        || authorization.request_budgets.repository_probe != 1
        || authorization.request_budgets.revocation != 1
        || authorization.request_budgets.retirement_probe != 1
        || authorization.request_budgets.revocation_wait_seconds > 300
        || !authorization.no_resend
        || authorization.one_attempt_lock != "locked"
        || authorization.replacement_lock != "locked-until-retired"
        || operation_plan.one_attempt_lock != authorization.one_attempt_lock
        || operation_plan.replacement_lock != authorization.replacement_lock
    {
        bail!("owner-lane budgets or execution locks are not the closed one-attempt tuple");
    }
    if operation_plan.attestation_template.repository != REPOSITORY
        || operation_plan.attestation_template.base_sha != authorization.base_sha
        || operation_plan.attestation_template.candidate_sha != authorization.candidate_sha
        || operation_plan.attestation_template.candidate_tree != authorization.candidate_tree
        || operation_plan.attestation_template.principal != authorization.principal
        || operation_plan.attestation_template.accepted_review_digest
            != authorization.accepted_review_digest
        || !operation_plan.attestation_template.attested
    {
        bail!("owner-lane attestation template does not bind the authorized candidate");
    }

    let evidence_root = canonical_contained_path(repo_root, &paths.evidence_root)?;
    if authorization.evidence_root != relative_path(repo_root, &evidence_root)? {
        bail!("owner-lane evidence-root binding mismatch");
    }
    validate_tools(&operation_plan.tools)?;
    let fixed_askpass = fs::canonicalize(
        repo_root
            .join(".octon/framework/execution-roles/_ops/scripts/git/git-owner-lane-askpass.sh"),
    )?;
    if Path::new(&operation_plan.tools["askpass"].canonical_path) != fixed_askpass {
        bail!("owner-lane askpass binding is not the fixed repository helper");
    }
    validate_planned_operations(&operation_plan)?;

    Ok(ValidatedPlan {
        authorization,
        capture_metadata,
        operation_plan,
        authorization_digest,
        capture_metadata_digest,
        operation_plan_digest,
        journal_path: evidence_root.join("owner-lane-events.ndjson"),
        issuance_path: evidence_root.join("credential-issuance-outcome-receipt.json"),
        lifecycle_path: evidence_root.join("credential-lifecycle-envelope.json"),
        admission_path: evidence_root.join("credential-admission-receipt.json"),
        manifest_path: evidence_root.join("operation-manifest.json"),
        attestation_path: evidence_root.join("owner-lane-attestation.json"),
        completed_prefix_path: evidence_root.join("completed-prefix-receipt.json"),
        retirement_path: evidence_root.join("credential-retirement-receipt.json"),
        evidence_root,
    })
}

fn validate_credential_tuple(tuple: &CredentialTuple) -> Result<()> {
    let expected_permissions = [
        ("administration", "write"),
        ("actions", "write"),
        ("variables", "write"),
        ("contents", "write"),
        ("pull_requests", "write"),
        ("checks", "read"),
        ("commit_statuses", "read"),
        ("metadata", "read"),
    ];
    if tuple.credential_class != "fine-grained-personal-access-token"
        || tuple.token_prefix != "github_pat_"
        || tuple.issuer != "github.com"
        || tuple.resource_owner.login != PRINCIPAL_LOGIN
        || tuple.resource_owner.id != PRINCIPAL_ID
        || tuple.selected_repositories != [REPOSITORY]
        || tuple.public_read_boundary != "anonymous-equivalent"
        || tuple.capture_channel != "inherited-fd"
        || tuple.api_version != API_VERSION
        || tuple.issuance_attempt_budget != 1
        || tuple.provider_expiry_days != 1
        || tuple.local_deadline_seconds != 3_600
        || tuple.permissions.len() != expected_permissions.len()
        || tuple
            .permissions
            .iter()
            .zip(expected_permissions)
            .any(|(actual, expected)| actual.name != expected.0 || actual.level != expected.1)
    {
        bail!("owner-lane credential tuple is not the closed GitHub fine-grained PAT tuple");
    }
    Ok(())
}

fn validate_capture_metadata_tuple(
    authorization: &AdmissionAuthorization,
    capture: &CredentialCaptureMetadata,
) -> Result<()> {
    if capture.issuance_attempts != 1
        || capture.capture_source != "github-fine-grained-pat-ui"
        || !capture.no_secret_retained
        || capture.selected_repositories != authorization.credential_tuple.selected_repositories
        || capture.permissions != authorization.credential_tuple.permissions
    {
        bail!("owner-lane capture metadata does not match the authorized credential tuple");
    }
    Ok(())
}

fn validate_capture_times(
    authorization: &AdmissionAuthorization,
    capture: &CredentialCaptureMetadata,
) -> Result<()> {
    let authorized_at = parse_timestamp(&authorization._authorized_at)?;
    let issued_at = parse_timestamp(&capture.issued_at)?;
    let provider_expires_at = parse_timestamp(&capture.provider_expires_at)?;
    let local_deadline = parse_timestamp(&capture.local_deadline)?;
    let recorded_at = parse_timestamp(&capture._recorded_at)?;
    if authorized_at > issued_at
        || issued_at > recorded_at
        || provider_expires_at - issued_at != time::Duration::days(1)
        || local_deadline - issued_at != time::Duration::seconds(3_600)
        || authorization.credential_tuple.provider_expiry_days != 1
        || authorization.credential_tuple.local_deadline_seconds != 3_600
    {
        bail!("owner-lane capture lifetime does not match the authorized one-day/60-minute window");
    }
    Ok(())
}

fn parse_timestamp(value: &str) -> Result<time::OffsetDateTime> {
    time::OffsetDateTime::parse(value, &time::format_description::well_known::Rfc3339)
        .context("owner-lane timestamp is not RFC 3339")
}

fn validate_planned_operations(plan: &OperationPlan) -> Result<()> {
    if plan.operations.len() != 14 || plan.branch != "octon-rp00" {
        bail!("owner-lane operation plan must contain the exact 14-operation protocol");
    }
    let required = [
        (OperationStage::Admission, OperationKind::IdentityProbe),
        (OperationStage::Admission, OperationKind::RepositoryProbe),
        (OperationStage::Prefix, OperationKind::WorkflowDisable),
        (OperationStage::Prefix, OperationKind::WorkflowRunCancel),
        (OperationStage::Prefix, OperationKind::GitPush),
        (OperationStage::Prefix, OperationKind::PullRequestCreate),
        (OperationStage::Prefix, OperationKind::PullRequestReconcile),
        (OperationStage::Suffix, OperationKind::MarkerCreate),
        (OperationStage::Suffix, OperationKind::RulesetUpdate),
        (OperationStage::Suffix, OperationKind::CheckTrigger),
        (OperationStage::Suffix, OperationKind::PullRequestMerge),
        (OperationStage::Suffix, OperationKind::MainPostRead),
        (OperationStage::Terminal, OperationKind::CredentialRevoke),
        (
            OperationStage::Terminal,
            OperationKind::TerminalIdentityProbe,
        ),
    ];
    let mut ids = BTreeSet::new();
    for (index, operation) in plan.operations.iter().enumerate() {
        if operation.sequence != index as u64 + 1
            || (operation.stage, operation.kind) != required[index]
            || !valid_operation_id(&operation.id)
            || !ids.insert(operation.id.clone())
            || !operation.no_resend
            || operation.expected_statuses.is_empty()
            || !is_sha256_digest(&operation.template_digest)
        {
            bail!("owner-lane operation plan sequence, stage, kind, or template is invalid");
        }
        if digest_value(&planned_operation_template_value(operation)?)? != operation.template_digest
        {
            bail!(
                "owner-lane operation {} template digest mismatch",
                operation.id
            );
        }
        validate_planned_operation_shape(operation, plan)?;
    }
    Ok(())
}

fn validate_planned_operation_shape(
    operation: &PlannedOperation,
    plan: &OperationPlan,
) -> Result<()> {
    let exact = operation.stage != OperationStage::Suffix;
    if exact && contains_binding(&operation.url)
        || exact && operation.body.as_ref().is_some_and(contains_binding)
        || exact && operation.refspec.as_ref().is_some_and(contains_binding)
    {
        bail!("owner-lane pre-suffix operation contains a future typed binding");
    }
    if operation.stage == OperationStage::Suffix {
        validate_binding_domain(&operation.url)?;
        if let Some(body) = &operation.body {
            validate_binding_domain(body)?;
        }
        if let Some(refspec) = &operation.refspec {
            validate_binding_domain(refspec)?;
        }
    }
    let preview = preview_operation(operation)?;
    validate_operation_allowlist(&preview)?;
    match operation.kind {
        OperationKind::GitPush => {
            let expected = format!("{}:refs/heads/{}", plan.head_sha, plan.branch);
            if preview.refspec.as_deref() != Some(&expected) {
                bail!("owner-lane Git push is not bound to the planned head SHA");
            }
        }
        OperationKind::PullRequestCreate => {
            let body = preview
                .body
                .as_ref()
                .and_then(Value::as_object)
                .context("owner-lane PR creation body is not an object")?;
            if body.get("head").and_then(Value::as_str) != Some(plan.branch.as_str())
                || body.get("base").and_then(Value::as_str) != Some("main")
                || body.get("title").and_then(Value::as_str).is_none()
            {
                bail!("owner-lane PR creation body is not bound to the planned branch and base");
            }
        }
        OperationKind::PullRequestMerge => {
            let body = preview
                .body
                .as_ref()
                .and_then(Value::as_object)
                .context("owner-lane PR merge body is not an object")?;
            if body.get("sha").and_then(Value::as_str) != Some(plan.head_sha.as_str()) {
                bail!("owner-lane PR merge body is not bound to the planned head SHA");
            }
        }
        OperationKind::CredentialRevoke if operation.expected_statuses != [202] => {
            bail!("owner-lane credential revoke must expect exactly 202");
        }
        OperationKind::TerminalIdentityProbe if operation.expected_statuses != [401] => {
            bail!("owner-lane terminal probe must expect exactly 401");
        }
        _ => {}
    }
    Ok(())
}

fn preview_operation(operation: &PlannedOperation) -> Result<OwnerLaneOperation> {
    let preview_bindings = Bindings {
        manifest_digest: "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
            .to_string(),
        attestation_digest:
            "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb".to_string(),
        completed_prefix_digest:
            "sha256:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc".to_string(),
        canonical_pr_number: 1,
    };
    realize_operation(operation, &preview_bindings)
}

fn validate_operation_allowlist(operation: &OwnerLaneOperation) -> Result<()> {
    let api_prefix = format!("https://api.github.com/repos/{REPOSITORY}");
    match operation.kind {
        OperationKind::IdentityProbe | OperationKind::TerminalIdentityProbe => {
            require_request(operation, "GET", "https://api.github.com/user", true)?;
        }
        OperationKind::RepositoryProbe => require_request(operation, "GET", &api_prefix, true)?,
        OperationKind::CredentialRevoke => require_request(
            operation,
            "POST",
            "https://api.github.com/credentials/revoke",
            false,
        )?,
        OperationKind::GitPush => require_request(
            operation,
            "PUSH",
            "https://github.com/jamesryancooper/octon.git",
            true,
        )?,
        OperationKind::WorkflowDisable => require_variable_path_request(
            operation,
            "PUT",
            &(api_prefix.clone() + "/actions/workflows/"),
            "/disable",
        )?,
        OperationKind::WorkflowRunCancel => require_numeric_path_request(
            operation,
            "POST",
            &(api_prefix.clone() + "/actions/runs/"),
            "/cancel",
        )?,
        OperationKind::PullRequestCreate => {
            require_request(operation, "POST", &(api_prefix.clone() + "/pulls"), true)?
        }
        OperationKind::PullRequestReconcile => require_request(
            operation,
            "GET",
            &(api_prefix.clone() + "/pulls?state=open&head=jamesryancooper%3Aocton-rp00&base=main"),
            true,
        )?,
        OperationKind::MarkerCreate => require_numeric_path_request(
            operation,
            "POST",
            &(api_prefix.clone() + "/issues/"),
            "/comments",
        )?,
        OperationKind::RulesetUpdate => require_numeric_path_request(
            operation,
            "PUT",
            &(api_prefix.clone() + "/rulesets/"),
            "",
        )?,
        OperationKind::CheckTrigger => require_request(
            operation,
            "POST",
            &(api_prefix.clone() + "/dispatches"),
            true,
        )?,
        OperationKind::PullRequestMerge => require_numeric_path_request(
            operation,
            "PUT",
            &(api_prefix.clone() + "/pulls/"),
            "/merge",
        )?,
        OperationKind::MainPostRead => require_request(
            operation,
            "GET",
            &(api_prefix + "/git/ref/heads/main"),
            true,
        )?,
    }
    Ok(())
}

fn require_variable_path_request(
    operation: &OwnerLaneOperation,
    method: &str,
    prefix: &str,
    suffix: &str,
) -> Result<()> {
    let middle = operation
        .url
        .strip_prefix(prefix)
        .and_then(|rest| rest.strip_suffix(suffix))
        .filter(|middle| !middle.is_empty() && !middle.contains('/'));
    if operation.method != method || !operation.authenticated || middle.is_none() {
        bail!(
            "owner-lane operation {} violates its fixed path shape",
            operation.id
        );
    }
    Ok(())
}

fn require_numeric_path_request(
    operation: &OwnerLaneOperation,
    method: &str,
    prefix: &str,
    suffix: &str,
) -> Result<()> {
    require_variable_path_request(operation, method, prefix, suffix)?;
    let middle = operation
        .url
        .strip_prefix(prefix)
        .and_then(|rest| rest.strip_suffix(suffix))
        .expect("validated above");
    if !middle.bytes().all(|byte| byte.is_ascii_digit()) {
        bail!(
            "owner-lane operation {} requires a numeric provider id",
            operation.id
        );
    }
    Ok(())
}

fn require_request(
    operation: &OwnerLaneOperation,
    method: &str,
    url: &str,
    authenticated: bool,
) -> Result<()> {
    if operation.method != method
        || operation.url != url
        || operation.authenticated != authenticated
    {
        bail!(
            "owner-lane operation {} violates its fixed request shape",
            operation.id
        );
    }
    Ok(())
}

#[derive(Debug, Clone, Serialize)]
struct Bindings {
    manifest_digest: String,
    attestation_digest: String,
    completed_prefix_digest: String,
    canonical_pr_number: u64,
}

fn planned_operation_template_value(operation: &PlannedOperation) -> Result<Value> {
    let mut value = serde_json::to_value(operation)?;
    value
        .as_object_mut()
        .context("planned operation is not an object")?
        .remove("template_digest");
    Ok(value)
}

fn binding_name(value: &Value) -> Option<&str> {
    let object = value.as_object()?;
    if object.len() != 1 {
        return None;
    }
    object.get("$owner_lane_binding")?.as_str()
}

fn contains_binding(value: &Value) -> bool {
    binding_name(value).is_some()
        || match value {
            Value::Array(values) => values.iter().any(contains_binding),
            Value::Object(values) => values.values().any(contains_binding),
            _ => false,
        }
}

fn validate_binding_domain(value: &Value) -> Result<()> {
    if let Some(name) = binding_name(value) {
        if !matches!(
            name,
            "manifest_digest"
                | "attestation_digest"
                | "completed_prefix_digest"
                | "canonical_pr_number"
        ) {
            bail!("owner-lane template contains unknown typed binding {name}");
        }
        return Ok(());
    }
    match value {
        Value::String(value)
            if value.contains("${") || value.contains("{{") || value.contains("*}") =>
        {
            bail!("owner-lane template contains arbitrary interpolation syntax")
        }
        Value::Array(values) => values.iter().try_for_each(validate_binding_domain)?,
        Value::Object(values) => {
            if values.contains_key("$owner_lane_binding") {
                bail!("owner-lane typed binding node has extra or invalid members");
            }
            values.values().try_for_each(validate_binding_domain)?;
        }
        _ => {}
    }
    Ok(())
}

fn resolve_value(value: &Value, bindings: &Bindings) -> Result<Value> {
    if let Some(name) = binding_name(value) {
        return Ok(match name {
            "manifest_digest" => Value::String(bindings.manifest_digest.clone()),
            "attestation_digest" => Value::String(bindings.attestation_digest.clone()),
            "completed_prefix_digest" => Value::String(bindings.completed_prefix_digest.clone()),
            "canonical_pr_number" => Value::from(bindings.canonical_pr_number),
            _ => bail!("owner-lane template contains unknown typed binding {name}"),
        });
    }
    match value {
        Value::Array(values) => values
            .iter()
            .map(|value| resolve_value(value, bindings))
            .collect::<Result<Vec<_>>>()
            .map(Value::Array),
        Value::Object(values) => values
            .iter()
            .map(|(key, value)| Ok((key.clone(), resolve_value(value, bindings)?)))
            .collect::<Result<Map<String, Value>>>()
            .map(Value::Object),
        _ => Ok(value.clone()),
    }
}

fn resolve_url(value: &Value, bindings: &Bindings) -> Result<String> {
    if let Some(url) = value.as_str() {
        return Ok(url.to_string());
    }
    let object = value
        .as_object()
        .context("owner-lane URL template must be a string or typed numeric-segment object")?;
    if object.len() != 3
        || object
            .keys()
            .any(|key| !matches!(key.as_str(), "prefix" | "binding" | "suffix"))
        || binding_name(&object["binding"]) != Some("canonical_pr_number")
    {
        bail!("owner-lane URL template is not the closed canonical PR-number segment shape");
    }
    let prefix = object["prefix"]
        .as_str()
        .context("owner-lane URL template prefix is not a string")?;
    let suffix = object["suffix"]
        .as_str()
        .context("owner-lane URL template suffix is not a string")?;
    Ok(format!("{prefix}{}{suffix}", bindings.canonical_pr_number))
}

fn realize_operation(
    operation: &PlannedOperation,
    bindings: &Bindings,
) -> Result<OwnerLaneOperation> {
    let body = operation
        .body
        .as_ref()
        .map(|value| resolve_value(value, bindings))
        .transpose()?;
    let refspec = operation
        .refspec
        .as_ref()
        .map(|value| {
            resolve_value(value, bindings)?
                .as_str()
                .map(str::to_string)
                .context("owner-lane refspec must resolve to one string")
        })
        .transpose()?;
    let mut realized = OwnerLaneOperation {
        id: operation.id.clone(),
        sequence: operation.sequence,
        stage: operation.stage,
        kind: operation.kind,
        method: operation.method.clone(),
        url: resolve_url(&operation.url, bindings)?,
        authenticated: operation.authenticated,
        no_resend: operation.no_resend,
        expected_statuses: operation.expected_statuses.clone(),
        body,
        refspec,
        template_digest: operation.template_digest.clone(),
        request_digest: String::new(),
    };
    realized.request_digest = operation_request_digest(&realized)?;
    validate_operation_allowlist(&realized)?;
    Ok(realized)
}

fn normalize_realized_operation(
    planned: &PlannedOperation,
    realized: &OwnerLaneOperation,
    bindings: &Bindings,
) -> Result<String> {
    let expected = realize_operation(planned, bindings)?;
    if canonical_json(&serde_json::to_value(&expected)?)?
        != canonical_json(&serde_json::to_value(realized)?)?
    {
        bail!("owner-lane realized request does not normalize to its sealed template");
    }
    let normalized_digest = digest_value(&planned_operation_template_value(planned)?)?;
    if normalized_digest != planned.template_digest {
        bail!("owner-lane normalized template digest mismatch");
    }
    Ok(normalized_digest)
}

fn validate_tools(tools: &BTreeMap<String, ToolBinding>) -> Result<()> {
    let required = ["curl", "git", "mkfifo", "askpass"];
    if tools.len() != required.len() || required.iter().any(|id| !tools.contains_key(*id)) {
        bail!("owner-lane tool bindings must contain exactly curl, git, mkfifo, and askpass");
    }
    for (id, binding) in tools {
        verify_tool_binding(id, binding)?;
    }
    Ok(())
}

fn verify_tool_binding(id: &str, binding: &ToolBinding) -> Result<()> {
    let path = Path::new(&binding.canonical_path);
    if !path.is_absolute() || fs::symlink_metadata(path)?.file_type().is_symlink() {
        bail!("owner-lane tool {id} is not an absolute non-symlink path");
    }
    if fs::canonicalize(path)? != path {
        bail!("owner-lane tool {id} path is not canonical");
    }
    if !fs::metadata(path)?.is_file() || sha256_file(path)? != binding.sha256 {
        bail!("owner-lane tool {id} digest drift");
    }
    Ok(())
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct OperationEvidence {
    schema_version: String,
    run_id: String,
    operation: OwnerLaneOperation,
    response_digest: String,
    result: OperationResult,
    recorded_at: String,
}

fn execute_staged_plan(
    plan: &ValidatedPlan,
    secret: &mut Secret,
    runner: &mut dyn OperationRunner,
) -> Result<()> {
    create_dir_all_sync(&plan.evidence_root)?;
    validate_capture_times(&plan.authorization, &plan.capture_metadata)?;
    let (issuance, issuance_digest, lifecycle, lifecycle_digest) =
        create_initial_artifacts(plan, secret)?;
    verify_secret_binding(&issuance, &lifecycle, secret)?;

    let empty_bindings = Bindings {
        manifest_digest: "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
            .to_string(),
        attestation_digest:
            "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb".to_string(),
        completed_prefix_digest:
            "sha256:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc".to_string(),
        canonical_pr_number: 1,
    };
    let mut prior_authenticated_200 = false;
    let mut manifest_digest = None;
    let mut attestation_digest = None;
    let mut completed_prefix_digest = None;
    let active_result: Result<()> = (|| {
        let identity = realize_operation(&plan.operation_plan.operations[0], &empty_bindings)?;
        let identity_evidence = execute_operation(plan, identity, secret, runner)?;
        prior_authenticated_200 = true;
        validate_runtime_response(
            plan,
            &identity_evidence.operation,
            &identity_evidence.result,
            None,
        )?;

        let repository = realize_operation(&plan.operation_plan.operations[1], &empty_bindings)?;
        let repository_evidence = execute_operation(plan, repository, secret, runner)?;
        validate_runtime_response(
            plan,
            &repository_evidence.operation,
            &repository_evidence.result,
            None,
        )?;
        let admission = build_admission_receipt(
            plan,
            &lifecycle_digest,
            &identity_evidence,
            &repository_evidence,
        )?;
        write_json_sync(&plan.admission_path, &admission)?;
        let admission_digest = digest_serializable(&admission)?;

        let manifest = build_manifest(
            plan,
            &issuance_digest,
            &lifecycle_digest,
            &admission_digest,
            &admission._recorded_at,
        )?;
        write_json_sync(&plan.manifest_path, &manifest)?;
        let current_manifest_digest = digest_serializable(&manifest)?;
        manifest_digest = Some(current_manifest_digest.clone());
        let attestation = build_attestation(
            plan,
            &current_manifest_digest,
            &admission_digest,
            &admission._recorded_at,
        )?;
        write_json_sync(&plan.attestation_path, &attestation)?;
        let current_attestation_digest = digest_serializable(&attestation)?;
        attestation_digest = Some(current_attestation_digest.clone());

        let mut completed_operation_ids = vec![
            identity_evidence.operation.id.clone(),
            repository_evidence.operation.id.clone(),
        ];
        let mut prefix_evidence = Vec::new();
        for planned in &plan.operation_plan.operations[2..=6] {
            let operation = realize_operation(planned, &empty_bindings)?;
            let evidence = execute_operation(plan, operation, secret, runner)?;
            validate_runtime_response(
                plan,
                &evidence.operation,
                &evidence.result,
                prefix_evidence
                    .iter()
                    .find_map(pull_request_number_from_evidence),
            )?;
            completed_operation_ids.push(evidence.operation.id.clone());
            prefix_evidence.push(evidence);
        }

        let create_evidence = prefix_evidence
            .iter()
            .find(|evidence| evidence.operation.kind == OperationKind::PullRequestCreate)
            .context("owner-lane prefix omitted PR creation evidence")?;
        let reconcile_evidence = prefix_evidence
            .iter()
            .find(|evidence| evidence.operation.kind == OperationKind::PullRequestReconcile)
            .context("owner-lane prefix omitted PR reconciliation evidence")?;
        let canonical_pr_number = pull_request_number_from_evidence(create_evidence)
            .context("owner-lane PR creation response omitted canonical number")?;
        validate_reconciled_pull_request(
            plan,
            canonical_pr_number,
            &reconcile_evidence.result.response,
        )?;

        let completed_prefix = CompletedPrefixReceipt {
            schema_version: "owner-lane-completed-prefix-receipt-v1".to_string(),
            run_id: plan.authorization.run_id.clone(),
            manifest_digest: current_manifest_digest.clone(),
            attestation_digest: current_attestation_digest.clone(),
            operation_plan_digest: plan.operation_plan_digest.clone(),
            completed_operation_ids,
            last_sequence: reconcile_evidence.operation.sequence,
            journal_digest: journal_prefix_digest(&plan.journal_path, 7)?,
            pull_request_create_request_digest: create_evidence.operation.request_digest.clone(),
            pull_request_create_response_digest: create_evidence.response_digest.clone(),
            pull_request_reconcile_request_digest: reconcile_evidence
                .operation
                .request_digest
                .clone(),
            pull_request_reconcile_response_digest: reconcile_evidence.response_digest.clone(),
            canonical_pr_number,
            repository: REPOSITORY.to_string(),
            base_sha: plan.operation_plan.base_sha.clone(),
            head_sha: plan.operation_plan.head_sha.clone(),
            candidate_tree: plan.operation_plan.candidate_tree.clone(),
            branch: plan.operation_plan.branch.clone(),
            terminal_state: "prefix-complete".to_string(),
            recorded_at: reconcile_evidence.recorded_at.clone(),
        };
        write_json_sync(&plan.completed_prefix_path, &completed_prefix)?;
        let current_completed_prefix_digest = digest_serializable(&completed_prefix)?;
        completed_prefix_digest = Some(current_completed_prefix_digest.clone());
        let bindings = Bindings {
            manifest_digest: current_manifest_digest,
            attestation_digest: current_attestation_digest,
            completed_prefix_digest: current_completed_prefix_digest,
            canonical_pr_number,
        };

        for planned in &plan.operation_plan.operations[7..=11] {
            let operation = realize_operation(planned, &bindings)?;
            write_operation_construction_receipt(
                plan,
                planned,
                &operation,
                &bindings,
                &completed_prefix.recorded_at,
            )?;
            let evidence = execute_operation(plan, operation, secret, runner)?;
            validate_runtime_response(
                plan,
                &evidence.operation,
                &evidence.result,
                Some(canonical_pr_number),
            )?;
        }
        Ok(())
    })();

    terminalize(
        plan,
        &lifecycle_digest,
        manifest_digest.as_deref(),
        attestation_digest.as_deref(),
        completed_prefix_digest.as_deref(),
        prior_authenticated_200,
        secret,
        runner,
        active_result.err(),
    )
}

fn create_initial_artifacts(
    plan: &ValidatedPlan,
    secret: &Secret,
) -> Result<(IssuanceOutcome, String, LifecycleEnvelope, String)> {
    let nonce_seed = digest_domain_parts(
        b"octon-owner-lane-nonce-v1\0",
        &[
            plan.authorization_digest.as_bytes(),
            plan.capture_metadata_digest.as_bytes(),
        ],
    );
    let nonce = nonce_seed
        .strip_prefix("sha256:")
        .expect("domain digest has sha256 prefix")[..32]
        .to_string();
    let handle_digest = digest_domain_parts(HANDLE_DOMAIN, &[nonce.as_bytes(), secret.expose()]);
    let mut header = [b"Authorization: Bearer ".as_slice(), secret.expose()].concat();
    let header_digest = digest_domain_parts(HEADER_DOMAIN, &[&header]);
    header.fill(0);
    let mut body = revocation_body(secret.expose());
    let revocation_body_digest = digest_domain_parts(REVOCATION_DOMAIN, &[&body]);
    body.fill(0);
    let issuance = IssuanceOutcome {
        schema_version: "owner-lane-credential-issuance-outcome-receipt-v1".to_string(),
        run_id: plan.authorization.run_id.clone(),
        authorization_digest: plan.authorization_digest.clone(),
        capture_metadata_digest: plan.capture_metadata_digest.clone(),
        operation_plan_digest: plan.operation_plan_digest.clone(),
        issued: true,
        issuance_attempts: 1,
        issuer: "github.com".to_string(),
        principal: plan.authorization.principal.clone(),
        nonce_salted_handle_digest: handle_digest.clone(),
        header_digest,
        revocation_body_digest,
        no_secret_retained: true,
        _recorded_at: plan.capture_metadata._recorded_at.clone(),
    };
    write_json_sync(&plan.issuance_path, &issuance)?;
    let issuance_digest = digest_serializable(&issuance)?;
    let lifecycle = LifecycleEnvelope {
        schema_version: "owner-lane-credential-lifecycle-envelope-v1".to_string(),
        run_id: plan.authorization.run_id.clone(),
        authorization_digest: plan.authorization_digest.clone(),
        capture_metadata_digest: plan.capture_metadata_digest.clone(),
        operation_plan_digest: plan.operation_plan_digest.clone(),
        issuance_outcome_digest: issuance_digest.clone(),
        credential_handle_nonce: nonce,
        credential_handle_digest: handle_digest,
        credential_tuple: plan.authorization.credential_tuple.clone(),
        request_budgets: plan.authorization.request_budgets.clone(),
        no_resend: true,
        replacement_lock: plan.authorization.replacement_lock.clone(),
        actual_reached_phase: "credential-issued".to_string(),
        evidence_root: plan.authorization.evidence_root.clone(),
        recorded_at: plan.capture_metadata._recorded_at.clone(),
    };
    write_json_sync(&plan.lifecycle_path, &lifecycle)?;
    let lifecycle_digest = digest_serializable(&lifecycle)?;
    Ok((issuance, issuance_digest, lifecycle, lifecycle_digest))
}

fn build_admission_receipt(
    plan: &ValidatedPlan,
    lifecycle_digest: &str,
    identity: &OperationEvidence,
    repository: &OperationEvidence,
) -> Result<AdmissionReceipt> {
    validate_runtime_response(plan, &identity.operation, &identity.result, None)?;
    validate_runtime_response(plan, &repository.operation, &repository.result, None)?;
    let identity_value = parse_strict_json(&identity.result.response)?;
    let login = identity_value
        .get("login")
        .and_then(Value::as_str)
        .context("owner-lane identity response omitted login")?;
    let id = identity_value
        .get("id")
        .and_then(Value::as_u64)
        .context("owner-lane identity response omitted id")?;
    let accepted = repository
        .result
        .headers
        .get("x-accepted-github-permissions")
        .context("repository probe omitted X-Accepted-GitHub-Permissions")?;
    let accepted_permissions = parse_accepted_permissions(accepted)?;
    let expected_permissions = expected_permissions_map(&plan.authorization.credential_tuple);
    if accepted_permissions != expected_permissions {
        bail!("repository probe accepted-permissions header does not equal the sealed tuple");
    }
    Ok(AdmissionReceipt {
        schema_version: "owner-lane-credential-admission-receipt-v1".to_string(),
        run_id: plan.authorization.run_id.clone(),
        lifecycle_digest: lifecycle_digest.to_string(),
        operation_plan_digest: plan.operation_plan_digest.clone(),
        identity_status: 200,
        repository_status: 200,
        login: login.to_string(),
        id,
        api_version: API_VERSION.to_string(),
        accepted_permissions,
        identity_request_digest: identity.operation.request_digest.clone(),
        identity_response_digest: identity.response_digest.clone(),
        repository_request_digest: repository.operation.request_digest.clone(),
        repository_response_digest: repository.response_digest.clone(),
        trusted_capture_facts_digest: plan.capture_metadata_digest.clone(),
        pagination_complete: true,
        admitted: true,
        prior_authenticated_200: true,
        _recorded_at: repository.recorded_at.clone(),
    })
}

fn expected_permissions_map(tuple: &CredentialTuple) -> BTreeMap<String, String> {
    tuple
        .permissions
        .iter()
        .map(|permission| (permission.name.clone(), permission.level.clone()))
        .collect()
}

fn build_manifest(
    plan: &ValidatedPlan,
    issuance_digest: &str,
    lifecycle_digest: &str,
    admission_digest: &str,
    recorded_at: &str,
) -> Result<OperationManifest> {
    let operation_values = plan
        .operation_plan
        .operations
        .iter()
        .map(planned_operation_template_value)
        .collect::<Result<Vec<_>>>()?;
    Ok(OperationManifest {
        schema_version: "owner-lane-operation-manifest-v1".to_string(),
        run_id: plan.authorization.run_id.clone(),
        authorization_digest: plan.authorization_digest.clone(),
        capture_metadata_digest: plan.capture_metadata_digest.clone(),
        issuance_outcome_digest: issuance_digest.to_string(),
        lifecycle_digest: lifecycle_digest.to_string(),
        admission_digest: admission_digest.to_string(),
        operation_plan_digest: plan.operation_plan_digest.clone(),
        repository: REPOSITORY.to_string(),
        base_sha: plan.operation_plan.base_sha.clone(),
        head_sha: plan.operation_plan.head_sha.clone(),
        candidate_tree: plan.operation_plan.candidate_tree.clone(),
        branch: plan.operation_plan.branch.clone(),
        attestation_template_digest: digest_serializable(
            &plan.operation_plan.attestation_template,
        )?,
        operation_template_digest: digest_value(&Value::Array(operation_values))?,
        one_attempt_lock: plan.authorization.one_attempt_lock.clone(),
        replacement_lock: plan.authorization.replacement_lock.clone(),
        tools: plan.operation_plan.tools.clone(),
        operations: plan.operation_plan.operations.clone(),
        recorded_at: recorded_at.to_string(),
    })
}

fn build_attestation(
    plan: &ValidatedPlan,
    manifest_digest: &str,
    admission_digest: &str,
    recorded_at: &str,
) -> Result<Attestation> {
    let template = &plan.operation_plan.attestation_template;
    Ok(Attestation {
        schema_version: "owner-lane-attestation-v1".to_string(),
        run_id: plan.authorization.run_id.clone(),
        manifest_digest: manifest_digest.to_string(),
        authorization_digest: plan.authorization_digest.clone(),
        admission_digest: admission_digest.to_string(),
        repository: template.repository.clone(),
        base_sha: template.base_sha.clone(),
        candidate_sha: template.candidate_sha.clone(),
        candidate_tree: template.candidate_tree.clone(),
        principal: template.principal.clone(),
        accepted_review_digest: template.accepted_review_digest.clone(),
        attested: template.attested,
        _recorded_at: recorded_at.to_string(),
    })
}

fn execute_operation(
    plan: &ValidatedPlan,
    operation: OwnerLaneOperation,
    secret: &Secret,
    runner: &mut dyn OperationRunner,
) -> Result<OperationEvidence> {
    match journal_request_state(&plan.journal_path, &operation.request_digest)? {
        JournalRequestState::Completed {
            status,
            response_digest,
        } => {
            let evidence = load_operation_evidence(plan, &operation)?;
            if evidence.result.status != Some(status)
                || evidence.response_digest != response_digest
                || sha256_prefixed(&evidence.result.response) != response_digest
            {
                bail!(
                    "owner-lane completed response evidence does not match journal for {}",
                    operation.id
                );
            }
            if !operation.expected_statuses.contains(&status) {
                bail!(
                    "owner-lane operation {} returned unexpected status {status}",
                    operation.id
                );
            }
            return Ok(evidence);
        }
        JournalRequestState::Unknown => {
            bail!(
                "outcome-unknown: request {} may never be resent",
                operation.request_digest
            )
        }
        JournalRequestState::Unseen => {
            if operation.stage != OperationStage::Terminal
                && time::OffsetDateTime::now_utc()
                    >= parse_timestamp(&plan.capture_metadata.local_deadline)?
            {
                bail!("owner-lane local credential deadline has expired");
            }
        }
    }
    plan.operation_plan
        .tools
        .iter()
        .try_for_each(|(id, binding)| verify_tool_binding(id, binding))?;
    append_journal(
        &plan.journal_path,
        JournalEvent {
            schema_version: "owner-lane-journal-event-v1",
            phase: "pre-send",
            operation_id: &operation.id,
            sequence: operation.sequence,
            request_digest: &operation.request_digest,
            status: None,
            response_digest: None,
        },
    )?;
    let result = runner
        .run(&operation, &plan.operation_plan.tools, secret.expose())
        .with_context(|| format!("outcome-unknown: operation {} launch failed", operation.id))?;
    let status = result.status.filter(|_| result.sent).with_context(|| {
        format!(
            "outcome-unknown: operation {} has no terminal response",
            operation.id
        )
    })?;
    let response_digest = sha256_prefixed(&result.response);
    let evidence = OperationEvidence {
        schema_version: "owner-lane-operation-response-evidence-v1".to_string(),
        run_id: plan.authorization.run_id.clone(),
        operation,
        response_digest: response_digest.clone(),
        result,
        recorded_at: current_timestamp(),
    };
    let evidence_path = operation_evidence_path(plan, &evidence.operation);
    create_dir_all_sync(
        evidence_path
            .parent()
            .context("owner-lane operation evidence path has no parent")?,
    )?;
    write_json_sync(&evidence_path, &evidence)?;
    append_journal(
        &plan.journal_path,
        JournalEvent {
            schema_version: "owner-lane-journal-event-v1",
            phase: "response",
            operation_id: &evidence.operation.id,
            sequence: evidence.operation.sequence,
            request_digest: &evidence.operation.request_digest,
            status: Some(status),
            response_digest: Some(response_digest.clone()),
        },
    )?;
    if !evidence.operation.expected_statuses.contains(&status) {
        bail!(
            "owner-lane operation {} returned unexpected status {status}",
            evidence.operation.id
        );
    }
    Ok(evidence)
}

fn validate_runtime_response(
    plan: &ValidatedPlan,
    operation: &OwnerLaneOperation,
    result: &OperationResult,
    expected_pr_number: Option<u64>,
) -> Result<()> {
    match operation.kind {
        OperationKind::IdentityProbe => {
            let value = parse_strict_json(&result.response)?;
            if value.get("login").and_then(Value::as_str) != Some(PRINCIPAL_LOGIN)
                || value.get("id").and_then(Value::as_u64) != Some(PRINCIPAL_ID)
            {
                bail!("owner-lane identity probe principal mismatch");
            }
        }
        OperationKind::RepositoryProbe => {
            let value = parse_strict_json(&result.response)?;
            if value.get("full_name").and_then(Value::as_str) != Some(REPOSITORY) {
                bail!("owner-lane repository probe target mismatch");
            }
        }
        OperationKind::PullRequestCreate => {
            let value = parse_strict_json(&result.response)?;
            validate_pull_request_value(plan, &value, None)?;
        }
        OperationKind::PullRequestReconcile => {
            let number = expected_pr_number.context("PR reconciliation lacks create identity")?;
            validate_reconciled_pull_request(plan, number, &result.response)?;
        }
        OperationKind::PullRequestMerge => {
            let value = parse_strict_json(&result.response)?;
            if value.get("merged").and_then(Value::as_bool) != Some(true) {
                bail!("owner-lane merge response is not an affirmative merge");
            }
        }
        OperationKind::MainPostRead => {
            let value = parse_strict_json(&result.response)?;
            if value
                .get("object")
                .and_then(|object| object.get("sha"))
                .and_then(Value::as_str)
                != Some(plan.operation_plan.head_sha.as_str())
            {
                bail!("owner-lane authoritative main post-read does not equal candidate head");
            }
        }
        _ => {}
    }
    Ok(())
}

fn validate_pull_request_value(
    plan: &ValidatedPlan,
    value: &Value,
    expected_number: Option<u64>,
) -> Result<u64> {
    let number = value
        .get("number")
        .and_then(Value::as_u64)
        .context("owner-lane pull-request response omitted number")?;
    if number == 0
        || expected_number.is_some_and(|expected| expected != number)
        || value.pointer("/head/sha").and_then(Value::as_str)
            != Some(plan.operation_plan.head_sha.as_str())
        || value.pointer("/head/ref").and_then(Value::as_str)
            != Some(plan.operation_plan.branch.as_str())
        || value.pointer("/base/sha").and_then(Value::as_str)
            != Some(plan.operation_plan.base_sha.as_str())
        || value.pointer("/base/ref").and_then(Value::as_str) != Some("main")
    {
        bail!("owner-lane pull-request identity does not match repository/base/head/branch");
    }
    Ok(number)
}

fn pull_request_number_from_evidence(evidence: &OperationEvidence) -> Option<u64> {
    if evidence.operation.kind != OperationKind::PullRequestCreate {
        return None;
    }
    parse_strict_json(&evidence.result.response)
        .ok()?
        .get("number")?
        .as_u64()
}

fn validate_reconciled_pull_request(
    plan: &ValidatedPlan,
    expected_number: u64,
    response: &[u8],
) -> Result<()> {
    let value = parse_strict_json(response)?;
    let matches = value
        .as_array()
        .context("owner-lane PR reconciliation response is not an array")?;
    if matches.len() != 1 {
        bail!("owner-lane PR reconciliation must return exactly one match");
    }
    validate_pull_request_value(plan, &matches[0], Some(expected_number))?;
    Ok(())
}

#[allow(clippy::too_many_arguments)]
fn terminalize(
    plan: &ValidatedPlan,
    lifecycle_digest: &str,
    manifest_digest: Option<&str>,
    attestation_digest: Option<&str>,
    completed_prefix_digest: Option<&str>,
    prior_authenticated_200: bool,
    secret: &mut Secret,
    runner: &mut dyn OperationRunner,
    primary_failure: Option<anyhow::Error>,
) -> Result<()> {
    let terminal_bindings = Bindings {
        manifest_digest: manifest_digest
            .unwrap_or(&plan.operation_plan_digest)
            .to_string(),
        attestation_digest: attestation_digest.unwrap_or(lifecycle_digest).to_string(),
        completed_prefix_digest: completed_prefix_digest
            .unwrap_or(&plan.capture_metadata_digest)
            .to_string(),
        canonical_pr_number: 1,
    };
    let revoke = realize_operation(&plan.operation_plan.operations[12], &terminal_bindings)?;
    let revoke_result = execute_operation(plan, revoke, secret, runner);
    if plan.authorization.request_budgets.revocation_wait_seconds > 0 {
        thread::sleep(std::time::Duration::from_secs(
            plan.authorization.request_budgets.revocation_wait_seconds,
        ));
    }
    let terminal = realize_operation(&plan.operation_plan.operations[13], &terminal_bindings)?;
    let terminal_result = execute_operation(plan, terminal, secret, runner);
    let terminal_error = revoke_result
        .as_ref()
        .err()
        .map(ToString::to_string)
        .or_else(|| terminal_result.as_ref().err().map(ToString::to_string));
    let secret_census = secret_census(&plan.evidence_root, secret.expose());
    secret.zeroize();
    let secret_census_empty = secret_census?;
    let fifo_removed = runner.fifo_removed();
    if revoke_result.is_err()
        || terminal_result.is_err()
        || !prior_authenticated_200
        || !fifo_removed
        || !secret_census_empty
    {
        return Err(primary_failure.unwrap_or_else(|| {
            anyhow!(
                "owner-lane credential retirement failed: {}",
                terminal_error.unwrap_or_else(|| "terminal evidence incomplete".to_string())
            )
        }));
    }
    let completed_at = terminal_result
        .as_ref()
        .expect("terminal result was checked above")
        .recorded_at
        .clone();
    let receipt = RetirementReceipt {
        schema_version: "owner-lane-credential-retirement-receipt-v1",
        run_id: &plan.authorization.run_id,
        authorization_digest: &plan.authorization_digest,
        operation_plan_digest: &plan.operation_plan_digest,
        lifecycle_digest,
        manifest_digest,
        attestation_digest,
        completed_prefix_digest,
        revocation_status: 202,
        terminal_identity_status: 401,
        prior_authenticated_200,
        local_buffer_zeroized: true,
        fifo_removed,
        secret_census_empty,
        retired: true,
        completed_at,
    };
    write_json_sync(&plan.retirement_path, &receipt)?;
    if let Some(error) = primary_failure {
        Err(error)
    } else {
        Ok(())
    }
}

fn digest_serializable(value: &impl Serialize) -> Result<String> {
    digest_value(&serde_json::to_value(value)?)
}

fn parse_accepted_permissions(value: &str) -> Result<BTreeMap<String, String>> {
    let mut parsed = BTreeMap::new();
    for item in value
        .split(';')
        .map(str::trim)
        .filter(|item| !item.is_empty())
    {
        let (permission, level) = item
            .split_once('=')
            .context("invalid X-Accepted-GitHub-Permissions member")?;
        if permission.is_empty()
            || !matches!(level, "read" | "write")
            || parsed
                .insert(permission.to_string(), level.to_string())
                .is_some()
        {
            bail!("invalid or duplicate X-Accepted-GitHub-Permissions member");
        }
    }
    if parsed.is_empty() {
        bail!("empty X-Accepted-GitHub-Permissions header");
    }
    Ok(parsed)
}

impl OperationRunner for SystemRunner<'_> {
    fn run(
        &mut self,
        operation: &OwnerLaneOperation,
        tools: &BTreeMap<String, ToolBinding>,
        secret: &[u8],
    ) -> Result<OperationResult> {
        if operation.kind == OperationKind::GitPush {
            return self.run_git(operation, tools, secret);
        }
        self.run_curl(operation, tools, secret)
    }

    fn fifo_removed(&self) -> bool {
        !self.fifo_active
    }
}

impl SystemRunner<'_> {
    fn run_curl(
        &self,
        operation: &OwnerLaneOperation,
        tools: &BTreeMap<String, ToolBinding>,
        secret: &[u8],
    ) -> Result<OperationResult> {
        let curl = &tools["curl"];
        verify_tool_binding("curl", curl)?;
        let mut config = SensitiveBuffer::new();
        writeln!(config, "silent")?;
        writeln!(config, "show-error")?;
        writeln!(config, "dump-header = \"-\"")?;
        writeln!(config, "connect-timeout = 10")?;
        writeln!(config, "max-time = 60")?;
        writeln!(config, "request = \"{}\"", operation.method)?;
        writeln!(config, "url = \"{}\"", operation.url)?;
        writeln!(config, "header = \"Accept: application/vnd.github+json\"")?;
        writeln!(config, "header = \"X-GitHub-Api-Version: {API_VERSION}\"")?;
        if operation.authenticated {
            let secret = std::str::from_utf8(secret)
                .context("owner-lane credential is not valid ASCII text")?;
            writeln!(config, "header = \"Authorization: Bearer {}\"", secret)?;
        }
        if operation.kind == OperationKind::CredentialRevoke {
            let body = Secret(revocation_body(secret));
            writeln!(config, "header = \"Content-Type: application/json\"")?;
            let body = std::str::from_utf8(body.expose())
                .context("owner-lane revocation body is not valid ASCII text")?;
            writeln!(config, "data = \"{}\"", body)?;
        } else if let Some(body) = &operation.body {
            let canonical = canonical_json(body)?;
            writeln!(config, "header = \"Content-Type: application/json\"")?;
            writeln!(
                config,
                "data = \"{}\"",
                escape_curl_config(&String::from_utf8_lossy(&canonical))
            )?;
        }
        writeln!(config, "write-out = \"\\n%{{http_code}}\"")?;
        let mut child = Command::new(&curl.canonical_path)
            .args(["--config", "-"])
            .env_clear()
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()?;
        child
            .stdin
            .take()
            .context("curl stdin unavailable")?
            .write_all(config.expose())?;
        drop(config);
        let output = child.wait_with_output()?;
        if !output.status.success() {
            return Ok(OperationResult {
                sent: true,
                status: None,
                headers: BTreeMap::new(),
                response: [output.stdout, output.stderr].concat(),
            });
        }
        let (headers, response, status) = split_http_response(&output.stdout)?;
        Ok(OperationResult {
            sent: true,
            status: Some(status),
            headers,
            response,
        })
    }

    fn run_git(
        &mut self,
        operation: &OwnerLaneOperation,
        tools: &BTreeMap<String, ToolBinding>,
        secret: &[u8],
    ) -> Result<OperationResult> {
        for id in ["git", "mkfifo", "askpass"] {
            verify_tool_binding(id, &tools[id])?;
        }
        let fifo = self.repo_root.join(".git").join(format!(
            "octon-owner-lane-{}.fifo",
            operation_digest_sha(&operation.request_digest)
        ));
        let used = PathBuf::from(format!("{}.used", fifo.display()));
        let _ = fs::remove_file(&fifo);
        let _ = fs::remove_dir(&used);
        let status = Command::new(&tools["mkfifo"].canonical_path)
            .arg(&fifo)
            .env_clear()
            .status()?;
        if !status.success() {
            bail!("bound mkfifo failed");
        }
        self.fifo_active = true;
        #[cfg(unix)]
        if !fs::metadata(&fifo)?.file_type().is_fifo() {
            bail!("owner-lane credential channel is not a FIFO");
        }
        let mut channel = match OpenOptions::new().read(true).write(true).open(&fifo) {
            Ok(channel) => channel,
            Err(error) => {
                let _ = fs::remove_file(&fifo);
                self.fifo_active = false;
                return Err(error.into());
            }
        };
        let child = Command::new(&tools["git"].canonical_path)
            .args([
                "-c",
                "credential.helper=",
                "-c",
                "core.askPass=",
                "push",
                &operation.url,
                operation
                    .refspec
                    .as_deref()
                    .context("git push refspec missing")?,
            ])
            .current_dir(self.repo_root)
            .env_clear()
            .env("GIT_TERMINAL_PROMPT", "0")
            .env("GIT_ASKPASS", &tools["askpass"].canonical_path)
            .env("OCTON_OWNER_LANE_CREDENTIAL_FIFO", &fifo)
            .stdin(Stdio::null())
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn();
        let mut child = match child {
            Ok(child) => child,
            Err(error) => {
                let _ = fs::remove_file(&fifo);
                let _ = fs::remove_dir(&used);
                self.fifo_active = false;
                return Err(error.into());
            }
        };
        let credential = Secret(secret.to_vec());
        if let Err(error) = channel
            .write_all(credential.expose())
            .and_then(|_| channel.write_all(b"\n"))
        {
            let _ = child.kill();
            let _ = child.wait();
            drop(channel);
            let removal = fs::remove_file(&fifo);
            let _ = fs::remove_dir(&used);
            if removal.is_ok() {
                self.fifo_active = false;
            }
            removal?;
            return Err(error.into());
        }
        let output = child.wait_with_output();
        drop(channel);
        let fifo_removal = fs::remove_file(&fifo).context("failed to remove credential FIFO");
        let _ = fs::remove_dir(&used);
        if fifo_removal.is_ok() {
            self.fifo_active = false;
        }
        fifo_removal?;
        let output = output?;
        Ok(OperationResult {
            sent: true,
            status: output.status.success().then_some(200),
            headers: BTreeMap::new(),
            response: [output.stdout, output.stderr].concat(),
        })
    }
}

fn read_credential_fd(fd: i32) -> Result<Secret> {
    if fd < 3 {
        bail!("owner-lane credential fd must be an inherited descriptor >= 3");
    }
    let file = unsafe { File::from_raw_fd(fd) };
    let mut bytes = Vec::new();
    let mut limited = file.take((MAX_CREDENTIAL_BYTES + 1) as u64);
    limited.read_to_end(&mut bytes)?;
    drop(limited);
    if bytes.len() > MAX_CREDENTIAL_BYTES {
        bytes.fill(0);
        bail!("owner-lane credential exceeds size limit");
    }
    while matches!(bytes.last(), Some(b'\n' | b'\r')) {
        bytes.pop();
    }
    if bytes.is_empty()
        || bytes.contains(&b'\n')
        || bytes.contains(&b'\r')
        || !bytes.starts_with(b"github_pat_")
        || !bytes
            .iter()
            .all(|byte| byte.is_ascii_alphanumeric() || *byte == b'_')
    {
        bytes.fill(0);
        bail!("owner-lane credential is not one fine-grained PAT line");
    }
    Ok(Secret(bytes))
}

fn verify_secret_binding(
    issuance: &IssuanceOutcome,
    lifecycle: &LifecycleEnvelope,
    secret: &Secret,
) -> Result<()> {
    let handle = digest_domain_parts(
        HANDLE_DOMAIN,
        &[
            lifecycle.credential_handle_nonce.as_bytes(),
            secret.expose(),
        ],
    );
    let header = [b"Authorization: Bearer ".as_slice(), secret.expose()].concat();
    let header_digest = digest_domain_parts(HEADER_DOMAIN, &[&header]);
    let mut header = header;
    header.fill(0);
    let mut body = revocation_body(secret.expose());
    let revocation_digest = digest_domain_parts(REVOCATION_DOMAIN, &[&body]);
    body.fill(0);
    if handle != lifecycle.credential_handle_digest
        || handle != issuance.nonce_salted_handle_digest
        || header_digest != issuance.header_digest
        || revocation_digest != issuance.revocation_body_digest
    {
        bail!("owner-lane credential does not match its opaque lifecycle bindings");
    }
    Ok(())
}

fn revocation_body(secret: &[u8]) -> Vec<u8> {
    let mut body = b"{\"credentials\":[\"".to_vec();
    body.extend_from_slice(secret);
    body.extend_from_slice(b"\"]}");
    body
}

fn append_journal(path: &Path, event: JournalEvent<'_>) -> Result<()> {
    let created = !path.exists();
    let mut file = OpenOptions::new().create(true).append(true).open(path)?;
    let bytes = serde_json::to_vec(&event)?;
    file.write_all(&bytes)?;
    file.write_all(b"\n")?;
    file.sync_data()?;
    if created {
        sync_parent_directory(path)?;
    }
    Ok(())
}

#[derive(Clone, Debug, Eq, PartialEq)]
enum JournalRequestState {
    Unseen,
    Completed {
        status: u16,
        response_digest: String,
    },
    Unknown,
}

fn journal_request_state(path: &Path, request_digest: &str) -> Result<JournalRequestState> {
    if !path.exists() {
        return Ok(JournalRequestState::Unseen);
    }
    let text = fs::read_to_string(path)?;
    let mut presend = 0_u64;
    let mut response = None;
    for line in text.lines().filter(|line| !line.trim().is_empty()) {
        let value = parse_strict_json(line.as_bytes())?;
        if value.get("request_digest").and_then(Value::as_str) == Some(request_digest) {
            match value.get("phase").and_then(Value::as_str) {
                Some("pre-send") => presend += 1,
                Some("response") => {
                    if response.is_some() {
                        bail!("owner-lane journal contains duplicate response events");
                    }
                    let status = value
                        .get("status")
                        .and_then(Value::as_u64)
                        .and_then(|value| u16::try_from(value).ok())
                        .context("owner-lane response journal event omitted valid status")?;
                    let digest = value
                        .get("response_digest")
                        .and_then(Value::as_str)
                        .filter(|value| is_sha256_digest(value))
                        .context("owner-lane response journal event omitted valid digest")?;
                    response = Some((status, digest.to_string()));
                }
                _ => bail!("invalid owner-lane journal phase"),
            }
        }
    }
    match (presend, response) {
        (0, None) => Ok(JournalRequestState::Unseen),
        (1, None) => Ok(JournalRequestState::Unknown),
        (1, Some((status, response_digest))) => Ok(JournalRequestState::Completed {
            status,
            response_digest,
        }),
        _ => bail!("owner-lane journal contains an invalid no-resend event sequence"),
    }
}

fn operation_evidence_path(plan: &ValidatedPlan, operation: &OwnerLaneOperation) -> PathBuf {
    plan.evidence_root
        .join("operation-responses")
        .join(format!("{:02}-{}.json", operation.sequence, operation.id))
}

fn load_operation_evidence(
    plan: &ValidatedPlan,
    operation: &OwnerLaneOperation,
) -> Result<OperationEvidence> {
    let path = operation_evidence_path(plan, operation);
    let value = read_strict_json(&path)
        .with_context(|| format!("missing durable response evidence: {}", path.display()))?;
    let evidence: OperationEvidence = serde_json::from_value(value)
        .with_context(|| format!("invalid durable response evidence: {}", path.display()))?;
    if evidence.schema_version != "owner-lane-operation-response-evidence-v1"
        || evidence.run_id != plan.authorization.run_id
        || canonical_json(&serde_json::to_value(&evidence.operation)?)?
            != canonical_json(&serde_json::to_value(operation)?)?
        || !evidence.result.sent
    {
        bail!(
            "owner-lane durable response evidence does not match operation {}",
            operation.id
        );
    }
    Ok(evidence)
}

fn write_operation_construction_receipt(
    plan: &ValidatedPlan,
    planned: &PlannedOperation,
    operation: &OwnerLaneOperation,
    bindings: &Bindings,
    constructed_at: &str,
) -> Result<()> {
    let root = plan.evidence_root.join("operation-construction");
    create_dir_all_sync(&root)?;
    let normalized_template_digest = normalize_realized_operation(planned, operation, bindings)?;
    let binding_digest = digest_serializable(bindings)?;
    let receipt = OperationConstructionReceipt {
        schema_version: "owner-lane-operation-construction-receipt-v1",
        run_id: &plan.authorization.run_id,
        manifest_digest: &bindings.manifest_digest,
        attestation_digest: &bindings.attestation_digest,
        completed_prefix_digest: &bindings.completed_prefix_digest,
        operation_id: &operation.id,
        sequence: operation.sequence,
        template_digest: &planned.template_digest,
        binding_digest: &binding_digest,
        resolved_request_digest: &operation.request_digest,
        normalized_template_digest: &normalized_template_digest,
        canonical_pr_number: bindings.canonical_pr_number,
        normalized: true,
        constructed_at: constructed_at.to_string(),
    };
    write_json_sync(
        &root.join(format!("{:02}-{}.json", operation.sequence, operation.id)),
        &receipt,
    )
}

fn journal_prefix_digest(path: &Path, last_sequence: u64) -> Result<String> {
    let text = fs::read_to_string(path)?;
    let mut prefix = Vec::new();
    for line in text.lines().filter(|line| !line.trim().is_empty()) {
        let value = parse_strict_json(line.as_bytes())?;
        let sequence = value
            .get("sequence")
            .and_then(Value::as_u64)
            .context("owner-lane journal event omitted sequence")?;
        if sequence <= last_sequence {
            prefix.extend_from_slice(line.as_bytes());
            prefix.push(b'\n');
        }
    }
    Ok(sha256_prefixed(&prefix))
}

fn secret_census(path: &Path, secret: &[u8]) -> Result<bool> {
    if secret.is_empty() {
        return Ok(false);
    }
    for entry in WalkDir::new(path).follow_links(false) {
        let entry = entry?;
        if entry.file_type().is_file()
            && fs::read(entry.path())?
                .windows(secret.len())
                .any(|window| window == secret)
        {
            return Ok(false);
        }
    }
    Ok(true)
}

fn write_json_sync(path: &Path, value: &impl Serialize) -> Result<()> {
    let mut bytes = serde_json::to_vec_pretty(value)?;
    bytes.push(b'\n');
    if path.exists() {
        if fs::read(path)? == bytes {
            return Ok(());
        }
        bail!(
            "owner-lane create-only artifact conflicts with existing bytes: {}",
            path.display()
        );
    }
    let mut file = OpenOptions::new().create_new(true).write(true).open(path)?;
    file.write_all(&bytes)?;
    file.sync_all()?;
    drop(file);
    sync_parent_directory(path)?;
    Ok(())
}

fn create_dir_all_sync(path: &Path) -> Result<()> {
    let existed = path.exists();
    fs::create_dir_all(path)?;
    sync_directory(path)?;
    if !existed {
        sync_parent_directory(path)?;
    }
    Ok(())
}

fn sync_parent_directory(path: &Path) -> Result<()> {
    if let Some(parent) = path.parent() {
        sync_directory(parent)?;
    }
    Ok(())
}

#[cfg(unix)]
fn sync_directory(path: &Path) -> Result<()> {
    File::open(path)?.sync_all()?;
    Ok(())
}

#[cfg(not(unix))]
fn sync_directory(_path: &Path) -> Result<()> {
    Ok(())
}

fn read_strict_json(path: &Path) -> Result<Value> {
    parse_strict_json(&fs::read(path)?)
        .with_context(|| format!("invalid strict JSON: {}", path.display()))
}

fn parse_strict_json(bytes: &[u8]) -> Result<Value> {
    let mut deserializer = serde_json::Deserializer::from_slice(bytes);
    let value = StrictValue.deserialize(&mut deserializer)?;
    deserializer.end()?;
    validate_json_domain(&value)?;
    Ok(value)
}

struct StrictValue;

impl<'de> DeserializeSeed<'de> for StrictValue {
    type Value = Value;

    fn deserialize<D>(self, deserializer: D) -> std::result::Result<Value, D::Error>
    where
        D: serde::Deserializer<'de>,
    {
        deserializer.deserialize_any(StrictValueVisitor)
    }
}

struct StrictValueVisitor;

impl<'de> Visitor<'de> for StrictValueVisitor {
    type Value = Value;

    fn expecting(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        formatter.write_str("strict RFC 8785-compatible JSON")
    }

    fn visit_bool<E>(self, value: bool) -> std::result::Result<Value, E> {
        Ok(Value::Bool(value))
    }

    fn visit_i64<E>(self, value: i64) -> std::result::Result<Value, E>
    where
        E: de::Error,
    {
        Ok(Value::Number(value.into()))
    }

    fn visit_u64<E>(self, value: u64) -> std::result::Result<Value, E>
    where
        E: de::Error,
    {
        Ok(Value::Number(value.into()))
    }

    fn visit_f64<E>(self, _value: f64) -> std::result::Result<Value, E>
    where
        E: de::Error,
    {
        Err(E::custom("floating-point values are forbidden"))
    }

    fn visit_str<E>(self, value: &str) -> std::result::Result<Value, E>
    where
        E: de::Error,
    {
        Ok(Value::String(value.to_string()))
    }

    fn visit_string<E>(self, value: String) -> std::result::Result<Value, E> {
        Ok(Value::String(value))
    }

    fn visit_none<E>(self) -> std::result::Result<Value, E> {
        Ok(Value::Null)
    }

    fn visit_unit<E>(self) -> std::result::Result<Value, E> {
        Ok(Value::Null)
    }

    fn visit_seq<A>(self, mut seq: A) -> std::result::Result<Value, A::Error>
    where
        A: SeqAccess<'de>,
    {
        let mut values = Vec::new();
        while let Some(value) = seq.next_element_seed(StrictValue)? {
            values.push(value);
        }
        Ok(Value::Array(values))
    }

    fn visit_map<A>(self, mut map: A) -> std::result::Result<Value, A::Error>
    where
        A: MapAccess<'de>,
    {
        let mut values = Map::new();
        while let Some(key) = map.next_key::<String>()? {
            if values.contains_key(&key) {
                return Err(de::Error::custom(format!("duplicate object key: {key}")));
            }
            values.insert(key, map.next_value_seed(StrictValue)?);
        }
        Ok(Value::Object(values))
    }
}

fn validate_json_domain(value: &Value) -> Result<()> {
    match value {
        Value::Number(number) => {
            if let Some(value) = number.as_u64() {
                if value > MAX_EXACT_INTEGER {
                    bail!("integer exceeds interoperable exact range");
                }
            } else if let Some(value) = number.as_i64() {
                if value.unsigned_abs() > MAX_EXACT_INTEGER {
                    bail!("integer exceeds interoperable exact range");
                }
            } else {
                bail!("floating-point values are forbidden");
            }
        }
        Value::Array(values) => values.iter().try_for_each(validate_json_domain)?,
        Value::Object(values) => values.values().try_for_each(validate_json_domain)?,
        _ => {}
    }
    Ok(())
}

fn canonical_json(value: &Value) -> Result<Vec<u8>> {
    validate_json_domain(value)?;
    let mut output = Vec::new();
    write_canonical(value, &mut output)?;
    Ok(output)
}

fn write_canonical(value: &Value, output: &mut Vec<u8>) -> Result<()> {
    match value {
        Value::Null => output.extend_from_slice(b"null"),
        Value::Bool(true) => output.extend_from_slice(b"true"),
        Value::Bool(false) => output.extend_from_slice(b"false"),
        Value::Number(number) => output.extend_from_slice(number.to_string().as_bytes()),
        Value::String(string) => {
            output.extend_from_slice(serde_json::to_string(string)?.as_bytes())
        }
        Value::Array(values) => {
            output.push(b'[');
            for (index, item) in values.iter().enumerate() {
                if index > 0 {
                    output.push(b',');
                }
                write_canonical(item, output)?;
            }
            output.push(b']');
        }
        Value::Object(values) => {
            output.push(b'{');
            let mut keys: Vec<_> = values.keys().collect();
            keys.sort_by(|left, right| left.encode_utf16().cmp(right.encode_utf16()));
            for (index, key) in keys.iter().enumerate() {
                if index > 0 {
                    output.push(b',');
                }
                output.extend_from_slice(serde_json::to_string(key)?.as_bytes());
                output.push(b':');
                write_canonical(&values[*key], output)?;
            }
            output.push(b'}');
        }
    }
    Ok(())
}

fn operation_digest_value(operation: &OwnerLaneOperation) -> Result<Value> {
    let mut value = serde_json::to_value(operation)?;
    value
        .as_object_mut()
        .context("operation is not an object")?
        .remove("request_digest");
    Ok(value)
}

fn operation_request_digest(operation: &OwnerLaneOperation) -> Result<String> {
    digest_value(&operation_digest_value(operation)?)
}

fn digest_value(value: &Value) -> Result<String> {
    Ok(sha256_prefixed(&canonical_json(value)?))
}

fn digest_domain_parts(domain: &[u8], parts: &[&[u8]]) -> String {
    let mut hasher = Sha256::new();
    hasher.update(domain);
    for part in parts {
        hasher.update((*part).len().to_be_bytes());
        hasher.update(part);
    }
    format!("sha256:{}", hex::encode(hasher.finalize()))
}

fn sha256_prefixed(bytes: &[u8]) -> String {
    format!("sha256:{}", hex::encode(Sha256::digest(bytes)))
}

fn is_lower_hex(value: &str, length: usize) -> bool {
    value.len() == length
        && value
            .bytes()
            .all(|byte| matches!(byte, b'0'..=b'9' | b'a'..=b'f'))
}

fn is_sha256_digest(value: &str) -> bool {
    value
        .strip_prefix("sha256:")
        .is_some_and(|digest| is_lower_hex(digest, 64))
}

fn valid_operation_id(value: &str) -> bool {
    !value.is_empty()
        && value.len() <= 64
        && value
            .bytes()
            .all(|byte| matches!(byte, b'a'..=b'z' | b'0'..=b'9' | b'-'))
        && !value.starts_with('-')
}

fn valid_run_id(value: &str) -> bool {
    !value.is_empty()
        && value.len() <= 128
        && value
            .bytes()
            .all(|byte| matches!(byte, b'a'..=b'z' | b'0'..=b'9' | b'-' | b'_' | b'.'))
        && value
            .bytes()
            .next()
            .is_some_and(|byte| byte.is_ascii_lowercase() || byte.is_ascii_digit())
}

fn sha256_file(path: &Path) -> Result<String> {
    Ok(sha256_prefixed(&fs::read(path)?))
}

fn operation_digest_sha(value: &str) -> String {
    hex::encode(Sha256::digest(value.as_bytes()))[..16].to_string()
}

fn split_http_response(stdout: &[u8]) -> Result<(BTreeMap<String, String>, Vec<u8>, u16)> {
    let split = stdout
        .iter()
        .rposition(|byte| *byte == b'\n')
        .context("curl response lacks HTTP status")?;
    let status = std::str::from_utf8(&stdout[split + 1..])?
        .trim()
        .parse::<u16>()?;
    let payload = &stdout[..split];
    let header_end = payload
        .windows(4)
        .position(|window| window == b"\r\n\r\n")
        .context("curl response lacks a complete header block")?;
    let header_block = std::str::from_utf8(&payload[..header_end])?;
    let mut lines = header_block.split("\r\n");
    let status_line = lines.next().context("curl response lacks status line")?;
    let status_line_code = status_line
        .split_ascii_whitespace()
        .nth(1)
        .context("curl response has an invalid status line")?
        .parse::<u16>()?;
    if !status_line.starts_with("HTTP/") || status_line_code != status {
        bail!("curl response has an invalid status line");
    }
    let mut headers = BTreeMap::new();
    for line in lines {
        let (name, value) = line
            .split_once(':')
            .context("curl response contains a malformed header")?;
        let name = name.trim().to_ascii_lowercase();
        if headers
            .insert(name.clone(), value.trim().to_string())
            .is_some()
        {
            bail!("curl response contains duplicate header {name}");
        }
    }
    Ok((headers, payload[header_end + 4..].to_vec(), status))
}

fn canonical_contained_path(repo_root: &Path, candidate: &Path) -> Result<PathBuf> {
    let canonical_root = fs::canonicalize(repo_root)?;
    let candidate = if candidate.is_absolute() {
        let normalized_candidate = normalize_path(candidate);
        let normalized_input_root = normalize_path(repo_root);
        if let Ok(relative) = normalized_candidate.strip_prefix(&normalized_input_root) {
            canonical_root.join(relative)
        } else {
            normalized_candidate
        }
    } else {
        canonical_root.join(candidate)
    };
    let normalized = normalize_path(&candidate);
    if !normalized.starts_with(&canonical_root) {
        bail!("owner-lane evidence root escapes the repository");
    }
    let mut current = canonical_root.clone();
    for component in normalized.strip_prefix(&canonical_root)?.components() {
        current.push(component.as_os_str());
        match fs::symlink_metadata(&current) {
            Ok(metadata) if metadata.file_type().is_symlink() => {
                bail!("owner-lane evidence root traverses a symlink");
            }
            Ok(metadata) if !metadata.is_dir() && current != normalized => {
                bail!("owner-lane evidence root traverses a non-directory");
            }
            Ok(_) => {}
            Err(error) if error.kind() == std::io::ErrorKind::NotFound => break,
            Err(error) => return Err(error.into()),
        }
    }
    Ok(normalized)
}

fn normalize_path(path: &Path) -> PathBuf {
    let mut result = PathBuf::new();
    for component in path.components() {
        match component {
            std::path::Component::CurDir => {}
            std::path::Component::ParentDir => {
                result.pop();
            }
            other => result.push(other.as_os_str()),
        }
    }
    result
}

fn relative_path(repo_root: &Path, path: &Path) -> Result<String> {
    Ok(path
        .strip_prefix(fs::canonicalize(repo_root)?)?
        .to_string_lossy()
        .to_string())
}

fn require_schema(actual: &str, expected: &str) -> Result<()> {
    if actual != expected {
        bail!("schema version {actual} does not equal {expected}");
    }
    Ok(())
}

fn escape_curl_config(value: &str) -> String {
    value
        .replace('\\', "\\\\")
        .replace('"', "\\\"")
        .replace('\n', "\\n")
}

fn current_timestamp() -> String {
    time::OffsetDateTime::now_utc()
        .format(&time::format_description::well_known::Rfc3339)
        .unwrap_or_else(|_| "1970-01-01T00:00:00Z".to_string())
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;
    use std::os::unix::fs::PermissionsExt;

    struct FixtureRunner {
        calls: usize,
        unknown_at: Option<usize>,
        false_terminal: bool,
        reconcile_matches: usize,
    }

    impl OperationRunner for FixtureRunner {
        fn run(
            &mut self,
            operation: &OwnerLaneOperation,
            _tools: &BTreeMap<String, ToolBinding>,
            secret: &[u8],
        ) -> Result<OperationResult> {
            self.calls += 1;
            assert!(!operation
                .url
                .as_bytes()
                .windows(secret.len())
                .any(|value| value == secret));
            if self.unknown_at == Some(self.calls) {
                return Ok(OperationResult {
                    sent: true,
                    status: None,
                    headers: BTreeMap::new(),
                    response: Vec::new(),
                });
            }
            let mut headers = BTreeMap::new();
            let response = match operation.kind {
                OperationKind::IdentityProbe => {
                    serde_json::to_vec(&json!({"login": PRINCIPAL_LOGIN, "id": PRINCIPAL_ID}))?
                }
                OperationKind::RepositoryProbe => {
                    headers.insert(
                        "x-accepted-github-permissions".to_string(),
                        "administration=write; actions=write; variables=write; contents=write; pull_requests=write; checks=read; commit_statuses=read; metadata=read".to_string(),
                    );
                    serde_json::to_vec(&json!({"full_name": REPOSITORY}))?
                }
                OperationKind::PullRequestCreate => serde_json::to_vec(&pull_request_value(37))?,
                OperationKind::PullRequestReconcile => serde_json::to_vec(
                    &(0..self.reconcile_matches)
                        .map(|index| pull_request_value(37 + index as u64))
                        .collect::<Vec<_>>(),
                )?,
                OperationKind::PullRequestMerge => serde_json::to_vec(&json!({"merged": true}))?,
                OperationKind::MainPostRead => serde_json::to_vec(&json!({
                    "object": {"sha": fixture_head_sha()}
                }))?,
                _ => Vec::new(),
            };
            let status =
                if operation.kind == OperationKind::TerminalIdentityProbe && self.false_terminal {
                    200
                } else {
                    operation.expected_statuses[0]
                };
            Ok(OperationResult {
                sent: true,
                status: Some(status),
                headers,
                response,
            })
        }
    }

    struct WrongIdentityRunner(FixtureRunner);

    impl OperationRunner for WrongIdentityRunner {
        fn run(
            &mut self,
            operation: &OwnerLaneOperation,
            tools: &BTreeMap<String, ToolBinding>,
            secret: &[u8],
        ) -> Result<OperationResult> {
            if operation.kind == OperationKind::IdentityProbe {
                self.0.calls += 1;
                return Ok(OperationResult {
                    sent: true,
                    status: Some(200),
                    headers: BTreeMap::new(),
                    response: serde_json::to_vec(&json!({"login": "substituted", "id": 1}))?,
                });
            }
            self.0.run(operation, tools, secret)
        }
    }

    struct PlanFixture {
        root: PathBuf,
        prepared: PreparedOwnerLane,
        secret: Secret,
    }

    fn fixture_head_sha() -> &'static str {
        "46e9900ce8a8b0c9f9d2e6ed1f5239985807f0cc"
    }

    fn fixture_base_sha() -> &'static str {
        "66a226b7751822ea8becf431dafeb5b4f5900d99"
    }

    fn fixture_tree_sha() -> &'static str {
        "5dfc97a4eda2b6d91503761b7b7dbe362d736b52"
    }

    fn pull_request_value(number: u64) -> Value {
        json!({
            "number": number,
            "head": {"sha": fixture_head_sha(), "ref": "octon-rp00"},
            "base": {"sha": fixture_base_sha(), "ref": "main"}
        })
    }

    fn write_executable(path: &Path, contents: &str) {
        fs::create_dir_all(path.parent().unwrap()).unwrap();
        fs::write(path, contents).unwrap();
        fs::set_permissions(path, fs::Permissions::from_mode(0o700)).unwrap();
    }

    fn permission(name: &str, level: &str) -> CredentialPermission {
        CredentialPermission {
            name: name.to_string(),
            level: level.to_string(),
        }
    }

    fn credential_tuple() -> CredentialTuple {
        CredentialTuple {
            credential_class: "fine-grained-personal-access-token".to_string(),
            token_prefix: "github_pat_".to_string(),
            issuer: "github.com".to_string(),
            resource_owner: Principal {
                login: PRINCIPAL_LOGIN.to_string(),
                id: PRINCIPAL_ID,
            },
            selected_repositories: vec![REPOSITORY.to_string()],
            public_read_boundary: "anonymous-equivalent".to_string(),
            permissions: vec![
                permission("administration", "write"),
                permission("actions", "write"),
                permission("variables", "write"),
                permission("contents", "write"),
                permission("pull_requests", "write"),
                permission("checks", "read"),
                permission("commit_statuses", "read"),
                permission("metadata", "read"),
            ],
            capture_channel: "inherited-fd".to_string(),
            api_version: API_VERSION.to_string(),
            issuance_attempt_budget: 1,
            provider_expiry_days: 1,
            local_deadline_seconds: 3_600,
        }
    }

    #[allow(clippy::too_many_arguments)]
    fn planned_operation(
        id: &str,
        sequence: u64,
        stage: OperationStage,
        kind: OperationKind,
        method: &str,
        url: Value,
        expected_status: u16,
        body: Option<Value>,
        refspec: Option<Value>,
        authenticated: bool,
    ) -> PlannedOperation {
        let mut operation = PlannedOperation {
            id: id.to_string(),
            sequence,
            stage,
            kind,
            method: method.to_string(),
            url,
            authenticated,
            no_resend: true,
            expected_statuses: vec![expected_status],
            body,
            refspec,
            template_digest: String::new(),
        };
        operation.template_digest =
            digest_value(&planned_operation_template_value(&operation).unwrap()).unwrap();
        operation
    }

    fn numeric_url(segment: &str, suffix: &str) -> Value {
        json!({
            "prefix": format!("https://api.github.com/repos/{REPOSITORY}/{segment}/"),
            "binding": {"$owner_lane_binding": "canonical_pr_number"},
            "suffix": suffix
        })
    }

    fn operation_plan(tools: BTreeMap<String, ToolBinding>) -> OperationPlan {
        let api = format!("https://api.github.com/repos/{REPOSITORY}");
        let digest_bindings = json!({
            "manifest_digest": {"$owner_lane_binding": "manifest_digest"},
            "attestation_digest": {"$owner_lane_binding": "attestation_digest"},
            "completed_prefix_digest": {"$owner_lane_binding": "completed_prefix_digest"}
        });
        let operations = vec![
            planned_operation(
                "identity",
                1,
                OperationStage::Admission,
                OperationKind::IdentityProbe,
                "GET",
                json!("https://api.github.com/user"),
                200,
                None,
                None,
                true,
            ),
            planned_operation(
                "repository",
                2,
                OperationStage::Admission,
                OperationKind::RepositoryProbe,
                "GET",
                json!(api.clone()),
                200,
                None,
                None,
                true,
            ),
            planned_operation(
                "disable-workflow",
                3,
                OperationStage::Prefix,
                OperationKind::WorkflowDisable,
                "PUT",
                json!(format!("{api}/actions/workflows/ci.yml/disable")),
                204,
                None,
                None,
                true,
            ),
            planned_operation(
                "cancel-run",
                4,
                OperationStage::Prefix,
                OperationKind::WorkflowRunCancel,
                "POST",
                json!(format!("{api}/actions/runs/72043128226/cancel")),
                202,
                None,
                None,
                true,
            ),
            planned_operation(
                "push",
                5,
                OperationStage::Prefix,
                OperationKind::GitPush,
                "PUSH",
                json!("https://github.com/jamesryancooper/octon.git"),
                200,
                None,
                Some(json!(format!(
                    "{}:refs/heads/octon-rp00",
                    fixture_head_sha()
                ))),
                true,
            ),
            planned_operation(
                "create-pr",
                6,
                OperationStage::Prefix,
                OperationKind::PullRequestCreate,
                "POST",
                json!(format!("{api}/pulls")),
                201,
                Some(json!({"title": "RP-00", "head": "octon-rp00", "base": "main"})),
                None,
                true,
            ),
            planned_operation(
                "reconcile-pr",
                7,
                OperationStage::Prefix,
                OperationKind::PullRequestReconcile,
                "GET",
                json!(format!(
                    "{api}/pulls?state=open&head=jamesryancooper%3Aocton-rp00&base=main"
                )),
                200,
                None,
                None,
                true,
            ),
            planned_operation(
                "create-marker",
                8,
                OperationStage::Suffix,
                OperationKind::MarkerCreate,
                "POST",
                numeric_url("issues", "/comments"),
                201,
                Some(json!({"body": digest_bindings})),
                None,
                true,
            ),
            planned_operation(
                "update-ruleset",
                9,
                OperationStage::Suffix,
                OperationKind::RulesetUpdate,
                "PUT",
                json!(format!("{api}/rulesets/1")),
                200,
                Some(
                    json!({"name": "rp00", "evidence": {"$owner_lane_binding": "completed_prefix_digest"}}),
                ),
                None,
                true,
            ),
            planned_operation(
                "trigger-check",
                10,
                OperationStage::Suffix,
                OperationKind::CheckTrigger,
                "POST",
                json!(format!("{api}/dispatches")),
                204,
                Some(
                    json!({"event_type": "rp00", "client_payload": {"attestation": {"$owner_lane_binding": "attestation_digest"}}}),
                ),
                None,
                true,
            ),
            planned_operation(
                "merge",
                11,
                OperationStage::Suffix,
                OperationKind::PullRequestMerge,
                "PUT",
                numeric_url("pulls", "/merge"),
                200,
                Some(json!({"sha": fixture_head_sha()})),
                None,
                true,
            ),
            planned_operation(
                "main-post-read",
                12,
                OperationStage::Suffix,
                OperationKind::MainPostRead,
                "GET",
                json!(format!("{api}/git/ref/heads/main")),
                200,
                None,
                None,
                true,
            ),
            planned_operation(
                "revoke",
                13,
                OperationStage::Terminal,
                OperationKind::CredentialRevoke,
                "POST",
                json!("https://api.github.com/credentials/revoke"),
                202,
                None,
                None,
                false,
            ),
            planned_operation(
                "terminal",
                14,
                OperationStage::Terminal,
                OperationKind::TerminalIdentityProbe,
                "GET",
                json!("https://api.github.com/user"),
                401,
                None,
                None,
                true,
            ),
        ];
        let review_digest = sha256_prefixed(b"accepted-owner-lane-review");
        OperationPlan {
            schema_version: "owner-lane-operation-plan-v1".to_string(),
            plan_id: "rp00-owner-lane-plan".to_string(),
            run_id: "owner-lane-fixture-run".to_string(),
            repository: REPOSITORY.to_string(),
            base_sha: fixture_base_sha().to_string(),
            head_sha: fixture_head_sha().to_string(),
            candidate_tree: fixture_tree_sha().to_string(),
            branch: "octon-rp00".to_string(),
            accepted_review_digest: review_digest.clone(),
            one_attempt_lock: "locked".to_string(),
            replacement_lock: "locked-until-retired".to_string(),
            tools,
            attestation_template: AttestationTemplate {
                repository: REPOSITORY.to_string(),
                base_sha: fixture_base_sha().to_string(),
                candidate_sha: fixture_head_sha().to_string(),
                candidate_tree: fixture_tree_sha().to_string(),
                principal: Principal {
                    login: PRINCIPAL_LOGIN.to_string(),
                    id: PRINCIPAL_ID,
                },
                accepted_review_digest: review_digest,
                attested: true,
            },
            operations,
        }
    }

    fn fixture_plan(label: &str) -> PlanFixture {
        let root = std::env::temp_dir().join(format!(
            "octon-owner-lane-v2-{}-{}-{}",
            std::process::id(),
            label,
            current_timestamp().replace([':', '.'], "-")
        ));
        let _ = fs::remove_dir_all(&root);
        fs::create_dir_all(root.join(".git")).unwrap();
        let mut tools = BTreeMap::new();
        for id in ["curl", "git", "mkfifo"] {
            let path = root.join(format!("tool-{id}"));
            write_executable(&path, "#!/bin/sh\nexit 0\n");
            let canonical = fs::canonicalize(path).unwrap();
            tools.insert(
                id.to_string(),
                ToolBinding {
                    canonical_path: canonical.to_string_lossy().to_string(),
                    sha256: sha256_file(&canonical).unwrap(),
                },
            );
        }
        let askpass = root
            .join(".octon/framework/execution-roles/_ops/scripts/git/git-owner-lane-askpass.sh");
        write_executable(&askpass, "#!/bin/sh\nexit 0\n");
        let canonical_askpass = fs::canonicalize(askpass).unwrap();
        tools.insert(
            "askpass".to_string(),
            ToolBinding {
                canonical_path: canonical_askpass.to_string_lossy().to_string(),
                sha256: sha256_file(&canonical_askpass).unwrap(),
            },
        );

        let operation_plan = operation_plan(tools);
        let operation_plan_digest = digest_serializable(&operation_plan).unwrap();
        let evidence_rel = format!(".octon/state/evidence/owner-lane/{label}");
        let authorization = AdmissionAuthorization {
            schema_version: "owner-lane-credential-admission-authorization-v1".to_string(),
            authorization_id: "fixture-authorization".to_string(),
            accepted_review_digest: operation_plan.accepted_review_digest.clone(),
            run_id: operation_plan.run_id.clone(),
            repository: REPOSITORY.to_string(),
            base_sha: operation_plan.base_sha.clone(),
            candidate_sha: operation_plan.head_sha.clone(),
            candidate_tree: operation_plan.candidate_tree.clone(),
            principal: Principal {
                login: PRINCIPAL_LOGIN.to_string(),
                id: PRINCIPAL_ID,
            },
            credential_tuple: credential_tuple(),
            operation_plan_digest: operation_plan_digest.clone(),
            evidence_root: evidence_rel.clone(),
            request_budgets: RequestBudgets {
                identity_probe: 1,
                repository_probe: 1,
                revocation: 1,
                retirement_probe: 1,
                revocation_wait_seconds: 0,
            },
            allowed_admission_probes: vec!["identity".to_string(), "repository".to_string()],
            no_resend: true,
            one_attempt_lock: "locked".to_string(),
            replacement_lock: "locked-until-retired".to_string(),
            _authorized_at: current_timestamp(),
        };
        let authorization_digest = digest_serializable(&authorization).unwrap();
        let issued_at = time::OffsetDateTime::now_utc();
        let format = &time::format_description::well_known::Rfc3339;
        let capture = CredentialCaptureMetadata {
            schema_version: "owner-lane-credential-capture-metadata-v1".to_string(),
            run_id: authorization.run_id.clone(),
            authorization_digest,
            operation_plan_digest,
            capture_source: "github-fine-grained-pat-ui".to_string(),
            issuance_attempts: 1,
            issued_at: issued_at.format(format).unwrap(),
            provider_expires_at: (issued_at + time::Duration::days(1))
                .format(format)
                .unwrap(),
            local_deadline: (issued_at + time::Duration::seconds(3_600))
                .format(format)
                .unwrap(),
            resource_owner: authorization.principal.clone(),
            selected_repositories: authorization.credential_tuple.selected_repositories.clone(),
            permissions: authorization.credential_tuple.permissions.clone(),
            no_secret_retained: true,
            _recorded_at: issued_at.format(format).unwrap(),
        };
        let input = root.join("inputs");
        fs::create_dir_all(&input).unwrap();
        let authorization_path = input.join("authorization.json");
        let capture_path = input.join("capture.json");
        let plan_path = input.join("plan.json");
        write_json_sync(&authorization_path, &authorization).unwrap();
        write_json_sync(&capture_path, &capture).unwrap();
        write_json_sync(&plan_path, &operation_plan).unwrap();
        let paths = ArtifactPaths {
            authorization: authorization_path,
            capture_metadata: capture_path,
            operation_plan: plan_path,
            evidence_root: root.join(evidence_rel),
        };
        let prepared = prepare(&root, &paths).unwrap();
        PlanFixture {
            root,
            prepared,
            secret: Secret(b"github_pat_fixture_owner_lane_v2_secret".to_vec()),
        }
    }

    #[test]
    fn owner_lane_rejects_duplicate_keys_floats_and_large_integers() {
        assert!(parse_strict_json(br#"{"a":1,"a":2}"#).is_err());
        assert!(parse_strict_json(br#"{"a":1.0}"#).is_err());
        assert!(parse_strict_json(br#"{"a":9007199254740992}"#).is_err());
        assert_eq!(
            canonical_json(&json!({"\u{e000}": 2, "\u{1f600}": 1})).unwrap(),
            "{\"😀\":1,\"\":2}".as_bytes()
        );
    }

    #[test]
    fn owner_lane_rejects_unknown_or_arbitrary_template_bindings() {
        assert!(validate_binding_domain(&json!({"$owner_lane_binding": "predicted_pr"})).is_err());
        assert!(validate_binding_domain(&json!("pull/${canonical_pr_number}")).is_err());
    }

    #[test]
    fn owner_lane_rejects_incomplete_tuple_capture_drift_and_temporal_forgery() {
        let mut tuple = credential_tuple();
        tuple.permissions.pop();
        assert!(validate_credential_tuple(&tuple).is_err());

        let fixture = fixture_plan("input-negative");
        let mut capture = fixture.prepared.plan.capture_metadata.clone();
        capture.permissions.pop();
        assert!(
            validate_capture_metadata_tuple(&fixture.prepared.plan.authorization, &capture)
                .is_err()
        );

        capture = fixture.prepared.plan.capture_metadata.clone();
        capture.issued_at = "2026-07-17T10:00:00Z".to_string();
        capture._recorded_at = "2026-07-17T10:00:00Z".to_string();
        capture.local_deadline = "2026-07-17T11:00:00Z".to_string();
        capture.provider_expires_at = "2026-07-18T10:00:00Z".to_string();
        let mut authorization = fixture.prepared.plan.authorization.clone();
        authorization._authorized_at = "2026-07-17T10:00:01Z".to_string();
        assert!(validate_capture_times(&authorization, &capture).is_err());

        let mut plan = fixture.prepared.plan.operation_plan.clone();
        plan.operations[4].refspec = Some(json!(format!(
            "{}:refs/heads/substituted",
            fixture_head_sha()
        )));
        plan.operations[4].template_digest =
            digest_value(&planned_operation_template_value(&plan.operations[4]).unwrap()).unwrap();
        assert!(validate_planned_operations(&plan).is_err());

        plan = fixture.prepared.plan.operation_plan.clone();
        plan.operations[5].body =
            Some(json!({"title": "RP-00", "head": "substituted", "base": "main"}));
        plan.operations[5].template_digest =
            digest_value(&planned_operation_template_value(&plan.operations[5]).unwrap()).unwrap();
        assert!(validate_planned_operations(&plan).is_err());
        let _ = fs::remove_dir_all(fixture.root);
    }

    #[test]
    fn owner_lane_staged_protocol_generates_ordered_evidence_and_retires() {
        let mut fixture = fixture_plan("full");
        let mut runner = FixtureRunner {
            calls: 0,
            unknown_at: None,
            false_terminal: false,
            reconcile_matches: 1,
        };
        execute_staged_plan(&fixture.prepared.plan, &mut fixture.secret, &mut runner).unwrap();
        assert_eq!(runner.calls, 14);
        for path in [
            &fixture.prepared.plan.issuance_path,
            &fixture.prepared.plan.lifecycle_path,
            &fixture.prepared.plan.admission_path,
            &fixture.prepared.plan.manifest_path,
            &fixture.prepared.plan.attestation_path,
            &fixture.prepared.plan.completed_prefix_path,
            &fixture.prepared.plan.retirement_path,
        ] {
            assert!(path.is_file(), "missing staged artifact {}", path.display());
        }
        let prefix = read_strict_json(&fixture.prepared.plan.completed_prefix_path).unwrap();
        assert_eq!(prefix["canonical_pr_number"], 37);
        assert_eq!(
            fs::read_dir(
                fixture
                    .prepared
                    .plan
                    .evidence_root
                    .join("operation-construction")
            )
            .unwrap()
            .count(),
            5
        );
        assert_eq!(
            fs::read_dir(
                fixture
                    .prepared
                    .plan
                    .evidence_root
                    .join("operation-responses")
            )
            .unwrap()
            .count(),
            14
        );
        assert!(fixture.secret.expose().is_empty());
        let _ = fs::remove_dir_all(fixture.root);
    }

    #[test]
    fn owner_lane_matching_restart_resumes_without_resend() {
        let mut fixture = fixture_plan("matching-resume");
        let mut first = FixtureRunner {
            calls: 0,
            unknown_at: None,
            false_terminal: false,
            reconcile_matches: 1,
        };
        execute_staged_plan(&fixture.prepared.plan, &mut fixture.secret, &mut first).unwrap();
        assert_eq!(first.calls, 14);

        fixture.secret = Secret(b"github_pat_fixture_owner_lane_v2_secret".to_vec());
        let mut resumed = FixtureRunner {
            calls: 0,
            unknown_at: None,
            false_terminal: false,
            reconcile_matches: 0,
        };
        execute_staged_plan(&fixture.prepared.plan, &mut fixture.secret, &mut resumed).unwrap();
        assert_eq!(resumed.calls, 0);
        assert!(fixture.secret.expose().is_empty());
        let _ = fs::remove_dir_all(fixture.root);
    }

    #[test]
    fn owner_lane_reconciliation_requires_exactly_one_matching_pr() {
        let mut fixture = fixture_plan("pr-mismatch");
        let mut runner = FixtureRunner {
            calls: 0,
            unknown_at: None,
            false_terminal: false,
            reconcile_matches: 2,
        };
        let error = execute_staged_plan(&fixture.prepared.plan, &mut fixture.secret, &mut runner)
            .expect_err("multiple PRs must fail closed after terminalization");
        assert!(error.to_string().contains("exactly one match"));
        assert!(!fixture.prepared.plan.completed_prefix_path.exists());
        assert!(fixture.prepared.plan.retirement_path.exists());
        let _ = fs::remove_dir_all(fixture.root);
    }

    #[test]
    fn owner_lane_reconciliation_denies_zero_and_substituted_pr_identity() {
        let fixture = fixture_plan("pr-identity-negative");
        assert!(validate_reconciled_pull_request(&fixture.prepared.plan, 37, b"[]").is_err());
        let wrong_number = serde_json::to_vec(&vec![pull_request_value(38)]).unwrap();
        assert!(
            validate_reconciled_pull_request(&fixture.prepared.plan, 37, &wrong_number).is_err()
        );
        let mut substituted = pull_request_value(37);
        substituted["head"]["sha"] = json!(fixture_base_sha());
        let substituted = serde_json::to_vec(&vec![substituted]).unwrap();
        assert!(
            validate_reconciled_pull_request(&fixture.prepared.plan, 37, &substituted).is_err()
        );
        let _ = fs::remove_dir_all(fixture.root);
    }

    #[test]
    fn owner_lane_realized_suffix_mutation_fails_template_normalization() {
        let fixture = fixture_plan("typed-normalization-negative");
        let bindings = Bindings {
            manifest_digest:
                "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
                    .to_string(),
            attestation_digest:
                "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
                    .to_string(),
            completed_prefix_digest:
                "sha256:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc"
                    .to_string(),
            canonical_pr_number: 37,
        };
        let planned = &fixture.prepared.plan.operation_plan.operations[7];
        let mut realized = realize_operation(planned, &bindings).unwrap();
        realized.body = Some(json!({"body": "substituted"}));
        realized.request_digest = operation_request_digest(&realized).unwrap();
        assert!(normalize_realized_operation(planned, &realized, &bindings).is_err());
        let _ = fs::remove_dir_all(fixture.root);
    }

    #[test]
    fn owner_lane_unknown_outcome_is_never_replayed() {
        let mut fixture = fixture_plan("unknown");
        let mut first = FixtureRunner {
            calls: 0,
            unknown_at: Some(3),
            false_terminal: false,
            reconcile_matches: 1,
        };
        let error = execute_staged_plan(&fixture.prepared.plan, &mut fixture.secret, &mut first)
            .expect_err("unknown outcome must stop mutations");
        assert!(error.to_string().contains("outcome-unknown"));
        fixture.secret = Secret(b"github_pat_fixture_owner_lane_v2_secret".to_vec());
        let mut retry = FixtureRunner {
            calls: 0,
            unknown_at: None,
            false_terminal: false,
            reconcile_matches: 1,
        };
        let retry_error =
            execute_staged_plan(&fixture.prepared.plan, &mut fixture.secret, &mut retry)
                .expect_err("completed or unknown requests must not replay");
        assert!(retry_error.to_string().contains("outcome-unknown"));
        assert_eq!(retry.calls, 0);
        let _ = fs::remove_dir_all(fixture.root);
    }

    #[test]
    fn owner_lane_every_send_boundary_denies_unknown_outcome_without_resend() {
        for boundary in 1..=14 {
            let mut fixture = fixture_plan(&format!("unknown-boundary-{boundary}"));
            let mut first = FixtureRunner {
                calls: 0,
                unknown_at: Some(boundary),
                false_terminal: false,
                reconcile_matches: 1,
            };
            let error =
                execute_staged_plan(&fixture.prepared.plan, &mut fixture.secret, &mut first)
                    .expect_err("every unknown send boundary must fail closed");
            assert!(error.to_string().contains("outcome-unknown"));

            fixture.secret = Secret(b"github_pat_fixture_owner_lane_v2_secret".to_vec());
            let mut retry = FixtureRunner {
                calls: 0,
                unknown_at: None,
                false_terminal: false,
                reconcile_matches: 1,
            };
            let retry_error =
                execute_staged_plan(&fixture.prepared.plan, &mut fixture.secret, &mut retry)
                    .expect_err("unknown request digest must remain non-replayable");
            assert!(retry_error.to_string().contains("outcome-unknown"));
            assert_eq!(retry.calls, 0);
            let _ = fs::remove_dir_all(fixture.root);
        }
    }

    #[test]
    fn owner_lane_expired_unseen_work_enters_terminalization_only() {
        let mut fixture = fixture_plan("expired-terminalization");
        let issued_at = time::OffsetDateTime::now_utc() - time::Duration::hours(2);
        let format = &time::format_description::well_known::Rfc3339;
        fixture.prepared.plan.authorization._authorized_at = issued_at.format(format).unwrap();
        fixture.prepared.plan.capture_metadata.issued_at = issued_at.format(format).unwrap();
        fixture.prepared.plan.capture_metadata._recorded_at = issued_at.format(format).unwrap();
        fixture.prepared.plan.capture_metadata.provider_expires_at = (issued_at
            + time::Duration::days(1))
        .format(format)
        .unwrap();
        fixture.prepared.plan.capture_metadata.local_deadline = (issued_at
            + time::Duration::hours(1))
        .format(format)
        .unwrap();
        let mut runner = FixtureRunner {
            calls: 0,
            unknown_at: None,
            false_terminal: false,
            reconcile_matches: 1,
        };
        let error = execute_staged_plan(&fixture.prepared.plan, &mut fixture.secret, &mut runner)
            .expect_err("expired unseen repository work must not execute");
        assert!(error.to_string().contains("deadline has expired"));
        assert_eq!(runner.calls, 2, "only revoke and terminal probe may run");
        assert!(fixture.secret.expose().is_empty());
        let _ = fs::remove_dir_all(fixture.root);
    }

    #[test]
    fn owner_lane_false_terminal_identity_is_denied() {
        let mut fixture = fixture_plan("false-terminal");
        let mut runner = FixtureRunner {
            calls: 0,
            unknown_at: None,
            false_terminal: true,
            reconcile_matches: 1,
        };
        let error = execute_staged_plan(&fixture.prepared.plan, &mut fixture.secret, &mut runner)
            .expect_err("same-token 200 is not retirement");
        assert!(error.to_string().contains("unexpected status 200"));
        assert!(!fixture.prepared.plan.retirement_path.exists());
        let _ = fs::remove_dir_all(fixture.root);
    }

    #[test]
    fn owner_lane_admission_semantic_failure_still_terminalizes() {
        let mut fixture = fixture_plan("admission-terminalization");
        let mut runner = WrongIdentityRunner(FixtureRunner {
            calls: 0,
            unknown_at: None,
            false_terminal: false,
            reconcile_matches: 1,
        });
        let error = execute_staged_plan(&fixture.prepared.plan, &mut fixture.secret, &mut runner)
            .expect_err("wrong admitted principal must fail after retirement");
        assert!(error.to_string().contains("principal mismatch"));
        assert_eq!(
            runner.0.calls, 3,
            "identity, revoke, and terminal probe run"
        );
        assert!(fixture.prepared.plan.retirement_path.is_file());
        assert!(fixture.secret.expose().is_empty());
        let _ = fs::remove_dir_all(fixture.root);
    }

    #[test]
    fn owner_lane_tool_drift_after_preflight_denies_before_send() {
        let mut fixture = fixture_plan("tool-drift");
        let curl =
            PathBuf::from(&fixture.prepared.plan.operation_plan.tools["curl"].canonical_path);
        fs::write(curl, b"substituted\n").unwrap();
        let mut runner = FixtureRunner {
            calls: 0,
            unknown_at: None,
            false_terminal: false,
            reconcile_matches: 1,
        };
        let error = execute_staged_plan(&fixture.prepared.plan, &mut fixture.secret, &mut runner)
            .expect_err("tool substitution must deny");
        assert!(error.to_string().contains("digest drift"));
        assert_eq!(runner.calls, 0);
        let _ = fs::remove_dir_all(fixture.root);
    }
}
