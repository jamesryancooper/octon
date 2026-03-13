#!/usr/bin/env python3
"""Validate generic design-package conformance scenarios."""

from __future__ import annotations

import json
import sys
from pathlib import Path


def ensure(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: validate_scenarios.py <package-root>", file=sys.stderr)
        return 2

    package_root = Path(sys.argv[1])
    scenarios_root = package_root / "conformance" / "scenarios"
    if not scenarios_root.is_dir():
        print(f"[ERROR] missing conformance/scenarios in {package_root}", file=sys.stderr)
        return 1

    scenario_files = sorted(scenarios_root.rglob("*.json"))
    if not scenario_files:
        print("[OK] no conformance scenarios declared")
        return 0

    failures = 0
    for path in scenario_files:
        try:
            payload = json.loads(path.read_text())
            ensure("scenario_id" in payload, f"{path}: missing scenario_id")
            ensure("suite" in payload, f"{path}: missing suite")
            ensure("description" in payload, f"{path}: missing description")
            ensure("expected" in payload, f"{path}: missing expected")
            print(f"[OK] scenario shape valid: {path}")
        except Exception as exc:  # pragma: no cover - template script
            failures += 1
            print(f"[ERROR] {exc}", file=sys.stderr)

    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
