#!/usr/bin/env nu

use ./common.nu
use ./common.nu [run_cmd run_sudo]

# Create a UEFI bootable NixOS USB installation media and a data partition in the remaining space
export def main [
  device: path # Path to the USB device
  --flake: string = $common.REPO_ROOT # Flake containing the NixOS configuration to build
  --attr (-A): string = "bootstrap" # Flake output attribute containing the NixOS configuration
  --iso-image-path: path # Path to a NixOS CD installation ISO (overrides `--flake` and `--attr`)
  --data-fs-type: string = "ext4" # Filesystem created in the extra data partition
  --data-fs-label: string = "data-extra" # Label for the extra data partition filesystem
  --dry-run (-n) # Do not run any destructive operations
]: nothing -> nothing {
  let spans = {
    device: (metadata $device).span,
    data_fs_type: (metadata $data_fs_type).span,
    data_fs_label: (metadata $data_fs_label).span,
  }

  validate_data_fs $data_fs_type $data_fs_label $spans
  common validate_device $device $spans.device

  let packages = run_cmd nix build --no-link --print-out-paths ...[
    nixpkgs#gptfdisk^out
    nixpkgs#dosfstools^out
    nixpkgs#e2fsprogs^bin
    nixpkgs#btrfs-progs^out
    nixpkgs#util-linux^bin
  ]
  $env.PATH = $env.PATH | prepend ($packages | lines | each { path join "bin" })

  create_partitions --dry-run=$dry_run $device
  create_esp_fs --dry-run=$dry_run $"($device)1"
  create_data_fs --dry-run=$dry_run $"($device)2" $data_fs_type $data_fs_label

  let iso_image_path = if $iso_image_path != null { $iso_image_path } else {
    common build_iso_image $flake $attr
  }

  common copy_to_esp --dry-run=$dry_run $iso_image_path $"($device)1" --fresh-esp
}

def validate_data_fs [type: string, label: string, spans: record]: nothing -> nothing {
  let max_label_length = match $type {
    "ext4" => { 16 }
    "vfat" => { 11 }
    "btrfs" => { 255 }
    _ => {
      error make {
        msg: "Unsupported filesystem"
        help: "Supported filesystems: ext4, vfat, btrfs"
        labels: [{
          text: $"The ($type) filesystem is not supported"
          span: $spans.data_fs_type
        }]
      }
    }
  }

  let label_length = $label | str length --utf-8-bytes
  if $max_label_length < $label_length {
    error make {
      msg: "Filesystem label is too long"
      labels: [{
        text: $"This label is ($label_length) bytes long"
        span: $spans.data_fs_label
      }, {
        text: $"Maximum label length for this filesystem is ($max_label_length)"
        span: $spans.data_fs_type
      }]
    }
  }
}

def create_partitions [--dry-run, device: path]: nothing -> nothing {
  run_sudo --dry-run=$dry_run wipefs --all $device
  run_sudo --dry-run=$dry_run sgdisk $device ...[
    --clear
    --align-end

    --new=1:0:+2G
    --partition-guid=1:R
    --change-name=1:nixos-installer-esp
    --typecode=1:EF00
    --attributes=1:=:0

    --new=2:0:-0
    --partition-guid=2:R
    --change-name=2:nixos-installer-extra-data
    --typecode=2:8300
    --attributes=2:=:0
  ]
}

def create_esp_fs [--dry-run, partition: path]: nothing -> nothing {
  run_sudo --dry-run=$dry_run wipefs --all $partition
  run_sudo --dry-run=$dry_run mkfs.vfat -F 32 -n nixos-usb $partition
}

def create_data_fs [
  --dry-run, partition: path, fs_type: string, fs_label: string
]: nothing -> nothing {
  run_sudo --dry-run=$dry_run wipefs --all $partition
  match $fs_type {
    "ext4" => {
      run_sudo --dry-run=$dry_run mkfs.ext4 -L $fs_label $partition
    }
    "vfat" => {
      run_sudo --dry-run=$dry_run mkfs.vfat -F 32 -n $fs_label $partition
    }
    "btrfs" => {
      run_sudo --dry-run=$dry_run mkfs.btrfs -L $fs_label $partition
    }
    _ => {
      error make -u $"Unsupported filesystem: ($fs_type)"
    }
  }
}
