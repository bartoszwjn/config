{
  config,
  lib,
  pkgs,
  customPkgs,
  ...
}:
let
  cfg = config.custom.xkb;
in
{
  options.custom.xkb = {
    enable = lib.mkEnableOption "custom xkb keyboard layout";
  };

  config = lib.mkIf cfg.enable {
    # https://xkbcommon.org/doc/current/user-configuration.html#user-config-locations
    #
    # For programs using libxkbcommon this should put the keymap's symbols and types files
    # in the search path with priority higher than the files from `xkeyboard-config`.
    # This allows us to extend `types/complete` with custom types.
    #
    # An alternative way to include `types/custom` with RMLVO configuration could be
    # with the `custom:types` option. However, some graphical environments (e.g. Cosmic)
    # don't allow setting arbitrary options outside of a small set of the most common ones.
    #
    # Including this in the system-wide config instead of the user's home directory
    # allows the layout to be used by the display manager, e.g. to input the login password.
    environment.etc."xkb".source = customPkgs.xkb-keymap-custom.src;
  };
}
