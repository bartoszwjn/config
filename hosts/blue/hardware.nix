{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot.kernelModules = [ "kvm-amd" ];

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    cpu.amd.updateMicrocode = true;
    keyboard.zsa.enable = true;
    logitech.wireless.enable = true;
  };

  powerManagement.cpuFreqGovernor = "ondemand";

  services.fstrim.enable = true;
}
