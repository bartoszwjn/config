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
  };

  config = {
    home = {
      packages =
        lib.optionals cfg.general (builtins.attrValues {
          inherit (pkgs) cmake gnumake just;
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
  };
}
