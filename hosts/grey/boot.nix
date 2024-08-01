{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "sd_mod"
        "sdhci_pci"
      ];
      kernelModules = [ "dm-snapshot" ];
      luks.devices."root" = {
        device = "/dev/vg0/cryptroot";
        preLVM = false;
        allowDiscards = true;
      };
    };

    kernelModules = [ "kvm-intel" ];

    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/155ea03b-d794-42d6-8ea8-96b4c6a8495e";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/1C7E-5A22";
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
