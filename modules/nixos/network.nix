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

    controllingUsers = lib.mkOption {
      type = types.listOf types.str;
      description = "Names of users added to the `networkmanager` group.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.enable = true;

    # NetworkManager for regular networking, configured imperatively
    networking.networkmanager.enable = true;
    users.users = lib.genAttrs cfg.controllingUsers (user: {
      extraGroups = [ "networkmanager" ];
    });

    # systemd-networkd for declaratively configured networking
    networking = {
      useNetworkd = true; # avoid scripted NixOS networking
      useDHCP = false; # do not create catchall networkd networks
    };
    systemd.network = {
      enable = true;
      wait-online.enable = false;
    };
  };
}
