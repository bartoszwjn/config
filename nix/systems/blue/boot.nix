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
      systemd-boot.enable = false;
      grub = {
        enable = true;
        enableCryptodisk = true;
        device = "nodev";
        efiSupport = true;
        efiInstallAsRemovable = true;
        extraEntries = let
          # nix shell nixpkgs#grub2 --command \
          #   sudo grub-probe --target=hints_string /mnt/EFI/Microsoft/Boot/bootmgfw.efi
          grubHints = "--hint-bios=hd0,gpt1 --hint-efi=hd0,gpt1 --hint-baremetal=ahci0,gpt1";
          # filesystem UUID of Windows EFI partition
          grubFsUuid = "22E5-28FE";
        in ''
          menuentry "Windows Boot Manager" --class windows --class os {
            insmod part_gpt
            insmod fat
            insmod chain
            search --no-floppy --fs-uuid --set=root ${grubHints} ${grubFsUuid}
            chainloader /EFI/Microsoft/Boot/bootmgfw.efi
          }
          menuentry "UEFI Firmware Settings" {
            fwsetup
          }
          menuentry "Reboot" {
            reboot
          }
          menuentry "Shutdown" {
            halt
          }
        '';
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
