use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum RuntimeEventType {
    RunCreated,
    StageStarted,
    CheckpointCreated,
    RetryRecorded,
    ContaminationRecorded,
    ApprovalResolved,
    RevocationActivated,
    DisclosureGenerated,
    CertificationCompleted,
}

impl RuntimeEventType {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::RunCreated => "run-created",
            Self::StageStarted => "stage-started",
            Self::CheckpointCreated => "checkpoint-created",
            Self::RetryRecorded => "retry-recorded",
            Self::ContaminationRecorded => "contamination-recorded",
            Self::ApprovalResolved => "approval-resolved",
            Self::RevocationActivated => "revocation-activated",
            Self::DisclosureGenerated => "disclosure-generated",
            Self::CertificationCompleted => "certification-completed",
        }
    }
}

pub fn global_completion_events() -> Vec<&'static str> {
    vec![
        RuntimeEventType::RunCreated.as_str(),
        RuntimeEventType::StageStarted.as_str(),
        RuntimeEventType::CheckpointCreated.as_str(),
        RuntimeEventType::RetryRecorded.as_str(),
        RuntimeEventType::ContaminationRecorded.as_str(),
        RuntimeEventType::ApprovalResolved.as_str(),
        RuntimeEventType::RevocationActivated.as_str(),
        RuntimeEventType::DisclosureGenerated.as_str(),
        RuntimeEventType::CertificationCompleted.as_str(),
    ]
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn global_completion_events_include_disclosure_and_certification() {
        let events = global_completion_events();
        assert!(events.contains(&"disclosure-generated"));
        assert!(events.contains(&"certification-completed"));
    }
}
