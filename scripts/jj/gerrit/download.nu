#!/usr/bin/env nu

use std assert
use std log

# Download a change from Gerrit into a local branch
def main [
    change_number: int
    patchset_number?: int
    --remote: string = origin # The remote to fetch from
    --no-move # Do not move to the downloaded change
    --edit (-e) # Edit the downloaded change instead of creating a new change based on it
]: nothing -> nothing {
    assert greater or equal $change_number 10 "Change number must be 10 or greater"
    if $patchset_number != null {
        assert greater or equal $patchset_number 1 "Patchset number must be a positive number"
    }

    let bookmark = match $patchset_number {
        null => { $"changes/($change_number)" }
        _ => { $"changes/($change_number)-($patchset_number)" }
    }

    let patchset_number = match $patchset_number {
        null => { get_newest_patchset_number $remote $change_number }
        $number => { $number }
    }

    let remote_ref = get_gerrit_ref $change_number $patchset_number
    let local_ref = $"refs/heads/($bookmark)"
    run_cmd git fetch $remote $"($remote_ref):($local_ref)"

    let bookmark_revset = $"bookmarks\(exact:($bookmark)\)"
    if $no_move {
        run_cmd jj log -r ("ancestors(remote_bookmarks().." + $bookmark_revset + ", 2)")
    } else {
        if $edit {
            run_cmd jj edit $bookmark_revset
        } else {
            run_cmd jj new $bookmark_revset
        }
    }
}

def get_newest_patchset_number [remote: string, change_number: int]: nothing -> int {
    let parsed_url = parse_gerrit_remote_url (git remote get-url $remote)

    match $parsed_url.scheme {
        "ssh" => { get_newest_patchset_over_ssh $parsed_url $change_number }
        "http" | "https" => { get_newest_patchset_over_http $parsed_url $change_number }
        $other => { error make -u { msg: $"Unsupported URL scheme for Gerrit remote: ($other)" } }
    }
}

def parse_gerrit_remote_url [
    remote_url: string
]: nothing -> record<scheme: string, username: string, host: string, port: string, project: string> {
    # Based on the implemenation of `git-review -d`
    # https://opendev.org/opendev/git-review/src/commit/45c94b63fbe0653d187c8afc1d316b9d3ac45176/git_review/cmd.py#L655

    let parsed = if ($remote_url | str contains "://") {
        $remote_url | url parse | select scheme username host port path
    } else {
        # scp-style address: [user@]host:[path]
        # https://opendev.org/opendev/git-review/src/commit/45c94b63fbe0653d187c8afc1d316b9d3ac45176/git_review/cmd.py#L610
        let parts = $remote_url | parse -r "^(?:(?<username>[^@:]*)@)?(?<host>[^:]*):(?<path>.+)?$"
        if ($parts | is-empty) {
            error make -u { msg: $"Invalid remote URL: ($remote_url)" }
        }
        $parts | get 0 | merge { scheme: "ssh", port: "22" }
    }

    # XXX: git-review supports http remotes where the Gerrit "root" can have a non-empty path
    let project = $parsed.path | str replace --all --regex '^/|\.git$' ''
    $parsed | reject path | insert project $project
}

def get_newest_patchset_over_ssh [ parsed_url: record, change_number: int ]: nothing -> int {
    assert false "not implemented yet"
}

def get_newest_patchset_over_http [ parsed_url: record, change_number: int ]: nothing -> int {
    assert false "not implemented yet"
}

def get_gerrit_ref [change_number: int, patchset_number: oneof<int, string>]: nothing -> string {
    assert greater or equal $change_number 10
    let last_2_digits = $change_number | into string | str substring (-2)..
    $"refs/changes/($last_2_digits)/($change_number)/($patchset_number)"
}

def --wrapped run_cmd [cmd: string, ...args: string]: any -> any {
    let input = $in
    [$cmd ...$args] | str join " " | $"(ansi default_bold)($in)(ansi reset)" | print -e
    $input | run-external $cmd ...$args
}
