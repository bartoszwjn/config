export def complete_workflow_file []: nothing -> list<path> {
    let repo_root = try { git rev-parse --show-toplevel } catch { return [] }
    let dir = $repo_root | path join .github/workflows
    ls --all $dir | each { get name | realpath --no-symlinks --relative-to . $in }
}
