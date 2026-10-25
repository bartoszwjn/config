#!/usr/bin/env nu

# Print all Nix garbage collector roots
export def main [
    --dst # Show store paths that the roots point to
    --include-proc # Include roots located in `/proc`
]: nothing -> list {
    let roots = (
        nix-store --gc --print-roots
        | collect # so that errors from external command are not ignored
        | lines
        | parse "{src} -> {dst}"
        | if $include_proc {} else { where src !~ "^/proc/" }
    )
    if $dst {
        $roots
    } else {
        $roots | get src
    }
}
