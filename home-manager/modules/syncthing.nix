{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: let
  inherit (lib) types;
  jsonFormat = pkgs.formats.json {};

  cfg = config.custom.syncthing;
in {
  options.custom.syncthing = {
    enable = lib.mkEnableOption "Syncthing with custom configuration";

    guiAddress = lib.mkOption {
      type = types.str;
      default = "127.0.0.1:8384";
      description = "The address to serve the web interface at";
    };

    homeDir = lib.mkOption {
      type = types.path;
      default = "${config.xdg.configHome}/syncthing";
      defaultText = lib.literalExpression ''"''${config.xdg.configHome}/syncthing"'';
      description = "Path to Syncthing's configuration and data directory";
    };
    certFile = lib.mkOption {
      type = types.path;
      description = ''
        Path to the `cert.pem` file, which will be copied into Syncthing's config directory
      '';
    };
    encryptedKeyFile = lib.mkOption {
      type = types.path;
      description = ''
        Path to the `key.pem` file, encrypted using sops, which will be decrypted and copied into
        Syncthing's config directory
      '';
    };

    settings = lib.mkOption {
      description = ''
        [Configuration options](https://docs.syncthing.net/users/config.html) to apply at startup,
        in the format used by the [REST API](https://docs.syncthing.net/rest/config.html).
      '';
      type = types.submodule {
        freeformType = jsonFormat.type;
        options = {
          version = lib.mkOption {
            type = types.int;
          };

          devices = lib.mkOption {
            default = {};
            type = types.attrsOf (types.submodule ({name, ...}: {
              freeformType = jsonFormat.type;
              options = {
                name = lib.mkOption {
                  type = types.str;
                  default = name;
                };
                deviceID = lib.mkOption {
                  type = types.str;
                };
              };
            }));
          };

          folders = lib.mkOption {
            default = {};
            type = types.attrsOf (types.submodule ({name, ...}: {
              freeformType = jsonFormat.type;
              options = {
                label = lib.mkOption {
                  type = types.str;
                  default = name;
                };
                id = lib.mkOption {
                  type = types.str;
                  default = name;
                };
                path = lib.mkOption {
                  type = types.addCheck types.str (
                    x: lib.strings.hasPrefix "/" x || lib.strings.hasPrefix "~/" x
                  );
                };
                devices = lib.mkOption {
                  type = types.listOf types.str;
                  default = [];
                  description = ''
                    List of device names the folder should be shared with. Each device must be
                    defined in the `custom.syncthing.settings.devices` option.
                  '';
                };
              };
            }));
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    custom.syncthing.settings = {
      version = 37;

      options = {
        globalAnnounceEnabled = false;
        localAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
        urAccepted = -1;
        minHomeDiskFree = {
          value = 5;
          unit = "%";
        };
        stunKeepaliveStartS = 0; # disable contacting STUN servers
        announceLANAddresses = false;
      };

      gui.address = cfg.guiAddress;

      devices = let
        privateConfig = flakeInputs.private-config.lib;
      in {
        arnold = {
          deviceID = privateConfig.arnold.syncthing.deviceId;
          addresses = ["tcp://${privateConfig.arnold.tailscale.fqdn}:22000"];
        };
        blue = {
          deviceID = privateConfig.blue.bartoszwjn.syncthing.deviceId;
          addresses = ["tcp://${privateConfig.blue.tailscale.fqdn}:22000"];
        };
        grey = {
          deviceID = privateConfig.grey.bartoszwjn.syncthing.deviceId;
          addresses = ["tcp://${privateConfig.grey.tailscale.fqdn}:22000"];
        };
        grey-bart3 = {
          deviceID = privateConfig.grey.bart3.syncthing.deviceId;
          addresses = ["tcp://${privateConfig.grey.tailscale.fqdn}:22001"];
        };
        red = {
          deviceID = privateConfig.red.syncthing.deviceId;
          addresses = ["tcp://${privateConfig.red.tailscale.fqdn}:22000"];
        };
      };

      folders = {
        bartoszwjn-main = {
          path = "~/syncthing";
          minDiskFree = {
            value = 5;
            unit = "%";
          };
        };
      };
    };

    home.packages = [pkgs.syncthing];

    services.syncthing = {
      enable = true;
      extraOptions = [
        "--no-default-folder"
        "--no-upgrade"
        "--skip-port-probing"
        "--home=${cfg.homeDir}"
        "--gui-address=${cfg.guiAddress}"
      ];
      tray.enable = true;
    };

    systemd.user.services.syncthing = {
      Service.ExecStartPre = let
        install = "${pkgs.coreutils}/bin/install";
        keyFile = "$XDG_RUNTIME_DIR/secrets/syncthing-key.pem";
      in
        pkgs.writeShellScript "syncthing-copy-keys" ''
          set -euo pipefail

          ${install} -dm700 ${cfg.homeDir}
          ${install} -Dm400 ${cfg.certFile} ${cfg.homeDir}/cert.pem
          ${install} -Dm400 ${keyFile} ${cfg.homeDir}/key.pem
        '';
      Unit.After = ["sops-nix.service"];
    };

    sops.secrets."syncthing-key.pem" = {
      sopsFile = cfg.encryptedKeyFile;
      format = "binary";
    };

    systemd.user.services.syncthing-config = let
      newConfig =
        cfg.settings
        // {
          devices = builtins.attrValues cfg.settings.devices;
          folders = lib.attrsets.mapAttrsToList (_: folder: mkFolder folder) cfg.settings.folders;
        };
      mkFolder = folder: folder // {devices = map mkFolderDevice folder.devices;};
      mkFolderDevice = deviceName: {deviceID = cfg.settings.devices.${deviceName}.deviceID;};

      curlAddr = path:
        if lib.strings.hasPrefix "/" cfg.guiAddress
        then "--unix-socket ${cfg.guiAddress} http://.${path}"
        else "${cfg.guiAddress}${path}";
    in {
      Unit = {
        Description = "Syncthing configuration updater";
        Requisite = ["syncthing.service"];
        After = ["syncthing.service"];
      };
      Install.WantedBy = ["default.target"];
      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        RuntimeDirectory = "syncthing-config";
        ExecStart = pkgs.writeShellScript "syncthing-update-config" ''
          set -euo pipefail
          umask 0077

          while
            ! ${pkgs.libxml2}/bin/xmllint \
              --xpath 'string(configuration/gui/apikey)' \
              ${cfg.homeDir}/config.xml \
              > "$RUNTIME_DIRECTORY/api_key"
          do ${pkgs.coreutils}/bin/sleep 1; done

          # Keep the old API key to not break things like syncthingtray
          ${pkgs.jq}/bin/jq --compact-output --rawfile apiKey "$RUNTIME_DIRECTORY/api_key" \
            '. * {"gui": {"apiKey": ($apiKey | rtrimstr("\n"))}}' \
            <<< ${lib.escapeShellArg (builtins.toJSON newConfig)} \
            > "$RUNTIME_DIRECTORY/new_config"

          (
            printf "X-API-Key: "
            ${pkgs.coreutils}/bin/cat "$RUNTIME_DIRECTORY/api_key"
          ) > "$RUNTIME_DIRECTORY/headers"

          function curl () {
            ${pkgs.curl}/bin/curl --fail --silent --show-error --location --insecure \
              --header "@$RUNTIME_DIRECTORY/headers" \
              --retry 100 --retry-delay 1 --retry-connrefused \
              "$@"
          }

          curl -X PUT --data "@$RUNTIME_DIRECTORY/new_config" \
            --header "Content-Type: application/json" \
            ${curlAddr "/rest/config"}

          restart_required=$(
            curl ${curlAddr "/rest/config/restart-required"} | ${pkgs.jq}/bin/jq .requiresRestart
          )
          case "$restart_required" in
            true) curl -X POST ${curlAddr "/rest/system/restart"} ;;
            false) ;;
            *) echo "Unexpected value of requiresRestart: $restart_required"; exit 1 ;;
          esac
        '';
      };
    };
  };
}
