{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.shell.zoxide;
in
{
  options.custom.shell.zoxide = {
    enable = lib.mkEnableOption "zoxide smart cd command";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.fzf
    ];

    programs.zoxide.enable = true;

    programs.zoxide.enableZshIntegration = true;

    custom.shell.nu.extraAutoloadFiles."zoxide.nu" =
      pkgs.runCommand "zoxide-nushell-config.nu"
        { nativeBuildInputs = [ config.programs.zoxide.package ]; }
        ''
          zoxide init nushell ${lib.escapeShellArgs config.programs.zoxide.options} > "$out"
        '';
  };
}
