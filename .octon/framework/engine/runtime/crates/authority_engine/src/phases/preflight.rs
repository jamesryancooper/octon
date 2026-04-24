use super::*;
use serde_json::{json, Value};

pub(crate) fn preflight_details(
    environment: &ExecutionEnvironment,
    effective_policy_mode: &str,
    executor_profile: Option<&str>,
    ownership_status: &str,
    support_route: &str,
) -> Value {
    json!({
        "environment_class": environment.as_str(),
        "effective_policy_mode": effective_policy_mode,
        "executor_profile": executor_profile,
        "ownership_status": ownership_status,
        "support_route": support_route,
    })
}
