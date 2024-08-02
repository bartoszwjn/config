#!/usr/bin/env nu

# Fetch the latest version of a pypi package, and show when it was released
def main [
  package: string # package name
] {
  let response = (http get $"https://pypi.org/pypi/($package)/json")
  let latest_version = ($response.info.version)
  let release_dates = ($response.releases | get $latest_version | $in.upload_time)
  print $"Package: ($response.info.name)"
  print $"Latest version: ($latest_version)"
  print $"Released: ($release_dates)"
}
