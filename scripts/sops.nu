#!/usr/bin/env nu

# Run sops with $env.SOPS_AGE_KEY set by decrypting the file at $env.AGE_KEY_FILE
export def --wrapped main [
    --help (-h) # Display the help message for this command
    ...args: string # Arguments passed to sops
] {
    let age_args = [-d $env.AGE_KEY_FILE]
    print -e $"(ansi default_bold)age ($age_args | str join ' ')(ansi reset)"
    $env.SOPS_AGE_KEY = (do -c { ^age ...$age_args })

    print -e $"(ansi default_bold)sops ($args | str join ' ')(ansi reset)"
    do -c { ^sops ...$args }
}

# Run 'sops encrypt' and save the output at the given path
export def --wrapped encrypt-to [
    --help (-h) # Display the help message for this command
    output: path # File to save the output in
    ...args: string # Additional arguments passed to sops
] {
    ^sops encrypt --output $output --filename-override $output ...$args
}

alias "main encrypt-to" = encrypt-to
