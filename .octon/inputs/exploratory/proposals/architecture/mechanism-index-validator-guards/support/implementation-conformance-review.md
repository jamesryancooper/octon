# Implementation Conformance Review Scaffold

status: not-run

## Purpose

After durable implementation lands, verify that validator changes enforce this
child packet.

## Required Checks

- Negative controls reject feature catalog authority overclaims.
- Negative controls reject mechanism index runtime authority overclaims.
- Negative controls reject state/control not retained evidence confusion.
- Negative controls reject lifecycle interaction receipts as authorization.
