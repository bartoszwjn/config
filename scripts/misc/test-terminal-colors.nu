#!/usr/bin/env nu

# Print a table using all the standard terminal colors
def main [] {
    let text = " Xyz "
    let base_colors = [
        [RED, red],
        [GRN, green],
        [YLW, yellow],
        [BLU, blue],
        [MAG, magenta],
        [CYA, cyan],
    ]
    let colors = (
        [[BLK, black], [DGRY, dark_gray]]
        ++ ($base_colors | zip ($base_colors | each { [$"L($in.0)", $"light_($in.1)"] }) | flatten)
        ++ [[LGRY, light_gray], [WHI, white]]
    )
    let fg_colors = [[FG, default]] | append $colors
    let bg_colors = [[BG, default]] | append $colors | each { [$in.0, $"bg_($in.1)"] }

    $env.config.table.mode = 'none'
    $env.config.table.padding = 0

    $fg_colors | each {|fg_color|
        $bg_colors | each {|bg_color|
            {
                name: $bg_color.0
                value: $"(ansi $fg_color.1)(ansi $bg_color.1)($text)(ansi reset)"
            }
        } | transpose -ird | merge {index: $fg_color.0}
    } | print
}
