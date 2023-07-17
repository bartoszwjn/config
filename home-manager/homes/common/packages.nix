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
      emacs-all-the-icons-fonts
      fzf
      git-review
      jq
      libnotify
      nasm
      ncdu
      nerdfonts
      nix-zsh-completions
      nushell
      rclone
      ripgrep
      signal-desktop
      sops
      spotify
      ;
    inherit (pkgs.haskellPackages) xmobar;
  };
}
