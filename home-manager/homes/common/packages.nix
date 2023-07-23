{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = builtins.attrValues {
    inherit
      (pkgs)
      age
      arc-icon-theme
      arc-theme
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
      nerdfonts
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
      xournalpp
      zathura
      zip
      ;
    inherit (pkgs.gnome) seahorse;
    inherit (pkgs.xorg) xev xrandr xmodmap xinit;
  };
}
