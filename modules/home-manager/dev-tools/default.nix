{
  config,
  lib,
  pkgs,
  customPkgs,
  ...
}:
let
  cfg = config.custom.dev-tools;
in
{
  options.custom.dev-tools = {
    general = lib.mkEnableOption "general dev tools";
    jsonnet = lib.mkEnableOption "jsonnet dev tools";
    lua = lib.mkEnableOption "Lua dev tools";
    nix = lib.mkEnableOption "Nix dev tools";
    python = lib.mkEnableOption "Python dev tools";
    rust = lib.mkEnableOption "Rust dev tools";
    terraform = lib.mkEnableOption "terraform config";

    git = {
      enable = lib.mkEnableOption "git with custom config";
      userEmail = lib.mkOption {
        type = lib.types.oneOf [
          lib.types.str
          (lib.types.attrsOf lib.types.str)
        ];
        description = ''
          Default user email to use, either a single value that applies globally, or an attribute
          set mapping directory paths to emails that will be used for repositories located in these
          directories.
        '';
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.general {
      home.packages = builtins.attrValues {
        inherit (pkgs)
          cmake
          gnumake
          just
          shellcheck
          ;
      };
    })

    (lib.mkIf cfg.jsonnet {
      home.packages = builtins.attrValues {
        inherit (pkgs) go-jsonnet jsonnet-bundler jsonnet-language-server;
      };
    })

    (lib.mkIf cfg.lua { home.packages = [ pkgs.lua-language-server ]; })

    (lib.mkIf cfg.nix {
      home.packages = builtins.attrValues {
        inherit (pkgs)
          alejandra
          nix-diff
          nix-output-monitor
          nix-prefetch-git
          nix-prefetch-github
          nix-tree
          nixfmt-rfc-style
          nvd
          ;
        inherit (customPkgs)
          deploy-utils
          ndf
          ;
      };
    })

    (lib.mkIf cfg.python {
      home.packages = builtins.attrValues {
        inherit (pkgs)
          black
          isort
          mypy
          pyright
          python3
          uv
          ;
        inherit (pkgs.python3Packages) ipython;
      };
    })

    (lib.mkIf cfg.rust {
      home = {
        packages = builtins.attrValues {
          inherit (pkgs)
            cargo
            cargo-edit
            cargo-expand
            cargo-outdated
            clippy
            gcc # linker
            rust-analyzer
            rustc
            rustfmt
            ;
        };

        sessionPath = [ (config.home.homeDirectory + "/.cargo/bin") ];

        file.".cargo/config.toml".source = (pkgs.formats.toml { }).generate "cargo-config.toml" {
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
    })

    (lib.mkIf cfg.terraform {
      home.file.".terraformrc".text = ''
        plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"
      '';

      systemd.user.tmpfiles.rules = [
        #Type Path                         Mode User Group Age Argument
        "d    %h/.terraform.d              0755 -    -     -"
        "d    %h/.terraform.d/plugin-cache 0755 -    -     -"
      ];
    })

    (lib.mkIf cfg.git.enable {
      home.packages = [ pkgs.gitui ];

      programs.git = {
        enable = true;
        userName = "Bartosz Wojno";
        userEmail = lib.mkIf (builtins.isString cfg.git.userEmail) cfg.git.userEmail;
        extraConfig = {
          advice.detachedHead = false;
          diff.sops.textconv = "sops decrypt";
          init.defaultBranch = "main";
          log.date = "format:%a %F %T %z";
          pull.ff = "only";
        };
        includes = lib.mkIf (builtins.isAttrs cfg.git.userEmail) (
          lib.mapAttrsToList (dir: email: {
            condition = "gitdir:${dir}";
            contents.user.email = email;
          }) cfg.git.userEmail
        );
      };

      xdg.configFile = {
        "gitui/key_bindings.ron".source = ./gitui-key-bindings.ron;
        "gitui/key_symbols.ron".source = ./gitui-key-symbols.ron;
      };
    })
  ];
}
