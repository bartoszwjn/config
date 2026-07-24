{
  config,
  lib,
  pkgs,
  options,
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

    documentation.man = {
      enable = true;
      cache.enable = true;
      cache.generateAtRuntime = true;
    };

    environment.systemPackages = [
      pkgs.man-pages
      pkgs.man-pages-posix
    ];
  };
}
