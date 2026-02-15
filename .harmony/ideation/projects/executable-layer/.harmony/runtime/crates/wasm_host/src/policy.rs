use std::collections::BTreeSet;

#[derive(Clone, Debug)]
pub struct GrantSet {
    caps: BTreeSet<String>,
}

impl GrantSet {
    pub fn new<I, S>(caps: I) -> Self
    where
        I: IntoIterator<Item = S>,
        S: Into<String>,
    {
        Self {
            caps: caps.into_iter().map(Into::into).collect(),
        }
    }

    pub fn has(&self, cap: &str) -> bool {
        self.caps.contains(cap)
    }

    pub fn list(&self) -> Vec<String> {
        self.caps.iter().cloned().collect()
    }

    pub fn require(&self, cap: &str) -> wasmtime::Result<()> {
        if self.has(cap) {
            Ok(())
        } else {
            Err(anyhow::anyhow!("CAPABILITY_DENIED: missing {cap}").into())
        }
    }
}
