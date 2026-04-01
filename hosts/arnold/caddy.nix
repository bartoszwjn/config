{
  config,
  lib,
  pkgs,
  privateConfig,
  ...
}:

let
  systemPrivateConfig = privateConfig.hosts.arnold;
in
{
  services.tailscale.permitCertUid = "caddy";

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    8123 # home assistant
  ];

  services.caddy = {
    enable = true;
    email = "bartoszwjn+caddyarnold@gmail.com";
    resume = false;
    # logFormat = "level DEBUG"; # useful for debugging, NixOS sets it to ERROR by default
    globalConfig = ''
      default_bind ${systemPrivateConfig.tailscale.ipv4}
    '';
    # `get_certificate tailscale` should not be needed for `.ts.net` domains, but it is...
    virtualHosts."${config.networking.fqdn}:8123".extraConfig = ''
      reverse_proxy "127.0.0.1:8123"
      tls {
        get_certificate tailscale
      }
    '';
  };

  systemd.services.caddy = {
    requires = [ "tailscaled.service" ];
    after = [ "tailscaled.service" ];
    # waiting for tailscaled is not enough, and it still fails on boot with
    # `cannot assign requested address`, so we try restarting a few times
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = lib.mkForce "3s";
      RestartPreventExitStatus = lib.mkForce "";
    };
    startLimitIntervalSec = lib.mkForce 60;
    startLimitBurst = lib.mkForce 20;
  };
}
