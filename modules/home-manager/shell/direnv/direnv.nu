$env.config.hooks.pre_prompt = (
    $env.config.hooks.pre_prompt | append {||
        use std/config env-conversions
        use std/log

        if (which direnv) == [] {
            return
        }

        let conversions = env-conversions | merge $env.ENV_CONVERSIONS
        let updates = direnv export json
        log debug $"direnv: env updates: ($updates)"
        let updates = $updates | from json | default {} | transpose var value

        # A record with the same keys as `$env`, where all values are non-null.
        # This let's us do case-insensitive lookups with `get`,
        # since `in` and `has` operators can't be used with cell paths.
        let vars = $env | columns | wrap k | insert v { $in.k } | transpose -ird

        for update in $updates {
            let var = $update.var
            let value = $update.value
            let var_path = [{value: $var, optional: true, insensitive: true}] | into cell-path

            let existing_var = $vars | get $var_path
            if $existing_var != null and $existing_var != $var {
              log warning $"direnv: ignoring $env.($var), $env.($existing_var) is already set"
              # Otherwise we'd change the value of `$existing_var` instead,
              # and then when exiting the directory direnv would think that,
              # since `$var` is not set, no changes are needed.
              # Also, Nix shells usually set `$env.shell`, which conflicts with `$env.SHELL`,
              # and is very annoying.
              # https://github.com/nushell/nushell/issues/17778
              continue
            }

            if $value == null {
                # Not using `hide-env` because it's cursed.
                # The hidden variable name is still remembered, so
                # `$env.ABC = 'ABC'; hide-env ABC; $env.abc = 'abc'`
                # ends up setting `$env.ABC = 'abc'`.
                #
                # `null` values in `$env` are not exported to external commands,
                # so this should have almost the same effect as `hide-env`
                # without creating a pitfall that future direnv loads could fall into.
                load-env { $var: null }
                continue
            }

            let value_type = $value | describe
            if $value_type != "string" {
                log warning $"direnv: $env.($var): expected a string, got ($value_type), ignoring"
                continue
            }

            let conversion = $conversions | get (
                $var_path | split cell-path | append [from_string] | into cell-path
            )
            if $conversion != null {
                let converted = do $conversion $value
                load-env { $var: $converted }
            } else if ($env | get $var_path | describe) not-in [string nothing] {
                log warning $"direnv: $env.($var): current value is not a string, ignoring"
            } else {
                load-env { $var: $value }
            }
        }
    }
)
