# Summaries, Projections, And Read Models

## Final design

Generated awareness remains generated.
This packet does not promote any summary or mission view to an authoritative surface.

## Required generated outputs for every active autonomous mission

- `generated/cognition/summaries/missions/<mission-id>/now.md`
- `generated/cognition/summaries/missions/<mission-id>/next.md`
- `generated/cognition/summaries/missions/<mission-id>/recent.md`
- `generated/cognition/summaries/missions/<mission-id>/recover.md`
- ownership-routed operator digests under `generated/cognition/summaries/operators/**`
- `generated/cognition/projections/materialized/missions/<mission-id>/mission-view.yml`

## Source-citation rule

Each generated output must cite its source roots, for example:

- mission charter path
- mode-state path
- intent register path
- current action-slice path
- route path
- continuity path
- relevant receipt paths

That keeps generated outputs transparent and non-authoritative.

## Universality rule

The audit gap was not that summaries did not exist.
It was that they were not yet clearly universal.

This packet closes that by requiring them for **every active autonomous mission** and validating them in blocking CI.

## Commit policy rule

Generated outputs must follow the root manifest’s commit/rebuild defaults.
If a generated surface is marked `commit`, it must be committed.
If a generated surface is marked `rebuild`, validation must prove it generates correctly even if it is not committed.
