use std/config

$env.config.show_banner = false

$env.config.cursor_shape = {
    emacs: block
    vi_insert: block
    vi_normal: underscore
}

$env.config.color_config = (config dark-theme | merge {
    nothing: light_gray
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
        only_buffer_difference: false
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
        only_buffer_difference: true
        marker: "? "
        type: {
            layout: list
            page_size: 10
        }
        style: $style
    }
    let help_menu = {
        name: help_menu
        only_buffer_difference: true
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
