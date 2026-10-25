use ../common.nu [run_sudo]

export def set_system_profile [path: path]: nothing -> nothing {
    run_sudo nix-env --profile /nix/var/nix/profiles/system --set $path
}

export def switch_to_configuration [
    path: path, action: string, specialisation?: string, --install-bootloader
]: nothing -> nothing {
    let systemd_run = [
        systemd-run
        -E LOCALE_ARCHIVE
        -E $"NIXOS_INSTALL_BOOTLOADER=(if $install_bootloader { '1' } else { '' })"
        --collect
        --no-ask-password
        --pipe
        --quiet
        --same-dir
        --service-type=exec
        --unit=nixos-switch-to-configuration
        --wait
    ]
    let cmd_path = [
        $path
        ...(if $specialisation != null { [specialisation $specialisation] } else { [] })
        bin/switch-to-configuration
    ] | path join

    run_sudo ...$systemd_run $cmd_path $action
}
