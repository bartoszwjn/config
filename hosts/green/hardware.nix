{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot = {
    kernelModules = [ "acpi_call" "kvm-amd" ];
    extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
    keyboard.zsa.enable = true;
    logitech.wireless.enable = true;
  };

  powerManagement.cpuFreqGovernor = "powersave";

  services = {
    fstrim.enable = true;
    udev.extraRules = lib.concatStringsSep ", " [
      ''ACTION=="add"''
      ''SUBSYSTEM=="backlight"''
      ''RUN+="${lib.getExe' pkgs.coreutils "chgrp"} video $sys$devpath/brightness"''
      ''RUN+="${lib.getExe' pkgs.coreutils "chmod"} g+w $sys$devpath/brightness"''
    ];
  };
}