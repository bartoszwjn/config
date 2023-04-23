{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.keyboardLayout;
in {
  options.custom.keyboardLayout = {
    enable = lib.mkEnableOption "custom ErgoDox/Moonlander layout for X11";
  };

  config = lib.mkIf (cfg.enable) {
    services.xserver = {
      layout = "ed";
      xkbOptions = "lv3:ralt_switch";
      extraLayouts.ed = {
        description = "Custom ED layout";
        languages = ["eng" "pol"];
        symbolsFile = ./symbols/ed;
        typesFile = ./types/ed;
      };
    };

    # include `types/ed` into `types/complete` as there seems to be no way to use anything other
    # than `types/complete` with `xorg.conf`
    nixpkgs.overlays = let
      updateAttr = name: fn: attrset: attrset // {${name} = fn attrset.${name};};
      addPatch = xkeyboardconfig_custom: args:
        (xkeyboardconfig_custom args).overrideAttrs (old: {
          patches = (old.patches or []) ++ [./custom-types.patch];
        });
    in [(final: prev: {xorg = updateAttr "xkeyboardconfig_custom" addPatch prev.xorg;})];
  };
}
