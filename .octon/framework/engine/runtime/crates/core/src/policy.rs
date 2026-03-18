use crate::config::RuntimeConfig;
use crate::errors::{ErrorCode, KernelError, Result};
use crate::registry::ServiceDescriptor;
use serde_json::json;
use std::collections::BTreeSet;

#[derive(Debug, Clone)]
pub enum PolicyDecision {
    Allow { granted: Vec<String> },
    Deny { error: KernelError },
}

pub struct PolicyEngine {
    cfg: RuntimeConfig,
}

impl PolicyEngine {
    pub fn new(cfg: RuntimeConfig) -> Self {
        Self { cfg }
    }

    pub fn decide(&self, service: &ServiceDescriptor) -> PolicyDecision {
        // Deny-by-default.
        let service_id = service.key.id();

        // Allowed capabilities according to policy config.
        let mut allowed: BTreeSet<String> = BTreeSet::new();
        allowed.extend(self.cfg.policy.default_allow.iter().cloned());

        if let Some(cat_allow) = self.cfg.policy.category_allow.get(&service.key.category) {
            allowed.extend(cat_allow.iter().cloned());
        }

        if let Some(svc_allow) = self.cfg.policy.service_allow.get(&service_id) {
            allowed.extend(svc_allow.iter().cloned());
        }

        // Required capabilities declared by the service manifest.
        let mut missing = Vec::new();
        for cap in &service.manifest.capabilities_required {
            if !allowed.contains(cap) {
                missing.push(cap.clone());
            }
        }

        if !missing.is_empty() {
            return PolicyDecision::Deny {
                error: KernelError::new(
                    ErrorCode::CapabilityDenied,
                    format!("capabilities not granted for {service_id}"),
                )
                .with_details(json!({
                    "service": service_id,
                    "missing": missing,
                })),
            };
        }

        // Grant only what the service declares (capability least privilege).
        PolicyDecision::Allow {
            granted: service.manifest.capabilities_required.clone(),
        }
    }

    pub fn decide_allow(&self, service: &ServiceDescriptor) -> Result<Vec<String>> {
        match self.decide(service) {
            PolicyDecision::Allow { granted } => Ok(granted),
            PolicyDecision::Deny { error } => Err(error),
        }
    }
}
