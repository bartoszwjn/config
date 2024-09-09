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
    timeout = 3;
    efi.canTouchEfiVariables = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd = {
    kernelModules = [ "dm-snapshot" ];
    availableKernelModules = [
      "nvme"
      "sd_mod"
      "thunderbolt"
      "usbhid"
      "xhci_pci"
    ];
  };

  boot.initrd.systemd.enable = true;
}
