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
      alacritty
      arc-icon-theme
      arc-theme
      bat
      dmenu
      emacs
      emacs-all-the-icons-fonts
      feh
      firefox
      fzf
      git-review
      jq
      keepassxc
      libnotify
      libreoffice-fresh
      mlocate
      nasm
      ncdu
      nerdfonts
      nextcloud-client
      nushell
      pasystray
      picom
      playerctl
      pulsemixer
      rclone
      ripgrep
      rsync
      scrot
      signal-desktop
      solaar
      sops
      spotify
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
    inherit (pkgs.haskellPackages) xmobar;
    inherit (pkgs.xorg) xev xrandr xmodmap xinit;
  };
}
