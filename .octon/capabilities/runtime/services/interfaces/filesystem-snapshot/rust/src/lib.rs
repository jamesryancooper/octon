use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use std::cell::RefCell;
use std::collections::{BTreeMap, BTreeSet, VecDeque};
use std::path::{Component, Path};

#[allow(warnings)]
mod bindings;

#[derive(Default)]
pub struct Service;

const CONTRACT_VERSION: &str = "1.0.0";
const SNAPSHOT_FORMAT_VERSION: u64 = 2;
const SNAPSHOT_MIN_SUPPORTED_FORMAT_VERSION: u64 = 1;
const SNAPSHOT_MAX_SUPPORTED_FORMAT_VERSION: u64 = SNAPSHOT_FORMAT_VERSION;
const DEFAULT_STATE_DIR: &str = ".octon/engine/_ops/state/snapshots";
const RUNTIME_STATE_ROOT: &str = ".octon/engine/_ops/state";
const SERVICES_BUILD_STATE_ROOT: &str = ".octon/capabilities/runtime/services/_ops/state/build";
const HASH_CACHE_FILE: &str = "hash-cache.jsonl";
const SEARCH_INDEX_FILE: &str = "search-index.jsonl";
const SNAPSHOT_READY_MARKER: &str = ".ready";
const SNAPSHOT_BUILDING_MARKER: &str = ".building";
const SNAPSHOT_BUILD_LOCK_FILE: &str = ".snapshot-build.lock";
const DEFAULT_SNAPSHOT_MAX_FILES: u64 = 200_000;
const DEFAULT_SNAPSHOT_MAX_TOTAL_BYTES: u64 = 512 * 1024 * 1024;
const DEFAULT_SNAPSHOT_MAX_OP_MS: u64 = 90_000;
const DEFAULT_SNAPSHOT_LOCK_STALE_MS: u64 = 15 * 60 * 1000;
const DEFAULT_SNAPSHOT_GC_MAX_SNAPSHOTS: u64 = 128;
const DEFAULT_SNAPSHOT_GC_MAX_AGE_HOURS: u64 = 24 * 30;
const DEFAULT_SNAPSHOT_GC_MAX_STATE_BYTES: u64 = 4 * 1024 * 1024 * 1024;
const DEFAULT_DISCOVER_MAX_OP_MS: u64 = 5_000;
const DEFAULT_DISCOVER_MAX_CONTENT_BYTES_PER_FILE: u64 = 64 * 1024;
const CACHE_PROBE_HEAD_BYTES: u64 = 2048;
const CACHE_PROBE_TAIL_BYTES: u64 = 2048;

#[derive(Debug)]
struct ServiceError {
    code: &'static str,
    message: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct FileRecord {
    path: String,
    sha256: String,
    size_bytes: u64,
    #[serde(default, alias = "modified_epoch")]
    modified_ms: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct NodeRecord {
    node_id: String,
    #[serde(rename = "type")]
    node_type: String,
    path: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    sha256: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct EdgeRecord {
    src: String,
    dst: String,
    #[serde(rename = "type")]
    edge_type: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct HashCacheRecord {
    path: String,
    size_bytes: u64,
    #[serde(default, alias = "modified_epoch")]
    modified_ms: u64,
    sha256: String,
    #[serde(default)]
    probe_sha256: String,
    #[serde(default)]
    probe_len: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
struct SearchIndexRecord {
    node_id: String,
    path: String,
    path_lc: String,
    terms: Vec<String>,
}

#[derive(Debug, Clone)]
struct SnapshotData {
    snapshot_id: String,
    manifest: Value,
    files: Vec<FileRecord>,
    nodes: Vec<NodeRecord>,
    edges: Vec<EdgeRecord>,
    search_index: Vec<SearchIndexRecord>,
}

#[derive(Debug, Default, Clone, Copy)]
struct OpCounters {
    scanned_files: u64,
    bytes_read: u64,
}

#[derive(Debug, Clone, Copy)]
struct SnapshotLimits {
    max_files: u64,
    max_total_bytes: u64,
    deadline_ms: u64,
}

#[derive(Debug, Default, Clone, Copy)]
struct SnapshotProgress {
    files_scanned: u64,
    total_size: u64,
}

#[derive(Debug, Clone)]
struct SnapshotDirInfo {
    id: String,
    path: String,
    modified_ms: u64,
    size_bytes: u64,
}

#[derive(Debug, Default, Clone, Copy, Serialize)]
struct SnapshotGcStats {
    deleted_snapshots: u64,
    deleted_bytes: u64,
    remaining_snapshots: u64,
    remaining_bytes: u64,
}

#[derive(Debug)]
struct SnapshotBuildLock {
    path: String,
    held: bool,
}

impl Drop for SnapshotBuildLock {
    fn drop(&mut self) {
        if !self.held {
            return;
        }
        if fs_exists(&self.path) {
            bindings::fs::remove_file(&self.path);
        }
        self.held = false;
    }
}

thread_local! {
    static OP_COUNTERS: RefCell<OpCounters> = RefCell::new(OpCounters::default());
}

impl bindings::Guest for Service {
    fn invoke(op: String, input_json: String) -> String {
        let started_ms = monotonic_now_ms();
        let input_bytes = input_json.len() as u64;
        reset_op_counters();

        let (out, status, error_code) = match serde_json::from_str::<Value>(&input_json) {
            Ok(v) if v.is_object() => match handle_op(&op, &v) {
                Ok(value) => match serde_json::to_string(&value) {
                    Ok(encoded) => (encoded, "ok", None),
                    Err(_) => (
                        error_json(
                            "ERR_FILESYSTEM_INTERFACES_INTERNAL",
                            "Failed to serialize service output.",
                        ),
                        "error",
                        Some("ERR_FILESYSTEM_INTERFACES_INTERNAL".to_string()),
                    ),
                },
                Err(e) => (
                    error_json(e.code, &e.message),
                    "error",
                    Some(e.code.to_string()),
                ),
            },
            Ok(_) => (
                error_json(
                    "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
                    "Input must be a JSON object.",
                ),
                "error",
                Some("ERR_FILESYSTEM_INTERFACES_INPUT_INVALID".to_string()),
            ),
            Err(e) => (
                error_json(
                    "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
                    &format!("Invalid JSON input: {e}"),
                ),
                "error",
                Some("ERR_FILESYSTEM_INTERFACES_INPUT_INVALID".to_string()),
            ),
        };
        let counters = snapshot_op_counters();

        emit_runtime_metric(
            &op,
            status,
            error_code.as_deref(),
            started_ms,
            monotonic_now_ms(),
            input_bytes,
            out.len() as u64,
            counters.scanned_files,
            counters.bytes_read,
        );

        out
    }
}

fn emit_runtime_metric(
    op: &str,
    status: &str,
    error_code: Option<&str>,
    started_ms: u64,
    ended_ms: u64,
    input_bytes: u64,
    output_bytes: u64,
    scanned_files: u64,
    bytes_read: u64,
) {
    let duration_ms = ended_ms.saturating_sub(started_ms);
    let slo_ms = op_latency_budget_ms(op);
    let slo_status = if duration_ms <= slo_ms {
        "ok"
    } else {
        "violation"
    };
    let level = if status != "ok" {
        "error"
    } else if slo_status == "violation" {
        "warn"
    } else {
        "info"
    };

    let metric = json!({
        "event": "filesystem_interfaces.metric",
        "service": "filesystem-snapshot",
        "contract_version": CONTRACT_VERSION,
        "op": op,
        "status": status,
        "error_code": error_code,
        "duration_ms": duration_ms,
        "slo_ms": slo_ms,
        "slo_status": slo_status,
        "input_bytes": input_bytes,
        "output_bytes": output_bytes,
        "scanned_files": scanned_files,
        "bytes_read": bytes_read,
        "ended_at": epoch_ms_to_rfc3339(ended_ms)
    });

    runtime_log(level, &metric.to_string());
}

fn op_latency_budget_ms(op: &str) -> u64 {
    match op {
        "fs.list" => 125,
        "fs.read" => 166,
        "fs.stat" => 117,
        "fs.search" => 500,
        "snapshot.build" => 1_500,
        "snapshot.diff" => 400,
        "snapshot.get-current" => 120,
        "kg.get-node" => 120,
        "kg.neighbors" => 200,
        "kg.traverse" => 300,
        "kg.resolve-to-file" => 141,
        "discover.start" => 500,
        "discover.expand" => 250,
        "discover.explain" => 250,
        "discover.resolve" => 260,
        _ => 2_000,
    }
}

fn reset_op_counters() {
    OP_COUNTERS.with(|c| *c.borrow_mut() = OpCounters::default());
}

fn snapshot_op_counters() -> OpCounters {
    OP_COUNTERS.with(|c| *c.borrow())
}

fn add_bytes_read(n: u64) {
    OP_COUNTERS.with(|c| {
        let mut counters = c.borrow_mut();
        counters.bytes_read = counters.bytes_read.saturating_add(n);
    });
}

fn mark_files_scanned(n: u64) {
    OP_COUNTERS.with(|c| {
        let mut counters = c.borrow_mut();
        counters.scanned_files = counters.scanned_files.saturating_add(n);
    });
}

fn read_bytes(path: &str) -> Vec<u8> {
    let bytes = bindings::fs::read(path);
    add_bytes_read(bytes.len() as u64);
    bytes
}

fn read_bytes_range(path: &str, offset: u64, max_bytes: u64) -> Vec<u8> {
    let bytes = bindings::fs::read_range(path, offset, max_bytes);
    add_bytes_read(bytes.len() as u64);
    bytes
}

fn handle_op(op: &str, input: &Value) -> Result<Value, ServiceError> {
    match op {
        "fs.list" => op_fs_list(input),
        "fs.read" => op_fs_read(input),
        "fs.stat" => op_fs_stat(input),
        "fs.search" => op_fs_search(input),
        "snapshot.build" => op_snapshot_build(input),
        "snapshot.diff" => op_snapshot_diff(input),
        "snapshot.get-current" => op_snapshot_get_current(input),
        "kg.get-node" => op_kg_get_node(input),
        "kg.neighbors" => op_kg_neighbors(input),
        "kg.traverse" => op_kg_traverse(input),
        "kg.resolve-to-file" => op_resolve(input),
        "discover.start" => op_discover_start(input),
        "discover.expand" => op_discover_expand(input),
        "discover.explain" => op_discover_explain(input),
        "discover.resolve" => op_resolve(input),
        _ => Err(err(
            "ERR_FILESYSTEM_INTERFACES_OPERATION_UNSUPPORTED",
            format!("Unsupported operation: {op}"),
        )),
    }
}

fn op_fs_list(input: &Value) -> Result<Value, ServiceError> {
    let path = norm_rel_or_default(get_str(input, "path")?, ".")?;
    let limit = get_u64_or(input, "limit", 200) as usize;

    match fs_get_stat(&path) {
        Some(stat) => {
            if !matches!(stat.kind, bindings::fs::NodeKind::Dir) {
                return Err(err(
                    "ERR_FILESYSTEM_INTERFACES_PATH_INVALID",
                    format!("Path is not a directory: {path}"),
                ));
            }
        }
        None => {
            return Err(err(
                "ERR_FILESYSTEM_INTERFACES_NOT_FOUND",
                format!("Directory not found: {path}"),
            ))
        }
    }

    let mut entries = fs_list_dir_paths(&path);
    entries.sort();

    let mut out = Vec::new();
    for child in entries.into_iter().take(limit) {
        let name = basename(&child);
        let kind = match fs_get_stat(&child) {
            Some(stat) => match stat.kind {
                bindings::fs::NodeKind::File => "file",
                bindings::fs::NodeKind::Dir => "dir",
            },
            None => "missing",
        };
        out.push(json!({"name": name, "kind": kind}));
    }

    Ok(json!({"path": path, "entries": out}))
}

fn op_fs_read(input: &Value) -> Result<Value, ServiceError> {
    let path = norm_rel_required(get_str(input, "path")?)?;
    let max_bytes = get_u64_or(input, "max_bytes", 16_384) as usize;

    match fs_get_stat(&path) {
        Some(stat) => {
            if !matches!(stat.kind, bindings::fs::NodeKind::File) {
                return Err(err(
                    "ERR_FILESYSTEM_INTERFACES_PATH_INVALID",
                    format!("Path is not a file: {path}"),
                ));
            }
        }
        None => {
            return Err(err(
                "ERR_FILESYSTEM_INTERFACES_NOT_FOUND",
                format!("File not found: {path}"),
            ))
        }
    }

    let stat = fs_get_stat(&path).ok_or_else(|| {
        err(
            "ERR_FILESYSTEM_INTERFACES_NOT_FOUND",
            format!("File not found: {path}"),
        )
    })?;

    mark_files_scanned(1);
    let cut = (stat.size as usize).min(max_bytes);
    let bytes = read_bytes_range(&path, 0, cut as u64);
    let content = String::from_utf8_lossy(&bytes).to_string();

    Ok(json!({
        "path": path,
        "content": content,
        "total_size": stat.size,
        "max_bytes": max_bytes,
        "truncated": stat.size as usize > max_bytes
    }))
}

fn op_fs_stat(input: &Value) -> Result<Value, ServiceError> {
    let path = norm_rel_required(get_str(input, "path")?)?;

    let stat = fs_get_stat(&path).ok_or_else(|| {
        err(
            "ERR_FILESYSTEM_INTERFACES_NOT_FOUND",
            format!("Path not found: {path}"),
        )
    })?;

    let kind = match stat.kind {
        bindings::fs::NodeKind::File => "file",
        bindings::fs::NodeKind::Dir => "dir",
    };

    Ok(json!({
        "path": path,
        "kind": kind,
        "size_bytes": stat.size,
        "modified_epoch": stat.modified_ms.unwrap_or(0) / 1000
    }))
}

fn op_fs_search(input: &Value) -> Result<Value, ServiceError> {
    let pattern = get_str(input, "pattern")?.unwrap_or_default();
    if pattern.trim().is_empty() {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
            "payload.pattern is required.",
        ));
    }

    let path = norm_rel_or_default(get_str(input, "path")?, ".")?;
    let limit = get_u64_or(input, "limit", 50) as usize;

    let stat = fs_get_stat(&path).ok_or_else(|| {
        err(
            "ERR_FILESYSTEM_INTERFACES_NOT_FOUND",
            format!("Path not found: {path}"),
        )
    })?;

    let mut files = Vec::new();
    match stat.kind {
        bindings::fs::NodeKind::File => files.push(path.clone()),
        bindings::fs::NodeKind::Dir => {
            collect_files_recursive(&path, DEFAULT_STATE_DIR, &mut files)?
        }
    }

    let mut hits = Vec::new();
    let pattern_lower = pattern.to_lowercase();

    for file_path in files {
        if hits.len() >= limit {
            break;
        }
        search_file(&file_path, &pattern_lower, &mut hits, limit);
    }

    Ok(json!({"pattern": pattern, "path": path, "hits": hits}))
}

fn op_snapshot_build(input: &Value) -> Result<Value, ServiceError> {
    let root = norm_rel_or_default(get_str(input, "root")?, ".")?;
    let state_dir = norm_rel_or_default(get_str(input, "state_dir")?, DEFAULT_STATE_DIR)?;
    let set_current = get_bool_or(input, "set_current", true);
    let max_files = get_u64_or(input, "max_files", DEFAULT_SNAPSHOT_MAX_FILES);
    let max_total_bytes = get_u64_or(input, "max_total_bytes", DEFAULT_SNAPSHOT_MAX_TOTAL_BYTES);
    let max_op_ms = get_u64_or(input, "max_op_ms", DEFAULT_SNAPSHOT_MAX_OP_MS);
    let lock_stale_ms = get_u64_or(input, "lock_stale_ms", DEFAULT_SNAPSHOT_LOCK_STALE_MS);
    let gc_max_snapshots = get_u64_or(input, "gc_max_snapshots", DEFAULT_SNAPSHOT_GC_MAX_SNAPSHOTS);
    let gc_max_age_hours = get_u64_or(input, "gc_max_age_hours", DEFAULT_SNAPSHOT_GC_MAX_AGE_HOURS);
    let gc_max_state_bytes = get_u64_or(
        input,
        "gc_max_state_bytes",
        DEFAULT_SNAPSHOT_GC_MAX_STATE_BYTES,
    );

    if max_files == 0 {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
            "max_files must be >= 1.",
        ));
    }

    if max_total_bytes == 0 {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
            "max_total_bytes must be >= 1.",
        ));
    }

    if max_op_ms == 0 {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
            "max_op_ms must be >= 1.",
        ));
    }

    if lock_stale_ms == 0 {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
            "lock_stale_ms must be >= 1.",
        ));
    }

    if gc_max_snapshots == 0 {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
            "gc_max_snapshots must be >= 1.",
        ));
    }

    match fs_get_stat(&root) {
        Some(stat) => {
            if !matches!(stat.kind, bindings::fs::NodeKind::Dir) {
                return Err(err(
                    "ERR_FILESYSTEM_INTERFACES_PATH_INVALID",
                    format!("Root is not a directory: {root}"),
                ));
            }
        }
        None => {
            return Err(err(
                "ERR_FILESYSTEM_INTERFACES_PATH_INVALID",
                format!("Root path not found: {root}"),
            ))
        }
    }

    if !fs_exists(&state_dir) {
        bindings::fs::mkdirp(&state_dir);
    }

    let _build_lock = acquire_snapshot_build_lock(&state_dir, lock_stale_ms)?;
    cleanup_snapshot_build_transients(&state_dir)?;

    let cache_path = join_path(&state_dir, HASH_CACHE_FILE);
    let cache_by_path = load_hash_cache(&cache_path)?;
    let mut cache_next: BTreeMap<String, HashCacheRecord> = BTreeMap::new();

    let mut files = Vec::new();
    let mut dirs = BTreeSet::new();
    let mut edges: BTreeSet<(String, String, String)> = BTreeSet::new();
    let mut progress = SnapshotProgress::default();
    let limits = SnapshotLimits {
        max_files,
        max_total_bytes,
        deadline_ms: monotonic_now_ms().saturating_add(max_op_ms),
    };

    collect_snapshot_data(
        &root,
        &state_dir,
        &cache_by_path,
        &mut cache_next,
        &mut files,
        &mut dirs,
        &mut edges,
        &limits,
        &mut progress,
    )?;

    if files.is_empty() {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_NOT_FOUND",
            "No files discovered for snapshot.",
        ));
    }

    files.sort_by(|a, b| a.path.cmp(&b.path));

    let mut file_lines = Vec::new();
    let mut seed_lines = Vec::new();
    for f in &files {
        file_lines.push(serde_json::to_string(f).map_err(|e| {
            err(
                "ERR_FILESYSTEM_INTERFACES_INTERNAL",
                format!("Failed to serialize file record: {e}"),
            )
        })?);
        seed_lines.push(format!("{}\t{}\t{}", f.path, f.sha256, f.size_bytes));
    }
    seed_lines.sort();

    let input_fingerprint = sha256_hex(seed_lines.join("\n").as_bytes());
    let snapshot_id = format!("snap-{}", &input_fingerprint[..16]);
    let snapshot_dir = join_path(&state_dir, &snapshot_id);
    let staging_dir = join_path(
        &state_dir,
        &format!(".staging-{snapshot_id}-{}", monotonic_now_ms()),
    );

    let mut node_lines = Vec::new();
    for dir_path in &dirs {
        let node = NodeRecord {
            node_id: format!("dir:{dir_path}"),
            node_type: "dir".to_string(),
            path: dir_path.clone(),
            sha256: None,
        };
        node_lines.push(serde_json::to_string(&node).map_err(|e| {
            err(
                "ERR_FILESYSTEM_INTERFACES_INTERNAL",
                format!("Failed to serialize dir node: {e}"),
            )
        })?);
    }

    for f in &files {
        let node = NodeRecord {
            node_id: format!("file:{}", f.path),
            node_type: "file".to_string(),
            path: f.path.clone(),
            sha256: Some(f.sha256.clone()),
        };
        node_lines.push(serde_json::to_string(&node).map_err(|e| {
            err(
                "ERR_FILESYSTEM_INTERFACES_INTERNAL",
                format!("Failed to serialize file node: {e}"),
            )
        })?);
    }

    let mut edge_lines = Vec::new();
    for (src, dst, edge_type) in &edges {
        let edge = EdgeRecord {
            src: src.clone(),
            dst: dst.clone(),
            edge_type: edge_type.clone(),
        };
        edge_lines.push(serde_json::to_string(&edge).map_err(|e| {
            err(
                "ERR_FILESYSTEM_INTERFACES_INTERNAL",
                format!("Failed to serialize edge: {e}"),
            )
        })?);
    }

    let search_index = build_search_index(&files);
    let search_index_lines: Vec<String> = search_index
        .iter()
        .map(|r| {
            serde_json::to_string(r).map_err(|e| {
                err(
                    "ERR_FILESYSTEM_INTERFACES_INTERNAL",
                    format!("Failed to serialize search index record: {e}"),
                )
            })
        })
        .collect::<Result<Vec<_>, _>>()?;

    let manifest = json!({
        "snapshot_format_version": SNAPSHOT_FORMAT_VERSION,
        "snapshot_id": snapshot_id,
        "root": root,
        "input_fingerprint": input_fingerprint,
        "created_at": now_rfc3339(),
        "counts": {
            "files": file_lines.len(),
            "nodes": node_lines.len(),
            "edges": edge_lines.len()
        }
    });

    let manifest_json = serde_json::to_string(&manifest).map_err(|e| {
        err(
            "ERR_FILESYSTEM_INTERFACES_INTERNAL",
            format!("Failed to serialize manifest: {e}"),
        )
    })?;

    let snapshot_ready = snapshot_dir_is_ready(&snapshot_dir);
    if !snapshot_ready {
        if fs_exists(&staging_dir) {
            bindings::fs::remove_dir_recursive(&staging_dir);
        }
        bindings::fs::mkdirp(&staging_dir);
        let staging_building_marker = join_path(&staging_dir, SNAPSHOT_BUILDING_MARKER);
        write_text_file(
            &staging_building_marker,
            &format!("started_at={}", epoch_ms_to_rfc3339(monotonic_now_ms())),
        )?;
        write_jsonl_file(&join_path(&staging_dir, "files.jsonl"), &file_lines)?;
        write_jsonl_file(&join_path(&staging_dir, "nodes.jsonl"), &node_lines)?;
        write_jsonl_file(&join_path(&staging_dir, "edges.jsonl"), &edge_lines)?;
        write_jsonl_file(&join_path(&staging_dir, SEARCH_INDEX_FILE), &search_index_lines)?;
        write_text_file(&join_path(&staging_dir, "manifest.json"), &manifest_json)?;
        write_text_file(
            &join_path(&staging_dir, SNAPSHOT_READY_MARKER),
            &format!("ready_at={}", epoch_ms_to_rfc3339(monotonic_now_ms())),
        )?;
        if fs_exists(&staging_building_marker) {
            bindings::fs::remove_file(&staging_building_marker);
        }

        if fs_exists(&snapshot_dir) {
            bindings::fs::remove_dir_recursive(&snapshot_dir);
        }
        bindings::fs::rename(&staging_dir, &snapshot_dir);
    } else if fs_exists(&staging_dir) {
        bindings::fs::remove_dir_recursive(&staging_dir);
    }

    write_hash_cache(&cache_path, &cache_next)?;

    if set_current {
        write_text_file(&join_path(&state_dir, "current"), &snapshot_id)?;
    }

    let mut gc_keep_ids = BTreeSet::new();
    gc_keep_ids.insert(snapshot_id.clone());
    let current_path = join_path(&state_dir, "current");
    if fs_exists(&current_path) {
        let current = read_text_file(&current_path).unwrap_or_default();
        let current = current.trim();
        if !current.is_empty() {
            gc_keep_ids.insert(current.to_string());
        }
    }
    let gc = run_snapshot_gc(
        &state_dir,
        &gc_keep_ids,
        gc_max_snapshots,
        gc_max_age_hours,
        gc_max_state_bytes,
    )?;

    Ok(json!({
        "ok": true,
        "snapshot_id": snapshot_id,
        "snapshot_dir": snapshot_dir,
        "manifest": join_path(&snapshot_dir, "manifest.json"),
        "counts": {
            "files": file_lines.len(),
            "nodes": node_lines.len(),
            "edges": edge_lines.len()
        },
        "set_current": set_current,
        "limits": {
            "max_files": max_files,
            "max_total_bytes": max_total_bytes,
            "max_op_ms": max_op_ms,
            "lock_stale_ms": lock_stale_ms
        },
        "gc": gc
    }))
}

fn op_snapshot_get_current(input: &Value) -> Result<Value, ServiceError> {
    let state_dir = norm_rel_or_default(get_str(input, "state_dir")?, DEFAULT_STATE_DIR)?;
    let current_path = join_path(&state_dir, "current");

    if !fs_exists(&current_path) {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_NOT_FOUND",
            "No active snapshot pointer found.",
        ));
    }

    let snapshot_id = read_text_file(&current_path)?.trim().to_string();
    if snapshot_id.is_empty() {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_SNAPSHOT_INVALID",
            "Active snapshot pointer is empty.",
        ));
    }

    let snapshot_dir = join_path(&state_dir, &snapshot_id);
    let manifest_path = join_path(&snapshot_dir, "manifest.json");
    let ready_marker = join_path(&snapshot_dir, SNAPSHOT_READY_MARKER);
    let building_marker = join_path(&snapshot_dir, SNAPSHOT_BUILDING_MARKER);

    if fs_exists(&building_marker) && !fs_exists(&ready_marker) {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_SNAPSHOT_INVALID",
            format!(
                "Active snapshot is incomplete: {snapshot_id}. {}",
                snapshot_rebuild_hint(&state_dir)
            ),
        ));
    }

    let manifest = if fs_exists(&manifest_path) {
        let manifest_text = read_text_file(&manifest_path)?;
        let parsed = serde_json::from_str::<Value>(&manifest_text).map_err(|e| {
            err(
                "ERR_FILESYSTEM_INTERFACES_SNAPSHOT_INVALID",
                format!(
                    "Active snapshot manifest is invalid JSON: {e}. {}",
                    snapshot_rebuild_hint(&state_dir)
                ),
            )
        })?;
        ensure_supported_snapshot_format(&parsed, &state_dir)?;
        parsed
    } else {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_SNAPSHOT_INVALID",
            format!(
                "Active snapshot manifest is missing: {manifest_path}. {}",
                snapshot_rebuild_hint(&state_dir)
            ),
        ));
    };

    Ok(json!({
        "snapshot_id": snapshot_id,
        "snapshot_dir": snapshot_dir,
        "manifest": manifest
    }))
}

fn op_snapshot_diff(input: &Value) -> Result<Value, ServiceError> {
    let state_dir = norm_rel_or_default(get_str(input, "state_dir")?, DEFAULT_STATE_DIR)?;
    let base_input = get_str(input, "base")?.unwrap_or_default();
    let head_input = get_str(input, "head")?.unwrap_or_default();

    if base_input.is_empty() || head_input.is_empty() {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
            "Both base and head are required.",
        ));
    }

    let (base_id, base_dir) = resolve_snapshot_ref(&state_dir, &base_input)?;
    let (head_id, head_dir) = resolve_snapshot_ref(&state_dir, &head_input)?;

    let base_files = parse_files_map(&join_path(&base_dir, "files.jsonl"))?;
    let head_files = parse_files_map(&join_path(&head_dir, "files.jsonl"))?;

    let (added, removed, changed) = compute_snapshot_diff(&base_files, &head_files);

    Ok(json!({
        "ok": true,
        "base_snapshot": base_id,
        "head_snapshot": head_id,
        "summary": {
            "added": added.len(),
            "removed": removed.len(),
            "changed": changed.len()
        },
        "details": {
            "added": added,
            "removed": removed,
            "changed": changed
        }
    }))
}

fn op_kg_get_node(input: &Value) -> Result<Value, ServiceError> {
    let snapshot = load_snapshot(input)?;

    let node_id = match get_str(input, "node_id")? {
        Some(v) if !v.is_empty() => v,
        _ => {
            let path = get_str(input, "path")?.unwrap_or_default();
            if path.is_empty() {
                return Err(err(
                    "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
                    "node_id or path is required.",
                ));
            }
            format!("file:{}", norm_rel_required(Some(path))?)
        }
    };

    let node = snapshot
        .nodes
        .iter()
        .find(|n| n.node_id == node_id)
        .ok_or_else(|| {
            err(
                "ERR_FILESYSTEM_INTERFACES_NOT_FOUND",
                format!("Node not found: {node_id}"),
            )
        })?;

    Ok(json!({"node": node}))
}

fn op_kg_neighbors(input: &Value) -> Result<Value, ServiceError> {
    let snapshot = load_snapshot(input)?;
    let node_id = get_str(input, "node_id")?
        .filter(|s| !s.is_empty())
        .ok_or_else(|| err("ERR_FILESYSTEM_INTERFACES_INPUT_INVALID", "node_id is required."))?;

    let direction = get_str(input, "direction")?.unwrap_or_else(|| "out".to_string());
    let edge_type_filter = get_str(input, "edge_type")?.unwrap_or_default();
    let limit = get_u64_or(input, "limit", 50) as usize;

    let mut edges = Vec::new();
    for edge in &snapshot.edges {
        let matches_direction = if direction == "in" {
            edge.dst == node_id
        } else {
            edge.src == node_id
        };

        if !matches_direction {
            continue;
        }
        if !edge_type_filter.is_empty() && edge.edge_type != edge_type_filter {
            continue;
        }

        edges.push(edge.clone());
        if edges.len() >= limit {
            break;
        }
    }

    let mut neighbor_ids = BTreeSet::new();
    for edge in &edges {
        if direction == "in" {
            neighbor_ids.insert(edge.src.clone());
        } else {
            neighbor_ids.insert(edge.dst.clone());
        }
    }

    let nodes: Vec<NodeRecord> = snapshot
        .nodes
        .iter()
        .filter(|n| neighbor_ids.contains(&n.node_id))
        .cloned()
        .collect();

    Ok(json!({"node_id": node_id, "edges": edges, "nodes": nodes}))
}

fn op_kg_traverse(input: &Value) -> Result<Value, ServiceError> {
    let snapshot = load_snapshot(input)?;
    let start = get_str(input, "start_node_id")?
        .filter(|s| !s.is_empty())
        .ok_or_else(|| {
            err(
                "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
                "start_node_id is required.",
            )
        })?;
    let depth = get_u64_or(input, "depth", 2) as usize;
    let edge_type_filter = get_str(input, "edge_type")?.unwrap_or_default();

    let (visited, traversed) = traverse_edges(&start, depth, &edge_type_filter, &snapshot.edges);

    let nodes: Vec<NodeRecord> = snapshot
        .nodes
        .iter()
        .filter(|n| visited.contains(&n.node_id))
        .cloned()
        .collect();

    let edges: Vec<EdgeRecord> = traversed
        .into_iter()
        .map(|(src, dst, edge_type)| EdgeRecord {
            src,
            dst,
            edge_type,
        })
        .collect();

    let visited_node_ids: Vec<String> = visited.into_iter().collect();

    Ok(json!({
        "start_node_id": start,
        "depth": depth,
        "visited_node_ids": visited_node_ids,
        "nodes": nodes,
        "edges": edges
    }))
}

fn op_discover_start(input: &Value) -> Result<Value, ServiceError> {
    let snapshot = load_snapshot(input)?;
    let query = get_str(input, "query")?.unwrap_or_default();

    if query.trim().is_empty() {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
            "query is required.",
        ));
    }

    let limit = get_u64_or(input, "limit", 20) as usize;
    let query_lower = query.to_lowercase();
    let query_terms = tokenize_terms(&query);
    let content_scan_limit = get_u64_or(input, "content_scan_limit", 200) as usize;
    let max_op_ms = get_u64_or(input, "max_op_ms", DEFAULT_DISCOVER_MAX_OP_MS);
    let max_content_bytes_per_file = get_u64_or(
        input,
        "max_content_bytes_per_file",
        DEFAULT_DISCOVER_MAX_CONTENT_BYTES_PER_FILE,
    );
    if max_op_ms == 0 {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
            "max_op_ms must be >= 1.",
        ));
    }
    if max_content_bytes_per_file == 0 {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
            "max_content_bytes_per_file must be >= 1.",
        ));
    }
    let deadline_ms = monotonic_now_ms().saturating_add(max_op_ms);

    let mut candidates: BTreeMap<String, (f64, String, String)> = BTreeMap::new();

    for rec in &snapshot.search_index {
        if rec.path_lc.contains(&query_lower) {
            candidates.insert(
                rec.node_id.clone(),
                (1.0, rec.path.clone(), "path-match".to_string()),
            );
            continue;
        }

        if !query_terms.is_empty() && rec.terms.iter().any(|t| query_terms.contains(t)) {
            candidates.entry(rec.node_id.clone()).or_insert((
                0.85,
                rec.path.clone(),
                "index-term-match".to_string(),
            ));
        }
    }

    let mut scanned = 0usize;
    for file in &snapshot.files {
        if monotonic_now_ms() > deadline_ms {
            return Err(err(
                "ERR_FILESYSTEM_INTERFACES_LIMIT_EXCEEDED",
                format!("discover.start exceeded max_op_ms limit ({max_op_ms} ms)."),
            ));
        }
        if candidates.len() >= limit.saturating_mul(2) || scanned >= content_scan_limit {
            break;
        }
        scanned += 1;
        mark_files_scanned(1);

        if !fs_exists(&file.path) {
            continue;
        }

        let key = format!("file:{}", file.path);
        if candidates.contains_key(&key) {
            continue;
        }

        if is_probably_binary_path(&file.path) {
            continue;
        }
        if file.size_bytes > max_content_bytes_per_file {
            continue;
        }

        let bytes = read_bytes_range(&file.path, 0, max_content_bytes_per_file);
        if looks_binary_content(&bytes) {
            continue;
        }
        let text = String::from_utf8_lossy(&bytes).to_lowercase();
        if text.contains(&query_lower) {
            let entry = candidates.entry(key).or_insert((
                0.7,
                file.path.clone(),
                "content-match".to_string(),
            ));
            if entry.0 < 0.7 {
                *entry = (0.7, file.path.clone(), "content-match".to_string());
            }
        }
    }

    let mut ranked: Vec<Value> = candidates
        .into_iter()
        .map(|(node_id, (score, path, reason))| {
            json!({
                "node_id": node_id,
                "path": path,
                "score": score,
                "reason": reason
            })
        })
        .collect();

    ranked.sort_by(|a, b| {
        let ascore = a["score"].as_f64().unwrap_or(0.0);
        let bscore = b["score"].as_f64().unwrap_or(0.0);
        bscore
            .partial_cmp(&ascore)
            .unwrap_or(std::cmp::Ordering::Equal)
            .then_with(|| {
                a["path"]
                    .as_str()
                    .unwrap_or("")
                    .cmp(b["path"].as_str().unwrap_or(""))
            })
    });
    ranked.truncate(limit);

    let frontier: Vec<Value> = ranked.iter().map(|c| c["node_id"].clone()).collect();

    Ok(json!({
        "query": query,
        "candidates": ranked,
        "frontier_node_ids": frontier
    }))
}

fn op_discover_expand(input: &Value) -> Result<Value, ServiceError> {
    let snapshot = load_snapshot(input)?;
    let limit = get_u64_or(input, "limit", 100) as usize;

    let ids_value = input.get("node_ids").ok_or_else(|| {
        err(
            "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
            "node_ids is required.",
        )
    })?;

    let ids_arr = ids_value.as_array().ok_or_else(|| {
        err(
            "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
            "node_ids must be an array.",
        )
    })?;

    if ids_arr.is_empty() {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
            "node_ids must be non-empty.",
        ));
    }

    let mut frontier = BTreeSet::new();
    for v in ids_arr {
        if let Some(s) = v.as_str() {
            frontier.insert(s.to_string());
        }
    }

    let mut edges = Vec::new();
    for edge in &snapshot.edges {
        if frontier.contains(&edge.src) {
            edges.push(edge.clone());
            if edges.len() >= limit {
                break;
            }
        }
    }

    let mut next_ids = BTreeSet::new();
    for edge in &edges {
        next_ids.insert(edge.dst.clone());
    }

    let nodes: Vec<NodeRecord> = snapshot
        .nodes
        .iter()
        .filter(|n| next_ids.contains(&n.node_id))
        .cloned()
        .collect();

    let frontier_ids: Vec<String> = frontier.into_iter().collect();
    let next_node_ids: Vec<String> = next_ids.into_iter().collect();

    Ok(json!({
        "frontier_node_ids": frontier_ids,
        "edges": edges,
        "next_node_ids": next_node_ids,
        "nodes": nodes
    }))
}

fn op_discover_explain(input: &Value) -> Result<Value, ServiceError> {
    let snapshot = load_snapshot(input)?;
    let query = get_str(input, "query")?.unwrap_or_default();

    let ids_value = input.get("candidate_node_ids").ok_or_else(|| {
        err(
            "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
            "candidate_node_ids is required.",
        )
    })?;
    let ids_arr = ids_value.as_array().ok_or_else(|| {
        err(
            "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
            "candidate_node_ids must be an array.",
        )
    })?;

    if ids_arr.is_empty() {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
            "candidate_node_ids must be non-empty.",
        ));
    }

    let mut ids = BTreeSet::new();
    for v in ids_arr {
        if let Some(s) = v.as_str() {
            ids.insert(s.to_string());
        }
    }

    let snapshot_id = snapshot
        .manifest
        .get("snapshot_id")
        .and_then(Value::as_str)
        .unwrap_or(&snapshot.snapshot_id)
        .to_string();
    let input_fingerprint = snapshot
        .manifest
        .get("input_fingerprint")
        .and_then(Value::as_str)
        .unwrap_or("")
        .to_string();

    let mut explanations = Vec::new();
    for node in &snapshot.nodes {
        if !ids.contains(&node.node_id) {
            continue;
        }

        explanations.push(json!({
            "node_id": node.node_id,
            "path": node.path,
            "reason": if query.is_empty() { "candidate" } else { "query-aligned" },
            "provenance": {
                "snapshot_id": snapshot_id,
                "input_fingerprint": input_fingerprint,
                "sha256": node.sha256
            }
        }));
    }

    Ok(json!({"query": query, "explanations": explanations}))
}

fn op_resolve(input: &Value) -> Result<Value, ServiceError> {
    let snapshot = load_snapshot(input)?;
    let node_id = get_str(input, "node_id")?
        .filter(|s| !s.is_empty())
        .ok_or_else(|| err("ERR_FILESYSTEM_INTERFACES_INPUT_INVALID", "node_id is required."))?;

    let node = snapshot
        .nodes
        .iter()
        .find(|n| n.node_id == node_id)
        .ok_or_else(|| {
            err(
                "ERR_FILESYSTEM_INTERFACES_NOT_FOUND",
                format!("Node not found: {node_id}"),
            )
        })?;

    if node.node_type != "file" && node.node_type != "dir" {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_NOT_FOUND",
            format!("Node is not filesystem-resolvable: {node_id}"),
        ));
    }

    let exists = fs_exists(&node.path);

    Ok(json!({
        "node_id": node.node_id,
        "type": node.node_type,
        "path": node.path,
        "absolute_path": node.path,
        "exists": exists
    }))
}

fn collect_snapshot_data(
    dir: &str,
    state_dir: &str,
    cache_by_path: &BTreeMap<String, HashCacheRecord>,
    cache_next: &mut BTreeMap<String, HashCacheRecord>,
    files: &mut Vec<FileRecord>,
    dirs: &mut BTreeSet<String>,
    edges: &mut BTreeSet<(String, String, String)>,
    limits: &SnapshotLimits,
    progress: &mut SnapshotProgress,
) -> Result<(), ServiceError> {
    if monotonic_now_ms() > limits.deadline_ms {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_LIMIT_EXCEEDED",
            "snapshot.build exceeded max_op_ms limit.",
        ));
    }

    dirs.insert(dir.to_string());

    let mut entries = fs_list_dir_paths(dir);
    entries.sort();

    for child in entries {
        if should_skip(&child, state_dir) {
            continue;
        }

        let stat = match fs_get_stat(&child) {
            Some(s) => s,
            None => continue,
        };

        match stat.kind {
            bindings::fs::NodeKind::Dir => {
                edges.insert((
                    format!("dir:{dir}"),
                    format!("dir:{child}"),
                    "CONTAINS".to_string(),
                ));
                collect_snapshot_data(
                    &child,
                    state_dir,
                    cache_by_path,
                    cache_next,
                    files,
                    dirs,
                    edges,
                    limits,
                    progress,
                )?;
            }
            bindings::fs::NodeKind::File => {
                let modified_ms = stat.modified_ms.unwrap_or(0);
                let size_bytes = stat.size;
                progress.files_scanned = progress.files_scanned.saturating_add(1);
                progress.total_size = progress.total_size.saturating_add(size_bytes);
                mark_files_scanned(1);

                if progress.files_scanned > limits.max_files {
                    return Err(err(
                        "ERR_FILESYSTEM_INTERFACES_LIMIT_EXCEEDED",
                        format!(
                            "snapshot.build exceeded max_files limit ({} > {}).",
                            progress.files_scanned, limits.max_files
                        ),
                    ));
                }

                if progress.total_size > limits.max_total_bytes {
                    return Err(err(
                        "ERR_FILESYSTEM_INTERFACES_LIMIT_EXCEEDED",
                        format!(
                            "snapshot.build exceeded max_total_bytes limit ({} > {}).",
                            progress.total_size, limits.max_total_bytes
                        ),
                    ));
                }

                if monotonic_now_ms() > limits.deadline_ms {
                    return Err(err(
                        "ERR_FILESYSTEM_INTERFACES_LIMIT_EXCEEDED",
                        "snapshot.build exceeded max_op_ms limit.",
                    ));
                }

                let (sha, probe_sha256, probe_len) =
                    resolve_file_digest(&child, size_bytes, modified_ms, cache_by_path)?;

                cache_next.insert(
                    child.clone(),
                    HashCacheRecord {
                        path: child.clone(),
                        size_bytes,
                        modified_ms,
                        sha256: sha.clone(),
                        probe_sha256,
                        probe_len,
                    },
                );

                files.push(FileRecord {
                    path: child.clone(),
                    sha256: sha,
                    size_bytes,
                    modified_ms,
                });

                edges.insert((
                    format!("dir:{dir}"),
                    format!("file:{child}"),
                    "CONTAINS".to_string(),
                ));
            }
        }
    }

    Ok(())
}

fn resolve_file_digest(
    path: &str,
    size_bytes: u64,
    modified_ms: u64,
    cache_by_path: &BTreeMap<String, HashCacheRecord>,
) -> Result<(String, String, u64), ServiceError> {
    if let Some(cached) = cache_by_path.get(path) {
        if cached.size_bytes == size_bytes
            && cached.modified_ms == modified_ms
            && !cached.probe_sha256.is_empty()
        {
            let (probe_sha256, probe_len) = probe_digest_for_file(path, size_bytes);
            if probe_sha256 == cached.probe_sha256 && probe_len == cached.probe_len {
                return Ok((
                    cached.sha256.clone(),
                    cached.probe_sha256.clone(),
                    cached.probe_len,
                ));
            }
        }
    }

    let bytes = read_bytes(path);
    let sha256 = sha256_hex(&bytes);
    let (probe_sha256, probe_len) = probe_digest_for_bytes(&bytes);
    Ok((sha256, probe_sha256, probe_len))
}

fn probe_digest_for_file(path: &str, size_bytes: u64) -> (String, u64) {
    let head_len = size_bytes.min(CACHE_PROBE_HEAD_BYTES);
    let head = if head_len > 0 {
        read_bytes_range(path, 0, head_len)
    } else {
        Vec::new()
    };

    let tail_len = size_bytes
        .saturating_sub(head_len)
        .min(CACHE_PROBE_TAIL_BYTES);
    let tail = if tail_len > 0 {
        let offset = size_bytes.saturating_sub(tail_len);
        read_bytes_range(path, offset, tail_len)
    } else {
        Vec::new()
    };

    probe_digest_from_segments(&head, &tail)
}

fn probe_digest_for_bytes(bytes: &[u8]) -> (String, u64) {
    let head_len = bytes.len().min(CACHE_PROBE_HEAD_BYTES as usize);
    let tail_len = bytes
        .len()
        .saturating_sub(head_len)
        .min(CACHE_PROBE_TAIL_BYTES as usize);

    let head = &bytes[..head_len];
    let tail = if tail_len > 0 {
        &bytes[bytes.len() - tail_len..]
    } else {
        &[]
    };
    probe_digest_from_segments(head, tail)
}

fn probe_digest_from_segments(head: &[u8], tail: &[u8]) -> (String, u64) {
    let mut sample = Vec::with_capacity(head.len() + tail.len() + usize::from(!tail.is_empty()));
    sample.extend_from_slice(head);
    if !tail.is_empty() {
        sample.push(b'|');
        sample.extend_from_slice(tail);
    }
    let probe_len = sample.len() as u64;
    (sha256_hex(&sample), probe_len)
}

fn collect_files_recursive(
    dir: &str,
    state_dir: &str,
    out: &mut Vec<String>,
) -> Result<(), ServiceError> {
    let mut entries = fs_list_dir_paths(dir);
    entries.sort();

    for child in entries {
        if should_skip(&child, state_dir) {
            continue;
        }

        let stat = match fs_get_stat(&child) {
            Some(s) => s,
            None => continue,
        };

        match stat.kind {
            bindings::fs::NodeKind::Dir => collect_files_recursive(&child, state_dir, out)?,
            bindings::fs::NodeKind::File => out.push(child),
        }
    }

    Ok(())
}

fn search_file(path: &str, pattern_lower: &str, hits: &mut Vec<Value>, limit: usize) {
    if hits.len() >= limit {
        return;
    }
    if !fs_exists(path) {
        return;
    }

    mark_files_scanned(1);
    let bytes = read_bytes(path);
    let text = String::from_utf8_lossy(&bytes);

    for (idx, line) in text.lines().enumerate() {
        if hits.len() >= limit {
            break;
        }
        if line.to_lowercase().contains(pattern_lower) {
            hits.push(json!({
                "path": path,
                "line": idx + 1,
                "snippet": line
            }));
        }
    }
}

fn load_snapshot(input: &Value) -> Result<SnapshotData, ServiceError> {
    let state_dir = norm_rel_or_default(get_str(input, "state_dir")?, DEFAULT_STATE_DIR)?;

    let snapshot_id = match get_str(input, "snapshot_id")? {
        Some(v) if !v.trim().is_empty() => v,
        _ => {
            let current_path = join_path(&state_dir, "current");
            if !fs_exists(&current_path) {
                return Err(err(
                    "ERR_FILESYSTEM_INTERFACES_NOT_FOUND",
                    "No snapshot_id provided and no active snapshot pointer exists.",
                ));
            }
            read_text_file(&current_path)?.trim().to_string()
        }
    };

    if snapshot_id.is_empty() {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_SNAPSHOT_INVALID",
            "snapshot_id is empty.",
        ));
    }

    let snapshot_dir = join_path(&state_dir, &snapshot_id);
    let manifest_path = join_path(&snapshot_dir, "manifest.json");
    let files_path = join_path(&snapshot_dir, "files.jsonl");
    let nodes_path = join_path(&snapshot_dir, "nodes.jsonl");
    let edges_path = join_path(&snapshot_dir, "edges.jsonl");
    let index_path = join_path(&snapshot_dir, SEARCH_INDEX_FILE);
    let ready_marker = join_path(&snapshot_dir, SNAPSHOT_READY_MARKER);
    let building_marker = join_path(&snapshot_dir, SNAPSHOT_BUILDING_MARKER);
    let remediation = snapshot_rebuild_hint(&state_dir);

    if fs_exists(&building_marker) && !fs_exists(&ready_marker) {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_SNAPSHOT_INVALID",
            format!(
                "Snapshot appears incomplete (building marker present): {snapshot_dir}. {remediation}"
            ),
        ));
    }

    for p in [&manifest_path, &files_path, &nodes_path, &edges_path] {
        if !fs_exists(p) {
            return Err(err(
                "ERR_FILESYSTEM_INTERFACES_SNAPSHOT_INVALID",
                format!("Missing snapshot artifact: {p}. {remediation}"),
            ));
        }
    }

    let manifest_text = read_text_file(&manifest_path)?;
    let manifest = serde_json::from_str::<Value>(&manifest_text).map_err(|e| {
        err(
            "ERR_FILESYSTEM_INTERFACES_SNAPSHOT_INVALID",
            format!("Invalid manifest JSON: {e}. {remediation}"),
        )
    })?;
    ensure_supported_snapshot_format(&manifest, &state_dir)?;

    let files = parse_jsonl::<FileRecord>(&read_text_file(&files_path)?).map_err(|e| {
        err(
            "ERR_FILESYSTEM_INTERFACES_SNAPSHOT_INVALID",
            format!("{}. {remediation}", e.message),
        )
    })?;
    let nodes = parse_jsonl::<NodeRecord>(&read_text_file(&nodes_path)?).map_err(|e| {
        err(
            "ERR_FILESYSTEM_INTERFACES_SNAPSHOT_INVALID",
            format!("{}. {remediation}", e.message),
        )
    })?;
    let edges = parse_jsonl::<EdgeRecord>(&read_text_file(&edges_path)?).map_err(|e| {
        err(
            "ERR_FILESYSTEM_INTERFACES_SNAPSHOT_INVALID",
            format!("{}. {remediation}", e.message),
        )
    })?;
    let search_index = if fs_exists(&index_path) {
        parse_jsonl::<SearchIndexRecord>(&read_text_file(&index_path)?).map_err(|e| {
            err(
                "ERR_FILESYSTEM_INTERFACES_SNAPSHOT_INVALID",
                format!("{}. {remediation}", e.message),
            )
        })?
    } else {
        build_search_index(&files)
    };

    Ok(SnapshotData {
        snapshot_id,
        manifest,
        files,
        nodes,
        edges,
        search_index,
    })
}

fn parse_files_map(path: &str) -> Result<BTreeMap<String, String>, ServiceError> {
    let files = parse_jsonl::<FileRecord>(&read_text_file(path)?)?;
    let mut map = BTreeMap::new();
    for f in files {
        map.insert(f.path, f.sha256);
    }
    Ok(map)
}

fn compute_snapshot_diff(
    base_files: &BTreeMap<String, String>,
    head_files: &BTreeMap<String, String>,
) -> (Vec<Value>, Vec<Value>, Vec<Value>) {
    let mut added = Vec::new();
    let mut removed = Vec::new();
    let mut changed = Vec::new();

    for (path, sha) in head_files {
        match base_files.get(path) {
            None => added.push(json!({"path": path, "sha256": sha})),
            Some(base_sha) if base_sha != sha => {
                changed.push(json!({"path": path, "base_sha256": base_sha, "head_sha256": sha}))
            }
            _ => {}
        }
    }

    for (path, sha) in base_files {
        if !head_files.contains_key(path) {
            removed.push(json!({"path": path, "sha256": sha}));
        }
    }

    let sort_by_path = |values: &mut Vec<Value>| {
        values.sort_by(|a, b| {
            a["path"]
                .as_str()
                .unwrap_or("")
                .cmp(b["path"].as_str().unwrap_or(""))
        });
    };
    sort_by_path(&mut added);
    sort_by_path(&mut removed);
    sort_by_path(&mut changed);

    (added, removed, changed)
}

fn traverse_edges(
    start: &str,
    depth: usize,
    edge_type_filter: &str,
    edges: &[EdgeRecord],
) -> (BTreeSet<String>, BTreeSet<(String, String, String)>) {
    let mut queue: VecDeque<(String, usize)> = VecDeque::new();
    let mut visited: BTreeSet<String> = BTreeSet::new();
    let mut traversed: BTreeSet<(String, String, String)> = BTreeSet::new();

    queue.push_back((start.to_string(), 0));
    visited.insert(start.to_string());

    while let Some((current, d)) = queue.pop_front() {
        if d >= depth {
            continue;
        }

        for edge in edges {
            if edge.src != current {
                continue;
            }
            if !edge_type_filter.is_empty() && edge.edge_type != edge_type_filter {
                continue;
            }

            traversed.insert((edge.src.clone(), edge.dst.clone(), edge.edge_type.clone()));
            if visited.insert(edge.dst.clone()) {
                queue.push_back((edge.dst.clone(), d + 1));
            }
        }
    }

    (visited, traversed)
}

fn load_hash_cache(path: &str) -> Result<BTreeMap<String, HashCacheRecord>, ServiceError> {
    if !fs_exists(path) {
        return Ok(BTreeMap::new());
    }
    let records = parse_jsonl::<HashCacheRecord>(&read_text_file(path)?)?;
    let mut out = BTreeMap::new();
    for record in records {
        out.insert(record.path.clone(), record);
    }
    Ok(out)
}

fn write_hash_cache(
    path: &str,
    records: &BTreeMap<String, HashCacheRecord>,
) -> Result<(), ServiceError> {
    let mut lines = Vec::with_capacity(records.len());
    for record in records.values() {
        lines.push(serde_json::to_string(record).map_err(|e| {
            err(
                "ERR_FILESYSTEM_INTERFACES_INTERNAL",
                format!("Failed to serialize hash cache record: {e}"),
            )
        })?);
    }
    write_jsonl_file(path, &lines)
}

fn build_search_index(files: &[FileRecord]) -> Vec<SearchIndexRecord> {
    let mut out = Vec::with_capacity(files.len());
    for file in files {
        let mut terms: Vec<String> = tokenize_terms(&file.path).into_iter().collect();
        terms.sort();
        out.push(SearchIndexRecord {
            node_id: format!("file:{}", file.path),
            path: file.path.clone(),
            path_lc: file.path.to_lowercase(),
            terms,
        });
    }
    out
}

fn parse_jsonl<T: for<'de> Deserialize<'de>>(text: &str) -> Result<Vec<T>, ServiceError> {
    let mut out = Vec::new();
    for (idx, line) in text.lines().enumerate() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }

        let item = serde_json::from_str::<T>(line).map_err(|e| {
            err(
                "ERR_FILESYSTEM_INTERFACES_SNAPSHOT_INVALID",
                format!("Invalid JSONL at line {}: {e}", idx + 1),
            )
        })?;

        out.push(item);
    }
    Ok(out)
}

fn snapshot_rebuild_hint(state_dir: &str) -> String {
    format!(
        "Rebuild snapshot artifacts: invoke snapshot.build with {{\"root\":\".\",\"state_dir\":\"{state_dir}\",\"set_current\":true}}."
    )
}

fn acquire_snapshot_build_lock(
    state_dir: &str,
    stale_after_ms: u64,
) -> Result<SnapshotBuildLock, ServiceError> {
    let lock_path = join_path(state_dir, SNAPSHOT_BUILD_LOCK_FILE);
    let now_ms = monotonic_now_ms();
    let lock_body = format!(
        "created_ms={now_ms}\ncreated_at={}\n",
        epoch_ms_to_rfc3339(now_ms)
    );

    if bindings::fs::create_file_exclusive(&lock_path, lock_body.as_bytes()) {
        return Ok(SnapshotBuildLock {
            path: lock_path,
            held: true,
        });
    }

    let existing_body = read_text_file(&lock_path).unwrap_or_default();
    if stale_after_ms > 0 {
        let created_ms = parse_lock_created_ms(&existing_body).or_else(|| {
            fs_get_stat(&lock_path).and_then(|stat| stat.modified_ms)
        });
        if let Some(created_ms) = created_ms {
            let age_ms = monotonic_now_ms().saturating_sub(created_ms);
            if age_ms > stale_after_ms {
                if fs_exists(&lock_path) {
                    bindings::fs::remove_file(&lock_path);
                }
                if bindings::fs::create_file_exclusive(&lock_path, lock_body.as_bytes()) {
                    return Ok(SnapshotBuildLock {
                        path: lock_path,
                        held: true,
                    });
                }
            }
        }
    }

    // Resolve racy lock-create windows where the competing process exited.
    if bindings::fs::create_file_exclusive(&lock_path, lock_body.as_bytes()) {
        return Ok(SnapshotBuildLock {
            path: lock_path,
            held: true,
        });
    }

    Err(err(
        "ERR_FILESYSTEM_INTERFACES_LOCKED",
        format!(
            "snapshot.build lock is held at {lock_path}. Retry after the active build completes."
        ),
    ))
}

fn parse_lock_created_ms(body: &str) -> Option<u64> {
    for line in body.lines() {
        let line = line.trim();
        if let Some(value) = line.strip_prefix("created_ms=") {
            if let Ok(parsed) = value.trim().parse::<u64>() {
                return Some(parsed);
            }
        }
    }
    None
}

fn snapshot_dir_is_ready(snapshot_dir: &str) -> bool {
    let ready_marker = join_path(snapshot_dir, SNAPSHOT_READY_MARKER);
    let building_marker = join_path(snapshot_dir, SNAPSHOT_BUILDING_MARKER);
    let manifest_path = join_path(snapshot_dir, "manifest.json");
    let files_path = join_path(snapshot_dir, "files.jsonl");
    let nodes_path = join_path(snapshot_dir, "nodes.jsonl");
    let edges_path = join_path(snapshot_dir, "edges.jsonl");
    let index_path = join_path(snapshot_dir, SEARCH_INDEX_FILE);

    fs_exists(snapshot_dir)
        && fs_exists(&ready_marker)
        && !fs_exists(&building_marker)
        && fs_exists(&manifest_path)
        && fs_exists(&files_path)
        && fs_exists(&nodes_path)
        && fs_exists(&edges_path)
        && fs_exists(&index_path)
}

fn cleanup_snapshot_build_transients(state_dir: &str) -> Result<(), ServiceError> {
    if !fs_exists(state_dir) {
        return Ok(());
    }

    let mut entries = fs_list_dir_paths(state_dir);
    entries.sort();

    for child in entries {
        let Some(stat) = fs_get_stat(&child) else {
            continue;
        };
        if !matches!(stat.kind, bindings::fs::NodeKind::Dir) {
            continue;
        }

        let id = basename(&child);
        if id.starts_with(".staging-snap-") {
            bindings::fs::remove_dir_recursive(&child);
            continue;
        }

        if id.starts_with("snap-") {
            let ready_marker = join_path(&child, SNAPSHOT_READY_MARKER);
            let building_marker = join_path(&child, SNAPSHOT_BUILDING_MARKER);
            if fs_exists(&building_marker) && !fs_exists(&ready_marker) {
                bindings::fs::remove_dir_recursive(&child);
            }
        }
    }

    Ok(())
}

fn ensure_supported_snapshot_format(
    manifest: &Value,
    state_dir: &str,
) -> Result<u64, ServiceError> {
    let format_version = snapshot_format_version(manifest).ok_or_else(|| {
        err(
            "ERR_FILESYSTEM_INTERFACES_FORMAT_UNSUPPORTED",
            format!(
                "Snapshot manifest has an invalid snapshot_format_version field. {}",
                snapshot_rebuild_hint(state_dir)
            ),
        )
    })?;

    if !(SNAPSHOT_MIN_SUPPORTED_FORMAT_VERSION..=SNAPSHOT_MAX_SUPPORTED_FORMAT_VERSION)
        .contains(&format_version)
    {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_FORMAT_UNSUPPORTED",
            format!(
                "Unsupported snapshot format version {format_version}; supported range is {}..={}. {}",
                SNAPSHOT_MIN_SUPPORTED_FORMAT_VERSION,
                SNAPSHOT_MAX_SUPPORTED_FORMAT_VERSION,
                snapshot_rebuild_hint(state_dir)
            ),
        ));
    }

    Ok(format_version)
}

fn snapshot_format_version(manifest: &Value) -> Option<u64> {
    match manifest.get("snapshot_format_version") {
        Some(value) => value.as_u64(),
        None => Some(1),
    }
}

fn run_snapshot_gc(
    state_dir: &str,
    keep_ids: &BTreeSet<String>,
    max_snapshots: u64,
    max_age_hours: u64,
    max_state_bytes: u64,
) -> Result<SnapshotGcStats, ServiceError> {
    let mut snapshots = list_snapshot_dirs(state_dir)?;
    if snapshots.is_empty() {
        return Ok(SnapshotGcStats::default());
    }

    snapshots.sort_by(|a, b| {
        b.modified_ms
            .cmp(&a.modified_ms)
            .then_with(|| a.id.cmp(&b.id))
    });

    let now_ms = monotonic_now_ms();
    let mut delete = vec![false; snapshots.len()];
    let age_limit_ms = max_age_hours.saturating_mul(3_600_000);

    if age_limit_ms > 0 {
        for (idx, snap) in snapshots.iter().enumerate() {
            if keep_ids.contains(&snap.id) {
                continue;
            }
            if now_ms.saturating_sub(snap.modified_ms) > age_limit_ms {
                delete[idx] = true;
            }
        }
    }

    let mut retained_count = snapshots
        .iter()
        .enumerate()
        .filter(|(idx, _)| !delete[*idx])
        .count() as u64;

    if retained_count > max_snapshots {
        let mut oldest_first: Vec<usize> = (0..snapshots.len()).collect();
        oldest_first.sort_by(|a, b| {
            snapshots[*a]
                .modified_ms
                .cmp(&snapshots[*b].modified_ms)
                .then_with(|| snapshots[*a].id.cmp(&snapshots[*b].id))
        });

        for idx in oldest_first {
            if retained_count <= max_snapshots {
                break;
            }
            if delete[idx] || keep_ids.contains(&snapshots[idx].id) {
                continue;
            }
            delete[idx] = true;
            retained_count = retained_count.saturating_sub(1);
        }
    }

    if max_state_bytes > 0 {
        let mut retained_bytes: u64 = snapshots
            .iter()
            .enumerate()
            .filter(|(idx, _)| !delete[*idx])
            .map(|(_, snap)| snap.size_bytes)
            .sum();

        if retained_bytes > max_state_bytes {
            let mut oldest_first: Vec<usize> = (0..snapshots.len()).collect();
            oldest_first.sort_by(|a, b| {
                snapshots[*a]
                    .modified_ms
                    .cmp(&snapshots[*b].modified_ms)
                    .then_with(|| snapshots[*a].id.cmp(&snapshots[*b].id))
            });

            for idx in oldest_first {
                if retained_bytes <= max_state_bytes {
                    break;
                }
                if delete[idx] || keep_ids.contains(&snapshots[idx].id) {
                    continue;
                }
                delete[idx] = true;
                retained_bytes = retained_bytes.saturating_sub(snapshots[idx].size_bytes);
            }
        }
    }

    let mut stats = SnapshotGcStats::default();
    for (idx, snap) in snapshots.iter().enumerate() {
        if !delete[idx] {
            continue;
        }
        if fs_exists(&snap.path) {
            bindings::fs::remove_dir_recursive(&snap.path);
        }
        stats.deleted_snapshots = stats.deleted_snapshots.saturating_add(1);
        stats.deleted_bytes = stats.deleted_bytes.saturating_add(snap.size_bytes);
    }

    for (idx, snap) in snapshots.iter().enumerate() {
        if delete[idx] {
            continue;
        }
        stats.remaining_snapshots = stats.remaining_snapshots.saturating_add(1);
        stats.remaining_bytes = stats.remaining_bytes.saturating_add(snap.size_bytes);
    }

    Ok(stats)
}

fn list_snapshot_dirs(state_dir: &str) -> Result<Vec<SnapshotDirInfo>, ServiceError> {
    if !fs_exists(state_dir) {
        return Ok(Vec::new());
    }

    let mut out = Vec::new();
    let mut entries = fs_list_dir_paths(state_dir);
    entries.sort();

    for child in entries {
        let Some(stat) = fs_get_stat(&child) else {
            continue;
        };
        if !matches!(stat.kind, bindings::fs::NodeKind::Dir) {
            continue;
        }

        let id = basename(&child);
        if !id.starts_with("snap-") {
            continue;
        }

        let manifest_path = join_path(&child, "manifest.json");
        let modified_ms = fs_get_stat(&manifest_path)
            .and_then(|s| s.modified_ms)
            .or(stat.modified_ms)
            .unwrap_or(0);
        let size_bytes = snapshot_dir_size_bytes(&child)?;

        out.push(SnapshotDirInfo {
            id,
            path: child,
            modified_ms,
            size_bytes,
        });
    }

    Ok(out)
}

fn snapshot_dir_size_bytes(dir: &str) -> Result<u64, ServiceError> {
    let mut total = 0u64;
    collect_dir_size_recursive(dir, &mut total)?;
    Ok(total)
}

fn collect_dir_size_recursive(path: &str, total: &mut u64) -> Result<(), ServiceError> {
    let mut entries = fs_list_dir_paths(path);
    entries.sort();

    for child in entries {
        let Some(stat) = fs_get_stat(&child) else {
            continue;
        };

        match stat.kind {
            bindings::fs::NodeKind::File => {
                *total = total.saturating_add(stat.size);
            }
            bindings::fs::NodeKind::Dir => collect_dir_size_recursive(&child, total)?,
        }
    }

    Ok(())
}

fn resolve_snapshot_ref(state_dir: &str, value: &str) -> Result<(String, String), ServiceError> {
    let normalized = norm_rel_required(Some(value.to_string()))?;

    if fs_exists(&normalized) {
        if let Some(stat) = fs_get_stat(&normalized) {
            if matches!(stat.kind, bindings::fs::NodeKind::Dir) {
                let id = basename(&normalized);
                return Ok((id, normalized));
            }
        }
    }

    let candidate = join_path(state_dir, &normalized);
    if fs_exists(&candidate) {
        if let Some(stat) = fs_get_stat(&candidate) {
            if matches!(stat.kind, bindings::fs::NodeKind::Dir) {
                let id = basename(&candidate);
                return Ok((id, candidate));
            }
        }
    }

    Err(err(
        "ERR_FILESYSTEM_INTERFACES_NOT_FOUND",
        format!("Snapshot not found: {value}"),
    ))
}

fn write_jsonl_file(path: &str, lines: &[String]) -> Result<(), ServiceError> {
    let body = if lines.is_empty() {
        String::new()
    } else {
        format!("{}\n", lines.join("\n"))
    };
    write_text_file(path, &body)
}

fn write_text_file(path: &str, content: &str) -> Result<(), ServiceError> {
    if let Some(parent) = parent_path(path) {
        if parent != "." && !fs_exists(&parent) {
            bindings::fs::mkdirp(&parent);
        }
    }
    bindings::fs::write(path, content.as_bytes());
    Ok(())
}

fn read_text_file(path: &str) -> Result<String, ServiceError> {
    if !fs_exists(path) {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_NOT_FOUND",
            format!("Read failed for {path}: not found"),
        ));
    }

    let bytes = read_bytes(path);
    String::from_utf8(bytes).map_err(|e| {
        err(
            "ERR_FILESYSTEM_INTERFACES_SNAPSHOT_INVALID",
            format!("UTF-8 decode failed for {path}: {e}"),
        )
    })
}

fn get_str(input: &Value, key: &str) -> Result<Option<String>, ServiceError> {
    let obj = input.as_object().ok_or_else(|| {
        err(
            "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
            "Input must be object.",
        )
    })?;

    Ok(obj.get(key).and_then(Value::as_str).map(|s| s.to_string()))
}

fn get_u64_or(input: &Value, key: &str, default: u64) -> u64 {
    input
        .as_object()
        .and_then(|o| o.get(key))
        .and_then(Value::as_u64)
        .unwrap_or(default)
}

fn get_bool_or(input: &Value, key: &str, default: bool) -> bool {
    input
        .as_object()
        .and_then(|o| o.get(key))
        .and_then(Value::as_bool)
        .unwrap_or(default)
}

fn norm_rel_required(value: Option<String>) -> Result<String, ServiceError> {
    let raw = value.unwrap_or_default();
    if raw.trim().is_empty() {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_INPUT_INVALID",
            "Required path value is missing.",
        ));
    }
    normalize_relative_path(&raw)
}

fn norm_rel_or_default(value: Option<String>, default: &str) -> Result<String, ServiceError> {
    match value {
        Some(v) if !v.trim().is_empty() => normalize_relative_path(&v),
        _ => normalize_relative_path(default),
    }
}

fn normalize_relative_path(raw: &str) -> Result<String, ServiceError> {
    if raw.trim().is_empty() {
        return Ok(".".to_string());
    }

    let p = Path::new(raw);
    if p.is_absolute() {
        return Err(err(
            "ERR_FILESYSTEM_INTERFACES_PATH_INVALID",
            format!("Absolute path is not allowed: {raw}"),
        ));
    }

    let mut parts = Vec::new();
    for comp in p.components() {
        match comp {
            Component::CurDir => {}
            Component::Normal(seg) => {
                let s = seg.to_string_lossy().to_string();
                if !s.is_empty() {
                    parts.push(s);
                }
            }
            Component::ParentDir => {
                return Err(err(
                    "ERR_FILESYSTEM_INTERFACES_PATH_INVALID",
                    format!("Parent directory '..' is not allowed: {raw}"),
                ))
            }
            Component::RootDir | Component::Prefix(_) => {
                return Err(err(
                    "ERR_FILESYSTEM_INTERFACES_PATH_INVALID",
                    format!("Absolute path is not allowed: {raw}"),
                ))
            }
        }
    }

    if parts.is_empty() {
        Ok(".".to_string())
    } else {
        Ok(parts.join("/"))
    }
}

fn join_path(base: &str, child: &str) -> String {
    if child.is_empty() {
        return base.to_string();
    }
    if base.is_empty() || base == "." {
        child.to_string()
    } else if child == "." {
        base.to_string()
    } else {
        format!("{base}/{child}")
    }
}

fn parent_path(path: &str) -> Option<String> {
    let mut iter = path.rsplitn(2, '/');
    let _ = iter.next();
    iter.next().map(|p| {
        if p.is_empty() {
            ".".to_string()
        } else {
            p.to_string()
        }
    })
}

fn basename(path: &str) -> String {
    path.rsplit('/').next().unwrap_or(path).to_string()
}

fn tokenize_terms(text: &str) -> BTreeSet<String> {
    let mut out = BTreeSet::new();
    let mut cur = String::new();

    for ch in text.chars() {
        if ch.is_ascii_alphanumeric() {
            cur.push(ch.to_ascii_lowercase());
        } else if !cur.is_empty() {
            if cur.len() >= 2 {
                out.insert(cur.clone());
            }
            cur.clear();
        }
    }

    if !cur.is_empty() && cur.len() >= 2 {
        out.insert(cur);
    }

    out
}

fn is_probably_binary_path(path: &str) -> bool {
    let ext = path
        .rsplit('.')
        .next()
        .map(|v| v.to_ascii_lowercase())
        .unwrap_or_default();

    matches!(
        ext.as_str(),
        "png"
            | "jpg"
            | "jpeg"
            | "gif"
            | "bmp"
            | "webp"
            | "ico"
            | "pdf"
            | "zip"
            | "gz"
            | "tar"
            | "tgz"
            | "7z"
            | "rar"
            | "jar"
            | "war"
            | "class"
            | "wasm"
            | "o"
            | "a"
            | "so"
            | "dylib"
            | "dll"
            | "exe"
            | "bin"
            | "mp3"
            | "mp4"
            | "mov"
            | "avi"
    )
}

fn looks_binary_content(bytes: &[u8]) -> bool {
    let sample_len = bytes.len().min(1024);
    bytes[..sample_len].iter().any(|b| *b == 0)
}

fn fs_exists(path: &str) -> bool {
    if path == "." {
        true
    } else {
        bindings::fs::exists(path)
    }
}

fn fs_get_stat(path: &str) -> Option<bindings::fs::Stat> {
    if path == "." {
        Some(bindings::fs::Stat {
            kind: bindings::fs::NodeKind::Dir,
            size: 0,
            modified_ms: None,
        })
    } else {
        bindings::fs::get_stat(path)
    }
}

fn fs_list_dir_paths(path: &str) -> Vec<String> {
    let mut out = BTreeSet::new();

    let patterns = if path == "." {
        vec!["*".to_string(), ".*".to_string()]
    } else {
        vec![format!("{path}/*"), format!("{path}/.*")]
    };

    for pattern in patterns {
        for matched in bindings::fs::glob(&pattern) {
            if matched.trim().is_empty() || matched == "." || matched == ".." {
                continue;
            }
            if !is_immediate_child(path, &matched) {
                continue;
            }
            out.insert(matched);
        }
    }

    out.into_iter().collect()
}

fn is_immediate_child(parent: &str, child: &str) -> bool {
    if child.is_empty() {
        return false;
    }

    if parent == "." {
        return !child.contains('/');
    }

    let prefix = format!("{parent}/");
    if !child.starts_with(&prefix) {
        return false;
    }

    let rest = &child[prefix.len()..];
    !rest.is_empty() && !rest.contains('/')
}

fn should_skip(path: &str, state_dir: &str) -> bool {
    if path == "." || path.is_empty() {
        return false;
    }

    let normalized = path.trim_start_matches("./");
    if normalized == "." || normalized.is_empty() {
        return false;
    }

    if normalized == RUNTIME_STATE_ROOT || normalized.starts_with(&format!("{RUNTIME_STATE_ROOT}/"))
    {
        return true;
    }

    if normalized == SERVICES_BUILD_STATE_ROOT
        || normalized.starts_with(&format!("{SERVICES_BUILD_STATE_ROOT}/"))
        || normalized.contains("/_ops/state/build/")
    {
        return true;
    }

    normalized == ".git"
        || normalized.starts_with(".git/")
        || normalized == state_dir
        || normalized.starts_with(&format!("{state_dir}/"))
}

fn sha256_hex(bytes: &[u8]) -> String {
    let digest = sha256_digest(bytes);
    to_hex_lower(&digest)
}

fn sha256_digest(input: &[u8]) -> [u8; 32] {
    const H0: [u32; 8] = [
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab,
        0x5be0cd19,
    ];

    const K: [u32; 64] = [
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4,
        0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe,
        0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f,
        0x4a7484aa, 0x5cb0a9dc, 0x76f988da, 0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
        0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc,
        0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
        0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070, 0x19a4c116,
        0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7,
        0xc67178f2,
    ];

    let mut h = H0;
    let bit_len = (input.len() as u64).wrapping_mul(8);

    let mut msg = input.to_vec();
    msg.push(0x80);
    while (msg.len() + 8) % 64 != 0 {
        msg.push(0);
    }
    msg.extend_from_slice(&bit_len.to_be_bytes());

    for chunk in msg.chunks_exact(64) {
        let mut w = [0u32; 64];

        for (i, slot) in w.iter_mut().take(16).enumerate() {
            let j = i * 4;
            *slot = u32::from_be_bytes([chunk[j], chunk[j + 1], chunk[j + 2], chunk[j + 3]]);
        }

        for i in 16..64 {
            let s0 = w[i - 15].rotate_right(7) ^ w[i - 15].rotate_right(18) ^ (w[i - 15] >> 3);
            let s1 = w[i - 2].rotate_right(17) ^ w[i - 2].rotate_right(19) ^ (w[i - 2] >> 10);
            w[i] = w[i - 16]
                .wrapping_add(s0)
                .wrapping_add(w[i - 7])
                .wrapping_add(s1);
        }

        let mut a = h[0];
        let mut b = h[1];
        let mut c = h[2];
        let mut d = h[3];
        let mut e = h[4];
        let mut f = h[5];
        let mut g = h[6];
        let mut hh = h[7];

        for i in 0..64 {
            let s1 = e.rotate_right(6) ^ e.rotate_right(11) ^ e.rotate_right(25);
            let ch = (e & f) ^ ((!e) & g);
            let temp1 = hh
                .wrapping_add(s1)
                .wrapping_add(ch)
                .wrapping_add(K[i])
                .wrapping_add(w[i]);
            let s0 = a.rotate_right(2) ^ a.rotate_right(13) ^ a.rotate_right(22);
            let maj = (a & b) ^ (a & c) ^ (b & c);
            let temp2 = s0.wrapping_add(maj);

            hh = g;
            g = f;
            f = e;
            e = d.wrapping_add(temp1);
            d = c;
            c = b;
            b = a;
            a = temp1.wrapping_add(temp2);
        }

        h[0] = h[0].wrapping_add(a);
        h[1] = h[1].wrapping_add(b);
        h[2] = h[2].wrapping_add(c);
        h[3] = h[3].wrapping_add(d);
        h[4] = h[4].wrapping_add(e);
        h[5] = h[5].wrapping_add(f);
        h[6] = h[6].wrapping_add(g);
        h[7] = h[7].wrapping_add(hh);
    }

    let mut out = [0u8; 32];
    for (i, v) in h.iter().enumerate() {
        out[i * 4..(i + 1) * 4].copy_from_slice(&v.to_be_bytes());
    }
    out
}

fn to_hex_lower(bytes: &[u8]) -> String {
    const HEX: &[u8; 16] = b"0123456789abcdef";
    let mut out = String::with_capacity(bytes.len() * 2);
    for b in bytes {
        out.push(HEX[(b >> 4) as usize] as char);
        out.push(HEX[(b & 0x0f) as usize] as char);
    }
    out
}

fn runtime_log(level: &str, message: &str) {
    #[cfg(target_arch = "wasm32")]
    bindings::log::write(level, message);

    #[cfg(not(target_arch = "wasm32"))]
    let _ = (level, message);
}

fn monotonic_now_ms() -> u64 {
    #[cfg(target_arch = "wasm32")]
    {
        bindings::clock::now_ms()
    }

    #[cfg(not(target_arch = "wasm32"))]
    {
        use std::time::{SystemTime, UNIX_EPOCH};
        let now = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap_or_default();
        now.as_millis() as u64
    }
}

fn now_rfc3339() -> String {
    let ms = monotonic_now_ms();
    epoch_ms_to_rfc3339(ms)
}

fn epoch_ms_to_rfc3339(ms: u64) -> String {
    let total_seconds = (ms / 1000) as i64;
    let days = total_seconds.div_euclid(86_400);
    let sec_of_day = total_seconds.rem_euclid(86_400);

    let hour = (sec_of_day / 3_600) as u32;
    let minute = ((sec_of_day % 3_600) / 60) as u32;
    let second = (sec_of_day % 60) as u32;

    let (year, month, day) = civil_from_days(days);

    format!(
        "{:04}-{:02}-{:02}T{:02}:{:02}:{:02}Z",
        year, month, day, hour, minute, second
    )
}

fn civil_from_days(days_since_epoch: i64) -> (i32, u32, u32) {
    let z = days_since_epoch + 719_468;
    let era = if z >= 0 { z } else { z - 146_096 } / 146_097;
    let doe = z - era * 146_097;
    let yoe = (doe - doe / 1_460 + doe / 36_524 - doe / 146_096) / 365;
    let y = yoe + era * 400;
    let doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    let mp = (5 * doy + 2) / 153;
    let day = doy - (153 * mp + 2) / 5 + 1;
    let month = mp + if mp < 10 { 3 } else { -9 };
    let year = y + if month <= 2 { 1 } else { 0 };

    (year as i32, month as u32, day as u32)
}

fn err(code: &'static str, message: impl Into<String>) -> ServiceError {
    ServiceError {
        code,
        message: message.into(),
    }
}

fn error_json(code: &str, message: &str) -> String {
    json!({
        "ok": false,
        "error": {
            "code": code,
            "message": message
        },
        "filesystem_interfaces_contract_version": CONTRACT_VERSION
    })
    .to_string()
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::{BTreeMap, BTreeSet, VecDeque};
    use std::fs;
    use std::path::PathBuf;

    #[derive(Clone)]
    struct TestRng {
        state: u64,
    }

    impl TestRng {
        fn new(seed: u64) -> Self {
            Self {
                state: seed.wrapping_add(0x9e3779b97f4a7c15),
            }
        }

        fn next_u32(&mut self) -> u32 {
            self.state = self.state.wrapping_mul(6364136223846793005).wrapping_add(1);
            (self.state >> 32) as u32
        }

        fn next_bool(&mut self) -> bool {
            self.next_u32() & 1 == 1
        }

        fn next_usize(&mut self, max_exclusive: usize) -> usize {
            if max_exclusive == 0 {
                0
            } else {
                (self.next_u32() as usize) % max_exclusive
            }
        }
    }

    #[test]
    fn normalize_relative_path_accepts_clean_paths() {
        assert_eq!(normalize_relative_path(".").unwrap(), ".");
        assert_eq!(normalize_relative_path("a/b/c").unwrap(), "a/b/c");
        assert_eq!(normalize_relative_path("./a//b").unwrap(), "a/b");
    }

    #[test]
    fn normalize_relative_path_rejects_escape_and_absolute() {
        assert!(normalize_relative_path("../x").is_err());
        assert!(normalize_relative_path("/abs/path").is_err());
    }

    #[test]
    fn sha256_matches_known_vector() {
        assert_eq!(
            sha256_hex(b"abc"),
            "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
        );
    }

    #[test]
    fn snapshot_diff_detects_added_removed_changed() {
        let mut base = BTreeMap::new();
        base.insert("a.txt".to_string(), "111".to_string());
        base.insert("b.txt".to_string(), "222".to_string());

        let mut head = BTreeMap::new();
        head.insert("a.txt".to_string(), "999".to_string());
        head.insert("c.txt".to_string(), "333".to_string());

        let (added, removed, changed) = compute_snapshot_diff(&base, &head);
        assert_eq!(added.len(), 1);
        assert_eq!(removed.len(), 1);
        assert_eq!(changed.len(), 1);
        assert_eq!(added[0]["path"].as_str(), Some("c.txt"));
        assert_eq!(removed[0]["path"].as_str(), Some("b.txt"));
        assert_eq!(changed[0]["path"].as_str(), Some("a.txt"));
    }

    #[test]
    fn traverse_edges_honors_depth_and_filter() {
        let edges = vec![
            EdgeRecord {
                src: "n1".to_string(),
                dst: "n2".to_string(),
                edge_type: "CONTAINS".to_string(),
            },
            EdgeRecord {
                src: "n2".to_string(),
                dst: "n3".to_string(),
                edge_type: "CONTAINS".to_string(),
            },
            EdgeRecord {
                src: "n1".to_string(),
                dst: "n4".to_string(),
                edge_type: "REF".to_string(),
            },
        ];

        let (visited_all, traversed_all) = traverse_edges("n1", 2, "", &edges);
        assert!(visited_all.contains("n3"));
        assert!(traversed_all.contains(&("n1".to_string(), "n4".to_string(), "REF".to_string())));

        let (visited_contains, traversed_contains) = traverse_edges("n1", 2, "CONTAINS", &edges);
        assert!(visited_contains.contains("n3"));
        assert!(!visited_contains.contains("n4"));
        assert!(!traversed_contains.contains(&(
            "n1".to_string(),
            "n4".to_string(),
            "REF".to_string()
        )));
    }

    #[test]
    fn should_skip_runtime_state_paths() {
        assert!(should_skip(
            ".octon/engine/_ops/state/traces/x.ndjson",
            DEFAULT_STATE_DIR
        ));
        assert!(should_skip(
            ".octon/engine/_ops/state/build/x",
            DEFAULT_STATE_DIR
        ));
        assert!(should_skip(
            ".octon/engine/_ops/state/snapshots/snap-abc",
            DEFAULT_STATE_DIR
        ));
        assert!(should_skip(
            ".octon/capabilities/runtime/services/_ops/state/build/target/debug/file.o",
            DEFAULT_STATE_DIR
        ));
        assert!(should_skip(".git/config", DEFAULT_STATE_DIR));
        assert!(!should_skip(
            ".octon/cognition/runtime/context/index.yml",
            DEFAULT_STATE_DIR
        ));
    }

    #[test]
    fn tokenize_terms_extracts_lowercase_tokens() {
        let terms = tokenize_terms("A/B-C_file.md");
        assert!(terms.contains("file"));
        assert!(terms.contains("md"));
        assert!(!terms.contains("a"));
        assert!(!terms.contains("b"));
    }

    #[test]
    fn snapshot_format_version_defaults_and_parses() {
        let no_version = serde_json::json!({
            "snapshot_id": "snap-abc12345"
        });
        assert_eq!(snapshot_format_version(&no_version), Some(1));

        let v2 = serde_json::json!({
            "snapshot_format_version": 2
        });
        assert_eq!(snapshot_format_version(&v2), Some(2));
    }

    #[test]
    fn ensure_supported_snapshot_format_rejects_invalid_version_type_and_range() {
        let invalid_type = serde_json::json!({
            "snapshot_format_version": "two"
        });
        let err_type = ensure_supported_snapshot_format(&invalid_type, DEFAULT_STATE_DIR)
            .expect_err("invalid type should fail");
        assert_eq!(err_type.code, "ERR_FILESYSTEM_INTERFACES_FORMAT_UNSUPPORTED");

        let unsupported = serde_json::json!({
            "snapshot_format_version": SNAPSHOT_MAX_SUPPORTED_FORMAT_VERSION + 1
        });
        let err_range = ensure_supported_snapshot_format(&unsupported, DEFAULT_STATE_DIR)
            .expect_err("unsupported version should fail");
        assert_eq!(err_range.code, "ERR_FILESYSTEM_INTERFACES_FORMAT_UNSUPPORTED");
    }

    #[test]
    fn probe_digest_for_bytes_is_deterministic() {
        let data = b"header-content........body........tail-content";
        let (hash_a, len_a) = probe_digest_for_bytes(data);
        let (hash_b, len_b) = probe_digest_for_bytes(data);

        assert_eq!(hash_a, hash_b);
        assert_eq!(len_a, len_b);
        assert!(!hash_a.is_empty());
    }

    #[test]
    fn parse_lock_created_ms_extracts_timestamp() {
        let body = "created_ms=12345\ncreated_at=2026-01-01T00:00:00Z\n";
        assert_eq!(parse_lock_created_ms(body), Some(12345));
        assert_eq!(parse_lock_created_ms("created_at=..."), None);
    }

    #[test]
    fn snapshot_diff_property_holds_under_randomized_inputs() {
        let universe: Vec<String> = (0..48).map(|i| format!("file-{i:02}.txt")).collect();

        for seed in 0..96u64 {
            let mut rng = TestRng::new(seed);
            let mut base = BTreeMap::new();
            let mut head = BTreeMap::new();

            for path in &universe {
                let in_base = rng.next_bool();
                let in_head = rng.next_bool();

                if in_base {
                    base.insert(path.clone(), format!("{:08x}", rng.next_u32()));
                }

                if in_head {
                    let sha = if in_base && rng.next_bool() {
                        base.get(path)
                            .cloned()
                            .unwrap_or_else(|| format!("{:08x}", rng.next_u32()))
                    } else {
                        format!("{:08x}", rng.next_u32())
                    };
                    head.insert(path.clone(), sha);
                }
            }

            let (added, removed, changed) = compute_snapshot_diff(&base, &head);

            let added_paths: BTreeSet<String> = added
                .iter()
                .filter_map(|v| v.get("path").and_then(Value::as_str).map(str::to_string))
                .collect();
            let removed_paths: BTreeSet<String> = removed
                .iter()
                .filter_map(|v| v.get("path").and_then(Value::as_str).map(str::to_string))
                .collect();
            let changed_paths: BTreeSet<String> = changed
                .iter()
                .filter_map(|v| v.get("path").and_then(Value::as_str).map(str::to_string))
                .collect();

            assert!(added_paths.is_disjoint(&removed_paths));
            assert!(added_paths.is_disjoint(&changed_paths));
            assert!(removed_paths.is_disjoint(&changed_paths));

            for path in &universe {
                let in_base = base.get(path);
                let in_head = head.get(path);

                match (in_base, in_head) {
                    (None, Some(_)) => assert!(added_paths.contains(path)),
                    (Some(_), None) => assert!(removed_paths.contains(path)),
                    (Some(base_sha), Some(head_sha)) if base_sha != head_sha => {
                        assert!(changed_paths.contains(path))
                    }
                    _ => {
                        assert!(!added_paths.contains(path));
                        assert!(!removed_paths.contains(path));
                        assert!(!changed_paths.contains(path));
                    }
                }
            }
        }
    }

    #[test]
    fn traverse_edges_matches_reference_bfs_under_randomized_graphs() {
        fn reference_traverse(
            start: &str,
            depth: usize,
            edge_type_filter: &str,
            edges: &[EdgeRecord],
        ) -> (BTreeSet<String>, BTreeSet<(String, String, String)>) {
            let mut queue: VecDeque<(String, usize)> = VecDeque::new();
            let mut visited = BTreeSet::new();
            let mut traversed = BTreeSet::new();

            queue.push_back((start.to_string(), 0));
            visited.insert(start.to_string());

            while let Some((current, d)) = queue.pop_front() {
                if d >= depth {
                    continue;
                }

                for edge in edges {
                    if edge.src != current {
                        continue;
                    }
                    if !edge_type_filter.is_empty() && edge.edge_type != edge_type_filter {
                        continue;
                    }
                    traversed.insert((edge.src.clone(), edge.dst.clone(), edge.edge_type.clone()));
                    if visited.insert(edge.dst.clone()) {
                        queue.push_back((edge.dst.clone(), d + 1));
                    }
                }
            }

            (visited, traversed)
        }

        for seed in 0..64u64 {
            let mut rng = TestRng::new(seed.wrapping_add(7));
            let node_count = 10usize;
            let node_ids: Vec<String> = (0..node_count).map(|i| format!("n{i}")).collect();
            let mut edges = Vec::new();

            for src_idx in 0..node_count {
                for dst_idx in 0..node_count {
                    if src_idx == dst_idx {
                        continue;
                    }
                    if rng.next_usize(4) != 0 {
                        continue;
                    }
                    edges.push(EdgeRecord {
                        src: node_ids[src_idx].clone(),
                        dst: node_ids[dst_idx].clone(),
                        edge_type: if rng.next_bool() {
                            "CONTAINS".to_string()
                        } else {
                            "REF".to_string()
                        },
                    });
                }
            }

            let start = &node_ids[rng.next_usize(node_ids.len())];
            let depth = rng.next_usize(5);
            let edge_filter = if rng.next_bool() { "CONTAINS" } else { "" };

            let (visited_a, traversed_a) = traverse_edges(start, depth, edge_filter, &edges);
            let (visited_b, traversed_b) = reference_traverse(start, depth, edge_filter, &edges);

            assert_eq!(visited_a, visited_b);
            assert_eq!(traversed_a, traversed_b);
        }
    }

    #[test]
    fn tokenize_terms_fuzz_preserves_token_constraints() {
        let alphabet =
            b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_/.:()[]{} \t\n";
        let mut rng = TestRng::new(42);

        for _ in 0..256 {
            let len = 1 + rng.next_usize(160);
            let mut sample = String::new();
            for _ in 0..len {
                let idx = rng.next_usize(alphabet.len());
                sample.push(alphabet[idx] as char);
            }

            let terms = tokenize_terms(&sample);
            for term in terms {
                assert!(term.len() >= 2);
                assert!(term
                    .chars()
                    .all(|c| c.is_ascii_lowercase() || c.is_ascii_digit()));
            }
        }
    }

    #[test]
    fn parse_jsonl_fuzz_returns_error_or_value_without_panicking() {
        let mut rng = TestRng::new(1234);
        let chars = b"{}[]\":,abcdefghijklmnopqrstuvwxyz0123456789 \n";

        for _ in 0..256 {
            let len = 1 + rng.next_usize(256);
            let mut sample = String::new();
            for _ in 0..len {
                sample.push(chars[rng.next_usize(chars.len())] as char);
            }

            let _ = parse_jsonl::<Value>(&sample);
        }
    }

    #[test]
    fn latency_budget_is_defined_for_all_public_ops() {
        let ops = [
            "fs.list",
            "fs.read",
            "fs.stat",
            "fs.search",
            "snapshot.build",
            "snapshot.diff",
            "snapshot.get-current",
            "kg.get-node",
            "kg.neighbors",
            "kg.traverse",
            "kg.resolve-to-file",
            "discover.start",
            "discover.expand",
            "discover.explain",
            "discover.resolve",
        ];

        for op in ops {
            assert!(op_latency_budget_ms(op) > 0);
        }
    }

    fn service_root() -> PathBuf {
        PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("..")
    }

    fn declared_error_codes() -> BTreeSet<String> {
        let errors_yml = service_root().join("contracts").join("errors.yml");
        let content = fs::read_to_string(errors_yml).expect("read contracts/errors.yml");
        let mut out = BTreeSet::new();

        for line in content.lines() {
            let trimmed = line.trim();
            if !trimmed.starts_with("- code:") && !trimmed.starts_with("code:") {
                continue;
            }
            if let Some(code) = trimmed.split_whitespace().nth(2) {
                out.insert(code.to_string());
            } else if let Some(code) = trimmed.split_whitespace().nth(1) {
                out.insert(code.to_string());
            }
        }

        out
    }

    fn runtime_error_codes_from_source() -> BTreeSet<String> {
        let mut out = BTreeSet::new();
        for token in
            include_str!("lib.rs").split(|c: char| !(c.is_ascii_alphanumeric() || c == '_'))
        {
            if token.starts_with("ERR_FILESYSTEM_INTERFACES_") && token != "ERR_FILESYSTEM_INTERFACES_" {
                out.insert(token.to_string());
            }
        }
        out
    }

    fn has_error_envelope(schema: &Value) -> bool {
        let branches = schema
            .get("anyOf")
            .or_else(|| schema.get("oneOf"))
            .and_then(Value::as_array);

        let Some(branches) = branches else {
            return false;
        };

        branches.iter().any(|branch| {
            let Some(props) = branch.get("properties").and_then(Value::as_object) else {
                return false;
            };

            let Some(required) = branch.get("required").and_then(Value::as_array) else {
                return false;
            };
            let has_required = |field: &str| required.iter().any(|v| v.as_str() == Some(field));

            let ok_false = props
                .get("ok")
                .and_then(|v| v.get("const"))
                .and_then(Value::as_bool)
                == Some(false);

            let contract_version_present = props.contains_key("filesystem_interfaces_contract_version");

            let error_has_code_message = props
                .get("error")
                .and_then(|v| v.get("properties"))
                .and_then(Value::as_object)
                .map(|error_props| {
                    error_props.contains_key("code") && error_props.contains_key("message")
                })
                .unwrap_or(false);

            ok_false
                && contract_version_present
                && error_has_code_message
                && has_required("ok")
                && has_required("filesystem_interfaces_contract_version")
                && has_required("error")
        })
    }

    #[test]
    fn documented_errors_cover_runtime_errors() {
        let declared = declared_error_codes();
        let used = runtime_error_codes_from_source();
        let missing: Vec<String> = used
            .into_iter()
            .filter(|code| !declared.contains(code))
            .collect();

        assert!(
            missing.is_empty(),
            "contracts/errors.yml is missing runtime error codes: {missing:?}"
        );
    }

    #[test]
    fn every_op_output_schema_includes_error_envelope() {
        let service_json = service_root().join("service.json");
        let payload = fs::read_to_string(service_json).expect("read service.json");
        let manifest: Value = serde_json::from_str(&payload).expect("parse service.json");
        let ops = manifest
            .get("ops")
            .and_then(Value::as_object)
            .expect("ops object in service.json");

        let mut missing = Vec::new();
        for (op, decl) in ops {
            let output_schema = decl.get("output_schema");
            if output_schema.is_none() || !has_error_envelope(output_schema.unwrap()) {
                missing.push(op.clone());
            }
        }

        assert!(
            missing.is_empty(),
            "ops missing standard error envelope in output_schema: {missing:?}"
        );
    }
}

bindings::export!(Service with_types_in bindings);
