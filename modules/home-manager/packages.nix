{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.packages;
in
{
  options.custom.packages = {
    cli.core.enable = lib.mkEnableOption "common core CLI packages";
    cli.ext.enable = lib.mkEnableOption "common misc CLI packages";
    gui.enable = lib.mkEnableOption "common misc GUI packages";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.cli.core.enable {
      home.packages = lib.attrValues {
        inherit (pkgs)
          # keep-sorted start
          age
          bat
          eza
          fd
          jq
          ncdu
          ripgrep
          rsync
          sops
          unzip
          vim
          zip
          # keep-sorted end
          ;
      };
    })

    (lib.mkIf cfg.cli.ext.enable {
      home.packages = lib.attrValues {
        inherit (pkgs)
          # keep-sorted start
          bluetui
          brightnessctl
          optipng
          playerctl
          pulsemixer
          rclone
          wally-cli
          wl-clipboard-rs
          # keep-sorted end
          ;
      };
    })

    (lib.mkIf cfg.gui.enable {
      home.packages = lib.attrValues {
        inherit (pkgs)
          # keep-sorted start
          feh
          firefox
          keepassxc
          libnotify
          libreoffice-fresh
          obsidian
          seahorse
          spotify
          xournalpp
          # keep-sorted end
          ;
      };
    })
  ];
}
