module sd {
    def complete [context: string] {
        let last_char_is_whitespace = ($context | split chars | last | str trim) == ''
        let args = $context | split words | skip 1
        let args = if $last_char_is_whitespace {
            $args
        } else {
            $args | take (($args | length) - 1)
        }

        if "CONFIG_REPO_ROOT" not-in $env {
            return []
        }
        let root = $env.CONFIG_REPO_ROOT | path join scripts

        let dir = $args | reduce --fold $root {|part, dir|
            if ($dir | path type) == dir {
                $dir | path join $part
            } else {
                $dir
            }
        }

        if ($dir | path type) == dir {
            ls --all --short-names $dir | each {
                let item = $in
                let description = if $item.type == file and ($item.name | str ends-with .nu) {
                    let help = try {
                        run-external ($dir | path join $item.name) "--help"
                    } catch {
                        null
                    }
                    $help | default "" | lines | get 0? | default $item.type
                } else {
                    $item.type
                }
                { value: ($item.name + " "), description: $description }
            }
        } else {
            []
        }
    }

    # Run a script from the scripts directory.
    export def --wrapped main [
        ...args: string@complete # Path components pointing to the script, then script arguments
    ] {
        let root = $env.CONFIG_REPO_ROOT | path join scripts
        let cmd = $args | reduce --fold { path: $root, args: [] } {|arg, acc|
            match ($acc.path | path type) {
                dir => {
                    { path: ($acc.path | path join $arg), args: $acc.args }
                }
                file => {
                    { path: $acc.path, args: ($acc.args ++ [$arg]) }
                }
                null => {
                    error make -u { msg: $"($acc.path) does not exist" }
                }
                $other => {
                    error make -u { msg: $"($acc.path) has unexpected type: ($other)" }
                }
            }
        }

        match ($cmd.path | path type) {
            file => {
                run-external $cmd.path ...$cmd.args
            }
            dir => {
                error make -u { msg: $"not enough arguments, ($cmd.path) is a directory" }
            }
            null => {
                error make -u { msg: $"($cmd.path) does not exist" }
            }
            $other => {
                error make -u { msg: $"($cmd.path) has unexpected type: ($other)" }
            }
        }
    }
}

use sd
