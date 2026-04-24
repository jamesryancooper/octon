#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

python3 - "$ROOT_DIR" <<'PY'
import re
import sys
from pathlib import Path

ROOT_DIR = Path(sys.argv[1]).resolve()
SCAN_ROOTS = [
    ROOT_DIR / ".octon/framework",
    ROOT_DIR / ".octon/instance",
    ROOT_DIR / ".octon/state",
    ROOT_DIR / ".octon/generated",
]

SELF_REF = ".octon/framework/assurance/runtime/_ops/scripts/validate-run-journal-append-boundary.sh"
ALLOWED_PREFIXES = (
    ".octon/framework/engine/runtime/crates/runtime_bus/",
    ".octon/framework/assurance/runtime/_ops/fixtures/",
    ".octon/state/evidence/",
)
TEXT_SUFFIXES = {
    ".bash",
    ".cmd",
    ".json",
    ".md",
    ".py",
    ".rs",
    ".sh",
    ".toml",
    ".txt",
    ".yaml",
    ".yml",
}

EVENT_TARGET = re.compile(r"events\.(?:ndjson|manifest\.yml)")
SHELL_ASSIGN = re.compile(r"^\s*(?:local\s+)?([A-Za-z_][A-Za-z0-9_]*)=.*events\.(?:ndjson|manifest\.yml)")
PY_ASSIGN = re.compile(r"^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=.*events\.(?:ndjson|manifest\.yml)")
RUST_ASSIGN_START = re.compile(r"\blet\s+(?:mut\s+)?([A-Za-z_][A-Za-z0-9_]*)\b\s*=")
CONTROL_JOURNAL_LITERAL = re.compile(
    r"(?:\.octon/|\$OCTON_DIR/|\$ROOT_DIR/|ROOT_DIR|OCTON_DIR|repo_root|control_root|run_root|state/control)"
    r"[^;\n]*state/control/execution/runs[^;\n]*events\.(?:ndjson|manifest\.yml)"
)
WRITE_CALL = re.compile(
    r"\b(?:fs::write|std::fs::write|File::create|OpenOptions::new|write_all|tee|cp|mv|install)\b"
)


def repo_rel(path: Path) -> str:
    return path.relative_to(ROOT_DIR).as_posix()


def skip_file(rel: str) -> bool:
    return rel == SELF_REF or any(rel.startswith(prefix) for prefix in ALLOWED_PREFIXES)


def text_files():
    for scan_root in SCAN_ROOTS:
        if not scan_root.exists():
            continue
        for path in scan_root.rglob("*"):
            if not path.is_file():
                continue
            rel = repo_rel(path)
            if skip_file(rel):
                continue
            if path.suffix in TEXT_SUFFIXES or path.name in {"AGENTS.md", ".gitignore"}:
                yield path


def has_redirect_to_tainted(line: str, tainted_vars: set[str]) -> bool:
    for var in tainted_vars:
        if re.search(rf"(^|[^<])>{1,2}\s*[\"']?\$\{{?{re.escape(var)}\}}?", line):
            return True
    return False


def has_write_call_to_tainted(line: str, tainted_vars: set[str]) -> bool:
    if not WRITE_CALL.search(line):
        return False
    return any(re.search(rf"\b{re.escape(var)}\b", line) for var in tainted_vars)


def direct_literal_write(line: str) -> bool:
    if not EVENT_TARGET.search(line):
        return False
    if re.search(r"(^|[^<])>{1,2}\s*[\"']?[^\"']*state/control/execution/runs[^\"']*events\.", line):
        return True
    return bool(WRITE_CALL.search(line) and CONTROL_JOURNAL_LITERAL.search(line))


violations: list[tuple[str, int, str]] = []
for path in text_files():
    rel = repo_rel(path)
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except UnicodeDecodeError:
        continue

    tainted_vars: set[str] = set()
    rust_pending_var = None
    rust_pending_contains_event = False
    for line_no, line in enumerate(lines, start=1):
        shell_match = SHELL_ASSIGN.search(line)
        py_match = PY_ASSIGN.search(line)
        rust_match = RUST_ASSIGN_START.search(line)
        if shell_match:
            tainted_vars.add(shell_match.group(1))
        if py_match:
            tainted_vars.add(py_match.group(1))
        if rust_match:
            rust_pending_var = rust_match.group(1)
            rust_pending_contains_event = bool(EVENT_TARGET.search(line))
        elif rust_pending_var and EVENT_TARGET.search(line):
            rust_pending_contains_event = True

        if direct_literal_write(line) or has_redirect_to_tainted(line, tainted_vars) or has_write_call_to_tainted(line, tainted_vars):
            violations.append((rel, line_no, line.strip()))

        if rust_pending_var and ";" in line:
            if rust_pending_contains_event:
                tainted_vars.add(rust_pending_var)
            rust_pending_var = None
            rust_pending_contains_event = False

if violations:
    print("== Run Journal Append Boundary Validation ==")
    for rel, line_no, line in violations:
        print(f"[ERROR] direct canonical run journal writer outside runtime_bus: {rel}:{line_no}: {line}")
    print(f"Validation summary: status=fail violations={len(violations)}")
    sys.exit(1)

print("== Run Journal Append Boundary Validation ==")
print("[OK] no active direct canonical run journal writers outside runtime_bus")
print("Validation summary: status=pass violations=0")
PY
