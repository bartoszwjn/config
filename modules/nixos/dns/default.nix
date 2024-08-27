{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.dns;

  # Using `config.systemd.services.dnscrypt-proxy2.serviceConfig` to define
  # `services.dnscrypt-proxy2.settings` results in infinite recursion
  systemdDir = "dnscrypt-proxy";
  cacheDirectory = "/var/cache/${systemdDir}";
  logsDirectory = "/var/log/${systemdDir}";
in
{
  options.custom.dns = {
    enable = lib.mkEnableOption "DNS configuration";
    disableWithSpecialisation = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to create a specialisation that disables the custom DNS configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    specialisation = lib.mkIf cfg.disableWithSpecialisation {
      normal-dns.configuration = {
        custom.dns.enable = lib.mkOverride 99 false; # between mkForce (50) and no override (100)
      };
    };

    assertions =
      let
        systemdCfg = config.systemd.services.dnscrypt-proxy2.serviceConfig;
        dirs = [
          "CacheDirectory"
          "LogsDirectory"
          "RuntimeDirectory"
          "StateDirectory"
        ];
      in
      map (dir: {
        assertion = systemdDir == systemdCfg.${dir};
        message =
          "systemd ${dir} for dnscrypt-proxy is ${systemdCfg.${dir}},"
          + " but the configuration expects ${systemdDir}";
      }) dirs;

    networking.nameservers = [ "127.0.0.1:53" ];

    services = {
      resolved.enable = true;

      dnscrypt-proxy2 = {
        enable = true;
        upstreamDefaults = false;
        settings = {
          listen_addresses = [ "127.0.0.1:53" ];
          max_clients = 250;
          force_tcp = false;
          http3 = false; # experimental
          timeout = 3000; # milliseconds
          keepalive = 30; # seconds, keepalive for HTTP (HTTPS, HTTP/2, HTTP/3) queries
          cert_refresh_delay = 240; # minutes
          cert_ignore_timestamp = false;
          dnscrypt_ephemeral_keys = false;
          tls_disable_session_tickets = false;
          offline_mode = false;

          bootstrap_resolvers = [
            "9.9.9.9:53"
            "[2620:fe::fe]:53"
            "149.112.112.112:53"
            "[2620:fe::9]:53"
          ];
          ignore_system_dns = true;
          netprobe_timeout = 10; # seconds
          netprobe_address = "9.9.9.9:53";

          lb_strategy = "p2";
          lb_estimator = true;

          log_level = 2; # 0-6, default is 2, 0 is the most verbose
          log_file = "${logsDirectory}/dnscrypt-proxy.log";
          log_file_latest = false;
          use_syslog = true;
          log_files_max_size = 10; # MB
          log_files_max_age = 7; # days
          log_files_max_backups = 1;

          cache = true;
          cache_size = 4096;
          cache_min_ttl = 2400; # seconds (40 minutes)
          cache_max_ttl = 86400; # seconds (24 hours)
          cache_neg_min_ttl = 60; # seconds (1 minute)
          cache_neg_max_ttl = 600; # seconds (10 minutes)

          server_names = [
            "quad9-dnscrypt-ip4-filter-pri"
            "quad9-dnscrypt-ip4-filter-alt"
            "quad9-dnscrypt-ip4-filter-alt2"
            "quad9-dnscrypt-ip6-filter-pri"
            "quad9-dnscrypt-ip6-filter-alt"
            "quad9-dnscrypt-ip6-filter-alt2"
          ];
          ipv4_servers = true;
          ipv6_servers = true;
          dnscrypt_servers = true;
          doh_servers = true;
          odoh_servers = false;

          # Request filters
          block_ipv6 = false;
          block_unqualified = true;
          block_undelegated = true;
          reject_ttl = 10;
          blocked_query_response = "refused";

          nx_log = {
            file = "${logsDirectory}/nx.log";
            format = "tsv";
          };

          blocked_ips = {
            blocked_ips_file = ./dnscrypt-proxy-blocked-ips.txt;
            log_file = "${logsDirectory}/blocked-ips.log";
            log_format = "tsv";
          };

          sources = {
            public-resolvers = {
              urls = [
                "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
                "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
                "https://ipv6.download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
              ];
              cache_file = "${cacheDirectory}/public-resolvers.md";
              minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
              refresh_delay = 72; # hours
              prefix = "";
            };

            quad9-resolvers = {
              urls = [
                "https://quad9.net/dnscrypt/quad9-resolvers.md"
                "https://raw.githubusercontent.com/Quad9DNS/dnscrypt-settings/main/dnscrypt/quad9-resolvers.md"
              ];
              minisign_key = "RWQBphd2+f6eiAqBsvDZEBXBGHQBJfeG6G+wJPPKxCZMoEQYpmoysKUN";
              cache_file = "${cacheDirectory}/quad9-resolvers.md";
              refresh_delay = 72; # hours
              prefix = "quad9-";
            };
          };

          broken_implementations = {
            fragments_blocked = [
              "cisco"
              "cisco-ipv6"
              "cisco-familyshield"
              "cisco-familyshield-ipv6"
              "cleanbrowsing-adult"
              "cleanbrowsing-adult-ipv6"
              "cleanbrowsing-family"
              "cleanbrowsing-family-ipv6"
              "cleanbrowsing-security"
              "cleanbrowsing-security-ipv6"
            ];
          };
        };
      };
    };

    systemd.network.networks =
      let
        networkCfg = config.custom.network;
      in
      builtins.listToAttrs (
        map (iface: {
          name = networkCfg.interfaceToNetwork.${iface};
          value = {
            dhcpV4Config.UseDNS = false;
            dhcpV6Config.UseDNS = false;
            ipv6AcceptRAConfig.UseDNS = false;
          };
        }) networkCfg.interfaces
      );
  };
}
