{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.dns;
in
{
  options.custom.dns = {
    enable = lib.mkEnableOption "DNS configuration";
  };

  config = lib.mkIf cfg.enable {
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

    networking.networkmanager.dns = lib.mkOverride 75 "none"; # between `mkForce` and the default
  };
}
