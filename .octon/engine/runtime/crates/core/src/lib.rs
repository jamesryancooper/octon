//! Octon executable runtime layer core (no Wasmtime dependencies).
//!
//! This crate implements the language-agnostic kernel modules from `spec-bundle.md` §5:
//! RootResolver, ConfigLoader, ServiceDiscovery, PolicyEngine, TraceWriter, and shared types.

pub mod config;
pub mod discovery;
pub mod errors;
pub mod jsonlines;
pub mod limits;
pub mod orchestration;
pub mod policy;
pub mod registry;
pub mod root;
pub mod schema;
pub mod tiers;
pub mod trace;
