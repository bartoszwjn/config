{
  config,
  lib,
  pkgs,
  ...
}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    initrd = {
      availableKernelModules = ["xhci_pci" "nvme" "usbhid" "sd_mod" "sdhci_pci"];
      kernelModules = ["dm-snapshot"];
      luks.devices."crypt-nixos" = {
        device = "/dev/disk/by-uuid/2a4583d7-029d-4a82-8ab1-1e63da26bf58";
        preLVM = true;
        allowDiscards = true;
      };
    };

    kernelModules = ["kvm-amd"];

    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
      };
      efi = {
        efiSysMountPoint = "/boot";
        canTouchEfiVariables = false;
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/vg0/root";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/4C4C-4D21";
      fsType = "vfat";
    };
  };

  swapDevices = [
    {device = "/dev/vg0/swap";}
  ];
}
