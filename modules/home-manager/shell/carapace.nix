{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.shell.carapace;
in
{
  options.custom.shell.carapace = {
    enable = lib.mkEnableOption "carapace shell completion library";
  };

  config = lib.mkIf cfg.enable {
    programs.carapace.enable = true;

    programs.carapace.enableZshIntegration = true;

    custom.shell.nu.extraAutoloadFiles."carapace.nu" =
      pkgs.runCommand "carapace-nushell-config.nu"
        { nativeBuildInputs = [ config.programs.carapace.package ]; }
        ''
          carapace _carapace nushell > "$out"
          substituteInPlace "$out" --replace-fail '"/homeless-shelter' '$"($env.HOME)'
        '';
  };
}
