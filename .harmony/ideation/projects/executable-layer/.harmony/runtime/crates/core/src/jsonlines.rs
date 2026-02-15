use crate::errors::{ErrorCode, KernelError, Result};
use std::io::{BufRead, Write};

/// Read a single JSON value from an NDJSON stream.
///
/// Returns Ok(None) on EOF.
pub fn read_json_line<R: BufRead>(reader: &mut R, max_bytes: usize) -> Result<Option<serde_json::Value>> {
    let mut line = String::new();
    let n = reader
        .read_line(&mut line)
        .map_err(|e| KernelError::new(ErrorCode::Internal, format!("failed to read stdin: {e}")))?;

    if n == 0 {
        return Ok(None);
    }

    if line.as_bytes().len() > max_bytes {
        return Err(KernelError::new(
            ErrorCode::RequestTooLarge,
            format!("line exceeds max length ({max_bytes} bytes)"),
        ));
    }

    // Allow \r\n.
    if line.ends_with('\n') {
        line.pop();
        if line.ends_with('\r') {
            line.pop();
        }
    }

    let value: serde_json::Value = serde_json::from_str(&line)
        .map_err(|e| KernelError::new(ErrorCode::MalformedJson, format!("invalid JSON line: {e}")))?;

    Ok(Some(value))
}

pub fn write_json_line<W: Write>(writer: &mut W, value: &serde_json::Value) -> Result<()> {
    let s = serde_json::to_string(value)
        .map_err(|e| KernelError::new(ErrorCode::Internal, format!("failed to serialize JSON: {e}")))?;
    writer
        .write_all(s.as_bytes())
        .map_err(|e| KernelError::new(ErrorCode::Internal, format!("stdout write failed: {e}")))?;
    writer
        .write_all(b"\n")
        .map_err(|e| KernelError::new(ErrorCode::Internal, format!("stdout write failed: {e}")))?;
    writer
        .flush()
        .map_err(|e| KernelError::new(ErrorCode::Internal, format!("stdout flush failed: {e}")))?;
    Ok(())
}
