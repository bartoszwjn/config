{
  config,
  lib,
  pkgs,
  ...
}: {
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
        networkConfig.DHCP = "yes";
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
