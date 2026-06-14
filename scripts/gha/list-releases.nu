#!/usr/bin/env nu

use std

# List releases of a specific GitHub Action.
def main [
  owner: string
  repo: string
] {
  (
    get_releases $owner $repo
    | select tag_name created_at updated_at published_at body
    | into datetime created_at updated_at published_at
    | insert date {|row|
      [
        $"Created:   ($row.created_at | display_date)"
        $"Updated:   ($row.updated_at | display_date)"
        $"Published: ($row.published_at | display_date)"
      ] | str join "\n"
    }
    | sort-by {|it| coalesce $it.updated_at $it.published_at $it.created_at }
    | select tag_name date body
    | table
    | print
  )
}

def get_releases [ owner: string, repo: string ]: nothing -> table {
  let headers = { "X-GitHub-Api-Version": "2026-03-10" }

  mut releases = []
  mut links = { next: $"https://api.github.com/repos/($owner)/($repo)/releases?per_page=100" }
  while "next" in $links {
    let response = http get --full --headers $headers $links.next
    $releases = $releases | append $response.body
    $links = parse_link_header $response
  }
  $releases
}

def parse_link_header [response: record]: nothing -> record {
  mut links = {}
  for header in ($response.headers.response | where name == link | each { get value }) {
    for part in ($header | split row "," | each { str trim }) {
      let parsed = $part | parse "<{url}>; rel=\"{rel}\"" | get 0
      $links = $links | insert $parsed.rel ($parsed.url | url decode)
    }
  }
  $links
}

def display_date []: datetime -> string {
  let dt = $in
  ($dt | format date "%F %T %Z") + $" \(($dt | date humanize)\)"
}

def coalesce [...args: any] {
  for arg in $args {
    if $arg != null {
      return $arg
    }
  }
  null
}
