use std::collections::BTreeMap;
use std::path::Path;

pub fn default_bound_inputs(target: &Path) -> BTreeMap<String, String> {
    let target = target.display().to_string();
    BTreeMap::from([
        ("target".to_string(), target.clone()),
        ("proposal_path".to_string(), target),
    ])
}
