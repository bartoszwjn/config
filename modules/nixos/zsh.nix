{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.zsh;
in {
  options.custom.zsh = {
    enable = lib.mkEnableOption "system-wide config needed for user-level zsh configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableBashCompletion = true;
    };
  };
}
