use std::env;
use std::path::PathBuf;

pub fn find_binary(name: &str) -> Option<PathBuf> {
    if name.contains(std::path::MAIN_SEPARATOR) {
        let path = PathBuf::from(name);
        return path.is_file().then_some(path);
    }
    let path_var = env::var_os("PATH")?;
    for entry in env::split_paths(&path_var) {
        let candidate = entry.join(name);
        if candidate.is_file() {
            return Some(candidate);
        }
    }
    None
}

pub fn resolve_executor(executor: &str) -> Option<(&'static str, PathBuf)> {
    match executor {
        "codex" => find_binary("codex").map(|path| ("codex", path)),
        "claude" => find_binary("claude").map(|path| ("claude", path)),
        "auto" => find_binary("codex")
            .map(|path| ("codex", path))
            .or_else(|| find_binary("claude").map(|path| ("claude", path))),
        _ => None,
    }
}
