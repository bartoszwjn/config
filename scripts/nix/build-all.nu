#!/usr/bin/env nu

use ../common.nu run_cmd

# Builds all packages, checks and NixOS configurations of a flake
export def main [
    flake_ref: string = "." # flake reference
    --no-packages # do not build packages
    --no-nixos # do not build NixOS configurations
    --no-checks # do not build checks
    --no-link # do not create symlinks to build results
    --out-link (-o): string # prefix for the build result symlinks
    --cores: int # number of cores to use in each build job (0 means all available CPU cores)
    --no-nom # Use `nix build` directly instead of using `nom`
]: nothing -> nothing {
    let system = nix eval --impure --raw --expr builtins.currentSystem

    let flake_json = nix eval --json $"($flake_ref)#." --apply 'flake: {
        packages = builtins.mapAttrs (_: builtins.attrNames) (flake.packages or { });
        checks = builtins.mapAttrs (_: builtins.attrNames) (flake.checks or { });
        nixosConfigurations = builtins.attrNames (flake.nixosConfigurations or { });
    }'
    let flake = $flake_json | from json

    let packages = if $no_packages { [] } else {
        $flake.packages | get -o $system | default [] | each {
            $"($flake_ref)#packages.($system).($in)"
        }
    }
    let checks = if $no_checks { [] } else {
        $flake.checks | get -o $system | default [] | each {
            $"($flake_ref)#checks.($system).($in)"
        }
    }
    let nixos = if $no_nixos { [] } else {
        $flake.nixosConfigurations | each {
            $"($flake_ref)#nixosConfigurations.($in).config.system.build.toplevel"
        }
    }

    run_cmd (if $no_nom { "nix" } else { "nom" }) ...[
        "build"
        ...$packages
        ...$checks
        ...$nixos
        ...(if $no_link { ["--no-link"] } else { [] })
        ...(if $out_link != null { ["--out-link" $out_link] } else { [] })
        ...(if $cores != null { ["--cores" $cores] } else { [] })
    ]
}
