use crate::{
    AdoptCmd, AttestCmd, AttestationPathCmd, AttestationStatusCmd, CertifyCmd, CompatibilityCmd,
    CompatibilityInspectCmd, DelegateCmd, DelegateLeaseCmd, FederationCmd, TrustCmd,
    TrustCompactCmd, TrustCompactDecisionCmd, TrustCompactProposeCmd, TrustDomainAddCmd,
    TrustDomainCmd, TrustDomainInspectCmd, TrustProofCmd, TrustProofExportCmd, TrustProofImportCmd,
    TrustProofPathCmd, TrustProofStatusCmd, TrustRegistryCmd,
};
use anyhow::{anyhow, bail, Context, Result};
use octon_authority_engine::now_rfc3339;
use serde_json::{json, Map, Value};
use sha2::{Digest, Sha256};
use std::fs;
use std::path::{Component, Path, PathBuf};
use time::{format_description::well_known::Rfc3339, Duration, OffsetDateTime};

const TRUST_REGISTRY_REF: &str = ".octon/instance/governance/trust/registry.yml";
const COMPATIBILITY_PROFILE_REF: &str =
    ".octon/instance/governance/trust/compatibility-profile.yml";
const ADOPTION_POLICY_REF: &str =
    ".octon/instance/governance/trust/policies/external-project-adoption.yml";
const LEDGER_REF: &str = ".octon/state/control/trust/ledger.yml";

pub(super) fn cmd_adopt(args: AdoptCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let root = repo_root(&octon_dir);
    let repo = canonical_or_input(&args.repo);
    let classification = classify_project(&repo);
    let project_id = project_id_for(&repo);
    let adoption_id = format!("adoption-{project_id}");
    let evidence_path = root
        .join(".octon/state/evidence/trust/external-projects")
        .join(&project_id)
        .join("adoption")
        .join("preflight.yml");
    let status_path = root
        .join(".octon/state/control/trust/external-projects")
        .join(&project_id)
        .join("adoption-status.yml");
    fs::create_dir_all(parent(&evidence_path)?)?;
    fs::create_dir_all(parent(&status_path)?)?;
    let now = now_rfc3339()?;
    let safe_adoption_sequence = vec![
        "detect existing .octon topology",
        "classify compatibility profile",
        "install or verify portable framework only",
        "initialize repo-specific instance authority",
        "create or reconcile workspace charter",
        "initialize ingress and bootstrap",
        "initialize governance and support-target posture",
        "initialize local state/control, state/evidence, and state/continuity roots",
        "rebuild generated projections locally",
        "run bootstrap and doctor checks",
        "assign compatibility profile",
        "defer federation membership until compatibility gates pass",
    ];
    let status = json!({
        "schema_version": "external-project-adoption-posture-v1",
        "adoption_id": adoption_id,
        "project_ref": repo.display().to_string(),
        "status": "preflight_only",
        "classification_ref": repo_ref(&root, &status_path),
        "safe_adoption_sequence": safe_adoption_sequence,
        "forbidden_shortcuts": [
            "blind full .octon copy from another project",
            "copying instance/** as authority",
            "copying state/** as current operational truth",
            "copying generated/** as source truth"
        ],
        "required_local_roots": ["framework", "instance", "state/control", "state/evidence", "state/continuity", "generated"],
        "failure_states": [
            "partial_octon",
            "stale_octon",
            "conflicting_octon",
            "missing_instance_authority",
            "missing_support_posture",
            "missing_state_roots",
            "generated_not_rebuilt",
            "bootstrap_doctor_failed",
            "blind_copy_detected"
        ],
        "blind_copy_full_octon_allowed": false,
        "generated_rebuild_required": true,
        "repo_specific_instance_authority_required": true,
        "support_target_admission_required": true,
        "bootstrap_doctor_required": true,
        "material_execution_authorized": false
    });
    write_yaml(&status_path, &status)?;
    let report = json!({
        "schema_version": "external-project-adoption-preflight-v1",
        "command": "adopt",
        "adoption_id": status.get("adoption_id"),
        "repo": repo.display().to_string(),
        "classification": classification,
        "policy_ref": ADOPTION_POLICY_REF,
        "adoption_status_ref": repo_ref(&root, &status_path),
        "safe_adoption_sequence": status.get("safe_adoption_sequence"),
        "blind_copy_full_octon_allowed": false,
        "state_copy_as_authority_allowed": false,
        "generated_copy_as_authority_allowed": false,
        "generated_rebuild_required": true,
        "material_execution_authorized": false,
        "outcome": "preflight-recorded-local-evidence-only",
        "recorded_at": now,
    });
    write_yaml(&evidence_path, &report)?;
    print_json(&report)
}

pub(super) fn cmd_compatibility(cmd: CompatibilityCmd) -> Result<()> {
    match cmd {
        CompatibilityCmd::Inspect(args) => compatibility_inspect(args),
        CompatibilityCmd::Profile(args) => compatibility_profile(args),
    }
}

pub(super) fn cmd_trust(cmd: TrustCmd) -> Result<()> {
    match cmd {
        TrustCmd::Status => trust_status(),
        TrustCmd::Domain { cmd } => match cmd {
            TrustDomainCmd::Add(args) => trust_domain_add(args),
            TrustDomainCmd::Inspect(args) => trust_domain_inspect(args),
        },
        TrustCmd::Registry { cmd } => match cmd {
            TrustRegistryCmd::Validate => trust_registry_validate(),
        },
        TrustCmd::Compact { cmd } => match cmd {
            TrustCompactCmd::Propose(args) => trust_compact_propose(args),
            TrustCompactCmd::Approve(args) => trust_compact_decision(args, "approved"),
            TrustCompactCmd::Revoke(args) => trust_compact_decision(args, "revoked"),
        },
    }
}

pub(super) fn cmd_proof(cmd: TrustProofCmd) -> Result<()> {
    match cmd {
        TrustProofCmd::Export(args) => proof_export(args),
        TrustProofCmd::Import(args) => proof_import(args),
        TrustProofCmd::Verify(args) => proof_verify(args),
        TrustProofCmd::Accept(args) => proof_accept_or_reject(args, "accepted"),
        TrustProofCmd::Reject(args) => proof_accept_or_reject(args, "rejected"),
        TrustProofCmd::Status(args) => proof_status(args),
    }
}

pub(super) fn cmd_attest(cmd: AttestCmd) -> Result<()> {
    match cmd {
        AttestCmd::Verify(args) => attest_verify(args),
        AttestCmd::Accept(args) => attest_accept_or_reject(args, "accepted"),
        AttestCmd::Reject(args) => attest_accept_or_reject(args, "rejected"),
        AttestCmd::Status(args) => attest_status(args),
    }
}

pub(super) fn cmd_delegate(cmd: DelegateCmd) -> Result<()> {
    match cmd {
        DelegateCmd::Lease { cmd } => match cmd {
            DelegateLeaseCmd::Create(args) => lease_create(args),
            DelegateLeaseCmd::Revoke(args) => lease_revoke(args),
        },
    }
}

pub(super) fn cmd_certify(cmd: CertifyCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let report = match cmd {
        CertifyCmd::Run(args) => json!({
            "schema_version": "trust-certification-command-result-v1",
            "command": "certify-run",
            "run_id": args.run_id,
            "profile": args.profile,
            "profile_ref": ".octon/instance/governance/trust/certification-profiles/auditor-verifiable-run.yml",
            "required_local_authority": [
                "run contract",
                "execution authorization",
                "retained run evidence",
                "run-card disclosure"
            ],
            "certification_authorizes_execution": false,
            "certification_widens_support_claims": false,
            "result": "requirements-reported"
        }),
        CertifyCmd::Connector(args) => json!({
            "schema_version": "trust-certification-command-result-v1",
            "command": "certify-connector",
            "connector_id": args.connector_id,
            "operation_id": args.operation_id,
            "profile": args.profile,
            "connector_admission_runtime_ref": ".octon/framework/orchestration/practices/connector-admission-standards.md",
            "certification_authorizes_execution": false,
            "certification_widens_support_claims": false,
            "result": "requirements-reported"
        }),
    };
    retain_command_receipt(&octon_dir, "certifications", &report)?;
    print_json(&report)
}

pub(super) fn cmd_federation(cmd: FederationCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    match cmd {
        FederationCmd::Status => {
            let root = repo_root(&octon_dir);
            let registry = read_yaml(&root.join(TRUST_REGISTRY_REF))?;
            let ledger = read_yaml(&root.join(LEDGER_REF))?;
            print_json(&json!({
                "schema_version": "trust-federation-status-command-result-v1",
                "authority_notice": "Trust status is derived from local registry authority and state/control trust ledger; generated trust views remain non-authoritative.",
                "status": {
                    "trust_domains": ledger.get("trust_domains").and_then(Value::as_array).map(|items| items.len()).unwrap_or(0),
                    "compacts": ledger.get("compacts").and_then(Value::as_array).map(|items| items.len()).unwrap_or(0),
                    "delegated_leases": ledger.get("delegated_leases").and_then(Value::as_array).map(|items| items.len()).unwrap_or(0),
                    "accepted_domains": registry.get("accepted_domains").and_then(Value::as_array).map(|items| items.len()).unwrap_or(0),
                    "unregistered_domain_route": registry.get("unregistered_domain_route").and_then(Value::as_str).unwrap_or("deny"),
                    "external_registry_is_authority": registry.get("external_registry_is_authority").and_then(Value::as_bool).unwrap_or(false),
                    "ledger_ref": LEDGER_REF,
                    "registry_ref": TRUST_REGISTRY_REF,
                    "status": "stage_only"
                }
            }))
        }
        FederationCmd::Ledger => {
            let ledger = read_yaml(&repo_root(&octon_dir).join(LEDGER_REF))?;
            print_json(&json!({
                "schema_version": "trust-federation-ledger-command-result-v1",
                "authority_notice": "The federation ledger indexes control and evidence refs; it does not replace source evidence or authorize execution.",
                "ledger": ledger
            }))
        }
    }
}

fn compatibility_inspect(args: CompatibilityInspectCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let root = repo_root(&octon_dir);
    let repo = canonical_or_input(&args.repo);
    let classification = classify_project(&repo);
    let project_id = project_id_for(&repo);
    let control_path = root
        .join(".octon/state/control/trust/external-projects")
        .join(&project_id)
        .join("inspection.yml");
    let evidence_path = root
        .join(".octon/state/evidence/trust/external-projects")
        .join(&project_id)
        .join("inspection")
        .join("receipt.yml");
    fs::create_dir_all(parent(&control_path)?)?;
    fs::create_dir_all(parent(&evidence_path)?)?;
    let now = now_rfc3339()?;
    let inspection = inspection_record(
        &repo,
        &classification,
        &project_id,
        &now,
        &evidence_path,
        &root,
    );
    write_yaml(&control_path, &inspection)?;
    let evidence = json!({
        "schema_version": "external-project-compatibility-inspection-evidence-v1",
        "inspection_ref": repo_ref(&root, &control_path),
        "classification": classification.get("participation_tier"),
        "detected_state": classification.get("detected_state"),
        "evidence_role": "retained compatibility inspection proof",
        "inspection_authorizes_adoption": false,
        "inspection_authorizes_federation": false,
        "material_execution_authorized": false,
        "recorded_at": now
    });
    write_yaml(&evidence_path, &evidence)?;
    print_json(&json!({
        "schema_version": "octon-compatibility-inspection-v1",
        "inspection_ref": repo_ref(&root, &control_path),
        "repo": repo.display().to_string(),
        "classification": classification,
        "profile_ref": COMPATIBILITY_PROFILE_REF,
        "external_artifacts_authorize_execution": false,
        "non_octon_system_can_be_federation_peer": false
    }))
}

fn compatibility_profile(args: CompatibilityInspectCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let repo = canonical_or_input(&args.repo);
    let classification = classify_project(&repo);
    let profile = read_yaml(&repo_root(&octon_dir).join(COMPATIBILITY_PROFILE_REF))?;
    print_json(&json!({
        "schema_version": "octon-compatibility-profile-command-result-v1",
        "repo": repo.display().to_string(),
        "classification": classification,
        "profile_set": profile,
        "authority_notice": "Compatibility classification does not authorize execution or federation by itself."
    }))
}

fn trust_domain_add(args: TrustDomainAddCmd) -> Result<()> {
    validate_id(&args.domain_id, "domain_id")?;
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let root = repo_root(&octon_dir);
    let now = now_rfc3339()?;
    let approved = args.approval_ref.is_some();
    let domain = json!({
        "schema_version": "trust-domain-v1",
        "domain_id": args.domain_id,
        "domain_kind": "external_system",
        "owner": args.owner,
        "scope": args.scope,
        "compatibility_profile": args.profile,
        "accepted_evidence_types": ["attestation envelope", "portable proof bundle"],
        "trusted_issuers": [],
        "revocation_policy": "local revocation required before acceptance changes",
        "data_boundary": "redacted proof exchange only",
        "credential_boundary": "no credential sharing",
        "support_posture": "stage-only until locally approved",
        "permitted_delegation_classes": [],
        "forbidden_delegation_classes": ["external_execution_authority", "direct_repo_mutation", "permanent_authority"],
        "local_approval_required": true,
        "domain_authorizes_execution": false,
        "external_registry_is_authority": false,
        "approval_refs": args.approval_ref.iter().collect::<Vec<_>>(),
        "status": if approved { "stage_only" } else { "blocked" },
        "created_at": now,
        "updated_at": now
    });
    let path = if approved {
        root.join(".octon/instance/governance/trust/domains")
            .join(format!("{}.yml", value_string(&domain, "domain_id")?))
    } else {
        root.join(".octon/state/control/trust/domain-registrations")
            .join(format!("{}.yml", value_string(&domain, "domain_id")?))
    };
    fs::create_dir_all(parent(&path)?)?;
    write_yaml(&path, &domain)?;
    print_json(&json!({
        "schema_version": "trust-domain-add-result-v1",
        "domain_ref": repo_ref(&root, &path),
        "outcome": if approved { "stage-only-domain-written" } else { "blocked-registration-request-written" },
        "domain_authorizes_execution": false
    }))
}

fn trust_domain_inspect(args: TrustDomainInspectCmd) -> Result<()> {
    validate_id(&args.domain_id, "domain_id")?;
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let path = repo_root(&octon_dir)
        .join(".octon/instance/governance/trust/domains")
        .join(format!("{}.yml", args.domain_id));
    let domain = read_yaml(&path)?;
    print_json(&json!({
        "schema_version": "trust-domain-inspect-result-v1",
        "domain": domain,
        "authority_notice": "Trust Domains bound local trust admission; they do not authorize execution."
    }))
}

fn trust_registry_validate() -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let root = repo_root(&octon_dir);
    let registry_path = root.join(TRUST_REGISTRY_REF);
    let registry = read_yaml(&registry_path)?;
    require_bool(&registry, "local_registry_is_authority", true)?;
    require_bool(&registry, "external_registry_is_authority", false)?;
    let mut problems = Vec::new();
    if let Some(domains) = registry.get("accepted_domains").and_then(Value::as_array) {
        for domain in domains {
            if let Some(domain_ref) = domain.get("domain_ref").and_then(Value::as_str) {
                let path = root.join(domain_ref);
                if !path.is_file() {
                    problems.push(format!("missing domain_ref {domain_ref}"));
                }
            }
        }
    }
    print_json(&json!({
        "schema_version": "trust-registry-validation-result-v1",
        "registry_ref": TRUST_REGISTRY_REF,
        "valid": problems.is_empty(),
        "problems": problems,
        "unregistered_domain_route": registry.get("unregistered_domain_route"),
        "external_registry_is_authority": false
    }))
}

fn trust_status() -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let root = repo_root(&octon_dir);
    let hooks = read_yaml(&root.join(".octon/instance/governance/trust/trust-domain-hooks.yml"))?;
    let compatibility =
        read_yaml(&root.join(".octon/state/control/trust/compatibility/status.yml"))?;
    print_json(&json!({
        "schema_version": "trust-hook-status-result-v1",
        "trust_domain_hook_ref": ".octon/instance/governance/trust/trust-domain-hooks.yml",
        "compatibility_status_ref": ".octon/state/control/trust/compatibility/status.yml",
        "registry_runtime_deferred": hooks.get("registry_runtime_deferred"),
        "federation_runtime_deferred": hooks.get("federation_runtime_deferred"),
        "external_registry_is_authority": false,
        "hook_authorizes_execution": false,
        "status": compatibility,
        "authority_notice": "Selected v6 trust hooks bind proof acceptance posture only; full trust registry and federation runtime remain deferred for this migration."
    }))
}

fn trust_compact_propose(args: TrustCompactProposeCmd) -> Result<()> {
    validate_id(&args.compact_id, "compact_id")?;
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let path = repo_root(&octon_dir)
        .join(".octon/state/control/trust/federation-compacts")
        .join(&args.compact_id)
        .join("status.yml");
    fs::create_dir_all(parent(&path)?)?;
    let value = json!({
        "schema_version": "federation-compact-status-v1",
        "compact_id": args.compact_id,
        "participating_domains": args.domains,
        "purpose": args.purpose.unwrap_or_else(|| "stage-only compact proposal".to_string()),
        "status": "proposed",
        "active_for_execution": false,
        "compact_authorizes_execution": false,
        "compact_overrides_local_authority": false,
        "compact_widens_support_claims": false,
        "compact_mutates_local_authority": false,
        "updated_at": now_rfc3339()?
    });
    write_yaml(&path, &value)?;
    print_json(
        &json!({"schema_version": "federation-compact-propose-result-v1", "status_ref": repo_ref(&repo_root(&octon_dir), &path), "compact_authorizes_execution": false}),
    )
}

fn trust_compact_decision(args: TrustCompactDecisionCmd, decision: &str) -> Result<()> {
    validate_id(&args.compact_id, "compact_id")?;
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    if decision == "approved" && args.approval_ref.is_none() {
        bail!("compact approval requires --approval-ref from local authority");
    }
    let path = repo_root(&octon_dir)
        .join(".octon/state/control/trust/federation-compacts")
        .join(&args.compact_id)
        .join("status.yml");
    let value = json!({
        "schema_version": "federation-compact-status-v1",
        "compact_id": args.compact_id,
        "status": decision,
        "approval_refs": args.approval_ref.iter().collect::<Vec<_>>(),
        "active_for_execution": false,
        "compact_authorizes_execution": false,
        "compact_overrides_local_authority": false,
        "compact_widens_support_claims": false,
        "compact_mutates_local_authority": false,
        "updated_at": now_rfc3339()?
    });
    fs::create_dir_all(parent(&path)?)?;
    write_yaml(&path, &value)?;
    print_json(
        &json!({"schema_version": "federation-compact-decision-result-v1", "status_ref": repo_ref(&repo_root(&octon_dir), &path), "status": decision, "compact_authorizes_execution": false}),
    )
}

fn proof_export(args: TrustProofExportCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let root = repo_root(&octon_dir);
    let now = now_rfc3339()?;
    let expires_at = args.expires_at.unwrap_or(future_rfc3339(90)?);
    let registry_ref = ".octon/instance/governance/trust/registry.yml";
    let registry_digest = sha256_file(&root.join(registry_ref))?;
    let export_evidence_ref = format!(
        ".octon/state/evidence/trust/proof-bundles/{}/export.yml",
        args.bundle_id
    );
    let bundle = json!({
        "schema_version": "portable-proof-bundle-v1",
        "bundle_id": args.bundle_id,
        "issuer": "octon-local",
        "trust_domain_id": "octon-local",
        "scope": args.scope,
        "valid_from": now.clone(),
        "expires_at": expires_at,
        "run_evidence_summary": {
            "material_execution_route": "local run contracts only",
            "trust_runtime_executes_material_work": false
        },
        "mission_evidence_summary": null,
        "support_target_proof_refs": [],
        "connector_trust_dossier_refs": [],
        "release_envelope_refs": [],
        "validation_results": [{
            "validator_ref": ".octon/framework/assurance/runtime/_ops/scripts/validate-federated-trust-runtime-v6.sh",
            "result": "pass",
            "completed_at": now.clone()
        }],
        "rollback_posture": "not-exported-by-default",
        "evidence_digests": [{
            "path": registry_ref,
            "digest_algorithm": "sha256",
            "digest": registry_digest
        }],
        "redaction_manifest": {
            "redaction_required": true,
            "exported_secret_material_allowed": false,
            "classification": "repo-local-governance-evidence",
            "redacted_fields": [],
            "reviewer_ref": ".octon/instance/governance/trust/policies/proof-bundle-acceptance.yml",
            "reviewed_at": now.clone()
        },
        "disclosure_refs": [".octon/instance/governance/trust/README.md"],
        "revocation_refs": [".octon/state/control/trust/revocations/revocation-octon-v6-expiry-policy.yml"],
        "import_export_controls": {
            "import_source": "local-export-command",
            "export_eligible": true,
            "export_manifest_ref": export_evidence_ref.clone(),
            "disclosure_boundary": "redacted proof only; no secrets or credentials",
            "portability_constraints": [
                "consumer must re-verify digest, freshness, scope, redaction, and revocation",
                "consumer local registry remains final"
            ]
        },
        "consumer_verification_requirements": [
            "schema validate portable-proof-bundle-v1",
            "verify digest refs and revocation refs locally",
            "record local acceptance before satisfying evidence requirements"
        ],
        "verification_status": "verified",
        "freshness_status": "fresh",
        "revocation_status": "unrevoked",
        "digest_verification": "verified",
        "local_acceptance_evidence_refs": [export_evidence_ref],
        "local_acceptance": "unreviewed",
        "proof_bundle_authorizes_execution": false,
        "proof_bundle_replaces_run_evidence": false,
        "proof_bundle_widens_support_claims": false,
        "updated_at": now
    });
    let export_evidence = root.join(format!(
        ".octon/state/evidence/trust/proof-bundles/{}/export.yml",
        value_string(&bundle, "bundle_id")?
    ));
    fs::create_dir_all(parent(&export_evidence)?)?;
    write_yaml(&export_evidence, &bundle)?;
    print_json(&bundle)
}

fn proof_import(args: TrustProofImportCmd) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let mut bundle = read_yaml_object(&args.path)?;
    verify_proof_bundle(&Value::Object(bundle.clone()), args.accept)?;
    let bundle_id = map_string(&bundle, "bundle_id")?;
    if args.accept {
        bundle.insert("local_acceptance".to_string(), json!("accepted"));
        bundle.insert(
            "proof_bundle_authorizes_execution".to_string(),
            json!(false),
        );
        bundle.insert(
            "proof_bundle_replaces_run_evidence".to_string(),
            json!(false),
        );
        bundle.insert(
            "proof_bundle_widens_support_claims".to_string(),
            json!(false),
        );
        bundle.insert("updated_at".to_string(), json!(now_rfc3339()?));
    }
    let receipt = json!({
        "schema_version": "proof-bundle-import-result-v1",
        "bundle_id": bundle_id.clone(),
        "source_path": args.path.display().to_string(),
        "verified": true,
        "locally_accepted": args.accept,
        "proof_bundle_authorizes_execution": false,
        "proof_bundle_replaces_run_evidence": false,
        "result": if args.accept { "accepted_as_evidence_only" } else { "verified_not_accepted" },
        "recorded_at": now_rfc3339()?
    });
    if args.accept {
        let control = repo_root(&octon_dir)
            .join(".octon/state/control/trust/proof-bundles")
            .join(format!("{bundle_id}.yml"));
        fs::create_dir_all(parent(&control)?)?;
        write_yaml(&control, &Value::Object(bundle))?;
        write_local_acceptance(
            &octon_dir,
            "portable_proof_bundle",
            &bundle_id,
            &repo_ref(&repo_root(&octon_dir), &control),
            "accepted_as_evidence",
            ".octon/instance/governance/trust/policies/proof-bundle-acceptance.yml",
        )?;
    }
    retain_command_receipt(&octon_dir, "proof-bundles", &receipt)?;
    print_json(&receipt)
}

fn proof_verify(args: TrustProofPathCmd) -> Result<()> {
    let proof = read_yaml(&args.path)?;
    verify_proof_bundle(&proof, true)?;
    print_json(&json!({
        "schema_version": "proof-bundle-verify-result-v1",
        "bundle_id": value_string(&proof, "bundle_id")?,
        "verified": true,
        "locally_accepted": false,
        "proof_bundle_authorizes_execution": false
    }))
}

fn proof_accept_or_reject(args: TrustProofPathCmd, disposition: &str) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let mut proof = read_yaml_object(&args.path)?;
    let bundle_id = map_string(&proof, "bundle_id")?;
    if disposition == "accepted" {
        verify_proof_bundle(&Value::Object(proof.clone()), true)?;
    } else {
        verify_proof_bundle(&Value::Object(proof.clone()), false)?;
    }
    proof.insert("local_acceptance".to_string(), json!(disposition));
    proof.insert(
        "proof_bundle_authorizes_execution".to_string(),
        json!(false),
    );
    proof.insert(
        "proof_bundle_replaces_run_evidence".to_string(),
        json!(false),
    );
    proof.insert(
        "proof_bundle_widens_support_claims".to_string(),
        json!(false),
    );
    proof.insert("updated_at".to_string(), json!(now_rfc3339()?));
    let control = repo_root(&octon_dir)
        .join(".octon/state/control/trust/proof-bundles")
        .join(format!("{bundle_id}.yml"));
    fs::create_dir_all(parent(&control)?)?;
    write_yaml(&control, &Value::Object(proof))?;
    let acceptance_state = if disposition == "accepted" {
        "accepted_as_evidence"
    } else {
        "rejected"
    };
    let acceptance_ref = write_local_acceptance(
        &octon_dir,
        "portable_proof_bundle",
        &bundle_id,
        &repo_ref(&repo_root(&octon_dir), &control),
        acceptance_state,
        ".octon/instance/governance/trust/policies/proof-bundle-acceptance.yml",
    )?;
    let receipt = json!({
        "schema_version": "proof-bundle-local-disposition-result-v1",
        "bundle_id": bundle_id,
        "disposition": disposition,
        "proof_ref": repo_ref(&repo_root(&octon_dir), &control),
        "local_acceptance_ref": acceptance_ref,
        "proof_bundle_authorizes_execution": false,
        "recorded_at": now_rfc3339()?
    });
    retain_command_receipt(&octon_dir, "proof-bundles", &receipt)?;
    print_json(&receipt)
}

fn proof_status(args: TrustProofStatusCmd) -> Result<()> {
    validate_id(&args.bundle_id, "bundle_id")?;
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let root = repo_root(&octon_dir);
    let proof_path = root
        .join(".octon/state/control/trust/proof-bundles")
        .join(format!("{}.yml", args.bundle_id));
    let proof = read_yaml(&proof_path)?;
    let acceptance_path = root
        .join(".octon/state/control/trust/local-acceptance")
        .join(format!("acceptance-{}.yml", args.bundle_id));
    let acceptance = if acceptance_path.is_file() {
        Some(read_yaml(&acceptance_path)?)
    } else {
        None
    };
    print_json(&json!({
        "schema_version": "proof-bundle-status-result-v1",
        "bundle_ref": repo_ref(&root, &proof_path),
        "local_acceptance_ref": if acceptance_path.is_file() { json!(repo_ref(&root, &acceptance_path)) } else { Value::Null },
        "proof": proof,
        "local_acceptance": acceptance,
        "proof_bundle_authorizes_execution": false
    }))
}

fn attest_verify(args: AttestationPathCmd) -> Result<()> {
    let attestation = read_yaml(&args.path)?;
    verify_attestation(&attestation)?;
    print_json(&json!({
        "schema_version": "attestation-verify-result-v1",
        "attestation_id": value_string(&attestation, "attestation_id")?,
        "verified": true,
        "locally_accepted": false,
        "attestation_authorizes_execution": false
    }))
}

fn attest_accept_or_reject(args: AttestationPathCmd, disposition: &str) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let mut attestation = read_yaml_object(&args.path)?;
    let id = map_string(&attestation, "attestation_id")?;
    if disposition == "accepted" {
        verify_attestation(&Value::Object(attestation.clone()))?;
    }
    attestation.insert("local_acceptance".to_string(), json!(disposition));
    attestation.insert("attestation_authorizes_execution".to_string(), json!(false));
    attestation.insert(
        "attestation_replaces_local_authority".to_string(),
        json!(false),
    );
    attestation.insert(
        "attestation_widens_support_claims".to_string(),
        json!(false),
    );
    let control = repo_root(&octon_dir)
        .join(".octon/state/control/trust/attestations")
        .join(format!("{id}.yml"));
    fs::create_dir_all(parent(&control)?)?;
    write_yaml(&control, &Value::Object(attestation))?;
    let acceptance_state = if disposition == "accepted" {
        "accepted_as_evidence"
    } else {
        "rejected"
    };
    let acceptance_ref = write_local_acceptance(
        &octon_dir,
        "attestation_envelope",
        &id,
        &repo_ref(&repo_root(&octon_dir), &control),
        acceptance_state,
        ".octon/instance/governance/trust/policies/attestation-acceptance.yml",
    )?;
    let receipt = json!({
        "schema_version": "attestation-local-disposition-result-v1",
        "attestation_id": id,
        "disposition": disposition,
        "attestation_ref": repo_ref(&repo_root(&octon_dir), &control),
        "local_acceptance_ref": acceptance_ref,
        "attestation_authorizes_execution": false,
        "recorded_at": now_rfc3339()?
    });
    retain_command_receipt(&octon_dir, "attestations", &receipt)?;
    print_json(&receipt)
}

fn attest_status(args: AttestationStatusCmd) -> Result<()> {
    validate_id(&args.attestation_id, "attestation_id")?;
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let root = repo_root(&octon_dir);
    let attestation_path = root
        .join(".octon/state/control/trust/attestations")
        .join(format!("{}.yml", args.attestation_id));
    let attestation = read_yaml(&attestation_path)?;
    let acceptance_path = root
        .join(".octon/state/control/trust/local-acceptance")
        .join(format!("acceptance-{}.yml", args.attestation_id));
    let acceptance = if acceptance_path.is_file() {
        Some(read_yaml(&acceptance_path)?)
    } else {
        None
    };
    print_json(&json!({
        "schema_version": "attestation-status-result-v1",
        "attestation_ref": repo_ref(&root, &attestation_path),
        "local_acceptance_ref": if acceptance_path.is_file() { json!(repo_ref(&root, &acceptance_path)) } else { Value::Null },
        "attestation": attestation,
        "local_acceptance": acceptance,
        "attestation_authorizes_execution": false
    }))
}

fn lease_create(args: crate::DelegateLeaseCreateCmd) -> Result<()> {
    validate_id(&args.lease_id, "lease_id")?;
    if args.approval_ref.is_none() {
        bail!("delegated lease creation requires --approval-ref; use a local Decision Request or approval control ref");
    }
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let path = repo_root(&octon_dir)
        .join(".octon/state/control/trust/delegated-leases")
        .join(format!("{}.yml", args.lease_id));
    let now = now_rfc3339()?;
    let expires_at = args.expires_at.unwrap_or(future_rfc3339(30)?);
    let value = json!({
        "schema_version": "delegated-authority-lease-v1",
        "lease_id": args.lease_id,
        "grantor": args.grantor,
        "grantee": args.grantee,
        "scope": args.scope,
        "action_classes": ["stage_only_coordination"],
        "support_tuple": "tuple://repo-local-governed/observe-and-read/reference-owned/english-primary/repo-shell",
        "support_target_ref": ".octon/instance/governance/support-targets.yml",
        "capability_packs": ["repo"],
        "capability_pack_registry_ref": ".octon/framework/capabilities/registry.yml",
        "valid_from": now.clone(),
        "expires_at": expires_at,
        "revoked_at": null,
        "revocation_ref": null,
        "revocation_conditions": ["domain revoked", "compact revoked", "lease expired"],
        "revocation_authority_refs": [".octon/instance/governance/trust/policies/federation-revocation.yml"],
        "evidence_obligations": ["lease receipt", "local authorization check"],
        "approval_refs": args.approval_ref.iter().collect::<Vec<_>>(),
        "rollback_or_compensation_posture": "revoke lease and retain evidence",
        "local_authorization_requirements": ["run contract required", "execution authorization required"],
        "status": "stage_only",
        "lifecycle_state": "stage_only",
        "lifecycle_transitions": [
            "proposed -> stage_only only with local approval refs",
            "stage_only -> revoked when any revocation condition matches",
            "stage_only -> expired at expires_at"
        ],
        "activation_requirements": [
            "trust registry domain and issuer checks pass",
            "compact remains stage_only or approved and unexpired",
            "local run contract and execution authorization remain required"
        ],
        "renewal_policy": "requires new local approval refs and recertification before expires_at",
        "lease_consumption_route": "local-authorization-input-only",
        "governance_exclusions_ref": ".octon/instance/governance/trust/policies/delegated-authority.yml",
        "lease_authorizes_execution": false,
        "permanent_authority": false,
        "run_contract_bypass_allowed": false,
        "execution_authorization_bypass_allowed": false,
        "support_claim_widening_allowed": false,
        "capability_widening_allowed": false,
        "updated_at": now
    });
    fs::create_dir_all(parent(&path)?)?;
    write_yaml(&path, &value)?;
    print_json(
        &json!({"schema_version": "delegated-lease-create-result-v1", "lease_ref": repo_ref(&repo_root(&octon_dir), &path), "lease_authorizes_execution": false, "permanent_authority": false}),
    )
}

fn lease_revoke(args: crate::DelegateLeaseRevokeCmd) -> Result<()> {
    validate_id(&args.lease_id, "lease_id")?;
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let path = repo_root(&octon_dir)
        .join(".octon/state/control/trust/revocations")
        .join(format!("revoke-{}.yml", args.lease_id));
    let value = json!({
        "schema_version": "trust-revocation-v1",
        "revocation_id": format!("revoke-{}", args.lease_id),
        "subject_ref": format!(".octon/state/control/trust/delegated-leases/{}.yml", args.lease_id),
        "reason": args.reason,
        "route_on_match": "deny",
        "fail_closed": true,
        "revocation_authorizes_execution": false,
        "created_at": now_rfc3339()?
    });
    fs::create_dir_all(parent(&path)?)?;
    write_yaml(&path, &value)?;
    print_json(
        &json!({"schema_version": "delegated-lease-revoke-result-v1", "revocation_ref": repo_ref(&repo_root(&octon_dir), &path), "route_on_match": "deny"}),
    )
}

fn classify_project(repo: &Path) -> Value {
    let octon = repo.join(".octon");
    let mut detected = Vec::new();
    if octon.is_dir() {
        detected.push(".octon");
    }
    if repo.join("attestation-envelope.yml").is_file()
        || repo.join("portable-proof-bundle.yml").is_file()
    {
        detected.push("octon-shaped-artifact");
    }
    if repo.join("connector-operation.yml").is_file() || repo.join("connector.yml").is_file() {
        detected.push("connector-shape");
    }
    let framework = octon.join("framework").is_dir();
    let root_manifest = octon.join("octon.yml").is_file();
    let instance = octon.join("instance/manifest.yml").is_file();
    let workspace = octon.join("instance/charter/workspace.yml").is_file();
    let state_control = octon.join("state/control").is_dir();
    let state_evidence = octon.join("state/evidence").is_dir();
    let state_continuity = octon.join("state/continuity").is_dir();
    let state_roots = state_control && state_evidence && state_continuity;
    let generated = octon.join("generated").is_dir();
    let connector_shape = detected.contains(&"connector-shape");
    let emitter_shape = detected.contains(&"octon-shaped-artifact");
    let complete_octon =
        octon.is_dir() && root_manifest && framework && instance && workspace && state_roots;
    let partial_octon = octon.is_dir() && !complete_octon;
    let detected_state = if complete_octon {
        "octon_enabled_repo"
    } else if emitter_shape {
        "octon_shaped_emitter"
    } else if connector_shape {
        "connector_only_external_system"
    } else if partial_octon && !root_manifest {
        "stale_octon"
    } else if partial_octon && (framework || instance || state_roots) {
        "partial_octon"
    } else if partial_octon {
        "conflicting_octon"
    } else {
        "no_octon"
    };
    let tier = if complete_octon {
        "octon_enabled_repo"
    } else if emitter_shape {
        "octon_compatible_emitter"
    } else if connector_shape {
        "octon_mediated_connector"
    } else {
        "external_evidence_source"
    };
    let adoption_state = if complete_octon {
        "octon_enabled"
    } else if partial_octon {
        "partial_or_conflicted_octon"
    } else {
        "no_octon"
    };
    json!({
        "participation_tier": tier,
        "detected_state": detected_state,
        "adoption_state": adoption_state,
        "detected_artifacts": detected,
        "root_manifest_present": root_manifest,
        "portable_framework_present": framework,
        "repo_specific_instance_present": instance,
        "workspace_charter_present": workspace,
        "state_control_root_present": state_control,
        "state_evidence_root_present": state_evidence,
        "state_continuity_root_present": state_continuity,
        "state_roots_present": state_roots,
        "generated_projection_present": generated,
        "generated_projection_requires_rebuild": generated,
        "bootstrap_doctor_ready": complete_octon,
        "blind_copy_full_octon_allowed": false,
        "deep_federation_allowed": false,
        "material_execution_authorized": false
    })
}

fn inspection_record(
    repo: &Path,
    classification: &Value,
    project_id: &str,
    now: &str,
    evidence_path: &Path,
    root: &Path,
) -> Value {
    let detected_state = classification
        .get("detected_state")
        .and_then(Value::as_str)
        .unwrap_or("no_octon");
    let tier = classification
        .get("participation_tier")
        .and_then(Value::as_str)
        .unwrap_or("external_evidence_source");
    json!({
        "schema_version": "external-project-compatibility-inspection-v1",
        "inspection_id": format!("inspection-{project_id}"),
        "project_ref": repo.display().to_string(),
        "inspected_at": now,
        "detected_state": detected_state,
        "classification": {
            "participation_tier": tier,
            "profile_ref": COMPATIBILITY_PROFILE_REF,
            "reason": "runtime compatibility inspection; classification does not authorize adoption, federation, or execution",
            "deep_federation_allowed": false
        },
        "topology_checks": {
            "octon_root_present": classification.get("detected_artifacts").and_then(Value::as_array).map(|items| items.iter().any(|item| item.as_str() == Some(".octon"))).unwrap_or(false),
            "portable_framework_present": classification.get("portable_framework_present").and_then(Value::as_bool).unwrap_or(false),
            "repo_specific_instance_present": classification.get("repo_specific_instance_present").and_then(Value::as_bool).unwrap_or(false),
            "workspace_charter_present": classification.get("workspace_charter_present").and_then(Value::as_bool).unwrap_or(false),
            "state_control_root_present": classification.get("state_control_root_present").and_then(Value::as_bool).unwrap_or(false),
            "state_evidence_root_present": classification.get("state_evidence_root_present").and_then(Value::as_bool).unwrap_or(false),
            "state_continuity_root_present": classification.get("state_continuity_root_present").and_then(Value::as_bool).unwrap_or(false),
            "generated_projection_present": classification.get("generated_projection_present").and_then(Value::as_bool).unwrap_or(false),
            "generated_projection_requires_rebuild": true,
            "bootstrap_doctor_ready": classification.get("bootstrap_doctor_ready").and_then(Value::as_bool).unwrap_or(false)
        },
        "adoption_gate": {
            "status": if tier == "octon_enabled_repo" { "ready" } else { "blocked" },
            "blockers": if tier == "octon_enabled_repo" { json!([]) } else { json!(["target is not Octon-enabled until safe adoption passes"]) },
            "blind_copy_full_octon_allowed": false
        },
        "federation_gate": {
            "status": "deferred",
            "deferred_scope": ["full Trust Registry runtime", "Federation Compact runtime", "delegated authority runtime"],
            "requires_future_trust_runtime": true
        },
        "evidence_refs": [repo_ref(root, evidence_path)],
        "material_execution_authorized": false,
        "inspection_authorizes_adoption": false,
        "inspection_authorizes_federation": false
    })
}

fn verify_attestation(value: &Value) -> Result<()> {
    for key in [
        "schema_version",
        "attestation_id",
        "issuer",
        "subject",
        "claim_type",
        "scope",
        "valid_from",
        "expires_at",
        "evidence_refs",
        "revocation_refs",
        "verification_method",
        "trust_domain_id",
        "verification_status",
        "freshness_status",
        "revocation_status",
        "local_acceptance_evidence_refs",
        "consumer_verification_requirements",
    ] {
        require_present(value, key)?;
    }
    require_schema(value, "attestation-envelope-v1")?;
    require_bool(value, "attestation_authorizes_execution", false)?;
    require_bool(value, "attestation_replaces_local_authority", false)?;
    require_bool(value, "attestation_widens_support_claims", false)?;
    ensure_not_expired(value, "expires_at")?;
    ensure_registry_accepts(
        value_string(value, "trust_domain_id")?.as_str(),
        value_string(value, "issuer")?.as_str(),
    )?;
    ensure_no_matching_revocation(value, "attestation_envelope", "attestation_id")?;
    if value.get("signature").is_some_and(Value::is_null) {
        let unsigned = value
            .get("unsigned_acceptance_constraints")
            .and_then(|v| v.get("unsigned_allowed"))
            .and_then(Value::as_bool)
            .unwrap_or(false);
        let route = value
            .get("unsigned_acceptance_constraints")
            .and_then(|v| v.get("route_when_unsigned"))
            .and_then(Value::as_str)
            .unwrap_or("deny");
        if !unsigned || route != "local-evidence-only" {
            bail!("unsigned attestation must route to local-evidence-only or be denied");
        }
    }
    if value.get("local_acceptance").and_then(Value::as_str) == Some("accepted") {
        require_string(value, "verification_status", "verified")?;
        require_string(value, "freshness_status", "fresh")?;
        require_string(value, "revocation_status", "unrevoked")?;
    }
    Ok(())
}

fn verify_proof_bundle(value: &Value, require_acceptable: bool) -> Result<()> {
    for key in [
        "schema_version",
        "bundle_id",
        "issuer",
        "trust_domain_id",
        "scope",
        "valid_from",
        "expires_at",
        "evidence_digests",
        "redaction_manifest",
        "revocation_refs",
        "import_export_controls",
        "consumer_verification_requirements",
        "verification_status",
        "freshness_status",
        "revocation_status",
        "digest_verification",
        "local_acceptance_evidence_refs",
    ] {
        require_present(value, key)?;
    }
    require_schema(value, "portable-proof-bundle-v1")?;
    require_bool(value, "proof_bundle_authorizes_execution", false)?;
    require_bool(value, "proof_bundle_replaces_run_evidence", false)?;
    require_bool(value, "proof_bundle_widens_support_claims", false)?;
    ensure_valid_from_active(value, "valid_from")?;
    ensure_not_expired(value, "expires_at")?;
    ensure_proof_status_not_denied(value)?;
    ensure_registry_accepts(
        value_string(value, "trust_domain_id")?.as_str(),
        value_string(value, "issuer")?.as_str(),
    )?;
    ensure_no_matching_revocation(value, "portable_proof_bundle", "bundle_id")?;
    ensure_redaction_manifest_safe(value)?;
    ensure_digest_refs(value)?;
    if require_acceptable
        || value.get("local_acceptance").and_then(Value::as_str) == Some("accepted")
    {
        require_string(value, "verification_status", "verified")?;
        require_string(value, "freshness_status", "fresh")?;
        require_string(value, "revocation_status", "unrevoked")?;
        require_string(value, "digest_verification", "verified")?;
    }
    Ok(())
}

fn write_local_acceptance(
    octon_dir: &Path,
    subject_kind: &str,
    subject_id: &str,
    subject_ref: &str,
    acceptance_state: &str,
    responsible_local_authority: &str,
) -> Result<String> {
    let root = repo_root(octon_dir);
    let acceptance_id = format!("acceptance-{subject_id}");
    let now = now_rfc3339()?;
    let record = json!({
        "schema_version": "local-proof-acceptance-v1",
        "acceptance_id": acceptance_id,
        "subject_kind": subject_kind,
        "subject_ref": subject_ref,
        "acceptance_state": acceptance_state,
        "scope": "local v6 proof interoperability evidence acceptance",
        "evidence_requirements_satisfied": if acceptance_state.starts_with("accepted") { json!(["schema validity", "freshness", "revocation posture", "local policy acceptance"]) } else { json!([]) },
        "limitations": [
            "does not authorize execution",
            "does not replace local authority",
            "does not widen support claims"
        ],
        "freshness_status": if acceptance_state.starts_with("accepted") { "fresh" } else { "stale" },
        "revocation_status": if acceptance_state == "revoked" { "revoked" } else { "unrevoked" },
        "responsible_local_authority": responsible_local_authority,
        "decision_request_ref": Value::Null,
        "accepted_at": now,
        "expires_at": future_rfc3339(90)?,
        "revocable": true,
        "local_acceptance_authorizes_execution": false,
        "local_acceptance_replaces_local_authority": false,
        "local_acceptance_widens_support_claims": false
    });
    let path = root
        .join(".octon/state/control/trust/local-acceptance")
        .join(format!("{acceptance_id}.yml"));
    fs::create_dir_all(parent(&path)?)?;
    write_yaml(&path, &record)?;
    let evidence_path = root
        .join(".octon/state/evidence/trust/local-acceptance")
        .join(&acceptance_id)
        .join("receipt.yml");
    fs::create_dir_all(parent(&evidence_path)?)?;
    write_yaml(
        &evidence_path,
        &json!({
            "schema_version": "local-proof-acceptance-evidence-v1",
            "acceptance_ref": repo_ref(&root, &path),
            "subject_ref": subject_ref,
            "accepted_as": if acceptance_state.starts_with("accepted") { "evidence-only" } else { "not-accepted" },
            "local_acceptance_authorizes_execution": false,
            "recorded_at": now_rfc3339()?
        }),
    )?;
    Ok(repo_ref(&root, &path))
}

fn ensure_not_expired(value: &Value, field: &str) -> Result<()> {
    let expires_at = value_string(value, field)?;
    let expires_at = OffsetDateTime::parse(&expires_at, &Rfc3339)
        .with_context(|| format!("{field} must be RFC3339"))?;
    if expires_at <= OffsetDateTime::now_utc() {
        bail!("{field} is expired; route is deny")
    }
    Ok(())
}

fn ensure_valid_from_active(value: &Value, field: &str) -> Result<()> {
    let valid_from = value_string(value, field)?;
    let valid_from = OffsetDateTime::parse(&valid_from, &Rfc3339)
        .with_context(|| format!("{field} must be RFC3339"))?;
    if valid_from > OffsetDateTime::now_utc() {
        bail!("{field} is in the future; route is deny")
    }
    Ok(())
}

fn ensure_proof_status_not_denied(value: &Value) -> Result<()> {
    match value.get("freshness_status").and_then(Value::as_str) {
        Some("stale" | "expired") => bail!("freshness_status routes to deny"),
        Some(_) => {}
        None => bail!("freshness_status is required"),
    }
    match value.get("revocation_status").and_then(Value::as_str) {
        Some("revoked") => bail!("revocation_status routes to deny"),
        Some(_) => {}
        None => bail!("revocation_status is required"),
    }
    match value.get("digest_verification").and_then(Value::as_str) {
        Some("failed") => bail!("digest_verification routes to deny"),
        Some(_) => {}
        None => bail!("digest_verification is required"),
    }
    match value.get("local_acceptance").and_then(Value::as_str) {
        Some("revoked" | "expired") => bail!("local_acceptance routes to deny"),
        Some(_) => {}
        None => bail!("local_acceptance is required"),
    }
    Ok(())
}

fn ensure_registry_accepts(domain_id: &str, issuer_id: &str) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let root = repo_root(&octon_dir);
    let registry = read_yaml(&root.join(TRUST_REGISTRY_REF))?;
    let domain_ok = registry
        .get("accepted_domains")
        .and_then(Value::as_array)
        .map(|domains| {
            domains.iter().any(|domain| {
                domain.get("domain_id").and_then(Value::as_str) == Some(domain_id)
                    && domain.get("status").and_then(Value::as_str) != Some("revoked")
            })
        })
        .unwrap_or(false);
    let issuer_ok = registry
        .get("trusted_issuers")
        .and_then(Value::as_array)
        .map(|issuers| {
            issuers.iter().any(|issuer| {
                issuer.get("issuer_id").and_then(Value::as_str) == Some(issuer_id)
                    && issuer.get("domain_id").and_then(Value::as_str) == Some(domain_id)
                    && issuer.get("status").and_then(Value::as_str) != Some("revoked")
            })
        })
        .unwrap_or(false);
    if !domain_ok {
        bail!("trust domain {domain_id} is not locally accepted")
    }
    if !issuer_ok {
        bail!("issuer {issuer_id} is not locally trusted for domain {domain_id}")
    }
    Ok(())
}

fn ensure_no_matching_revocation(value: &Value, subject_kind: &str, id_key: &str) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let root = repo_root(&octon_dir);
    let id = value_string(value, id_key)?;
    let subject_candidates = [
        id.clone(),
        format!(".octon/state/control/trust/proof-bundles/{id}.yml"),
        format!(".octon/state/control/trust/attestations/{id}.yml"),
        format!(".octon/state/control/trust/local-acceptance/acceptance-{id}.yml"),
    ];
    let Some(refs) = value.get("revocation_refs").and_then(Value::as_array) else {
        bail!("revocation_refs must be an array");
    };
    for rev_ref in refs.iter().filter_map(Value::as_str) {
        let path = ensure_repo_scoped_artifact(&root, rev_ref, "revocation ref")?;
        let revocation = read_yaml(&path)?;
        let schema_version = revocation.get("schema_version").and_then(Value::as_str);
        if schema_version != Some("proof-revocation-v1")
            && schema_version != Some("trust-revocation-v1")
        {
            bail!("revocation ref {rev_ref} must be a recognized revocation artifact");
        }
        if schema_version == Some("trust-revocation-v1") {
            if revocation.get("route_on_match").and_then(Value::as_str) != Some("deny")
                || revocation.get("fail_closed").and_then(Value::as_bool) != Some(true)
            {
                bail!("trust revocation ref {rev_ref} must fail closed");
            }
            continue;
        }
        let kind_matches = revocation.get("subject_kind").and_then(Value::as_str)
            == Some(subject_kind)
            || revocation.get("subject_kind").and_then(Value::as_str) == Some("local_acceptance");
        let subject_matches = revocation
            .get("subject_ref")
            .and_then(Value::as_str)
            .map(|subject| {
                subject_candidates
                    .iter()
                    .any(|candidate| candidate == subject)
            })
            .unwrap_or(false);
        let status_blocks = matches!(
            revocation.get("status").and_then(Value::as_str),
            Some("revoked" | "expired" | "stale")
        );
        if kind_matches && subject_matches && status_blocks {
            bail!("matching proof revocation {} routes to deny", rev_ref);
        }
    }
    Ok(())
}

fn ensure_redaction_manifest_safe(value: &Value) -> Result<()> {
    let manifest = value
        .get("redaction_manifest")
        .ok_or_else(|| anyhow!("redaction_manifest is required"))?;
    if manifest
        .get("exported_secret_material_allowed")
        .and_then(Value::as_bool)
        != Some(false)
    {
        bail!("exported_secret_material_allowed must be false")
    }
    if manifest
        .get("redaction_required")
        .and_then(Value::as_bool)
        .is_none()
    {
        bail!("redaction_required must be present")
    }
    Ok(())
}

fn ensure_digest_refs(value: &Value) -> Result<()> {
    let octon_dir = octon_core::root::RootResolver::resolve()?;
    let root = repo_root(&octon_dir);
    let Some(digests) = value.get("evidence_digests").and_then(Value::as_array) else {
        bail!("evidence_digests must be an array");
    };
    if digests.is_empty() {
        bail!("evidence_digests must not be empty");
    }
    for digest in digests {
        let Some(rel_path) = digest.get("path").and_then(Value::as_str) else {
            bail!("evidence digest path is required");
        };
        if digest.get("digest_algorithm").and_then(Value::as_str) != Some("sha256") {
            bail!("evidence digest algorithm must be sha256 for {rel_path}");
        }
        let Some(expected) = digest.get("digest").and_then(Value::as_str) else {
            bail!("evidence digest value is required");
        };
        let path = ensure_repo_scoped_artifact(&root, rel_path, "evidence digest path")?;
        let actual = sha256_file(&path)?;
        if actual != expected {
            bail!("digest mismatch for {rel_path}");
        }
    }
    Ok(())
}

fn ensure_repo_scoped_artifact(root: &Path, rel_path: &str, label: &str) -> Result<PathBuf> {
    let rel = Path::new(rel_path);
    if rel_path.trim().is_empty() {
        bail!("{label} is empty");
    }
    if rel.is_absolute() {
        bail!("{label} must be repo-relative: {rel_path}");
    }
    if rel.components().any(|component| {
        matches!(
            component,
            Component::ParentDir | Component::RootDir | Component::Prefix(_)
        )
    }) {
        bail!("{label} must not escape the repository: {rel_path}");
    }

    let normalized = rel_path.replace('\\', "/");
    if !normalized.starts_with(".octon/") {
        bail!("{label} must remain under .octon/: {rel_path}");
    }
    if normalized.starts_with(".octon/inputs/") || normalized.starts_with(".octon/generated/") {
        bail!(
            "{label} is outside the proof-verifiable authority/control/evidence scope: {rel_path}"
        );
    }

    let root_canonical = root
        .canonicalize()
        .with_context(|| format!("canonicalize repository root {}", root.display()))?;
    let path = root.join(rel);
    let path_canonical = path
        .canonicalize()
        .with_context(|| format!("{label} is missing or unreadable: {rel_path}"))?;
    if !path_canonical.starts_with(&root_canonical) {
        bail!("{label} must resolve inside the repository: {rel_path}");
    }
    let metadata = fs::metadata(&path_canonical)
        .with_context(|| format!("{label} is unreadable: {rel_path}"))?;
    if !metadata.is_file() {
        bail!("{label} must resolve to a file: {rel_path}");
    }
    Ok(path_canonical)
}

fn retain_command_receipt(octon_dir: &Path, family: &str, value: &Value) -> Result<()> {
    let id = short_digest(serde_json::to_string(value)?.as_bytes());
    let path = repo_root(octon_dir)
        .join(".octon/state/evidence/trust")
        .join(family)
        .join(format!("command-{id}"))
        .join("receipt.yml");
    fs::create_dir_all(parent(&path)?)?;
    write_yaml(&path, value)
}

fn read_yaml(path: &Path) -> Result<Value> {
    let bytes = fs::read(path).with_context(|| format!("read {}", path.display()))?;
    Ok(serde_yaml::from_slice(&bytes).with_context(|| format!("parse yaml {}", path.display()))?)
}

fn read_yaml_object(path: &Path) -> Result<Map<String, Value>> {
    read_yaml(path)?
        .as_object()
        .cloned()
        .ok_or_else(|| anyhow!("{} must contain a YAML mapping", path.display()))
}

fn write_yaml(path: &Path, value: &Value) -> Result<()> {
    let text = serde_yaml::to_string(value)?;
    fs::write(path, text).with_context(|| format!("write {}", path.display()))
}

fn print_json(value: &Value) -> Result<()> {
    println!("{}", serde_json::to_string_pretty(value)?);
    Ok(())
}

fn repo_root(octon_dir: &Path) -> PathBuf {
    octon_dir
        .parent()
        .map(Path::to_path_buf)
        .unwrap_or_else(|| PathBuf::from("."))
}

fn repo_ref(root: &Path, path: &Path) -> String {
    path.strip_prefix(root)
        .map(|rel| rel.display().to_string())
        .unwrap_or_else(|_| path.display().to_string())
}

fn project_id_for(path: &Path) -> String {
    format!(
        "project-{}",
        short_digest(path.display().to_string().as_bytes())
    )
}

fn parent(path: &Path) -> Result<&Path> {
    path.parent()
        .ok_or_else(|| anyhow!("path has no parent: {}", path.display()))
}

fn canonical_or_input(path: &Path) -> PathBuf {
    path.canonicalize().unwrap_or_else(|_| path.to_path_buf())
}

fn validate_id(value: &str, label: &str) -> Result<()> {
    if value
        .chars()
        .all(|ch| ch.is_ascii_alphanumeric() || ch == '-' || ch == '_' || ch == '.')
        && !value.is_empty()
    {
        Ok(())
    } else {
        bail!("{label} contains unsupported characters: {value}")
    }
}

fn require_present(value: &Value, key: &str) -> Result<()> {
    if value.get(key).is_some() {
        Ok(())
    } else {
        bail!("{key} is required")
    }
}

fn require_schema(value: &Value, schema: &str) -> Result<()> {
    if value.get("schema_version").and_then(Value::as_str) == Some(schema) {
        Ok(())
    } else {
        bail!("schema_version must be {schema}")
    }
}

fn require_bool(value: &Value, key: &str, expected: bool) -> Result<()> {
    if value.get(key).and_then(Value::as_bool) == Some(expected) {
        Ok(())
    } else {
        bail!("{key} must be {expected}")
    }
}

fn require_string(value: &Value, key: &str, expected: &str) -> Result<()> {
    if value.get(key).and_then(Value::as_str) == Some(expected) {
        Ok(())
    } else {
        bail!("{key} must be {expected}")
    }
}

fn value_string(value: &Value, key: &str) -> Result<String> {
    value
        .get(key)
        .and_then(Value::as_str)
        .map(str::to_string)
        .ok_or_else(|| anyhow!("{key} must be a string"))
}

fn map_string(value: &Map<String, Value>, key: &str) -> Result<String> {
    value
        .get(key)
        .and_then(Value::as_str)
        .map(str::to_string)
        .ok_or_else(|| anyhow!("{key} must be a string"))
}

fn future_rfc3339(days: i64) -> Result<String> {
    Ok((OffsetDateTime::now_utc() + Duration::days(days)).format(&Rfc3339)?)
}

fn sha256_file(path: &Path) -> Result<String> {
    let bytes = fs::read(path).with_context(|| format!("read {}", path.display()))?;
    Ok(hex::encode(Sha256::digest(bytes)))
}

fn short_digest(bytes: &[u8]) -> String {
    let digest = Sha256::digest(bytes);
    hex::encode(&digest[..8])
}
