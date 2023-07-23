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
      xournalpp
      zip
      ;
    inherit (pkgs.gnome) seahorse;
    inherit (pkgs.xorg) xev xrandr xmodmap xinit;
  };
}
