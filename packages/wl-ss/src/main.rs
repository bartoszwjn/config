use std::{
    error::Error,
    path::PathBuf,
    process::{Command, ExitCode},
};

use clap::{Parser, ValueEnum};

use command::{run, run_command};
use hyprland::{get_active_window_region, get_active_workspace_region};

mod command;
mod hyprland;

/// Helper script for taking screenshots in Hyprland, using grim and slurp.
#[derive(Clone, Debug, Parser)]
#[command(version)]
struct Args {
    /// Select which region of the desktop to capture.
    #[arg(short, long)]
    select: Selection,
    /// Path to save the image at (default: $HOME/screenshots/%Y-%m-%d_%H:%M:%S.%N.png).
    #[arg(short, long)]
    output: Option<PathBuf>,
}

/// Selects which region of the desktop to capture.
#[derive(Clone, Copy, Debug, ValueEnum)]
enum Selection {
    /// Select the region interactively using `grim`.
    Interactive,
    /// Select the active window.
    ActiveWindow,
    /// Select the active workspace.
    ActiveWorkspace,
    /// Select the entire desktop.
    Desktop,
}

type Result<T> = std::result::Result<T, Box<dyn Error>>;

fn main() -> ExitCode {
    match main_impl() {
        Ok(()) => ExitCode::SUCCESS,
        Err(e) => {
            eprintln!("error: {}", e);
            ExitCode::FAILURE
        }
    }
}

fn main_impl() -> Result<()> {
    let args = Args::parse();

    let region = get_region(args.select)?;

    let output_path = match args.output {
        Some(output_path) => output_path,
        // important to choose this after the user is done selecting the region
        None => get_default_output_path()?,
    };

    take_screenshot(region, output_path)?;

    Ok(())
}

#[derive(Clone, Copy, Debug)]
struct Region {
    x: i32,
    y: i32,
    width: u32,
    height: u32,
}

fn get_region(selection: Selection) -> Result<Option<Region>> {
    match selection {
        Selection::Interactive => Ok(Some(select_region_interactively()?)),
        Selection::ActiveWindow => Ok(Some(get_active_window_region()?)),
        Selection::ActiveWorkspace => Ok(Some(get_active_workspace_region()?)),
        Selection::Desktop => Ok(None),
    }
}

fn select_region_interactively() -> Result<Region> {
    let output = run("slurp", &["-d", "-f", "%x;%y;%w;%h"])?;
    let mut parts = output.split(';').fuse();
    let x = parts.next().and_then(|x| x.parse().ok());
    let y = parts.next().and_then(|y| y.parse().ok());
    let w = parts.next().and_then(|w| w.parse().ok());
    let h = parts.next().and_then(|h| h.parse().ok());
    let (((x, y), width), height) = (x.zip(y).zip(w).zip(h))
        .ok_or_else(|| format!("failed to parse the output of slurp: {:?}", output))?;
    Ok(Region {
        x,
        y,
        width,
        height,
    })
}

fn get_default_output_path() -> Result<PathBuf> {
    let home = PathBuf::from(std::env::var_os("HOME").ok_or("$HOME is not set")?);
    if !home.is_absolute() {
        return Err(format!("$HOME is not an absolute path: {:?}", home).into());
    }
    let filename = run("date", &["+%Y-%m-%d_%H:%M:%S.%N.png"])?;

    let mut output_path = home;
    output_path.push("screenshots");
    output_path.push(filename.trim());
    Ok(output_path)
}

fn take_screenshot(region: Option<Region>, output_path: PathBuf) -> Result<()> {
    let mut cmd = Command::new("grim");
    cmd.args(["-t", "png"]);
    if let Some(region) = region {
        let geometry = &format!(
            "{x},{y} {w}x{h}",
            x = region.x,
            y = region.y,
            w = region.width,
            h = region.height
        );
        cmd.args(["-g", geometry]);
    }
    cmd.arg(&output_path);
    print!("{}", run_command(&mut cmd)?);
    Ok(())
}
