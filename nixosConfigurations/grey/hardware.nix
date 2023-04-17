{
  config,
  lib,
  pkgs,
  ...
}: {
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

  services.fstrim.enable = true;

  sound.enable = true;
}
