#!/usr/bin/env nu

def main [
  file: path # Path to source.json file
  --dry-run # Print the new contents instead of modifying the file in place
] {
  let old = (open --raw $file | from json)

  let commit = (
    http get $"https://api.github.com/repos/($old.owner)/($old.repo)/branches/($old.branch)"
    | get commit
  )
  let git_commit = $commit.commit
  let new_datetime = ($git_commit.committer.date | into datetime)
  let new_summary = ($git_commit.message | lines | first)
  print -e $"Most recent commit: ($new_summary)\nCommit date: ($new_datetime)"

  let fetch_submodules = if "fetchSubmodules" in ($old | columns) and $old.fetchSubmodules {
    "--fetch-submodules"
  } else {
    "--no-fetch-submodules"
  }
  let new_hash = (
    do -c { ^nix-prefetch-github $old.owner $old.repo --rev $commit.sha $fetch_submodules --json }
    | from json | get hash
  )

  let new = (
    $old
    | update rev $commit.sha
    | update hash $new_hash
    | update commitDate ($new_datetime | format date "%Y-%m-%d")
  )
  let new_json = ($new | to json --indent 4) + "\n"

  if $dry_run {
    print $new_json
  } else {
    $new_json | save --raw --force $file
  }
}
