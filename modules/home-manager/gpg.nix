{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.gpg;
in
{
  options.custom.gpg = {
    enable = lib.mkEnableOption "gpg with custom config";
  };

  config = lib.mkIf cfg.enable {
    programs.gpg.enable = true;

    services.gpg-agent = {
      enable = true;
      enableScDaemon = true;
      defaultCacheTtl = 3600; # seconds
      pinentry.package = pkgs.pinentry-curses;
    };

    custom.shell.nu.extraAutoloadFiles."gpg-agent.nu" = pkgs.writeText "gpg-agent-nushell-config.nu" ''
      $env.GPG_TTY = (tty)
    '';
  };
}
