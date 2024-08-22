#!/usr/bin/env nu

# Close all windows, stop the graphical session, wait for processes to exit, then exit Hyprland
def main [
    --dry-run # Print what commands would be executed without running them
    --systemd-service # Run directly instead of through systemd-run
]: nothing -> nothing {
    if not $systemd_service {
        let systemd_args = [
            --user
            --unit=hypr-exit
            --service-type=exec
            --same-dir
            --setenv=PATH
            --setenv=HYPRLAND_INSTANCE_SIGNATURE
        ]
        let self_args = [--systemd-service] ++ (if $dry_run { [--dry-run] } else { [] })
        exec systemd-run ...$systemd_args $env.CURRENT_FILE ...$self_args
    }

    let clients = (get-clients)
    let pids = ($clients | get-pids)
    let actions = ($clients | get-actions)

    $actions.close | close-windows --dry-run=$dry_run
    $actions.kill | kill-processes --dry-run=$dry_run
    $pids | wait-for-processes --dry-run=$dry_run
    stop-session --dry-run=$dry_run
    stop-session-pre --dry-run=$dry_run
    exit-hyprland --dry-run=$dry_run
}

def get-clients []: nothing -> table {
    do -c { ^hyprctl clients -j } | from json
}

def get-pids []: table -> list<int> {
    (
        get pid
        | uniq
        # only wait for processes that are not part of a systemd unit
        | filter {|pid| (^systemctl --user whoami $pid | complete | get exit_code) != 0 }
    )
}

def get-actions []: table -> record<close: list<string>, kill: list<int>> {
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

def close-windows [--dry-run]: list<string> -> nothing {
    $in | each { run-cmd --dry-run=$dry_run hyprctl dispatch closewindow $"address:($in)" }
}

def kill-processes [--dry-run]: list<int> -> nothing {
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

def wait-for-processes [--dry-run]: list<int> -> nothing {
    run-cmd --dry-run=$dry_run waitpid "--exited" ...($in)
}

def stop-session [--dry-run]: nothing -> nothing {
    run-cmd --dry-run=$dry_run systemctl "--user" stop graphical-session.target
}

def stop-session-pre [--dry-run]: nothing -> nothing {
    run-cmd --dry-run=$dry_run systemctl "--user" stop graphical-session-pre.target
}

def exit-hyprland [--dry-run]: nothing -> nothing {
    run-cmd --dry-run=$dry_run hyprctl dispatch exit
}

def run-cmd [$cmd: string, ...$args: string, --dry-run]: any -> any {
    if $dry_run {
        $"Would run ($cmd) ($args | str join ' ')" | print -e
    } else {
        $"($cmd) ($args | str join ' ')" | print -e
        do -c { ^$cmd ...$args }
    }
}
