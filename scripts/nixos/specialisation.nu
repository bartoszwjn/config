#!/usr/bin/env nu

use ./common.nu switch_to_configuration

# Switch to a specialisation of the system configuration
#
# If no specialisation name is given, switch to the default, unspecialised configuration.
export def main [
    specialisation?: string # Name of the specialisation to activate
] {
    switch_to_configuration /nix/var/nix/profiles/system test $specialisation
}
