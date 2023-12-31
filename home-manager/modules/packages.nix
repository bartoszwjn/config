{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.packages;
in {
  options.custom.packages = {
    enable = lib.mkEnableOption "all common misc packages";
  };

  config = lib.mkIf cfg.enable {
    home.packages = builtins.attrValues {
      inherit
        (pkgs)
        age
        bat
        fd
        feh
        firefox
        jq
        keepassxc
        libnotify
        libreoffice-fresh
        nasm
        ncdu
        obsidian
        playerctl
        pulsemixer
        rclone
        ripgrep
        rsync
        scrot
        sops
        spotify
        tree
        unzip
        vim
        wally-cli
        xclip
        xournalpp
        zip
        ;
      inherit (pkgs.gnome) seahorse;
      inherit (pkgs.xorg) xev xrandr xmodmap xinit;
    };
  };
}
