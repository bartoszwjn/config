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
    enable = lib.mkEnableOption "keyring daemon";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = osConfig.services.gnome.gnome-keyring.enable == true;
        message = ''
          gnome-keyring user service requires enabling gnome-keyring in the NixOS configuration
        '';
      }
    ];

    home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";
    # `pkgs.gnome.gnome-keyring` doesn't have the right process capabilities. Enabling
    # `services.gnome.gnome-keyring` in the NixOS configuration makes the daemon autostart without
    # the ssh component.
    systemd.user.services.gnome-keyring = {
      Unit = {
        Description = "GNOME Keyring";
        PartOf = [ "graphical-session-pre.target" ];
      };
      Install.WantedBy = [ "graphical-session-pre.target" ];
      Service = {
        ExecStart = "${osConfig.security.wrapperDir}/gnome-keyring-daemon --start --foreground";
        Restart = "on-abort";
      };
    };
  };
}
