use crate::errors::{ErrorCode, KernelError, Result};
use jsonschema::{Draft, JSONSchema};
use serde_json::json;
use std::path::Path;

#[derive(Clone)]
pub struct SchemaStore {
    manifest_schema: std::sync::Arc<JSONSchema>,
}

impl SchemaStore {
    pub fn load(octon_dir: &Path) -> Result<Self> {
        let schema_path = octon_dir
            .join("engine")
            .join("runtime")
            .join("spec")
            .join("service-manifest-v1.schema.json");
        let bytes = std::fs::read(&schema_path).map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("failed to read manifest schema at {}: {e}", schema_path.display()),
            )
        })?;
        let schema_json: serde_json::Value = serde_json::from_slice(&bytes).map_err(|e| {
            KernelError::new(
                ErrorCode::Internal,
                format!("manifest schema is not valid JSON: {e}"),
            )
        })?;

        let compiled = JSONSchema::options()
            .with_draft(Draft::Draft202012)
            .compile(&schema_json)
            .map_err(|e| KernelError::new(ErrorCode::Internal, format!("failed to compile schema: {e}")))?;

        Ok(Self {
            manifest_schema: std::sync::Arc::new(compiled),
        })
    }

    pub fn validate_service_manifest(&self, manifest_json: &serde_json::Value) -> Result<()> {
        let mut problems = Vec::new();
        if let Err(errors) = self.manifest_schema.validate(manifest_json) {
            for e in errors {
                problems.push(json!({
                    "instance_path": e.instance_path.to_string(),
                    "schema_path": e.schema_path.to_string(),
                    "message": e.to_string(),
                }));
            }
        }

        if problems.is_empty() {
            Ok(())
        } else {
            Err(KernelError::new(
                ErrorCode::Internal,
                "service.json does not conform to service-manifest-v1 schema",
            )
            .with_details(json!({"problems": problems})))
        }
    }

    pub fn validate_against_schema(
        &self,
        instance: &serde_json::Value,
        schema: &serde_json::Value,
        code: ErrorCode,
        message: &str,
    ) -> Result<()> {
        let compiled = JSONSchema::options()
            .with_draft(Draft::Draft202012)
            .compile(schema)
            .map_err(|e| KernelError::new(ErrorCode::Internal, format!("invalid JSON schema: {e}")))?;

        let mut problems = Vec::new();
        if let Err(errors) = compiled.validate(instance) {
            for e in errors {
                problems.push(json!({
                    "instance_path": e.instance_path.to_string(),
                    "schema_path": e.schema_path.to_string(),
                    "message": e.to_string(),
                }));
            }
        }

        if problems.is_empty() {
            Ok(())
        } else {
            Err(KernelError::new(code, message).with_details(json!({"problems": problems})))
        }
    }
}
