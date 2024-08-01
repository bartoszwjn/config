{
  config,
  lib,
  pkgs,
  ...
}:
{
  custom = {
    dns.enable = true;
    network = {
      enable = true;
      interfaces = [ "enp5s0" ];
    };
  };

  networking = {
    hostName = "blue";
    firewall.interfaces.tailscale0 = {
      allowedTCPPorts = [ 22000 ]; # syncthing
      allowedUDPPorts = [ 22000 ]; # syncthing
    };
  };

  services.tailscale.enable = true;
  # otherwise tailscale gets stuck on shutdown trying to send logs
  systemd.services.tailscaled = {
    after = [
      "nss-lookup.target"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
  };
}
