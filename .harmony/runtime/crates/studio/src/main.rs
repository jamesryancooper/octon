mod app_state;
mod graph;
mod staging;
mod workflows;

use anyhow::{Context, Result};
use app_state::AppState;
use slint::{ModelRc, VecModel};
use std::cell::RefCell;
use std::path::{Path, PathBuf};
use std::rc::Rc;

slint::include_modules!();

fn main() -> Result<()> {
    let launch_dir = std::env::current_dir().context("failed to read current working directory")?;
    let root = find_harmony_root(&launch_dir).unwrap_or(launch_dir);
    let state = Rc::new(RefCell::new(AppState::load(root)?));

    let window = AppWindow::new().context("failed to create Slint window")?;
    refresh_view(&window, &state.borrow());

    let weak_window = window.as_weak();
    let state_for_select = Rc::clone(&state);
    window.on_select_workflow(move |id| {
        if let Some(window) = weak_window.upgrade() {
            let mut state = state_for_select.borrow_mut();
            state.select_workflow(id.as_str());
            refresh_view(&window, &state);
        }
    });

    let weak_window = window.as_weak();
    let state_for_pan = Rc::clone(&state);
    window.on_pan_view(move |dx, dy| {
        if let Some(window) = weak_window.upgrade() {
            let mut state = state_for_pan.borrow_mut();
            state.pan_by(dx as f32, dy as f32);
            refresh_view(&window, &state);
        }
    });

    let weak_window = window.as_weak();
    let state_for_zoom = Rc::clone(&state);
    window.on_zoom_view(move |factor| {
        if let Some(window) = weak_window.upgrade() {
            let mut state = state_for_zoom.borrow_mut();
            state.zoom_by(factor);
            refresh_view(&window, &state);
        }
    });

    let weak_window = window.as_weak();
    let state_for_reset = Rc::clone(&state);
    window.on_reset_view(move || {
        if let Some(window) = weak_window.upgrade() {
            let mut state = state_for_reset.borrow_mut();
            state.reset_view();
            refresh_view(&window, &state);
        }
    });

    let weak_window = window.as_weak();
    let state_for_stage = Rc::clone(&state);
    window.on_stage_selected_edits(move || {
        if let Some(window) = weak_window.upgrade() {
            let mut state = state_for_stage.borrow_mut();
            if let Err(error) = state.stage_selected_safe_edits() {
                eprintln!("failed to stage safe edits: {error:#}");
            }
            refresh_view(&window, &state);
        }
    });

    let weak_window = window.as_weak();
    let state_for_clear = Rc::clone(&state);
    window.on_clear_staged_edits(move || {
        if let Some(window) = weak_window.upgrade() {
            let mut state = state_for_clear.borrow_mut();
            state.clear_staged_edits();
            refresh_view(&window, &state);
        }
    });

    let weak_window = window.as_weak();
    let state_for_export = Rc::clone(&state);
    window.on_export_patch_preview(move || {
        if let Some(window) = weak_window.upgrade() {
            let mut state = state_for_export.borrow_mut();
            if let Err(error) = state.export_patch_preview() {
                eprintln!("failed to export patch preview: {error:#}");
            }
            refresh_view(&window, &state);
        }
    });

    let weak_window = window.as_weak();
    let state_for_toggle_arm = Rc::clone(&state);
    window.on_toggle_apply_arm(move || {
        if let Some(window) = weak_window.upgrade() {
            let mut state = state_for_toggle_arm.borrow_mut();
            state.toggle_apply_arm();
            refresh_view(&window, &state);
        }
    });

    let weak_window = window.as_weak();
    let state_for_apply = Rc::clone(&state);
    window.on_apply_staged_edits(move || {
        if let Some(window) = weak_window.upgrade() {
            let mut state = state_for_apply.borrow_mut();
            if let Err(error) = state.apply_staged_edits() {
                eprintln!("failed to apply staged edits: {error:#}");
            }
            refresh_view(&window, &state);
        }
    });

    let weak_window = window.as_weak();
    let state_for_refresh_audits = Rc::clone(&state);
    window.on_refresh_audits(move || {
        if let Some(window) = weak_window.upgrade() {
            let mut state = state_for_refresh_audits.borrow_mut();
            state.refresh_audit_index();
            refresh_view(&window, &state);
        }
    });

    let weak_window = window.as_weak();
    let state_for_select_audit = Rc::clone(&state);
    window.on_select_audit(move |index| {
        if let Some(window) = weak_window.upgrade() {
            let mut state = state_for_select_audit.borrow_mut();
            state.select_audit(index);
            refresh_view(&window, &state);
        }
    });

    let weak_window = window.as_weak();
    let state_for_open_audit = Rc::clone(&state);
    window.on_open_selected_audit(move || {
        if let Some(window) = weak_window.upgrade() {
            let mut state = state_for_open_audit.borrow_mut();
            if let Err(error) = state.open_selected_audit_location() {
                eprintln!("failed to open selected audit location: {error:#}");
            }
            refresh_view(&window, &state);
        }
    });

    let weak_window = window.as_weak();
    let state_for_copy_audit_path = Rc::clone(&state);
    window.on_copy_selected_audit_path(move || {
        if let Some(window) = weak_window.upgrade() {
            let mut state = state_for_copy_audit_path.borrow_mut();
            if let Err(error) = state.copy_selected_audit_path() {
                eprintln!("failed to copy selected audit path: {error:#}");
            }
            refresh_view(&window, &state);
        }
    });

    let weak_window = window.as_weak();
    let state_for_set_audit_filter_query = Rc::clone(&state);
    window.on_set_audit_filter_query(move |query| {
        if let Some(window) = weak_window.upgrade() {
            let mut state = state_for_set_audit_filter_query.borrow_mut();
            state.set_audit_filter_query(query.as_str());
            refresh_view(&window, &state);
        }
    });

    let weak_window = window.as_weak();
    let state_for_set_audit_status_filter = Rc::clone(&state);
    window.on_set_audit_status_filter(move |mode| {
        if let Some(window) = weak_window.upgrade() {
            let mut state = state_for_set_audit_status_filter.borrow_mut();
            state.set_audit_status_filter(mode);
            refresh_view(&window, &state);
        }
    });

    window.run().context("studio window exited with error")
}

fn refresh_view(window: &AppWindow, state: &AppState) {
    window.set_root_path(state.root_display().into());
    window.set_status_text(state.status_line().into());
    window.set_workflow_count(state.workflow_count() as i32);
    window.set_edge_count(state.edge_count() as i32);
    window.set_issue_count(state.issue_count() as i32);
    window.set_zoom_percent(state.zoom_percent());
    window.set_staged_edit_count(state.staged_edit_count() as i32);
    window.set_apply_armed(state.apply_armed());
    window.set_audit_count(state.audit_count() as i32);
    window.set_patch_preview(state.patch_preview_text().into());
    window.set_export_status(state.export_status_text().into());
    window.set_selected_audit_path(state.selected_audit_path_text().into());
    window.set_selected_audit_preview(state.selected_audit_preview_text().into());
    window.set_audit_filter_query(state.audit_filter_query_text().into());
    window.set_audit_status_filter_mode(state.audit_status_filter_mode());

    window.set_selected_title(state.selected_title().into());
    window.set_selected_description(state.selected_description().into());
    window.set_selected_path(state.selected_path().into());
    window.set_selected_dependency_summary(state.selected_dependency_summary().into());
    window.set_selected_issue_count(state.selected_issue_count() as i32);

    let workflows: Vec<WorkflowListItem> = state
        .workflow_list_items()
        .into_iter()
        .map(|item| WorkflowListItem {
            id: item.id.into(),
            label: item.label.into(),
            selected: item.selected,
            issue_count: item.issue_count,
            step_count: item.step_count,
        })
        .collect();
    window.set_workflows(ModelRc::new(VecModel::from(workflows)));

    let nodes: Vec<GraphNodeItem> = state
        .graph_node_items()
        .into_iter()
        .map(|node| GraphNodeItem {
            id: node.id.into(),
            label: node.label.into(),
            x: node.x,
            y: node.y,
            selected: node.selected,
        })
        .collect();
    window.set_graph_nodes(ModelRc::new(VecModel::from(nodes)));

    let steps: Vec<InspectorStepItem> = state
        .selected_steps()
        .into_iter()
        .map(|step| InspectorStepItem {
            id: step.id.into(),
            file: step.file.into(),
            status: step.status.into(),
            description: step.description.into(),
        })
        .collect();
    window.set_inspector_steps(ModelRc::new(VecModel::from(steps)));

    let issues: Vec<InspectorIssueItem> = state
        .selected_issues()
        .into_iter()
        .map(|issue| InspectorIssueItem {
            code: issue.code.into(),
            message: issue.message.into(),
        })
        .collect();
    window.set_inspector_issues(ModelRc::new(VecModel::from(issues)));

    let audits: Vec<ApplyAuditItem> = state
        .audit_items()
        .into_iter()
        .map(|audit| ApplyAuditItem {
            path: audit.path.into(),
            status: audit.status.into(),
            summary: audit.summary.into(),
            selected: audit.selected,
        })
        .collect();
    window.set_apply_audits(ModelRc::new(VecModel::from(audits)));
}

fn find_harmony_root(start: &Path) -> Option<PathBuf> {
    start.ancestors().find_map(|ancestor| {
        let manifest = ancestor.join(".harmony/orchestration/workflows/manifest.yml");
        if manifest.exists() {
            Some(ancestor.to_path_buf())
        } else {
            None
        }
    })
}
