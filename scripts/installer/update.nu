#!/usr/bin/env nu

use ./common.nu

# Update a UEFI bootable NixOS USB installation media without overwriting the data partition
export def main [
  device: path # Path to the USB device
  --flake: string = $common.REPO_ROOT # Flake containing the NixOS configuration to build
  --attr (-A): string = "bootstrap" # Flake output attribute containing the NixOS configuration
  --iso-image-path: path # Path to a NixOS CD installation ISO (overrides `--flake` and `--attr`)
  --dry-run (-n) # Do not run any destructive operations
]: nothing -> nothing {
  common validate_device $device (metadata $device).span

  let iso_image_path = if $iso_image_path != null { $iso_image_path } else {
    common build_iso_image $flake $attr
  }

  common copy_to_esp --dry-run=$dry_run $iso_image_path $"($device)1"
}
