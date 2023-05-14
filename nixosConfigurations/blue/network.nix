{
  config,
  lib,
  pkgs,
  ...
}: {
  custom = {
    dns.enable = true;
    network = {
      enable = true;
      interfaces = ["enp5s0"];
    };
  };

  networking.hostName = "blue";

  services.tailscale.enable = true;
  # otherwise tailscale gets stuck on shutdown trying to send logs
  systemd.services.tailscaled = {
    after = ["nss-lookup.target" "network-online.target"];
    wants = ["network-online.target"];
  };
}
