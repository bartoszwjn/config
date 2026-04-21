use ./log.nu
use ./utils.nu

# Copy the system closures to their respective nodes without deploying the changes.
export def main [
    ...nodes: string@"utils complete-node" # Node(s) to copy to.
    --flake: string = "." # The flake to use as a source of deploy-rs profiles.
    --quiet (-q) # Be less verbose.
    --no-substitute-on-destination (-S) # Do not try substitutes on the destination node
]: nothing -> table {
    let opts = {
        flake: $flake
        quiet: $quiet
        substitute_on_destination: (not $no_substitute_on_destination)
    }

    let profiles = (utils get-profile-info --flake $opts.flake ...$nodes)
    if not $opts.quiet {
        log info $"Copying closures for ($profiles | length) profiles:"
        $profiles | update ssh_opts { to json --raw } | print --stderr
    }

    $profiles | each {|profile| copy-closure $profile $opts } | collect
}

def copy-closure [profile: record, opts: record]: nothing -> record {
    let cmd = "nix"
    let args = [
        copy
        ...(if $opts.substitute_on_destination { [--substitute-on-destination] } else { [] })
        --to $"ssh://($profile.hostname)"
        $"($opts.flake)#deploy.nodes.($profile.node).profiles.($profile.profile).path"
    ]
    let nix_ssh_opts = ($profile.ssh_opts | str join " ")

    let command_string = $"NIX_SSH_OPTS='($nix_ssh_opts)' ($cmd) ($args | str join ' ')"
    if not $opts.quiet {
        log info $"Running (ansi default_bold)($command_string)(ansi reset)"
    }

    let exit_code = try {
        with-env {NIX_SSH_OPTS: $nix_ssh_opts} { ^$cmd ...$args }
        $env.LAST_EXIT_CODE
    } catch {
        $env.LAST_EXIT_CODE
    }
    let status = if $env.LAST_EXIT_CODE == 0 {
        $"(ansi green)success(ansi reset)"
    } else {
        $"(ansi red)error(ansi reset)"
    }
    $profile | insert status $status
}
