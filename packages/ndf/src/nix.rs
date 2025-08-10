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
    let package_names_fn =
        format!("flake: builtins.attrNames ((flake.packages or {{}}).{current_system} or {{}})");
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
    let result: Vec<String> = match source {
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
        SourceType::File(_) => {
            todo!("get drv paths from file");
            // // Without at least one `-A` `nix-instantiate --eval` doesn't auto-call functions
            // if attr_paths.is_empty() {
            //     vec![]
            // } else {
            //     let mut cmd = Command::new("nix-instantiate");
            //     cmd.args(["--eval", "--strict", "--json"]);
            //     for &attr_path in attr_paths {
            //         cmd.args(["--attr", &format!("{}.drvPath", attr_path)]);
            //     }
            //     match rev {
            //         GitRev::Worktree => {
            //             cmd.arg("--");
            //             cmd.arg(path);
            //         }
            //         GitRev::Rev { rev, .. } => {
            //             cmd.args([
            //                 "--expr",
            //                 // TODO find git repo root, import file relative to repo root
            //                 r#"{path, rev}: builtins.fetchGit { url = path; inherit rev; name = "source"; }"#,
            //             ]);
            //             cmd.args(["--arg", "path"]);
            //             cmd.arg(path);
            //             cmd.args(["--argstr", "rev", rev]);
            //         }
            //     }
            //     command::output_json_lines(&mut cmd)?
            // }
        }
    };

    assert_eq!(result.len(), attr_paths.len());
    Ok(result)
}

fn get_flake_drv_paths_expr(attr_paths: &[&str], current_system: &str) -> String {
    intersperse_str(
        String::from("flake: ["),
        " ",
        attr_paths
            .into_iter()
            .map(|&attr_path| format!("({})", get_flake_drv_path_expr(attr_path, current_system))),
    ) + "]"
}

fn get_flake_drv_path_expr(attr_path: &str, current_system: &str) -> String {
    let mut expr = String::new();
    let candidates: &[_] = match attr_path.strip_prefix(".") {
        None => &[
            format!("packages.{current_system}.{attr_path}.drvPath"),
            format!("legacyPackages.{current_system}.{attr_path}.drvPath"),
            format!("{attr_path}.drvPath"),
        ],
        Some(path) => &[format!("{path}.drvPath")],
    };
    for candidate in candidates {
        expr.push_str(&format!(
            "if flake ? {candidate} then flake.{candidate} else "
        ));
    }
    expr.push_str(&format!(
        r#"throw "flake does not provide attribute {}""#,
        list_alternatives(
            candidates
                .into_iter()
                .map(|c| show_attr_path_in_str_literal(c))
        )
    ));
    expr
}

fn show_attr_path_in_str_literal(attr_path: &str) -> String {
    format!(
        "'{}'",
        attr_path
            .replace('\\', "\\\\")
            .replace("${", "\\${")
            .replace('"', "\\\"")
    )
}

fn intersperse_str(
    buf: String,
    sep: &str,
    items: impl IntoIterator<Item = impl AsRef<str>>,
) -> String {
    items
        .into_iter()
        .fold((buf, true), |(buf, first), item| {
            (if first { buf } else { buf + sep } + item.as_ref(), false)
        })
        .0
}

fn list_alternatives(items: impl IntoIterator<Item = impl AsRef<str>>) -> String {
    let mut items = items.into_iter().peekable();
    let mut ret = String::new();
    let mut first = true;
    while let Some(next) = items.next() {
        if first {
            first = false;
        } else if items.peek().is_some() {
            ret.push_str(", ")
        } else {
            ret.push_str(" or ")
        }
        ret.push_str(next.as_ref());
    }
    ret
}
