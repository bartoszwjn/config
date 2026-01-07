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

    # systemd-resolved for DNS, with manually selected DNS servers and DNS over TLS
    networking.nameservers = [
      "2620:fe::fe#dns.quad9.net"
      "2620:fe::9#dns.quad9.net"
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
    ];
    services = {
      resolved = {
        enable = true;
        dnssec = "false";
        dnsovertls = "true";
        fallbackDns = [
          "1.1.1.1#cloudflare-dns.com"
          "8.8.8.8#dns.google"
          "1.0.0.1#cloudflare-dns.com"
          "8.8.4.4#dns.google"
          "2606:4700:4700::1111#cloudflare-dns.com"
          "2001:4860:4860::8888#dns.google"
          "2606:4700:4700::1001#cloudflare-dns.com"
          "2001:4860:4860::8844#dns.google"
        ];
      };
    };
    # Do not use nameservers obtained from DHCP.
    networking.networkmanager.dns = lib.mkOverride 75 "none"; # between `mkForce` and the default
  };
}
