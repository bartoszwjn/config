{
  pkgs,
  ...
}:
{
  projectRootFile = "flake.nix";

  settings.on-unmatched = "info";

  programs.nixfmt.enable = true;
}
