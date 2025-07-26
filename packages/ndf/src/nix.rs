use std::{path::Path, process::Command};

use crate::{
    command,
    items::{GitRev, SourceType},
};

fn get_current_system() -> anyhow::Result<String> {
    command::run_json(
        "nix-instantiate",
        &["--eval", "--json", "--expr", "builtins.currentSystem"],
    )
}

pub(crate) fn get_current_flake_packages() -> anyhow::Result<Vec<String>> {
    let current_system = get_current_system()?;
    let package_names_fn = format!(
        "flake: builtins.attrNames ((flake.packages or {{}}).{} or {{}})",
        current_system,
    );
    command::run_json(
        "nix",
        &["eval", "--json", ".#.", "--apply", &package_names_fn],
    )
}

pub(crate) fn get_current_flake_nixos_configurations() -> anyhow::Result<Vec<String>> {
    let nixos_names_fn = "flake: builtins.attrNames (flake.nixosConfigurations or {})";
    command::run_json("nix", &["eval", "--json", ".#.", "--apply", nixos_names_fn])
}

pub(crate) fn get_file_output_attributes(file: &Path) -> anyhow::Result<Vec<String>> {
    command::output_json(
        Command::new("nix")
            .args(["eval", "--json", "--file"])
            .arg(file)
            .args([
                "--apply",
                "x: let r = if builtins.isFunction x then x {} else x; in builtins.attrNames r",
            ]),
    )
}

pub(crate) fn get_drv_paths(
    source: &SourceType,
    rev: &GitRev,
    attr_paths: &[&str],
) -> anyhow::Result<Vec<String>> {
    let result = match source {
        SourceType::FlakeCurrentDir => {
            let current_system = get_current_system()?;
            let mut cmd = Command::new("nix");
            cmd.args([
                "eval",
                "--json",
                "--apply",
                &get_flake_drv_paths_expr(attr_paths, &current_system),
            ]);
            let flake_ref = match rev {
                GitRev::Rev { rev, .. } => &format!(".?rev={}#.", rev),
                GitRev::Worktree => ".#.",
            };
            cmd.args(["--", flake_ref]);
            command::output_json(&mut cmd)?
        }
        SourceType::File(path) => {
            // Without at least one `-A` `nix-instantiate --eval` doesn't auto-call functions
            if attr_paths.is_empty() {
                vec![]
            } else {
                let mut cmd = Command::new("nix-instantiate");
                cmd.args(["--eval", "--strict", "--json"]);
                for &attr_path in attr_paths {
                    cmd.args(["--attr", &format!("{}.drvPath", attr_path)]);
                }
                match rev {
                    GitRev::Worktree => {
                        cmd.arg("--");
                        cmd.arg(path);
                    }
                    GitRev::Rev { rev, .. } => {
                        cmd.args([
                            "--expr",
                            // TODO find git repo root, import file relative to repo root
                            r#"{path, rev}: builtins.fetchGit { url = path; inherit rev; name = "source"; }"#,
                        ]);
                        cmd.args(["--arg", "path"]);
                        cmd.arg(path);
                        cmd.args(["--argstr", "rev", rev]);
                    }
                }
                command::output_json_lines(&mut cmd)?
            }
        }
    };

    assert_eq!(result.len(), attr_paths.len());
    Ok(result)
}

fn get_flake_drv_paths_expr(attr_paths: &[&str], current_system: &str) -> String {
    let mut expr = String::from("flake: [");
    let mut first = true;
    for &attr_path in attr_paths {
        if first {
            first = false;
        } else {
            expr.push(' ');
        }
        expr.push('(');
        let candidates = [
            format!("packages.{current_system}."),
            format!("legacyPackages.{current_system}."),
            String::new(),
        ]
        .into_iter()
        .map(|prefix| prefix + attr_path)
        .collect::<Vec<_>>();
        for candidate in &candidates {
            expr.push_str(&format!(
                "if flake ? {candidate} then flake.{candidate} else "
            ));
        }
        expr.push_str(&format!(
            r#"throw "flake does not provide attribute '{}', '{}' or '{}'""#,
            candidates[0], candidates[1], candidates[2],
        ));
        expr.push(')');
    }
    expr.push(']');
    expr
}
