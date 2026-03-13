#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path

import yaml


def parse_hhmm(value: str) -> int:
    hour, minute = value.split(":")
    return int(hour) * 60 + int(minute)


def format_hhmm(total_minutes: int) -> str:
    hour = total_minutes // 60
    minute = total_minutes % 60
    return f"{hour:02d}:{minute:02d}"


def schedule_window_id(automation_id: str, local_date: str, resolved_local_time: str) -> str:
    return f"{automation_id}:{local_date}:{resolved_local_time}"


def evaluate_transition(automation_id: str, schedule: dict, transition: dict) -> dict:
    scheduled_minutes = parse_hhmm(schedule["at"])
    kind = transition["kind"]
    local_date = transition["local_date"]

    if kind == "spring_forward":
      gap_start = parse_hhmm(transition["gap_start"])
      gap_end = parse_hhmm(transition["gap_end"])
      resolved = gap_end + 1 if gap_start <= scheduled_minutes <= gap_end else scheduled_minutes
      resolved_local_time = format_hhmm(resolved)
      return {
          "resolved_local_time": resolved_local_time,
          "window_count": 1,
          "schedule_window_id": schedule_window_id(automation_id, local_date, resolved_local_time),
      }

    if kind == "fall_back":
      resolved_local_time = schedule["at"]
      return {
          "resolved_local_time": resolved_local_time,
          "window_count": 1,
          "selected_occurrence": "first",
          "schedule_window_id": schedule_window_id(automation_id, local_date, resolved_local_time),
      }

    raise SystemExit(f"unsupported transition kind: {kind}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--automation-id", required=True)
    parser.add_argument("--trigger-file", required=True)
    parser.add_argument("--transition-file")
    args = parser.parse_args()

    trigger = yaml.safe_load(Path(args.trigger_file).read_text())
    if trigger.get("kind") != "schedule":
        raise SystemExit("trigger-file must be a schedule automation")
    schedule = trigger["schedule"]

    if args.transition_file:
        transition = json.loads(Path(args.transition_file).read_text())["transition"]
        print(json.dumps(evaluate_transition(args.automation_id, schedule, transition)))
        return 0

    raise SystemExit("transition-file is required for deterministic schedule evaluation in v1")


if __name__ == "__main__":
    raise SystemExit(main())
