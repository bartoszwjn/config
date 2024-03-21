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
    nvidia.modesetting.enable = true;
  };

  powerManagement.cpuFreqGovernor = "ondemand";

  services.fstrim.enable = true;
}
