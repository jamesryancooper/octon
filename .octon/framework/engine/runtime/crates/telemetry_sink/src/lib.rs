use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Default, PartialEq, Serialize, Deserialize)]
pub struct TelemetryTotals {
    pub latency_ms: u64,
    pub retry_count: u32,
    pub intervention_count: u32,
    pub token_usage: u64,
    pub cost_microusd: u64,
}

impl TelemetryTotals {
    pub fn absorb(&mut self, other: &TelemetryTotals) {
        self.latency_ms += other.latency_ms;
        self.retry_count += other.retry_count;
        self.intervention_count += other.intervention_count;
        self.token_usage += other.token_usage;
        self.cost_microusd += other.cost_microusd;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn absorb_accumulates_runtime_measurements() {
        let mut base = TelemetryTotals {
            latency_ms: 10,
            retry_count: 1,
            intervention_count: 0,
            token_usage: 120,
            cost_microusd: 400,
        };
        base.absorb(&TelemetryTotals {
            latency_ms: 5,
            retry_count: 2,
            intervention_count: 1,
            token_usage: 80,
            cost_microusd: 600,
        });

        assert_eq!(base.latency_ms, 15);
        assert_eq!(base.retry_count, 3);
        assert_eq!(base.intervention_count, 1);
        assert_eq!(base.token_usage, 200);
        assert_eq!(base.cost_microusd, 1000);
    }
}
