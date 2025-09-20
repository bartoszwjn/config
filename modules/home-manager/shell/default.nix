{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.shell;
in
{
  imports = [
    ./carapace.nix
    ./direnv
    ./nu
    ./starship.nix
    ./zoxide.nix
    ./zsh.nix
  ];

  options.custom.shell = {
    enable = lib.mkEnableOption "shell configuration";
  };

  config = lib.mkIf cfg.enable {
    custom.shell = {
      nu.enable = true;
      zsh.enable = true;

      carapace.enable = true;
      direnv.enable = true;
      starship.enable = true;
      zoxide.enable = true;
    };
  };
}
