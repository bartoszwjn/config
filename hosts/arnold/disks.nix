{
  config,
  lib,
  pkgs,
  ...
}:

{
  assertions = [
    {
      assertion = config.boot.zfs.enabled == true;
      message = "ZFS support is not enabled";
    }
  ];

  disko.devices = {
    disk =
      let
        mkHdd = n: device: {
          type = "disk";
          inherit device;
          content = {
            type = "gpt";
            partitions = {
              data = {
                type = "8309"; # Linux LUKS
                size = "100%";
                content = {
                  type = "luks";
                  name = "data-${toString n}";
                  passwordFile = "/tmp/luks.key";
                  content = {
                    type = "zfs";
                    pool = "zdata";
                  };
                };
              };
            };
          };
        };
      in
      {
        ssd1 = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-eui.6479a718a1262cb2";
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
                type = "8309"; # Linux LUKS
                size = "100%"; # all remaining
                content = {
                  type = "luks";
                  name = "root";
                  passwordFile = "/tmp/luks.key";
                  settings = {
                    allowDiscards = true;
                  };
                  content = {
                    type = "zfs";
                    pool = "zroot";
                  };
                };
              };
            };
          };
        };
        hdd1 = mkHdd 1 "/dev/disk/by-id/wwn-0x50014ee214f8192b";
        hdd2 = mkHdd 2 "/dev/disk/by-id/wwn-0x50014ee26b0f68c7";
        hdd3 = mkHdd 3 "/dev/disk/by-id/wwn-0x50014ee2bfa346e3";
      };

    zpool = {
      zroot = {
        type = "zpool";
        mode = ""; # no redundancy
        mountpoint = null;
        options = {
          ashift = "12";
          autotrim = "on";
        };
        rootFsOptions = {
          mountpoint = "none";
          # defaults for other datasets
          acltype = "posix";
          atime = "on";
          checksum = "on";
          compression = "on";
          dedup = "off";
          redundant_metadata = "all";
          relatime = "on";
          xattr = "sa";
        };
        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
            postCreateHook = "zfs snapshot zroot/root@empty";
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
          };
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
            options.mountpoint = "legacy";
          };
          var = {
            type = "zfs_fs";
            mountpoint = "/var";
            options.mountpoint = "legacy";
          };
        };
      };
      zdata = {
        type = "zpool";
        mode = "raidz";
        mountpoint = null;
        options = {
          ashift = "12";
        };
        rootFsOptions = {
          mountpoint = "none";
          # defaults for other datasets
          acltype = "posix";
          atime = "on";
          checksum = "on";
          compression = "on";
          dedup = "off";
          redundant_metadata = "all";
          relatime = "on";
          xattr = "sa";
        };
        datasets = {
          data = {
            type = "zfs_fs";
            mountpoint = "/data";
            options.mountpoint = "legacy";
          };
        };
      };
    };
  };

  swapDevices = [ ];

  boot.zfs = {
    forceImportRoot = false;
    forceImportAll = false;
  };

  services.zfs = {
    trim = {
      enable = true;
      interval = "weekly";
    };
    autoScrub = {
      enable = true;
      interval = "Sun, 02:00";
      pools = [ ]; # all
    };
  };
}
