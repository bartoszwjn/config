{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.network;
in
{
  options.custom.network = {
    enable = lib.mkEnableOption "network configuration";

    enableWireless = lib.mkEnableOption "wpa_supplicant configuration";

    interfaces = lib.mkOption {
      type = lib.types.uniq (lib.types.listOf lib.types.str);
      description = ''
        List of network interfaces managed by systemd-networkd. Interfaces earlier in that list will
        be preferred over later ones for sending outgoing packets.
      '';
    };

    interfaceToNetwork = lib.mkOption {
      type = lib.types.uniq (lib.types.attrsOf lib.types.str);
      description = ''
        A read-only option that maps names of interfaces in `config.custom.network.interfaces` to
        names of networks that control them.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    custom.network.interfaceToNetwork =
      let
        numWidth = lib.max 2 (builtins.stringLength (toString (builtins.length cfg.interfaces)));
      in
      builtins.listToAttrs (
        lib.flip lib.imap1 cfg.interfaces (
          n: iface: {
            name = iface;
            value = "${lib.strings.fixedWidthNumber numWidth n}-${iface}";
          }
        )
      );

    networking = {
      useNetworkd = true;
      firewall.enable = true;

      wireless = lib.mkIf cfg.enableWireless {
        enable = true;
        userControlled = {
          enable = true;
          group = "wheel";
        };
        allowAuxiliaryImperativeNetworks = true;
      };
    };

    systemd.network = {
      enable = true;
      networks = builtins.listToAttrs (
        lib.flip lib.imap1 cfg.interfaces (
          n: iface: {
            name = cfg.interfaceToNetwork.${iface};
            value = {
              matchConfig.Name = iface;
              networkConfig.DHCP = "ipv4";
              dhcpV4Config.RouteMetric = n;
              ipv6AcceptRAConfig.RouteMetric = n;
            };
          }
        )
      );
      wait-online.anyInterface = true;
    };
  };
}
