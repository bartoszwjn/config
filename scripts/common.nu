# Run an external command, printing the command and arguments to stderr
export def --wrapped run_cmd [cmd: string, ...args: string, --dry-run]: nothing -> any {
    let display = [$cmd ...$args] | str join " " | $"(ansi default_bold)($in)(ansi reset)"
    if $dry_run {
        print --stderr $"Would run ($display)"
        null
    } else {
        print --stderr $display
        run-external $cmd ...$args
    }
}

# Run an external command with `sudo`, printing the command and arguments to stderr
export def --wrapped run_sudo [...args: string, --dry-run]: nothing -> any {
    run_cmd --dry-run=$dry_run sudo ...$args
}
