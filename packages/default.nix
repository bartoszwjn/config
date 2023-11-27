{pkgs}: {
  bash_3_2 = pkgs.callPackage ./bash_3_2.nix {};
  chatterino2 = pkgs.libsForQt5.callPackage ./chatterino2.nix {};
}
