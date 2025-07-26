use std::{
    collections::{BTreeSet, HashMap},
    process::ExitCode,
};

use anstream::{eprintln, println};
use clap::Parser as _;

use cli::{Cli, DiffProgram};
use color::{GREEN_BOLD, RED_BOLD};
use items::{GitRev, Item, ItemPair, SourceType};

mod cli;
mod color;
mod command;
mod git;
mod items;
mod nix;

fn main() -> ExitCode {
    let args = Cli::parse();
    match run(args) {
        Ok(()) => ExitCode::SUCCESS,
        Err(err) => {
            eprintln!("{RED_BOLD}error:{RED_BOLD:#} {err}");
            ExitCode::FAILURE
        }
    }
}

fn run(args: Cli) -> anyhow::Result<()> {
    let program = args.program;
    let items = ItemPair::from_args(args)?;

    for pair in &items {
        println!("{}", pair);
    }
    println!();

    let drv_paths = eval_drv_paths(&items)?;

    for (pair, (old_path, new_path)) in items.iter().zip(&drv_paths) {
        println!("{RED_BOLD}-{RED_BOLD:#} {} {}", old_path, pair.old);
        println!("{GREEN_BOLD}+{GREEN_BOLD:#} {} {}", new_path, pair.new);
        match program {
            DiffProgram::None => {}
            DiffProgram::NixDiff => {
                todo!("nix-diff diff")
            }
            DiffProgram::Nvd => todo!("nvd diff"),
        }
    }

    todo!("summary");
}

fn eval_drv_paths(items: &[ItemPair]) -> anyhow::Result<Vec<(String, String)>> {
    let eval_jobs = {
        let mut map = HashMap::<(&SourceType, &GitRev), BTreeSet<&str>>::new();
        for item in items.iter().flat_map(|pair| [&pair.old, &pair.new]) {
            map.entry((&item.source, &item.git_rev))
                .or_default()
                .insert(&item.attr_path);
        }
        map
    };

    let drv_paths = {
        let mut map = HashMap::<(&SourceType, &GitRev, &str), String>::new();
        for ((source, rev), attr_paths) in eval_jobs {
            let attr_paths = attr_paths.into_iter().collect::<Vec<_>>();
            let drv_paths = nix::get_drv_paths(source, rev, &attr_paths)?;
            for (attr_path, drv_path) in attr_paths.into_iter().zip(drv_paths) {
                map.insert((source, rev, attr_path), drv_path);
            }
        }
        map
    };

    let get_drv_path =
        |item: &Item| drv_paths[&(&item.source, &item.git_rev, item.attr_path.as_str())].clone();
    Ok(items
        .iter()
        .map(|pair| (get_drv_path(&pair.old), get_drv_path(&pair.new)))
        .collect())
}
