use std::fs;
use std::path::{Path, PathBuf};
use std::process::{Command, Output};
use std::time::{SystemTime, UNIX_EPOCH};

struct FixtureRepo {
    root: PathBuf,
}

impl FixtureRepo {
    fn new(name: &str, child_phase_id: Option<&str>) -> Self {
        let nanos = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_nanos();
        for counter in 0..1000 {
            let root = std::env::temp_dir().join(format!(
                "octon-proposal-program-cli-{name}-{}-{nanos}-{counter}",
                std::process::id()
            ));
            if fs::create_dir(&root).is_ok() {
                let fixture = Self { root };
                fixture.write_generated_catalog();
                fixture.write_context_pack_authority();
                fixture.write_child_contract();
                fixture.write_program_contract();
                fixture.write_parent(child_phase_id);
                fixture.write_child();
                return fixture;
            }
        }
        panic!("unable to create fixture repo for {name}");
    }

    fn write(&self, rel: &str, content: &str) {
        let path = self.root.join(rel);
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent).unwrap();
        }
        fs::write(path, content).unwrap();
    }

    fn write_generated_catalog(&self) {
        self.write(
            ".octon/generated/effective/extensions/catalog.effective.yml",
            r#"
schema_version: "test"
packs:
  - pack_id: "test-extension"
    capability_profiles: ["validation-surface", "lifecycle-contract"]
    lifecycle_contracts:
      - lifecycle_id: "proposal-packet"
        projection_source_path: ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml"
      - lifecycle_id: "proposal-program"
        projection_source_path: ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml"
"#,
        );
    }

    fn write_context_pack_authority(&self) {
        self.write(
            ".octon/framework/engine/runtime/spec/context-pack-builder-v1.md",
            "# Context Pack Builder v1\n",
        );
        self.write(
            ".octon/instance/governance/policies/context-packing.yml",
            "schema_version: context-packing-policy-v1\n",
        );
    }

    fn write_child_contract(&self) {
        self.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycle.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-packet"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }
states: [{ state_id: "implement" }]
terminal_outcomes:
  - outcome_id: "implemented"
    when: { manifest_status: "implemented" }
receipts:
  - receipt_id: "implementation-prompt"
    path: "support/executable-implementation-prompt.md"
  - receipt_id: "implementation-run"
    path: "support/implementation-run.md"
    required_fields: ["verdict", "implemented_at", "promotion_evidence_count"]
    verdict_field: "verdict"
routes:
  - route_id: "run-packet-implementation"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: ["implementation-prompt"]
      required_receipts_before_completion: ["implementation-run"]
      replay_class: "bounded-retry"
      automated_recovery_policy: "bounded-automated-retry"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
    enter_when:
      all:
        - manifest_status: "accepted"
        - receipt_complete: "implementation-prompt"
        - receipt_absent: "implementation-run"
    completion:
      expected_receipts: ["implementation-run"]
"#,
        );
    }

    fn write_program_contract(&self) {
        self.write(
            ".octon/generated/effective/extensions/published/test-extension/bundled/context/lifecycles/proposal-program.contract.yml",
            r#"
schema_version: "octon-extension-lifecycle-contract-v1"
lifecycle_id: "proposal-program"
owner_extension: "test-extension"
version: "1.0.0"
target: { input: "program_packet_path", manifest_path: "proposal.yml", status_field: "status", allowed_statuses: ["accepted", "implemented"] }
program:
  child_registry_path: "resources/child-packet-index.yml"
  child_lifecycle_id_default: "proposal-packet"
  supported_execution_modes: ["parallel-independent"]
  recovery_policy:
    max_recovery_attempts: 2
    serialize_write_scope_conflicts: true
  authority_boundaries:
    parent_coordinates_only: true
    child_receipts_remain_child_owned: true
    child_promotion_targets_remain_child_owned: true
states: [{ state_id: "coordinate" }]
terminal_outcomes:
  - outcome_id: "implemented"
    when: { manifest_status: "implemented" }
receipts:
  - receipt_id: "program-summary"
    path: "support/program-summary.md"
routes:
  - route_id: "generate-program-implementation-orchestration-prompt"
    route_type: "extension"
    delegation_contract:
      decision_class: "delegated-execution"
      safe_delegation: true
      authority_zones_allowed: ["workspace-declared"]
      declared_write_scope_source: "target"
      required_evidence_gates: []
      required_receipts_before_dispatch: []
      required_receipts_before_completion: ["program-implementation-orchestration-prompt"]
      replay_class: "idempotent"
      automated_recovery_policy: "fail-closed"
      human_only_boundaries: ["scope-expansion", "policy-override", "governance-mutation"]
"#,
        );
    }

    fn write_parent(&self, child_phase_id: Option<&str>) {
        self.write("parent/proposal.yml", "status: accepted\n");
        let phase = child_phase_id
            .map(|phase_id| format!("    phase_id: \"{phase_id}\"\n"))
            .unwrap_or_default();
        self.write(
            "parent/resources/child-packet-index.yml",
            &format!(
                "schema_version: \"octon-proposal-program-child-registry-v1\"\nexecution_mode: \"parallel-independent\"\ndefault_child_lifecycle_id: \"proposal-packet\"\nchildren:\n  - child_id: \"child-a\"\n    path: \"children/child-a\"\n{phase}"
            ),
        );
    }

    fn write_child(&self) {
        self.write(
            "children/child-a/proposal.yml",
            "status: accepted\npromotion_targets:\n  - \"framework/child-a.md\"\n",
        );
        self.write(
            "children/child-a/support/executable-implementation-prompt.md",
            "# Executable Implementation Prompt\n\nMock-ready child prompt.\n",
        );
    }
}

impl Drop for FixtureRepo {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.root);
    }
}

fn octon_bin() -> PathBuf {
    PathBuf::from(env!("CARGO_BIN_EXE_octon"))
}

fn run_octon(repo: &FixtureRepo, args: &[&str]) -> Output {
    Command::new(octon_bin())
        .current_dir(&repo.root)
        .env("OCTON_ROOT_DIR", &repo.root)
        .args(args)
        .output()
        .unwrap()
}

fn stdout(output: &Output) -> String {
    String::from_utf8_lossy(&output.stdout).into_owned()
}

fn assert_success(output: &Output) {
    assert!(
        output.status.success(),
        "status: {:?}\nstdout:\n{}\nstderr:\n{}",
        output.status,
        String::from_utf8_lossy(&output.stdout),
        String::from_utf8_lossy(&output.stderr)
    );
}

fn assert_file_contains(path: &Path, needle: &str) {
    let content = fs::read_to_string(path).unwrap();
    assert!(
        content.contains(needle),
        "{} did not contain {needle:?}:\n{content}",
        path.display()
    );
}

#[test]
fn program_run_without_execute_routes_hands_off_child_route_without_dispatching() {
    let repo = FixtureRepo::new("handoff", None);

    let output = run_octon(
        &repo,
        &[
            "lifecycle",
            "run",
            "--lifecycle",
            "proposal-program",
            "--target",
            "parent",
            "--run-id",
            "program-handoff",
            "--executor",
            "mock",
        ],
    );

    assert_success(&output);
    let stdout = stdout(&output);
    assert!(stdout.contains("route_execution_mode: program-route-handoff"));
    assert!(stdout.contains("selected_children:"));
    assert!(stdout.contains("- child-a"));
    assert!(!repo
        .root
        .join("children/child-a/support/implementation-run.md")
        .exists());
    assert_file_contains(
        &repo
            .root
            .join(".octon/state/evidence/runs/workflows/program-handoff/summary.md"),
        "selected_route: run-packet-implementation",
    );
}

#[test]
fn program_run_execute_routes_dispatches_child_route_and_writes_child_receipt() {
    let repo = FixtureRepo::new("execute-child", None);

    let output = run_octon(
        &repo,
        &[
            "lifecycle",
            "run",
            "--lifecycle",
            "proposal-program",
            "--target",
            "parent",
            "--run-id",
            "program-execute-child",
            "--executor",
            "mock",
            "--execute-routes",
            "--max-steps",
            "1",
        ],
    );

    assert_success(&output);
    let stdout = stdout(&output);
    assert!(stdout.contains("route_execution_mode: program-adapter-executed"));
    assert!(stdout.contains("child_results:"));
    assert!(stdout.contains("route_id: run-packet-implementation"));
    assert!(stdout.contains("status: completed"));
    assert_file_contains(
        &repo
            .root
            .join("children/child-a/support/implementation-run.md"),
        "promotion_evidence_count:",
    );
    assert_file_contains(
        &repo.root.join(
            ".octon/state/control/execution/runs/program-execute-child/program-events.ndjson",
        ),
        "child-route-started",
    );
}

#[test]
fn program_plan_keeps_child_phase_metadata_from_replacing_contract_route() {
    let repo = FixtureRepo::new("phase-metadata", Some("promote-proposal"));

    let output = run_octon(
        &repo,
        &[
            "lifecycle",
            "plan",
            "--lifecycle",
            "proposal-program",
            "--target",
            "parent",
        ],
    );

    assert_success(&output);
    let stdout = stdout(&output);
    assert!(stdout.contains("phase_id: promote-proposal"));
    assert!(stdout.contains("route_id: run-packet-implementation"));
    assert!(!stdout.contains("route_id: promote-proposal"));
}

#[test]
fn program_handoff_fixture_covers_terminal_routing_matrix_without_child_side_effects() {
    let repo = FixtureRepo::new("terminal-routing-matrix", Some("phase-6"));
    repo.write(
        "children/child-b/proposal.yml",
        "status: accepted\npromotion_targets:\n  - \"framework/child-b.md\"\n",
    );
    repo.write(
        "children/child-b/support/executable-implementation-prompt.md",
        "# Executable Implementation Prompt\n\nMock-ready sibling child prompt.\n",
    );
    repo.write(
        "parent/resources/child-packet-index.yml",
        r#"schema_version: "octon-proposal-program-child-registry-v2"
execution_mode: "parallel-independent"
default_child_lifecycle_id: "proposal-packet"
children:
  - child_id: "child-a"
    path: "children/child-a"
    phase_id: "phase-6"
    group_id: "tests"
    write_scopes:
      - "framework/child-a.md"
  - child_id: "child-b"
    path: "children/child-b"
    phase_id: "phase-6"
    group_id: "tests"
    write_scopes:
      - "framework/child-b.md"
"#,
    );

    let output = run_octon(
        &repo,
        &[
            "lifecycle",
            "run",
            "--lifecycle",
            "proposal-program",
            "--target",
            "parent",
            "--run-id",
            "program-terminal-routing-matrix",
            "--executor",
            "codex",
        ],
    );

    assert_success(&output);
    let stdout = stdout(&output);
    assert!(stdout.contains("route_execution_mode: program-route-handoff"));
    assert!(stdout.contains("- child-a"));
    assert!(stdout.contains("- child-b"));
    assert!(!repo
        .root
        .join("children/child-a/support/implementation-run.md")
        .exists());
    assert!(!repo
        .root
        .join("children/child-b/support/implementation-run.md")
        .exists());
    assert_file_contains(
        &repo.root.join(
            ".octon/state/evidence/runs/workflows/program-terminal-routing-matrix/summary.md",
        ),
        "final_verdict: planned",
    );
    assert_file_contains(
        &repo.root.join(
            ".octon/state/evidence/runs/workflows/program-terminal-routing-matrix/summary.md",
        ),
        "selected_route: run-packet-implementation",
    );
    assert_file_contains(
        &repo.root.join(
            ".octon/state/evidence/runs/workflows/program-terminal-routing-matrix/summary.md",
        ),
        "Child packet manifests, receipts, promotion targets, validation verdicts, and archive metadata remain child-owned.",
    );
}
