{
  config,
  lib,
  pkgs,
  privateConfig,
  ...
}:

let
  stateDir = "syncthing";
  systemPrivateConfig = privateConfig.hosts.arnold;
in
{
  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [ 22000 ];
  };

  services.syncthing = {
    enable = true;
    systemService = true;
    # Where the config, keys and the database are stored. Preferably located on an SSD.
    configDir = "/var/lib/${stateDir}";
    # Home dir of the service user, folder paths starting with `~` resolve relative to this.
    dataDir = "/var/lib/${stateDir}";

    cert = "${systemPrivateConfig.syncthing.certFile}";
    key = config.sops.secrets."syncthing-key.pem".path;

    openDefaultPorts = false;
    guiAddress = "127.0.0.1:8384";

    overrideDevices = true;
    overrideFolders = true;

    settings = {
      options = {
        listenAddresses = [ "tcp://${systemPrivateConfig.tailscale.ipv4}:22000" ];
        globalAnnounceEnabled = false;
        localAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
        urAccepted = -1; # no usage reporting
        minHomeDiskFree = {
          value = 1;
          unit = "%";
        };
        crashReportingEnabled = false;
        stunKeepaliveStartS = 0; # disable contacting STUN servers
        announceLANAddresses = false;
      };

      devices = {
        bartoszwjn-blue = {
          id = privateConfig.hosts.blue.bartoszwjn.syncthing.deviceId;
          addresses = [ "tcp://${privateConfig.hosts.blue.tailscale.fqdn}:22000" ];
        };
        bartoszwjn-green = {
          id = privateConfig.hosts.green.bartoszwjn.syncthing.deviceId;
          addresses = [ "tcp://${privateConfig.hosts.green.tailscale.fqdn}:22000" ];
        };
        bartoszwjn-green-bart3 = {
          id = privateConfig.hosts.green.bart3.syncthing.deviceId;
          addresses = [ "tcp://${privateConfig.hosts.green.tailscale.fqdn}:22001" ];
        };
        bartoszwjn-red = {
          id = privateConfig.hosts.red.syncthing.deviceId;
          addresses = [ "tcp://${privateConfig.hosts.red.tailscale.fqdn}:22000" ];
        };
      };

      folders = {
        bartoszwjn-main = {
          path = "/data/syncthing/bartoszwjn-main";
          type = "sendreceive";
          devices = [
            "bartoszwjn-blue"
            "bartoszwjn-green"
            "bartoszwjn-green-bart3"
            "bartoszwjn-red"
          ];
          ignorePerms = false;
          versioning = {
            type = "staggered";
            params.maxAge = "0";
          };
        };
      };
    };
  };

  systemd = {
    services.syncthing = {
      after = [ "systemd-tmpfiles-setup.service" ];
      # create `configDir` in case it's different from `dataDir`
      serviceConfig.StateDirectory = stateDir;
    };
    tmpfiles.rules =
      let
        inherit (config.services.syncthing) user group;
      in
      [
        "d /data/syncthing 0700 ${user} ${group} -"
      ];
  };

  sops.secrets."syncthing-key.pem" = {
    format = "binary";
    sopsFile = systemPrivateConfig.syncthing.encryptedKeyFile;
    owner = config.services.syncthing.user;
    restartUnits = [ "syncthing.service" ];
  };
}
