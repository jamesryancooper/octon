# Normalized Child Terminal Evidence Summary

## Problem

Planner and validators disagreed about terminal child evidence, causing receipt repair loops.

## Goal

Add or compute a normalized terminal evidence summary for child packets and archived children.

## Dependencies

- complete-program-blocker-vector-planner-output

## Boundary

This child packet is planning lineage only until a later accepted implementation route. It does not implement durable behavior and does not authorize archive, cleanup, delivery, git mutation, PR creation, or `cleaned` claims.
