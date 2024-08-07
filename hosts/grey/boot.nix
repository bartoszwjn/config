{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot.loader = {
    systemd-boot = {
      enable = true;
      editor = false;
    };
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    kernelModules = [ "kvm-intel" ];
    initrd = {
      kernelModules = [ "dm-snapshot" ];
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "sd_mod"
        "sdhci_pci"
      ];
    };
  };

  boot.initrd.systemd.enable = true;

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/vg0/cryptroot";
      allowDiscards = true;
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
