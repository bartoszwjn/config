use std/config

$env.config.show_banner = false

$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""
$env.PROMPT_MULTILINE_INDICATOR = "::: "
$env.config.edit_mode = "vi"
$env.config.cursor_shape = {
    emacs: block
    vi_insert: block
    vi_normal: underscore
}

$env.config.highlight_resolved_externals = true
$env.config.color_config = (config dark-theme | merge {
    nothing: light_gray
    shape_external: red
    shape_external_resolved: cyan
    shape_externalarg: green
})

$env.config.datetime_format = {
    normal: '%a %F %T%.f %Z'
    table: '%F %T%.f %z'
}

$env.config.explore = {
    status_bar_background: { fg: "#1D1F21", bg: "#C4C9C6" },
    command_bar_text: { fg: "#C4C9C6" },
    highlight: { fg: "black", bg: "yellow" },
    status: {
        error: { fg: "white", bg: "red" },
        warn: {}
        info: {}
    },
    selected_cell: { bg: light_blue },
}

$env.config.history = {
    file_format: sqlite
    max_size: 1_000_000
    isolation: false
}

$env.config.table.trim = {
    methodology: truncating
    truncating_suffix: "…"
}

$env.config.menus ++= do {
    let style = {
        text: default
        description_text: yellow
        selected_text: { attr: bu }
        match_text: { attr: u }
        selected_match_text: { attr: bu }
    }
    let completion_menu = {
        name: completion_menu
        input_mode: cursor_prefix
        marker: "| "
        type: {
            layout: columnar
            columns: 4
            col_width: 20
            col_padding: 2
        }
        style: $style
    }
    let history_menu = {
        name: history_menu
        input_mode: cursor_prefix
        marker: "^ "
        type: {
            layout: list
            page_size: 10
        }
        style: $style
    }
    let help_menu = {
        name: help_menu
        input_mode: diff
        marker: "? "
        type: {
            layout: description
            columns: 4
            col_width: 20
            col_padding: 2
            selection_rows: 4
            description_rows: 20
        }
        style: $style
    }
    [$completion_menu $history_menu $help_menu]
}

$env.config.keybindings ++= do {
    let all_modes = [emacs vi_insert vi_normal helix_insert helix_normal]
    [
        {
            name: menu_up_ctrl_k
            modifier: control
            keycode: char_k
            mode: $all_modes
            event: { send: menuup }
        }
        {
            name: menu_down_ctrl_j
            modifier: control
            keycode: char_j
            mode: $all_modes
            event: { send: menudown }
        }
        {
            name: menu_left_ctrl_h
            modifier: control
            keycode: char_h
            mode: $all_modes
            event: { send: menuleft }
        }
        {
            name: menu_right_or_clear_screen_ctrl_l
            modifier: control
            keycode: char_l
            mode: $all_modes
            event: {
                until: [
                    { send: menuright }
                    { send: clearscreen }
                ]
            }
        }
    ]
}
