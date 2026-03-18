use std::collections::{HashMap, VecDeque};

#[derive(Debug, Clone)]
pub struct Node {
    pub id: String,
}

#[derive(Debug, Clone)]
pub struct Edge {
    pub from: String,
    pub to: String,
}

#[derive(Debug, Clone)]
pub struct PositionedNode {
    pub id: String,
    pub x: f32,
    pub y: f32,
}

pub fn layered_layout(nodes: &[Node], edges: &[Edge]) -> Vec<PositionedNode> {
    const X_START: f32 = 80.0;
    const Y_START: f32 = 110.0;
    const X_STEP: f32 = 260.0;
    const Y_STEP: f32 = 86.0;

    let mut index_by_id: HashMap<&str, usize> = HashMap::new();
    for (index, node) in nodes.iter().enumerate() {
        index_by_id.insert(node.id.as_str(), index);
    }

    let mut indegree = vec![0usize; nodes.len()];
    let mut outgoing = vec![Vec::<usize>::new(); nodes.len()];

    for edge in edges {
        let Some(&from_index) = index_by_id.get(edge.from.as_str()) else {
            continue;
        };
        let Some(&to_index) = index_by_id.get(edge.to.as_str()) else {
            continue;
        };
        outgoing[from_index].push(to_index);
        indegree[to_index] += 1;
    }

    let mut queue = VecDeque::new();
    let mut level = vec![0usize; nodes.len()];
    for (index, degree) in indegree.iter().enumerate() {
        if *degree == 0 {
            queue.push_back(index);
        }
    }

    while let Some(current) = queue.pop_front() {
        let next_level = level[current] + 1;
        for &neighbor in &outgoing[current] {
            if level[neighbor] < next_level {
                level[neighbor] = next_level;
            }
            indegree[neighbor] -= 1;
            if indegree[neighbor] == 0 {
                queue.push_back(neighbor);
            }
        }
    }

    // Cycles are valid in exploratory workflow graphs; place unresolved nodes in a fallback band.
    let fallback_level = level.iter().copied().max().unwrap_or(0) + 1;
    for (index, degree) in indegree.iter().enumerate() {
        if *degree > 0 {
            level[index] = fallback_level;
        }
    }

    let mut lane_counts: HashMap<usize, usize> = HashMap::new();
    let mut positioned = Vec::with_capacity(nodes.len());
    for (index, node) in nodes.iter().enumerate() {
        let lane = lane_counts.entry(level[index]).or_insert(0);
        let x = X_START + level[index] as f32 * X_STEP;
        let y = Y_START + *lane as f32 * Y_STEP;
        *lane += 1;
        positioned.push(PositionedNode {
            id: node.id.clone(),
            x,
            y,
        });
    }

    positioned
}
