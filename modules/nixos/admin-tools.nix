{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.admin-tools;
in
{
  options.custom.admin-tools = {
    enable = lib.mkEnableOption "admin tools";
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = builtins.attrValues {
        inherit (pkgs)
          file
          git
          htop
          hwinfo
          iftop
          inetutils
          iotop-c
          ldns
          lshw
          lsof
          ntfs3g
          openssh
          pciutils
          vim
          ;
        inherit (config.boot.kernelPackages) cpupower;
      };
      variables.EDITOR = "vim";
    };

    boot.kernel.sysctl."kernel.task_delayacct" = true; # required by iotop-c
  };
}
