{
  config,
  lib,
  pkgs,
  ...
}: let
  # include `types/ed` into `types/complete` as there seems no way to use anything other than
  # `types/complete` with `xorg.conf`
  customTypesPatch = ./custom-types.patch;

  addPatch = pkg: pkg.overrideAttrs (old: {patches = (old.patches or []) ++ [customTypesPatch];});
  patch_xkeyboardconfig_custom = xorg: {
    xkeyboardconfig_custom = args: addPatch (xorg.xkeyboardconfig_custom args);
  };
  customTypesOverlay = final: prev: {xorg = prev.xorg // patch_xkeyboardconfig_custom prev.xorg;};
in {
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

  nixpkgs.overlays = [customTypesOverlay];
}
