{pkgs}: {
  bash_3_2 = pkgs.callPackage ./bash_3_2.nix {};
  chatterino2 = pkgs.libsForQt5.callPackage ./chatterino2 {};
  neovim-custom = pkgs.callPackage ./neovim-custom.nix {};
  wl-ss = pkgs.callPackage ./wl-ss/package.nix {};
}
