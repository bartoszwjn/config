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

        for update in $updates {
            let var = $update.var
            let value = $update.value

            if $value == null {
                hide-env $var
                continue
            }

            let value_type = $value | describe
            if $value_type != "string" {
                log warning $"direnv: $env.($var): expected a string, got ($value_type), ignoring"
                continue
            }

            let conversion = $conversions | get (
                [{value: $var, optional: true, insensitive: true} from_string] | into cell-path
            )
            if $conversion != null {
                let converted = do $conversion $value
                load-env { $var: $converted }
            } else if (
                ($env | get (
                    [{value: $var, optional: true, insensitive: true}] | into cell-path
                ) | describe) not-in [string nothing]
            ) {
                log warning $"direnv: $env.($var): current value is not a string, ignoring"
            } else {
                load-env { $var: $value }
            }
        }
    }
)
