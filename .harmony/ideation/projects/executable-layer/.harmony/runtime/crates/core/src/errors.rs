use serde_json::json;

/// Standard error codes (v1) from `spec-bundle.md` §4.5.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ErrorCode {
    ProtocolUnsupported,
    MalformedJson,
    RequestTooLarge,
    UnknownMethod,
    UnknownService,
    UnknownOperation,
    InvalidInput,
    CapabilityDenied,
    Timeout,
    ServiceTrap,
    Internal,
    Cancelled,
}

impl ErrorCode {
    pub fn as_str(self) -> &'static str {
        match self {
            ErrorCode::ProtocolUnsupported => "PROTOCOL_UNSUPPORTED",
            ErrorCode::MalformedJson => "MALFORMED_JSON",
            ErrorCode::RequestTooLarge => "REQUEST_TOO_LARGE",
            ErrorCode::UnknownMethod => "UNKNOWN_METHOD",
            ErrorCode::UnknownService => "UNKNOWN_SERVICE",
            ErrorCode::UnknownOperation => "UNKNOWN_OPERATION",
            ErrorCode::InvalidInput => "INVALID_INPUT",
            ErrorCode::CapabilityDenied => "CAPABILITY_DENIED",
            ErrorCode::Timeout => "TIMEOUT",
            ErrorCode::ServiceTrap => "SERVICE_TRAP",
            ErrorCode::Internal => "INTERNAL",
            ErrorCode::Cancelled => "CANCELLED",
        }
    }
}

#[derive(thiserror::Error, Debug)]
#[error("{code}: {message}")]
pub struct KernelError {
    pub code: ErrorCode,
    pub message: String,
    pub details: serde_json::Value,
}

impl KernelError {
    pub fn new(code: ErrorCode, message: impl Into<String>) -> Self {
        Self {
            code,
            message: message.into(),
            details: json!({}),
        }
    }

    pub fn with_details(mut self, details: serde_json::Value) -> Self {
        self.details = details;
        self
    }

    pub fn as_error_object(&self) -> serde_json::Value {
        json!({
            "code": self.code.as_str(),
            "message": self.message,
            "details": self.details,
        })
    }
}

pub type Result<T> = std::result::Result<T, KernelError>;

impl From<anyhow::Error> for KernelError {
    fn from(err: anyhow::Error) -> Self {
        // Allow mapping from tagged anyhow strings like "CAPABILITY_DENIED: ...".
        let msg = err.to_string();
        if let Some((code, rest)) = msg.split_once(':') {
            let code = code.trim();
            let rest = rest.trim();
            let mapped = match code {
                "PROTOCOL_UNSUPPORTED" => Some(ErrorCode::ProtocolUnsupported),
                "MALFORMED_JSON" => Some(ErrorCode::MalformedJson),
                "REQUEST_TOO_LARGE" => Some(ErrorCode::RequestTooLarge),
                "UNKNOWN_METHOD" => Some(ErrorCode::UnknownMethod),
                "UNKNOWN_SERVICE" => Some(ErrorCode::UnknownService),
                "UNKNOWN_OPERATION" => Some(ErrorCode::UnknownOperation),
                "INVALID_INPUT" => Some(ErrorCode::InvalidInput),
                "CAPABILITY_DENIED" => Some(ErrorCode::CapabilityDenied),
                "TIMEOUT" => Some(ErrorCode::Timeout),
                "SERVICE_TRAP" => Some(ErrorCode::ServiceTrap),
                "INTERNAL" => Some(ErrorCode::Internal),
                "CANCELLED" => Some(ErrorCode::Cancelled),
                _ => None,
            };
            if let Some(ec) = mapped {
                return KernelError::new(ec, rest);
            }
        }

        KernelError::new(ErrorCode::Internal, msg)
    }
}
