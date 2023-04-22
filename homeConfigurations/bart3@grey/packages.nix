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
      black
      cmake
      dmenu
      emacs
      feh
      firefox
      google-cloud-sdk
      isort
      keepassxc
      libreoffice-fresh
      mlocate
      mypy
      nextcloud-client
      pasystray
      picom
      playerctl
      pulsemixer
      python3
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
    inherit (pkgs.nodePackages) pyright;
    inherit (pkgs.python3Packages) ipython;
    inherit (pkgs.xorg) xev xrandr xmodmap xinit;
  };
}
