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
}
