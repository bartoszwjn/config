{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) types;

  cfg = config.custom.network;
in
{
  options.custom.network = {
    enable = lib.mkEnableOption "network configuration";

    wireless = {
      enable = lib.mkEnableOption "wpa_supplicant configuration";
      controllingUsers = lib.mkOption {
        type = types.listOf types.str;
        description = ''
          Names of users who are allowed to control wpa_supplicant using `wpa_cli` or `wpa_gui`.
        '';
      };
    };

    networks = lib.mkOption {
      type = types.listOf types.str;
      description = "Names of systemd-networkd networks configured by this module";
      readOnly = true;
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      useNetworkd = true;
      firewall.enable = true;

      wireless = lib.mkIf cfg.wireless.enable {
        enable = true;
        userControlled = true;
        allowAuxiliaryImperativeNetworks = true;
      };
    };

    users.users = lib.optionalAttrs cfg.wireless.enable (
      lib.listToAttrs (
        lib.forEach cfg.wireless.controllingUsers (
          user: lib.nameValuePair user { extraGroups = [ "wpa_supplicant" ]; }
        )
      )
    );

    systemd.network = {
      enable = true;
      wait-online.anyInterface = true;
      networks = {
        "90-ethernet" = {
          # Match ethernet interfaces, excluding virtual interfaces.
          # https://wiki.archlinux.org/title/Systemd-networkd#Configuration_examples
          matchConfig.Type = "ether";
          matchConfig.Kind = "!*";

          networkConfig.DHCP = "ipv4";
          networkConfig.IPv6PrivacyExtensions = "yes";

          dhcpV4Config.RouteMetric = 1024;
          ipv6AcceptRAConfig.RouteMetric = 1024;
        };
        "90-wireless" = {
          matchConfig.WLANInterfaceType = "station";

          networkConfig.DHCP = "ipv4";
          networkConfig.IPv6PrivacyExtensions = "yes";

          dhcpV4Config.RouteMetric = 1025;
          ipv6AcceptRAConfig.RouteMetric = 1025;
        };
      };
    };

    custom.network.networks = [
      "90-ethernet"
      "90-wireless"
    ];
  };
}
