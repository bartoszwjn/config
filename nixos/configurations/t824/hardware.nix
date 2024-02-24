{
  config,
  lib,
  pkgs,
  ...
}: {
  boot = {
    kernelModules = ["acpi_call"];
    extraModulePackages = [config.boot.kernelPackages.acpi_call];
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    cpu.amd.updateMicrocode = true;
    keyboard.zsa.enable = true;
    logitech.wireless.enable = true;
    pulseaudio.enable = true;
  };

  powerManagement.cpuFreqGovernor = "powersave";

  services = {
    fstrim.enable = true;
    udev.extraRules = lib.concatStringsSep ", " [
      ''ACTION=="add"''
      ''SUBSYSTEM=="backlight"''
      ''RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness"''
      ''RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"''
    ];
  };

  sound.enable = true;
}
