{
  config,
  lib,
  pkgs,
  ...
}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    initrd = {
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "sd_mod"];
      kernelModules = ["dm-snapshot"];
      luks = {
        reusePassphrases = true;
        devices = {
          root = {
            device = "/dev/vg0/cryptroot";
            preLVM = false;
            allowDiscards = true;
          };
          data-0-0 = {
            device = "/dev/disk/by-uuid/6bfa567a-0adc-4332-8849-41dadfcf465c";
            preLVM = false;
            allowDiscards = true;
          };
          data-0-1 = {
            device = "/dev/disk/by-uuid/9174ee64-8fe1-47a4-87af-94b597560e4d";
            preLVM = false;
            allowDiscards = true;
          };
        };
      };
    };

    kernelModules = ["kvm-amd"];

    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/ac15240d-7e73-4a26-b2c5-6be49550d6c1";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/7D58-3055";
      fsType = "vfat";
    };
    "/mnt/data-0" = {
      device = "/dev/disk/by-label/data-0";
      fsType = "btrfs";
    };
  };

  swapDevices = [
    {
      device = "/dev/vg0/cryptswap";
      randomEncryption = {
        enable = true;
        allowDiscards = true;
      };
    }
  ];
}
