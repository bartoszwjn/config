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
      default_bind ${systemPrivateConfig.tailscale.ipv4} [${systemPrivateConfig.tailscale.ipv6}]
    '';
    # `get_certificate tailscale` should not be needed for `.ts.net` domains, but it is...
    virtualHosts."${systemPrivateConfig.tailscale.fqdn}:8123".extraConfig = ''
      reverse_proxy "127.0.0.1:8123"
      tls {
        get_certificate tailscale
      }
    '';
    virtualHosts."http://${systemPrivateConfig.tailscale.fqdn}:8124" = {
      serverAliases = [
        "http://${systemPrivateConfig.tailscale.ipv4}:8124"
        "http://[${systemPrivateConfig.tailscale.ipv6}]:8124"
      ];
      extraConfig = ''
        reverse_proxy "127.0.0.1:8123"
      '';
    };
  };

  systemd.services.caddy = {
    requires = [ "tailscale-online.service" ];
    after = [ "tailscale-online.service" ];
  };
}
