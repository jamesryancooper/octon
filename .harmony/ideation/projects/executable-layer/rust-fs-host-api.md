# Rust FS Host API Implementation

This document provides the **sandboxed filesystem host API** implementation for the Harmony kernel. It covers `ScopedFs` (the core sandboxing struct), all FS operations, the `fs::Host` trait implementation, security analysis, and policy recommendations.

> **Scope:** Filesystem host API only. For the canonical WIT contract (which includes the `fs` interface), `HostState` definition, and other host APIs (log, clock, kv), see [rust-kernel-reference.md](rust-kernel-reference.md). For normative contracts, see [spec-bundle.md](spec-bundle.md).

**Workspace root** = the repo root, i.e. the directory that *contains* the root `.harmony/`.

---

## 1) ScopedFs (sandboxed filesystem)

Create: `.harmony/runtime/crates/wasm_host/src/scoped_fs.rs`

This struct enforces:

- **repo-root sandboxing** — all paths must resolve under the workspace root
- **absolute path + `..` rejection** — no escape via path traversal
- **symlink escape prevention** — best-effort, cross-platform
- **atomic writes** — temp file + fsync + rename

```rust
use std::{
    fs,
    io,
    path::{Component, Path, PathBuf},
};

#[derive(Clone)]
pub struct ScopedFs {
    root: PathBuf, // repo root (canonicalized once)
}

impl ScopedFs {
    pub fn new(repo_root: PathBuf) -> io::Result<Self> {
        let root = canonicalize_existing(&repo_root)?;
        Ok(Self { root })
    }

    pub fn read_bytes(&self, user_path: &str) -> io::Result<Vec<u8>> {
        let rel = sanitize_relative(user_path)?;
        let joined = self.root.join(&rel);

        let target = canonicalize_existing(&joined)?;
        ensure_under_root(&self.root, &target)?;
        ensure_no_symlink_components_existing(&self.root, &rel)?;

        fs::read(target)
    }

    pub fn write_bytes_atomic(&self, user_path: &str, data: &[u8]) -> io::Result<()> {
        let rel = sanitize_relative(user_path)?;
        let joined = self.root.join(&rel);

        let parent_rel = rel.parent().ok_or_else(|| io_err("path has no parent"))?;
        let parent_joined = self.root.join(parent_rel);

        create_dir_all_checked(&self.root, parent_rel)?;

        if joined.exists() {
            let md = fs::symlink_metadata(&joined)?;
            if md.file_type().is_symlink() {
                return Err(io_err("refusing to write through symlink"));
            }
            let canon = canonicalize_existing(&joined)?;
            ensure_under_root(&self.root, &canon)?;
        } else {
            let canon_parent = canonicalize_existing(&parent_joined)?;
            ensure_under_root(&self.root, &canon_parent)?;
        }

        atomic_write_file(&joined, data)
    }

    pub fn read_text(&self, user_path: &str, max_bytes: usize) -> io::Result<String> {
        let bytes = self.read_bytes(user_path)?;
        if bytes.len() > max_bytes {
            return Err(io::Error::new(io::ErrorKind::InvalidInput, "file too large"));
        }
        String::from_utf8(bytes)
            .map_err(|_| io::Error::new(io::ErrorKind::InvalidData, "file is not valid UTF-8"))
    }

    pub fn write_text_atomic(&self, user_path: &str, text: &str, max_bytes: usize) -> io::Result<()> {
        if text.as_bytes().len() > max_bytes {
            return Err(io::Error::new(io::ErrorKind::InvalidInput, "text too large"));
        }
        self.write_bytes_atomic(user_path, text.as_bytes())
    }

    pub fn exists(&self, user_path: &str) -> io::Result<bool> {
        let rel = sanitize_relative(user_path)?;
        ensure_no_symlink_components_existing(&self.root, &rel)?;
        let joined = self.root.join(&rel);

        if !joined.exists() {
            return Ok(false);
        }

        let md = fs::symlink_metadata(&joined)?;
        if md.file_type().is_symlink() {
            return Ok(false);
        }

        let canon = canonicalize_existing(&joined)?;
        Ok(canon.starts_with(&self.root))
    }

    pub fn list_dir(&self, user_path: &str) -> io::Result<Vec<String>> {
        let rel = sanitize_relative(user_path)?;
        ensure_no_symlink_components_existing(&self.root, &rel)?;
        let joined = self.root.join(&rel);

        let canon = canonicalize_existing(&joined)?;
        ensure_under_root(&self.root, &canon)?;

        let md = fs::symlink_metadata(&joined)?;
        if md.file_type().is_symlink() {
            return Err(io::Error::new(io::ErrorKind::Other, "path is symlink"));
        }
        if !md.is_dir() {
            return Err(io::Error::new(io::ErrorKind::InvalidInput, "not a directory"));
        }

        let mut out = Vec::new();
        for entry in fs::read_dir(&canon)? {
            let entry = entry?;
            let name = entry.file_name();
            let name = name.to_string_lossy().to_string();
            out.push(name);
        }
        out.sort();
        Ok(out)
    }

    pub fn glob(&self, pattern: &str, max_results: usize) -> io::Result<Vec<String>> {
        let _ = sanitize_relative_pattern(pattern)?;

        let full_pattern = self.root.join(pattern).to_string_lossy().to_string();

        let mut out = Vec::new();
        for entry in glob::glob(&full_pattern)
            .map_err(|e| io::Error::new(io::ErrorKind::InvalidInput, format!("bad glob: {e}")))? {
            let path = entry.map_err(|e| io::Error::new(io::ErrorKind::Other, format!("glob err: {e}")))?;

            if let Ok(md) = fs::symlink_metadata(&path) {
                if md.file_type().is_symlink() {
                    continue;
                }
            }
            let canon = match path.canonicalize() {
                Ok(c) => c,
                Err(_) => continue,
            };
            if !canon.starts_with(&self.root) {
                continue;
            }

            let rel = canon.strip_prefix(&self.root)
                .map_err(|_| io::Error::new(io::ErrorKind::Other, "strip prefix failed"))?;
            out.push(rel.to_string_lossy().to_string());

            if out.len() >= max_results {
                break;
            }
        }
        out.sort();
        Ok(out)
    }

    pub fn mkdirp(&self, user_path: &str) -> io::Result<()> {
        let rel = sanitize_relative(user_path)?;
        create_dir_all_checked(&self.root, &rel)
    }

    pub fn remove_file(&self, user_path: &str) -> io::Result<()> {
        let rel = sanitize_relative(user_path)?;
        ensure_no_symlink_components_existing(&self.root, &rel)?;
        let joined = self.root.join(&rel);

        if !joined.exists() {
            return Ok(());
        }

        let md = fs::symlink_metadata(&joined)?;
        if md.file_type().is_symlink() {
            return Err(io::Error::new(io::ErrorKind::Other, "refusing to remove symlink"));
        }
        if md.is_dir() {
            return Err(io::Error::new(io::ErrorKind::InvalidInput, "path is a directory"));
        }

        let canon = canonicalize_existing(&joined)?;
        ensure_under_root(&self.root, &canon)?;
        fs::remove_file(&joined)
    }

    pub fn remove_dir_recursive(&self, user_path: &str) -> io::Result<()> {
        let rel = sanitize_relative(user_path)?;
        ensure_no_symlink_components_existing(&self.root, &rel)?;
        let joined = self.root.join(&rel);

        if !joined.exists() {
            return Ok(());
        }

        let md = fs::symlink_metadata(&joined)?;
        if md.file_type().is_symlink() {
            return Err(io::Error::new(io::ErrorKind::Other, "refusing to remove symlink dir"));
        }
        if !md.is_dir() {
            return Err(io::Error::new(io::ErrorKind::InvalidInput, "not a directory"));
        }

        let canon = canonicalize_existing(&joined)?;
        ensure_under_root(&self.root, &canon)?;

        remove_dir_all_checked(&joined)
    }

    pub fn stat(&self, user_path: &str) -> io::Result<Option<Stat>> {
        let rel = sanitize_relative(user_path)?;
        ensure_no_symlink_components_existing(&self.root, &rel)?;
        let joined = self.root.join(&rel);

        if !joined.exists() {
            return Ok(None);
        }

        let md = fs::symlink_metadata(&joined)?;
        if md.file_type().is_symlink() {
            return Ok(None);
        }

        let canon = canonicalize_existing(&joined)?;
        ensure_under_root(&self.root, &canon)?;

        let kind = if md.is_dir() { NodeKind::Dir } else { NodeKind::File };
        let size = if md.is_file() { md.len() } else { 0 };

        let modified_ms = md.modified().ok().and_then(|t| {
            t.duration_since(std::time::UNIX_EPOCH).ok().map(|d| d.as_millis() as u64)
        });

        Ok(Some(Stat { kind, size, modified_ms }))
    }
}

#[derive(Clone, Debug)]
pub enum NodeKind { File, Dir }

#[derive(Clone, Debug)]
pub struct Stat {
    pub kind: NodeKind,
    pub size: u64,
    pub modified_ms: Option<u64>,
}
```

---

## 2) Path sanitization and security helpers

```rust
/// Reject absolute paths, prefixes, and any `..` components.
fn sanitize_relative(user_path: &str) -> io::Result<PathBuf> {
    if user_path.trim().is_empty() {
        return Err(io::Error::new(io::ErrorKind::InvalidInput, "empty path"));
    }

    let p = Path::new(user_path);
    let mut out = PathBuf::new();
    for c in p.components() {
        match c {
            Component::Normal(seg) => out.push(seg),
            Component::CurDir => {}
            Component::ParentDir => {
                return Err(io::Error::new(io::ErrorKind::InvalidInput, "parent dir '..' not allowed"))
            }
            Component::RootDir | Component::Prefix(_) => {
                return Err(io::Error::new(io::ErrorKind::InvalidInput, "absolute paths not allowed"))
            }
        }
    }

    if out.as_os_str().is_empty() {
        return Err(io::Error::new(io::ErrorKind::InvalidInput, "path resolves to empty"));
    }
    Ok(out)
}

/// Like sanitize_relative but allows glob wildcards in segments.
fn sanitize_relative_pattern(pattern: &str) -> io::Result<PathBuf> {
    if pattern.trim().is_empty() {
        return Err(io::Error::new(io::ErrorKind::InvalidInput, "empty pattern"));
    }
    let p = Path::new(pattern);
    let mut out = PathBuf::new();
    for c in p.components() {
        use std::path::Component::*;
        match c {
            Normal(seg) => out.push(seg),
            CurDir => {}
            ParentDir => return Err(io::Error::new(io::ErrorKind::InvalidInput, "pattern cannot contain '..'")),
            RootDir | Prefix(_) => return Err(io::Error::new(io::ErrorKind::InvalidInput, "absolute patterns not allowed")),
        }
    }
    if out.as_os_str().is_empty() {
        return Err(io::Error::new(io::ErrorKind::InvalidInput, "pattern resolves to empty"));
    }
    Ok(out)
}

fn canonicalize_existing(path: &Path) -> io::Result<PathBuf> {
    path.canonicalize().map_err(|e| {
        io::Error::new(e.kind(), format!("canonicalize failed for {}: {}", path.display(), e))
    })
}

fn ensure_under_root(root: &Path, target: &Path) -> io::Result<()> {
    if target.starts_with(root) {
        Ok(())
    } else {
        Err(io_err("path escapes workspace root"))
    }
}

/// Walk existing components under root and reject symlinks.
fn ensure_no_symlink_components_existing(root: &Path, rel: &Path) -> io::Result<()> {
    let mut cur = root.to_path_buf();
    for comp in rel.components() {
        if let Component::Normal(seg) = comp {
            cur.push(seg);
            if cur.exists() {
                let md = fs::symlink_metadata(&cur)?;
                if md.file_type().is_symlink() {
                    return Err(io_err("path contains symlink component"));
                }
            }
        }
    }
    Ok(())
}

/// Create directories one component at a time, rejecting symlinks.
fn create_dir_all_checked(root: &Path, rel_dir: &Path) -> io::Result<()> {
    let mut cur = root.to_path_buf();

    for comp in rel_dir.components() {
        match comp {
            Component::Normal(seg) => {
                cur.push(seg);

                if cur.exists() {
                    let md = fs::symlink_metadata(&cur)?;
                    if md.file_type().is_symlink() {
                        return Err(io_err("refusing to traverse symlink directory"));
                    }
                    if !md.is_dir() {
                        return Err(io_err("expected directory but found file"));
                    }
                } else {
                    fs::create_dir(&cur)?;
                }
            }
            Component::CurDir => {}
            Component::ParentDir => return Err(io_err(".. not allowed")),
            Component::RootDir | Component::Prefix(_) => return Err(io_err("absolute paths not allowed")),
        }
    }

    let canon = canonicalize_existing(&cur)?;
    ensure_under_root(root, &canon)
}

/// Recursively removes a directory tree without traversing symlinks.
fn remove_dir_all_checked(dir: &Path) -> io::Result<()> {
    for entry in fs::read_dir(dir)? {
        let entry = entry?;
        let path = entry.path();

        let md = fs::symlink_metadata(&path)?;
        if md.file_type().is_symlink() {
            return Err(io::Error::new(io::ErrorKind::Other, "refusing to traverse symlink"));
        }

        if md.is_dir() {
            remove_dir_all_checked(&path)?;
            fs::remove_dir(&path)?;
        } else {
            fs::remove_file(&path)?;
        }
    }
    fs::remove_dir(dir)
}
```

---

## 3) Atomic write helpers

These utilities are shared with `KvStore` (see [rust-kernel-reference.md §11](rust-kernel-reference.md)). In practice, place them in a shared module or duplicate as needed.

```rust
fn atomic_write_file(dest: &Path, data: &[u8]) -> io::Result<()> {
    let dir = dest.parent().ok_or_else(|| io_err("missing parent dir"))?;
    let tmp = temp_path(dest);

    {
        let mut f = fs::File::create(&tmp)?;
        use std::io::Write;
        f.write_all(data)?;
        f.sync_all()?;
    }

    #[cfg(windows)]
    {
        if dest.exists() {
            fs::remove_file(dest)?;
        }
    }

    fs::rename(&tmp, dest)?;
    fsync_dir_best_effort(dir);
    Ok(())
}

fn temp_path(dest: &Path) -> PathBuf {
    let mut p = dest.to_path_buf();
    let pid = std::process::id();
    let nanos = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default()
        .as_nanos();
    let file_name = format!(
        "{}.tmp.{}.{}",
        dest.file_name().and_then(|x| x.to_str()).unwrap_or("file"),
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
        if let Ok(f) = fs::OpenOptions::new().read(true).custom_flags(libc::O_DIRECTORY).open(dir) {
            let _ = f.sync_all();
        }
    }
}

fn io_err(msg: &str) -> io::Error {
    io::Error::new(io::ErrorKind::Other, msg.to_string())
}
```

### Security note

This is **strong best-effort** sandboxing with symlink checks and canonicalization. A fully race-free implementation requires OS-specific "openat-style" APIs and `O_NOFOLLOW`/reparse-point handling per component; that level of complexity isn't uniformly portable. For repo-local harness use, the above is the right balance.

---

## 4) `fs::Host` trait implementation (capability-gated)

In `.harmony/runtime/crates/wasm_host/src/host_api.rs`, alongside the log/clock/kv implementations from [rust-kernel-reference.md §13](rust-kernel-reference.md):

```rust
use crate::bindings::fs;
use crate::state::HostState;

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
```

---

## 5) Capability gating summary

| Operation | Required capability |
| --- | --- |
| `read`, `read_text`, `exists`, `list_dir`, `glob`, `stat` | `fs.read` |
| `write`, `write_text`, `mkdirp`, `remove_file`, `remove_dir_recursive` | `fs.write` |

### Recommended default policy

- Default deny `fs.write`
- Allow `fs.read` for a narrow subset of services (or none by default)
- Enforce Harmony's "no silent apply" rule at the orchestration/skill layer before enabling write paths

---

## 6) Guest-side usage

After regenerating bindings (see [rust-service-authoring.md](rust-service-authoring.md)), services can call:

```rust
let s = bindings::fs::read_text("README.md");
bindings::fs::write_text("output/report.md", s);
let files = bindings::fs::glob("src/**/*.rs");
let info = bindings::fs::stat("Cargo.toml");
bindings::fs::mkdirp("output/data");
```

The kernel enforces capability grants, repo-root sandboxing, and symlink traversal prevention transparently.

### Behavior guarantees

- All paths are **repo-root sandboxed**
- Absolute paths and `..` are rejected
- Symlink traversal is **blocked best-effort** (rejects symlink components; ignores symlink hits in glob results)
- Writes are **atomic-ish** (temp write + rename) and safe on Windows (dest removed first)
- Deletion is **strict**: encountering a symlink anywhere inside a recursive delete fails closed

### Dependency note

The `glob()` method requires the `glob` crate. Add to `crates/wasm_host/Cargo.toml`:

```toml
glob = "0.3"
```
