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
    cpu.amd.updateMicrocode = true;
    keyboard.zsa.enable = true;
    logitech.wireless.enable = true;
    pulseaudio.enable = true;
  };

  powerManagement.cpuFreqGovernor = "ondemand";

  services.fstrim.enable = true;

  sound.enable = true;
}
