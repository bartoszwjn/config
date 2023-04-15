{
  config,
  lib,
  pkgs,
  ...
}: {
  networking = {
    hostName = "blue";
    useDHCP = true;
    firewall.enable = true;
  };

  services.tailscale.enable = true;
  # otherwise tailscale gets stuck on shutdown trying to send logs
  systemd.services.tailscaled = {
    after = ["nss-lookup.target" "network-online.target"];
    wants = ["network-online.target"];
  };
}
