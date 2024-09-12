{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot = {
    kernelModules = [
      "acpi_call"
      "kvm-intel"
    ];
    extraModulePackages = [ config.boot.kernelPackages.acpi_call ];
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    cpu.intel.updateMicrocode = true;
    keyboard.zsa.enable = true;
    logitech.wireless.enable = true;
  };

  powerManagement.cpuFreqGovernor = "powersave";

  services.fstrim.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  services.udev.extraRules = lib.concatStringsSep ", " [
    ''ACTION=="add"''
    ''SUBSYSTEM=="backlight"''
    ''RUN+="${lib.getExe' pkgs.coreutils "chgrp"} video $sys$devpath/brightness"''
    ''RUN+="${lib.getExe' pkgs.coreutils "chmod"} g+w $sys$devpath/brightness"''
  ];
}
