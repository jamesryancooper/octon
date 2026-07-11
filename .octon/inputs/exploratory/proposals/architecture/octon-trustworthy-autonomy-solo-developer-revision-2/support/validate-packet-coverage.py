#!/usr/bin/env python3
"""Validate Revision 2 file inventory, decisions, and required workflow coverage."""

from __future__ import annotations

import hashlib
import re
import sys
from pathlib import Path


PACKET_ROOT = Path(__file__).resolve().parent.parent


def read(relative: str) -> str:
    return (PACKET_ROOT / relative).read_text(encoding="utf-8")


def artifact_set_digest(paths: set[str]) -> str:
    """Hash sorted `sha256  relative-path` records, excluding the review itself."""
    review = "support/implementation-grade-completeness-review.md"
    records: list[str] = []
    for relative in sorted(paths - {review}):
        file_digest = hashlib.sha256((PACKET_ROOT / relative).read_bytes()).hexdigest()
        records.append(f"{file_digest}  {relative}\n")
    return hashlib.sha256("".join(records).encode("utf-8")).hexdigest()


def parse_markdown_table(document: str, first_header: str) -> tuple[list[str], list[list[str]]]:
    lines = document.splitlines()
    start = next(
        (index for index, line in enumerate(lines) if line.startswith(f"| {first_header} |")),
        None,
    )
    if start is None:
        return [], []

    def cells(line: str) -> list[str]:
        return [cell.strip() for cell in line.strip().strip("|").split("|")]

    headers = cells(lines[start])
    rows: list[list[str]] = []
    for line in lines[start + 2 :]:
        if not line.startswith("|"):
            break
        rows.append(cells(line))
    return headers, rows


def main() -> None:
    errors: list[str] = []

    catalog = read("navigation/artifact-catalog.md")
    cataloged = set(re.findall(r"^\| `([^`]+)` \|", catalog, flags=re.MULTILINE))
    visible = {
        path.relative_to(PACKET_ROOT).as_posix()
        for path in PACKET_ROOT.rglob("*")
        if path.is_file()
    }
    for relative in sorted(visible - cataloged):
        errors.append(f"artifact missing from catalog: {relative}")
    for relative in sorted(cataloged - visible):
        errors.append(f"catalog references missing artifact: {relative}")

    decisions = read("architecture/decisions.md")
    matches = list(
        re.finditer(
            r"^## AD-(?P<id>\d{2}) — .+?$",
            decisions,
            flags=re.MULTILINE,
        )
    )
    actual_ids = [match.group("id") for match in matches]
    expected_ids = [f"{number:02d}" for number in range(1, 13)]
    if actual_ids != expected_ids:
        errors.append(f"decision IDs are {actual_ids}, expected {expected_ids}")

    required_fields = [
        "Recommended option",
        "Rejected alternatives",
        "Rationale",
        "Security effect",
        "Development-velocity effect",
        "Implementation cost",
        "Migration impact",
        "Residual risk",
        "Acceptance test",
    ]
    for index, match in enumerate(matches):
        end = matches[index + 1].start() if index + 1 < len(matches) else len(decisions)
        block = decisions[match.end() : end]
        for field in required_fields:
            field_match = re.search(
                rf"^- \*\*{re.escape(field)}:\*\*(?P<body>.*?)"
                rf"(?=^- \*\*(?:{'|'.join(re.escape(item) for item in required_fields)}):\*\*|\Z)",
                block,
                flags=re.MULTILINE | re.DOTALL,
            )
            if field_match is None:
                errors.append(f"AD-{match.group('id')} missing field: {field}")
            elif not re.search(r"[A-Za-z0-9]", field_match.group("body")):
                errors.append(f"AD-{match.group('id')} has empty field: {field}")

    workflows_document = read("architecture/performance-and-workflows.md")
    required_workflows = [
        "small bug fix",
        "multi-file refactor",
        "new feature",
        "long-running mission",
        "low-risk autonomous pull-request completion",
        "production change",
        "ordinary octon self-development",
        "octon trust-root modification",
    ]
    workflow_headers, workflow_rows = parse_markdown_table(
        workflows_document, "Workflow"
    )
    required_columns = [
        "Workflow",
        "Actions performed without interruption",
        "Automatically brokered effects",
        "Actions requiring operator approval",
        "Expected blocking interruptions",
        "Initial Octon-added latency target",
        "Failure and recovery behavior",
    ]
    missing_columns = [
        column for column in required_columns if column not in workflow_headers
    ]
    if missing_columns:
        errors.append(
            "representative workflow matrix missing columns: "
            + ", ".join(missing_columns)
        )
    else:
        indexes = {column: workflow_headers.index(column) for column in required_columns}
        normalized_rows: dict[str, list[str]] = {}
        for row_number, row in enumerate(workflow_rows, start=1):
            if len(row) != len(workflow_headers):
                errors.append(
                    f"workflow row {row_number} has {len(row)} cells, "
                    f"expected {len(workflow_headers)}"
                )
                continue
            name = re.sub(r"^\d+\.\s*", "", row[indexes["Workflow"]]).lower()
            if name in normalized_rows:
                errors.append(f"duplicate workflow row: {name}")
            normalized_rows[name] = row
            for column in required_columns:
                if not re.search(r"[A-Za-z0-9]", row[indexes[column]]):
                    errors.append(
                        f"workflow {name or row_number} has empty column: {column}"
                    )

        actual_workflows = set(normalized_rows)
        expected_workflows = set(required_workflows)
        for workflow in sorted(expected_workflows - actual_workflows):
            errors.append(f"required workflow row missing: {workflow}")
        for workflow in sorted(actual_workflows - expected_workflows):
            errors.append(f"unexpected workflow row: {workflow}")

    required_artifacts = {
        "architecture/authority-and-failure-model.md",
        "architecture/governance-and-enforcement.md",
        "architecture/trusted-computing-base.md",
        "architecture/identity-evidence-merge-self-development.md",
        "architecture/workspace-project-and-harness-factory.md",
        "architecture/performance-and-workflows.md",
        "architecture/decisions.md",
        "architecture/acceptance-criteria.md",
        "architecture/implementation-plan.md",
        "resources/evidence-appendix.yml",
        "resources/evidence-appendix-v1.schema.json",
    }
    for relative in sorted(required_artifacts - visible):
        errors.append(f"required architecture artifact missing: {relative}")

    review_relative = "support/implementation-grade-completeness-review.md"
    if review_relative in visible:
        review = read(review_relative)
        digest_match = re.search(
            r"^- reviewed_artifact_set_digest: sha256:([0-9a-f]{64})$",
            review,
            flags=re.MULTILINE,
        )
        count_match = re.search(
            r"^- reviewed_artifact_count: ([0-9]+)$", review, flags=re.MULTILINE
        )
        expected_digest = artifact_set_digest(visible)
        expected_count = len(visible - {review_relative})
        if digest_match is None:
            errors.append("completeness review missing reviewed_artifact_set_digest")
        elif digest_match.group(1) != expected_digest:
            errors.append(
                "completeness review artifact-set digest is stale: "
                f"{digest_match.group(1)} != {expected_digest}"
            )
        if count_match is None:
            errors.append("completeness review missing reviewed_artifact_count")
        elif int(count_match.group(1)) != expected_count:
            errors.append(
                "completeness review artifact count is stale: "
                f"{count_match.group(1)} != {expected_count}"
            )
    else:
        errors.append("implementation-grade completeness review missing")

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        raise SystemExit(1)

    print(
        "validated packet coverage: "
        f"files={len(visible)} decisions={len(matches)} "
        f"workflows={len(required_workflows)} completeness_receipt=bound"
    )


if __name__ == "__main__":
    main()
