use std

$env.config.show_banner = false

$env.config.cursor_shape = {
    emacs: block
    vi_insert: block
    vi_normal: underscore
}

$env.config.color_config = (std config dark-theme | merge {
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
