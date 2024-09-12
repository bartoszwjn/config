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

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd = {
    kernelModules = [ "dm-snapshot" ];
    availableKernelModules = [
      "ahci"
      "nvme"
      "sd_mod"
      "usbhid"
      "xhci_pci"
    ];
  };

  boot.initrd.systemd.enable = true;
}
