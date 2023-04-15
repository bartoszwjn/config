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
      archman
      bat
      cargo-edit
      cargo-expand
      cargo-outdated
      emacs-all-the-icons-fonts
      fzf
      git-review
      jq
      just
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
