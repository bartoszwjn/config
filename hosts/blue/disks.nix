{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/vg0/cryptroot";
      allowDiscards = true;
    };
    data-0-0 = {
      device = "/dev/disk/by-uuid/6bfa567a-0adc-4332-8849-41dadfcf465c";
      allowDiscards = true;
    };
    data-0-1 = {
      device = "/dev/disk/by-uuid/9174ee64-8fe1-47a4-87af-94b597560e4d";
      allowDiscards = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/root";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/7D58-3055";
      fsType = "vfat";
    };
    "/mnt/data-0" = {
      device = "/dev/mapper/data-0-0";
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
