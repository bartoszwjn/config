use std::{
    collections::BTreeSet,
    path::{Path, PathBuf},
    sync::LazyLock,
};

use unicode_width::UnicodeWidthStr;

use crate::{
    cli::Cli,
    color::{
        BLUE, BRIGHT_BLACK_BOLD, BRIGHT_YELLOW_BOLD, CYAN, GREEN, GREEN_BOLD, MAGENTA, RED_BOLD,
        YELLOW,
    },
    git, nix,
};

#[derive(Clone, Debug, Eq, Hash, PartialEq)]
pub(crate) struct ItemPair {
    pub(crate) old: Item,
    pub(crate) new: Item,
}

#[derive(Clone, Debug, Eq, Hash, PartialEq)]
pub(crate) struct Item {
    pub(crate) source: SourceType,
    pub(crate) attr_path: String,
    pub(crate) git_rev: GitRev,
}

#[derive(Clone, Debug, Eq, Hash, PartialEq)]
pub(crate) enum SourceType {
    FlakeCurrentDir,
    File(PathBuf),
}

#[derive(Clone, Debug, Eq, Hash, PartialEq)]
pub(crate) enum GitRef {
    Ref(String),
    Worktree,
}

#[derive(Clone, Debug, Eq, Hash, PartialEq)]
pub(crate) enum GitRev {
    Rev { orig_ref: String, rev: String },
    Worktree,
}

impl ItemPair {
    pub(crate) fn new(old: Item, new: Item) -> Self {
        Self { old, new }
    }

    pub(crate) fn from_args(args: Cli) -> anyhow::Result<Vec<Self>> {
        let old_ref = GitRef::old_from_args(args.old, &args.lhs);
        let new_ref = GitRef::new_from_args(args.new);

        let paths = if args.paths.is_empty() {
            get_default_paths(&args.file, args.nixos)?
        } else {
            args.paths
        };

        let common_lhs = match args.lhs {
            Some(lhs) => {
                let (source, attr_path) = parse_path(lhs, &args.file, args.nixos);
                let rev = old_ref.resolve(&source)?;
                Some(Item::new(source, attr_path, rev))
            }
            None => None,
        };

        let items = paths
            .into_iter()
            .map(|path| parse_path(path, &args.file, args.nixos))
            .map(|(source, attr_path)| -> anyhow::Result<_> {
                let lhs = match &common_lhs {
                    Some(lhs) => lhs.clone(),
                    None => Item::new(source.clone(), attr_path.clone(), old_ref.resolve(&source)?),
                };
                let rhs_rev = new_ref.resolve(&source)?;
                let rhs = Item::new(source, attr_path, rhs_rev);
                Ok(ItemPair::new(lhs, rhs))
            })
            .collect::<Result<_, _>>()?;

        Ok(items)
    }
}

impl Item {
    fn new(source: SourceType, attr_path: String, git_rev: GitRev) -> Self {
        Self {
            source,
            attr_path,
            git_rev,
        }
    }
}

impl GitRef {
    fn old_from_args(old: Option<String>, lhs: &Option<String>) -> Self {
        match (old, lhs) {
            (Some(old), _) => GitRef::Ref(old),
            (None, Some(_)) => GitRef::Worktree,
            (None, None) => GitRef::Ref("HEAD".to_owned()),
        }
    }

    fn new_from_args(new: Option<String>) -> Self {
        match new {
            Some(new) => GitRef::Ref(new),
            None => GitRef::Worktree,
        }
    }

    fn resolve(&self, source: &SourceType) -> anyhow::Result<GitRev> {
        match self {
            Self::Worktree => Ok(GitRev::Worktree),
            Self::Ref(git_ref) => {
                let path_in_repo = match source {
                    SourceType::FlakeCurrentDir => Path::new("."),
                    SourceType::File(path) => path.as_path(),
                };
                let rev = git::resolve_ref(git_ref, path_in_repo)?;
                let orig_ref = git_ref.clone();
                Ok(GitRev::Rev { orig_ref, rev })
            }
        }
    }
}

fn get_default_paths(file: &Option<PathBuf>, nixos: bool) -> anyhow::Result<Vec<String>> {
    Ok(match file {
        Some(file) => nix::get_file_output_attributes(file)?,
        None if nixos => nix::get_current_flake_nixos_configurations()?
            .into_iter()
            .map(|mut nixos| {
                nixos.insert_str(0, ".#");
                nixos
            })
            .collect(),
        None => nix::get_current_flake_packages()?
            .into_iter()
            .map(|mut pkg| {
                pkg.insert_str(0, ".#");
                pkg
            })
            .collect(),
    })
}

fn parse_path(path: String, file: &Option<PathBuf>, nixos: bool) -> (SourceType, String) {
    let (source, mut attr_path) = match file {
        Some(file) => (SourceType::File(file.clone()), path),
        None => {
            if !path.starts_with(".#") {
                todo!("flake outputs other than .#<attr>");
            }
            let attr_path = {
                let mut attr_path = path;
                attr_path.replace_range(..".#".len(), "");
                if nixos {
                    attr_path.insert_str(0, "nixosConfigurations.");
                }
                attr_path
            };
            (SourceType::FlakeCurrentDir, attr_path)
        }
    };
    if nixos {
        attr_path.push_str(".config.system.build.toplevel");
    };

    static ALLOWED_CHARS: LazyLock<BTreeSet<char>> = LazyLock::new(|| {
        let identifier_chars = ['a'..='z', 'A'..='Z', '0'..='9']
            .into_iter()
            .flatten()
            .chain(['_', '\'', '-']);
        identifier_chars.chain(['.']).collect::<BTreeSet<_>>()
    });
    if attr_path.contains(|c| !ALLOWED_CHARS.contains(&c)) {
        todo!("attr paths with non-identifier characters");
    }

    (source, attr_path)
}

impl std::fmt::Display for ItemPair {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{RED_BOLD}-{RED_BOLD:#} {}\n{GREEN_BOLD}+{GREEN_BOLD:#} {}",
            self.old, self.new
        )
    }
}

impl std::fmt::Display for Item {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match &self.source {
            SourceType::FlakeCurrentDir => {
                write!(f, "{BLUE}.{BLUE:#}{CYAN}#{}{CYAN:#}", self.attr_path)?
            }
            SourceType::File(path) => write!(
                f,
                "{YELLOW}({YELLOW:#}-f {BLUE}{}{BLUE:#}{YELLOW}){YELLOW:#}{CYAN}.{}{CYAN:#}",
                path.display(),
                self.attr_path
            )?,
        }
        write!(f, " {}", self.git_rev)
    }
}

impl std::fmt::Display for GitRev {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Rev { orig_ref, rev } => {
                use YELLOW as Y;
                write!(f, "{Y}({Y:#}{GREEN}{orig_ref}{GREEN:#} {rev}{Y}){Y:#}")
            }
            // NOTE: ref names cannot contain '[', see `git check-ref-format --help`.
            Self::Worktree => {
                write!(f, "{MAGENTA}[worktree]{MAGENTA:#}")
            }
        }
    }
}

pub(crate) fn diff_item_pair(pair: &ItemPair, store_paths: Option<(&str, &str)>) -> [String; 3] {
    let mut cols = vec![
        [
            format!("{RED_BOLD}-{RED_BOLD:#}"),
            match store_paths {
                None => String::new(),
                Some((l, r)) if l == r => format!("{BRIGHT_BLACK_BOLD}={BRIGHT_BLACK_BOLD:#}"),
                Some(_) => format!("{BRIGHT_YELLOW_BOLD}!{BRIGHT_YELLOW_BOLD:#}"),
            },
            format!("{GREEN_BOLD}+{GREEN_BOLD:#}"),
        ],
        [" ".to_owned(), " ".to_owned(), " ".to_owned()],
    ];
    if let Some((l, r)) = store_paths {
        cols.append(&mut diff_elems(
            [l.to_owned(), " ".to_owned()],
            [r.to_owned(), " ".to_owned()],
        ));
    }
    cols.append(&mut diff_source_types(&pair.old.source, &pair.new.source));
    cols.append(&mut diff_elems(
        [format!("{CYAN}{}{CYAN:#}", pair.old.attr_path)],
        [format!("{CYAN}{}{CYAN:#}", pair.new.attr_path)],
    ));
    cols.push([" ".to_owned(), " ".to_owned(), " ".to_owned()]);
    cols.append(&mut diff_git_revs(&pair.old.git_rev, &pair.new.git_rev));
    layout_elements(cols)
}

fn diff_source_types(old: &SourceType, new: &SourceType) -> Vec<[String; 3]> {
    diff_elems(source_type_elements(old), source_type_elements(new))
    // (-f ./foo.nix   ).attr.path
    //     .            #attr.path
    //     path:foo/bar #attr.path
}

fn diff_git_revs(old: &GitRev, new: &GitRev) -> Vec<[String; 3]> {
    match (old, new) {
        (GitRev::Worktree, GitRev::Worktree) => {
            vec![[String::new(), git_rev_worktree_element(), String::new()]]
        }
        (GitRev::Worktree, GitRev::Rev { orig_ref, rev }) => {
            vec![[
                git_rev_worktree_element(),
                "".to_owned(),
                git_rev_rev_elements(orig_ref, rev).join(""),
            ]]
        }
        (GitRev::Rev { orig_ref, rev }, GitRev::Worktree) => {
            vec![[
                git_rev_rev_elements(orig_ref, rev).join(""),
                "".to_owned(),
                git_rev_worktree_element(),
            ]]
        }
        (
            GitRev::Rev {
                orig_ref: orig_ref_old,
                rev: rev_old,
            },
            GitRev::Rev {
                orig_ref: orig_ref_new,
                rev: rev_new,
            },
        ) => diff_elems(
            git_rev_rev_elements(orig_ref_old, rev_old),
            git_rev_rev_elements(orig_ref_new, rev_new),
        ),
    }
}

fn diff_elems<const N: usize>(old: [String; N], new: [String; N]) -> Vec<[String; 3]> {
    old.into_iter()
        .zip(new)
        .map(|(elem_old, elem_new)| {
            if elem_old == elem_new {
                [String::new(), elem_old, String::new()]
            } else {
                [elem_old, String::new(), elem_new]
            }
        })
        .collect()
}

fn source_type_elements(source_type: &SourceType) -> [String; 6] {
    match source_type {
        SourceType::FlakeCurrentDir => [
            String::new(),
            String::new(),
            String::new(),
            format!("{BLUE}.{BLUE:#}"),
            String::new(),
            format!("{CYAN}#{CYAN:#}"),
        ],
        SourceType::File(path) => [
            format!("{YELLOW}({YELLOW:#}"),
            "-f".to_owned(),
            " ".to_owned(),
            format!("{BLUE}{}{BLUE:#}", path.display()),
            format!("{YELLOW}){YELLOW:#}"),
            format!("{CYAN}.{CYAN:#}"),
        ],
    }
}

fn git_rev_rev_elements(orig_ref: &str, rev: &str) -> [String; 5] {
    use GREEN as G;
    use YELLOW as Y;
    [
        format!("{Y}({Y:#}"),
        format!("{G}{orig_ref}{G:#}"),
        String::from(" "),
        rev.to_owned(),
        format!("{Y}){Y:#}"),
    ]
}

fn git_rev_worktree_element() -> String {
    format!("{MAGENTA}[worktree]{MAGENTA:#}")
}

fn layout_elements<const N: usize>(columns: impl IntoIterator<Item = [String; N]>) -> [String; N] {
    let mut lines = [const { String::new() }; N];
    for col in columns {
        for i in 0..lines.len() {
            lines[i].push_str(col[i].as_ref());
        }
        let widths = col.map(|elem| element_width(elem.as_ref()));
        let width = widths.into_iter().max().unwrap_or(0);
        for i in 0..lines.len() {
            for _ in 0..(width - widths[i]) {
                lines[i].push(' ');
            }
        }
    }
    lines
}

fn element_width(element: &str) -> usize {
    UnicodeWidthStr::width(anstream::adapter::strip_str(element).to_string().as_str())
}
