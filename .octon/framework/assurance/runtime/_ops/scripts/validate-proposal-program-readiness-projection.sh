#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
ROOT_DIR="${OCTON_ROOT_DIR:-$DEFAULT_ROOT}"
PROGRAM_PATH=""
PROJECTION_PATH=""
TERMINAL_REQUIRED=0

usage() {
  cat <<'EOF'
usage:
  validate-proposal-program-readiness-projection.sh --package <program-packet-path> [--projection <projection.yml|json>] [--require-terminal-evidence] [--root <repo-root>]

Validates a proposal-program readiness projection as read-only diagnostic
evidence. The projection never authorizes dispatch, child gates, closeout,
archive, implementation, correction, or generated-state authority.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package)
      PROGRAM_PATH="${2:-}"
      shift 2
      ;;
    --projection)
      PROJECTION_PATH="${2:-}"
      shift 2
      ;;
    --require-terminal-evidence)
      TERMINAL_REQUIRED=1
      shift
      ;;
    --root)
      ROOT_DIR="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$PROGRAM_PATH" ]]; then
  echo "[ERROR] missing --package" >&2
  usage >&2
  exit 2
fi

python3 - "$ROOT_DIR" "$PROGRAM_PATH" "$PROJECTION_PATH" "$TERMINAL_REQUIRED" <<'PY'
import hashlib
import json
import pathlib
import re
import subprocess
import sys

root = pathlib.Path(sys.argv[1]).resolve()
program_arg = pathlib.Path(sys.argv[2])
projection_arg = sys.argv[3]
terminal_required = sys.argv[4] == "1"
program_dir = program_arg if program_arg.is_absolute() else root / program_arg
projection_path = None
if projection_arg:
    raw_projection = pathlib.Path(projection_arg)
    projection_path = raw_projection if raw_projection.is_absolute() else root / raw_projection

errors = []
warnings = []
SHA_RE = re.compile(r"^sha256:[0-9a-f]{64}$")
SAFE_REL_RE = re.compile(r"^[A-Za-z0-9._/@+-][A-Za-z0-9._/@+\-]*$")


def ok(message):
    print(f"[OK] {message}")


def warn(message):
    warnings.append(message)
    print(f"[WARN] {message}")


def fail(message):
    errors.append(message)
    print(f"[ERROR] {message}")


def run(command):
    return subprocess.run(command, cwd=root, text=True, capture_output=True, check=False)


def load_data(path):
    result = run(["yq", "-o=json", ".", str(path)])
    if result.returncode != 0:
        fail(f"cannot parse YAML/JSON: {repo_rel(path)}: {result.stderr.strip()}")
        return {}
    try:
        return json.loads(result.stdout or "{}")
    except json.JSONDecodeError as exc:
        fail(f"cannot decode YAML/JSON: {repo_rel(path)}: {exc}")
        return {}


def repo_rel(path):
    path = pathlib.Path(path)
    try:
        return str(path.resolve().relative_to(root))
    except ValueError:
        return str(path)


def safe_rel_path(value):
    if not value or value.startswith("/") or value.startswith("./") or value.startswith("../"):
        return False
    if value in {".", ".."} or "/../" in value or value.endswith("/..") or "/./" in value or value.endswith("/."):
        return False
    return bool(SAFE_REL_RE.match(value))


def resolve_ref(ref):
    return pathlib.Path(ref) if pathlib.Path(ref).is_absolute() else root / ref


def archived_packet_ref(ref):
    parts = pathlib.PurePosixPath(ref).parts
    needle = (".octon", "inputs", "exploratory", "proposals")
    for index in range(0, len(parts) - len(needle) + 1):
        if parts[index:index + len(needle)] != needle:
            continue
        after = index + len(needle)
        if after >= len(parts) or parts[after] == ".archive":
            return ""
        if after + 1 >= len(parts):
            return ""
        archived = (
            list(parts[:after])
            + [".archive", parts[after]]
            + list(parts[after + 1:])
        )
        return "/".join(archived)
    return ""


def resolve_packet_ref(ref):
    packet_dir = resolve_ref(ref)
    if (packet_dir / "proposal.yml").is_file():
        return packet_dir, ref
    archived_ref = archived_packet_ref(ref)
    if archived_ref:
        archived_dir = resolve_ref(archived_ref)
        if (archived_dir / "proposal.yml").is_file():
            return archived_dir, archived_ref
    return packet_dir, ref


def field_from_markdown(path, field):
    if not path.is_file():
        return ""
    pattern = re.compile(rf"^[\s-]*{re.escape(field)}\s*:\s*(.+?)\s*$", re.IGNORECASE)
    for line in path.read_text(errors="replace").splitlines():
        match = pattern.match(line)
        if match:
            return match.group(1).strip().strip("`").strip('"')
    return ""


def receipt_field(path, field):
    return field_from_markdown(path, field)


def require_receipt_pass(path, label):
    if not path.is_file():
        fail(f"{label} missing: {repo_rel(path)}")
        return
    verdict = receipt_field(path, "verdict")
    if verdict == "pass":
        ok(f"{label} passes")
    else:
        fail(f"{label} verdict must be pass: {repo_rel(path)}")


def validation_receipt_records_pass(path):
    if not path.is_file():
        return False
    if receipt_field(path, "verdict") == "pass":
        return True

    text = path.read_text(errors="replace")
    if re.search(r"All listed commands exited successfully\.?", text, re.IGNORECASE):
        return True

    table_rows = [
        line
        for line in text.splitlines()
        if re.match(r"^\|\s*`[^`]+`\s*\|\s*[^|]+\s*\|", line)
    ]
    if not table_rows:
        return False

    saw_pass = False
    for row in table_rows:
        cells = [cell.strip().lower() for cell in row.strip().strip("|").split("|")]
        if any(cell in {"fail", "failed", "error", "blocked"} for cell in cells):
            return False
        if any(cell == "pass" for cell in cells):
            saw_pass = True
    return saw_pass


def require_validation_receipt_pass(path, label):
    if not path.is_file():
        fail(f"{label} missing: {repo_rel(path)}")
        return
    if validation_receipt_records_pass(path):
        ok(f"{label} passes")
    else:
        fail(f"{label} must record pass: {repo_rel(path)}")


def require_receipt_value(path, label, field, expected):
    if not path.is_file():
        fail(f"{label} missing: {repo_rel(path)}")
        return
    actual = receipt_field(path, field)
    if actual == expected:
        ok(f"{label} {field}={expected}")
    else:
        fail(f"{label} {field} must be {expected}: {repo_rel(path)}")


def proposal_review_digest(path):
    result = run([
        "bash",
        ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh",
        "--package",
        repo_rel(path),
        "--print-digest",
    ])
    if result.returncode != 0:
        fail(f"cannot compute review digest for {repo_rel(path)}: {result.stderr.strip() or result.stdout.strip()}")
        return ""
    return result.stdout.strip().splitlines()[-1]


def run_gate(label, command):
    result = run(command)
    if result.returncode == 0:
        ok(label)
    else:
        fail(f"{label} failed")
        output = (result.stdout + result.stderr).strip()
        if output:
            for line in output.splitlines()[:20]:
                print(line)


def validate_projection_file():
    if projection_path is None:
        warn("no materialized projection file supplied; validating live sources only")
        return
    if not projection_path.is_file():
        fail(f"projection file missing: {repo_rel(projection_path)}")
        return
    data = load_data(projection_path)
    boundary = data.get("authority_boundary") or {}
    expected_false = [
        "authorizes_dispatch",
        "satisfies_child_gates",
        "authorizes_closeout",
        "authorizes_archive",
        "authorizes_correction",
        "authorizes_implementation",
        "authorizes_generated_publication",
        "replaces_source_evidence",
        "parent_summary_satisfies_child_receipts",
        "retained_evidence_authorizes_execution",
    ]
    for key in expected_false:
        if boundary.get(key) is False:
            ok(f"projection authority boundary {key}=false")
        else:
            fail(f"projection authority boundary {key} must be false")
    if boundary.get("diagnostic_only") is True:
        ok("projection is diagnostic only")
    else:
        fail("projection must declare diagnostic_only: true")
    if boundary.get("generated_output_authority") == "derived-only":
        ok("projection keeps generated output derived-only")
    else:
        fail("projection generated_output_authority must be derived-only")
    if boundary.get("proposal_input_authority") == "non-authoritative":
        ok("projection keeps proposal inputs non-authoritative")
    else:
        fail("projection proposal_input_authority must be non-authoritative")


def validate_publication_freshness(program):
    refs = program.get("readiness_projection") or {}
    publication_refs = refs.get("publication_freshness_refs") or []
    if terminal_required and not publication_refs and program.get("status") == "archived":
        archive = program.get("archive") or {}
        publication_refs = archive.get("promotion_evidence") or []
        if publication_refs:
            ok("archived program exposes archive promotion evidence refs")
    if not terminal_required and not publication_refs:
        warn("no publication freshness refs declared; terminal evidence not required")
        return
    if terminal_required and not publication_refs:
        fail("terminal readiness requires publication freshness refs")
        return
    for ref in publication_refs:
        if isinstance(ref, dict):
            path_ref = ref.get("ref") or ""
            digest = ref.get("sha256") or ""
        else:
            path_ref = str(ref)
            digest = ""
        if not safe_rel_path(path_ref):
            fail(f"publication freshness ref is unsafe: {path_ref}")
            continue
        path = resolve_ref(path_ref)
        if not path.is_file():
            fail(f"publication freshness ref missing: {path_ref}")
            continue
        if digest:
            actual = "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()
            if digest == actual:
                ok(f"publication freshness ref digest matches: {path_ref}")
            else:
                fail(f"publication freshness ref digest mismatch: {path_ref}")
        else:
            ok(f"publication freshness ref exists: {path_ref}")


def validate_evidence_index(ref):
    if not safe_rel_path(ref):
        fail(f"evidence index ref is unsafe: {ref}")
        return
    path = resolve_ref(ref)
    if not path.is_file():
        fail(f"evidence index missing: {ref}")
        return
    result = run([
        "bash",
        ".octon/framework/assurance/runtime/_ops/scripts/validate-retained-run-evidence-index.sh",
        "--root",
        str(root),
        "--index",
        ref,
    ])
    if result.returncode == 0:
        ok(f"evidence index validates: {ref}")
    else:
        fail(f"evidence index validation failed: {ref}")
        output = (result.stdout + result.stderr).strip()
        if output:
            for line in output.splitlines()[:20]:
                print(line)


def validate_program():
    if not program_dir.is_dir():
        fail(f"program packet missing: {repo_rel(program_dir)}")
        return
    manifest_path = program_dir / "proposal.yml"
    registry_path = program_dir / "resources/child-packet-index.yml"
    if manifest_path.is_file():
        ok("parent manifest exists")
    else:
        fail(f"parent manifest missing: {repo_rel(manifest_path)}")
        return
    if registry_path.is_file():
        ok("child registry exists")
    else:
        fail(f"child registry missing: {repo_rel(registry_path)}")
        return

    program = load_data(manifest_path)
    registry = load_data(registry_path)
    status = program.get("status")
    if status in {"accepted", "implemented", "archived"}:
        ok(f"parent status supports readiness projection: {status}")
    else:
        fail(f"parent status does not support readiness projection: {status}")

    parent_review_command = [
        "bash",
        ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh",
        "--package",
        repo_rel(program_dir),
    ]
    if status in {"accepted", "implemented"}:
        parent_review_command.append("--require-implementation-authorization")
    run_gate("parent proposal review gate", parent_review_command)
    children = registry.get("children") or []
    if children:
        ok("child registry includes children")
    else:
        fail("child registry must include children")

    child_status = {}
    child_required = {}
    child_deps = {}
    for child in children:
        child_id = child.get("child_id") or ""
        child_path_ref = child.get("path") or ""
        required = not bool(child.get("deferred", False))
        child_required[child_id] = required
        deps = []
        for pred in child.get("predecessor_constraints") or []:
            dep = pred.get("predecessor_child_id")
            if dep:
                deps.append(dep)
        child_deps[child_id] = deps
        if not re.match(r"^[a-z][a-z0-9-]*$", child_id):
            fail(f"child id invalid: {child_id}")
            continue
        if not safe_rel_path(child_path_ref):
            fail(f"child path unsafe for {child_id}: {child_path_ref}")
            continue
        child_dir, child_package_ref = resolve_packet_ref(child_path_ref)
        manifest = child_dir / "proposal.yml"
        if not manifest.is_file():
            fail(f"child manifest missing for {child_id}: {child_path_ref}/proposal.yml")
            continue
        if child_package_ref != child_path_ref:
            ok(f"child {child_id} resolved archived packet path: {child_package_ref}")
        child_manifest = load_data(manifest)
        status = child_manifest.get("status")
        child_status[child_id] = status
        if status in {"accepted", "implemented", "archived", "rejected"}:
            ok(f"child {child_id} status visible: {status}")
        else:
            fail(f"child {child_id} status is not projection-ready: {status}")

        run_gate(
            f"child {child_id} proposal standard gate",
            [
                "bash",
                ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh",
                "--package",
                child_package_ref,
                "--skip-registry-check",
            ],
        )

        child_review_command = [
            "bash",
            ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh",
            "--package",
            child_package_ref,
        ]
        if status == "accepted":
            child_review_command.append("--require-implementation-authorization")
        run_gate(f"child {child_id} review gate", child_review_command)
        readiness_receipt = child_dir / "support/implementation-grade-completeness-review.md"
        if readiness_receipt.is_file():
            ok(f"child {child_id} implementation-readiness receipt exists")
            if receipt_field(readiness_receipt, "verdict") == "pass":
                ok(f"child {child_id} implementation-readiness verdict passes")
            else:
                fail(f"child {child_id} implementation-readiness verdict must be pass")
            if receipt_field(readiness_receipt, "unresolved_questions_count") == "0":
                ok(f"child {child_id} implementation-readiness unresolved questions are zero")
            else:
                fail(f"child {child_id} implementation-readiness unresolved questions must be zero")
            if receipt_field(readiness_receipt, "clarification_required") == "no":
                ok(f"child {child_id} implementation-readiness clarification not required")
            else:
                fail(f"child {child_id} implementation-readiness clarification_required must be no")
        else:
            fail(f"child {child_id} implementation-readiness receipt missing")

        if status == "accepted":
            run_gate(
                f"child {child_id} implementation-readiness gate",
                [
                    "bash",
                    ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh",
                    "--package",
                    child_package_ref,
                ],
            )

        if status == "archived":
            ok(f"child {child_id} review digest preserved from pre-archive packet")
        else:
            recorded_digest = field_from_markdown(child_dir / "support/proposal-review.md", "reviewed_packet_digest")
            current_digest = proposal_review_digest(child_dir)
            if recorded_digest and current_digest and recorded_digest == current_digest:
                ok(f"child {child_id} review digest fresh")
            else:
                fail(f"child {child_id} review digest stale")

        if required and status in {"implemented", "archived"}:
            require_receipt_pass(child_dir / "support/implementation-run.md", f"child {child_id} implementation receipt")
            require_receipt_pass(child_dir / "support/implementation-conformance-review.md", f"child {child_id} conformance receipt")
            require_receipt_pass(child_dir / "support/post-implementation-drift-churn-review.md", f"child {child_id} drift receipt")
        if required and terminal_required and status in {"implemented", "archived"}:
            require_receipt_pass(child_dir / "support/proposal-closeout.md", f"child {child_id} closeout receipt")
        if required and status == "archived":
            archive = child_manifest.get("archive") or {}
            if archive.get("archived_from_status") == "implemented" and archive.get("disposition") == "implemented":
                ok(f"child {child_id} archive metadata implemented")
            else:
                fail(f"child {child_id} archive metadata must preserve implemented disposition")
            require_validation_receipt_pass(child_dir / "support/validation.md", f"child {child_id} validation receipt")
            require_receipt_value(
                child_dir / "support/proposal-terminal-closeout.yml",
                f"child {child_id} terminal closeout receipt",
                "terminal_verdict",
                "archive-ready",
            )
            require_receipt_value(
                child_dir / "support/proposal-terminal-closeout.yml",
                f"child {child_id} terminal closeout receipt",
                "archive_ready",
                "yes",
            )

        index_refs = child.get("evidence_index_refs") or []
        if required and (terminal_required or status in {"implemented", "archived"}):
            if index_refs:
                ok(f"child {child_id} declares evidence index refs")
            elif status == "archived":
                ok(f"child {child_id} archive packet retains terminal receipts without registry evidence index refs")
            else:
                fail(f"child {child_id} terminal readiness requires evidence index refs")
        for ref in index_refs:
            validate_evidence_index(str(ref))

        blocker_refs = child.get("blocker_refs") or []
        for ref in blocker_refs:
            if not safe_rel_path(str(ref)):
                fail(f"child {child_id} blocker ref unsafe: {ref}")
                continue
            blocker_path = resolve_ref(str(ref))
            if not blocker_path.is_file():
                fail(f"child {child_id} blocker ref missing: {ref}")
                continue
            text = blocker_path.read_text(errors="replace").lower()
            if "unresolved" in text or "blocked" in text:
                fail(f"child {child_id} blocker ref contains unresolved blocker: {ref}")
            else:
                ok(f"child {child_id} blocker ref clear: {ref}")

    for child_id, deps in child_deps.items():
        for dep in deps:
            if dep not in child_status:
                fail(f"child {child_id} dependency missing from registry: {dep}")
            elif child_required.get(dep, True) and child_status.get(dep) not in {"implemented", "archived", "rejected"}:
                fail(f"child {child_id} dependency not terminal: {dep}")
            else:
                ok(f"child {child_id} dependency resolved: {dep}")

    validate_publication_freshness(program)


validate_projection_file()
validate_program()

print(f"Validation summary: errors={len(errors)} warnings={len(warnings)}")
sys.exit(1 if errors else 0)
PY
