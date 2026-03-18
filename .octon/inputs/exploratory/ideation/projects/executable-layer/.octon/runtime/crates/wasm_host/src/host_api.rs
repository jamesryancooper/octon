use crate::bindings::{clock, fs, kv, log};
use crate::state::HostState;

impl log::Host for HostState {
    fn write(&mut self, level: String, message: String) -> wasmtime::Result<()> {
        self.grants.require("log.write")?;
        eprintln!("[{level}] {message}");
        Ok(())
    }
}

impl clock::Host for HostState {
    fn now_ms(&mut self) -> wasmtime::Result<u64> {
        self.grants.require("clock.read")?;
        Ok(std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap_or_default()
            .as_millis() as u64)
    }
}

impl kv::Host for HostState {
    fn get(&mut self, key: String) -> wasmtime::Result<Option<String>> {
        self.grants.require("storage.local")?;
        Ok(self.kv.get(&key)?)
    }

    fn put(&mut self, key: String, value: String) -> wasmtime::Result<()> {
        self.grants.require("storage.local")?;
        self.kv.put(&key, &value)?;
        Ok(())
    }

    fn del(&mut self, key: String) -> wasmtime::Result<()> {
        self.grants.require("storage.local")?;
        let _ = self.kv.del(&key)?;
        Ok(())
    }
}

impl fs::Host for HostState {
    fn read(&mut self, path: String) -> wasmtime::Result<Vec<u8>> {
        self.grants.require("fs.read")?;
        Ok(self.fs.read_bytes(&path)?)
    }

    fn write(&mut self, path: String, data: Vec<u8>) -> wasmtime::Result<()> {
        self.grants.require("fs.write")?;
        if data.len() > 4 * 1024 * 1024 {
            return Err(anyhow::anyhow!("INVALID_INPUT: write too large").into());
        }
        self.fs.write_bytes_atomic(&path, &data)?;
        Ok(())
    }

    fn read_text(&mut self, path: String) -> wasmtime::Result<String> {
        self.grants.require("fs.read")?;
        Ok(self.fs.read_text(&path, 1 * 1024 * 1024)?)
    }

    fn write_text(&mut self, path: String, data: String) -> wasmtime::Result<()> {
        self.grants.require("fs.write")?;
        self.fs.write_text_atomic(&path, &data, 1 * 1024 * 1024)?;
        Ok(())
    }

    fn exists(&mut self, path: String) -> wasmtime::Result<bool> {
        self.grants.require("fs.read")?;
        Ok(self.fs.exists(&path)?)
    }

    fn list_dir(&mut self, path: String) -> wasmtime::Result<Vec<String>> {
        self.grants.require("fs.read")?;
        Ok(self.fs.list_dir(&path)?)
    }

    fn glob(&mut self, pattern: String) -> wasmtime::Result<Vec<String>> {
        self.grants.require("fs.read")?;
        Ok(self.fs.glob(&pattern, 10_000)?)
    }

    fn mkdirp(&mut self, path: String) -> wasmtime::Result<()> {
        self.grants.require("fs.write")?;
        self.fs.mkdirp(&path)?;
        Ok(())
    }

    fn remove_file(&mut self, path: String) -> wasmtime::Result<()> {
        self.grants.require("fs.write")?;
        self.fs.remove_file(&path)?;
        Ok(())
    }

    fn remove_dir_recursive(&mut self, path: String) -> wasmtime::Result<()> {
        self.grants.require("fs.write")?;
        self.fs.remove_dir_recursive(&path)?;
        Ok(())
    }

    fn stat(&mut self, path: String) -> wasmtime::Result<Option<fs::Stat>> {
        self.grants.require("fs.read")?;
        let Some(st) = self.fs.stat(&path)? else { return Ok(None); };

        let kind = match st.kind {
            crate::scoped_fs::NodeKind::File => fs::NodeKind::File,
            crate::scoped_fs::NodeKind::Dir => fs::NodeKind::Dir,
        };

        Ok(Some(fs::Stat {
            kind,
            size: st.size,
            modified_ms: st.modified_ms,
        }))
    }
}
