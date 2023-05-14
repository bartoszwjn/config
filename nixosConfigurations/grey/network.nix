{
  config,
  lib,
  pkgs,
  ...
}: {
  custom.dns.enable = true;

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
        networkConfig.DHCP = "ipv4";
        dhcpV4Config = {
          RouteMetric = 10;
          UseDNS = false;
        };
        dhcpV6Config.UseDNS = false;
        ipv6AcceptRAConfig = {
          RouteMetric = 10;
          UseDNS = false;
        };
      };
      "11-wireless" = {
        matchConfig.Name = "wlp5s0";
        networkConfig.DHCP = "ipv4";
        dhcpV4Config = {
          RouteMetric = 20;
          UseDNS = false;
        };
        dhcpV6Config.UseDNS = false;
        ipv6AcceptRAConfig = {
          RouteMetric = 20;
          UseDNS = false;
        };
      };
    };
    wait-online.anyInterface = true;
  };

  services.tailscale.enable = true;
  # otherwise tailscale gets stuck on shutdown trying to send logs
  systemd.services.tailscaled = {
    after = ["nss-lookup.target" "network-online.target"];
    wants = ["network-online.target"];
  };
}
