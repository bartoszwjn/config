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
    programs.man = {
      enable = true;
      generateCaches = true;
    };
  };
}
