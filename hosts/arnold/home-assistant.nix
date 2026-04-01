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
  services.home-assistant = {
    enable = true;
    configDir = "/var/lib/hass";
    extraPackages = pyPkgs: [
      pyPkgs.securetar
    ];
    extraComponents = [
      "esphome"
      "group"
      "met"
      "zha"
    ];
    config = {
      http = {
        server_host = [ "127.0.0.1" ];
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" ];
      };
      homeassistant = {
        inherit (systemPrivateConfig.homeAssistant)
          name
          time_zone
          latitude
          longitude
          elevation
          ;
        unit_system = "metric";
        temperature_unit = "C";
      };
      default_config = { };
      automation = "!include automations.yaml";
      scene = "!include scenes.yaml";
    };
  };
}
