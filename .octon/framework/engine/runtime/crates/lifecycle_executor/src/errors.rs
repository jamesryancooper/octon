use thiserror::Error;

#[derive(Clone, Debug, serde::Serialize, serde::Deserialize, Eq, PartialEq)]
#[serde(rename_all = "kebab-case")]
pub enum LifecycleErrorClass {
    Discovery,
    InputBinding,
    ApprovalRequired,
    ExecutorUnavailable,
    ExecutorFailed,
    Timeout,
    Cancelled,
    CompletionNotObserved,
    PartialMutation,
    ReceiptInvalid,
    Io,
}

impl LifecycleErrorClass {
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Discovery => "discovery",
            Self::InputBinding => "input-binding",
            Self::ApprovalRequired => "approval-required",
            Self::ExecutorUnavailable => "executor-unavailable",
            Self::ExecutorFailed => "executor-failed",
            Self::Timeout => "timeout",
            Self::Cancelled => "cancelled",
            Self::CompletionNotObserved => "completion-not-observed",
            Self::PartialMutation => "partial-mutation",
            Self::ReceiptInvalid => "receipt-invalid",
            Self::Io => "io",
        }
    }
}

#[derive(Debug, Error)]
#[error("{class:?}: {message}")]
pub struct LifecycleExecutionError {
    pub class: LifecycleErrorClass,
    pub message: String,
}

impl LifecycleExecutionError {
    pub fn new(class: LifecycleErrorClass, message: impl Into<String>) -> Self {
        Self {
            class,
            message: message.into(),
        }
    }
}

impl From<std::io::Error> for LifecycleExecutionError {
    fn from(error: std::io::Error) -> Self {
        Self::new(LifecycleErrorClass::Io, error.to_string())
    }
}

impl From<anyhow::Error> for LifecycleExecutionError {
    fn from(error: anyhow::Error) -> Self {
        Self::new(LifecycleErrorClass::Io, error.to_string())
    }
}

impl From<serde_yaml::Error> for LifecycleExecutionError {
    fn from(error: serde_yaml::Error) -> Self {
        Self::new(LifecycleErrorClass::Io, error.to_string())
    }
}
