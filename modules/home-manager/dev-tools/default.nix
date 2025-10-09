{
  config,
  lib,
  pkgs,
  customPkgs,
  ...
}:
let
  cfg = config.custom.dev-tools;

  tomlFormat = pkgs.formats.toml { };
in
{
  options.custom.dev-tools = {
    enableAll = lib.mkEnableOption "all dev tools";

    general.enable = lib.mkEnableOption "general dev tools";
    jsonnet.enable = lib.mkEnableOption "jsonnet dev tools";
    lua.enable = lib.mkEnableOption "Lua dev tools";
    nix.enable = lib.mkEnableOption "Nix dev tools";
    python.enable = lib.mkEnableOption "Python dev tools";
    rust.enable = lib.mkEnableOption "Rust dev tools";
    terraform.enable = lib.mkEnableOption "terraform config";

    vcs = {
      git.enable = lib.mkEnableOption "git with custom config";

      jujutsu = {
        enable = lib.mkEnableOption "jujutsu with custom config";
        settings = lib.mkOption {
          type = tomlFormat.type;
          description = "Options to add to jujutsu's `config.toml` file.";
        };
      };

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
    (lib.mkIf cfg.enableAll {
      custom.dev-tools = lib.mkDefault {
        general.enable = true;
        jsonnet.enable = true;
        lua.enable = true;
        nix.enable = true;
        python.enable = true;
        rust.enable = true;
        terraform.enable = true;

        vcs.git.enable = true;
        vcs.jujutsu.enable = true;
      };
    })

    (lib.mkIf cfg.general.enable {
      home.packages = lib.attrValues {
        inherit (pkgs)
          cmake
          gnumake
          just
          shellcheck
          ;
      };
    })

    (lib.mkIf cfg.jsonnet.enable {
      home.packages = lib.attrValues {
        inherit (pkgs) go-jsonnet jsonnet-bundler jsonnet-language-server;
      };
    })

    (lib.mkIf cfg.lua.enable { home.packages = [ pkgs.lua-language-server ]; })

    (lib.mkIf cfg.nix.enable {
      home.packages = lib.attrValues {
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

    (lib.mkIf cfg.python.enable {
      home.packages = lib.attrValues {
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

    (lib.mkIf cfg.rust.enable {
      home = {
        packages = lib.attrValues {
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

    (lib.mkIf cfg.terraform.enable {
      home.file.".terraformrc".text = ''
        plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"
      '';

      systemd.user.tmpfiles.rules = [
        #Type Path                         Mode User Group Age Argument
        "d    %h/.terraform.d              0755 -    -     -"
        "d    %h/.terraform.d/plugin-cache 0755 -    -     -"
      ];
    })

    (lib.mkIf cfg.vcs.git.enable {
      home.packages = [ pkgs.gitui ];

      programs.git = {
        enable = true;
        userName = "Bartosz Wojno";
        userEmail = lib.mkIf (lib.isString cfg.vcs.userEmail) cfg.vcs.userEmail;
        extraConfig = {
          advice.detachedHead = false;
          diff.sops.textconv = "sops decrypt";
          init.defaultBranch = "main";
          log.date = "format:%a %F %T %z";
          pull.ff = "only";
        };
        includes = lib.mkIf (lib.isAttrs cfg.vcs.userEmail) (
          lib.mapAttrsToList (dir: email: {
            condition = "gitdir:${dir}";
            contents.user.email = email;
          }) cfg.vcs.userEmail
        );
      };

      xdg.configFile = {
        "gitui/key_bindings.ron".source = ./gitui-key-bindings.ron;
        "gitui/key_symbols.ron".source = ./gitui-key-symbols.ron;
      };
    })

    (lib.mkIf cfg.vcs.jujutsu.enable {
      home.packages = [ pkgs.jujutsu ];

      xdg.configFile."jj/config.toml" = lib.mkIf (cfg.vcs.jujutsu.settings != { }) {
        source = tomlFormat.generate "jj-config.toml" cfg.vcs.jujutsu.settings;
      };

      custom.dev-tools.vcs.jujutsu.settings = {
        user.name = "Bartosz Wojno";
        user.email = lib.mkIf (lib.isString cfg.vcs.userEmail) cfg.vcs.userEmail;
        "--scope" = lib.mkIf (lib.isAttrs cfg.vcs.userEmail) (
          lib.mapAttrsToList (dir: email: {
            "--when".repositories = [ dir ];
            user.email = email;
          }) cfg.vcs.userEmail
        );

        ui.default-command = "log";
        ui.diff-editor = ":builtin";
        ui.pager = ":builtin";
      };
    })
  ];
}
