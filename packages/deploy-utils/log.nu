export def info [message: string]: nothing -> nothing {
    print --stderr $"[(ansi blue)INFO(ansi reset)] ($message)"
}
