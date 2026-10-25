#!/usr/bin/env nu

use ../common.nu run_cmd
use ./build.nu
use ./common.nu [set_system_profile, switch_to_configuration]

# Check if the currently active NixOS configuration is up to date.
export def main [] {
    let flake = $env.CONFIG_REPO_ROOT
    let host = sys host | get hostname
    let expected = run_cmd "nix" ...[
        "eval"
        "--raw"
        $"git+file://($flake)#nixosConfigurations.($host).config.system.build.toplevel.outPath"
    ]

    let current_system = run_cmd realpath /run/current-system
    let current_profile = run_cmd realpath /nix/var/nix/profiles/system

    let status = match [($expected == $current_system), ($expected == $current_profile)] {
        [true, true] => { $"(ansi green)up to date(ansi reset)" },
        [true, false] => { $"(ansi yellow)up to date \(current boot only\)(ansi reset)" },
        [false, true] => { $"(ansi yellow)needs reboot(ansi reset)" },
        [false, false] => { $"(ansi red)outdated(ansi reset)" },
        _ => { error make -u "unreachable" },
    }

    print $"(ansi blue)($host)(ansi reset) ($status)"
}
