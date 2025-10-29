#!/usr/bin/env nu

# Initialize jj in a Git repo with Gerrit-specific configuration
def main []: nothing -> nothing {
    let repo_root = git rev-parse --show-toplevel
    if $env.PWD != $repo_root {
        print_cmd cd $repo_root
        cd $repo_root
    }

    let git_review_config = open .gitreview | from ini
    let default_branch = $git_review_config.gerrit.defaultbranch
    let default_remote = $git_review_config.gerrit.defaultremote
    let untracked_files = git ls-files --other --exclude-standard
    let untracked_files = $untracked_files | lines

    run_cmd jj git init
    run_cmd jj bookmark track $"($default_branch)@($default_remote)"
    run_cmd jj config set --repo templates.commit_trailers (
        'if(!trailers.contains_key("Change-Id"), format_gerrit_change_id_trailer(self))'
    )
    run_cmd jj config set --repo gerrit.default-remote-branch $default_branch

    if $untracked_files != [] {
        warn (
            "Consider setting snapshot.auto-track to ignore files that were untracked before:\n"
            + ($untracked_files | each { $"  ($in)\n" } | str join)
            + "Approximate command:\n"
            + "jj config set --repo snapshot.auto-track '"
            + ($untracked_files | each { $"root-file:($in)" } | prepend ["all()"] | str join " ~ ")
            + "'"
        )
    }
}

def --wrapped run_cmd [cmd: string, ...args: string]: any -> any {
    let input = $in
    print_cmd $cmd ...$args
    $input | run-external $cmd ...$args
}

def print_cmd [cmd: string, ...args: string]: nothing -> nothing {
    [$cmd ...$args] | str join " " | $"(ansi default_bold)($in)(ansi reset)" | print -e
}

def warn [msg: string]: nothing -> nothing {
    $"(ansi yellow_bold)warning:(ansi reset) ($msg)" | print -e
}
