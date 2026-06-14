#!/usr/bin/env nu

# List all actions used as dependencies in a GitHub Actions workflow file.
export def main [
  workflow_file: path
]: nothing -> table<owner: string, repo: string, version: string, sha: string, lines: list<int>> {
  let contents = open --raw $workflow_file

  let owner_pat = "(?<owner>[a-zA-Z0-9_-]+)"
  let repo_pat = "(?<repo>[a-zA-Z0-9_-]+)"
  let sha_pat = "(?<sha>[0-9a-f]{40})"
  let version_pat = "(?<version>v[0-9]+(?:\\.[0-9]+)*)"
  let pat = $"^ *uses: ($owner_pat)/($repo_pat)@($sha_pat) # ($version_pat)$"

  (
    $contents
    | lines
    | enumerate
    | each {|it|
      let matches = $it.item | parse --regex $pat
      if not ($matches | is-empty) {
        $matches | get 0 | insert line $it.index | select line owner repo version sha
      } else {
        null
      }
    }
    | group-by { select owner repo version sha }
    | values
    | each {|it|
      $it.0 | reject line | insert lines $it.line
    }
  )
}
