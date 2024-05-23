use serde::Deserialize;

use crate::{command::run, Region, Result};

#[derive(Clone, Debug, Deserialize)]
struct ActiveWindow {
    at: (i32, i32),
    size: (u32, u32),
}

#[derive(Clone, Debug, Deserialize)]
struct ActiveWorkspace {
    #[serde(rename = "monitorID")]
    monitor_id: u32,
}

#[derive(Clone, Debug, Deserialize)]
struct Monitor {
    id: u32,
    width: u32,
    height: u32,
    x: i32,
    y: i32,
}

pub(crate) fn get_active_window_region() -> Result<Region> {
    let active_window: ActiveWindow =
        serde_json::from_str(&run("hyprctl", &["activewindow", "-j"])?)
            .map_err(|e| format!("failed to parse output of 'hyprctl activewindow -j': {}", e))?;
    Ok(Region {
        x: active_window.at.0,
        y: active_window.at.1,
        width: active_window.size.0,
        height: active_window.size.1,
    })
}

pub(crate) fn get_active_workspace_region() -> Result<Region> {
    let active_workspace: ActiveWorkspace =
        serde_json::from_str(&run("hyprctl", &["activeworkspace", "-j"])?).map_err(|e| {
            format!(
                "failed to parse output of 'hyprctl activeworkspace -j': {}",
                e
            )
        })?;
    let monitors: Vec<Monitor> = serde_json::from_str(&run("hyprctl", &["monitors", "-j"])?)
        .map_err(|e| format!("failed to parse output of 'hyprctl monitors -j': {}", e))?;
    let active_monitor = monitors
        .iter()
        .find(|monitor| monitor.id == active_workspace.monitor_id)
        .ok_or("no monitor with ID matching the monitorID of the active workspace")?;
    Ok(Region {
        x: active_monitor.x,
        y: active_monitor.y,
        width: active_monitor.width,
        height: active_monitor.height,
    })
}
