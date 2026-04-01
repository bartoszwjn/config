{
  config,
  lib,
  pkgs,
  ...
}:

{
  powerManagement.cpuFreqGovernor = "ondemand";
  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
  };
}
