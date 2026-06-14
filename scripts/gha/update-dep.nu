#!/usr/bin/env nu

use ./list-deps.nu

# Update all uses of an action in a workflow file to a new version.
def main [
  workflow_file: path
  owner: string
  repo: string
  new_version: string
] {
  let deps = list-deps $workflow_file | where {|dep| $dep.owner == $owner and $dep.repo == $repo }
  if ($deps | is-empty) {
    error make -u $"workflow ($workflow_file) does not depend on ($owner)/($repo)"
  }

  let new_sha = resolve_tag $owner $repo $new_version

  let contents = open --raw $workflow_file
  let lines = $deps | each { get lines } | flatten
  let new_contents = (
    $contents
    | lines
    | enumerate
    | each {|line|
      if $line.index in $lines {
        let indent = $line.item | str replace --regex "^(?<indent> *)uses:.*$" "${indent}"
        $"($indent)uses: ($owner)/($repo)@($new_sha) # ($new_version)\n"
      } else {
        $line.item + "\n"
      }
    }
    | str join
  )
  $new_contents | save --force $workflow_file
}

def resolve_tag [
  owner: string
  repo: string
  tag: string
]: nothing -> string {
  let headers = { "X-GitHub-Api-Version": "2026-03-10" }

  let url = $"https://api.github.com/repos/($owner)/($repo)/git/ref/tags/($tag)"
  let ref = http get --headers $headers $url

  match $ref.object.type {
    commit => { $ref.object.sha }
    tag => {
      let tag = http get --headers $headers $ref.object.url
      match $tag.object.type {
        commit => { $tag.object.sha }
        $type => {
          error make -u {
            msg: (
              $"tag object pointed to by ($ref.ref) points to an object of type ($type),"
              + " expected a commit"
            )
          }
        }
      }
    }
    $type => {
      error make -u {
        msg: $"ref tags/($tag) points to an object of type ($type), expected a commit or a tag"
      }
    }
  }
}
