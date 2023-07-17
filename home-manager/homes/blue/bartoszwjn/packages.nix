{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = builtins.attrValues {
    inherit
      (pkgs)
      alacritty
      arc-icon-theme
      arc-theme
      chatterino2
      discord
      dmenu
      emacs
      feh
      firefox
      keepassxc
      libreoffice-fresh
      mlocate
      nextcloud-client
      pasystray
      picom
      playerctl
      pulsemixer
      rsync
      scrot
      solaar
      tree
      unzip
      vim
      wally-cli
      xournalpp
      xss-lock
      zathura
      zip
      zsh-completions
      ;
    inherit (pkgs.gnome) seahorse;
    inherit (pkgs.xorg) xev xrandr xmodmap xinit;
  };
}
