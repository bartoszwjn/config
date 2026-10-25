module sd {
    def complete [place: record] {
        let previous_args = $place.command | skip 1 | take (($in | length) - 1)

        if "CONFIG_REPO_ROOT" not-in $env {
            return []
        }
        let root = $env.CONFIG_REPO_ROOT | path join scripts

        let dir = $previous_args | reduce --fold $root {|part, dir|
            if ($dir | path type) == dir {
                $dir | path join $part
            } else {
                $dir
            }
        }

        if ($dir | path type) == dir {
            ls --all --short-names $dir | each {
                let item = $in
                let opts = match $item.type {
                    file if ($item.name | str ends-with .nu) => {
                        let help = try {
                            run-external ($dir | path join $item.name) "--help"
                        } catch { null }
                        let help = $help | default "" | lines | get 0?
                        let style = if $help != null { "green_bold" } else { null }
                        { description: $help, style: $style }
                    }
                    dir => { { style: blue_bold } }
                    _ => { { description: $item.type } }
                }
                $opts | merge { value: ($item.name + " "), display_override: $item.name }
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
