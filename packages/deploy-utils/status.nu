use ./log.nu
use ./utils.nu

# Check if deployed NixOS configurations are up to date with the local config.
export def main [
    ...nodes: string@"utils complete-node" # Check profiles from the given node(s) only.
    --flake: string = "." # The flake to use as a source of deploy-rs profiles.
    --eval-threads: int # The number of threads to use for Nix evaluation.
    --single-eval # Evaluate all store paths with a single invocation of Nix.
    --quiet (-q) # Be less verbose.
]: nothing -> table {
    let profiles = (utils get-profile-info --flake $flake ...$nodes)
    if not $quiet {
        log info $"Found ($profiles | length) defined profiles:"
        $profiles | update ssh_opts { to json --raw } | print --stderr
    }

    if not $quiet {
        log info "Checking deployed profile paths"
    }
    let queried = (
        # This is bottlenecked by network latency, make a thread for each element to start every
        # connection immediately
        $profiles | par-each --keep-order --threads ($profiles | length) { query-profile }
    )

    if not $quiet {
        log info "Evaluating local profile paths"
    }
    let evaled = match [$single_eval, $eval_threads] {
        [true, _] => {
            $queried | eval-all-profiles $flake
        }
        [false, null] => {
            # This is bottlenecked by CPU/memory, use the default thread pool
            $queried | par-each --keep-order { eval-profile $flake }
        }
        [false, _] => {
            $queried | par-each --keep-order --threads $eval_threads { eval-profile $flake }
        }
    }

    $evaled | each { compare-profile }
}

def query-profile []: record -> record {
    let profile = $in
    let check_profile = '
        if [ -L "$1" ]; then
            printf "valid;%s" "$(realpath "$1")"
        elif [ -e "$1" ]; then
            printf "invalid;"
        else
            printf "missing;"
        fi
    '
    let result = (
        $check_profile
        | ^ssh -T
            -o "ConnectTimeout=3" -o $"User=($profile.ssh_user)"
            $profile.hostname -- bash -s $profile.profile_path
        | complete
    )

    let result_parsed = match $result {
        { exit_code: 0, stdout: $out } => {
            let status = ($out | str replace --regex ";.*" "")
            let $deployed_path = match $status {
                "valid" => { $out | str replace "valid;" "" }
                _ => { null }
            }
            { status: $status, deployed_path: $deployed_path, context: null }
        }
        { exit_code: 1.., stderr: $context } => {
            { status: "unknown", deployed_path: null, context: ($context | str trim) }
        }
    }
    $profile | merge $result_parsed
}

def eval-profile [flake: string]: record -> record {
    let profile = $in
    let flake_ref = (
        $"($flake)#deploy.nodes.($profile.node).profiles.($profile.profile).path.outPath"
    )
    # `--no-eval-cache` to avoid a spam of "SQLite database is busy" errors, which happens when
    # running multiple instances of nix in parallel. It even seems to make it slightly faster.
    # `complete` to avoid a spam of "warning: Git tree is dirty" for each `nix eval`.
    let local_path = (
        do -c { ^nix eval $flake_ref --json --no-eval-cache }
        | complete | get stdout
        | from json
    )
    $profile | insert local_path $local_path
}

def eval-all-profiles [flake: string]: list<record> -> list<record> {
    let profiles = $in
    let flake_ref = $"($flake)#deploy"
    let profile_exprs = (
        $profiles
        | each {|profile| $"deploy.nodes.($profile.node).profiles.($profile.profile).path.outPath" }
        | str join " "
    )
    let expr = $"deploy: [($profile_exprs)]"
    let local_paths = (
        do -c { ^nix eval $flake_ref --apply $expr --json }
        | from json
    )
    $profiles | merge ($local_paths | wrap local_path)
}

def compare-profile []: record -> record {
    let profile = $in
    let status = match $profile.status {
        "valid" => {
            if $profile.deployed_path == $profile.local_path {
                "up-to-date"
            } else {
                "outdated"
            }
        }
        $other => { $other }
    }
    $profile | update status ($status | display-status)
}

def display-status []: string -> string {
    match $in {
        "up-to-date" => { $"(ansi green)up-to-date(ansi reset)" },
        "outdated" => { $"(ansi yellow)outdated(ansi reset)" },
        "invalid" => { $"(ansi red)invalid(ansi reset)" },
        "missing" => { $"(ansi yellow)missing(ansi reset)" },
        "unknown" => { $"(ansi dark_gray)unknown(ansi reset)" },
        _ => { $in },
    }
}
