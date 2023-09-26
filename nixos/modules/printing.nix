{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.printing;
in {
  options.custom.printing = {
    enable = lib.mkEnableOption "printer configuration";
  };

  config = lib.mkIf cfg.enable {
    services = {
      avahi = {
        enable = true;
        nssmdns = true;
        openFirewall = true;
      };
      printing.enable = true;
    };
  };
}
