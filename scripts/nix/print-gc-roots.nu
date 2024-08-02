#!/usr/bin/env nu

# Print all Nix garbage collector roots
def main [
  --dst # Show store paths that the roots point to
] {
  let roots = (
    do -c { ^nix-store --gc --print-roots | ^rg --invert-match '^/proc/' }
    | lines
    | parse "{src} -> {dst}"
  )
  if $dst {
    $roots
  } else {
    $roots | get src
  }
}
