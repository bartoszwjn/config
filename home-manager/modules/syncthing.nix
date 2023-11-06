{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.syncthing;
in {
  options.custom.syncthing = {
    enable = lib.mkEnableOption "Syncthing with custom configuration";

    guiAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1:8384";
      description = "The address to serve the web interface at";
    };

    homeDir = lib.mkOption {
      type = lib.types.path;
      default = "${config.xdg.configHome}/syncthing";
      defaultText = lib.literalExpression ''"''${config.xdg.configHome}/syncthing"'';
      description = "Path to Syncthing's configuration and data directory";
    };
    certFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path to the `cert.pem` file, which will be copied into Syncthing's config directory
      '';
    };
    encryptedKeyFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path to the `key.pem` file, encrypted using sops, which will be decrypted and copied into
        Syncthing's config directory
      '';
    };
  };

  config = lib.mkIf cfg.enable {
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
  };
}
