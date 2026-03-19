use parking_lot::Mutex;
use std::{
    collections::BTreeMap,
    fs,
    io::{self, Read, Write},
    path::{Path, PathBuf},
    sync::Arc,
};

#[derive(Clone)]
pub struct KvStore {
    inner: Arc<Mutex<Inner>>,
}

struct Inner {
    file_path: PathBuf,
    map: BTreeMap<String, String>,
}

impl KvStore {
    /// Opens (or creates) a KV store at `state_dir` (e.g. `.octon/state/control/engine/kv/`).
    /// Stores data in `store.json` as a JSON object: { "key": "value", ... }.
    pub fn open(state_dir: PathBuf) -> io::Result<Self> {
        fs::create_dir_all(&state_dir)?;
        let file_path = state_dir.join("store.json");

        let map = if file_path.exists() {
            load_json_map(&file_path)?
        } else {
            BTreeMap::new()
        };

        Ok(Self {
            inner: Arc::new(Mutex::new(Inner { file_path, map })),
        })
    }

    pub fn get(&self, key: &str) -> io::Result<Option<String>> {
        validate_key(key)?;
        let inner = self.inner.lock();
        Ok(inner.map.get(key).cloned())
    }

    pub fn put(&self, key: &str, value: &str) -> io::Result<()> {
        validate_key(key)?;
        validate_value(value)?;
        let mut inner = self.inner.lock();
        inner.map.insert(key.to_string(), value.to_string());
        persist_atomic(&inner.file_path, &inner.map)
    }

    pub fn del(&self, key: &str) -> io::Result<bool> {
        validate_key(key)?;
        let mut inner = self.inner.lock();
        let existed = inner.map.remove(key).is_some();
        if existed {
            persist_atomic(&inner.file_path, &inner.map)?;
        }
        Ok(existed)
    }

    pub fn len(&self) -> io::Result<usize> {
        let inner = self.inner.lock();
        Ok(inner.map.len())
    }
}

fn load_json_map(path: &Path) -> io::Result<BTreeMap<String, String>> {
    let mut f = fs::File::open(path)?;
    let mut s = String::new();
    f.read_to_string(&mut s)?;
    if s.trim().is_empty() {
        return Ok(BTreeMap::new());
    }
    serde_json::from_str::<BTreeMap<String, String>>(&s)
        .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, format!("invalid JSON: {e}")))
}

fn persist_atomic(path: &Path, map: &BTreeMap<String, String>) -> io::Result<()> {
    let dir = path.parent().ok_or_else(|| io_err("missing parent dir"))?;
    fs::create_dir_all(dir)?;

    let tmp = temp_path(path);
    let bytes = serde_json::to_vec(map)
        .map_err(|e| io::Error::new(io::ErrorKind::InvalidData, format!("serialize error: {e}")))?;

    {
        let mut f = fs::File::create(&tmp)?;
        f.write_all(&bytes)?;
        f.sync_all()?;
    }

    #[cfg(windows)]
    {
        if path.exists() {
            fs::remove_file(path)?;
        }
    }

    fs::rename(&tmp, path)?;
    fsync_dir_best_effort(dir);
    Ok(())
}

fn validate_key(key: &str) -> io::Result<()> {
    if key.is_empty() {
        return Err(io::Error::new(io::ErrorKind::InvalidInput, "key is empty"));
    }
    if key.len() > 256 {
        return Err(io::Error::new(io::ErrorKind::InvalidInput, "key too long"));
    }
    if key.chars().any(|c| c == '\n' || c == '\r' || c == '\0') {
        return Err(io::Error::new(
            io::ErrorKind::InvalidInput,
            "key contains invalid characters",
        ));
    }
    Ok(())
}

fn validate_value(value: &str) -> io::Result<()> {
    if value.len() > 1_000_000 {
        return Err(io::Error::new(io::ErrorKind::InvalidInput, "value too large"));
    }
    if value.chars().any(|c| c == '\0') {
        return Err(io::Error::new(
            io::ErrorKind::InvalidInput,
            "value contains invalid characters",
        ));
    }
    Ok(())
}

fn temp_path(path: &Path) -> PathBuf {
    let mut p = path.to_path_buf();
    let pid = std::process::id();
    let nanos = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default()
        .as_nanos();
    let file_name = format!(
        "{}.tmp.{}.{}",
        path.file_name()
            .and_then(|x| x.to_str())
            .unwrap_or("file"),
        pid,
        nanos
    );
    p.set_file_name(file_name);
    p
}

fn fsync_dir_best_effort(dir: &Path) {
    #[cfg(unix)]
    {
        use std::os::unix::fs::OpenOptionsExt;
        if let Ok(f) = fs::OpenOptions::new()
            .read(true)
            .custom_flags(libc::O_DIRECTORY)
            .open(dir)
        {
            let _ = f.sync_all();
        }
    }
}

fn io_err(msg: &str) -> io::Error {
    io::Error::new(io::ErrorKind::Other, msg.to_string())
}

#[cfg(test)]
mod tests {
    use super::KvStore;
    use std::fs;
    use std::path::PathBuf;

    #[test]
    fn persists_put_get_del() {
        let dir = PathBuf::from("target/tmp-kv-test");
        let _ = fs::remove_dir_all(&dir);

        let kv = KvStore::open(dir.clone()).unwrap();
        kv.put("a", "1").unwrap();
        assert_eq!(kv.get("a").unwrap(), Some("1".to_string()));

        let kv2 = KvStore::open(dir.clone()).unwrap();
        assert_eq!(kv2.get("a").unwrap(), Some("1".to_string()));

        assert_eq!(kv2.del("a").unwrap(), true);
        assert_eq!(kv2.get("a").unwrap(), None);
    }
}
