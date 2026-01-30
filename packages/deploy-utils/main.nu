#!/usr/bin/env nu

use ./copy.nu
use ./status.nu

# Helper scripts for working with deploy-rs.
def main []: nothing -> nothing {
    help main
}

# Copy the system closures to their respective nodes without deploying the changes.
def "main copy" [
    ...nodes: string # Node(s) to copy to.
    --flake: string = "." # The flake to use as a source of deploy-rs profiles.
    --quiet (-q) # Be less verbose.
    --no-substitute-on-destination (-S) # Do not try substitutes on the destination node
]: nothing -> nothing {
    $env.config.table.mode = "none"
    (
        copy ...$nodes
            --flake $flake
            --quiet=$quiet
            --no-substitute-on-destination=$no_substitute_on_destination
        | select node profile status
        | print
    )
}


# Check if deployed NixOS configurations are up to date with the local config.
def "main status" [
    ...nodes: string # Check profiles from the given node(s) only.
    --flake: string = "." # The flake to use as a source of deploy-rs profiles.
    --eval-threads: int # The number of threads to use for Nix evaluation.
    --single-eval # Evaluate all store paths with a single invocation of Nix.
    --quiet (-q) # Be less verbose.
    --show-paths # Include profile store paths in the output.
]: nothing -> nothing {
    $env.config.table.mode = "none"
    (
        status ...$nodes
            --flake $flake
            --eval-threads $eval_threads
            --single-eval=$single_eval
            --quiet=$quiet
        | select status node profile context
            ...(if $show_paths { [deployed_path local_path] } else { [] })
        | print
    )
}
