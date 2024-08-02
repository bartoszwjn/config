#!/usr/bin/env nu

const profile_path = "/nix/var/nix/profiles/system"
const spec_path = ($profile_path | path join "specialisation")

# Switch to a specialisation of the system configuration
export def main [
    specialisation: string@specialisations # Name of the specialisation to activate
] {
    switch ($spec_path | path join $specialisation "bin" "switch-to-configuration")
}

# Switch to the default, unspecialized system configuration
export def "main default" [] {
    switch ($profile_path | path join "bin" "switch-to-configuration")
}

def switch [cmd: path] {
    let sudo_args = [$cmd test]
    print -e $"(ansi default_bold)sudo ($sudo_args | str join ' ')(ansi reset)"
    do -c { ^sudo ...$sudo_args }
}

def specialisations []: nothing -> list<string> {
    if ($spec_path | path type) == dir {
        ls --short-names $spec_path | get name
    } else {
        []
    }
}
