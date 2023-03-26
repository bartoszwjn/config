{
  pkgs,
  ra,
}: let
  system = pkgs.stdenv.hostPlatform.system;
in {
  chatterino2 = pkgs.libsForQt5.callPackage ./chatterino2.nix {};
  ra = ra.packages.${system}.default;
}
