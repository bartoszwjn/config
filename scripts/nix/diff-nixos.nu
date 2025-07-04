#!/usr/bin/env nu

use std/assert
use std/iter

# Compare NixOS configurations across revisions of a flake
#
# --left defaults to 'HEAD', if --left-host is not given, and to the current worktree otherwise.
# --right defaults to the current worktree.
def main [
    ...hosts: string # Name of the attribute(s) in `nixosConfigurations` to compare
    --left (-l): string # Commit on the left side of the comparison
    --right (-r): string # Commit on the right side of the comparison
    --left-host: string # Compare all other hosts to this one.
    --program (-p): string = "nix-diff" # Program used for diffing ('nix-diff', 'nvd' or 'none')
    --eval-threads: int # Number of threads to use for Nix evaluation
] {
    let left = match [$left $left_host] {
        [null null] => { "HEAD" },
        [null _] => { null },
        [_ _] => { $left },
    }
    let program = match $program {
        "nix-diff" | "nvd" | "none" => { $program },
        _ => {
            error make {
                msg: $"Unsupported value for parameter --program: ($program)"
                label: {
                    text: "Expected one of: 'nix-diff', 'nvd', 'none'"
                    span: (metadata $program).span
                }
            }
        }
    }

    let left_rev = get-rev $left
    let right_rev = get-rev $right

    let hosts = get-hosts $hosts $left_rev $right_rev
    let host_pairs = $hosts | each {|right_host| {
        left_host: (match $left_host { null => { $right_host }, _ => { $left_host } })
        right_host: $right_host
    } }

    do {
        $env.config.table.mode = 'none'
        print (
            { left_ref: $left, left_rev: $left_rev, right_ref: $right, right_rev: $right_rev }
            | merge (if $left_host != null { { left_host: $left_host } } else { {} })
            | insert hosts ($hosts | to nuon)
        )
    }

    let hosts_info = get-hosts-info $host_pairs $left_rev $right_rev $eval_threads $program
    let host_pairs = $host_pairs | each {|host_pair|
        get-host-pair-status $host_pair $hosts_info $left_rev $right_rev
    }

    for host_pair in $host_pairs {
        diff-host-pair $host_pair.left_path $host_pair.right_path $program
    }

    do {
        $env.config.table.mode = 'none'
        print $host_pairs
    }
}

def get-rev [ref?: string]: nothing -> any {
    let effective_ref = match $ref {
        null => {
            let status = (^git diff-index --quiet HEAD | complete)
            match $status.exit_code {
                0 => { "HEAD" },
                1 => { null },
                _ => {
                    error make --unspanned {
                        msg: $"git diff-index exited with an error:\n($status.stderr)"
                    }
                },
            }
        },
        _ => { $ref },
    }
    match $effective_ref {
        null => { null },
        _ => { ^git rev-parse $effective_ref },
    }
}

def get-hosts [hosts: list<string>, left_rev?: string, right_rev?: string]: nothing -> list<string> {
    match $hosts {
        [] => {
            get-rev-hosts $left_rev | append (get-rev-hosts $right_rev) | uniq | sort --natural
        }
        _ => { $hosts },
    }
}

def get-rev-hosts [rev?: string]: nothing -> list<string> {
    let rev = match $rev { null => { "" }, _ => { $"?rev=($rev)" } }
    (
        do -c { ^nix eval $".($rev)#nixosConfigurations" --apply "builtins.attrNames" --json }
        | from json
    )
}

def get-hosts-info [
    host_pairs: table<left_host: string, right_host: string>
    left_rev: any
    right_rev: any
    eval_threads: any
    program: string
]: nothing -> table<rev: any, host: string, path: any> {
    let hosts_uniq = (
        $host_pairs
        | iter flat-map {|pair| [
            {rev: $left_rev, host: $pair.left_host}
            {rev: $right_rev, host: $pair.right_host}
        ] }
        | uniq
    )

    # par-each discards nulls, so return records with a nullable drv_path
    let add_drv_path = {|job| $job | insert drv_path (get-host-drv-path $job.host $job.rev) }
    let host_drv_paths = match $eval_threads {
        null => {
            $hosts_uniq | par-each $add_drv_path --keep-order | get drv_path
        }
        _ => {
            $hosts_uniq | par-each $add_drv_path --keep-order --threads $eval_threads | get drv_path
        }
    }

    let host_paths = match $program {
        "nix-diff" | "none" => { $host_drv_paths },
        "nvd" => { build-host-drvs $host_drv_paths },
    }
    $hosts_uniq | merge ($host_paths | wrap path)
}

def get-host-drv-path [host: string, rev?: string]: nothing -> any {
    let rev = match $rev { null => { "" }, _ => { $"?rev=($rev)" } }
    let attr = $"nixosConfigurations.($host).config.system.build.toplevel"
    let f = $'cfgs: let
        host = cfgs.($host) or null;
    in
        if host == null
        then null
        else host.config.system.build.toplevel.drvPath
    '
    (
        do -c { ^nix eval $".($rev)#nixosConfigurations" --apply $f --json --no-eval-cache }
        | complete | get stdout # ignore stderr
        | from json
    )
}

def build-host-drvs [drv_paths: list<any>]: nothing -> list<any> {
    let installables = $drv_paths | where { $in != null } | uniq | each { $"($in)^out" }
    let build_results = do -c { ^nix build --no-link --json -- ...$installables } | from json
    assert equal ($installables | length) ($build_results | length)

    let out_paths = (
        $drv_paths
        | wrap drvPath
        | join --left $build_results drvPath
        | get outputs
        | each --keep-empty {
            match $in {
                null => { null },
                $outputs => { $outputs.out },
            }
        }
    )
    assert equal ($drv_paths | length) ($out_paths | length)

    $out_paths
}

def get-host-pair-status [
    host_pair: record<left_host: string, right_host: string>
    hosts_info: table<rev: any, host: string, path: any>
    left_rev: any
    right_rev: any
]: [
    nothing -> record<
        status: string, left_host: string, right_host: string, left_path: any, right_path: any
    >
] {
    let find_host_path = {|rev, host|
        $hosts_info | iter find {|i| $i.rev == $rev and $i.host == $host } | get path
    }
    let $left_path = do $find_host_path $left_rev $host_pair.left_host
    let $right_path = do $find_host_path $right_rev $host_pair.right_host

    let status = match [$left_path $right_path] {
        [null null] => { $"(ansi red)missing(ansi reset)" },
        [null _] => { $"(ansi yellow)right only(ansi reset)" },
        [_ null] => { $"(ansi yellow)left only(ansi reset)" },
        [_ _] if $left_path == $right_path => { $"(ansi green)equal(ansi reset)" },
        _ => { $"(ansi yellow)different(ansi reset)" },
    }

    {
        status: $status,
        left_host: $host_pair.left_host,
        right_host: $host_pair.right_host,
        left_path: $left_path,
        right_path: $right_path,
    }
}

def diff-host-pair [left_path: any, right_path: any, program: string]: nothing -> nothing {
    if $left_path != null and $right_path != null and $left_path != $right_path {
        match $program {
            "nix-diff" => {
                do -c { ^nix-diff --character-oriented $left_path $right_path }
            }
            "nvd" => {
                do -c { ^nvd diff $left_path $right_path }
            }
            "none" => {}
        }
    }
}
