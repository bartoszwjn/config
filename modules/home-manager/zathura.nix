{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.zathura;
in
{
  options.custom.zathura = {
    enable = lib.mkEnableOption "zathura with custom config";
  };

  config = lib.mkIf cfg.enable {
    programs.zathura = {
      enable = true;

      options = {
        recolor = true;
        recolor-darkcolor = "#cccccc";
        recolor-lightcolor = "#1e2027";
        recolor-keephue = true;

        show-recent = 2;

        window-title-home-tilde = true;
        statusbar-home-tilde = true;

        selection-clipboard = "clipboard";
      };
    };
  };
}
