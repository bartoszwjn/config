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
      black
      chatterino2
      cmake
      discord
      dmenu
      emacs
      feh
      firefox
      gdb
      gimp
      i3lock-color
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
      zsh-syntax-highlighting
      ;
    inherit (pkgs.gnome) seahorse;
    inherit (pkgs.nodePackages) pyright;
    inherit (pkgs.python3Packages) ipython;
    inherit (pkgs.xorg) xev xrandr xmodmap xinit;
  };
}
