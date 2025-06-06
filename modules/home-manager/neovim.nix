{
  config,
  lib,
  pkgs,
  customPkgs,
  ...
}:
let
  cfg = config.custom.neovim;
in
{
  options.custom.neovim = {
    enable = lib.mkEnableOption "neovim with custom config";
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ customPkgs.neovim-custom ];
      sessionVariables = {
        EDITOR = "nvim";
      };
    };

    systemd.user.tmpfiles.rules = [
      #Type Path    Mode User Group Age Argument
      "d    %C/nvim 0755 -    -     -   -"
    ];
  };
}
