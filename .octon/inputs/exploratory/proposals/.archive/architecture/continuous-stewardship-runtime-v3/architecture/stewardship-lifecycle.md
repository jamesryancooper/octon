# Stewardship Lifecycle

```text
Draft Program -> Active Program -> Active Epoch -> Observe -> Admit/Idle ->
Mission Handoff -> Evidence Aggregation -> Epoch Closeout -> Renew / Pause /
Revoke / Close / Idle Until Trigger
```

## Draft Program

Program authority has been proposed but is not active. No observation or
admission happens.

## Active Program

Durable instance authority and control/evidence roots exist. Program can open
finite epochs.

## Active Epoch

A finite stewardship window is open. Observation and admission may occur within
program and epoch limits.

## Observe

Recognized triggers are normalized and retained as evidence. Observation does
not create work.

## Admit or Idle

Each trigger receives a Stewardship Admission Decision. If no admissible work
exists, Octon emits Idle Decision and stops.

## Mission Handoff

Admitted work becomes a mission candidate and enters v1/v2 surfaces. Stewardship
no longer owns execution.

## Evidence Aggregation

Stewardship Ledger indexes trigger, admission, mission, run, campaign, idle, and
renewal evidence without replacing lower-level evidence.

## Epoch Closeout and Renewal

Epoch closeout proves work disposition and emits Renewal Decision. Renewal opens
a new finite epoch only when permitted.
