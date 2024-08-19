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
    cli = lib.mkEnableOption "common misc CLI packages";
    gui = lib.mkEnableOption "common misc GUI packages";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.cli {
      home.packages = builtins.attrValues {
        inherit (pkgs)
          age
          bat
          brightnessctl
          eza
          fd
          jq
          nasm
          ncdu
          optipng
          playerctl
          pulsemixer
          rclone
          ripgrep
          rsync
          sops
          unzip
          vim
          wally-cli
          zip
          ;
      };
    })

    (lib.mkIf cfg.gui {
      home.packages = builtins.attrValues {
        inherit (pkgs)
          feh
          firefox
          keepassxc
          libnotify
          libreoffice-fresh
          obsidian
          seahorse
          spotify
          xournalpp
          ;
      };
    })
  ];
}
