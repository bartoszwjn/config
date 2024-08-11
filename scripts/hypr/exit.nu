#!/usr/bin/env nu

# Close all windows, stop the graphical session, wait for processes to exit, then exit Hyprland
export def main [
    --dry-run # Print what commands would be executed without running them
]: nothing -> nothing {
    let clients = (get-clients)
    let pids = ($clients | get-pids)
    let actions = ($clients | get-actions)

    $actions.close | close-windows --dry-run=$dry_run
    $actions.kill | kill-processes --dry-run=$dry_run
    stop-session --dry-run=$dry_run
    $pids | wait-for-processes --dry-run=$dry_run
    stop-session-pre --dry-run=$dry_run
    exit-hyprland --dry-run=$dry_run
}

export def get-clients []: nothing -> table {
    do -c { ^hyprctl clients -j } | from json
}

export def get-pids []: table -> list<int> {
    $in | get pid | uniq
}

export def get-actions []: table -> record<close: list<string>, kill: list<int>> {
    let $clients = $in

    let actions = (
        $clients
        | merge (
            $clients
            | each { if $in.class == firefox { "kill" } else { "close" } }
            | wrap action
        )
    )

    {
        close: ($actions | where action == close | each { get address })
        kill: ($actions | where action == kill | each { get pid } | uniq)
    }
}

export def close-windows [--dry-run]: list<string> -> nothing {
    $in | each { run-cmd --dry-run=$dry_run hyprctl dispatch closewindow $"address:($in)" }
}

export def kill-processes [--dry-run]: list<int> -> nothing {
    let $pids = $in
    if ($pids | length) > 0 {
        if $dry_run {
            $"Would run kill ($pids | str join ' ')" | print -e
        } else {
            $"kill ($pids | str join ' ')" | print -e
            kill ($pids.0) ...($pids | skip 1)
        }
    }
}

export def stop-session [--dry-run]: nothing -> nothing {
    run-cmd --dry-run=$dry_run systemctl "--user" stop hyprland-session.target
}

export def wait-for-processes [--dry-run]: list<int> -> nothing {
    run-cmd --dry-run=$dry_run waitpid "--exited" ...($in)
}

export def stop-session-pre [--dry-run]: nothing -> nothing {
    run-cmd --dry-run=$dry_run systemctl "--user" stop graphical-session-pre.target
}

export def exit-hyprland [--dry-run]: nothing -> nothing {
    run-cmd --dry-run=$dry_run hyprctl dispatch exit
}

export def run-cmd [$cmd: string, ...$args: string, --dry-run]: any -> any {
    if $dry_run {
        $"Would run ($cmd) ($args | str join ' ')" | print -e
    } else {
        $"($cmd) ($args | str join ' ')" | print -e
        do -c { ^$cmd ...$args }
    }
}