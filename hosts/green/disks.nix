{
  config,
  lib,
  pkgs,
  ...
}:
{
  disko.devices = {
    disk = {
      ssd0 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-eui.002538db21a831f0";
        content = {
          type = "gpt";
          partitions = {
            esp = {
              type = "ef00"; # EFI system partition
              size = "1G"; # GiB
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                extraArgs = [
                  "-F"
                  "32"
                  "-n"
                  "ESP"
                ];
              };
            };
            root = {
              type = "8e00"; # Linux LVM
              size = "100%"; # all remaining
              content = {
                type = "lvm_pv";
                vg = "vg0";
              };
            };
          };
        };
      };
    };

    lvm_vg = {
      vg0 = {
        type = "lvm_vg";
        lvs = {
          cryptroot = {
            size = "100%FREE";
            priority = 9000;
            content = {
              type = "luks";
              name = "root";
              settings.allowDiscards = true;
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L"
                  "root"
                ];
                mountpoint = null;
                subvolumes = {
                  "@home" = {
                    mountpoint = "/home";
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                  };
                  "@root" = {
                    mountpoint = "/";
                  };
                  "@snapshots" = {
                    mountpoint = "/snapshots";
                  };
                  "@var" = {
                    mountpoint = "/var";
                  };
                };
                postCreateHook =
                  let
                    btrfs = config.disko.devices.lvm_vg.vg0.lvs.cryptroot.content.content;
                  in
                  ''
                    (
                      MNTPOINT=$(mktemp -d)
                      mount ${btrfs.device} "$MNTPOINT" -o subvol=/
                      trap 'umount "$MNTPOINT"; rm -rf "$MNTPOINT"' EXIT
                      mkdir -p "$MNTPOINT/@snapshots/root"
                      btrfs subvolume snapshot -r "$MNTPOINT/@root" "$MNTPOINT/@snapshots/root/empty"
                    )
                  '';
              };
            };
          };
          cryptswap = {
            size = "32G"; # GiB
            priority = 1000;
            content = {
              type = "swap";
              randomEncryption = true;
              discardPolicy = "both";
              resumeDevice = false;
            };
          };
        };
      };
    };
  };
}
