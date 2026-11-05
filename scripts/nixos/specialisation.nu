#!/usr/bin/env nu

use ./common.nu switch_to_configuration

# Switch to a specialisation of the system configuration
#
# If no specialisation name is given, switch to the default, unspecialised configuration.
export def main [
    specialisation?: string@list_specialisations # Name of the specialisation to activate
] {
    switch_to_configuration /nix/var/nix/profiles/system test $specialisation
}

def list_specialisations []: nothing -> list<string> {
    let dir = "/nix/var/nix/profiles/system/specialisation"
    if ($dir | path exists) {
        ls --short-names --all $dir | each { get name }
    } else {
        []
    }
}
