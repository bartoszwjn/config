use std/assert

export const REPO_ROOT = path self "../.."

export def validate_device [device: path, span: record]: nothing -> nothing {
  assert ($device =~ "^/dev/sd[a-z]$") "Invalid device path" --error-label {
    text: "Expected device path to match '/dev/sd[a-z]'",
    span: $span,
  }

  let name = $device | str replace --regex "^/dev/" ""
  let sys_path = $"/sys/class/block/($name)"
  let removable_path = $sys_path | path join "removable"
  if not ($removable_path | path exists) {
    error make -u $"($removable_path) does not exist. Are you sure ($device) is the correct device?"
  }
  if (open --raw $removable_path | str trim) != "1" {
    error make -u $"($device) is not removable. Are you sure ($device) is the correct device?"
  }

  let vendor = open --raw ($sys_path | path join device/vendor) | str trim
  let model = open --raw ($sys_path | path join device/model) | str trim

  print -e $"Using device ($device): ($vendor) ($model)"
  let answer = input "Proceed? [y/N] "
  match ($answer | str downcase) {
    "y" | "yes" => {}
    "n" | "no" | "" => { exit 0 }
    _ => {
      print -e $"Expected 'y' or 'n', got '($answer)', aborting..."
      exit 1
    }
  }
}

export def build_iso_image [flake: string, attr: string]: nothing -> path {
  let attr = if ($attr | str starts-with ".") { $attr } else {
    $".nixosConfigurations.($attr).config.system.build.isoImage"
  }
  let installable = $"($flake)#($attr)"
  let output = run_cmd nix build --print-out-paths --no-link -- $installable

  let files = ls --all --full-paths ($output | path join "iso")

  assert length $files 1
  assert equal $files.0.type "file"
  assert equal ($files.0.name | path parse | get extension) "iso"

  $files.0.name
}

export def copy_to_esp [
  --dry-run, --fresh-esp, iso_image_path: path, esp_partition: path
]: nothing -> nothing {
  with_tmp_mount_dirs {|iso_mount_point, esp_mount_point|
    with_mount iso9660 $iso_image_path $iso_mount_point {||
      with_mount --dry-run=($dry_run and $fresh_esp) vfat $esp_partition $esp_mount_point {||
        let src_items = ls --all --short-names $iso_mount_point | select name type | sort-by name
        assert equal $src_items [
          [name type];
          [.boot.cat file]
          [EFI dir]
          [boot dir]
          [isolinux dir]
          [nix-store.squashfs file]
          [version.txt file]
        ]

        if not $fresh_esp {
          let dst_items = ls --all --full-paths $esp_mount_point | get name
          run_sudo --dry-run=$dry_run rm -r ...$dst_items
        }

        (
          $src_items | get name
          | where { $in not-in [.boot.cat isolinux] } # ignore ISO9660/El Torito files
          | each {|item| $iso_mount_point | path join $item }
          | run_sudo --dry-run=$dry_run cp --archive ...$in $esp_mount_point
        )
      }
    }
  }
}

def with_tmp_mount_dirs [f: closure]: nothing -> any {
  let tmp_dir = mktemp --directory
  let iso_mount_point = $tmp_dir | path join iso
  let esp_mount_point = $tmp_dir | path join esp
  mkdir $iso_mount_point $esp_mount_point
  
  with_cleanup {|| rm $iso_mount_point $esp_mount_point; rm $tmp_dir } {||
    do $f $iso_mount_point $esp_mount_point
  }
}

def with_mount [
  --dry-run, fs: string, device: path, mountpoint: path, f: closure
]: nothing -> any {
  run_sudo --dry-run=$dry_run mount -t $fs $device $mountpoint

  with_cleanup {|| run_sudo --dry-run=$dry_run umount $mountpoint } {||
    do $f
  }
}

def with_cleanup [cleanup: closure, f: closure]: nothing -> any {
  try {
    let result = do $f
    [true $result]
  } catch {|err|
    [false $err]
  } finally {|res|
    do $cleanup
    if $res.0 { $res.1 } else { error make $res.1 }
  }
}

export def --wrapped run_cmd [--dry-run, cmd: string, ...args: string]: nothing -> any {
    if $dry_run {
      print -e $"Would run (ansi default_bold)($cmd) ($args | str join ' ')(ansi reset)"
      null
    } else {
      print -e $"(ansi default_bold)($cmd) ($args | str join ' ')(ansi reset)"
      run-external $cmd ...$args
    }
}

export def --wrapped run_sudo [--dry-run, ...args: string]: nothing -> any {
  run_cmd --dry-run=$dry_run sudo ...$args
}
