{
  pkgs,
  ...
}:
{
  projectRootFile = "flake.nix";

  settings.on-unmatched = "info";

  programs.nixfmt.enable = true;

  programs.rustfmt.enable = true;

  programs.stylua = {
    enable = true;
    settings = {
      column_width = 100;
      indent_type = "Spaces";
      indent_width = 2;
      call_parentheses = "NoSingleTable";
      sort_requires.enabled = true;
    };
  };
}
