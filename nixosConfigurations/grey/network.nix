{
  config,
  lib,
  pkgs,
  ...
}: {
  networking = {
    hostName = "grey";
    dhcpcd.enable = false;
    firewall.enable = true;
    wireless = {
      enable = true;
      userControlled.enable = true;
      allowAuxiliaryImperativeNetworks = true;
    };
  };

  systemd.network = {
    enable = true;
    networks = {
      "10-wired" = {
        matchConfig.Name = "enp3s0";
        networkConfig.DHCP = "yes";
        dhcpV4Config.RouteMetric = 10;
        ipv6AcceptRAConfig.RouteMetric = 10;
      };
      "11-wireless" = {
        matchConfig.Name = "wlp5s0";
        networkConfig.DHCP = "yes";
        dhcpV4Config.RouteMetric = 20;
        ipv6AcceptRAConfig.RouteMetric = 20;
      };
    };
    wait-online.anyInterface = true;
  };

  services = {
    resolved.enable = true;
    tailscale.enable = true;
  };
  # otherwise tailscale gets stuck on shutdown trying to send logs
  systemd.services.tailscaled = {
    after = ["nss-lookup.target" "network-online.target"];
    wants = ["network-online.target"];
  };
}
