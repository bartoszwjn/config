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
    cpu.intel.updateMicrocode = true;
    keyboard.zsa.enable = true;
    logitech.wireless.enable = true;
    pulseaudio.enable = true;
  };

  powerManagement.cpuFreqGovernor = "powersave";

  services = {
    fstrim.enable = true;
    tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = 75;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
    };
  };

  sound.enable = true;
}