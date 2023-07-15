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
      luks.devices."root" = {
        device = "/dev/vg0/cryptroot";
        preLVM = false;
        allowDiscards = true;
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
