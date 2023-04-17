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
      systemd-boot.enable = false;
      grub = {
        enable = true;
        enableCryptodisk = true;
        device = "nodev";
        efiSupport = true;
        efiInstallAsRemovable = true;
        extraEntries = let
          # nix shell nixpkgs#grub2 --command \
          #   sudo grub-probe --target=hints_string /boot/EFI/Microsoft/Boot/bootmgfw.efi
          grubHints = "";
          # filesystem UUID of the EFI partition
          grubFsUuid = "1C7E-5A22";
          archParams = lib.concatStringsSep " " [
            "root=UUID=c7af6e53-a18d-48a2-ac88-91d16d1f58e1"
            "rw"
            "cryptdevice=UUID=18ba60de-e82c-426e-a856-4bd95a1a778b:cryptroot"
            "loglevel=3"
            "systemd.unified_cgroup_hierarchy=1"
          ];
        in ''
          menuentry "Arch Linux" --class arch --class gnu-linux --class gnu --class os {
            insmod gzio
            insmod part_gpt
            insmod fat
            search --no-floppy --fs-uuid --set=root ${grubHints} ${grubFsUuid}
            echo "Loading Linux linux ..."
            linux /vmlinuz-linux ${archParams}
            echo "Loading initial ramdisk ..."
            initrd /intel-ucode.img /initramfs-linux.img
          }
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
