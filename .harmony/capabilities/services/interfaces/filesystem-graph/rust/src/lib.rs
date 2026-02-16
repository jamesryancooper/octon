use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use std::collections::{BTreeMap, BTreeSet, VecDeque};
use std::path::{Component, Path};

#[allow(warnings)]
mod bindings;

#[derive(Default)]
pub struct Service;

const CONTRACT_VERSION: &str = "1.0.0";
const DEFAULT_STATE_DIR: &str = ".harmony/runtime/_ops/state/snapshots";

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
    modified_epoch: u64,
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

#[derive(Debug, Clone)]
struct SnapshotData {
    snapshot_id: String,
    manifest: Value,
    files: Vec<FileRecord>,
    nodes: Vec<NodeRecord>,
    edges: Vec<EdgeRecord>,
}

impl bindings::Guest for Service {
    fn invoke(op: String, input_json: String) -> String {
        let input: Value = match serde_json::from_str::<Value>(&input_json) {
            Ok(v) if v.is_object() => v,
            Ok(_) => {
                return error_json(
                    "ERR_FILESYSTEM_GRAPH_INPUT_INVALID",
                    "Input must be a JSON object.",
                )
            }
            Err(e) => {
                return error_json(
                    "ERR_FILESYSTEM_GRAPH_INPUT_INVALID",
                    &format!("Invalid JSON input: {e}"),
                )
            }
        };

        match handle_op(&op, &input) {
            Ok(v) => serde_json::to_string(&v).unwrap_or_else(|_| {
                error_json(
                    "ERR_FILESYSTEM_GRAPH_INTERNAL",
                    "Failed to serialize service output.",
                )
            }),
            Err(e) => error_json(e.code, &e.message),
        }
    }
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
            "ERR_FILESYSTEM_GRAPH_OPERATION_UNSUPPORTED",
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
                    "ERR_FILESYSTEM_GRAPH_PATH_INVALID",
                    format!("Path is not a directory: {path}"),
                ));
            }
        }
        None => {
            return Err(err(
                "ERR_FILESYSTEM_GRAPH_NOT_FOUND",
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
                    "ERR_FILESYSTEM_GRAPH_PATH_INVALID",
                    format!("Path is not a file: {path}"),
                ));
            }
        }
        None => {
            return Err(err(
                "ERR_FILESYSTEM_GRAPH_NOT_FOUND",
                format!("File not found: {path}"),
            ))
        }
    }

    let bytes = bindings::fs::read(&path);
    let cut = bytes.len().min(max_bytes);
    let content = String::from_utf8_lossy(&bytes[..cut]).to_string();

    Ok(json!({
        "path": path,
        "content": content,
        "total_size": bytes.len(),
        "max_bytes": max_bytes,
        "truncated": bytes.len() > max_bytes
    }))
}

fn op_fs_stat(input: &Value) -> Result<Value, ServiceError> {
    let path = norm_rel_required(get_str(input, "path")?)?;

    let stat = fs_get_stat(&path)
        .ok_or_else(|| err("ERR_FILESYSTEM_GRAPH_NOT_FOUND", format!("Path not found: {path}")))?;

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
            "ERR_FILESYSTEM_GRAPH_INPUT_INVALID",
            "payload.pattern is required.",
        ));
    }

    let path = norm_rel_or_default(get_str(input, "path")?, ".")?;
    let limit = get_u64_or(input, "limit", 50) as usize;

    let stat = fs_get_stat(&path)
        .ok_or_else(|| err("ERR_FILESYSTEM_GRAPH_NOT_FOUND", format!("Path not found: {path}")))?;

    let mut files = Vec::new();
    match stat.kind {
        bindings::fs::NodeKind::File => files.push(path.clone()),
        bindings::fs::NodeKind::Dir => collect_files_recursive(&path, DEFAULT_STATE_DIR, &mut files)?,
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

    match fs_get_stat(&root) {
        Some(stat) => {
            if !matches!(stat.kind, bindings::fs::NodeKind::Dir) {
                return Err(err(
                    "ERR_FILESYSTEM_GRAPH_PATH_INVALID",
                    format!("Root is not a directory: {root}"),
                ));
            }
        }
        None => {
            return Err(err(
                "ERR_FILESYSTEM_GRAPH_PATH_INVALID",
                format!("Root path not found: {root}"),
            ))
        }
    }

    bindings::fs::mkdirp(&state_dir);

    let mut files = Vec::new();
    let mut dirs = BTreeSet::new();
    let mut edges: BTreeSet<(String, String, String)> = BTreeSet::new();

    collect_snapshot_data(&root, &state_dir, &mut files, &mut dirs, &mut edges)?;

    if files.is_empty() {
        return Err(err(
            "ERR_FILESYSTEM_GRAPH_NOT_FOUND",
            "No files discovered for snapshot.",
        ));
    }

    files.sort_by(|a, b| a.path.cmp(&b.path));

    let mut file_lines = Vec::new();
    let mut seed_lines = Vec::new();
    for f in &files {
        file_lines.push(serde_json::to_string(f).map_err(|e| {
            err(
                "ERR_FILESYSTEM_GRAPH_INTERNAL",
                format!("Failed to serialize file record: {e}"),
            )
        })?);
        seed_lines.push(format!(
            "{}\t{}\t{}\t{}",
            f.path, f.sha256, f.size_bytes, f.modified_epoch
        ));
    }
    seed_lines.sort();

    let input_fingerprint = sha256_hex(seed_lines.join("\n").as_bytes());
    let snapshot_id = format!("snap-{}", &input_fingerprint[..16]);
    let snapshot_dir = join_path(&state_dir, &snapshot_id);

    bindings::fs::mkdirp(&snapshot_dir);

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
                "ERR_FILESYSTEM_GRAPH_INTERNAL",
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
                "ERR_FILESYSTEM_GRAPH_INTERNAL",
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
                "ERR_FILESYSTEM_GRAPH_INTERNAL",
                format!("Failed to serialize edge: {e}"),
            )
        })?);
    }

    write_jsonl_file(&join_path(&snapshot_dir, "files.jsonl"), &file_lines)?;
    write_jsonl_file(&join_path(&snapshot_dir, "nodes.jsonl"), &node_lines)?;
    write_jsonl_file(&join_path(&snapshot_dir, "edges.jsonl"), &edge_lines)?;

    let manifest = json!({
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

    write_text_file(
        &join_path(&snapshot_dir, "manifest.json"),
        &serde_json::to_string(&manifest).map_err(|e| {
            err(
                "ERR_FILESYSTEM_GRAPH_INTERNAL",
                format!("Failed to serialize manifest: {e}"),
            )
        })?,
    )?;

    if set_current {
        write_text_file(&join_path(&state_dir, "current"), &snapshot_id)?;
    }

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
        "set_current": set_current
    }))
}

fn op_snapshot_get_current(input: &Value) -> Result<Value, ServiceError> {
    let state_dir = norm_rel_or_default(get_str(input, "state_dir")?, DEFAULT_STATE_DIR)?;
    let current_path = join_path(&state_dir, "current");

    if !fs_exists(&current_path) {
        return Err(err(
            "ERR_FILESYSTEM_GRAPH_NOT_FOUND",
            "No active snapshot pointer found.",
        ));
    }

    let snapshot_id = read_text_file(&current_path)?.trim().to_string();
    if snapshot_id.is_empty() {
        return Err(err(
            "ERR_FILESYSTEM_GRAPH_SNAPSHOT_INVALID",
            "Active snapshot pointer is empty.",
        ));
    }

    let snapshot_dir = join_path(&state_dir, &snapshot_id);
    let manifest_path = join_path(&snapshot_dir, "manifest.json");

    let manifest = if fs_exists(&manifest_path) {
        let manifest_text = read_text_file(&manifest_path)?;
        serde_json::from_str::<Value>(&manifest_text).unwrap_or_else(|_| json!({}))
    } else {
        json!({})
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
            "ERR_FILESYSTEM_GRAPH_INPUT_INVALID",
            "Both base and head are required.",
        ));
    }

    let (base_id, base_dir) = resolve_snapshot_ref(&state_dir, &base_input)?;
    let (head_id, head_dir) = resolve_snapshot_ref(&state_dir, &head_input)?;

    let base_files = parse_files_map(&join_path(&base_dir, "files.jsonl"))?;
    let head_files = parse_files_map(&join_path(&head_dir, "files.jsonl"))?;

    let mut added = Vec::new();
    let mut removed = Vec::new();
    let mut changed = Vec::new();

    for (path, sha) in &head_files {
        match base_files.get(path) {
            None => added.push(json!({"path": path, "sha256": sha})),
            Some(base_sha) if base_sha != sha => {
                changed.push(json!({"path": path, "base_sha256": base_sha, "head_sha256": sha}))
            }
            _ => {}
        }
    }

    for (path, sha) in &base_files {
        if !head_files.contains_key(path) {
            removed.push(json!({"path": path, "sha256": sha}));
        }
    }

    added.sort_by(|a, b| {
        a["path"]
            .as_str()
            .unwrap_or("")
            .cmp(b["path"].as_str().unwrap_or(""))
    });
    removed.sort_by(|a, b| {
        a["path"]
            .as_str()
            .unwrap_or("")
            .cmp(b["path"].as_str().unwrap_or(""))
    });
    changed.sort_by(|a, b| {
        a["path"]
            .as_str()
            .unwrap_or("")
            .cmp(b["path"].as_str().unwrap_or(""))
    });

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
                    "ERR_FILESYSTEM_GRAPH_INPUT_INVALID",
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
        .ok_or_else(|| err("ERR_FILESYSTEM_GRAPH_NOT_FOUND", format!("Node not found: {node_id}")))?;

    Ok(json!({"node": node}))
}

fn op_kg_neighbors(input: &Value) -> Result<Value, ServiceError> {
    let snapshot = load_snapshot(input)?;
    let node_id = get_str(input, "node_id")?
        .filter(|s| !s.is_empty())
        .ok_or_else(|| err("ERR_FILESYSTEM_GRAPH_INPUT_INVALID", "node_id is required."))?;

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
        .ok_or_else(|| err("ERR_FILESYSTEM_GRAPH_INPUT_INVALID", "start_node_id is required."))?;
    let depth = get_u64_or(input, "depth", 2) as usize;
    let edge_type_filter = get_str(input, "edge_type")?.unwrap_or_default();

    let mut queue: VecDeque<(String, usize)> = VecDeque::new();
    let mut visited: BTreeSet<String> = BTreeSet::new();
    let mut traversed: BTreeSet<(String, String, String)> = BTreeSet::new();

    queue.push_back((start.clone(), 0));
    visited.insert(start.clone());

    while let Some((current, d)) = queue.pop_front() {
        if d >= depth {
            continue;
        }

        for edge in &snapshot.edges {
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
            "ERR_FILESYSTEM_GRAPH_INPUT_INVALID",
            "query is required.",
        ));
    }

    let limit = get_u64_or(input, "limit", 20) as usize;
    let query_lower = query.to_lowercase();

    let mut candidates: BTreeMap<String, (f64, String, String)> = BTreeMap::new();

    for file in &snapshot.files {
        if file.path.to_lowercase().contains(&query_lower) {
            candidates.insert(
                format!("file:{}", file.path),
                (1.0, file.path.clone(), "path-match".to_string()),
            );
        }
    }

    for file in &snapshot.files {
        if candidates.len() >= limit.saturating_mul(2) {
            break;
        }

        if !fs_exists(&file.path) {
            continue;
        }

        let bytes = bindings::fs::read(&file.path);
        let text = String::from_utf8_lossy(&bytes).to_lowercase();
        if text.contains(&query_lower) {
            let key = format!("file:{}", file.path);
            let entry = candidates
                .entry(key)
                .or_insert((0.7, file.path.clone(), "content-match".to_string()));
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

    let ids_value = input
        .get("node_ids")
        .ok_or_else(|| err("ERR_FILESYSTEM_GRAPH_INPUT_INVALID", "node_ids is required."))?;

    let ids_arr = ids_value
        .as_array()
        .ok_or_else(|| err("ERR_FILESYSTEM_GRAPH_INPUT_INVALID", "node_ids must be an array."))?;

    if ids_arr.is_empty() {
        return Err(err(
            "ERR_FILESYSTEM_GRAPH_INPUT_INVALID",
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
            "ERR_FILESYSTEM_GRAPH_INPUT_INVALID",
            "candidate_node_ids is required.",
        )
    })?;
    let ids_arr = ids_value.as_array().ok_or_else(|| {
        err(
            "ERR_FILESYSTEM_GRAPH_INPUT_INVALID",
            "candidate_node_ids must be an array.",
        )
    })?;

    if ids_arr.is_empty() {
        return Err(err(
            "ERR_FILESYSTEM_GRAPH_INPUT_INVALID",
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
        .ok_or_else(|| err("ERR_FILESYSTEM_GRAPH_INPUT_INVALID", "node_id is required."))?;

    let node = snapshot
        .nodes
        .iter()
        .find(|n| n.node_id == node_id)
        .ok_or_else(|| err("ERR_FILESYSTEM_GRAPH_NOT_FOUND", format!("Node not found: {node_id}")))?;

    if node.node_type != "file" && node.node_type != "dir" {
        return Err(err(
            "ERR_FILESYSTEM_GRAPH_NOT_FOUND",
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
    files: &mut Vec<FileRecord>,
    dirs: &mut BTreeSet<String>,
    edges: &mut BTreeSet<(String, String, String)>,
) -> Result<(), ServiceError> {
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
                collect_snapshot_data(&child, state_dir, files, dirs, edges)?;
            }
            bindings::fs::NodeKind::File => {
                let bytes = bindings::fs::read(&child);
                let sha = sha256_hex(&bytes);
                let modified_epoch = stat.modified_ms.unwrap_or(0) / 1000;

                files.push(FileRecord {
                    path: child.clone(),
                    sha256: sha,
                    size_bytes: stat.size.max(bytes.len() as u64),
                    modified_epoch,
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

fn collect_files_recursive(dir: &str, state_dir: &str, out: &mut Vec<String>) -> Result<(), ServiceError> {
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

    let bytes = bindings::fs::read(path);
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
                    "ERR_FILESYSTEM_GRAPH_NOT_FOUND",
                    "No snapshot_id provided and no active snapshot pointer exists.",
                ));
            }
            read_text_file(&current_path)?.trim().to_string()
        }
    };

    if snapshot_id.is_empty() {
        return Err(err(
            "ERR_FILESYSTEM_GRAPH_SNAPSHOT_INVALID",
            "snapshot_id is empty.",
        ));
    }

    let snapshot_dir = join_path(&state_dir, &snapshot_id);
    let manifest_path = join_path(&snapshot_dir, "manifest.json");
    let files_path = join_path(&snapshot_dir, "files.jsonl");
    let nodes_path = join_path(&snapshot_dir, "nodes.jsonl");
    let edges_path = join_path(&snapshot_dir, "edges.jsonl");

    for p in [&manifest_path, &files_path, &nodes_path, &edges_path] {
        if !fs_exists(p) {
            return Err(err(
                "ERR_FILESYSTEM_GRAPH_SNAPSHOT_INVALID",
                format!("Missing snapshot artifact: {p}"),
            ));
        }
    }

    let manifest_text = read_text_file(&manifest_path)?;
    let manifest = serde_json::from_str::<Value>(&manifest_text).map_err(|e| {
        err(
            "ERR_FILESYSTEM_GRAPH_SNAPSHOT_INVALID",
            format!("Invalid manifest JSON: {e}"),
        )
    })?;

    let files = parse_jsonl::<FileRecord>(&read_text_file(&files_path)?)?;
    let nodes = parse_jsonl::<NodeRecord>(&read_text_file(&nodes_path)?)?;
    let edges = parse_jsonl::<EdgeRecord>(&read_text_file(&edges_path)?)?;

    Ok(SnapshotData {
        snapshot_id,
        manifest,
        files,
        nodes,
        edges,
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

fn parse_jsonl<T: for<'de> Deserialize<'de>>(text: &str) -> Result<Vec<T>, ServiceError> {
    let mut out = Vec::new();
    for (idx, line) in text.lines().enumerate() {
        let line = line.trim();
        if line.is_empty() {
            continue;
        }

        let item = serde_json::from_str::<T>(line).map_err(|e| {
            err(
                "ERR_FILESYSTEM_GRAPH_SNAPSHOT_INVALID",
                format!("Invalid JSONL at line {}: {e}", idx + 1),
            )
        })?;

        out.push(item);
    }
    Ok(out)
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
        "ERR_FILESYSTEM_GRAPH_NOT_FOUND",
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
        bindings::fs::mkdirp(&parent);
    }
    bindings::fs::write(path, content.as_bytes());
    Ok(())
}

fn read_text_file(path: &str) -> Result<String, ServiceError> {
    if !fs_exists(path) {
        return Err(err(
            "ERR_FILESYSTEM_GRAPH_NOT_FOUND",
            format!("Read failed for {path}: not found"),
        ));
    }

    let bytes = bindings::fs::read(path);
    String::from_utf8(bytes).map_err(|e| {
        err(
            "ERR_FILESYSTEM_GRAPH_SNAPSHOT_INVALID",
            format!("UTF-8 decode failed for {path}: {e}"),
        )
    })
}

fn get_str(input: &Value, key: &str) -> Result<Option<String>, ServiceError> {
    let obj = input
        .as_object()
        .ok_or_else(|| err("ERR_FILESYSTEM_GRAPH_INPUT_INVALID", "Input must be object."))?;

    Ok(obj
        .get(key)
        .and_then(Value::as_str)
        .map(|s| s.to_string()))
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
            "ERR_FILESYSTEM_GRAPH_INPUT_INVALID",
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
            "ERR_FILESYSTEM_GRAPH_PATH_INVALID",
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
                    "ERR_FILESYSTEM_GRAPH_PATH_INVALID",
                    format!("Parent directory '..' is not allowed: {raw}"),
                ))
            }
            Component::RootDir | Component::Prefix(_) => {
                return Err(err(
                    "ERR_FILESYSTEM_GRAPH_PATH_INVALID",
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
    path == ".git"
        || path.starts_with(".git/")
        || path == state_dir
        || path.starts_with(&format!("{state_dir}/"))
}

fn sha256_hex(bytes: &[u8]) -> String {
    let digest = sha256_digest(bytes);
    to_hex_lower(&digest)
}

fn sha256_digest(input: &[u8]) -> [u8; 32] {
    const H0: [u32; 8] = [
        0x6a09e667,
        0xbb67ae85,
        0x3c6ef372,
        0xa54ff53a,
        0x510e527f,
        0x9b05688c,
        0x1f83d9ab,
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

fn now_rfc3339() -> String {
    let ms = bindings::clock::now_ms();
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
        "filesystem_graph_contract_version": CONTRACT_VERSION
    })
    .to_string()
}

bindings::export!(Service with_types_in bindings);
