#!/usr/bin/env nu

# Builds all packages, checks and NixOS configurations of a flake
def main [
  flake_ref: string = "." # flake reference
  --no-packages # do not build packages
  --no-nixos # do not build NixOS configurations
  --no-checks # do not build checks
  --no-link # do not create symlinks to build results
  --out-link (-o): string = "result" # prefix for the build result symlinks
  --cores: int # number of cores to use in each build job (0 means all available CPU cores)
]: nothing -> nothing {
  let system = (nix eval --impure --raw --expr builtins.currentSystem)
  let flake = (nix flake show $flake_ref --json --all-systems | from json)

  let packages = if $no_packages { [] } else { get_packages $flake_ref $flake $system }
  let checks = if $no_checks { [] } else { get_checks $flake_ref $flake $system }
  let nixos_configurations = if $no_nixos { [] } else {
    get_nixos_configurations $flake_ref $flake
  }

  let nix_args = (
    ["build"] ++ $packages ++ $checks ++ $nixos_configurations
    ++ (if $no_link { ["--no-link"] } else { [] })
    ++ (if $out_link != "result" { ["--out-link" $out_link] } else { [] })
    ++ (if $cores != null { ["--cores" $cores] } else { [] })
  )
  print -e $"(ansi default_bold)nix ($nix_args | str join ' ')(ansi reset)\n"
  nix ...$nix_args
}

def get_packages [flake_ref: string, flake: record, system: string]: nothing -> list<string> {
  let packages = ($flake | get -i packages | get -i $system)
  if $packages == null {
    []
  } else {
    $packages | columns | each {|it| $"($flake_ref)#packages.($system).($it)"}
  }
}

def get_checks [flake_ref: string, flake: record, system: string]: nothing -> list<string> {
  let checks = ($flake | get -i checks | get -i $system)
  if $checks == null {
    []
  } else {
    $checks | columns | each {|it| $"($flake_ref)#checks.($system).($it)"}
  }
}

def get_nixos_configurations [flake_ref: string, flake: record]: nothing -> list<string> {
  let nixos_configurations = ($flake | get -i nixosConfigurations)
  if $nixos_configurations == null {
    []
  } else {
    $nixos_configurations | columns | each {|it|
      $"($flake_ref)#nixosConfigurations.($it).config.system.build.toplevel"
    }
  }
}
