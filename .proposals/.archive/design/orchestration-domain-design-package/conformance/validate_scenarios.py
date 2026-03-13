#!/usr/bin/env python3
"""Package-local semantic conformance evaluator."""

from __future__ import annotations

import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
import fnmatch


SEVERITY_ORDER = {"info": 0, "warning": 1, "high": 2, "critical": 3}


@dataclass
class ScenarioFailure(Exception):
    message: str


def normalize_path(value: str) -> str:
    return value.replace("\\", "/")


def octon_glob_match(pattern: str, value: str) -> bool:
    normalized_pattern = normalize_path(pattern)
    normalized_value = normalize_path(value)
    return fnmatch.fnmatchcase(normalized_value, normalized_pattern)


def ensure(condition: bool, message: str) -> None:
    if not condition:
        raise ScenarioFailure(message)


def evaluate_selector(selector: dict, event: dict) -> bool:
    selector_results = []
    if "watcher_ids" in selector:
        selector_results.append(event["watcher_id"] in selector["watcher_ids"])
    if "event_types" in selector:
        selector_results.append(event["event_type"] in selector["event_types"])
    if "severity_at_or_above" in selector:
        selector_results.append(
            SEVERITY_ORDER[event["severity"]]
            >= SEVERITY_ORDER[selector["severity_at_or_above"]]
        )
    if "source_ref_globs" in selector:
        selector_results.append(
            any(
                octon_glob_match(pattern, event["source_ref"])
                for pattern in selector["source_ref_globs"]
            )
        )

    match_mode = selector["match_mode"]
    if not selector_results:
        return True
    if match_mode == "all":
        return all(selector_results)
    if match_mode == "any":
        return any(selector_results)
    raise ScenarioFailure(f"unsupported match_mode: {match_mode}")


def evaluate_routing(scenario: dict) -> None:
    event = scenario["event"]
    matched = []
    for automation in scenario["automations"]:
        selector = automation["selector"]
        if evaluate_selector(selector, event):
            matched.append(automation["automation_id"])

    outcome = "no_match_block" if not matched else "match"
    if event.get("target_automation_id"):
        matched = [
            automation_id
            for automation_id in matched
            if automation_id == event["target_automation_id"]
        ]
        outcome = "blocked_target_hint" if not matched else "target_hint_match"

    matched = sorted(matched)
    dedupe_hits = set(scenario.get("dedupe_hits", []))
    suppressed = []
    unsuppressed = []
    for automation in scenario["automations"]:
        automation_id = automation["automation_id"]
        selector = automation["selector"]
        if automation_id not in matched:
            continue
        if selector.get("dedupe_window") and automation_id in dedupe_hits:
            suppressed.append(automation_id)
        else:
            unsuppressed.append(automation_id)

    unsuppressed = sorted(unsuppressed)
    suppressed = sorted(suppressed)

    if not unsuppressed:
        outcome = "no_match_block" if suppressed else outcome
    if len(unsuppressed) > 1:
        outcome = "fan_out"
    elif len(unsuppressed) == 1 and outcome == "match":
        outcome = "single_match"

    expected = scenario["expected"]
    ensure(
        unsuppressed == expected["matched_automation_ids"],
        f"{scenario['scenario_id']}: matched ids {unsuppressed} != {expected['matched_automation_ids']}",
    )
    ensure(
        sorted(suppressed) == sorted(expected.get("suppressed_automation_ids", [])),
        f"{scenario['scenario_id']}: suppressed ids {suppressed} != {expected.get('suppressed_automation_ids', [])}",
    )
    if "outcome" in expected:
        ensure(
            outcome == expected["outcome"],
            f"{scenario['scenario_id']}: outcome {outcome} != {expected['outcome']}",
        )


def parse_hhmm(value: str) -> int:
    hour, minute = value.split(":")
    return int(hour) * 60 + int(minute)


def format_hhmm(total_minutes: int) -> str:
    hour = total_minutes // 60
    minute = total_minutes % 60
    return f"{hour:02d}:{minute:02d}"


def evaluate_scheduling(scenario: dict) -> None:
    schedule = scenario["schedule"]
    transition = scenario["transition"]
    expected = scenario["expected"]
    scheduled_minutes = parse_hhmm(schedule["at"])

    if transition["kind"] == "spring_forward":
        gap_start = parse_hhmm(transition["gap_start"])
        gap_end = parse_hhmm(transition["gap_end"])
        resolved = (
            gap_end + 1
            if gap_start <= scheduled_minutes <= gap_end
            else scheduled_minutes
        )
        actual = {
            "resolved_local_time": format_hhmm(resolved),
            "window_count": 1,
        }
    elif transition["kind"] == "fall_back":
        repeated_time = parse_hhmm(transition["repeated_time"])
        selected_occurrence = "first" if scheduled_minutes == repeated_time else "only"
        actual = {
            "resolved_local_time": schedule["at"],
            "window_count": 1,
            "selected_occurrence": selected_occurrence,
        }
    else:
        raise ScenarioFailure(f"unsupported scheduling transition kind: {transition['kind']}")

    ensure(
        actual == expected,
        f"{scenario['scenario_id']}: scheduling result {actual} != {expected}",
    )


def evaluate_recovery(scenario: dict) -> None:
    signals = scenario["signals"]
    if signals["same_executor_reacknowledged"] and signals["coordination_still_valid"]:
        actual = {
            "outcome": "resume_same_executor",
            "recovery_status": "recovered",
            "allow_new_side_effects": True,
        }
    else:
        actual = {
            "outcome": "abandon_and_escalate",
            "recovery_status": "abandoned",
            "allow_new_side_effects": False,
        }

    ensure(
        actual == scenario["expected"],
        f"{scenario['scenario_id']}: recovery result {actual} != {scenario['expected']}",
    )


def load_scenarios(root: Path) -> list[Path]:
    return sorted(root.glob("scenarios/**/*.json"))


def validate_shape(scenario: dict, path: Path) -> None:
    ensure("scenario_id" in scenario, f"{path}: missing scenario_id")
    ensure("suite" in scenario, f"{path}: missing suite")
    ensure("description" in scenario, f"{path}: missing description")
    ensure("expected" in scenario, f"{path}: missing expected block")


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: validate_scenarios.py <conformance-dir>", file=sys.stderr)
        return 2

    conformance_dir = Path(sys.argv[1])
    scenario_root = (
        conformance_dir / "conformance"
        if (conformance_dir / "conformance").is_dir()
        else conformance_dir
    )
    scenario_files = load_scenarios(scenario_root)
    if not scenario_files:
        print("[ERROR] no conformance scenario files found", file=sys.stderr)
        return 1

    failures = 0
    for path in scenario_files:
        try:
            scenario = json.loads(path.read_text())
            validate_shape(scenario, path)
            suite = scenario["suite"]
            if suite == "routing":
                evaluate_routing(scenario)
            elif suite == "scheduling":
                evaluate_scheduling(scenario)
            elif suite == "recovery":
                evaluate_recovery(scenario)
            else:
                raise ScenarioFailure(f"{path}: unsupported suite {suite}")
            print(f"[OK] conformance scenario passed: {path}")
        except (json.JSONDecodeError, OSError) as exc:
            failures += 1
            print(f"[ERROR] {path}: {exc}", file=sys.stderr)
        except ScenarioFailure as exc:
            failures += 1
            print(f"[ERROR] {exc.message}", file=sys.stderr)

    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
