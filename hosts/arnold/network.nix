{
  config,
  lib,
  pkgs,
  privateConfig,
  ...
}:

{
  networking = {
    hostName = "arnold";
    domain = privateConfig.common.tailscale.tailnetDnsName;
    hostId = "40cb7820";
    useDHCP = true;
  };

  services.tailscale.enable = true;

  # https://github.com/tailscale/tailscale/issues/11504#issuecomment-2667381779
  systemd.services.tailscale-online = {
    after = ["tailscaled.service"];
    bindsTo = ["tailscaled.service"];
    script = ''
      until ${lib.getExe' config.services.tailscale.package "tailscale"} status --peers=false; do
        sleep 1
      done
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutSec = "60s";
    };
  };
}
