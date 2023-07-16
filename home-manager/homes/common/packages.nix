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
      alejandra
      bat
      cargo-edit
      cargo-expand
      cargo-outdated
      emacs-all-the-icons-fonts
      fzf
      git-review
      gnumake
      jq
      just
      libnotify
      nasm
      ncdu
      nerdfonts
      nix-prefetch-git
      nix-prefetch-github
      nix-zsh-completions
      nixfmt
      nushell
      rclone
      ripgrep
      rust-analyzer
      signal-desktop
      sops
      spotify
      ;
    inherit (pkgs.haskellPackages) xmobar;
    rustToolchain = pkgs.fenix.stable.defaultToolchain;
  };
}
