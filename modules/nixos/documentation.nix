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
    }
    // (
      # Added in https://github.com/NixOS/nixpkgs/pull/488395
      if options ? documentation.man.cache then
        {
          cache.enable = true;
          cache.generateAtRuntime = true;
        }
      # TODO: no longer needed in 26.05
      else
        {
          generateCaches = true;
        }
    );

    environment.systemPackages = [
      pkgs.man-pages
      pkgs.man-pages-posix
    ];
  };
}
