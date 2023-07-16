{
  config,
  lib,
  pkgs,
  ...
}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    initrd = {
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "sd_mod" "sdhci_pci"];
      kernelModules = ["dm-snapshot"];
      luks.devices."root" = {
        device = "/dev/vg0/cryptroot";
        preLVM = false;
        allowDiscards = true;
      };
    };

    kernelModules = ["kvm-intel"];

    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
        extraEntries = {
          "arch.conf" = ''
            title Arch Linux
            linux /vmlinuz-linux
            initrd /intel-ucode.img
            initrd /initramfs-linux.img
            options root=UUID=c7af6e53-a18d-48a2-ac88-91d16d1f58e1
            options rw
            options cryptdevice=UUID=18ba60de-e82c-426e-a856-4bd95a1a778b:cryptroot
            options loglevel=3
            options systemd.unified_cgroup_hierarchy=1
          '';
        };
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
