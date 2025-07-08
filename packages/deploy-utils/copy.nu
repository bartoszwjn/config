use ./log.nu
use ./utils.nu

# Copy the system closures to their respective nodes without deploying the changes.
export def main [
    ...nodes: string@"utils complete-node" # Node(s) to copy to.
    --flake: string = "." # The flake to use as a source of deploy-rs profiles.
    --quiet (-q) # Be less verbose.
]: nothing -> table {
    let profiles = (utils get-profile-info --flake $flake ...$nodes)
    if not $quiet {
        log info $"Copying closures for ($profiles | length) profiles:"
        $profiles | update ssh_opts { to json --raw } | print --stderr
    }

    $profiles | each { copy-closure --flake $flake --quiet=$quiet }
}

def copy-closure [--flake: string, --quiet]: record -> record {
    let profile = $in
    let cmd = "nix"
    let args = [
        copy
        --substitute-on-destination
        --to $"ssh://($profile.hostname)"
        $"($flake)#deploy.nodes.($profile.node).profiles.($profile.profile).path"
    ]
    let nix_ssh_opts = ($profile.ssh_opts | str join " ")

    let command_string = $"NIX_SSH_OPTS='($nix_ssh_opts)' ($cmd) ($args | str join ' ')"
    if not $quiet {
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
