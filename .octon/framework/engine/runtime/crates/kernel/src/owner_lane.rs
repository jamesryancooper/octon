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
    pub issuance_outcome: PathBuf,
    pub lifecycle_envelope: PathBuf,
    pub admission_receipt: PathBuf,
    pub manifest: PathBuf,
    pub attestation: PathBuf,
    pub evidence_root: PathBuf,
}

#[derive(Debug, Deserialize)]
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
    manifest_digest: String,
    operation_digest: String,
    evidence_root: String,
    one_attempt_lock: String,
    #[serde(rename = "authorized_at")]
    _authorized_at: String,
}

#[derive(Debug, Deserialize)]
#[serde(deny_unknown_fields)]
struct Principal {
    login: String,
    id: u64,
}

#[derive(Debug, Deserialize)]
#[serde(deny_unknown_fields)]
struct CredentialTuple {
    credential_class: String,
    issuer: String,
    capture_channel: String,
    api_version: String,
}

#[derive(Debug, Deserialize)]
#[serde(deny_unknown_fields)]
struct IssuanceOutcome {
    schema_version: String,
    run_id: String,
    authorization_digest: String,
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

#[derive(Debug, Deserialize)]
#[serde(deny_unknown_fields)]
struct LifecycleEnvelope {
    schema_version: String,
    run_id: String,
    authorization_digest: String,
    issuance_outcome_digest: String,
    manifest_digest: String,
    attestation_digest: String,
    credential_handle_nonce: String,
    credential_handle_digest: String,
    identity_probe_budget: u64,
    repository_probe_budget: u64,
    revocation_budget: u64,
    retirement_probe_budget: u64,
    revocation_wait_seconds: u64,
    actual_reached_phase: String,
    evidence_root: String,
}

#[derive(Debug, Deserialize)]
#[serde(deny_unknown_fields)]
struct AdmissionReceipt {
    schema_version: String,
    run_id: String,
    lifecycle_digest: String,
    identity_status: u16,
    repository_status: u16,
    login: String,
    id: u64,
    api_version: String,
    accepted_permissions: BTreeMap<String, String>,
    pagination_complete: bool,
    admitted: bool,
    prior_authenticated_200: bool,
    #[serde(rename = "recorded_at")]
    _recorded_at: String,
}

#[derive(Debug, Deserialize)]
#[serde(deny_unknown_fields)]
struct Attestation {
    schema_version: String,
    run_id: String,
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

#[derive(Debug, Deserialize)]
#[serde(deny_unknown_fields)]
struct OperationManifest {
    schema_version: String,
    run_id: String,
    repository: String,
    base_sha: String,
    head_sha: String,
    candidate_tree: String,
    attestation_digest: String,
    operation_digest: String,
    one_attempt_lock: String,
    tools: BTreeMap<String, ToolBinding>,
    operations: Vec<OwnerLaneOperation>,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct OwnerLaneOperation {
    id: String,
    sequence: u64,
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
    #[serde(default, skip_serializing_if = "Option::is_none")]
    observation_digest: Option<String>,
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
    MarkerCreate,
    RulesetUpdate,
    CheckTrigger,
    PullRequestMerge,
    MainPostRead,
    CredentialRevoke,
    TerminalIdentityProbe,
}

impl OperationKind {
    fn is_mutation(self) -> bool {
        matches!(
            self,
            Self::WorkflowDisable
                | Self::WorkflowRunCancel
                | Self::GitPush
                | Self::PullRequestCreate
                | Self::MarkerCreate
                | Self::RulesetUpdate
                | Self::CheckTrigger
                | Self::PullRequestMerge
        )
    }
}

#[derive(Debug)]
struct ValidatedPlan {
    authorization: AdmissionAuthorization,
    issuance: IssuanceOutcome,
    lifecycle: LifecycleEnvelope,
    admission: AdmissionReceipt,
    manifest: OperationManifest,
    _attestation: Attestation,
    lifecycle_digest: String,
    manifest_digest: String,
    evidence_root: PathBuf,
    journal_path: PathBuf,
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
            "github://repo/{REPOSITORY}/rp00-owner-lane-cutover/run/{}/authorization/{}/review/{}/base/{}/candidate/{}/tree/{}/manifest/{}/operation/{}/principal/{}:{}",
            self.plan.authorization.run_id,
            self.plan.authorization.authorization_id,
            self.plan.authorization.accepted_review_digest,
            self.plan.authorization.base_sha,
            self.plan.authorization.candidate_sha,
            self.plan.authorization.candidate_tree,
            self.plan.manifest_digest,
            self.plan.authorization.operation_digest,
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
    lifecycle_digest: String,
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
    lifecycle_digest: &'a str,
    operation_id: &'a str,
    sequence: u64,
    request_digest: &'a str,
    prior_observation_digest: &'a str,
    cycle_free: bool,
    constructed_at: String,
}

#[derive(Debug, Serialize)]
struct CompletedPrefixReceipt<'a> {
    schema_version: &'static str,
    run_id: &'a str,
    manifest_digest: &'a str,
    operation_digest: &'a str,
    completed_operation_ids: &'a [String],
    last_sequence: u64,
    journal_digest: String,
    terminal_state: &'a str,
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
    fs::create_dir_all(&prepared.plan.evidence_root)?;
    let mut secret = read_credential_fd(credential_fd)?;
    verify_secret_binding(&prepared.plan, &secret)?;
    let mut runner = SystemRunner {
        repo_root,
        fifo_active: false,
    };
    execute_validated_plan(&prepared.plan, &mut secret, &mut runner)
}

fn validate_plan(repo_root: &Path, paths: &ArtifactPaths) -> Result<ValidatedPlan> {
    let authorization_value = read_strict_json(&paths.authorization)?;
    let issuance_value = read_strict_json(&paths.issuance_outcome)?;
    let lifecycle_value = read_strict_json(&paths.lifecycle_envelope)?;
    let admission_value = read_strict_json(&paths.admission_receipt)?;
    let manifest_value = read_strict_json(&paths.manifest)?;
    let attestation_value = read_strict_json(&paths.attestation)?;

    let authorization: AdmissionAuthorization =
        serde_json::from_value(authorization_value.clone())?;
    let issuance: IssuanceOutcome = serde_json::from_value(issuance_value.clone())?;
    let lifecycle: LifecycleEnvelope = serde_json::from_value(lifecycle_value.clone())?;
    let admission: AdmissionReceipt = serde_json::from_value(admission_value.clone())?;
    let manifest: OperationManifest = serde_json::from_value(manifest_value.clone())?;
    let attestation: Attestation = serde_json::from_value(attestation_value.clone())?;

    let auth_digest = digest_value(&authorization_value)?;
    let issuance_digest = digest_value(&issuance_value)?;
    let lifecycle_digest = digest_value(&lifecycle_value)?;
    let manifest_digest = digest_value(&manifest_value)?;
    let attestation_digest = digest_value(&attestation_value)?;

    require_schema(
        &authorization.schema_version,
        "owner-lane-credential-admission-authorization-v1",
    )?;
    require_schema(
        &issuance.schema_version,
        "owner-lane-credential-issuance-outcome-receipt-v1",
    )?;
    require_schema(
        &lifecycle.schema_version,
        "owner-lane-credential-lifecycle-envelope-v1",
    )?;
    require_schema(
        &admission.schema_version,
        "owner-lane-credential-admission-receipt-v1",
    )?;
    require_schema(&manifest.schema_version, "owner-lane-operation-manifest-v1")?;
    require_schema(&attestation.schema_version, "owner-lane-attestation-v1")?;

    for digest in [
        authorization.accepted_review_digest.as_str(),
        authorization.manifest_digest.as_str(),
        authorization.operation_digest.as_str(),
        issuance.authorization_digest.as_str(),
        issuance.nonce_salted_handle_digest.as_str(),
        issuance.header_digest.as_str(),
        issuance.revocation_body_digest.as_str(),
        lifecycle.authorization_digest.as_str(),
        lifecycle.issuance_outcome_digest.as_str(),
        lifecycle.manifest_digest.as_str(),
        lifecycle.attestation_digest.as_str(),
        lifecycle.credential_handle_digest.as_str(),
        admission.lifecycle_digest.as_str(),
        manifest.attestation_digest.as_str(),
        manifest.operation_digest.as_str(),
        attestation.accepted_review_digest.as_str(),
    ] {
        if !is_sha256_digest(digest) {
            bail!("owner-lane artifact contains a malformed SHA-256 digest");
        }
    }
    for sha in [
        authorization.base_sha.as_str(),
        authorization.candidate_sha.as_str(),
        authorization.candidate_tree.as_str(),
        manifest.base_sha.as_str(),
        manifest.head_sha.as_str(),
        manifest.candidate_tree.as_str(),
        attestation.base_sha.as_str(),
        attestation.candidate_sha.as_str(),
        attestation.candidate_tree.as_str(),
    ] {
        if !is_lower_hex(sha, 40) {
            bail!("owner-lane artifact contains a malformed Git object id");
        }
    }
    for timestamp in [
        authorization._authorized_at.as_str(),
        issuance._recorded_at.as_str(),
        admission._recorded_at.as_str(),
        attestation._recorded_at.as_str(),
    ] {
        time::OffsetDateTime::parse(timestamp, &time::format_description::well_known::Rfc3339)
            .context("owner-lane artifact timestamp is not RFC 3339")?;
    }

    if authorization.repository != REPOSITORY
        || manifest.repository != REPOSITORY
        || attestation.repository != REPOSITORY
    {
        bail!("owner-lane repository binding must be {REPOSITORY}");
    }

    if !valid_run_id(&authorization.run_id) {
        bail!("owner-lane run id is not a safe canonical identifier");
    }
    if authorization.credential_tuple.credential_class != "fine-grained-personal-access-token"
        || authorization.credential_tuple.issuer != "github.com"
        || authorization.credential_tuple.capture_channel != "inherited-fd"
        || authorization.credential_tuple.api_version != API_VERSION
    {
        bail!("owner-lane credential tuple is not the closed GitHub fine-grained PAT tuple");
    }
    if authorization.one_attempt_lock != "locked" || manifest.one_attempt_lock != "locked" {
        bail!("owner-lane one-attempt lock must be locked");
    }
    if !issuance.issued
        || issuance.issuance_attempts != 1
        || issuance.issuer != "github.com"
        || !issuance.no_secret_retained
    {
        bail!("credential issuance outcome is not a single successful secret-free issuance");
    }
    if !admission.admitted
        || !admission.pagination_complete
        || !admission.prior_authenticated_200
        || admission.identity_status != 200
        || admission.repository_status != 200
        || admission.api_version != API_VERSION
        || admission.accepted_permissions.is_empty()
        || admission
            .accepted_permissions
            .values()
            .any(|permission| !matches!(permission.as_str(), "read" | "write"))
    {
        bail!("credential admission receipt is not complete and admitted");
    }
    if !attestation.attested {
        bail!("owner-lane attestation is not affirmative");
    }
    let run_ids = [
        issuance.run_id.as_str(),
        lifecycle.run_id.as_str(),
        admission.run_id.as_str(),
        manifest.run_id.as_str(),
        attestation.run_id.as_str(),
    ];
    if run_ids.iter().any(|run_id| *run_id != authorization.run_id) {
        bail!("owner-lane artifacts do not bind the same run id");
    }
    if issuance.authorization_digest != auth_digest
        || lifecycle.authorization_digest != auth_digest
        || lifecycle.issuance_outcome_digest != issuance_digest
        || lifecycle.manifest_digest != manifest_digest
        || lifecycle.attestation_digest != attestation_digest
        || admission.lifecycle_digest != lifecycle_digest
        || manifest.attestation_digest != attestation_digest
        || authorization.manifest_digest != manifest_digest
    {
        bail!("owner-lane artifact digest chain mismatch");
    }
    if authorization.operation_digest != manifest.operation_digest {
        bail!("owner-lane operation digest mismatch");
    }
    if authorization.base_sha != manifest.base_sha
        || authorization.candidate_sha != manifest.head_sha
        || authorization.candidate_tree != manifest.candidate_tree
        || attestation.base_sha != manifest.base_sha
        || attestation.candidate_sha != manifest.head_sha
        || attestation.candidate_tree != manifest.candidate_tree
        || attestation.accepted_review_digest != authorization.accepted_review_digest
    {
        bail!("owner-lane candidate or accepted-review binding mismatch");
    }
    if authorization.principal.login != issuance.principal.login
        || authorization.principal.id != issuance.principal.id
        || authorization.principal.login != admission.login
        || authorization.principal.id != admission.id
        || authorization.principal.login != attestation.principal.login
        || authorization.principal.id != attestation.principal.id
    {
        bail!("owner-lane principal binding mismatch");
    }
    if authorization.principal.login != PRINCIPAL_LOGIN
        || authorization.principal.id != PRINCIPAL_ID
    {
        bail!("owner-lane principal must be {PRINCIPAL_LOGIN}:{PRINCIPAL_ID}");
    }
    if lifecycle.identity_probe_budget != 1
        || lifecycle.repository_probe_budget != 1
        || lifecycle.revocation_budget != 1
        || lifecycle.retirement_probe_budget == 0
        || lifecycle.retirement_probe_budget > 8
    {
        bail!("owner-lane finite probe/revocation budgets are invalid");
    }
    if lifecycle.actual_reached_phase != "credential-issued"
        && lifecycle.actual_reached_phase != "admitted"
    {
        bail!("owner-lane lifecycle phase cannot enter execution");
    }
    let evidence_root = canonical_contained_path(repo_root, &paths.evidence_root)?;
    if authorization.evidence_root != relative_path(repo_root, &evidence_root)?
        || lifecycle.evidence_root != authorization.evidence_root
    {
        bail!("owner-lane evidence-root binding mismatch");
    }
    validate_tools(&manifest.tools)?;
    let fixed_askpass = fs::canonicalize(
        repo_root
            .join(".octon/framework/execution-roles/_ops/scripts/git/git-owner-lane-askpass.sh"),
    )?;
    if Path::new(&manifest.tools["askpass"].canonical_path) != fixed_askpass {
        bail!("owner-lane askpass binding is not the fixed repository helper");
    }
    validate_operations(&manifest)?;

    let journal_path = evidence_root.join("owner-lane-events.ndjson");
    let retirement_path = evidence_root.join("credential-retirement-receipt.json");
    Ok(ValidatedPlan {
        authorization,
        issuance,
        lifecycle,
        admission,
        manifest,
        _attestation: attestation,
        lifecycle_digest,
        manifest_digest,
        evidence_root,
        journal_path,
        retirement_path,
    })
}

fn validate_operations(manifest: &OperationManifest) -> Result<()> {
    if manifest.operations.len() < 5 {
        bail!("owner-lane manifest is missing required admission, post-read, or retirement operations");
    }
    let mut ids = BTreeSet::new();
    let mut saw_identity = false;
    let mut saw_repository = false;
    let mut revoke_count = 0;
    let mut terminal_count = 0;
    let mut operation_values = Vec::new();
    for (index, operation) in manifest.operations.iter().enumerate() {
        if operation.sequence != index as u64 + 1
            || !valid_operation_id(&operation.id)
            || !ids.insert(operation.id.clone())
        {
            bail!("owner-lane operation sequence or id is duplicated/reordered");
        }
        if !is_sha256_digest(&operation.request_digest)
            || operation
                .observation_digest
                .as_deref()
                .is_some_and(|digest| !is_sha256_digest(digest))
        {
            bail!("owner-lane operation contains a malformed binding digest");
        }
        if !operation.no_resend || operation.expected_statuses.is_empty() {
            bail!("every owner-lane operation must be no-resend with explicit expected statuses");
        }
        validate_operation_allowlist(operation)?;
        match operation.kind {
            OperationKind::IdentityProbe | OperationKind::RepositoryProbe => {
                if operation.expected_statuses != [200] {
                    bail!("owner-lane admission probes must expect exactly 200");
                }
            }
            OperationKind::CredentialRevoke => {
                if operation.expected_statuses != [202] {
                    bail!("owner-lane credential revoke must expect exactly 202");
                }
            }
            OperationKind::TerminalIdentityProbe => {
                if operation.expected_statuses != [401] {
                    bail!("owner-lane terminal probe must expect exactly 401");
                }
            }
            OperationKind::MainPostRead => {
                if operation.expected_statuses != [200] {
                    bail!("owner-lane authoritative main post-read must expect exactly 200");
                }
            }
            OperationKind::GitPush => {
                let expected_prefix = format!("{}:refs/heads/", manifest.head_sha);
                if !operation
                    .refspec
                    .as_deref()
                    .is_some_and(|refspec| refspec.starts_with(&expected_prefix))
                {
                    bail!("owner-lane Git push is not bound to the manifest head SHA");
                }
            }
            OperationKind::PullRequestMerge => {
                if operation
                    .body
                    .as_ref()
                    .and_then(|body| body.get("sha"))
                    .and_then(Value::as_str)
                    != Some(manifest.head_sha.as_str())
                {
                    bail!("owner-lane merge body must bind sha to the manifest head SHA");
                }
            }
            _ => {}
        }
        let calculated = operation_request_digest(operation)?;
        if calculated != operation.request_digest {
            bail!(
                "owner-lane operation {} request digest mismatch",
                operation.id
            );
        }
        match operation.kind {
            OperationKind::IdentityProbe => saw_identity = true,
            OperationKind::RepositoryProbe => saw_repository = true,
            OperationKind::CredentialRevoke => revoke_count += 1,
            OperationKind::TerminalIdentityProbe => terminal_count += 1,
            kind if kind.is_mutation() => {
                if !saw_identity || !saw_repository || operation.observation_digest.is_none() {
                    bail!(
                        "owner-lane mutation {} lacks admission/observation binding",
                        operation.id
                    );
                }
            }
            _ => {}
        }
        operation_values.push(operation_digest_value(operation)?);
    }
    if manifest.operations[0].kind != OperationKind::IdentityProbe
        || manifest.operations[1].kind != OperationKind::RepositoryProbe
        || manifest.operations[manifest.operations.len() - 2].kind
            != OperationKind::CredentialRevoke
        || manifest.operations.last().map(|op| op.kind)
            != Some(OperationKind::TerminalIdentityProbe)
        || revoke_count != 1
        || terminal_count != 1
    {
        bail!("owner-lane manifest must have fixed admission and terminalization suffix ordering");
    }
    let digest = digest_value(&Value::Array(operation_values))?;
    if digest != manifest.operation_digest {
        bail!("owner-lane manifest operation-set digest mismatch");
    }
    Ok(())
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
        OperationKind::GitPush => {
            require_request(
                operation,
                "PUSH",
                "https://github.com/jamesryancooper/octon.git",
                true,
            )?;
            operation
                .refspec
                .as_deref()
                .context("git push requires refspec")?;
        }
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

fn execute_validated_plan(
    plan: &ValidatedPlan,
    secret: &mut Secret,
    runner: &mut dyn OperationRunner,
) -> Result<()> {
    let mut prior_authenticated_200 = plan.admission.prior_authenticated_200;
    let mut revocation_status = None;
    let mut terminal_status = None;
    let mut completed_operation_ids = Vec::new();
    let mut terminal_only = false;
    let mut primary_failure: Option<anyhow::Error> = None;
    for operation in &plan.manifest.operations {
        if terminal_only
            && !matches!(
                operation.kind,
                OperationKind::CredentialRevoke | OperationKind::TerminalIdentityProbe
            )
        {
            continue;
        }
        match journal_request_state(&plan.journal_path, &operation.request_digest)? {
            JournalRequestState::Completed => {
                secret.zeroize();
                bail!(
                    "owner-lane replay denied: request {} already completed",
                    operation.request_digest
                );
            }
            JournalRequestState::Unknown => {
                secret.zeroize();
                bail!(
                    "outcome-unknown: request {} may never be resent",
                    operation.request_digest
                );
            }
            JournalRequestState::Unseen => {}
        }
        if operation.kind == OperationKind::TerminalIdentityProbe {
            thread::sleep(std::time::Duration::from_secs(
                plan.lifecycle.revocation_wait_seconds,
            ));
        }
        if let Err(error) = plan
            .manifest
            .tools
            .iter()
            .try_for_each(|(id, binding)| verify_tool_binding(id, binding))
        {
            primary_failure.get_or_insert(error);
            terminal_only = true;
            continue;
        }
        write_operation_construction_receipt(plan, operation)?;
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
        let result = match runner.run(operation, &plan.manifest.tools, secret.expose()) {
            Ok(result) if result.sent && result.status.is_some() => result,
            Ok(_) => {
                write_completed_prefix_receipt(
                    plan,
                    &completed_operation_ids,
                    operation.sequence,
                    "outcome-unknown",
                )?;
                primary_failure.get_or_insert_with(|| {
                    anyhow!(
                        "outcome-unknown: operation {} has no terminal response",
                        operation.id
                    )
                });
                terminal_only = true;
                continue;
            }
            Err(error) => {
                write_completed_prefix_receipt(
                    plan,
                    &completed_operation_ids,
                    operation.sequence,
                    "outcome-unknown",
                )?;
                primary_failure.get_or_insert_with(|| {
                    anyhow!(
                        "outcome-unknown: operation {} launch failed: {error}",
                        operation.id
                    )
                });
                terminal_only = true;
                continue;
            }
        };
        let status = result.status.expect("matched above");
        append_journal(
            &plan.journal_path,
            JournalEvent {
                schema_version: "owner-lane-journal-event-v1",
                phase: "response",
                operation_id: &operation.id,
                sequence: operation.sequence,
                request_digest: &operation.request_digest,
                status: Some(status),
                response_digest: Some(sha256_prefixed(&result.response)),
            },
        )?;
        completed_operation_ids.push(operation.id.clone());
        if !operation.expected_statuses.contains(&status) {
            primary_failure.get_or_insert_with(|| {
                anyhow!(
                    "owner-lane operation {} returned unexpected status {status}",
                    operation.id
                )
            });
            terminal_only = true;
            write_completed_prefix_receipt(
                plan,
                &completed_operation_ids,
                operation.sequence,
                "failed-closed",
            )?;
            continue;
        }
        if let Err(error) = validate_operation_response(plan, operation, &result) {
            primary_failure.get_or_insert(error);
            terminal_only = true;
            write_completed_prefix_receipt(
                plan,
                &completed_operation_ids,
                operation.sequence,
                "failed-closed",
            )?;
            continue;
        }
        if operation.authenticated && status == 200 {
            prior_authenticated_200 = true;
        }
        match operation.kind {
            OperationKind::CredentialRevoke => revocation_status = Some(status),
            OperationKind::TerminalIdentityProbe => terminal_status = Some(status),
            _ => {}
        }
        write_completed_prefix_receipt(
            plan,
            &completed_operation_ids,
            operation.sequence,
            if operation.kind == OperationKind::TerminalIdentityProbe {
                "terminalized"
            } else {
                "in-progress"
            },
        )?;
    }
    let secret_census_empty = secret_census(&plan.evidence_root, secret.expose())?;
    secret.zeroize();
    let fifo_removed = runner.fifo_removed();
    if revocation_status != Some(202)
        || terminal_status != Some(401)
        || !prior_authenticated_200
        || !fifo_removed
    {
        return Err(primary_failure.unwrap_or_else(|| {
            anyhow!("owner-lane credential retirement did not prove 202 acceptance and same-token 401 terminality")
        }));
    }
    let receipt = RetirementReceipt {
        schema_version: "owner-lane-credential-retirement-receipt-v1",
        run_id: &plan.authorization.run_id,
        lifecycle_digest: plan.lifecycle_digest.clone(),
        revocation_status: 202,
        terminal_identity_status: 401,
        prior_authenticated_200,
        local_buffer_zeroized: true,
        fifo_removed,
        secret_census_empty,
        retired: true,
        completed_at: current_timestamp(),
    };
    if !receipt.secret_census_empty {
        bail!("owner-lane scoped secret census found credential bytes");
    }
    write_json_sync(&plan.retirement_path, &receipt)?;
    if let Some(error) = primary_failure {
        Err(error)
    } else {
        Ok(())
    }
}

fn validate_operation_response(
    plan: &ValidatedPlan,
    operation: &OwnerLaneOperation,
    result: &OperationResult,
) -> Result<()> {
    match operation.kind {
        OperationKind::IdentityProbe => {
            let value = parse_strict_json(&result.response)?;
            if value.get("login").and_then(Value::as_str)
                != Some(plan.authorization.principal.login.as_str())
                || value.get("id").and_then(Value::as_u64) != Some(plan.authorization.principal.id)
            {
                bail!("owner-lane identity probe principal mismatch");
            }
        }
        OperationKind::RepositoryProbe => {
            let value = parse_strict_json(&result.response)?;
            if value.get("full_name").and_then(Value::as_str) != Some(REPOSITORY) {
                bail!("owner-lane repository probe target mismatch");
            }
            let accepted = result
                .headers
                .get("x-accepted-github-permissions")
                .context("repository probe omitted X-Accepted-GitHub-Permissions")?;
            if parse_accepted_permissions(accepted)? != plan.admission.accepted_permissions {
                bail!("repository probe accepted-permissions header mismatch");
            }
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
                != Some(plan.manifest.head_sha.as_str())
            {
                bail!("owner-lane authoritative main post-read does not equal candidate head");
            }
        }
        _ => {}
    }
    Ok(())
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
        let mut config = Vec::new();
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
            writeln!(
                config,
                "header = \"Authorization: Bearer {}\"",
                String::from_utf8_lossy(secret)
            )?;
        }
        if operation.kind == OperationKind::CredentialRevoke {
            let mut body = revocation_body(secret);
            writeln!(config, "header = \"Content-Type: application/json\"")?;
            writeln!(
                config,
                "data = \"{}\"",
                escape_curl_config(&String::from_utf8_lossy(&body))
            )?;
            body.fill(0);
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
            .write_all(&config)?;
        config.fill(0);
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
    {
        bytes.fill(0);
        bail!("owner-lane credential is not one fine-grained PAT line");
    }
    Ok(Secret(bytes))
}

fn verify_secret_binding(plan: &ValidatedPlan, secret: &Secret) -> Result<()> {
    let handle = digest_domain_parts(
        HANDLE_DOMAIN,
        &[
            plan.lifecycle.credential_handle_nonce.as_bytes(),
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
    if handle != plan.lifecycle.credential_handle_digest
        || handle != plan.issuance.nonce_salted_handle_digest
        || header_digest != plan.issuance.header_digest
        || revocation_digest != plan.issuance.revocation_body_digest
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
    let mut file = OpenOptions::new().create(true).append(true).open(path)?;
    let bytes = serde_json::to_vec(&event)?;
    file.write_all(&bytes)?;
    file.write_all(b"\n")?;
    file.sync_data()?;
    Ok(())
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
enum JournalRequestState {
    Unseen,
    Completed,
    Unknown,
}

fn journal_request_state(path: &Path, request_digest: &str) -> Result<JournalRequestState> {
    if !path.exists() {
        return Ok(JournalRequestState::Unseen);
    }
    let text = fs::read_to_string(path)?;
    let mut presend = 0_u64;
    let mut response = 0_u64;
    for line in text.lines().filter(|line| !line.trim().is_empty()) {
        let value = parse_strict_json(line.as_bytes())?;
        if value.get("request_digest").and_then(Value::as_str) == Some(request_digest) {
            match value.get("phase").and_then(Value::as_str) {
                Some("pre-send") => presend += 1,
                Some("response") => response += 1,
                _ => bail!("invalid owner-lane journal phase"),
            }
        }
    }
    if presend > response {
        Ok(JournalRequestState::Unknown)
    } else if response > 0 {
        Ok(JournalRequestState::Completed)
    } else {
        Ok(JournalRequestState::Unseen)
    }
}

#[cfg(test)]
fn journal_has_unknown_outcome(path: &Path, request_digest: &str) -> Result<bool> {
    Ok(journal_request_state(path, request_digest)? == JournalRequestState::Unknown)
}

fn write_operation_construction_receipt(
    plan: &ValidatedPlan,
    operation: &OwnerLaneOperation,
) -> Result<()> {
    let root = plan.evidence_root.join("operation-construction");
    fs::create_dir_all(&root)?;
    let prior_observation_digest = operation
        .observation_digest
        .as_deref()
        .unwrap_or(&plan.lifecycle_digest);
    let receipt = OperationConstructionReceipt {
        schema_version: "owner-lane-operation-construction-receipt-v1",
        run_id: &plan.authorization.run_id,
        manifest_digest: &plan.manifest_digest,
        lifecycle_digest: &plan.lifecycle_digest,
        operation_id: &operation.id,
        sequence: operation.sequence,
        request_digest: &operation.request_digest,
        prior_observation_digest,
        cycle_free: true,
        constructed_at: current_timestamp(),
    };
    write_json_sync(
        &root.join(format!("{:02}-{}.json", operation.sequence, operation.id)),
        &receipt,
    )
}

fn write_completed_prefix_receipt(
    plan: &ValidatedPlan,
    completed_operation_ids: &[String],
    last_sequence: u64,
    terminal_state: &str,
) -> Result<()> {
    let root = plan.evidence_root.join("completed-prefix");
    fs::create_dir_all(&root)?;
    let receipt = CompletedPrefixReceipt {
        schema_version: "owner-lane-completed-prefix-receipt-v1",
        run_id: &plan.authorization.run_id,
        manifest_digest: &plan.manifest_digest,
        operation_digest: &plan.manifest.operation_digest,
        completed_operation_ids,
        last_sequence,
        journal_digest: sha256_file(&plan.journal_path)?,
        terminal_state,
        recorded_at: current_timestamp(),
    };
    write_json_sync(
        &root.join(format!("{:02}-{terminal_state}.json", last_sequence)),
        &receipt,
    )
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
    let mut file = OpenOptions::new().create_new(true).write(true).open(path)?;
    file.write_all(&serde_json::to_vec_pretty(value)?)?;
    file.write_all(b"\n")?;
    file.sync_all()?;
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
            keys.sort();
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
        false_terminal: bool,
        unknown_at: Option<usize>,
        calls: usize,
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
                .any(|part| part == secret));
            if self.unknown_at == Some(self.calls) {
                return Ok(OperationResult {
                    sent: true,
                    status: None,
                    headers: BTreeMap::new(),
                    response: Vec::new(),
                });
            }
            let status = match operation.kind {
                OperationKind::CredentialRevoke => 202,
                OperationKind::TerminalIdentityProbe if self.false_terminal => 200,
                OperationKind::TerminalIdentityProbe => 401,
                OperationKind::PullRequestCreate | OperationKind::MarkerCreate => 201,
                _ => 200,
            };
            let mut headers = BTreeMap::new();
            if operation.kind == OperationKind::RepositoryProbe {
                headers.insert(
                    "x-accepted-github-permissions".to_string(),
                    "administration=write; contents=write".to_string(),
                );
            }
            let response = match operation.kind {
                OperationKind::IdentityProbe => {
                    br#"{"login":"jamesryancooper","id":800837}"#.to_vec()
                }
                OperationKind::RepositoryProbe => {
                    br#"{"full_name":"jamesryancooper/octon"}"#.to_vec()
                }
                OperationKind::PullRequestMerge => br#"{"merged":true}"#.to_vec(),
                OperationKind::MainPostRead => {
                    br#"{"object":{"sha":"c11b73b38c3825bb177b269826677b8255ab1445"}}"#.to_vec()
                }
                _ => format!("fixture-response:{}:{status}", operation.id).into_bytes(),
            };
            Ok(OperationResult {
                sent: true,
                status: Some(status),
                headers,
                response,
            })
        }
    }

    struct PlanFixture {
        root: PathBuf,
        plan: ValidatedPlan,
        secret: Secret,
    }

    fn write_value(path: &Path, value: &Value) {
        fs::write(path, serde_json::to_vec_pretty(value).unwrap()).unwrap();
    }

    fn write_executable(path: &Path, contents: &str) {
        fs::write(path, contents).unwrap();
        fs::set_permissions(path, fs::Permissions::from_mode(0o700)).unwrap();
    }

    fn operation(
        id: &str,
        sequence: u64,
        kind: &str,
        method: &str,
        url: &str,
        status: u16,
        authenticated: bool,
        mutation: bool,
    ) -> Value {
        let mut value = json!({
            "id": id,
            "sequence": sequence,
            "kind": kind,
            "method": method,
            "url": url,
            "authenticated": authenticated,
            "no_resend": true,
            "expected_statuses": [status],
            "request_digest": ""
        });
        if mutation {
            value["observation_digest"] = Value::String(sha256_prefixed(b"observed-base"));
        }
        if kind == "git_push" {
            value["refspec"] = Value::String(
                "c11b73b38c3825bb177b269826677b8255ab1445:refs/heads/rp00-candidate".to_string(),
            );
        } else if kind == "pull_request_merge" {
            value["body"] = json!({
                "sha": "c11b73b38c3825bb177b269826677b8255ab1445",
                "merge_method": "merge"
            });
        } else if mutation {
            value["body"] =
                json!({"fixture": true, "candidate": "c11b73b38c3825bb177b269826677b8255ab1445"});
        }
        let parsed: OwnerLaneOperation = serde_json::from_value(value.clone()).unwrap();
        value["request_digest"] = Value::String(operation_request_digest(&parsed).unwrap());
        value
    }

    fn fixture_plan(suffix: &str) -> PlanFixture {
        let root =
            std::env::temp_dir().join(format!("octon-owner-lane-{}-{suffix}", std::process::id()));
        let _ = fs::remove_dir_all(&root);
        fs::create_dir_all(root.join("artifacts")).unwrap();
        fs::create_dir_all(root.join(".git")).unwrap();
        let evidence_rel = ".octon/state/evidence/owner-lane-fixture";
        fs::create_dir_all(root.join(evidence_rel)).unwrap();
        let curl_path = root.join("tool-curl");
        write_executable(
            &curl_path,
            r#"#!/bin/bash
set -euo pipefail
for value in "$@"; do
  [[ "$value" != *github_pat_* ]] || exit 90
done
for name in $(compgen -e); do
  value="${!name}"
  [[ "$value" != *github_pat_* ]] || exit 91
done
url=''
while IFS= read -r line; do
  case "$line" in
    'url = "'*)
      url="${line#url = \"}"
      url="${url%\"}"
      ;;
  esac
done
status=200
body='{}'
permissions=''
case "$url" in
  https://api.github.com/user)
    if [[ -e "${0}.revoked" ]]; then
      status=401
    else
      body='{"login":"jamesryancooper","id":800837}'
    fi
    ;;
  https://api.github.com/repos/jamesryancooper/octon)
    body='{"full_name":"jamesryancooper/octon"}'
    permissions='administration=write; contents=write'
    ;;
  https://api.github.com/credentials/revoke)
    : > "${0}.revoked"
    status=202
    ;;
  */pulls/1/merge)
    body='{"merged":true}'
    ;;
  */git/ref/heads/main)
    body='{"object":{"sha":"c11b73b38c3825bb177b269826677b8255ab1445"}}'
    ;;
  */pulls|*/issues/1/comments)
    status=201
    ;;
esac
printf 'HTTP/1.1 %s Fixture\r\n' "$status"
if [[ -n "$permissions" ]]; then
  printf 'X-Accepted-GitHub-Permissions: %s\r\n' "$permissions"
fi
printf 'Content-Type: application/json\r\n\r\n%s\n%s' "$body" "$status"
"#,
        );
        let git_path = root.join("tool-git");
        write_executable(
            &git_path,
            r#"#!/bin/bash
set -euo pipefail
for value in "$@"; do
  [[ "$value" != *github_pat_* ]] || exit 90
done
for name in $(compgen -e); do
  value="${!name}"
  [[ "$value" != *github_pat_* ]] || exit 91
done
username="$("$GIT_ASKPASS" 'Username for owner lane')"
password="$("$GIT_ASKPASS" 'Password for owner lane')"
[[ "$username" == 'x-access-token' ]]
[[ "$password" == github_pat_* ]]
password=''
printf '%s\n' 'hermetic push accepted'
"#,
        );
        let askpass_path = root
            .join(".octon/framework/execution-roles/_ops/scripts/git/git-owner-lane-askpass.sh");
        fs::create_dir_all(askpass_path.parent().unwrap()).unwrap();
        let source_askpass = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .join("../../../../execution-roles/_ops/scripts/git/git-owner-lane-askpass.sh");
        fs::copy(source_askpass, &askpass_path).unwrap();
        fs::set_permissions(&askpass_path, fs::Permissions::from_mode(0o700)).unwrap();
        let mkfifo_path = [Path::new("/usr/bin/mkfifo"), Path::new("/bin/mkfifo")]
            .into_iter()
            .find(|path| path.is_file())
            .expect("system mkfifo is required for owner-lane tests");
        let mut tools = Map::new();
        for (id, path) in [
            ("curl", curl_path.as_path()),
            ("git", git_path.as_path()),
            ("mkfifo", mkfifo_path),
            ("askpass", askpass_path.as_path()),
        ] {
            let canonical = fs::canonicalize(&path).unwrap();
            tools.insert(
                id.to_string(),
                json!({
                    "canonical_path": canonical,
                    "sha256": sha256_file(&canonical).unwrap()
                }),
            );
        }
        let operations = vec![
            operation(
                "identity",
                1,
                "identity_probe",
                "GET",
                "https://api.github.com/user",
                200,
                true,
                false,
            ),
            operation(
                "repository",
                2,
                "repository_probe",
                "GET",
                "https://api.github.com/repos/jamesryancooper/octon",
                200,
                true,
                false,
            ),
            operation(
                "disable-workflow",
                3,
                "workflow_disable",
                "PUT",
                "https://api.github.com/repos/jamesryancooper/octon/actions/workflows/1/disable",
                200,
                true,
                true,
            ),
            operation(
                "cancel-run",
                4,
                "workflow_run_cancel",
                "POST",
                "https://api.github.com/repos/jamesryancooper/octon/actions/runs/1/cancel",
                200,
                true,
                true,
            ),
            operation(
                "push",
                5,
                "git_push",
                "PUSH",
                "https://github.com/jamesryancooper/octon.git",
                200,
                true,
                true,
            ),
            operation(
                "create-pr",
                6,
                "pull_request_create",
                "POST",
                "https://api.github.com/repos/jamesryancooper/octon/pulls",
                201,
                true,
                true,
            ),
            operation(
                "create-marker",
                7,
                "marker_create",
                "POST",
                "https://api.github.com/repos/jamesryancooper/octon/issues/1/comments",
                201,
                true,
                true,
            ),
            operation(
                "update-ruleset",
                8,
                "ruleset_update",
                "PUT",
                "https://api.github.com/repos/jamesryancooper/octon/rulesets/1",
                200,
                true,
                true,
            ),
            operation(
                "trigger-check",
                9,
                "check_trigger",
                "POST",
                "https://api.github.com/repos/jamesryancooper/octon/dispatches",
                200,
                true,
                true,
            ),
            operation(
                "merge",
                10,
                "pull_request_merge",
                "PUT",
                "https://api.github.com/repos/jamesryancooper/octon/pulls/1/merge",
                200,
                true,
                true,
            ),
            operation(
                "main-post-read",
                11,
                "main_post_read",
                "GET",
                "https://api.github.com/repos/jamesryancooper/octon/git/ref/heads/main",
                200,
                true,
                false,
            ),
            operation(
                "revoke",
                12,
                "credential_revoke",
                "POST",
                "https://api.github.com/credentials/revoke",
                202,
                false,
                false,
            ),
            operation(
                "terminal",
                13,
                "terminal_identity_probe",
                "GET",
                "https://api.github.com/user",
                401,
                true,
                false,
            ),
        ];
        let operation_digest_values = operations
            .iter()
            .map(|operation| {
                let parsed: OwnerLaneOperation = serde_json::from_value(operation.clone()).unwrap();
                operation_digest_value(&parsed).unwrap()
            })
            .collect();
        let operation_digest = digest_value(&Value::Array(operation_digest_values)).unwrap();
        let run_id = "owner-lane-fixture-run";
        let principal = json!({"login": "jamesryancooper", "id": 800837});
        let accepted_review_digest = sha256_prefixed(b"accepted-review");
        let attestation = json!({
            "schema_version": "owner-lane-attestation-v1",
            "run_id": run_id,
            "repository": REPOSITORY,
            "base_sha": "40fe9d0b4d1f41c69c4d2e3585c772c96a324023",
            "candidate_sha": "c11b73b38c3825bb177b269826677b8255ab1445",
            "candidate_tree": "9c6002867ea0f5ae7e76d4d90f1edeabeb0d4ea9",
            "principal": principal,
            "accepted_review_digest": accepted_review_digest,
            "attested": true,
            "recorded_at": "2026-07-17T00:00:00Z"
        });
        let attestation_digest = digest_value(&attestation).unwrap();
        let manifest = json!({
            "schema_version": "owner-lane-operation-manifest-v1",
            "run_id": run_id,
            "repository": REPOSITORY,
            "base_sha": "40fe9d0b4d1f41c69c4d2e3585c772c96a324023",
            "head_sha": "c11b73b38c3825bb177b269826677b8255ab1445",
            "candidate_tree": "9c6002867ea0f5ae7e76d4d90f1edeabeb0d4ea9",
            "attestation_digest": attestation_digest,
            "operation_digest": operation_digest,
            "one_attempt_lock": "locked",
            "tools": Value::Object(tools),
            "operations": operations
        });
        let manifest_digest = digest_value(&manifest).unwrap();
        let authorization = json!({
            "schema_version": "owner-lane-credential-admission-authorization-v1",
            "authorization_id": "fixture-authorization",
            "accepted_review_digest": accepted_review_digest,
            "run_id": run_id,
            "repository": REPOSITORY,
            "base_sha": "40fe9d0b4d1f41c69c4d2e3585c772c96a324023",
            "candidate_sha": "c11b73b38c3825bb177b269826677b8255ab1445",
            "candidate_tree": "9c6002867ea0f5ae7e76d4d90f1edeabeb0d4ea9",
            "principal": principal,
            "credential_tuple": {
                "credential_class": "fine-grained-personal-access-token",
                "issuer": "github.com",
                "capture_channel": "inherited-fd",
                "api_version": API_VERSION
            },
            "manifest_digest": manifest_digest,
            "operation_digest": operation_digest,
            "evidence_root": evidence_rel,
            "one_attempt_lock": "locked",
            "authorized_at": "2026-07-17T00:00:00Z"
        });
        let authorization_digest = digest_value(&authorization).unwrap();
        let secret = Secret(b"github_pat_fixture_owner_lane_secret".to_vec());
        let nonce = "0123456789abcdef0123456789abcdef";
        let handle_digest =
            digest_domain_parts(HANDLE_DOMAIN, &[nonce.as_bytes(), secret.expose()]);
        let header = [b"Authorization: Bearer ".as_slice(), secret.expose()].concat();
        let mut revoke_body = revocation_body(secret.expose());
        let issuance = json!({
            "schema_version": "owner-lane-credential-issuance-outcome-receipt-v1",
            "run_id": run_id,
            "authorization_digest": authorization_digest,
            "issued": true,
            "issuance_attempts": 1,
            "issuer": "github.com",
            "principal": principal,
            "nonce_salted_handle_digest": handle_digest,
            "header_digest": digest_domain_parts(HEADER_DOMAIN, &[&header]),
            "revocation_body_digest": digest_domain_parts(REVOCATION_DOMAIN, &[&revoke_body]),
            "no_secret_retained": true,
            "recorded_at": "2026-07-17T00:00:00Z"
        });
        revoke_body.fill(0);
        let issuance_digest = digest_value(&issuance).unwrap();
        let lifecycle = json!({
            "schema_version": "owner-lane-credential-lifecycle-envelope-v1",
            "run_id": run_id,
            "authorization_digest": authorization_digest,
            "issuance_outcome_digest": issuance_digest,
            "manifest_digest": manifest_digest,
            "attestation_digest": attestation_digest,
            "credential_handle_nonce": nonce,
            "credential_handle_digest": handle_digest,
            "identity_probe_budget": 1,
            "repository_probe_budget": 1,
            "revocation_budget": 1,
            "retirement_probe_budget": 1,
            "revocation_wait_seconds": 0,
            "actual_reached_phase": "admitted",
            "evidence_root": evidence_rel
        });
        let lifecycle_digest = digest_value(&lifecycle).unwrap();
        let admission = json!({
            "schema_version": "owner-lane-credential-admission-receipt-v1",
            "run_id": run_id,
            "lifecycle_digest": lifecycle_digest,
            "identity_status": 200,
            "repository_status": 200,
            "login": "jamesryancooper",
            "id": 800837,
            "api_version": API_VERSION,
            "accepted_permissions": {"contents": "write", "administration": "write"},
            "pagination_complete": true,
            "admitted": true,
            "prior_authenticated_200": true,
            "recorded_at": "2026-07-17T00:00:00Z"
        });
        let artifacts = root.join("artifacts");
        let paths = ArtifactPaths {
            authorization: artifacts.join("authorization.json"),
            issuance_outcome: artifacts.join("issuance.json"),
            lifecycle_envelope: artifacts.join("lifecycle.json"),
            admission_receipt: artifacts.join("admission.json"),
            manifest: artifacts.join("manifest.json"),
            attestation: artifacts.join("attestation.json"),
            evidence_root: root.join(evidence_rel),
        };
        for (path, value) in [
            (&paths.authorization, &authorization),
            (&paths.issuance_outcome, &issuance),
            (&paths.lifecycle_envelope, &lifecycle),
            (&paths.admission_receipt, &admission),
            (&paths.manifest, &manifest),
            (&paths.attestation, &attestation),
        ] {
            write_value(path, value);
        }
        let plan = validate_plan(&root, &paths).unwrap();
        verify_secret_binding(&plan, &secret).unwrap();
        PlanFixture { root, plan, secret }
    }

    #[test]
    fn owner_lane_rejects_duplicate_keys_floats_and_large_integers() {
        assert!(parse_strict_json(br#"{"a":1,"a":2}"#).is_err());
        assert!(parse_strict_json(br#"{"a":1.0}"#).is_err());
        assert!(parse_strict_json(br#"{"a":9007199254740992}"#).is_err());
    }

    #[test]
    fn owner_lane_canonicalization_sorts_keys() {
        let value = parse_strict_json(br#"{"z":[3,2,1],"a":{"b":true,"a":null}}"#).unwrap();
        assert_eq!(
            canonical_json(&value).unwrap(),
            br#"{"a":{"a":null,"b":true},"z":[3,2,1]}"#
        );
    }

    #[test]
    fn owner_lane_unknown_outcome_blocks_resend() {
        let root = std::env::temp_dir().join(format!("octon-owner-lane-{}", std::process::id()));
        let _ = fs::remove_dir_all(&root);
        fs::create_dir_all(&root).unwrap();
        let journal = root.join("events.ndjson");
        append_journal(
            &journal,
            JournalEvent {
                schema_version: "owner-lane-journal-event-v1",
                phase: "pre-send",
                operation_id: "merge",
                sequence: 1,
                request_digest: "sha256:abc",
                status: None,
                response_digest: None,
            },
        )
        .unwrap();
        assert!(journal_has_unknown_outcome(&journal, "sha256:abc").unwrap());
        let _ = fs::remove_dir_all(root);
    }

    #[test]
    fn owner_lane_allowlist_denies_cross_repository_url() {
        let operation = OwnerLaneOperation {
            id: "escape".to_string(),
            sequence: 1,
            kind: OperationKind::RulesetUpdate,
            method: "PUT".to_string(),
            url: "https://api.github.com/repos/other/repo/rulesets/1".to_string(),
            authenticated: true,
            no_resend: true,
            expected_statuses: vec![200],
            body: None,
            refspec: None,
            observation_digest: Some("sha256:abc".to_string()),
            request_digest: "sha256:unused".to_string(),
        };
        assert!(validate_operation_allowlist(&operation).is_err());
    }

    #[test]
    fn owner_lane_hermetic_full_protocol_retires_secret() {
        let mut fixture = fixture_plan("full");
        let mut runner = FixtureRunner {
            false_terminal: false,
            unknown_at: None,
            calls: 0,
        };
        execute_validated_plan(&fixture.plan, &mut fixture.secret, &mut runner).unwrap();
        assert_eq!(runner.calls, 13);
        let receipt = read_strict_json(&fixture.plan.retirement_path).unwrap();
        assert_eq!(receipt["revocation_status"], 202);
        assert_eq!(receipt["terminal_identity_status"], 401);
        assert_eq!(receipt["secret_census_empty"], true);
        assert!(fixture.secret.expose().is_empty());
        assert_eq!(
            fs::read_dir(fixture.plan.evidence_root.join("operation-construction"))
                .unwrap()
                .count(),
            13
        );
        assert_eq!(
            fs::read_dir(fixture.plan.evidence_root.join("completed-prefix"))
                .unwrap()
                .count(),
            13
        );
        let _ = fs::remove_dir_all(fixture.root);
    }

    #[test]
    fn owner_lane_hermetic_process_transport_keeps_secret_off_argv_env_and_disk() {
        let mut fixture = fixture_plan("process-transport");
        let mut runner = SystemRunner {
            repo_root: &fixture.root,
            fifo_active: false,
        };
        execute_validated_plan(&fixture.plan, &mut fixture.secret, &mut runner).unwrap();
        assert!(runner.fifo_removed());
        assert!(fixture.root.join("tool-curl.revoked").is_file());
        assert!(fixture.secret.expose().is_empty());
        let secret = b"github_pat_fixture_owner_lane_secret";
        for entry in WalkDir::new(&fixture.root).follow_links(false) {
            let entry = entry.unwrap();
            if entry.file_type().is_file() {
                assert!(!fs::read(entry.path())
                    .unwrap()
                    .windows(secret.len())
                    .any(|window| window == secret));
            }
        }
        assert!(fixture.secret.expose().is_empty());
        let _ = fs::remove_dir_all(fixture.root);
    }

    #[test]
    fn owner_lane_unknown_send_outcome_is_never_replayed() {
        let mut fixture = fixture_plan("unknown");
        let mut first = FixtureRunner {
            false_terminal: false,
            unknown_at: Some(3),
            calls: 0,
        };
        let error = execute_validated_plan(&fixture.plan, &mut fixture.secret, &mut first)
            .expect_err("unknown outcome must stop");
        assert!(error.to_string().contains("outcome-unknown"));
        assert_eq!(first.calls, 5);
        assert_eq!(
            journal_request_state(
                &fixture.plan.journal_path,
                &fixture.plan.manifest.operations[2].request_digest
            )
            .unwrap(),
            JournalRequestState::Unknown
        );
        fixture.secret = Secret(b"github_pat_fixture_owner_lane_secret".to_vec());
        let mut retry = FixtureRunner {
            false_terminal: false,
            unknown_at: None,
            calls: 0,
        };
        let retry_error = execute_validated_plan(&fixture.plan, &mut fixture.secret, &mut retry)
            .expect_err("unknown request must not be resent");
        assert!(retry_error.to_string().contains("replay denied"));
        assert_eq!(retry.calls, 0);
        let _ = fs::remove_dir_all(fixture.root);
    }

    #[test]
    fn owner_lane_false_terminal_identity_response_is_denied() {
        let mut fixture = fixture_plan("false-terminal");
        let mut runner = FixtureRunner {
            false_terminal: true,
            unknown_at: None,
            calls: 0,
        };
        let error = execute_validated_plan(&fixture.plan, &mut fixture.secret, &mut runner)
            .expect_err("same-token 200 is not retirement");
        assert!(error.to_string().contains("unexpected status 200"));
        assert!(!fixture.plan.retirement_path.exists());
        let _ = fs::remove_dir_all(fixture.root);
    }

    #[test]
    fn owner_lane_tool_drift_after_validation_denies_before_send() {
        let mut fixture = fixture_plan("tool-drift");
        let curl = PathBuf::from(&fixture.plan.manifest.tools["curl"].canonical_path);
        fs::write(curl, b"substituted\n").unwrap();
        let mut runner = FixtureRunner {
            false_terminal: false,
            unknown_at: None,
            calls: 0,
        };
        let error = execute_validated_plan(&fixture.plan, &mut fixture.secret, &mut runner)
            .expect_err("tool substitution must deny");
        assert!(error.to_string().contains("digest drift"));
        assert_eq!(runner.calls, 0);
        let _ = fs::remove_dir_all(fixture.root);
    }
}
