{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.printing;
in
{
  options.custom.printing = {
    enable = lib.mkEnableOption "printer configuration";
  };

  config = lib.mkIf cfg.enable {
    services = {
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
      printing.enable = true;
    };

    # https://discourse.nixos.org/t/cups-cups-filters-and-libppd-security-issues/52780
    systemd.services.cups-browsed.enable = false;
  };
}
