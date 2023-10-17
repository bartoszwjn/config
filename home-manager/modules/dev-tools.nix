{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.dev-tools;
in {
  options.custom.dev-tools = {
    general = lib.mkEnableOption "general dev tools";
    nix = lib.mkEnableOption "Nix dev tools";
    python = lib.mkEnableOption "Python dev tools";
    rust = lib.mkEnableOption "Rust dev tools";

    git = {
      enable = lib.mkEnableOption "git with custom config";
      userEmail = lib.mkOption {
        type = lib.types.oneOf [lib.types.str (lib.types.attrsOf lib.types.str)];
        description = ''
          Default user email to use, either a single value that applies globally, or an attribute
          set mapping directory paths to emails that will be used for repositories located in these
          directories.
        '';
      };
    };
  };

  config = {
    home = {
      packages =
        lib.optionals cfg.general (builtins.attrValues {
          inherit (pkgs) cmake gnumake just shellcheck;
        })
        ++ lib.optionals cfg.nix (builtins.attrValues {
          inherit (pkgs) alejandra nix-diff nix-prefetch-git nix-prefetch-github;
        })
        ++ lib.optionals cfg.python (builtins.attrValues {
          inherit (pkgs) black isort mypy poetry python3;
          inherit (pkgs.nodePackages) pyright;
          inherit (pkgs.python3Packages) ipython;
        })
        ++ lib.optionals cfg.rust (builtins.attrValues {
          inherit (pkgs) cargo-edit cargo-expand cargo-outdated rust-analyzer;
          inherit (pkgs.fenix.stable) defaultToolchain;
        });

      sessionPath = lib.optional cfg.rust (config.home.homeDirectory + "/.cargo/bin");

      file = lib.optionalAttrs cfg.rust {
        ".cargo/config".source = (pkgs.formats.toml {}).generate "cargo-config.toml" {
          alias = {
            b = "build";
            br = "build --release";
            c = "check";
            ca = "check --all-targets";
            d = "doc --document-private-items --no-deps";
            do = "doc --document-private-items --no-deps --open";
            r = "run";
            rr = "run --release";
            t = "test";
          };
          cargo-new = {
            name = "Bartosz Wojno";
            email = "bartoszwjn@gmail.com";
            vcs = "git";
          };
        };
      };
    };

    programs.git = lib.mkIf cfg.git.enable {
      enable = true;
      userName = "Bartosz Wojno";
      userEmail = lib.mkIf (builtins.isString cfg.git.userEmail) cfg.git.userEmail;
      extraConfig = {
        advice.detachedHead = false;
        init.defaultBranch = "main";
        pull.ff = "only";
      };
      includes = lib.mkIf (builtins.isAttrs cfg.git.userEmail) (
        lib.flip lib.mapAttrsToList cfg.git.userEmail (dir: email: {
          condition = "gitdir:${dir}";
          contents.user.email = email;
        })
      );
    };
  };
}
