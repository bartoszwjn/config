{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  cfg = config.custom.keyring;
in
{
  options.custom.keyring = {
    enable = lib.mkEnableOption "user-level keyring configuration";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = osConfig.services.gnome.gcr-ssh-agent.enable == true;
        message = ''
          user-level keyring configuration requires enabling gcr-ssh-agent in the NixOS configuration
        '';
      }
    ];

    home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gcr/ssh";
  };
}
