{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.documentation;
in
{
  options.custom.documentation = {
    enable = lib.mkEnableOption "additional documentation";
  };

  config = lib.mkIf cfg.enable {
    documentation.dev.enable = true;

    environment.systemPackages = [
      pkgs.man-pages
      pkgs.man-pages-posix
    ];
  };
}
