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
      systemPackages = lib.attrValues {
        inherit (pkgs)
          # keep-sorted start
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
          ncdu
          ntfs3g
          openssh
          pciutils
          vim
          # keep-sorted end
          ;
        inherit (config.boot.kernelPackages) cpupower;
      };
      variables.EDITOR = "vim";
    };

    boot.kernel.sysctl."kernel.task_delayacct" = true; # required by iotop-c
  };
}
