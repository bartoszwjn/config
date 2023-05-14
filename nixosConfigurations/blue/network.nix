{
  config,
  lib,
  pkgs,
  ...
}: {
  custom.dns.enable = true;

  networking = {
    hostName = "blue";
    dhcpcd.enable = false;
    firewall.enable = true;
  };

  systemd.network = {
    enable = true;
    networks = {
      "10-wired" = {
        matchConfig.Name = "enp5s0";
        networkConfig.DHCP = "ipv4";
        dhcpV4Config.UseDNS = false;
        dhcpV6Config.UseDNS = false;
        ipv6AcceptRAConfig.UseDNS = false;
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
