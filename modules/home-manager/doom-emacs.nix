{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: let
  cfg = config.custom.doom-emacs;
in {
  options.custom.doom-emacs = {
    enable = lib.mkEnableOption "custom Doom Emacs configuration";

    doomEmacsRoot = lib.mkOption {
      type = lib.types.path;
      default = config.home.homeDirectory + "/repos/doom-emacs";
      defaultText = lib.literalExpression ''config.home.homeDirectory + "/repos/doom-emacs"'';
      description = "Path to a local clone of the Doom Emacs repo";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      sessionPath = [(cfg.doomEmacsRoot + "/bin")];
      sessionVariables = {
        DOOM_EMACS_ROOT = cfg.doomEmacsRoot;
      };
      packages = builtins.attrValues {
        inherit (pkgs) emacs emacs-all-the-icons-fonts fd findutils git ripgrep;
      };

      file = let
        inherit (config.lib.file) mkOutOfStoreSymlink;
      in {
        ".doom.d".source = mkOutOfStoreSymlink (config.custom.repo.configRepoRoot + "/doom-emacs");
        ".emacs-profile".text = "doom";
        ".emacs-profiles.el".text = ''
          (("doom" . ((user-emacs-directory . "${cfg.doomEmacsRoot}")
                      (env . (("DOOMDIR" . "~/.doom.d"))))))
        '';
        ".emacs.d".source = flakeInputs.chemacs2;
      };
    };
  };
}
