use serde::{Deserialize, Serialize};
use std::collections::{BTreeMap, BTreeSet};

#[allow(warnings)]
mod bindings;

const CONTRACT_VERSION: &str = "1.0.0";
const DEFAULT_STATE_KEY: &str = "filesystem-watch:default";
const DEFAULT_STATE_DIR: &str = ".harmony/runtime/_ops/state/watch";
const DEFAULT_ROOT: &str = ".";
const DEFAULT_MAX_EVENTS: usize = 500;
const MAX_EVENTS_HARD: usize = 10_000;
const DEFAULT_MAX_FILES: usize = 50_000;
const MAX_STATE_SAMPLE: usize = 1_000;

#[derive(Default)]
pub struct Service;

#[derive(Debug, Deserialize)]
#[serde(default)]
struct PollInput {
    root: String,
    state_dir: String,
    state_key: String,
    max_events: usize,
    max_files: usize,
}

impl Default for PollInput {
    fn default() -> Self {
        Self {
            root: DEFAULT_ROOT.to_string(),
            state_dir: DEFAULT_STATE_DIR.to_string(),
            state_key: DEFAULT_STATE_KEY.to_string(),
            max_events: DEFAULT_MAX_EVENTS,
            max_files: DEFAULT_MAX_FILES,
        }
    }
}

#[derive(Debug, Deserialize, Serialize, Clone, PartialEq, Eq)]
struct FileFingerprint {
    size: u64,
    modified_ms: Option<u64>,
}

#[derive(Debug, Deserialize, Serialize)]
struct WatchState {
    cursor: String,
    files: BTreeMap<String, FileFingerprint>,
}

#[derive(Debug, Serialize)]
struct WatchEvent {
    path: String,
    change: String,
}

#[derive(Debug, Serialize)]
struct WatchSummary {
    added: usize,
    removed: usize,
    changed: usize,
    total_files: usize,
    sample_size: usize,
    truncated: bool,
}

#[derive(Debug, Serialize)]
struct PollOutput {
    ok: bool,
    filesystem_watch_contract_version: String,
    cursor: String,
    state_key: String,
    scanned_at_ms: u64,
    summary: WatchSummary,
    events: Vec<WatchEvent>,
}

#[derive(Debug, Serialize)]
struct ErrorBody {
    code: String,
    message: String,
}

#[derive(Debug, Serialize)]
struct ErrorOutput {
    ok: bool,
    filesystem_watch_contract_version: String,
    error: ErrorBody,
}

impl bindings::Guest for Service {
    fn invoke(op: String, input_json: String) -> String {
        match op.as_str() {
            "watch.poll" => op_watch_poll(&input_json),
            _ => err_json(
                "ERR_FILESYSTEM_WATCH_INPUT_INVALID",
                &format!("Unsupported operation: {op}"),
            ),
        }
    }
}

fn op_watch_poll(input_json: &str) -> String {
    let input: PollInput = match serde_json::from_str(input_json) {
        Ok(v) => v,
        Err(err) => {
            return err_json(
                "ERR_FILESYSTEM_WATCH_INPUT_INVALID",
                &format!("Input payload failed validation: {err}"),
            )
        }
    };

    if input.max_events == 0 || input.max_events > MAX_EVENTS_HARD {
        return err_json(
            "ERR_FILESYSTEM_WATCH_LIMIT_EXCEEDED",
            &format!(
                "max_events must be between 1 and {} (received {}).",
                MAX_EVENTS_HARD, input.max_events
            ),
        );
    }

    if input.max_files == 0 {
        return err_json(
            "ERR_FILESYSTEM_WATCH_LIMIT_EXCEEDED",
            "max_files must be greater than 0.",
        );
    }

    let root = normalize_rel_path(&input.root);
    if root.is_empty() {
        return err_json(
            "ERR_FILESYSTEM_WATCH_INPUT_INVALID",
            "root must not be empty.",
        );
    }

    let state_dir = normalize_rel_path(&input.state_dir);
    if state_dir.is_empty() {
        return err_json(
            "ERR_FILESYSTEM_WATCH_INPUT_INVALID",
            "state_dir must not be empty.",
        );
    }

    let state_key = if input.state_key.trim().is_empty() {
        DEFAULT_STATE_KEY.to_string()
    } else {
        input.state_key.trim().to_string()
    };
    let state_file = state_file_path(&state_dir, &state_key);

    let previous = load_previous_state(&state_file);

    let current_files = match collect_fingerprints(&root, input.max_files, &state_dir) {
        Ok(v) => v,
        Err((code, message)) => return err_json(&code, &message),
    };
    let sampled_files = sample_state_files(&current_files);

    let cursor = compute_cursor(&current_files);
    let previous_cursor = previous
        .as_ref()
        .map(|state| state.cursor.clone())
        .unwrap_or_default();
    let (mut events, added, removed, mut changed) = diff_states(
        previous
            .as_ref()
            .map(|state| &state.files)
            .unwrap_or(&BTreeMap::new()),
        &sampled_files,
    );
    if !previous_cursor.is_empty()
        && previous_cursor != cursor
        && added == 0
        && removed == 0
        && changed == 0
    {
        changed = 1;
        events.push(WatchEvent {
            path: root.clone(),
            change: "changed".to_string(),
        });
    }

    let truncated = events.len() > input.max_events;
    if truncated {
        events.truncate(input.max_events);
    }

    let persisted = WatchState {
        cursor: cursor.clone(),
        files: sampled_files,
    };
    if let Err(message) = persist_state(&state_file, &persisted) {
        return err_json("ERR_FILESYSTEM_WATCH_INTERNAL", &message);
    }

    let scanned_at_ms = bindings::clock::now_ms();
    let _ = bindings::log::write(
        "info",
        &format!(
            "filesystem_watch.metric op=watch.poll ok=true total_files={} added={} removed={} changed={} events={} truncated={}",
            current_files.len(),
            added,
            removed,
            changed,
            events.len(),
            truncated
        ),
    );

    serde_json::to_string(&PollOutput {
        ok: true,
        filesystem_watch_contract_version: CONTRACT_VERSION.to_string(),
        cursor,
        state_key,
        scanned_at_ms,
        summary: WatchSummary {
            added,
            removed,
            changed,
            total_files: current_files.len(),
            sample_size: persisted.files.len(),
            truncated,
        },
        events,
    })
    .unwrap_or_else(|_| {
        err_json(
            "ERR_FILESYSTEM_WATCH_INTERNAL",
            "Failed to serialize watch output.",
        )
    })
}

fn load_previous_state(state_key: &str) -> Option<WatchState> {
    if !bindings::fs::exists(state_key) {
        return None;
    }
    let raw = bindings::fs::read_text(state_key);
    match serde_json::from_str::<WatchState>(&raw) {
        Ok(state) => Some(state),
        Err(err) => {
            let _ = bindings::log::write(
                "warn",
                &format!(
                    "filesystem_watch.metric op=watch.poll ok=false code=ERR_FILESYSTEM_WATCH_INTERNAL state_key={} detail=invalid_previous_state err={}",
                    state_key, err
                ),
            );
            None
        }
    }
}

fn collect_fingerprints(
    root: &str,
    max_files: usize,
    state_dir: &str,
) -> Result<BTreeMap<String, FileFingerprint>, (String, String)> {
    let mut files = BTreeMap::new();

    let Some(root_stat) = fs_get_stat(root) else {
        return Err((
            "ERR_FILESYSTEM_WATCH_INPUT_INVALID".to_string(),
            format!("root path does not exist: {root}"),
        ));
    };

    if matches!(root_stat.kind, bindings::fs::NodeKind::File) {
        let normalized = normalize_rel_path(root);
        files.insert(
            normalized,
            FileFingerprint {
                size: root_stat.size,
                modified_ms: root_stat.modified_ms,
            },
        );
        return Ok(files);
    }

    let mut stack = vec![normalize_rel_path(root)];
    while let Some(dir_path) = stack.pop() {
        let mut entries: Vec<String> = fs_list_dir_paths(&dir_path)
            .into_iter()
            .map(|p| normalize_rel_path(&p))
            .filter(|p| !p.is_empty())
            .collect();
        entries.sort();
        entries.dedup();

        for path in entries {
            if should_skip(&path, state_dir) {
                continue;
            }
            let Some(stat) = fs_get_stat(&path) else {
                continue;
            };
            if matches!(stat.kind, bindings::fs::NodeKind::Dir) {
                stack.push(path);
                continue;
            }

            files.insert(
                path,
                FileFingerprint {
                    size: stat.size,
                    modified_ms: stat.modified_ms,
                },
            );

            if files.len() > max_files {
                return Err((
                    "ERR_FILESYSTEM_WATCH_LIMIT_EXCEEDED".to_string(),
                    format!(
                        "watch.poll exceeded max_files limit ({} > {}).",
                        files.len(),
                        max_files
                    ),
                ));
            }
        }
    }

    Ok(files)
}

fn diff_states(
    previous: &BTreeMap<String, FileFingerprint>,
    current: &BTreeMap<String, FileFingerprint>,
) -> (Vec<WatchEvent>, usize, usize, usize) {
    let mut all_paths = BTreeSet::new();
    all_paths.extend(previous.keys().cloned());
    all_paths.extend(current.keys().cloned());

    let mut events = Vec::new();
    let mut added = 0usize;
    let mut removed = 0usize;
    let mut changed = 0usize;

    for path in all_paths {
        match (previous.get(&path), current.get(&path)) {
            (None, Some(_)) => {
                added += 1;
                events.push(WatchEvent {
                    path,
                    change: "added".to_string(),
                });
            }
            (Some(_), None) => {
                removed += 1;
                events.push(WatchEvent {
                    path,
                    change: "removed".to_string(),
                });
            }
            (Some(prev), Some(curr)) if prev != curr => {
                changed += 1;
                events.push(WatchEvent {
                    path,
                    change: "changed".to_string(),
                });
            }
            _ => {}
        }
    }

    (events, added, removed, changed)
}

fn compute_cursor(files: &BTreeMap<String, FileFingerprint>) -> String {
    let mut hash: u64 = 0xcbf29ce484222325;
    for (path, fp) in files {
        hash = fnv1a_update(hash, path.as_bytes());
        hash = fnv1a_update(hash, b"\t");
        hash = fnv1a_update(hash, fp.size.to_string().as_bytes());
        hash = fnv1a_update(hash, b"\t");
        match fp.modified_ms {
            Some(ms) => hash = fnv1a_update(hash, ms.to_string().as_bytes()),
            None => hash = fnv1a_update(hash, b"null"),
        }
        hash = fnv1a_update(hash, b"\n");
    }
    format!("watch-{hash:016x}")
}

fn sample_state_files(
    files: &BTreeMap<String, FileFingerprint>,
) -> BTreeMap<String, FileFingerprint> {
    let mut sampled = BTreeMap::new();
    for (path, fp) in files.iter().take(MAX_STATE_SAMPLE) {
        sampled.insert(path.clone(), fp.clone());
    }
    sampled
}

fn fnv1a_update(mut hash: u64, data: &[u8]) -> u64 {
    const FNV_PRIME: u64 = 0x100000001b3;
    for b in data {
        hash ^= *b as u64;
        hash = hash.wrapping_mul(FNV_PRIME);
    }
    hash
}

fn normalize_rel_path(path: &str) -> String {
    let mut out = path.replace('\\', "/");
    while out.starts_with("./") {
        out = out[2..].to_string();
    }
    while out.starts_with('/') {
        out = out[1..].to_string();
    }
    while out.ends_with('/') && out.len() > 1 {
        out.pop();
    }
    if out.is_empty() {
        ".".to_string()
    } else {
        out
    }
}

fn should_skip(path: &str, state_dir: &str) -> bool {
    let p = normalize_rel_path(path);
    const PREFIXES: [&str; 5] = [
        ".git",
        ".harmony/runtime/_ops/state/traces",
        ".harmony/runtime/_ops/state/build",
        ".harmony/runtime/_ops/state/snapshots",
        ".harmony/runtime/_ops/state/watch",
    ];

    for prefix in PREFIXES {
        if p == prefix || p.starts_with(&format!("{prefix}/")) {
            return true;
        }
    }
    if !state_dir.is_empty() && (p == state_dir || p.starts_with(&format!("{state_dir}/"))) {
        return true;
    }
    false
}

fn state_file_path(state_dir: &str, state_key: &str) -> String {
    let key = sanitize_state_key(state_key);
    format!("{state_dir}/{key}.json")
}

fn sanitize_state_key(value: &str) -> String {
    let mut out = String::new();
    for ch in value.chars() {
        if ch.is_ascii_alphanumeric() || ch == '-' || ch == '_' {
            out.push(ch);
        } else {
            out.push('_');
        }
    }
    if out.is_empty() {
        "default".to_string()
    } else {
        out
    }
}

fn persist_state(state_file: &str, state: &WatchState) -> Result<(), String> {
    let serialized = serde_json::to_string(state)
        .map_err(|err| format!("failed to encode watch state: {err}"))?;
    if let Some(parent) = parent_dir(state_file) {
        bindings::fs::mkdirp(&parent);
    }
    bindings::fs::write_text(state_file, &serialized);
    Ok(())
}

fn parent_dir(path: &str) -> Option<String> {
    path.rsplit_once('/').map(|(parent, _)| parent.to_string())
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

fn err_json(code: &str, message: &str) -> String {
    let _ = bindings::log::write(
        "error",
        &format!(
            "filesystem_watch.metric op=watch.poll ok=false code={} message={}",
            code, message
        ),
    );
    serde_json::to_string(&ErrorOutput {
        ok: false,
        filesystem_watch_contract_version: CONTRACT_VERSION.to_string(),
        error: ErrorBody {
            code: code.to_string(),
            message: message.to_string(),
        },
    })
    .unwrap_or_else(|_| {
        "{\"ok\":false,\"filesystem_watch_contract_version\":\"1.0.0\",\"error\":{\"code\":\"ERR_FILESYSTEM_WATCH_INTERNAL\",\"message\":\"failed to encode error\"}}".to_string()
    })
}

bindings::export!(Service with_types_in bindings);
