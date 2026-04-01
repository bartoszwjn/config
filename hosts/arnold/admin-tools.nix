{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      file
      git
      htop
      iftop
      inetutils
      iotop-c
      ldns
      lshw
      lsof
      pciutils
      vim
      ;
    inherit (config.boot.kernelPackages) cpupower;
  };

  environment.variables.EDITOR = "vim";

  boot.kernel.sysctl."kernel.task_delayacct" = true; # required by iotop-c
}
