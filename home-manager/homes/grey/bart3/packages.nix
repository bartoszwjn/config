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
      awscli2
      dmenu
      emacs
      feh
      firefox
      google-cloud-sdk
      keepassxc
      libreoffice-fresh
      mlocate
      nextcloud-client
      pasystray
      picom
      playerctl
      postgresql
      pulsemixer
      rsync
      scrot
      slack
      solaar
      teams
      terraform
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
