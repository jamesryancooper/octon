# Input Baseline and Source Normalization

## Purpose

Normalize the user requests and repo-grounded observations that shaped this
packet into one explicit baseline.

## Normalized problem statement

The motivating problem is not simply “where should a temporary binary be
installed.” It is:

1. Octon must remain portable across arbitrary repositories and operating
   systems.
2. The same system may host multiple Octon-enabled repositories.
3. Repo-local authority must not be contaminated by OS-specific third-party
   binaries.
4. External tool provisioning must still be deterministic, governed, and
   evidence-backed.

## Normalized architectural requirements

1. Repo-local `/.octon/**` surfaces declare desired requirements only.
2. Actual external tool installs live outside the repo.
3. Multiple repos can share a host cache while retaining independent desired
   state.
4. `/init` remains repo bootstrap only.
5. Consumer commands such as `repo-hygiene` resolve required tools through one
   governed subsystem and fail closed when unmet.

## Why existing extension governance matters

The live extension model already separates:

- desired activation;
- actual active state;
- quarantine;
- generated effective outputs.

That pattern is directly relevant here, but the actual install state for host
tools must be host-scoped rather than repo-scoped.
