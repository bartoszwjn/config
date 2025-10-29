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
    let remote_ref_pattern = get_gerrit_ref $change_number "*"
    let result = run_cmd git ls-remote --refs $remote $remote_ref_pattern
    let patchsets = (
        $result
        | lines
        | parse --regex "^[0-9a-f]{40}\trefs/changes/[0-9]{2}/[0-9]+/(?<patchset>[0-9]+)$"
    )
    if ($patchsets | is-empty) {
        error make -u { msg: $"No patchsets found for change ($change_number)" }
    }
    $patchsets | get patchset | into int | math max
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
