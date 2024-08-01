{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.i18n;
in
{
  options.custom.i18n = {
    enable = lib.mkEnableOption "custom locale config";
  };

  config = lib.mkIf cfg.enable {
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_COLLATE = "C";
        LC_TIME = "en_GB.UTF-8";
      };
      supportedLocales = [
        "C.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
        "en_GB.UTF-8/UTF-8"
        "pl_PL.UTF-8/UTF-8"
      ];
    };
  };
}
