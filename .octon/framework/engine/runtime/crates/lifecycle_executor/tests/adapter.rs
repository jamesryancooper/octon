use octon_lifecycle_executor::{
    default_bound_inputs, resolve_prompt_bundle, resolve_workflow_manifest,
    DefaultLifecycleRouteExecutor, LifecycleApprovalContext, LifecycleExecutionPolicy,
    LifecycleReceiptSpec, LifecycleRouteExecutionRequest, LifecycleRouteExecutor,
    LifecycleRouteSpec,
};
use std::env;
use std::fs;
#[cfg(unix)]
use std::os::unix::fs::symlink;
#[cfg(unix)]
use std::os::unix::fs::PermissionsExt;
use std::path::{Path, PathBuf};
use std::sync::{Mutex, OnceLock};
use std::thread;
use std::time::{Duration, Instant, SystemTime, UNIX_EPOCH};

fn temp_root(name: &str) -> PathBuf {
    let nanos = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_nanos();
    for counter in 0..1000 {
        let root = std::env::temp_dir().join(format!(
            "octon-lifecycle-executor-{name}-{}-{nanos}-{counter}",
            std::process::id()
        ));
        if fs::create_dir(&root).is_ok() {
            return root;
        }
    }
    panic!("unable to create unique lifecycle executor temp root for {name}");
}

fn write_file(path: &Path, content: &str) {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent).unwrap();
    }
    fs::write(path, content).unwrap();
}

fn env_lock() -> &'static Mutex<()> {
    static LOCK: OnceLock<Mutex<()>> = OnceLock::new();
    LOCK.get_or_init(|| Mutex::new(()))
}

struct PathGuard {
    original: Option<std::ffi::OsString>,
}

impl Drop for PathGuard {
    fn drop(&mut self) {
        if let Some(value) = self.original.as_ref() {
            env::set_var("PATH", value);
        } else {
            env::remove_var("PATH");
        }
    }
}

fn prepend_path(bin_dir: &Path) -> PathGuard {
    let original = env::var_os("PATH");
    let mut paths = vec![bin_dir.to_path_buf()];
    if let Some(existing) = original.as_ref() {
        paths.extend(env::split_paths(existing));
    }
    env::set_var("PATH", env::join_paths(paths).unwrap());
    PathGuard { original }
}

fn write_fake_agent_binary(path: &Path, label: &str) {
    write_file(
        path,
        &format!(
            r#"#!/usr/bin/env bash
set -euo pipefail
prompt="$(cat)"
target="$(printf '%s\n' "$prompt" | sed -n 's/^- target: `\(.*\)`/\1/p' | head -n 1)"
if [[ -z "$target" ]]; then
  echo "target binding missing" >&2
  exit 3
fi
mkdir -p "$target/support"
printf '# Executable Implementation Prompt\n\nfake {label} executor\n' > "$target/support/executable-implementation-prompt.md"
printf 'fake {label} executed\n'
"#
        ),
    );
    #[cfg(unix)]
    {
        let mut permissions = fs::metadata(path).unwrap().permissions();
        permissions.set_mode(0o755);
        fs::set_permissions(path, permissions).unwrap();
    }
}

fn write_failing_mutating_agent_binary(path: &Path) {
    write_file(
        path,
        r#"#!/usr/bin/env bash
set -euo pipefail
prompt="$(cat)"
target="$(printf '%s\n' "$prompt" | sed -n 's/^- target: `\(.*\)`/\1/p' | head -n 1)"
if [[ -n "$target" ]]; then
  mkdir -p "$target"
  printf 'mutated before failure\n' >> "$target/README.md"
fi
echo "failed after mutation" >&2
exit 9
"#,
    );
    #[cfg(unix)]
    {
        let mut permissions = fs::metadata(path).unwrap().permissions();
        permissions.set_mode(0o755);
        fs::set_permissions(path, permissions).unwrap();
    }
}

fn write_hanging_agent_binary(path: &Path) {
    write_file(
        path,
        r#"#!/usr/bin/env bash
set -euo pipefail
cat >/dev/null
echo "hanging fake executor started"
trap '' TERM
while true; do
  sleep 60
done
"#,
    );
    #[cfg(unix)]
    {
        let mut permissions = fs::metadata(path).unwrap().permissions();
        permissions.set_mode(0o755);
        fs::set_permissions(path, permissions).unwrap();
    }
}

fn write_descendant_hanging_agent_binary(path: &Path, marker: &Path) {
    write_file(
        path,
        &format!(
            r#"#!/usr/bin/env bash
set -euo pipefail
cat >/dev/null
echo "descendant fake executor started"
(
  trap '' TERM
  sleep 4
  printf survived > "{}"
  while true; do
    sleep 60
  done
) &
wait
"#,
            marker.display()
        ),
    );
    #[cfg(unix)]
    {
        let mut permissions = fs::metadata(path).unwrap().permissions();
        permissions.set_mode(0o755);
        fs::set_permissions(path, permissions).unwrap();
    }
}

fn write_fake_prompt_catalog(root: &Path) {
    let asset_rel = ".octon/generated/effective/extensions/published/test-extension/bundled/prompts/fake/stages/01.md";
    write_file(
        &root.join(".octon/generated/effective/extensions/catalog.effective.yml"),
        &format!(
            r#"schema_version: "octon-extension-effective-catalog-v7"
packs:
  - pack_id: "test-extension"
    source_id: "bundled"
    capability_profiles:
      - "validation-surface"
      - "prompt-bundle"
    prompt_bundles:
      - prompt_set_id: "test-extension-fake-route"
        prompt_assets:
          - projection_source_path: "{asset_rel}"
"#
        ),
    );
    write_file(
        &root.join(asset_rel),
        "Write support/executable-implementation-prompt.md for {{target}}.\n",
    );
}

fn write_prompt_catalog(root: &Path, body: &str) {
    write_file(
        &root.join(".octon/generated/effective/extensions/catalog.effective.yml"),
        body,
    );
}

fn request(
    root: &Path,
    route_id: &str,
    route_type: &str,
    policy: &str,
) -> LifecycleRouteExecutionRequest {
    let target = root.join("packet");
    write_file(&target.join("proposal.yml"), "status: draft\n");
    write_file(&target.join("README.md"), "# Mock Packet\n");
    LifecycleRouteExecutionRequest {
        schema_version: "octon-lifecycle-route-execution-request-v1".to_string(),
        run_id: "test-run".to_string(),
        lifecycle_id: "proposal-packet".to_string(),
        owner_extension: "test-extension".to_string(),
        target,
        manifest_path: "proposal.yml".to_string(),
        status_field: "status".to_string(),
        executor: "mock".to_string(),
        route: LifecycleRouteSpec {
            route_id: route_id.to_string(),
            route_type: route_type.to_string(),
            command_id: None,
            skill_id: None,
            prompt_set_id: None,
            required_inputs: Vec::new(),
            completion_replan_required: true,
            approval_required_by_default: false,
            approval_reason: None,
        },
        effective_extension_catalog: root
            .join(".octon/generated/effective/extensions/catalog.effective.yml"),
        runtime_route_bundle: root.join(".octon/generated/effective/runtime/route-bundle.yml"),
        bound_inputs: default_bound_inputs(Path::new("packet")),
        receipts: vec![LifecycleReceiptSpec {
            receipt_id: "proposal-review".to_string(),
            path: "support/proposal-review.md".to_string(),
            required_fields: vec![
                "review_id".to_string(),
                "reviewed_at".to_string(),
                "reviewer".to_string(),
                "verdict".to_string(),
                "implementation_prompt_authorized".to_string(),
                "reviewed_packet_digest".to_string(),
                "open_blocking_findings_count".to_string(),
            ],
            verdict_field: Some("verdict".to_string()),
        }],
        expected_receipts: vec!["proposal-review".to_string()],
        expected_paths: Vec::new(),
        expected_manifest_status: None,
        expected_target_change: false,
        evidence_root: root.join(".octon/state/evidence/runs/workflows/test-run"),
        checkpoint_path: root
            .join(".octon/state/control/execution/runs/test-run/lifecycle-checkpoint.yml"),
        policy: LifecycleExecutionPolicy {
            timeout_seconds: 30,
            cancellation_token: None,
            retry_attempt: 0,
            approval_policy: policy.to_string(),
        },
        approval_context: None,
    }
}

#[test]
fn approval_pause_writes_program_child_guidance_when_present() {
    let root = temp_root("program-child-approval-guidance");
    let executor = DefaultLifecycleRouteExecutor::new(&root);
    let mut request = request(&root, "review-proposal", "agent", "minimize");
    request.route.approval_required_by_default = true;
    request.approval_context = Some(LifecycleApprovalContext {
        context_kind: "program-child-route".to_string(),
        program_run_id: Some("program-run".to_string()),
        child_id: Some("child-a".to_string()),
        approval_instruction: Some(
            "octon lifecycle program approve --run-id program-run --child child-a --route review-proposal --reason <reason>".to_string(),
        ),
        retry_instruction: Some(
            "octon lifecycle program retry --run-id program-run --child child-a".to_string(),
        ),
        unattended_override_instruction: Some(
            "octon lifecycle run --lifecycle proposal-packet --target packet --run-id child-run --execute-routes --approval-policy unattended".to_string(),
        ),
    });

    let result = executor.execute_route(request.clone()).unwrap();

    assert_eq!(result.status, "approval-required");
    let approval = fs::read_to_string(request.evidence_root.join("approval-required.yml")).unwrap();
    assert!(approval.contains("context_kind: program-child-route"));
    assert!(approval.contains("program_run_id: program-run"));
    assert!(approval.contains("child_id: child-a"));
    assert!(approval.contains("octon lifecycle program approve --run-id program-run --child child-a --route review-proposal"));
    assert!(approval.contains("octon lifecycle program retry --run-id program-run --child child-a"));
}

#[test]
fn cancellation_token_returns_cancelled_before_executor_dispatch() {
    let root = temp_root("cancellation-token");
    let executor = DefaultLifecycleRouteExecutor::new(&root);
    let mut request = request(&root, "review-proposal", "agent", "unattended");
    let token = root.join(".octon/state/control/execution/runs/test-run/cancellation.yml");
    write_file(&token, "schema_version: octon-lifecycle-cancellation-v1\n");
    request.policy.cancellation_token = Some(token.clone());

    let result = executor.execute_route(request.clone()).unwrap();

    assert_eq!(result.status, "cancelled");
    assert_eq!(
        result.error_class,
        Some(octon_lifecycle_executor::LifecycleErrorClass::Cancelled)
    );
    let cancelled =
        fs::read_to_string(request.evidence_root.join("review-proposal-cancelled.yml")).unwrap();
    assert!(cancelled.contains(&token.display().to_string()));
}

#[test]
fn real_executor_modes_invoke_prompt_bundle_through_adapter_boundary() {
    let _guard = env_lock().lock().unwrap();
    let root = temp_root("fake-agent");
    let bin_dir = root.join("bin");
    fs::create_dir_all(&bin_dir).unwrap();
    write_fake_agent_binary(&bin_dir.join("codex"), "codex");
    write_fake_agent_binary(&bin_dir.join("claude"), "claude");
    let _path_guard = prepend_path(&bin_dir);

    for (mode, expected_executor) in [("codex", "codex"), ("claude", "claude"), ("auto", "codex")] {
        let case_root = temp_root(&format!("fake-agent-{mode}"));
        write_fake_prompt_catalog(&case_root);
        let executor = DefaultLifecycleRouteExecutor::new(&case_root);
        let mut request = request(
            &case_root,
            "generate-packet-implementation-prompt",
            "extension",
            "unattended",
        );
        request.executor = mode.to_string();
        request.route.prompt_set_id = Some("test-extension-fake-route".to_string());
        request.expected_receipts = Vec::new();
        request.expected_paths = vec!["support/executable-implementation-prompt.md".to_string()];

        let result = executor.execute_route(request).unwrap();
        assert_eq!(result.status, "completed");
        assert_eq!(result.executor_used, expected_executor);
        assert!(result.prompt_packet_path.as_ref().unwrap().is_file());
        assert!(
            result
                .evidence_paths
                .iter()
                .any(|path| path
                    .ends_with("generate-packet-implementation-prompt-executor-start.yml"))
        );
        assert!(result
            .evidence_paths
            .iter()
            .any(|path| path
                .ends_with("generate-packet-implementation-prompt-executor-terminal.yml")));
        let prompt = fs::read_to_string(result.prompt_packet_path.as_ref().unwrap()).unwrap();
        assert!(prompt.contains("## Bound Inputs"));
        assert!(prompt.contains("- `proposal_path`: `packet`"));
        assert!(case_root
            .join("packet/support/executable-implementation-prompt.md")
            .is_file());
    }
}

#[test]
fn real_executor_timeout_writes_logs_and_route_result() {
    let _guard = env_lock().lock().unwrap();
    let root = temp_root("timeout-agent");
    let bin_dir = root.join("bin");
    fs::create_dir_all(&bin_dir).unwrap();
    write_hanging_agent_binary(&bin_dir.join("codex"));
    let _path_guard = prepend_path(&bin_dir);
    write_fake_prompt_catalog(&root);
    let executor = DefaultLifecycleRouteExecutor::new(&root);
    let mut request = request(
        &root,
        "generate-packet-implementation-prompt",
        "extension",
        "unattended",
    );
    request.executor = "codex".to_string();
    request.route.prompt_set_id = Some("test-extension-fake-route".to_string());
    request.expected_receipts = Vec::new();
    request.expected_paths = vec!["support/executable-implementation-prompt.md".to_string()];
    request.policy.timeout_seconds = 1;

    let started = Instant::now();
    let result = executor.execute_route(request.clone()).unwrap();

    assert!(
        started.elapsed() < Duration::from_secs(8),
        "timeout route should return promptly"
    );
    assert_eq!(result.status, "timed-out");
    assert_eq!(
        result.error_class,
        Some(octon_lifecycle_executor::LifecycleErrorClass::Timeout)
    );
    assert!(request
        .evidence_root
        .join("generate-packet-implementation-prompt-stdout.log")
        .is_file());
    assert!(request
        .evidence_root
        .join("generate-packet-implementation-prompt-stderr.log")
        .is_file());
    assert!(request
        .evidence_root
        .join("generate-packet-implementation-prompt-route-execution.yml")
        .is_file());
    let terminal = fs::read_to_string(
        request
            .evidence_root
            .join("generate-packet-implementation-prompt-executor-terminal.yml"),
    )
    .unwrap();
    assert!(terminal.contains("state: timed-out"));
}

#[test]
fn real_executor_cancellation_during_dispatch_writes_cancelled_result() {
    let _guard = env_lock().lock().unwrap();
    let root = temp_root("running-cancel-agent");
    let bin_dir = root.join("bin");
    fs::create_dir_all(&bin_dir).unwrap();
    write_hanging_agent_binary(&bin_dir.join("codex"));
    let _path_guard = prepend_path(&bin_dir);
    write_fake_prompt_catalog(&root);
    let mut request = request(
        &root,
        "generate-packet-implementation-prompt",
        "extension",
        "unattended",
    );
    request.executor = "codex".to_string();
    request.route.prompt_set_id = Some("test-extension-fake-route".to_string());
    request.expected_receipts = Vec::new();
    request.expected_paths = vec!["support/executable-implementation-prompt.md".to_string()];
    request.policy.timeout_seconds = 30;
    let token = root.join(".octon/state/control/execution/runs/test-run/cancellation.yml");
    request.policy.cancellation_token = Some(token.clone());
    let start_evidence = request
        .evidence_root
        .join("generate-packet-implementation-prompt-executor-start.yml");
    let route_evidence = request
        .evidence_root
        .join("generate-packet-implementation-prompt-route-execution.yml");
    let thread_root = root.clone();
    let handle = thread::spawn(move || {
        let executor = DefaultLifecycleRouteExecutor::new(&thread_root);
        executor.execute_route(request).unwrap()
    });
    for _ in 0..100 {
        if start_evidence.is_file() {
            break;
        }
        thread::sleep(Duration::from_millis(50));
    }
    assert!(start_evidence.is_file(), "executor should have started");
    write_file(&token, "schema_version: octon-lifecycle-cancellation-v1\n");

    let result = handle.join().unwrap();

    assert_eq!(result.status, "cancelled");
    assert_eq!(
        result.error_class,
        Some(octon_lifecycle_executor::LifecycleErrorClass::Cancelled)
    );
    assert!(route_evidence.is_file());
}

#[test]
fn timeout_terminates_descendant_process_group() {
    let _guard = env_lock().lock().unwrap();
    let root = temp_root("descendant-timeout-agent");
    let bin_dir = root.join("bin");
    fs::create_dir_all(&bin_dir).unwrap();
    let marker = root.join("descendant-survived");
    write_descendant_hanging_agent_binary(&bin_dir.join("codex"), &marker);
    let _path_guard = prepend_path(&bin_dir);
    write_fake_prompt_catalog(&root);
    let executor = DefaultLifecycleRouteExecutor::new(&root);
    let mut request = request(
        &root,
        "generate-packet-implementation-prompt",
        "extension",
        "unattended",
    );
    request.executor = "codex".to_string();
    request.route.prompt_set_id = Some("test-extension-fake-route".to_string());
    request.expected_receipts = Vec::new();
    request.expected_paths = vec!["support/executable-implementation-prompt.md".to_string()];
    request.policy.timeout_seconds = 1;

    let result = executor.execute_route(request).unwrap();
    thread::sleep(Duration::from_secs(2));

    assert_eq!(result.status, "timed-out");
    assert!(
        !marker.exists(),
        "descendant process should be terminated with the executor process group"
    );
}

#[test]
fn prompt_bundle_resolution_is_scoped_to_owner_extension() {
    let root = temp_root("owner-scoped-prompt");
    let other_asset =
        ".octon/generated/effective/extensions/published/other-extension/bundled/prompts/fake.md";
    let owner_asset =
        ".octon/generated/effective/extensions/published/test-extension/bundled/prompts/fake.md";
    write_prompt_catalog(
        &root,
        &format!(
            r#"schema_version: "octon-extension-effective-catalog-v7"
packs:
  - pack_id: "other-extension"
    source_id: "bundled"
    capability_profiles:
      - "validation-surface"
      - "prompt-bundle"
    prompt_bundles:
      - prompt_set_id: "duplicate-route"
        prompt_assets:
          - projection_source_path: "{other_asset}"
  - pack_id: "test-extension"
    source_id: "bundled"
    capability_profiles:
      - "validation-surface"
      - "prompt-bundle"
    prompt_bundles:
      - prompt_set_id: "duplicate-route"
        prompt_assets:
          - projection_source_path: "{owner_asset}"
"#
        ),
    );
    write_file(&root.join(other_asset), "wrong owner\n");
    write_file(&root.join(owner_asset), "right owner\n");

    let bundle = resolve_prompt_bundle(
        &root,
        &root.join(".octon/generated/effective/extensions/catalog.effective.yml"),
        "test-extension",
        "duplicate-route",
    )
    .unwrap();

    assert_eq!(bundle.assets.len(), 1);
    assert!(bundle.assets[0].content.contains("right owner"));

    let error = resolve_prompt_bundle(
        &root,
        &root.join(".octon/generated/effective/extensions/catalog.effective.yml"),
        "missing-extension",
        "duplicate-route",
    )
    .unwrap_err();
    assert_eq!(
        error.class,
        octon_lifecycle_executor::LifecycleErrorClass::Discovery
    );
}

#[test]
fn prompt_bundle_resolution_fails_closed_on_missing_projection_path() {
    let root = temp_root("missing-projection-source-path");
    write_prompt_catalog(
        &root,
        r#"schema_version: "octon-extension-effective-catalog-v7"
packs:
  - pack_id: "test-extension"
    source_id: "bundled"
    capability_profiles:
      - "validation-surface"
      - "prompt-bundle"
    prompt_bundles:
      - prompt_set_id: "bad-route"
        prompt_assets:
          - source_path: ".octon/inputs/additive/extensions/test-extension/prompts/bad.md"
"#,
    );

    let error = resolve_prompt_bundle(
        &root,
        &root.join(".octon/generated/effective/extensions/catalog.effective.yml"),
        "test-extension",
        "bad-route",
    )
    .unwrap_err();

    assert_eq!(
        error.class,
        octon_lifecycle_executor::LifecycleErrorClass::Discovery
    );
    assert!(error.message.contains("missing projection_source_path"));
}

#[test]
fn prompt_bundle_resolution_rejects_traversal_and_non_generated_assets() {
    for (name, raw) in [
        (
            "asset-traversal",
            ".octon/generated/effective/extensions/published/test-extension/../escape.md",
        ),
        (
            "asset-non-generated",
            ".octon/inputs/additive/extensions/test-extension/prompts/bad.md",
        ),
    ] {
        let root = temp_root(name);
        write_prompt_catalog(
            &root,
            &format!(
                r#"schema_version: "octon-extension-effective-catalog-v7"
packs:
  - pack_id: "test-extension"
    source_id: "bundled"
    capability_profiles:
      - "validation-surface"
      - "prompt-bundle"
    prompt_bundles:
      - prompt_set_id: "bad-route"
        prompt_assets:
          - projection_source_path: "{raw}"
"#
            ),
        );

        let error = resolve_prompt_bundle(
            &root,
            &root.join(".octon/generated/effective/extensions/catalog.effective.yml"),
            "test-extension",
            "bad-route",
        )
        .unwrap_err();

        assert_eq!(
            error.class,
            octon_lifecycle_executor::LifecycleErrorClass::Discovery
        );
        assert!(error
            .message
            .contains("outside required generated/runtime root"));
    }
}

#[test]
fn prompt_bundle_resolution_requires_generated_effective_catalog_path() {
    let root = temp_root("non-generated-catalog-path");
    let asset_rel =
        ".octon/generated/effective/extensions/published/test-extension/bundled/prompts/fake.md";
    let catalog = format!(
        r#"schema_version: "octon-extension-effective-catalog-v7"
packs:
  - pack_id: "test-extension"
    source_id: "bundled"
    capability_profiles:
      - "validation-surface"
      - "prompt-bundle"
    prompt_bundles:
      - prompt_set_id: "fake-route"
        prompt_assets:
          - projection_source_path: "{asset_rel}"
"#
    );
    write_prompt_catalog(&root, &catalog);
    write_file(
        &root.join(".octon/inputs/additive/extensions/test-extension/catalog.yml"),
        &catalog,
    );
    write_file(&root.join(asset_rel), "fake\n");

    let error = resolve_prompt_bundle(
        &root,
        &root.join(".octon/inputs/additive/extensions/test-extension/catalog.yml"),
        "test-extension",
        "fake-route",
    )
    .unwrap_err();

    assert_eq!(
        error.class,
        octon_lifecycle_executor::LifecycleErrorClass::Discovery
    );
    assert!(error
        .message
        .contains("must be resolved from generated effective projection"));
}

#[test]
fn mock_executor_writes_structured_result_and_receipt_observation() {
    let root = temp_root("mock");
    let executor = DefaultLifecycleRouteExecutor::new(&root);
    let result = executor
        .execute_route(request(&root, "review-packet", "extension", "unattended"))
        .unwrap();
    assert_eq!(result.status, "completed");
    assert_eq!(result.executor_used, "mock");
    assert_eq!(result.receipts_observed[0].receipt_id, "proposal-review");
    assert!(result.receipts_observed[0].complete);
    assert!(root
        .join(".octon/state/evidence/runs/workflows/test-run/review-packet-route-execution.yml")
        .is_file());
}

#[test]
fn mock_executor_creates_draft_proposal_packet_from_bound_source() {
    let root = temp_root("mock-create");
    let executor = DefaultLifecycleRouteExecutor::new(&root);
    let mut request = request(&root, "create-packet", "extension", "unattended");
    fs::remove_dir_all(&request.target).unwrap();
    request.route.required_inputs = vec!["source".to_string()];
    request
        .bound_inputs
        .insert("source".to_string(), "mock source context".to_string());
    request
        .bound_inputs
        .insert("source_kind".to_string(), "requirements".to_string());
    request.receipts = vec![LifecycleReceiptSpec {
        receipt_id: "proposal-creation".to_string(),
        path: "support/proposal-creation.md".to_string(),
        required_fields: vec![
            "creation_id".to_string(),
            "created_at".to_string(),
            "creator".to_string(),
            "source_context_bound".to_string(),
            "packet_path".to_string(),
            "verdict".to_string(),
        ],
        verdict_field: Some("verdict".to_string()),
    }];
    request.expected_receipts = vec!["proposal-creation".to_string()];
    request.expected_paths = vec![
        "proposal.yml".to_string(),
        "README.md".to_string(),
        "navigation/artifact-catalog.md".to_string(),
        "navigation/source-of-truth-map.md".to_string(),
        "resources/source-context.md".to_string(),
        "support/implementation-grade-completeness-review.md".to_string(),
    ];
    request.expected_manifest_status = Some("draft".to_string());
    request.expected_target_change = true;

    let result = executor.execute_route(request).unwrap();
    assert_eq!(result.status, "completed");
    assert!(root.join("packet/proposal.yml").is_file());
    assert!(root.join("packet/support/proposal-creation.md").is_file());
    assert!(
        fs::read_to_string(root.join("packet/resources/source-context.md"))
            .unwrap()
            .contains("mock source context")
    );
}

#[test]
fn workflow_routes_pause_for_approval_by_default() {
    let root = temp_root("approval");
    let executor = DefaultLifecycleRouteExecutor::new(&root);
    let result = executor
        .execute_route(request(&root, "promote-proposal", "workflow", "minimize"))
        .unwrap();
    assert_eq!(result.status, "approval-required");
    assert_eq!(result.next_action, "resume-after-approval");
    assert!(root
        .join(".octon/state/evidence/runs/workflows/test-run/approval-required.yml")
        .is_file());
}

#[test]
fn unattended_approval_override_writes_explicit_evidence() {
    let root = temp_root("approval-override");
    let executor = DefaultLifecycleRouteExecutor::new(&root);
    let mut request = request(&root, "promote-proposal", "workflow", "unattended");
    request.expected_receipts = Vec::new();
    request.expected_manifest_status = Some("implemented".to_string());

    let result = executor.execute_route(request).unwrap();

    assert_eq!(result.status, "completed");
    let override_path = root.join(
        ".octon/state/evidence/runs/workflows/test-run/promote-proposal-approval-override.yml",
    );
    assert!(override_path.is_file());
    let content = fs::read_to_string(&override_path).unwrap();
    assert!(content.contains("override_class: operator-unattended-durable-route"));
    assert!(content.contains("authorization_source: cli-operator-override"));
    assert!(result
        .evidence_paths
        .iter()
        .any(|path| path.ends_with("promote-proposal-approval-override.yml")));
}

#[test]
fn missing_required_input_blocks_before_executor_dispatch() {
    let root = temp_root("missing-input");
    let executor = DefaultLifecycleRouteExecutor::new(&root);
    let mut request = request(&root, "create-packet", "extension", "unattended");
    fs::remove_dir_all(&request.target).unwrap();
    request.route.required_inputs = vec!["source".to_string()];
    request.expected_receipts = vec!["proposal-creation".to_string()];
    request.receipts = vec![LifecycleReceiptSpec {
        receipt_id: "proposal-creation".to_string(),
        path: "support/proposal-creation.md".to_string(),
        required_fields: vec![
            "creation_id".to_string(),
            "created_at".to_string(),
            "creator".to_string(),
            "source_context_bound".to_string(),
            "packet_path".to_string(),
            "verdict".to_string(),
        ],
        verdict_field: Some("verdict".to_string()),
    }];
    let result = executor.execute_route(request).unwrap();
    assert_eq!(result.status, "blocked");
    assert_eq!(
        result.error_class,
        Some(octon_lifecycle_executor::LifecycleErrorClass::InputBinding)
    );
    assert!(!root.join("packet/proposal.yml").exists());
}

#[test]
fn approval_metadata_pauses_extension_routes_by_default() {
    let root = temp_root("extension-approval");
    let executor = DefaultLifecycleRouteExecutor::new(&root);
    let mut request = request(&root, "run-packet-implementation", "extension", "minimize");
    request.route.approval_required_by_default = true;
    request.route.approval_reason = Some("durable implementation".to_string());
    let result = executor.execute_route(request).unwrap();
    assert_eq!(result.status, "approval-required");
    assert_eq!(
        result.error_message.as_deref(),
        Some("durable implementation")
    );
}

#[test]
fn extension_route_ids_do_not_force_approval_without_metadata() {
    let root = temp_root("extension-no-hardcoded-approval");
    let executor = DefaultLifecycleRouteExecutor::new(&root);
    let mut request = request(&root, "run-packet-implementation", "extension", "minimize");
    request.receipts = vec![LifecycleReceiptSpec {
        receipt_id: "implementation-run".to_string(),
        path: "support/implementation-run.md".to_string(),
        required_fields: vec![
            "verdict".to_string(),
            "implemented_at".to_string(),
            "promotion_evidence_count".to_string(),
        ],
        verdict_field: Some("verdict".to_string()),
    }];
    request.expected_receipts = vec!["implementation-run".to_string()];

    let result = executor.execute_route(request).unwrap();
    assert_eq!(result.status, "completed");
    assert_ne!(result.status, "approval-required");
}

#[test]
fn failed_real_executor_is_not_retryable_after_target_mutation() {
    let _guard = env_lock().lock().unwrap();
    let root = temp_root("failed-mutating-agent");
    let bin_dir = root.join("bin");
    fs::create_dir_all(&bin_dir).unwrap();
    write_failing_mutating_agent_binary(&bin_dir.join("codex"));
    let _path_guard = prepend_path(&bin_dir);
    write_fake_prompt_catalog(&root);
    let executor = DefaultLifecycleRouteExecutor::new(&root);
    let mut request = request(
        &root,
        "generate-packet-implementation-prompt",
        "extension",
        "unattended",
    );
    request.executor = "codex".to_string();
    request.route.prompt_set_id = Some("test-extension-fake-route".to_string());
    request.expected_receipts = Vec::new();
    request.expected_paths = vec!["support/executable-implementation-prompt.md".to_string()];

    let result = executor.execute_route(request).unwrap();
    assert_eq!(result.status, "failed");
    assert_eq!(
        result.error_class,
        Some(octon_lifecycle_executor::LifecycleErrorClass::ExecutorFailed)
    );
    assert!(!result.retryable);
}

#[test]
fn unrelated_receipts_do_not_satisfy_route_completion() {
    let root = temp_root("unrelated-receipt");
    let executor = DefaultLifecycleRouteExecutor::new(&root);
    let mut request = request(&root, "unknown-route", "extension", "unattended");
    request.expected_receipts = Vec::new();
    write_file(
        &request.target.join("support/proposal-review.md"),
        "review_id: review-1\nreviewed_at: 2026-05-07T00:00:00Z\nreviewer: test\nverdict: accepted\nimplementation_prompt_authorized: yes\nreviewed_packet_digest: sha256:test\nopen_blocking_findings_count: 0\n",
    );
    let result = executor.execute_route(request).unwrap();
    assert_eq!(result.status, "failed");
    assert_eq!(
        result.error_class,
        Some(octon_lifecycle_executor::LifecycleErrorClass::CompletionNotObserved)
    );
}

#[test]
fn adapter_rejects_unsafe_manifest_receipt_and_completion_paths_before_execution() {
    for (name, mutate) in [
        (
            "unsafe-manifest-path",
            Box::new(|request: &mut LifecycleRouteExecutionRequest| {
                request.manifest_path = "../outside.yml".to_string();
            }) as Box<dyn Fn(&mut LifecycleRouteExecutionRequest)>,
        ),
        (
            "unsafe-receipt-path",
            Box::new(|request: &mut LifecycleRouteExecutionRequest| {
                request.receipts[0].path = "/tmp/outside-receipt.md".to_string();
            }),
        ),
        (
            "unsafe-completion-path",
            Box::new(|request: &mut LifecycleRouteExecutionRequest| {
                request.expected_paths = vec!["../outside-completion.md".to_string()];
            }),
        ),
    ] {
        let root = temp_root(name);
        let executor = DefaultLifecycleRouteExecutor::new(&root);
        let mut request = request(&root, "review-packet", "extension", "unattended");
        mutate(&mut request);

        let result = executor.execute_route(request).unwrap();

        assert_eq!(result.status, "failed");
        assert_eq!(
            result.error_class,
            Some(octon_lifecycle_executor::LifecycleErrorClass::ReceiptInvalid)
        );
        assert!(!root.join("packet/support/proposal-review.md").exists());
    }
}

#[cfg(unix)]
#[test]
fn adapter_rejects_symlink_escape_for_expected_paths_before_execution() {
    let root = temp_root("unsafe-completion-symlink");
    let outside = temp_root("unsafe-completion-symlink-outside");
    let executor = DefaultLifecycleRouteExecutor::new(&root);
    let mut request = request(&root, "review-packet", "extension", "unattended");
    symlink(&outside, request.target.join("outside-link")).unwrap();
    request.expected_receipts = Vec::new();
    request.expected_paths = vec!["outside-link".to_string()];

    let result = executor.execute_route(request).unwrap();

    assert_eq!(result.status, "failed");
    assert_eq!(
        result.error_class,
        Some(octon_lifecycle_executor::LifecycleErrorClass::ReceiptInvalid)
    );
    assert!(result
        .error_message
        .as_deref()
        .unwrap_or_default()
        .contains("escapes target root"));
}

#[test]
fn route_specific_target_change_can_satisfy_completion() {
    let root = temp_root("target-change");
    let executor = DefaultLifecycleRouteExecutor::new(&root);
    let mut request = request(&root, "revise-packet", "extension", "unattended");
    request.expected_receipts = Vec::new();
    request.expected_paths = vec!["support/revisions".to_string()];
    request.expected_target_change = true;
    let target = request.target.clone();
    let result = executor.execute_route(request).unwrap();
    assert_eq!(result.status, "completed");
    assert!(target
        .join("support/revisions/mock-revision-1.md")
        .is_file());
}

#[test]
fn executor_errors_are_recorded_as_structured_failed_results() {
    let root = temp_root("unsupported");
    let executor = DefaultLifecycleRouteExecutor::new(&root);
    let mut request = request(&root, "review-packet", "extension", "unattended");
    request.executor = "unsupported".to_string();
    let result = executor.execute_route(request).unwrap();
    assert_eq!(result.status, "failed");
    assert_eq!(
        result.error_class,
        Some(octon_lifecycle_executor::LifecycleErrorClass::ExecutorUnavailable)
    );
    assert!(root
        .join(".octon/state/evidence/runs/workflows/test-run/review-packet-error.yml")
        .is_file());
    assert!(root
        .join(".octon/state/evidence/runs/workflows/test-run/review-packet-route-execution.yml")
        .is_file());
}

#[test]
fn workflow_manifest_resolves_through_generated_route_bundle_source_ref() {
    let root = temp_root("workflow-source-ref");
    write_file(
        &root.join(".octon/generated/effective/runtime/route-bundle.yml"),
        "schema_version: octon-runtime-effective-route-bundle-v1\nsource_refs:\n  workflow_manifest_ref: \".octon/framework/orchestration/runtime/workflows/manifest.yml\"\nroutes: []\nextensions:\n  generation_id: test\n  status: published\n  quarantine_count: 0\n",
    );
    write_file(
        &root.join(".octon/framework/orchestration/runtime/workflows/manifest.yml"),
        "workflows:\n  - id: promote-proposal\n    path: meta/promote-proposal/\n",
    );
    write_file(
        &root.join(
            ".octon/framework/orchestration/runtime/workflows/meta/promote-proposal/workflow.yml",
        ),
        "name: promote-proposal\n",
    );

    let resolved = resolve_workflow_manifest(
        &root,
        &root.join(".octon/generated/effective/runtime/route-bundle.yml"),
        "promote-proposal",
    )
    .unwrap();
    assert!(resolved.ends_with("meta/promote-proposal/workflow.yml"));
}

#[test]
fn workflow_manifest_resolution_requires_generated_route_bundle_reference() {
    let root = temp_root("workflow-missing-source-ref");
    write_file(
        &root.join(".octon/generated/effective/runtime/route-bundle.yml"),
        "schema_version: octon-runtime-effective-route-bundle-v1\nsource_refs: {}\nroutes: []\nextensions:\n  generation_id: test\n  status: published\n  quarantine_count: 0\n",
    );

    let error = resolve_workflow_manifest(
        &root,
        &root.join(".octon/generated/effective/runtime/route-bundle.yml"),
        "promote-proposal",
    )
    .unwrap_err();
    assert_eq!(
        error.class,
        octon_lifecycle_executor::LifecycleErrorClass::Discovery
    );
}

#[test]
fn workflow_manifest_resolution_rejects_traversal_source_ref() {
    let root = temp_root("workflow-traversal-source-ref");
    write_file(
        &root.join(".octon/generated/effective/runtime/route-bundle.yml"),
        "schema_version: octon-runtime-effective-route-bundle-v1\nsource_refs:\n  workflow_manifest_ref: \".octon/framework/orchestration/runtime/workflows/../manifest.yml\"\nroutes: []\nextensions:\n  generation_id: test\n  status: published\n  quarantine_count: 0\n",
    );

    let error = resolve_workflow_manifest(
        &root,
        &root.join(".octon/generated/effective/runtime/route-bundle.yml"),
        "promote-proposal",
    )
    .unwrap_err();

    assert_eq!(
        error.class,
        octon_lifecycle_executor::LifecycleErrorClass::Discovery
    );
    assert!(error
        .message
        .contains("outside required generated/runtime root"));
}

#[test]
fn workflow_manifest_resolution_rejects_non_runtime_source_ref() {
    let root = temp_root("workflow-non-runtime-source-ref");
    write_file(
        &root.join(".octon/generated/effective/runtime/route-bundle.yml"),
        "schema_version: octon-runtime-effective-route-bundle-v1\nsource_refs:\n  workflow_manifest_ref: \".octon/inputs/additive/extensions/test/workflows/manifest.yml\"\nroutes: []\nextensions:\n  generation_id: test\n  status: published\n  quarantine_count: 0\n",
    );

    let error = resolve_workflow_manifest(
        &root,
        &root.join(".octon/generated/effective/runtime/route-bundle.yml"),
        "promote-proposal",
    )
    .unwrap_err();

    assert_eq!(
        error.class,
        octon_lifecycle_executor::LifecycleErrorClass::Discovery
    );
    assert!(error
        .message
        .contains("outside required generated/runtime root"));
}

#[test]
fn workflow_manifest_resolution_requires_generated_runtime_route_bundle_path() {
    let root = temp_root("non-generated-route-bundle");
    let route_bundle = "schema_version: octon-runtime-effective-route-bundle-v1\nsource_refs:\n  workflow_manifest_ref: \".octon/framework/orchestration/runtime/workflows/manifest.yml\"\nroutes: []\nextensions:\n  generation_id: test\n  status: published\n  quarantine_count: 0\n";
    write_file(
        &root.join(".octon/generated/effective/runtime/route-bundle.yml"),
        route_bundle,
    );
    write_file(
        &root.join(".octon/inputs/additive/extensions/test/route-bundle.yml"),
        route_bundle,
    );
    write_file(
        &root.join(".octon/framework/orchestration/runtime/workflows/manifest.yml"),
        "workflows: []\n",
    );

    let error = resolve_workflow_manifest(
        &root,
        &root.join(".octon/inputs/additive/extensions/test/route-bundle.yml"),
        "promote-proposal",
    )
    .unwrap_err();

    assert_eq!(
        error.class,
        octon_lifecycle_executor::LifecycleErrorClass::Discovery
    );
    assert!(error
        .message
        .contains("must be resolved from generated effective projection"));
}

#[test]
fn workflow_manifest_resolution_rejects_traversal_workflow_path() {
    let root = temp_root("workflow-path-traversal");
    write_file(
        &root.join(".octon/generated/effective/runtime/route-bundle.yml"),
        "schema_version: octon-runtime-effective-route-bundle-v1\nsource_refs:\n  workflow_manifest_ref: \".octon/framework/orchestration/runtime/workflows/manifest.yml\"\nroutes: []\nextensions:\n  generation_id: test\n  status: published\n  quarantine_count: 0\n",
    );
    write_file(
        &root.join(".octon/framework/orchestration/runtime/workflows/manifest.yml"),
        "workflows:\n  - id: promote-proposal\n    path: ../escape\n",
    );

    let error = resolve_workflow_manifest(
        &root,
        &root.join(".octon/generated/effective/runtime/route-bundle.yml"),
        "promote-proposal",
    )
    .unwrap_err();

    assert_eq!(
        error.class,
        octon_lifecycle_executor::LifecycleErrorClass::Discovery
    );
    assert!(error.message.contains("without traversal"));
}
